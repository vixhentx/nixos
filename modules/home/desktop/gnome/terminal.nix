{ config, lib, ... }:

{
  config = lib.mkIf config.vix.desktop.gnome.enable {
    programs.kitty = {
      enable = true;
      # Preserve Shift+Enter as a distinct key in OpenCode's Kitty keyboard protocol.
      keybindings."shift+enter" = "send_text application \\x1b[13;2u";
    };

    vix.program.xdg.terminal = {
      application = "kitty";
      desktopFile = "kitty.desktop";
    };
  };
}
