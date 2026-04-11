{ pkgs, ... }:

{
  home.packages = with pkgs; [
    fira-code
    nerd-fonts.symbols-only
    noto-fonts-color-emoji
    sarasa-gothic
  ];
}
