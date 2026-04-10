{ pkgs, ... }:

{
  imports = [ ../../modules/dev/default.nix ];

  users.users.vix_hentx = {
    isNormalUser = true;
    description = "Trihydra";
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "docker" ];
    initialPassword = "vix";
    shell = pkgs.zsh;
    packages = with pkgs; [ tree ];
  };
}
