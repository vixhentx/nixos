{ config, lib, pkgs, ... }:
let
  cfg = config.vix.program.ai;
in
{
  config = lib.mkIf (cfg.enable && cfg.aider.enable) {
    programs.aider-chat = {
      enable = true;
      settings = {
        yes-always = true;
        auto-commits = false;
      };
    };

    # Claude Code skill that dispatches aider in the current project.
    home.file.".claude/skills/aider/SKILL.md".source = ./skills/aider/SKILL.md;
  };
}
