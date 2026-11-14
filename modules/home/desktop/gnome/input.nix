{ config, lib, ... }:

let
  sources = map lib.hm.gvariant.mkTuple [
    [ "xkb" "us" ]
    [ "ibus" "rime" ]
  ];
in
{
  config = lib.mkIf config.vix.desktop.gnome.enable {
    assertions = [
      {
        assertion = !config.vix.program.fcitx.enable;
        message = "GNOME uses the system IBus Rime engine; do not enable Fcitx5 in the same profile.";
      }
    ];

    dconf.settings."org/gnome/desktop/input-sources" = {
      # GNOME expects a(ss), not an array of strings containing tuple syntax.
      inherit sources;
      mru-sources = sources;
      xkb-options = [ ];
      per-window = false;
    };

    # GTK uses GNOME's native Wayland input path, including the screen keyboard.
    # Qt and XWayland applications still need an explicit IBus backend.
    home.sessionVariables = {
      GTK_IM_MODULE = lib.mkForce null;
      QT_IM_MODULE = lib.mkForce "ibus";
      SDL_IM_MODULE = lib.mkForce null;
      XMODIFIERS = lib.mkForce "@im=ibus";
    };
  };
}
