vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- CUSTOM: true because we have a Nerd Font (dam9000 default is false)
vim.g.have_nerd_font = true
-- CUSTOM: Python provider path
vim.g.python3_host_prog = vim.fn.expand '~/.venvs/nvim/bin/python'
-- CUSTOM: disable Perl provider
vim.g.loaded_perl_provider = 0

require 'options'
require 'keymaps'
require 'lazy-bootstrap'
require 'lazy-plugins'

-- vim: ts=2 sts=2 sw=2 et
