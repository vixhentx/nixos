{ pkgs, ... }:

{
  imports = [
    ./zsh.nix 
    ../../modules/desktop/default.nix
  ];

  home.username = "vix_hentx";
  home.homeDirectory = "/home/vix_hentx";

  home.packages = with pkgs; [
    direnv
    fzf
    clash-verge-rev
    microsoft-edge
    thunderbird
  ];

  programs.vscode = {
    enable = true;
    package = pkgs.vscode-fhs;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      ms-dotnettools.csharp
      ms-ceintl.vscode-language-pack-zh-hans
      jdinhlife.gruvbox
    ];
  };

  home.stateVersion = "25.11";
}
