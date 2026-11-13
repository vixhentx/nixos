{ pkgs, lib, inputs, ... }:
pkgs.python3Packages.buildPythonApplication {
  pname = "kicad-cli-extended";
  version = "0.1.0";
  pyproject = true;
  src = inputs.kicad-cli-extended;
  doCheck = false;
  nativeBuildInputs = [ pkgs.python3Packages.hatchling ];
  propagatedBuildInputs = [
    pkgs.python3Packages.click
    pkgs.python3Packages.prompt-toolkit
  ];
  meta = {
    description = "KiCad CLI extensions for AI agents and hardware automation";
    homepage = "https://github.com/Hybirdss/kicad-cli-extended";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
  };
}
