local e = not vim.g.IsServerMode
local config_app = vim.fn.fnamemodify(vim.fn.stdpath("config"), ":t")
local is_pager = vim.env.NVIM_APPNAME == "nvimpager" or config_app == "nvimpager"

return {
	{
		"nvim-telescope/telescope.nvim",
		enabled = e,
		dependencies = { "nvim-lua/plenary.nvim" },
	},
	{
		"hrsh7th/nvim-cmp",
		enabled = not vim.g.vscode and not is_pager,
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
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
