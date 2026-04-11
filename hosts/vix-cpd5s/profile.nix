{ my, ... }:
let
  m = my.modules;
in
{
  imports =
    m.sys "system" [ "core" ]
    ++ m.sys "desktop" [ "hypr" "sddm" "fcitx" ]
    ++ m.sys "device" [ "nvidia" ]
    ++ m.sys "program" [ "zsh" ];

  home-manager.users.vix_hentx.imports =
    m.home "desktop" [ "hypr" "font" ]
    ++ m.home "program" [ "apps" ];

  services.printing.enable = true;
  services.libinput.enable = true;

  home-manager.users.vix_hentx.wayland.windowManager.hyprland.settings.monitor = [
    "DP-1,1920x1080,-1280x180,1.5"
    "eDP-1,2560x1440,0x0,1.6"
    "DP-4,1920x1080,1600x180,1.5"
  ];

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };
}
