{
  description = "NixOS from Scratch";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # weekly prebuilt nix-index database (for comma / command-not-found)
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, nix-index-database, ... }:
      let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
      shellArgs = { inherit pkgs pkgs-unstable; };
    in 
    {
      devShells.${system} = {
        suckless = import ./shells/suckless.nix shellArgs;
      };

      nixosConfigurations.nix = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit pkgs-unstable; };
        modules = [
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.user = import ./home.nix;
            home-manager.sharedModules = [ nix-index-database.homeModules.nix-index ];
            home-manager.backupFileExtension = "backup";
            home-manager.extraSpecialArgs = { inherit pkgs-unstable; };
          }
        ];
      };
    };
}
