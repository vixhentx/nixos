{ config, lib, pkgs, inputs, ... }:

let
  # 插件打包
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

  # 正统方案：在原生包基础上开启 CUDA 支持
  # 重点：通过指定 cudaCapabilities 为 ["8.9"] (RTX 4060 架构)，避开大规模内核编译导致的死机
  blender-with-cuda = pkgs.blender.override {
    cudaSupport = true;
  };

  # 包装插件路径
  blender-custom = pkgs.symlinkJoin {
    name = "blender-custom";
    paths = [ blender-with-cuda ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/blender \
        --set BLENDER_USER_SCRIPTS ${blender-mcp-addon}/scripts
    '';
  };
in
{
  home.packages = [
    blender-custom
  ];

  # 告诉 Nixpkgs 只编译 8.9 架构的 CUDA 内核，这样构建既快又不会死机
  # 这是处理 NixOS 上 CUDA 应用的“标准姿势”
  nixpkgs.config.cudaCapabilities = [ "8.9" ];
  nixpkgs.config.cudaSupport = true;
}
