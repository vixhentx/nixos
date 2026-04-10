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
    clash-verge-rev
    godotPackages_4_6.godot-mono
    microsoft-edge
    thunderbird
    dotnetCorePackages.sdk_10_0_1xx-bin
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
