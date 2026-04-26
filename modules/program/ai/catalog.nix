{ config, lib, osConfig ? { }, pkgs }:
let
  timezone =
    if osConfig ? time && osConfig.time ? timeZone && osConfig.time.timeZone != null then
      osConfig.time.timeZone
    else
      "UTC";

  knowledgeBaseDir = "${config.xdg.dataHome}/ai/knowledge-base";
  memoryFile = "${config.xdg.dataHome}/ai/memory/knowledge-graph.jsonl";
  playwrightOutputDir = "${config.xdg.stateHome}/playwright-mcp";

  # Configuration directories for AI agents
  configDirs = {
    gemini = "${config.xdg.configHome}/gemini-cli";
    gemini_legacy = "${config.home.homeDirectory}/.gemini";
    codex = "${config.xdg.configHome}/codex";
    claude = "${config.home.homeDirectory}/.claudecode";
  };

  sharedPrompt = ''
    # Shared Agent Defaults

    - Prefer concise, actionable answers.
    - For Nix and NixOS work, favor declarative changes over one-off imperative fixes.
    - Preserve module boundaries. Add new logic in dedicated files instead of growing monolithic configs.
    - Reuse packaged tools and official Home Manager or NixOS modules when they exist.
    - Put reusable local notes and reference material under `${knowledgeBaseDir}`.
  '';
in
{
  inherit
    knowledgeBaseDir
    memoryFile
    playwrightOutputDir
    configDirs
    sharedPrompt
    timezone
    ;

  mcpServers = {
    context7 = {
      command = "${pkgs.context7-mcp}/bin/context7-mcp";
    };

    nixos = {
      command = "${pkgs.mcp-nixos}/bin/mcp-nixos";
    };

    filesystem = {
      command = "${pkgs.mcp-server-filesystem}/bin/mcp-server-filesystem";
      args = [
        config.home.homeDirectory
        "/tmp"
        knowledgeBaseDir
      ];
    };

    git = {
      command = "${pkgs.mcp-server-git}/bin/mcp-server-git";
    };

    fetch = {
      command = "${pkgs.mcp-server-fetch}/bin/mcp-server-fetch";
      args = [
        "--user-agent"
        "Mozilla/5.0 (compatible; VixAI/1.0; +https://mcp.local)"
      ];
    };

    time = {
      command = "${pkgs.mcp-server-time}/bin/mcp-server-time";
      args = [
        "--local-timezone"
        timezone
      ];
    };

    memory = {
      command = "${pkgs.mcp-server-memory}/bin/mcp-server-memory";
      env = {
        MEMORY_FILE_PATH = memoryFile;
      };
    };

    # The server reads runtime auth from the shell environment when needed.
    github = {
      command = "${pkgs.github-mcp-server}/bin/github-mcp-server";
      args = [
        "stdio"
        "--read-only"
        "--toolsets=default,issues,pull_requests,repos,users"
      ];
    };

    playwright = {
      command = "${pkgs.playwright-mcp}/bin/mcp-server-playwright";
      args = [
        "--headless"
        "--isolated"
        "--output-dir"
        playwrightOutputDir
      ];
    };
  };

}
