{ config, lib, pkgs, ... }:
let
  nvimConfig = ./config;
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
  };

  home.activation.seedNvimLazyLock = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    lockfile="${config.xdg.configHome}/nvim/lazy-lock.json"
    if [ ! -e "$lockfile" ]; then
      $DRY_RUN_CMD ${pkgs.coreutils}/bin/install -Dm0644 ${nvimConfig}/lazy-lock.json "$lockfile"
    fi
  '';
}
