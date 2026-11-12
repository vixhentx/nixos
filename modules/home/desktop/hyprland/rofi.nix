{ config, lib, pkgs, ... }:

let
  cfg = config.vix.desktop.hyprland.rofi;
  mkLiteral = config.lib.formats.rasi.mkLiteral;
in
{
  options.vix.desktop.hyprland.rofi = {
    enable = lib.mkEnableOption "Rofi application launcher";
  };

  config = lib.mkIf cfg.enable {
    programs.rofi = {
      enable = true;
      package = pkgs.rofi;
      settings = {
        modes = [ "drun" "window" "run" ];
        yoffset = -24;
        terminal = "kitty";
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
          width = mkLiteral "90%";
          border = mkLiteral "2px";
          border-radius = mkLiteral "18px";
          children = map mkLiteral [ "mainbox" ];
        };
        mainbox = {
          children = map mkLiteral [ "inputbar" "message" "listview" ];
          spacing = mkLiteral "12px";
          padding = mkLiteral "16px";
        };
        inputbar = {
          border-radius = mkLiteral "14px";
          children = map mkLiteral [ "prompt" "entry" ];
          padding = mkLiteral "12px 14px";
          spacing = mkLiteral "10px";
        };
        entry = {
          placeholder = "Launch, search, switch";
        };
        listview = {
          border = 0;
          columns = 1;
          lines = 8;
          scrollbar = false;
          spacing = mkLiteral "8px";
        };
        element = {
          border = 0;
          border-radius = mkLiteral "12px";
          orientation = mkLiteral "vertical";
          padding = mkLiteral "10px 12px";
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
  };
}
