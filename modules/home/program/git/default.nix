{ pkgs, lib, config, ...}:
let
  cfg = config.vix.program.git;
in
{
  options.vix.program.git = {
    enable = lib.mkEnableOption "Enable git program";
  };
  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;
      lfs.enable = true;
      settings = [
        {
          core = {
            autocrlf = "input";
            whitespace = "tab-in-indent";
            eol = "lf";
          };
          init.defaultBranch = "main";
          credential.helper = "store";
        }
      ];
    };
  };
}
