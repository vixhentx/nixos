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
      "*" = {
        bg = mkLiteral "#1e1e2ef2";
        bg-alt = mkLiteral "#313244";
        fg = mkLiteral "#cdd6f4";
        fg-muted = mkLiteral "#7f849c";
        border = mkLiteral "#b4befe";
        accent = mkLiteral "#89b4fa";
        urgent = mkLiteral "#f38ba8";
        selected = mkLiteral "#f5e0dc";
        background-color = mkLiteral "transparent";
        text-color = mkLiteral "@fg";
      };

      window = {
        width = mkLiteral "760px";
        border = mkLiteral "2px";
        border-radius = mkLiteral "24px";
        border-color = mkLiteral "@border";
        background-color = mkLiteral "@bg";
        children = map mkLiteral [ "mainbox" ];
      };

      mainbox = {
        background-color = mkLiteral "transparent";
        children = map mkLiteral [ "inputbar" "message" "listview" ];
        spacing = mkLiteral "18px";
        padding = mkLiteral "24px";
      };

      inputbar = {
        background-color = mkLiteral "@bg-alt";
        border-radius = mkLiteral "18px";
        children = map mkLiteral [ "prompt" "entry" ];
        padding = mkLiteral "14px 18px";
        spacing = mkLiteral "14px";
      };

      prompt = {
        background-color = mkLiteral "transparent";
        text-color = mkLiteral "@accent";
      };

      entry = {
        background-color = mkLiteral "transparent";
        text-color = mkLiteral "@fg";
        placeholder = "Launch, search, switch";
        placeholder-color = mkLiteral "@fg-muted";
      };

      "textbox-prompt-colon" = {
        expand = false;
        str = "";
      };

      message = {
        enabled = false;
      };

      listview = {
        background-color = mkLiteral "transparent";
        border = 0;
        columns = 1;
        lines = 8;
        scrollbar = false;
        spacing = mkLiteral "10px";
      };

      element = {
        background-color = mkLiteral "transparent";
        border = 0;
        border-radius = mkLiteral "16px";
        orientation = mkLiteral "vertical";
        padding = mkLiteral "14px 18px";
        spacing = mkLiteral "6px";
        text-color = mkLiteral "@fg";
      };

      "element normal.normal" = {
        background-color = mkLiteral "transparent";
        text-color = mkLiteral "@fg";
      };

      "element selected.normal" = {
        background-color = mkLiteral "@bg-alt";
        border = mkLiteral "1px";
        border-color = mkLiteral "@accent";
        text-color = mkLiteral "@selected";
      };

      "element-icon" = {
        background-color = mkLiteral "transparent";
        size = mkLiteral "1.15em";
      };

      "element-text" = {
        background-color = mkLiteral "transparent";
        text-color = mkLiteral "inherit";
        vertical-align = mkLiteral "0.5";
      };
    };
  };
}