-- ~/.config/nvim/lua/plugins/scrollbar.lua
return {
  "petertriho/nvim-scrollbar",
  event = "VeryLazy",
  opts = {
    handle = {
      color = "#45475a", -- any visible color that fits your theme
    },
    handlers = {
      cursor = true,
      diagnostic = true,
      gitsigns = true, -- LazyVim already bundles gitsigns.nvim, so this just works
      search = false, -- set true + add kevinhwang91/nvim-hlslens as a dependency if you want search hits marked too
    },
  },
}
