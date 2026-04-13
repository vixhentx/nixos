{ pkgs, config, ... }:

let
  mkLiteral = config.lib.formats.rasi.mkLiteral;
in
{
    
  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
    font = "Sarasa Mono SC 12";
    terminal = "kitty";
    location = "center";
    yoffset = -24;
    modes = [
      "drun"
      "window"
      "run"
    ];
    extraConfig = {
      modi = "drun,window,run";
      show-icons = true;
      drun-display-format = "{name}";
      display-drun = " Apps ";
      display-window = " Windows ";
      display-run = " Run ";
      hover-select = true;
      me-select-entry = "";
      cycle = true;
    };
    theme = {
      window = {
        width = mkLiteral "760px";
        border = mkLiteral "2px";
        border-radius = mkLiteral "24px";
        children = map mkLiteral [ "mainbox" ];
      };

      mainbox = {
        children = map mkLiteral [ "inputbar" "message" "listview" ];
        spacing = mkLiteral "18px";
        padding = mkLiteral "24px";
      };

      inputbar = {
        border-radius = mkLiteral "18px";
        children = map mkLiteral [ "prompt" "entry" ];
        padding = mkLiteral "14px 18px";
        spacing = mkLiteral "14px";
      };

      entry = {
        placeholder = "Launch, search, switch";
      };

      "textbox-prompt-colon" = {
        expand = false;
        str = "";
      };

      message = {
        enabled = false;
      };

      listview = {
        border = 0;
        columns = 1;
        lines = 8;
        scrollbar = false;
        spacing = mkLiteral "10px";
      };

      element = {
        border = 0;
        border-radius = mkLiteral "16px";
        orientation = mkLiteral "vertical";
        padding = mkLiteral "14px 18px";
        spacing = mkLiteral "6px";
      };

      "element selected.normal" = {
        border = mkLiteral "1px";
      };

      "element-icon" = {
        size = mkLiteral "1.15em";
      };

      "element-text" = {
        vertical-align = mkLiteral "0.5";
      };
    };
  };
}
