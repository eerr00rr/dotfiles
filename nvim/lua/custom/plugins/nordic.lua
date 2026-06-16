return {
	"AlexvZyl/nordic.nvim",
	lazy = false,
	priority = 1000,
	config = function()
		require("nordic").setup({
			-- Your configuration here
			on_palette = function(palette)
				palette.black0 = "#1E222A"
				palette.black1 = "#191D24"
			end,
			after_palette = function(palette)
				local U = require("nordic.utils")
				palette.bg_visual = U.blend(palette.orange.base, palette.bg, 0.15)
			end,
			on_highlight = function(highlights, palette)
				highlights.TabLineSel = {
					fg = "#191D24",
					bg = "#80b3b2",
					bold = true,
				}
			end,
			bold_keywords = false,
			italic_comments = true,
			transparent = {
				bg = false,
				float = false,
			},
			bright_border = false,
			reduced_blue = true,
			swap_backgrounds = true,
			cursorline = {
				bold = false,
				bold_number = true,
				theme = "dark",
				blend = 0.85,
			},
			visual = {
				bold = false,
				bold_number = true,
				theme = "dark",
				blend = 0.85,
			},
			noice = {
				style = "classic",
			},
			telescope = {
				style = "flat",
			},
			leap = {
				dim_backdrop = false,
			},
			ts_context = {
				dark_background = true,
			},
		})

		-- Load the colorscheme
		vim.cmd.colorscheme("nordic")
	end,
}
