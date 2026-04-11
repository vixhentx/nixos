{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    direnv
    fzf
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    
    # Built-in NixOS support for common plugins
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    ohMyZsh = {
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
        "direnv" # Native OMZ plugin for direnv
      ]; 
    };

    # Discovered aliases
    shellAliases = {
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../../";
      gitcat = "git ls-files -z | xargs -0 batcat --style=header --decorations=always";
    };

    # Custom functions and complex initialization logic
    interactiveShellInit = builtins.readFile ./utils.zsh;

    promptInit = ''
      export PAGER=nvimpager
      export MANPAGER=nvimpager
    '';
  };

  programs.ssh.startAgent = true;
}
