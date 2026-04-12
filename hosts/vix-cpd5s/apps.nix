{ pkgs, ... }:
{
  home-manager.users.vix_hentx.home.packages = with pkgs; [
    blender
    bottles
    kdePackages.kdenlive
    krita
  ];
}
