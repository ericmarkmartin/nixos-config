{ pkgs, ... }: {
	wsl.enable = true;
	wsl.defaultUser = "ericmarkmartin";
	wsl.startMenuLaunchers = true;

	# Make VSCode Remote-WSL play nice
	wsl.useWindowsDriver = true;

	# Open URLs and files with their default Windows applications. wslu,
	# which provided wslview, is archived; wsl-open is its maintained
	# replacement, with compatibility shims for tools using the old or XDG name.
	environment.systemPackages = [
		pkgs.wsl-open
		(pkgs.writeShellScriptBin "wslview" ''
			exec ${pkgs.wsl-open}/bin/wsl-open "$@"
		'')
		(pkgs.writeShellScriptBin "xdg-open" ''
			exec ${pkgs.wsl-open}/bin/wsl-open "$@"
		'')
	];
	environment.variables.BROWSER = "wsl-open";

	system.stateVersion = "25.11";
}
