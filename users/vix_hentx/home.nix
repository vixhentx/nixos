{ config, pkgs, ... }:

{
  home.username = "vix_hentx";
  home.homeDirectory = "/home/vix_hentx";

  # 1. 直接安装你的生产力工具
  home.packages = with pkgs; [
    microsoft-edge  # Edge 浏览器
    clash-verge-rev # 代理工具
    thunderbird     # 邮件
  ];

  # 2. 配置 VSCode (带插件管理)
  programs.vscode = {
    enable = true;
    package = pkgs.vscode-fhs; # 强烈建议针对 .NET 开发使用 FHS 版本
    profiles.defualt.extensions = with pkgs.vscode-extensions; [
      ms-dotnettools.csharp
      ms-ceintl.vscode-language-pack-zh-hans
      jdinhlife.gruvbox # 换个好看的主题
    ];
  };

  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "sudo" "docker" ];
      theme = "robbyrussell";
    };
  };

  # 必须设置这个版本号
  home.stateVersion = "25.11"; 
}
