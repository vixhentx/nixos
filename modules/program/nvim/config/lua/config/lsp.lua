local M = {}

local function nixd_settings(root_dir)
    local settings = {
        nixd = {
            nixpkgs = {
                expr = "import <nixpkgs> { }",
            },
            formatting = {
                command = { "nixfmt" },
            },
        },
    }

    if not root_dir or root_dir == "" then
        return settings
    end

    local flake_root = string.format("%q", root_dir)
    settings.nixd.options = {
        nixos = {
            expr = string.format(
                "(builtins.getFlake %s).nixosConfigurations.vix-cpd5s.options",
                flake_root
            ),
        },
        home_manager = {
            expr = string.format(
                "(builtins.getFlake %s).nixosConfigurations.vix-cpd5s.options.home-manager.users.type.getSubOptions []",
                flake_root
            ),
        },
    }

    return settings
end

function M.setup()
    local cmp = require("cmp")
    local capabilities = require("cmp_nvim_lsp").default_capabilities()

    cmp.setup({
        completion = {
            completeopt = "menu,menuone,noinsert",
        },
        mapping = cmp.mapping.preset.insert({
            ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
            ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
            ["<C-Space>"] = cmp.mapping.complete(),
            ["<C-y>"] = cmp.mapping.confirm({ select = true }),
            ["<CR>"] = cmp.mapping.confirm({ select = false }),
        }),
        sources = {
            { name = "nvim_lsp" },
        },
    })

    local on_attach = function(_, bufnr)
        local keymap = vim.keymap.set
        local opts = { buffer = bufnr, silent = true }

        keymap("n", "K", vim.lsp.buf.hover, opts)
        keymap("n", "gd", vim.lsp.buf.definition, opts)
        keymap("n", "gD", vim.lsp.buf.declaration, opts)
        keymap("n", "gr", vim.lsp.buf.references, opts)
        keymap("n", "gi", vim.lsp.buf.implementation, opts)
        keymap("n", "<leader>rn", vim.lsp.buf.rename, opts)
        keymap("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        keymap("n", "<leader>f", function()
            vim.lsp.buf.format({ async = true })
        end, opts)
    end

    vim.lsp.config("nixd", {
        cmd = { "nixd" },
        filetypes = { "nix" },
        root_markers = { "flake.nix", ".git" },
        capabilities = capabilities,
        on_attach = on_attach,
        before_init = function(_, config)
            config.settings = nixd_settings(config.root_dir or vim.uv.cwd())
        end,
    })

    vim.lsp.enable("nixd")
end

return M
