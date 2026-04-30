{ pkgs, ... }: {
    home.username = "ericmarkmartin";
    home.homeDirectory = "/home/ericmarkmartin";
    home.stateVersion = "25.11";

    home.packages = with pkgs; [
        ripgrep fd bat eza fzf jq gh 
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
        enableCompletion = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;
        shellAliases = {
            ls = "eza";
            ll = "eza -la --git";
        };
    };

    programs.neovim = {
        enable = true;
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;
    };

    programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
    };

    programs.ssh = {
        enable = true;
        enableDefaultConfig = false;

        matchBlocks = {
            "github.com" = {
                identityFile = "~/.ssh/id_github";
                extraOptions.AddKeysToAgent = "yes";
            };
            "*" = {
                forwardAgent = false;
                serverAliveInterval = 0;
                serverAliveCountMax = 3;
                compression = false;
                addKeysToAgent = "no";
                hashKnownHosts = false;
                userKnownHostsFile = "~/.ssh/known_hosts";
                controlMaster = "no";
                controlPath = "~/.ssh/master-%r@%n:%p";
                controlPersist = "no";
            };
        };


    };

    programs.starship = {
        enable = true;
        settings = {
            add_newline = false;
            format = "$directory$git_branch$git_status$character";

            character = {
        	success_symbol = "[>](bold green)";
        	error_symbol = "[>](bold red)";
            };

            directory = {
        	truncation_length = 3;
        	truncate_to_repo = true;
            };

            git_branch = {
        	symbol = "";
        	style = "bold purple";
            };

            git_status = {
        	style = "bold yellow";
            };

            aws.disabled = true;
            gcloud.disabled = true;
        };
    };
}
