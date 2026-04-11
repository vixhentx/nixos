{ pkgs, ... }:

{
  home.packages = with pkgs; [
    aria2
    curl
    delta
    fd
    gnupg
    doggo
    dua
    duf
    dust
    hyperfine
    lazydocker
    lazygit
    ncdu
    fastfetch
    ouch
    p7zip
    pass
    procs
    ripgrep
    rsync
    tokei
    unzip
    wget
    xh
    zellij
    zstd
  ];

  programs.bat = {
    enable = true;
    config = {
      paging = "never";
      style = "numbers,changes,header";
    };
  };

  programs.btop = {
    enable = true;
    settings = {
      vim_keys = true;
      update_ms = 1200;
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    silent = true;
  };

  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    git = true;
    icons = "auto";
    extraOptions = [
      "--group-directories-first"
      "--header"
    ];
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "fd --type f --strip-cwd-prefix";
    fileWidgetCommand = "fd --type f --strip-cwd-prefix";
    changeDirWidgetCommand = "fd --type d --strip-cwd-prefix";
  };

  programs.lsd = {
    enable = true;
    settings = {
      blocks = [
        "permission"
        "user"
        "group"
        "size"
        "date"
        "name"
      ];
      date = "relative";
      dereference = true;
      display = "all";
      icons = {
        when = "auto";
        theme = "fancy";
      };
      ignore-globs = [
        ".git"
        "node_modules"
      ];
      indicators = true;
      layout = "grid";
      permission = "rwx";
      size = "short";
      sorting = {
        column = "extension";
        dir-grouping = "first";
      };
    };
  };

  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    shellWrapperName = "y";
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = [ "--cmd cd" ];
  };
}
