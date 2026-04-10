{ config, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    
    # 1. 将 $EDITOR 环境变量设为 nvim
    defaultEditor = true;
    
    # 2. 让 vi 命令指向 nvim
    viAlias = true;
    
    # 3. 让 vim 命令指向 nvim
    vimAlias = true;
  };

  environment.systemPackages = with pkgs; [
    nvimpager
  ];
}
