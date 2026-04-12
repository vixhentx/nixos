{ ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

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
