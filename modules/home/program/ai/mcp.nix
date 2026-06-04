{ config, lib, pkgs, ... }:
let
  cfg = config.vix.program.ai;
  mcp = cfg.mcp;

  mkServer = command: args: env: { inherit command; } // lib.optionalAttrs (args != null) { inherit args; } // lib.optionalAttrs (env != null) { inherit env; };

  servers = lib.filterAttrs (_: s: s != null) {
    context7 = lib.mkIf mcp.context7.enable (mkServer "${pkgs.context7-mcp}/bin/context7-mcp" null null);

    nixos = lib.mkIf mcp.nixos.enable (mkServer "${pkgs.mcp-nixos}/bin/mcp-nixos" null {
      FASTMCP_UPDATE_CHECK = "off";
    });

    filesystem = lib.mkIf mcp.filesystem.enable (mkServer
      "${pkgs.mcp-server-filesystem}/bin/mcp-server-filesystem"
      [ config.home.homeDirectory "/tmp" cfg.knowledgeBaseDir ]
      null);

    git = lib.mkIf mcp.git.enable (mkServer "${pkgs.mcp-server-git}/bin/mcp-server-git" null null);

    fetch = lib.mkIf mcp.fetch.enable (mkServer
      "${pkgs.mcp-server-fetch}/bin/mcp-server-fetch"
      [ "--user-agent" "Mozilla/5.0 (compatible; VixAI/1.0; +https://mcp.local)" ]
      null);

    time = lib.mkIf mcp.time.enable (mkServer
      "${pkgs.mcp-server-time}/bin/mcp-server-time"
      [ "--local-timezone" cfg.timezone ]
      null);

    memory = lib.mkIf mcp.memory.enable (mkServer "${pkgs.mcp-server-memory}/bin/mcp-server-memory" null {
      MEMORY_FILE_PATH = cfg.memoryFile;
    });

    github = lib.mkIf mcp.github.enable (mkServer
      "${pkgs.github-mcp-server}/bin/github-mcp-server"
      [ "stdio" "--read-only" "--toolsets=default,issues,pull_requests,repos,users" ]
      null);

    playwright = lib.mkIf mcp.playwright.enable (mkServer
      "${pkgs.playwright-mcp}/bin/mcp-server-playwright"
      [ "--headless" "--isolated" "--output-dir" cfg.playwrightOutputDir ]
      null);

    sequential-thinking = lib.mkIf mcp.sequential-thinking.enable (mkServer
      "${pkgs.mcp-server-sequential-thinking}/bin/mcp-server-sequential-thinking" null null);

    blender = lib.mkIf mcp.blender.enable (mkServer
      "${pkgs.uv}/bin/uvx"
      [ "blender-mcp" ]
      null);

    libreoffice = lib.mkIf mcp.libreoffice.enable (mkServer
      "${pkgs.uv}/bin/uvx"
      [ "--with" "ooo-dev-tools" "--from" "iflow-mcp-waterpistolai-libreoffice-mcp" "libreoffice-mcp" ]
      null);
  };
in
{
  config = lib.mkIf cfg.enable {
    programs.mcp = {
      enable = true;
      servers = servers;
    };
  };
}
