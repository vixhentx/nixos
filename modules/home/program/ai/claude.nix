{ config, lib, ... }:
let
  cfg = config.vix.program.ai;
in
{
  config = lib.mkIf (cfg.enable && cfg.claude.enable) {
    programs.claude-code = {
      enable = true;
      enableMcpIntegration = true;
      context = cfg.sharedPrompt;
      settings = {
        includeCoAuthoredBy = false;
        permissions.additionalDirectories = [
          config.home.homeDirectory
          "/tmp"
          cfg.knowledgeBaseDir
        ];
      };
    };
  };
}
