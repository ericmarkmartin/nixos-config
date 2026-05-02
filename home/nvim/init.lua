-- Leader must be set before plugins load
vim.g.mapleader = " "

local opt = vim.opt
opt.number         = true
opt.relativenumber = true
opt.expandtab      = true
opt.shiftwidth     = 4
opt.tabstop        = 4
opt.softtabstop    = 4
opt.smartindent    = true
opt.wrap           = false
opt.undofile       = true
opt.ignorecase     = true
opt.smartcase      = true
opt.termguicolors  = true
opt.scrolloff      = 8
opt.signcolumn     = "yes"
opt.updatetime     = 50
opt.cursorline     = true

-- guifont applies only to GUI nvim frontends (neovide, nvim-qt, fvim, …).
-- In terminal nvim — including Windows Terminal — this is a no-op; the
-- terminal's font is what renders. Setting it here means a future `neovide`
-- install would pick up the right font without extra config.
opt.guifont = "Iosevka Term SS10:h11"

vim.keymap.set("n", "-",  "<cmd>Oil<cr>", { desc = "Open parent directory" })
vim.keymap.set("i", "jk", "<Esc>",        { desc = "Leave insert mode" })
vim.keymap.set("n", "<leader>F", function()
    vim.lsp.buf.format({ async = true })
end, { desc = "Format buffer (LSP)" })

-- Treesitter: nvim-treesitter v1.0 dropped the old `configs.setup`. The
-- modern way is to start it per-buffer via FileType. Grammars from
-- `withPlugins` live on the rtp, so `vim.treesitter.start` finds them.
-- pcall swallows the "no parser for X" error for unknown filetypes.
vim.api.nvim_create_autocmd("FileType", {
    callback = function(args)
        pcall(vim.treesitter.start, args.buf)
    end,
})

require("oil").setup()
require("gitsigns").setup()
require("which-key").setup()
require("nvim-web-devicons").setup()

local tb = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", tb.find_files,                    { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", tb.live_grep,                     { desc = "Live grep" })
vim.keymap.set("n", "<leader>fb", tb.buffers,                       { desc = "Buffers" })
vim.keymap.set("n", "<leader>fh", tb.help_tags,                     { desc = "Help tags" })
vim.keymap.set("n", "<leader>fs", tb.lsp_document_symbols,          { desc = "Doc symbols" })
vim.keymap.set("n", "<leader>fS", tb.lsp_dynamic_workspace_symbols, { desc = "Workspace symbols" })

require("blink.cmp").setup({
    keymap     = { preset = "default" },
    completion = { documentation = { auto_show = true } },
    sources    = { default = { "lsp", "path", "buffer" } },
})

-- LSP buffer-local keymaps applied when any client attaches.
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local bufnr = args.buf
        local map = function(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc })
        end
        map("gd", vim.lsp.buf.definition,      "Go to definition")
        map("gD", vim.lsp.buf.declaration,     "Go to declaration")
        map("gy", vim.lsp.buf.type_definition, "Go to type definition")
    end,
})

-- nvim 0.11+ native LSP API: vim.lsp.config registers config, vim.lsp.enable
-- activates it (auto-attaches on matching filetypes/root markers).
-- A "*" config sets defaults that merge into every server.
vim.lsp.config("*", {
    capabilities = require("blink.cmp").get_lsp_capabilities(),
})

-- clangd, ruff, nixd, lua_ls: nvim-lspconfig ships default configs at
-- lsp/<name>.lua on the runtimepath, so `enable` is enough to wire them up.
vim.lsp.enable({ "clangd", "ruff", "nixd", "lua_ls" })

-- nixd needs a custom formatter setting on top of the default config.
vim.lsp.config("nixd", {
    settings = { nixd = { formatting = { command = { "nixfmt" } } } },
})

-- lua_ls: teach it about neovim's lua API so editing this file (or any
-- nvim plugin lua) gets `vim.X` completion + no "undefined global" warnings.
-- `nvim_get_runtime_file("", true)` returns every dir on the rtp; lua_ls
-- treats those as library sources.
vim.lsp.config("lua_ls", {
    settings = {
        Lua = {
            runtime    = { version = "LuaJIT" },
            workspace  = {
                library = vim.api.nvim_get_runtime_file("", true),
                checkThirdParty = false,
            },
            diagnostics = { globals = { "vim" } },
            telemetry  = { enable = false },
        },
    },
})

-- ty is alpha and isn't in nvim-lspconfig yet, so we define the config from
-- scratch. Filetypes + root_markers tell neovim when to attach.
vim.lsp.config("ty", {
    cmd          = { "ty", "server" },
    filetypes    = { "python" },
    root_markers = { "pyproject.toml", ".git" },
})
vim.lsp.enable("ty")
