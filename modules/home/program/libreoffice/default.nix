{ config, lib, pkgs, ... }:

let
  cfg = config.vix.program.libreoffice;

  libreoffice-mcp-app = pkgs.symlinkJoin {
    name = "libreoffice-mcp";
    paths = [ pkgs.libreoffice-fresh ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/libreoffice \
        --add-flags "--accept='socket,host=localhost,port=2083;urp;'"

      ln -s $out/bin/libreoffice $out/bin/libreoffice-mcp
    '';
  };
in
{
  options.vix.program.libreoffice = {
    enable = lib.mkEnableOption "LibreOffice (MCP protocol wrapper included when ai.mcp.libreoffice is enabled)";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      (if (config.vix.program.ai.enable or false) && (config.vix.program.ai.mcp.libreoffice.enable or true)
       then libreoffice-mcp-app
       else pkgs.libreoffice-fresh)
    ];
  };
}
