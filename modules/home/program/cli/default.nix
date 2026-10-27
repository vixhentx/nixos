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
      unzip
      wget
      xh
      zstd
      usbutils
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
    programs.eza = {
      enable = true;
      enableZshIntegration = true;
    };
    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
    programs.yazi = {
      enable = true;
      shellWrapperName = "y";
    };
    programs.fzf = {
      enable = true;
      historyWidget.command = "";
    };
    programs.zellij.enableZshIntegration = true;
    programs.zellij.exitShellOnExit = true;

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
    vix.program.git.enable = true;
    vix.program.zellij.enable = true;
  };
}
