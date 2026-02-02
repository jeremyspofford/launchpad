-- ============================================================================ --
-- Catppuccin Theme with Auto Dark Mode
-- ============================================================================ --

return {
	-- Catppuccin theme
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		opts = {
			flavour = "mocha",
			background = {
				-- light = "latte",
				dark = "mocha",
			},
			transparent_background = false,
			term_colors = true,
			integrations = {
				cmp = true,
				gitsigns = true,
				nvimtree = true,
				telescope = true,
				treesitter = true,
				which_key = true,
				mini = true,
				native_lsp = {
					enabled = true,
				},
			},
		},
	},

	-- Set catppuccin as the default colorscheme for LazyVim
	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = "catppuccin-mocha",
		},
	},
}
