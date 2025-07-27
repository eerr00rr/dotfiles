return {
	{
		"rebelot/kanagawa.nvim",
		priority = 1000,
		config = function()
			---@diagnostic disable-next-line: missing-fields
			require("kanagawa").setup({
				compile = true, -- enable compiling the colorscheme
				undercurl = true, -- enable undercurls
				commentStyle = { italic = true },
				functionStyle = {},
				keywordStyle = { italic = true },
				statementStyle = { bold = true },
				typeStyle = {},
				transparent = false, -- do not set background color
				dimInactive = false, -- dim inactive window `:h hl-NormalNC`
				terminalColors = false, -- define vim.g.terminal_color_{0,17}
				colors = { -- add/modify theme and palette colors
					palette = {},
					theme = {
						wave = {
							ui = {
								fg = "#c5c9c5", -- palette.dragonWhite
								fg_dim = "#C8C093", -- palette.oldWhite
								fg_reverse = "#223249", -- palette.waveBlue1

								bg_dim = "#12120f", -- palette.dragonBlack1
								bg_gutter = "#282727", -- palette.dragonBlack4

								bg_m3 = "#0d0c0c", -- palette.dragonBlack0
								bg_m2 = "#12120f", -- palette.dragonBlack1
								bg_m1 = "#1D1C19", -- palette.dragonBlack2
								bg = "#181616", -- palette.dragonBlack3
								bg_p1 = "#282727", -- palette.dragonBlack4
								bg_p2 = "#393836", -- palette.dragonBlack5

								special = "#7a8382", -- palette.dragonGray3
								whitespace = "#625e5a", -- palette.dragonBlack6
								nontext = "#625e5a", -- palette.dragonBlack6

								bg_visual = "#223249", -- palette.waveBlue1
								bg_search = "#2D4F67", -- palette.waveBlue2

								pmenu = {
									fg = "#DCD7BA", -- (palette.fujiWhite)
									fg_sel = "none",
									bg = "#1D1C19", -- (palette.dragonBlack2)
									bg_sel = "#181616", -- (palette.dragonBlack3)
									bg_thumb = "#393836", -- (palette.dragonBlack5)
									bg_sbar = "#282727", -- (palette.dragonBlack4)
								},

								float = {
									fg = "#C8C093", -- palette.oldWhite
									bg = "#0d0c0c", -- palette.dragonBlack0
									fg_border = "#54546D", -- palette.sumiInk6
									bg_border = "#0d0c0c", -- palette.dragonBlack0
								},
							},
						},
						lotus = {},
						dragon = {},
						all = {},
					},
				},
				overrides = function(colors) -- add/modify highlights
					return {}
				end,
				theme = "wave", -- Load "wave" theme
				background = { -- map the value of 'background' option to a theme
					dark = "wave", -- try "dragon" !
					light = "lotus",
				},
			})

			-- setup must be called before loading
			vim.cmd("colorscheme kanagawa")
		end,
	},
}
-- vim: ts=2 sts=2 sw=2 et
