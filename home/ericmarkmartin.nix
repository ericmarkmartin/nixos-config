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
        ripgrep fd bat eza fzf jq gh claude-code
        bear  # generates compile_commands.json for cpython: `bear -- make`
        uv    # Python package/venv manager
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
        initContent = ''
            # zimfw/git aliases (G-prefix: Gws, Gb, Gc, ...)
            fpath+=(${zimfwGit}/functions)
            for f in ${zimfwGit}/functions/*(N); do autoload -Uz ''${f:t}; done
            source ${zimfwGit}/init.zsh
        '';
    };

    programs.nixvim = {
        enable = true;
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;

        globals.mapleader = " ";

        opts = {
            number = true;
            relativenumber = true;
            expandtab = true;
            shiftwidth = 4;
            tabstop = 4;
            softtabstop = 4;
            smartindent = true;
            wrap = false;
            undofile = true;
            ignorecase = true;
            smartcase = true;
            termguicolors = true;
            scrolloff = 8;
            signcolumn = "yes";
            updatetime = 50;
            cursorline = true;
        };

        plugins = {
            treesitter = {
                enable = true;
                settings = {
                    highlight.enable = true;
                    indent.enable = true;
                };
            };

            lsp = {
                enable = true;
                servers = {
                    clangd.enable = true;  # C — cpython interpreter
                    ty.enable = true;      # Python type checker (Astral, alpha)
                    ruff.enable = true;    # Python linter/formatter
                    nixd = {
                        enable = true;
                        settings.nixd.formatting.command = [ "nixfmt" ];
                    };
                };
                keymaps.lspBuf = {
                    gd = "definition";
                    gD = "declaration";
                    gy = "type_definition";
                };
            };

            blink-cmp = {
                enable = true;
                settings = {
                    keymap.preset = "default";
                    completion.documentation.auto_show = true;
                    sources.default = [ "lsp" "path" "buffer" ];
                };
            };

            telescope = {
                enable = true;
                keymaps = {
                    "<leader>ff" = "find_files";
                    "<leader>fg" = "live_grep";
                    "<leader>fb" = "buffers";
                    "<leader>fh" = "help_tags";
                    "<leader>fs" = "lsp_document_symbols";
                    "<leader>fS" = "lsp_dynamic_workspace_symbols";
                };
            };

            oil.enable = true;
            gitsigns.enable = true;
            which-key.enable = true;
            web-devicons.enable = true;  # file icons for telescope
        };

        keymaps = [
            {
                mode = "n";
                key = "-";
                action = "<cmd>Oil<cr>";
                options.desc = "Open parent directory";
            }
            {
                mode = "n";
                key = "<leader>F";
                action.__raw = "function() vim.lsp.buf.format({ async = true }) end";
                options.desc = "Format buffer (LSP)";
            }
            {
                mode = "i";
                key = "jk";
                action = "<Esc>";
                options.desc = "Leave insert mode";
            }
        ];

        extraPackages = with pkgs; [
            nixfmt  # used by nixd for `:lua vim.lsp.buf.format()`
        ];
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
