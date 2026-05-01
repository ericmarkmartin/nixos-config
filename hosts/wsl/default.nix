{ pkgs, lib, ... }: {
	imports = [
		../../modules/users/ericmarkmartin.nix
	];

	wsl.enable = true;
	wsl.defaultUser = "ericmarkmartin";

	wsl.startMenuLaunchers = true;

	# Make VSCode Remote-WSL play nice
	wsl.useWindowsDriver = true;

	system.stateVersion = "25.11";

	environment.systemPackages = with pkgs; [
		git curl wget
	];

	# allow running non-Nix binaries
	programs.nix-ld.enable = true;

	nix.settings.experimental-features = [ "nix-command" "flakes" ];

        nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
            "claude-code"
        ];
}
