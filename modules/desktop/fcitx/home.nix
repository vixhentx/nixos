{ pkgs, ... }:

{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      addons = with pkgs; [
        fcitx5-rime
      ];

      settings = {
        globalOptions = {
          Hotkey = {
            EnumerateWithTriggerKeys = true;
          };

          "Hotkey/TriggerKeys"."0" = "Super+space";
          "Hotkey/EnumerateGroupForwardKeys"."0" = "Super+space";
          "Hotkey/EnumerateGroupBackwardKeys"."0" = "Shift+Super+space";
        };

        inputMethod = {
          GroupOrder."0" = "Default";

          "Groups/0" = {
            Name = "Default";
            "Default Layout" = "us";
            DefaultIM = "rime";
          };

          "Groups/0/Items/0" = {
            Name = "keyboard-us";
            Layout = null;
          };

          "Groups/0/Items/1" = {
            Name = "rime";
            Layout = null;
          };
        };
      };
    };
  };
}
