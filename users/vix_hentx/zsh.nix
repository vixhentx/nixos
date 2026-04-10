{ pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    
    # Built-in NixOS support for common plugins
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
        "direnv" # Native OMZ plugin for direnv
      ]; # Extracted from your old plugin list
    };

    # Discovered aliases
    shellAliases = {
      zshconfig = "nvim ~/.zshrc";
      plugconfig = "nvim ~/.zsh_plugins.zsh";
      aliasconfig = "nvim ~/.zsh_aliases.zsh";
      reload = "source ~/.zshrc";
      ohmyzsh = "nvim ~/.oh-my-zsh";
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../../";
      gitcat = "git ls-files -z | xargs -0 batcat --style=header --decorations=always";
    };

    # Discovered environment variables
    sessionVariables = {
      EDITOR = "nvim";
      LANG = "en_US.UTF-8";
      PNPM_HOME = "$HOME/.local/share/pnpm";
    };

    # Custom functions and complex initialization logic
    initContent = ''
      # Path additions
      export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:$HOME/.npm-global/bin:$PATH"

      # Conda initialization
      if [ -f "/home/vix_hentx/miniconda3/etc/profile.d/conda.sh" ]; then
          source "/home/vix_hentx/miniconda3/etc/profile.d/conda.sh"
      fi

      # Proxy Management Logic
      typeset -A proxy_map=(
        [qs]="9674"
        [hiddify]="7890"
      )

      proxy_on() {
        local input="''${1:-hiddify}"
        local port="''${proxy_map[$input]:-$input}"
        
        if [[ ! "$port" =~ ^[0-9]+$ ]]; then
          echo -e "\033[31mError: Unknown proxy profile or invalid port '$input'\033[0m"
          return 1
        fi

        export http_proxy="http://127.0.0.1:$port"
        export https_proxy="http://127.0.0.1:$port"
        export all_proxy="socks5://127.0.0.1:$port"
        echo -e "Proxy \033[32mON\033[0m (Port: \033[34m$port\033[0m)"
      }

      proxy_off() {
        unset http_proxy https_proxy all_proxy
        echo -e "Proxy \033[31mOFF\033[0m"
      }

      # Note: source $HOME/.local/bin/env was found in your old .zshrc
      if [ -f "$HOME/.local/bin/env" ]; then
        source "$HOME/.local/bin/env"
      fi
    '';
  };
}