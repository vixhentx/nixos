{
  description = "Vix Hentx's NixOS Refactored Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-facter-modules.url = "github:nix-community/nixos-facter";

    nixvim = {
      url = "github:nix-community/nixvim";
      # Remove follows to avoid nixpkgs source mismatch warning in nixvim
    };

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    blender-bin = {
      url = "github:edolstra/nix-warez?dir=blender";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    blender-mcp = {
      url = "github:ahujasid/blender-mcp";
      flake = false;
    };
  };

  outputs = inputs:
    inputs.snowfall-lib.mkFlake {
      inherit inputs;
      src = ./.;

      snowfall = {
        namespace = "vix"; # 用户要求的命名空间
      };

      systems.modules.nixos = with inputs; [
        stylix.nixosModules.stylix
        catppuccin.nixosModules.catppuccin
        {
          nixpkgs.config.allowUnfree = true;
        }
      ];

      homes.modules = with inputs; [
        catppuccin.homeModules.catppuccin
        nixvim.homeModules.nixvim
      ];

      # 这里的配置将根据后续重构进行扩展
    };
}
