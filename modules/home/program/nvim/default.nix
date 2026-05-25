{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.vix.program.nvim;
  isServer = cfg.serverMode;
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
    home.packages = [ pkgs.nvimpager ];

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
      # Use the path from pkgs directly to ensure consistency
      nixpkgs.source = pkgs.path;

      # Ensure nixvim generates the init.lua in a way that external tools can see
      # it, but also try to make it self-contained if possible.
      wrapRc = true;

      viAlias = true;
      vimAlias = true;

      # Basic Options (from init.lua and server_opt.lua)
      opts = {
        number = true;
        relativenumber = true;
        mouse = ""; # Disable mouse support
        
        # Default indentation: 4-space tabs
        shiftwidth = 4;
        tabstop = 4;
        expandtab = false; # Use actual tabs
      } // lib.optionalAttrs isServer {
        showmode = false;
        laststatus = 0;
        ruler = false;
        showcmd = false;
        lazyredraw = true;
        fillchars = "eob: ,fold: ,foldsep: ";
        visualbell = false;
        errorbells = false;
      };

      # Filetype specific settings
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
      } // lib.optionalAttrs isServer {
        loaded_matchparen = 1;
      };

      keymaps = (if isServer then [] else [
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
      ]) ++ [
        {
          mode = "n";
          key = "K";
          action = "<cmd>lua vim.diagnostic.open_float()<CR>";
          options.desc = "Show diagnostics";
        }
      ];

      # Core Plugins
      plugins = {
        nvim-surround.enable = true;
        comment.enable = true;
        nvim-autopairs.enable = true;
        gitsigns.enable = true;
        
        treesitter = {
          enable = true;
          settings = {
            ensure_installed = [ "lua" "python" "javascript" "nix" "json" "jsonc" "yaml" "bash" "markdown" ];
            indent.enable = true;
          };
        };

        telescope.enable = !isServer;
        
        cmp = {
          enable = !isServer;
          settings = {
            sources = [
              { name = "nvim_lsp"; }
            ];
            mapping = {
              "<C-n>" = "cmp.mapping.select_next_item()";
              "<C-p>" = "cmp.mapping.select_prev_item()";
              "<C-Space>" = "cmp.mapping.complete()";
              "<C-y>" = "cmp.mapping.confirm({ select = true })";
              "<CR>" = "cmp.mapping.confirm({ select = false })";
            };
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

        none-ls = {
          enable = true;
          sources.formatting.jq.enable = true;
        };

        alpha = lib.mkIf (!isServer) {
          enable = true;
          theme = "dashboard";
        };

        web-devicons.enable = !isServer;
        lualine.enable = !isServer;
        
        nvim-tree = lib.mkIf (!isServer) {
          enable = true;
          settings.view.width = 30;
        };

        indent-blankline.enable = !isServer;
      };

      # Themes
      colorschemes.tokyonight = {
        enable = true;
        settings.style = "night";
      };

    };
  };
}
