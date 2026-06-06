{ config, lib, ... }:

let
  cfg = config.vix.program.starship;
in
{
  options.vix.program.starship = {
    enable = lib.mkEnableOption "Starship prompt with Stylix-managed colors";
  };

  config = lib.mkIf cfg.enable {
    programs.starship = {
      enable = true;
      enableZshIntegration = true;

      settings = {
        add_newline = false;

        character = {
          success_symbol = "[❯](green)";
          error_symbol = "[❯](red)";
          vimcmd_symbol = "[❮](green)";
          vimcmd_replace_one_symbol = "[❮](purple)";
          vimcmd_replace_symbol = "[❮](purple)";
          vimcmd_visual_symbol = "[❮](yellow)";
        };

        git_branch.symbol = " ";
        git_status = { format = "([\\[$all_status$ahead_behind\\]]($style)) "; };
        directory.truncation_length = 3;
      };
    };
  };
}
