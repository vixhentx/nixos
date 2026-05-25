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

    # 其他 inputs 将在迁移具体模块时添加
  };

  outputs = inputs:
    inputs.snowfall-lib.mkFlake {
      inherit inputs;
      src = ./.;

      snowfall = {
        namespace = "vix"; # 用户要求的命名空间
      };

      homes.modules = with inputs; [
        nixvim.homeModules.nixvim
      ];

      # 这里的配置将根据后续重构进行扩展
    };
}
