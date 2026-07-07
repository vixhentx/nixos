{ config, lib, pkgs, osConfig ? { }, ... }:
let
  cfg = config.vix.program.ai;

  # ── Shared paths ──────────────────────────────────────
  knowledgeBaseDir = "${config.xdg.dataHome}/ai/knowledge-base";
  memoryFile = "${config.xdg.dataHome}/ai/memory/knowledge-graph.jsonl";
  playwrightOutputDir = "${config.xdg.stateHome}/playwright-mcp";

  # ── Timezone (from NixOS, fallback UTC) ────────────────
  timezone =
    if osConfig ? time && osConfig.time ? timeZone && osConfig.time.timeZone != null then
      osConfig.time.timeZone
    else
      "UTC";

  # ── Shared agent prompt (injected into all AI tools) ──
  sharedPrompt = ''
    # Shared Agent Defaults

    - Prefer concise, actionable answers.
    - For Nix and NixOS work, favor declarative changes over one-off imperative fixes.
    - Preserve module boundaries. Add new logic in dedicated files instead of growing monolithic configs.
    - Reuse packaged tools and official Home Manager or NixOS modules when they exist.
    - Put reusable local notes and reference material under `${knowledgeBaseDir}`.
  '';

  # ── Reusable mkEnableOption with default=true ──────────
  mkToolEnable = desc: lib.mkEnableOption desc // { default = true; };
in
{
  # ── Options ────────────────────────────────────────────
  options.vix.program.ai = {
    enable = lib.mkEnableOption "AI assistant tooling (Claude Code, Codex, Gemini, Aider) with MCP infrastructure";

    # Shared data (consumed by sub-modules)
    knowledgeBaseDir = lib.mkOption { type = lib.types.str; internal = true; };
    memoryFile = lib.mkOption { type = lib.types.str; internal = true; };
    playwrightOutputDir = lib.mkOption { type = lib.types.str; internal = true; };
    timezone = lib.mkOption { type = lib.types.str; internal = true; };
    sharedPrompt = lib.mkOption { type = lib.types.str; internal = true; };

    # Per-MCP-server toggles (all default true)
    mcp = {
      context7.enable = mkToolEnable "Context7 documentation MCP server";
      nixos.enable = mkToolEnable "NixOS MCP server";
      filesystem.enable = mkToolEnable "Filesystem MCP server";
      git.enable = mkToolEnable "Git MCP server";
      fetch.enable = mkToolEnable "HTTP fetch MCP server";
      time.enable = mkToolEnable "Timezone MCP server";
      memory.enable = mkToolEnable "Memory knowledge-graph MCP server";
      github.enable = mkToolEnable "GitHub MCP server";
      playwright.enable = mkToolEnable "Playwright browser-automation MCP server";
      sequential-thinking.enable = mkToolEnable "Sequential thinking MCP server";
      blender.enable = mkToolEnable "Blender MCP server";
      libreoffice.enable = mkToolEnable "LibreOffice MCP server";
    };

    # Per-tool toggles (all default true when AI is enabled)
    claude.enable = mkToolEnable "Claude Code";
    codex.enable = mkToolEnable "OpenAI Codex CLI";
    gemini.enable = mkToolEnable "Google Gemini CLI";
    aider.enable = mkToolEnable "Aider AI pair programming";
    cline.enable = mkToolEnable "VS Code Cline MCP integration";
  };

  # ── Imports ────────────────────────────────────────────
  imports = [
    ./mcp.nix
    ./claude.nix
    ./codex.nix
    ./gemini.nix
    ./aider.nix
    ./cline.nix
  ];

  # ── Config ─────────────────────────────────────────────
  config = lib.mkIf cfg.enable {
    # Expose shared values for sub-modules
    vix.program.ai = {
      knowledgeBaseDir = lib.mkDefault knowledgeBaseDir;
      memoryFile = lib.mkDefault memoryFile;
      playwrightOutputDir = lib.mkDefault playwrightOutputDir;
      timezone = lib.mkDefault timezone;
      sharedPrompt = lib.mkDefault sharedPrompt;
    };

    # Session environment variables
    home.sessionVariables = {
      AI_KNOWLEDGE_BASE_DIR = knowledgeBaseDir;
      AI_MCP_MEMORY_FILE = memoryFile;
      AI_PLAYWRIGHT_OUTPUT_DIR = playwrightOutputDir;
    };

    # Knowledge base README (co-located with this module)
    xdg.dataFile."ai/knowledge-base/README.md".source = ./README.md;

  };
}
