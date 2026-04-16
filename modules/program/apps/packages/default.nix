{ lib, pkgs }:
let
  groups = {
    chat = import ./chat.nix { inherit pkgs; };
    dev = import ./dev.nix { inherit pkgs; };
    internet = import ./internet.nix { inherit pkgs; };
    media = import ./media.nix { inherit pkgs; };
    utils = import ./utils.nix { inherit pkgs; };
    work = import ./work.nix { inherit pkgs; };
  };
in
{
  inherit groups;

  all = lib.concatLists [
    groups.internet
    groups.dev
    groups.chat
    groups.media
    groups.work
    groups.utils
  ];
}
