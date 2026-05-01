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

	# allow running non-Nix binaries (e.g. uv-installed Pythons)
	programs.nix-ld.enable = true;
	programs.nix-ld.libraries = with pkgs; [
		stdenv.cc.cc.lib  # libstdc++, libgcc_s
		zlib
		openssl
		libffi
		ncurses
		bzip2
		xz
		sqlite
		readline
	];

	nix.settings.experimental-features = [ "nix-command" "flakes" ];

        nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
            "claude-code"
        ];
}
