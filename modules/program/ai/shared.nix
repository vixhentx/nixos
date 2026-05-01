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
  '';
}
