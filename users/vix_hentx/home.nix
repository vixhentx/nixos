{ ... }:

{
  imports = [
    ./git.nix
    ./theme/home.nix
  ];

  home.username = "vix_hentx";
  home.homeDirectory = "/home/vix_hentx";
  home.stateVersion = "25.11";
}
