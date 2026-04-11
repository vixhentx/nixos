-- lua/plugins/core.lua
local is_gui = not vim.g.IsServerMode

return {
	{ "kylechui/nvim-surround", version = "*", event = "VeryLazy", config = true },
	{ "numToStr/Comment.nvim", config = true },
	{ "windwp/nvim-autopairs", event = "InsertEnter", config = true },

	-- Git 标记 (VS Code 模式下也可以开启，因为它在 gutter 显示，通常不冲突)
	{
		"lewis6991/gitsigns.nvim",
		config = function() require("gitsigns").setup() end,
	},

	-- Treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = { "lua", "python", "javascript" },
				highlight = { enable = is_gui }, -- 后端模式禁用高亮
				indent = { enable = true },
			})
		end,
	},

	{ 'wellle/targets.vim' },

}
