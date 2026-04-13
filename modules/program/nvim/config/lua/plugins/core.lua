-- lua/plugins/core.lua
local is_gui = not vim.g.IsServerMode

return {
	{ "kylechui/nvim-surround", version = "*", event = "VeryLazy", config = true },
	{
		"numToStr/Comment.nvim",
		config = function()
			require("Comment").setup({
				mappings = vim.g.vscode and {
					basic = false,
					extra = false,
				} or nil,
			})
		end,
	},
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
			local treesitter = require("nvim-treesitter")
			local languages = { "lua", "python", "javascript", "nix" }

			treesitter.setup()
			treesitter.install(languages)

			vim.api.nvim_create_autocmd("FileType", {
				pattern = languages,
				callback = function()
					if is_gui then
						vim.treesitter.start()
					end
					vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end,
			})
		end,
	},

	{ 'wellle/targets.vim' },

}
