{ config, pkgs, ... }:

{
  users.users.vix_hentx = {
    isNormalUser = true;
    # uid = 1000;
    description = "Trihydra";
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "docker" ];
    initialPassword = "vix";
    shell = pkgs.zsh;
    packages = with pkgs; [
      tree
    ];
  };
}
