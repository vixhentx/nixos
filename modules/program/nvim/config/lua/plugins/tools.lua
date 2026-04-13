local e = not vim.g.IsServerMode
return {
	{
		"nvim-telescope/telescope.nvim",
		enabled = e,
		dependencies = { "nvim-lua/plenary.nvim" },
	},
	{
		"neovim/nvim-lspconfig",
		enabled = not vim.g.vscode,
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"hrsh7th/nvim-cmp",
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			require("config.lsp").setup()
		end,
	},
	-- {
	-- 	"tversteeg/registers.nvim",
	-- 	config = function()
	-- 		require("registers").setup()
	-- 	end,
	-- }
}
