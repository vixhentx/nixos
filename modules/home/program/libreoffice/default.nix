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
    enable = lib.mkEnableOption "LibreOffice with MCP protocol support";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ libreoffice-mcp-app ];
  };
}
