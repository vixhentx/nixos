{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.vix.system.font;
in
{
  options.vix.system.font = {
    enable = lib.mkEnableOption "System-level font configuration";

    main = {
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.sarasa-gothic;
        description = "Primary font package for the system";
      };
      serifName = lib.mkOption {
        type = lib.types.str;
        default = "Sarasa UI SC";
        description = "Name of the serif font";
      };
      sansName = lib.mkOption {
        type = lib.types.str;
        default = "Sarasa UI SC";
        description = "Name of the sans-serif font";
      };
      monoName = lib.mkOption {
        type = lib.types.str;
        default = "Sarasa Mono SC";
        description = "Name of the monospace font";
      };
    };

    emoji = {
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.noto-fonts-color-emoji;
        description = "Package for emoji fonts";
      };
      name = lib.mkOption {
        type = lib.types.str;
        default = "Noto Color Emoji";
        description = "Name of the emoji font";
      };
    };

    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = with pkgs; [
        nerd-fonts.symbols-only
        fira-code
      ];
      description = "Additional font packages to install";
    };
  };

  config = lib.mkIf cfg.enable {
    fonts = {
      packages = [
        cfg.main.package
        cfg.emoji.package
      ] ++ cfg.extraPackages;

      fontconfig = {
        enable = true;
        defaultFonts = {
          serif = [ cfg.main.serifName ];
          sansSerif = [ cfg.main.sansName ];
          monospace = [ cfg.main.monoName ];
          emoji = [ cfg.emoji.name ];
        };
      };
    };
  };
}
