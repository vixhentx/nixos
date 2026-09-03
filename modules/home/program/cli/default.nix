{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.vix.program.cli;
in
{
  options.vix.program.cli = {
    enable = lib.mkEnableOption "Common CLI tools collection";
  };

  config = lib.mkIf cfg.enable {
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
      uv
      wget
      xh
      zellij
      zstd
      git
      git-lfs
      usbutils
      mpv
      jq
      file
      xxd
      python3
      gh
    ];

    programs.btop.enable = true;
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    programs.eza.enable = true;
    programs.fzf.enable = true;
    programs.zoxide.enable = true;
    programs.yazi = {
      enable = true;
      shellWrapperName = "y";
    };

    vix.program.zsh.extraAliases = {
      g = "git";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      lg = "lazygit";
      el = "eza -lh --git";
      ela = "eza -lah --git";
      et = "eza --tree --level=2";
    };
  };
}
