{ config, lib, inputs, ... }:
let
  cfg = config.vix.program.ai;
in
{
  config = lib.mkIf (cfg.enable && cfg.typst.enable) {
    home.file = {
      ".claude/skills/typst-author".source = "${inputs.typst-skills}/typst-author";
      ".claude/skills/touying-author".source = "${inputs.typst-skills}/touying-author";
    };
  };
}
