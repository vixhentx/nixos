{ config, lib, ... }:

{
  config = lib.mkIf config.vix.desktop.plasma.enable {
    programs.plasma.shortcuts = {
      kwin = {
        "Edit Tiles" = "Meta+Alt+T";
        MoveMouseToCenter = "Meta+F6";
        MoveMouseToFocus = "Meta+F5";
        "Switch to Desktop 1" = "Meta+1";
        "Switch to Desktop 2" = "Meta+2";
        "Switch to Desktop 3" = "Meta+3";
        "Switch to Desktop 4" = "Meta+4";
        "Switch to Desktop 5" = "Meta+5";
        "Switch to Desktop 6" = "Meta+6";
        "Switch to Desktop 7" = "Meta+7";
        "Switch to Desktop 8" = "Meta+8";
        "Switch to Desktop 9" = "Meta+9";
        "Switch to Desktop 10" = "Meta+0";
        "Window Close" = "Meta+C";
        "Window One Desktop Down" = "Meta+Ctrl+Shift+Down";
        "Window One Desktop Up" = "Meta+Ctrl+Shift+Up";
        "Window One Desktop to the Left" = "Meta+Ctrl+Shift+Left";
        "Window One Desktop to the Right" = "Meta+Ctrl+Shift+Right";
        "Window Operations Menu" = "Meta+F3";
        "Window Restore" = "Meta+Backspace";
        "Window to Next Screen" = "Meta+Shift+Right";
        "Window to Previous Screen" = "Meta+Shift+Left";
      };

      plasmashell = {
        clipboard_action = "Meta+Ctrl+X";
        cycle-panels = "Meta+Alt+P";
        "next activity" = "Meta+A";
        "previous activity" = "Meta+Shift+A";
        "show-on-mouse-pos" = "Meta+V";
      };

      "services/org.kde.konsole.desktop"._launch = "Meta+T";
    };
  };
}
