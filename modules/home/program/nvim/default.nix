{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.vix.program.nvim;

  # Single factory: returns a nixvim attrset for any serverMode.
  # All shared configuration (opts, parsers, LSP servers, etc.) is
  # defined exactly once here.
  mkNvimConfig = { serverMode ? false }: {
    wrapRc = true;

    extraConfigLuaPre = builtins.readFile ./server-mode.lua;

    opts = {
      number = true;
      relativenumber = true;
      mouse = "";
      shiftwidth = 4;
      tabstop = 4;
      expandtab = false;
    } // lib.optionalAttrs serverMode {
      showmode = false;
      laststatus = 0;
      ruler = false;
      showcmd = false;
      lazyredraw = true;
      fillchars = "eob: ,fold: ,foldsep: ";
      visualbell = false;
      errorbells = false;
    };

    files = {
      "ftplugin/nix.lua".opts = {
        shiftwidth = 2;
        tabstop = 2;
        expandtab = true;
      };
      "ftplugin/yaml.lua".opts = {
        shiftwidth = 2;
        tabstop = 2;
        expandtab = true;
      };
      "ftplugin/json.lua".opts = {
        shiftwidth = 2;
        tabstop = 2;
        expandtab = true;
      };
      "ftplugin/jsonc.lua".opts = {
        shiftwidth = 2;
        tabstop = 2;
        expandtab = true;
      };
    };

    globals = {
      mapleader = " ";
      maplocalleader = " ";
    } // lib.optionalAttrs serverMode {
      loaded_matchparen = 1;
    };

    keymaps = [
      {
        mode = "n";
        key = "K";
        action = "<cmd>lua vim.diagnostic.open_float()<CR>";
        options.desc = "Show diagnostics";
      }
    ] ++ lib.optionals (!serverMode) [
      {
        mode = "n";
        key = "<leader>ff";
        action = "<cmd>Telescope find_files<CR>";
      }
      {
        mode = "n";
        key = "<leader>fg";
        action = "<cmd>Telescope live_grep<CR>";
      }
      {
        mode = "n";
        key = "<leader>e";
        action = "<cmd>NvimTreeToggle<CR>";
      }
    ] ++ lib.optionals serverMode [
      {
        mode = "n";
        key = "<leader>ff";
        action = "<Cmd>call VSCodeNotify('workbench.action.quickOpen')<CR>";
      }
    ];

    plugins = {
      nvim-surround = { enable = true; };
      comment = {
        enable = true;
      } // lib.optionalAttrs serverMode {
        settings = {
          mappings = {
            basic = false;
            extra = false;
          };
        };
      };
      nvim-autopairs = { enable = true; };
      gitsigns = { enable = true; };
      treesitter = {
        enable = true;
        settings = {
          ensure_installed = [
            "lua" "python" "javascript" "nix"
            "json" "jsonc" "yaml" "bash" "markdown"
          ];
          indent.enable = true;
        };
      };
      lsp = {
        enable = true;
        keymaps = {
          silent = true;
          lspBuf = {
            "gd" = "definition";
            "gD" = "declaration";
            "gr" = "references";
            "gi" = "implementation";
            "<leader>rn" = "rename";
            "<leader>ca" = "code_action";
            "<leader>f" = "format";
          };
        };
        servers = {
          nixd = {
            enable = true;
            settings = {
              formatting.command = [ "nixfmt" ];
            };
          };
          jsonls.enable = true;
          yamlls.enable = true;
        };
      };
    } // lib.optionalAttrs (!serverMode) {
      telescope = { enable = true; };
      cmp = {
        enable = true;
        settings = {
          sources = [ { name = "nvim_lsp"; } ];
          mapping = {
            "<C-n>" = "cmp.mapping.select_next_item()";
            "<C-p>" = "cmp.mapping.select_prev_item()";
            "<C-Space>" = "cmp.mapping.complete()";
            "<C-y>" = "cmp.mapping.confirm({ select = true })";
            "<CR>" = "cmp.mapping.confirm({ select = false })";
          };
        };
      };
      alpha = {
        enable = true;
        theme = "dashboard";
      };
      web-devicons = { enable = true; };
      lualine = { enable = true; };
      nvim-tree = {
        enable = true;
        settings.view.width = 30;
      };
      indent-blankline = { enable = true; };
    };

    colorschemes = lib.optionalAttrs (!serverMode) {
      tokyonight = {
        enable = true;
        settings.style = "night";
      };
    };
  };

  # Terminal: full-featured nvim.  Respects the user-facing serverMode
  # option (if someone wants to force a headless-only build).
  terminalConfig = mkNvimConfig { serverMode = cfg.serverMode; };

  # Server: minimal nvim for VSCode / external GUI hosts.
  # No colorscheme, no UI plugins — only the editing core.
  serverConfig = mkNvimConfig { serverMode = true; };

  serverNvim = inputs.nixvim.lib.nixvim.modules.buildNixvimWith {
    system = pkgs.stdenv.hostPlatform.system;
    modules = [ serverConfig ];
  };

  serverNvimBin = pkgs.runCommand "nvim-server" {
    nativeBuildInputs = [ pkgs.makeWrapper ];
  } ''
    mkdir -p $out/bin
    ln -s ${serverNvim}/bin/nvim $out/bin/nvim-server
  '';
in
{
  options.vix.program.nvim = {
    enable = lib.mkEnableOption "Neovim configuration via nixvim";
    serverMode = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable server mode (disables UI plugins for fast headless startup)";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.nvimpager serverNvimBin ];

    home.sessionVariables = {
      EDITOR = "nvim";
      PAGER = "nvimpager";
      # Ensure nvimpager uses the nixvim-wrapped nvim with all plugins
      NVIMPAGER_NVIM = "${config.programs.nixvim.build.package}/bin/nvim";
    };

    vix.program.zsh.extraAliases = {
      editor = "nvim";
      pager = "nvimpager";
    };

    # Link nvimpager config to nvim config
    xdg.configFile."nvimpager/init.lua".source = config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/nvim/init.lua";
    # Sharing data dir helps with some state/plugins
    xdg.dataFile."nvimpager".source = config.lib.file.mkOutOfStoreSymlink "${config.xdg.dataHome}/nvim";

    programs.nixvim = {
      enable = true;
      nixpkgs.source = pkgs.path;
      viAlias = true;
      vimAlias = true;
    } // terminalConfig;
  };
}
