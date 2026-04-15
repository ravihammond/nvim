---@module 'lazy'
---@type LazySpec
return {
  'nvim-tree/nvim-web-devicons',
  enabled = vim.g.have_nerd_font,
  lazy = false,
  opts = {
    color_icons = true,
    default = true,
    strict = true,
  },
  config = function(_, opts)
    require('nvim-web-devicons').setup(opts)
    pcall(vim.api.nvim_del_user_command, 'NeoTreeIconCheck')
    pcall(vim.api.nvim_del_user_command, 'NvimWebDeviconsHiTest')
  end,
}

-- vim: ts=2 sts=2 sw=2 et
