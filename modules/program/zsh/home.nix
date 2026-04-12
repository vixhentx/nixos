{ config, ... }:

{
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      filter_mode = "global";
      filter_mode_shell_up_key_binding = "directory";
      search_mode = "fuzzy";
      style = "compact";
      inline_height = 20;
      workspaces = true;
      search.filters = [
        "global"
        "workspace"
        "directory"
        "session"
        "host"
      ];
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    history = {
      path = "${config.xdg.stateHome}/zsh/history";
      size = 50000;
      save = 50000;
      append = true;
      extended = true;
      expireDuplicatesFirst = true;
      findNoDups = true;
      ignoreAllDups = true;
      saveNoDups = true;
    };
    historySubstringSearch = {
      enable = true;
      searchUpKey = [ "^P" ];
      searchDownKey = [ "^N" ];
    };

    oh-my-zsh = {
      enable = true;
      theme = "jonathan";
      plugins = [
        "git"
        "aliases"
        "extract"
        "zsh-interactive-cd"
        "python"
        "docker"
        "docker-compose"
        "encode64"
        "debian"
        "git-commit"
        "dotnet"
        "direnv"
      ];
    };

    shellAliases = {
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../../";
      c = "clear";
      cat = "bat";
      g = "git";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      lg = "lazygit";
      pager = "nvimpager";
      less = "nvimpager";
      more = "nvimpager";
      el = "eza -lh --git";
      ela = "eza -lah --git";
      et = "eza --tree --level=2";
      gitcat = "git ls-files -z | xargs -0 bat --style=header --decorations=always";
    };

    initContent = builtins.readFile ./utils.zsh;

    sessionVariables = {
      PAGER = "nvimpager";
      MANPAGER = "nvimpager";
    };
  };
}
