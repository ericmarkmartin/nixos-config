{ pkgs, ... }:
let
    zimfwGit = pkgs.fetchFromGitHub {
        owner = "zimfw";
        repo = "git";
        rev = "fff448c0b89a4885f4ace90e2f37893a078b0c8a";
        hash = "sha256-ojcv6nCOcv+2bbOZxcWhiefQ6mIWovYV57K8V6iyO5M=";
    };
in {
    home.username = "ericmarkmartin";
    home.homeDirectory = "/home/ericmarkmartin";
    home.stateVersion = "25.11";

    home.packages = with pkgs; [
        ripgrep fd bat eza fzf jq gh claude-code dysk
        bear     # generates compile_commands.json for cpython: `bear -- make`
        gnumake  # `make` — needed for cpython's build
        uv       # Python package/venv manager
        jujutsu  # git-compatible VCS; `jj` binary
    ];

    # `home.sessionVariables` writes to ~/.profile (and home-manager's
    # zsh env-loading shim), so login shells pick them up. New shells
    # opened *now* in this session won't have them until you re-login or
    # `source ~/.zshenv` — easiest is just opening a fresh WT tab.
    home.sessionVariables = {
        EDITOR = "nvim";
        PAGER  = "bat";
    };

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
        initContent = ''
            # zimfw/git aliases (G-prefix: Gws, Gb, Gc, ...)
            fpath+=(${zimfwGit}/functions)
            for f in ${zimfwGit}/functions/*(N); do autoload -Uz ''${f:t}; done
            source ${zimfwGit}/init.zsh
        '';
    };

    programs.neovim = {
        enable = true;
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;

        # Opt into the new defaults early (in 26.05 these flip to false).
        # We don't need ruby or the python3 provider inside nvim itself —
        # python tooling reaches us via ruff/ty on extraPackages, not via
        # nvim's :py3 bridge.
        withRuby = false;
        withPython3 = false;

        # LSP servers + tools placed on neovim's wrapper PATH (not your shell's).
        # Same wrapper-PATH trick nixvim was doing under the hood.
        # `clang-tools` is the package that ships the `clangd` binary.
        extraPackages = with pkgs; [
            clang-tools
            ty
            ruff
            nixd
            nixfmt
            lua-language-server  # lua_ls
        ];

        # Plugins are added to nvim's runtimepath. Treesitter grammars come as
        # separate derivations; `withPlugins` bundles only the ones we ask for
        # so nvim never has to compile a parser at runtime.
        plugins = with pkgs.vimPlugins; [
            (nvim-treesitter.withPlugins (p: with p; [
                c lua nix python vim vimdoc query
            ]))

            nvim-lspconfig
            blink-cmp
            telescope-nvim
            plenary-nvim          # telescope dep
            oil-nvim
            gitsigns-nvim
            which-key-nvim
            nvim-web-devicons
        ];

        # `builtins.readFile` slurps the file at evaluation time, so its contents
        # become a string baked into the generated init at rebuild. Editor gets
        # full lua LSP on the file. Flake gotcha: `home/nvim/init.lua` must be
        # `git add`ed for the flake to see it.
        initLua = builtins.readFile ./nvim/init.lua;
    };

    programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
    };

    services.ssh-agent.enable = true;

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
            format = "$directory$git_branch$git_status$python$cmd_duration$line_break$character";

            character = {
                success_symbol = "[❯](bold green)";
                error_symbol = "[❯](bold red)";
            };

            directory = {
                truncation_length = 3;
                truncate_to_repo = true;
            };

            git_branch = {
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
