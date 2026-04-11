{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    lfs.enable = true;
    settings = {
      user = {
        name  = "vix_hentx";
        email = "w1084349470@outlook.com";
      };
      init.defaultBranch = "main";
    };
  };
}
