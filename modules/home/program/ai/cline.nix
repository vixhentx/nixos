{ config, lib, pkgs, ... }:
let
  cfg = config.vix.program.ai;
  clineSettingsPath = "${config.xdg.configHome}/Code/User/globalStorage/saoudrizwan.claude-dev/settings/cline_mcp_settings.json";

  mcpServers = { } // (lib.optionalAttrs cfg.mcp.context7.enable {
    "github.com/upstash/context7-mcp" = {
      command = "${pkgs.context7-mcp}/bin/context7-mcp";
      args = [ ];
      disabled = false;
      autoApprove = [ ];
    };
  });

  settings = {
    mcpServers = mcpServers;
  };
in
{
  config = lib.mkIf (cfg.enable && cfg.cline.enable) {
    home.file."${clineSettingsPath}" = {
      text = builtins.toJSON settings;
      force = true;
    };
  };
}