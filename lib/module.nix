# lib/module.nix
{ lib }:
let
  baseDir = ../modules;

  path = kind: filename: category: name:
    let
      module = "${category}/${name}/${filename}";
      file = baseDir + "/${module}";
    in
      if builtins.pathExists file then file
      else throw "${kind} module '${module}' not found under ${toString baseDir}";
in
{
  sys = category: names: map (path "System" "default.nix" category) names;
  home = category: names: map (path "Home" "home.nix" category) names;
  conf = category: names: map (path "Config" "config.nix" category) names;
}
