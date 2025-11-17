--[[
  SINGLE FILE NEOVIM CONFIG
  Theme: Gruvbox Hard
  Manager: Lazy.nvim
--]]

-- ========================================================================== --
-- ==                           BOOTSTRAP LAZY                             == --
-- ========================================================================== --
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- ========================================================================== --
-- ==                         LEADER & OPTIONS                             == --
-- ========================================================================== --
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opt = vim.opt

-- Sane Defaults
opt.number = true             -- Show line numbers
opt.relativenumber = true     -- Relative line numbers
opt.mouse = "a"               -- Enable mouse mode
opt.clipboard = "unnamedplus" -- Sync with system clipboard
opt.breakindent = true        -- Enable break indent
opt.undofile = true           -- Save undo history
opt.ignorecase = true         -- Case insensitive searching
opt.smartcase = true          -- Case sensitive if capital included
opt.signcolumn = "yes"        -- Always show sign column
opt.updatetime = 250          -- Decrease update time
opt.timeoutlen = 300          -- Time to wait for a mapped sequence
opt.splitright = true         -- Put new windows right of current
opt.splitbelow = true         -- Put new windows below current
opt.inccommand = "split"      -- Preview substitutions live
opt.cursorline = true         -- Highlight current line
opt.scrolloff = 10            -- Keep 10 lines above/below cursor
opt.termguicolors = true      -- True color support

-- Indentation
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true

-- ========================================================================== --
-- ==                             PLUGINS                                  == --
-- ========================================================================== --
require("lazy").setup({

    -- 1. THEME: GRUVBOX HARD
    {
        "ellisonleao/gruvbox.nvim",
        priority = 1000,
        config = function()
            require("gruvbox").setup({
                contrast = "hard",
                palette_overrides = {
                    hard0 = "#1d2021",
                },
            })
            vim.cmd.colorscheme("gruvbox")
        end,
    },

    -- 2. ICONS
    { "nvim-tree/nvim-web-devicons", lazy = true },


    -- 4. TELESCOPE (Fuzzy Finder)
    {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.5",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local builtin = require("telescope.builtin")
            vim.keymap.set("n", "<leader><leader>", builtin.find_files, { desc = "Find Files" })
            vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Grep Files" })
            vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find Buffers" })
            vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help Tags" })
        end,
    },

    -- 5. TREESITTER (Syntax Highlighting)
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "javascript", "typescript", "go", "python", "html", "css", "sql" },
                auto_install = true,
                highlight = { enable = true },
                indent = { enable = true },
            })
        end,
    },
    -- TMUS navigation
    {
        "christoomey/vim-tmux-navigator",
    },
    -- noice utils
    {
        "folke/noice.nvim",
        event = "VeryLazy",
        dependencies = {
            "MunifTanjim/nui.nvim",
            "rcarriga/nvim-notify",
        },
        config = function()
            require("noice").setup({
                lsp = {
                    -- override markdown rendering so that **cmp** and other plugins use Treesitter
                    override = {
                        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                        ["vim.lsp.util.stylize_markdown"] = true,
                        ["cmp.entry.get_documentation"] = true,
                    },
                },
                presets = {
                    bottom_search = true, -- use a classic bottom cmdline for search
                    command_palette = true, -- position the cmdline and popupmenu together
                    long_message_to_split = true, -- long messages will be sent to a split
                    inc_rename = false, -- enables an input dialog for inc-rename.nvim
                    lsp_doc_border = false, -- add a border to hover docs and signature help
                },
            })
        end,
    },
    --Which key
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        init = function()
            vim.o.timeout = true
            vim.o.timeoutlen = 300
        end,
        opts = {},
    },

    -- 3. VIM-LIKE FILE SELECTOR (Nvim-Tree)
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("nvim-tree").setup({
                view = { width = 30 },
                renderer = { group_empty = true },
                filters = { dotfiles = false },
                -- NEW: Close tree after opening a file
                actions = {
                    open_file = {
                        quit_on_open = true,
                    },
                },
            })
            -- Mappings for File Explorer
            vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle Explorer" })
            vim.keymap.set("n", "<leader>E", ":NvimTreeFocus<CR>", { desc = "Focus Explorer" })
        end,
    },

    -- 6. LSP CONFIGURATION (Language Servers)
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "hrsh7th/cmp-nvim-lsp",
            "j-hui/fidget.nvim",
        },
        config = function()
            require("mason").setup()
            require("fidget").setup({})

            local capabilities = require("cmp_nvim_lsp").default_capabilities()
            local lspconfig = require("lspconfig")

            -- FIX: New mason-lspconfig setup structure
            require("mason-lspconfig").setup({
                ensure_installed = { "lua_ls", "gopls", "pyright", "ts_ls", "html", "cssls" },
                handlers = {
                    -- The default handler (applies to all servers installed via mason)
                    function(server_name)
                        lspconfig[server_name].setup({
                            capabilities = capabilities,
                        })
                    end,
                },
            })
        end,
    },

    -- 7. AUTOCOMPLETION (CMP)
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
        },
        config = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")

            cmp.setup({
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-k>"] = cmp.mapping.select_prev_item(),
                    ["<C-j>"] = cmp.mapping.select_next_item(),
                    ["<C-y>"] = cmp.mapping.confirm({ select = true }),
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),
                    ["<C-Space>"] = cmp.mapping.complete(),
                }),
                sources = {
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                    { name = "buffer" },
                    { name = "path" },
                },
            })
        end,
    },

    -- 8. FORMATTING & LINTING (None-ls)
    {
        "nvimtools/none-ls.nvim",
        config = function()
            local null_ls = require("null-ls")
            null_ls.setup({
                sources = {
                    null_ls.builtins.formatting.gofmt,
                    null_ls.builtins.formatting.prettier,
                    null_ls.builtins.formatting.black,
                },
                on_attach = function(client, bufnr)
                    if client.supports_method("textDocument/formatting") then
                        vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
                        vim.api.nvim_create_autocmd("BufWritePre", {
                            group = augroup,
                            buffer = bufnr,
                            callback = function()
                                -- on 0.8, you should use vim.lsp.buf.format({ bufnr = bufnr }) instead
                                -- on later neovim version, you should use vim.lsp.buf.format({ async = false })
                                vim.lsp.buf.format({ async = false })
                            end,
                        })
                    end
                end,
            })
            vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, { desc = "Format File" })
        end,
    },

    -- 9. STATUSLINE (Lualine)
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("lualine").setup({
                options = { theme = "gruvbox" },
            })
        end,
    },

    -- 10. TABLINE / BUFFERLINE
    {
        "akinsho/bufferline.nvim",
        version = "*",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("bufferline").setup({
                options = {
                    mode = "buffers",
                    separator_style = "thick",
                    always_show_bufferline = true,
                    diagnostics = "nvim_lsp",
                },
            })
            vim.keymap.set("n", "<S-h>", ":BufferLineCyclePrev<CR>", { desc = "Prev Buffer" })
            vim.keymap.set("n", "<S-l>", ":BufferLineCycleNext<CR>", { desc = "Next Buffer" })
            vim.keymap.set("n", "<leader>bd", ":bdelete<CR>", { desc = "Close Buffer" })
        end,
    },

    -- 11. GIT INTEGRATION
    {
        "lewis6991/gitsigns.nvim",
        config = function() require("gitsigns").setup() end,
    },
    { "tpope/vim-fugitive" },

    -- 12. DEBUGGER (DAP)
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            "rcarriga/nvim-dap-ui",
            "nvim-neotest/nvim-nio",
            "leoluz/nvim-dap-go",
        },
        config = function()
            local dap = require("dap")
            local dapui = require("dapui")

            dapui.setup()
            require("dap-go").setup()

            dap.listeners.before.attach.dapui_config = function() dapui.open() end
            dap.listeners.before.launch.dapui_config = function() dapui.open() end
            dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
            dap.listeners.before.event_exited.dapui_config = function() dapui.close() end

            vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Toggle Breakpoint" })
            vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "Debug Continue" })
        end,
    },

    -- 13. DATABASE (Dadbod)
    {
        "tpope/vim-dadbod",
        dependencies = {
            "kristijanhusak/vim-dadbod-ui",
            "kristijanhusak/vim-dadbod-completion",
        },
        config = function()
            vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/db_ui"
            vim.api.nvim_create_autocmd("FileType", {
                pattern = { "sql", "mysql", "plsql" },
                callback = function()
                    require("cmp").setup.buffer({ sources = { { name = "vim-dadbod-completion" } } })
                end,
            })
        end,
    },

    -- 14. EXTRAS
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = true,
    },
    {
        "numToStr/Comment.nvim",
        config = true,
    },

})

-- ========================================================================== --
-- ==                           ADDITIONAL KEYMAPS                         == --
-- ========================================================================== --

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic message" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic message" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostics list" })

vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspConfig", {}),
    callback = function(ev)
        local opts = { buffer = ev.buf }
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    end,
})
