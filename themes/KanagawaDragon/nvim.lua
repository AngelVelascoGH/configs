require("kanagawa").setup({
	theme = "dragon",
	background = {
		dark = "dragon",
	},
	colors = {
		theme = {
			all = {
				ui = {
					bg_gutter = "none", -- Removes the column background color
				},
			},
		},
	},
	overrides = function(colors)
		return {
			-- Optional: Ensure line numbers blend in too
			LineNr = { bg = "none" },
			SignColumn = { bg = "none" },
			FoldColumn = { bg = "none" },
		}
	end,
})

vim.cmd.colorscheme("kanagawa")
