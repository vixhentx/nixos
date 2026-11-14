{ config, lib, pkgs, ... }:

let
  stylixCss = config.xdg.dataFile."themes/Stylix/gnome-shell/gnome-shell.css".source;
  colors = config.lib.stylix.colors;
  shellTheme = pkgs.runCommand "vix-gnome-shell-theme" { } ''
    destination="$out/share/themes/Vix-Gnome/gnome-shell"
    mkdir -p "$destination"
    cp -r ${builtins.dirOf (toString stylixCss)}/. "$destination/"
    chmod u+w "$destination/gnome-shell.css"
    cat >> "$destination/gnome-shell.css" <<'EOF'
    #panel,
    #panel:overview,
    #panel.unlock-screen,
    #panel.login-screen {
      background-color: #${colors.base00} !important;
    }
    EOF
  '';
in
{
  config = lib.mkIf config.vix.desktop.gnome.enable {
    home.pointerCursor.gtk.enable = true;

    dconf.settings = {
      "org/gnome/shell/extensions/user-theme".name = lib.mkForce "Vix-Gnome";
      "org/gnome/shell/extensions/hidetopbar" = {
        enable-intellihide = true;
        enable-active-window = false;
        mouse-sensitive = true;
        show-in-overview = true;
      };
      "org/gnome/desktop/interface" = {
        cursor-theme = config.home.pointerCursor.name;
        cursor-size = config.home.pointerCursor.size;
      };
    };

    programs.gnome-shell.theme = {
      name = "Vix-Gnome";
      package = shellTheme;
    };
  };
}
