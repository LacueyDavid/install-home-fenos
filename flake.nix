{
  description = "Fenos post-install config (NixOS + Home Manager)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      homeManagerModule = {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.backupFileExtension = "hm-backup";
        home-manager.users.seth = import ./home/seth/home.nix;
        home-manager.users.root = import ./home/root/home.nix;
      };

      mkHost = hostModule: nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          hostModule
          home-manager.nixosModules.home-manager
          homeManagerModule
        ];
      };
    in {
      nixosConfigurations.pc = mkHost ./hosts/pc/configuration.nix;
      nixosConfigurations.vm = mkHost ./hosts/vm/configuration.nix;
      nixosConfigurations.default = self.nixosConfigurations.pc;
    };
}
