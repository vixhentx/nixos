{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.vix.program.blender;

  blender-mcp-addon = pkgs.stdenv.mkDerivation {
    pname = "blender-mcp-addon";
    version = "latest";
    src = inputs.blender-mcp;
    dontBuild = true;
    installPhase = ''
      mkdir -p $out/scripts/addons
      cp addon.py $out/scripts/addons/blender_mcp.py
    '';
  };

  blender-custom = pkgs.symlinkJoin {
    name = "blender-custom";
    paths = [ inputs.blender-bin.packages.${pkgs.stdenv.hostPlatform.system}.default ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/blender \
        --set BLENDER_USER_SCRIPTS ${blender-mcp-addon}/scripts
    '';
  };
in
{
  options.vix.program.blender = {
    enable = lib.mkEnableOption "Blender 3D creation suite (MCP addon included when ai.mcp.blender is enabled)";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      (if (config.vix.program.ai.enable or false) && (config.vix.program.ai.mcp.blender.enable or true)
       then blender-custom
       else inputs.blender-bin.packages.${pkgs.stdenv.hostPlatform.system}.default)
    ];
  };
}
