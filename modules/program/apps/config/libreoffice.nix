{ config, lib, pkgs, ... }:

let
  libreoffice-mcp-app = pkgs.symlinkJoin {
    name = "libreoffice-mcp";
    paths = [ pkgs.libreoffice-fresh ]; # 或者 pkgs.libreoffice，取决于你安装的版本
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/libreoffice \
        --add-flags "--accept='socket,host=localhost,port=2083;urp;'"
      
      # 创建一个更直观的软链接
      ln -s $out/bin/libreoffice $out/bin/libreoffice-mcp
    '';
  };
in
{
  home.packages = [
    libreoffice-mcp-app
  ];
}
