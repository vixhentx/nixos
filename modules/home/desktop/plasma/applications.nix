{ config, lib, ... }:

{
  config = lib.mkIf config.vix.desktop.plasma.enable {
    programs.plasma.configFile = {
      dolphinrc = {
        General.OpenExternallyCalledFolderInNewTab = true;
        IconsMode.PreviewSize = 96;
      };

      kdeglobals."KFileDialog Settings" = {
        "Automatically select filename extension" = true;
        "Show Inline Previews" = true;
        "Sort directories first" = true;
        "View Style" = "DetailTree";
      };

      katerc.General = {
        "Show Menu Bar" = true;
        "Show Status Bar" = true;
        "Show Tab Bar" = true;
        "Show Url Nav Bar" = true;
      };
    };
  };
}
