{ ... }: {
	wsl.enable = true;
	wsl.defaultUser = "ericmarkmartin";
	wsl.startMenuLaunchers = true;

	# Make VSCode Remote-WSL play nice
	wsl.useWindowsDriver = true;

	system.stateVersion = "25.11";
}
