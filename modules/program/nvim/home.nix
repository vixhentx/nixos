{ config, lib, pkgs, ... }:
let
  nvimConfig = ./config;
  inherit (config.lib.file) mkOutOfStoreSymlink;
in
{
  home.packages = with pkgs; [
    fd
    gcc
    git
    gnumake
    ripgrep
    tree-sitter
  ];

  xdg.configFile = {
    "nvim/init.lua".source = "${nvimConfig}/init.lua";
    "nvim/lua/config/keymaps.lua".source = "${nvimConfig}/lua/config/keymaps.lua";
    "nvim/lua/config/lazy.lua".source = "${nvimConfig}/lua/config/lazy.lua";
    "nvim/lua/config/server_opt.lua".source = "${nvimConfig}/lua/config/server_opt.lua";
    "nvim/lua/plugins/core.lua".source = "${nvimConfig}/lua/plugins/core.lua";
    "nvim/lua/plugins/init.lua".source = "${nvimConfig}/lua/plugins/init.lua";
    "nvim/lua/plugins/tools.lua".source = "${nvimConfig}/lua/plugins/tools.lua";
    "nvim/lua/plugins/ui.lua".source = "${nvimConfig}/lua/plugins/ui.lua";

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
