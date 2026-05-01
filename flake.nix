{
    description = "Eric's NixOS config";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
        nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";
        home-manager.url = "github:nix-community/home-manager";
        home-manager.inputs.nixpkgs.follows = "nixpkgs";
        nixvim.url = "github:nix-community/nixvim";
        nixvim.inputs.nixpkgs.follows = "nixpkgs";
    };

    outputs = { self, nixpkgs, nixos-wsl, home-manager, nixvim, ... }: {
        nixosConfigurations.wsl = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
                nixos-wsl.nixosModules.default
                ./modules/common.nix
                ./modules/users/ericmarkmartin.nix
                ./hosts/wsl
                home-manager.nixosModules.home-manager
                {
                    home-manager.useGlobalPkgs = true;
                    home-manager.useUserPackages = true;
                    home-manager.sharedModules = [ nixvim.homeModules.nixvim ];
                    home-manager.users.ericmarkmartin = import ./home/ericmarkmartin.nix;
                }
            ];
        };
    };
}
