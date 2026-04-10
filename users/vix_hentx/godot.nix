{ pkgs, ... }:

let
  # 使用 overrideAttrs 强制替换 SDK 属性
  customGodot = pkgs.godot-mono.overrideAttrs (oldAttrs: {
    # 替换 common.nix 内部定义的 dotnet-sdk 变量 [cite: 9, 136]
    dotnet-sdk = pkgs.dotnetCorePackages.sdk_10_0-bin;
  });
in
{
  # 将自定义后的 Godot 添加到安装列表
  home.packages = [
    customGodot
  ];
}
