-- lua/plugins/ui.lua
local is_gui = not vim.g.IsServerMode

return {
    -- 启动界面 (Alpha)
    {
        'goolord/alpha-nvim',
        enabled = is_gui, -- VS Code 禁用
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        config = function ()
            require'alpha'.setup(require'alpha.themes.dashboard'.config)
        end
    },

    -- 颜色主题
    {
        "catppuccin/nvim",
        name = "catppuccin",
        lazy = false,
        priority = 1000,
        config = function()
            require("catppuccin").setup({
                flavour = "mocha",
                integrations = {
                    alpha = true,
                    nvimtree = true,
                },
            })
            if is_gui then vim.cmd.colorscheme("catppuccin") end
        end,
    },

    -- 状态栏
    { "nvim-lualine/lualine.nvim", enabled = is_gui, config = true },

    -- 文件树 (Nvim-Tree)
    {
        "nvim-tree/nvim-tree.lua",
        enabled = is_gui,
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("nvim-tree").setup({ view = { width = 30 } })
        end,
    },

    -- 缩进线
    { "lukas-reineke/indent-blankline.nvim", enabled = is_gui, main = "ibl", opts = {} },
}
