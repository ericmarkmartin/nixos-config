{ pkgs, ... }: {
	home.username = "ericmarkmartin";
	home.homeDirectory = "/home/ericmarkmartin";
	home.stateVersion = "25.11";

	home.packages = with pkgs; [
		ripgrep fd bat eza fzf jq neovim gh
	];

	programs.home-manager.enable = true;

	programs.git = {
		enable = true;
		settings = {
			user = {
				name = "Eric Mark Martin";
				email = "eric@emm.dev";
			};
		};
	};

	programs.zsh = {
		enable = true;
	};

	programs.direnv = {
		enable = true;
		nix-direnv.enable = true;
	};

	programs.ssh = {
		enable = true;
		matchBlocks = {
			"github.com" = {
				identityFile = "~/.ssh/id_github";
				extraOptions.AddKeysToAgent = "yes";
			};
		};
	};
}
