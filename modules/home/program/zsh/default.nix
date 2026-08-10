{ config, lib, pkgs, ... }:
let
  cfg = config.vix.program.zsh;
  histdbFile = "${config.xdg.stateHome}/zsh/history.db";

  histdbInitScript = pkgs.replaceVars ./scripts/histdb-init.zsh.in {
    sqlite = lib.getExe pkgs.sqlite;
    histdbFile = histdbFile;
    zshHistdb = pkgs.zsh-histdb;
  };
in
{
  options.vix.program.zsh = {
    enable = lib.mkEnableOption "High-performance integrated Zsh shell";
    
    extraAliases = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      description = "Extra aliases to be added to Zsh, provided by other modules.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ sqlite atuin ];

    # Atuin 集成保持作为 Zsh 的一部分, 因为它深度依赖 Shell 历史
    programs.atuin = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        filter_mode = "directory";
        search_mode = "fuzzy";
        style = "compact";
        inline_height = 20;
      };
    };

    programs.zsh = {
      enable = true;
      dotDir = "${config.home.homeDirectory}/.config/zsh";
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      # 基础别名 (不依赖外部工具的)
      shellAliases = {
        ".." = "cd ..";
        "..." = "cd ../..";
        "...." = "cd ../../../";
        c = "clear";
      } // cfg.extraAliases; # 合并注入的别名

      oh-my-zsh = {
        enable = true;
        # Theme is managed by Starship (vix.program.starship).
        # oh-my-zsh plugins are kept for functionality.
        plugins = [ "git" "extract" "python" "docker" "direnv" ];
      };

      initContent = ''
        # Disable Zsh internal history to let Atuin handle everything
        unset HISTFILE
        SAVEHIST=0
        HISTSIZE=0

        ${builtins.readFile histdbInitScript}
      '';

      sessionVariables = {
        HISTDB_FILE = histdbFile;
      };
    };
  };
}
