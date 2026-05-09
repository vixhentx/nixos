{ pkgs, ... }:
{
  home-manager.users.vix_hentx.home.packages = with pkgs; [
      bottles
      kdePackages.kdenlive
      krita
    ];

  programs.wireshark = 
  {
    enable = true;
    package = pkgs.wireshark;
  };
}
