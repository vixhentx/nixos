{ config, lib, osConfig ? { }, pkgs, ... }:
let
  ai = import ./catalog.nix { inherit config lib osConfig pkgs; };
in
{
  home.sessionVariables = {
    AI_KNOWLEDGE_BASE_DIR = ai.knowledgeBaseDir;
    AI_MCP_MEMORY_FILE = ai.memoryFile;
    AI_PLAYWRIGHT_OUTPUT_DIR = ai.playwrightOutputDir;
  };

  xdg.dataFile."ai/knowledge-base/README.md".text = ''
    # AI Knowledge Base

    把长期可复用的资料放在这里，例如：

    - 项目架构说明
    - 常用命令备忘
    - 产品或业务背景
    - PDF/Office 转出的 Markdown 笔记
  '';

  home.activation.aiAgentDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "${ai.knowledgeBaseDir}"
    mkdir -p "$(dirname "${ai.memoryFile}")"
    mkdir -p "${ai.playwrightOutputDir}"

    # Ensure AI agent config directories are writable and not symlinks
    for dir in "${ai.configDirs.gemini}" "${ai.configDirs.gemini_legacy}" "${ai.configDirs.codex}" "${ai.configDirs.claude}"; do
      if [ -L "$dir" ]; then
        rm "$dir"
      fi
      mkdir -p "$dir"
      
      # Recursively convert any symlinks inside these directories to regular files
      # This handles cases where HM links individual files instead of the whole directory
      find "$dir" -type l -exec bash -c 'for link; do target=$(readlink -f "$link"); rm "$link"; cp "$target" "$link"; chmod u+w "$link"; done' _ {} +
    done

    # Initialize gemini-cli config if not exists
    GEMINI_CONFIG="${ai.configDirs.gemini}/config.json"
    if [ ! -f "$GEMINI_CONFIG" ]; then
      cat > "$GEMINI_CONFIG" <<EOF
{
  "context": {
    "fileName": ["GEMINI.md", "AGENTS.md", "CONTEXT.md"]
  },
  "general": {
    "preferredEditor": "nvim",
    "vimMode": true
  }
}
EOF
      chown $USER:users "$GEMINI_CONFIG" || true
      chmod 644 "$GEMINI_CONFIG" || true
    fi

    # Initialize codex config if not exists
    CODEX_CONFIG="${ai.configDirs.codex}/config.json"
    if [ ! -f "$CODEX_CONFIG" ]; then
      cat > "$CODEX_CONFIG" <<EOF
{
  "api_endpoint": "http://YOUR_INTERNAL_IP:PORT",
  "note": "This file is initialized by Nix but NOT managed by it. You can safely edit it."
}
EOF
    fi

    # Fix read-only files that might have been left by previous HM generations
    find "${ai.configDirs.gemini}" "${ai.configDirs.codex}" "${ai.configDirs.claude}" -type f -maxdepth 1 -exec chmod u+w {} + 2>/dev/null || true
  '';
}
