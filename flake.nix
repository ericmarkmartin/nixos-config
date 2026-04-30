{
	description = "Eric's NixOS config";

	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
		nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
		nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";
		home-manager.url = "github:nix-community/home-manager";
		home-manager.inputs.nixpkgs.follows = "nixpkgs";
	};

	outputs = { self, nixpkgs, nixos-wsl, home-manager, ... }: {
		nixosConfigurations.wsl = nixpkgs.lib.nixosSystem {
			system = "x86_64-linux";
			modules = [
				nixos-wsl.nixosModules.default
				./modules/users/ericmarkmartin.nix
				./hosts/wsl
				home-manager.nixosModules.home-manager
				{
					home-manager.useGlobalPkgs = true;
					home-manager.useUserPackages = true;
					home-manager.users.ericmarkmartin = import ./home/ericmarkmartin.nix;
				}
			];
		};
	};
}
