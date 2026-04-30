{ pkgs, ... }: {
	users.users.ericmarkmartin = {
		isNormalUser = true;
		description = "Eric Mark Martin";
		extraGroups = [ "wheel" ];  # sudo
		shell = pkgs.zsh;
	};
	
	programs.zsh.enable = true;  # required for zsh as login shell
}
