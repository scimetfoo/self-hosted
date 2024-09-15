{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-24.05";
    };

    sops-nix.url = "github:Mic92/sops-nix";

    actual-nix.url = "git+https://git.xeno.science/xenofem/actual-nix";
    
    disko = {
      url = "github:nix-community/disko";
      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
      };
    };
  };

  outputs = inputs@{ self, nixpkgs, ... }: {
    nixosConfigurations = {
      personal-server = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
	specialArgs = { inherit inputs; };
        modules = [
	  ./user.nix
          ./nixos/configuration.nix
	  inputs.disko.nixosModules.disko
	  inputs.sops-nix.nixosModules.sops
	  inputs.actual-nix.nixosModules.default
	];
      };
    };
  };
}
