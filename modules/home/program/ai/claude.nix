{ config, lib, ... }:
let
  cfg = config.vix.program.ai;
  cmds = import ./commands.nix;
  referenceDir = "~/reference";
  bashPrefix = prefix: "Bash(${prefix}:*)";
  bashPattern = pattern: "Bash(${pattern})";

  # MCP tools to auto-allow: read-only tools across all servers. Write/mutating
  # MCP tools stay gated (prompt) to match the Bash permission policy.
  mcpAllow = [
    # Read-only servers — allow every tool.
    "mcp__plugin_claude-code-home-manager_context7__*"
    "mcp__plugin_claude-code-home-manager_nixos__*"
    "mcp__plugin_claude-code-home-manager_fetch__*"
    "mcp__plugin_claude-code-home-manager_time__*"
    "mcp__plugin_claude-code-home-manager_sequential-thinking__*"
    # Filesystem — read-only tools.
    "mcp__plugin_claude-code-home-manager_filesystem__list_allowed_directories"
    "mcp__plugin_claude-code-home-manager_filesystem__list_directory"
    "mcp__plugin_claude-code-home-manager_filesystem__list_directory_with_sizes"
    "mcp__plugin_claude-code-home-manager_filesystem__directory_tree"
    "mcp__plugin_claude-code-home-manager_filesystem__get_file_info"
    "mcp__plugin_claude-code-home-manager_filesystem__read_file"
    "mcp__plugin_claude-code-home-manager_filesystem__read_text_file"
    "mcp__plugin_claude-code-home-manager_filesystem__read_multiple_files"
    "mcp__plugin_claude-code-home-manager_filesystem__read_media_file"
    "mcp__plugin_claude-code-home-manager_filesystem__search_files"
    # Git — read-only tools.
    "mcp__plugin_claude-code-home-manager_git__git_status"
    "mcp__plugin_claude-code-home-manager_git__git_log"
    "mcp__plugin_claude-code-home-manager_git__git_diff"
    "mcp__plugin_claude-code-home-manager_git__git_diff_staged"
    "mcp__plugin_claude-code-home-manager_git__git_diff_unstaged"
    "mcp__plugin_claude-code-home-manager_git__git_show"
    "mcp__plugin_claude-code-home-manager_git__git_branch"
    # Memory — read-only tools.
    "mcp__plugin_claude-code-home-manager_memory__read_graph"
    "mcp__plugin_claude-code-home-manager_memory__search_nodes"
    "mcp__plugin_claude-code-home-manager_memory__open_nodes"
  ];
in
{
  config = lib.mkIf (cfg.enable && cfg.claude.enable) {
    programs.claude-code = {
      enable = true;
      enableMcpIntegration = true;
      context = cfg.sharedPrompt;
      settings = {
        includeCoAuthoredBy = false;
        permissions = {
          defaultMode = "default";
          additionalDirectories = [
            config.home.homeDirectory
            "${config.home.homeDirectory}/reference"
            "/tmp"
            cfg.knowledgeBaseDir
          ];
          allow = (map bashPrefix (cmds.gitRead ++ cmds.nixAllowed ++ cmds.buildTools ++ cmds.readTools ++ cmds.gitManage)) ++ mcpAllow;
          deny = (map bashPrefix cmds.nixDeny) ++ (map bashPattern cmds.dangerousDeny) ++ [ "Edit(${referenceDir}/**)" ];
        };
      };
    };
  };
}
