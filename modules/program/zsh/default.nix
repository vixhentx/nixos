{ ... }:

{
  programs.zsh = {
    enable = true;
  };

  programs.ssh.startAgent = true;
}
