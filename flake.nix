{
  description = "Vix Hentx's NixOS Flake Configuration";

  inputs = {
    # Always bleeding edge
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations.vix-cpd5s = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./hosts/vix-cpd5s/default.nix
        ./users/vix_hentx/default.nix
        
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.vix_hentx = import ./users/vix_hentx/home.nix;
        }
      ];
    };
  };
}
