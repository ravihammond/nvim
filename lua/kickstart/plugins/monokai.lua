---@module 'lazy'
---@type LazySpec
return {
  'patstockwell/vim-monokai-tasty',
  priority = 1000, -- load before all other plugins so the colorscheme is ready
  config = function()
    vim.cmd.colorscheme 'vim-monokai-tasty'
  end,
}

-- vim: ts=2 sts=2 sw=2 et
