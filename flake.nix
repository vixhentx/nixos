{
  description = "Vix Hentx's NixOS Flake Configuration";

  inputs = {
    # Always bleeding edge
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      type = "git";
      url = "https://github.com/hyprwm/Hyprland";
      submodules = true;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    Hyprspace = {
      url = "github:KZDKM/Hyprspace";
      # Hyprspace uses latest Hyprland. We declare this to keep them in sync.
      inputs.hyprland.follows = "hyprland";
    };

    catppuccin.url = "github:catppuccin/nix";
  };

  outputs = { self, nixpkgs, home-manager, catppuccin, ... }@inputs:
  let
    my = import ./lib { inherit (nixpkgs) lib; };
  in
  {
    nixosConfigurations.vix-cpd5s = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs my; };
      modules = [
        ./hosts/vix-cpd5s/default.nix
        ./users/vix_hentx/default.nix
        
        catppuccin.nixosModules.catppuccin
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs my; };
          home-manager.sharedModules = [
            catppuccin.homeModules.catppuccin
          ];
          home-manager.users.vix_hentx = import ./users/vix_hentx/home.nix;
        }
      ];
    };
  };
}
