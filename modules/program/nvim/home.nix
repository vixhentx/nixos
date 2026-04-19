{ config, lib, pkgs, ... }:
let
  inherit (config.lib.file) mkOutOfStoreSymlink;
  nvimConfig = "${config.home.homeDirectory}/.config/nixos/modules/program/nvim/config";
  nvimConfigFile = path: mkOutOfStoreSymlink "${nvimConfig}/${path}";
in
{
  home.packages = with pkgs; [
    fd
    gcc
    git
    gnumake
    nixd
    nixfmt
    ripgrep
    tree-sitter
  ];

  xdg.configFile = {
    "nvim/init.lua".source = nvimConfigFile "init.lua";
    "nvim/lua/config/keymaps.lua".source = nvimConfigFile "lua/config/keymaps.lua";
    "nvim/lua/config/lazy.lua".source = nvimConfigFile "lua/config/lazy.lua";
    "nvim/lua/config/lsp.lua".source = nvimConfigFile "lua/config/lsp.lua";
    "nvim/lua/config/server_opt.lua".source = nvimConfigFile "lua/config/server_opt.lua";
    "nvim/lua/plugins/core.lua".source = nvimConfigFile "lua/plugins/core.lua";
    "nvim/lua/plugins/init.lua".source = nvimConfigFile "lua/plugins/init.lua";
    "nvim/lua/plugins/tools.lua".source = nvimConfigFile "lua/plugins/tools.lua";
    "nvim/lua/plugins/ui.lua".source = nvimConfigFile "lua/plugins/ui.lua";

    # nvimpager defaults to ~/.config/nvimpager instead of ~/.config/nvim.
    # Point it back to the managed nvim config so both share the same setup.
    "nvimpager".source = mkOutOfStoreSymlink "${config.xdg.configHome}/nvim";
  };

  # Share lazy.nvim data/plugins with nvimpager as well, otherwise it will
  # look in ~/.local/share/nvimpager and miss plugins installed under nvim.
  xdg.dataFile."nvimpager".source = mkOutOfStoreSymlink "${config.xdg.dataHome}/nvim";

  home.activation.seedNvimLazyLock = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    lockfile="${config.xdg.configHome}/nvim/lazy-lock.json"
    if [ ! -e "$lockfile" ]; then
      $DRY_RUN_CMD ${pkgs.coreutils}/bin/install -Dm0644 ${nvimConfig}/lazy-lock.json "$lockfile"
    fi
  '';
}
