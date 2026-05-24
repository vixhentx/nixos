{ config, pkgs, ... }:
let
  inherit (config.lib.file) mkOutOfStoreSymlink;
in
{
  home.packages = with pkgs; [
    fd
    gcc
    git
    gnumake
    nixd
    nixfmt-rfc-style
    ripgrep
    tree-sitter
  ];

  xdg.configFile = {
    "nvim".source = ./config;
    "nvimpager".source = ./config;
  };

  xdg.dataFile."nvimpager".source = mkOutOfStoreSymlink "${config.xdg.dataHome}/nvim";
}