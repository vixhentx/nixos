{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    lfs.enable = true;
    config = {
      user = {
        name  = "vix_hentx";
        email = "w1084349470@outlook.com";
      };
      init.defaultBranch = "main";
    };
  };

  environment.systemPackages = [
    pkgs.git-lfs
  ];
}
