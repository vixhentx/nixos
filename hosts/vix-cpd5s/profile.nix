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

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };
}
