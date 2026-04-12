local e = not vim.g.IsServerMode
return {
	{
		"nvim-telescope/telescope.nvim",
		enabled = e,
		dependencies = { "nvim-lua/plenary.nvim" },
	},
	-- {
	-- 	"tversteeg/registers.nvim",
	-- 	config = function()
	-- 		require("registers").setup()
	-- 	end,
	-- }
}
