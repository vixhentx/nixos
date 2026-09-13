{ config, lib, pkgs, ... }:
let
  cfg = config.vix.program.ai;

  # feishu-cli ships the domain skills in its source tree. Install each skill
  # as a top-level Claude skill so the AI tools can route Feishu requests.
  feishuSkills = builtins.attrNames (builtins.readDir "${pkgs.feishu-cli.src}/skills");
  skillFiles = lib.listToAttrs (map
    (skill: lib.nameValuePair ".claude/skills/${skill}" {
      source = "${pkgs.feishu-cli.src}/skills/${skill}";
    })
    feishuSkills);
in
{
  config = lib.mkIf (cfg.enable && cfg.feishu.enable) {
    home.packages = [ pkgs.feishu-cli ];
    home.file = skillFiles;
  };
}
