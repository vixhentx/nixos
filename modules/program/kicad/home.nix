{ lib, pkgs, ... }:
let
  kicadBasePkg = pkgs.kicad;
  kicadPkg = pkgs.symlinkJoin {
    name = "kicad-wrapped-${kicadBasePkg.version}";
    paths = [ kicadBasePkg ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      for program in \
        bitmap2component \
        eeschema \
        gerbview \
        kicad \
        pcb_calculator \
        pcbnew \
        pl_editor
      do
        rm "$out/bin/$program"
        makeWrapper ${kicadBasePkg}/bin/$program "$out/bin/$program" \
          --set GTK_THEME Adwaita:dark
      done
    '';
  };
  kicadConfigVersion = lib.versions.majorMinor kicadBasePkg.version;
  kicadLibs = kicadBasePkg.passthru.libraries;
in
{
  home.packages = [
    kicadPkg
    kicadLibs.symbols
    kicadLibs.footprints
    kicadLibs.packages3d
    kicadLibs.templates
  ];

  home.sessionVariables = {
    KICAD10_3DMODEL_DIR = "${kicadLibs.packages3d}/share/kicad/3dmodels";
    KICAD10_FOOTPRINT_DIR = "${kicadLibs.footprints}/share/kicad/footprints";
    KICAD10_SYMBOL_DIR = "${kicadLibs.symbols}/share/kicad/symbols";
    KICAD10_TEMPLATE_DIR = "${kicadLibs.templates}/share/kicad/template";
  };

  home.activation.fixKicadStockTables = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    kicadConfigDir="$HOME/.config/kicad/${kicadConfigVersion}"
    symTable="$kicadConfigDir/sym-lib-table"
    fpTable="$kicadConfigDir/fp-lib-table"

    $DRY_RUN_CMD ${pkgs.coreutils}/bin/mkdir -p "$kicadConfigDir"

    if [ ! -e "$symTable" ] || ${pkgs.gnugrep}/bin/grep -q 'kicad-base-.*template/sym-lib-table' "$symTable"; then
      $DRY_RUN_CMD ${pkgs.coreutils}/bin/install -Dm0644 \
        ${kicadLibs.symbols}/share/kicad/template/sym-lib-table \
        "$symTable"
    fi

    if [ ! -e "$fpTable" ] || ${pkgs.gnugrep}/bin/grep -q 'kicad-base-.*template/fp-lib-table' "$fpTable"; then
      $DRY_RUN_CMD ${pkgs.coreutils}/bin/install -Dm0644 \
        ${kicadLibs.footprints}/share/kicad/template/fp-lib-table \
        "$fpTable"
    fi
  '';
}
