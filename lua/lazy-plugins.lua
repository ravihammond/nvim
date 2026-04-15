-- [[ Configure and install plugins ]]
--
--  To check the current status of your plugins, run
--    :Lazy
--
--  You can press `?` in this menu for help. Use `:q` to close the window
--
--  To update plugins you can run
--    :Lazy update
--
-- NOTE: Here is where you install your plugins.
require('lazy').setup({
  { 'NMAC427/guess-indent.nvim', opts = {} },
  require 'kickstart.plugins.gitsigns',
  require 'kickstart.plugins.which-key',
  require 'kickstart.plugins.telescope',
  require 'kickstart.plugins.lspconfig',
  require 'kickstart.plugins.conform',
  require 'kickstart.plugins.blink-cmp',
  require 'kickstart.plugins.tokyonight',
  require 'kickstart.plugins.todo-comments',
  require 'kickstart.plugins.mini',
  require 'kickstart.plugins.treesitter',

  -- NOTE: Next step on your Neovim journey: Add/Configure additional plugins for Kickstart
  --
  --  Here are some example plugins that I've included in the Kickstart repository.
  --  Uncomment any of the lines below to enable them (you will need to restart nvim).
  --
  -- require 'kickstart.plugins.debug',
  -- require 'kickstart.plugins.indent_line',
  -- require 'kickstart.plugins.lint',
  -- require 'kickstart.plugins.autopairs',
  -- require 'kickstart.plugins.neo-tree',

  -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
  --    This is the easiest way to modularize your config.
  --
  --  Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
  -- { import = 'custom.plugins' },
  --
  -- For additional information with loading, sourcing and examples see `:help lazy.nvim-🔌-plugin-spec`
  -- Or use telescope!
  -- In normal mode type `<space>sh` then write `lazy.nvim-plugin`
  -- you can continue same window with `<space>sr` which resumes last telescope search
}, { ---@diagnostic disable-line: missing-fields
  ui = {
    -- If you are using a Nerd Font: set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
  change_detection = { enabled = true, notify = false },
})

-- [[ Config Live Reload ]]
--
-- Watches ~/.config/nvim/ for ANY write — whether you save a file from inside
-- this Neovim session, or an external tool (Claude Code, Codex, a shell
-- script, another editor) writes to the directory.
--
-- Every running Neovim instance sets up its own watcher independently, so ALL
-- open instances reload simultaneously when a change lands.
--
-- Usage:
--   - Just save any .lua file in the config directory — reload is automatic.
--   - <leader>sv to force a manual reload at any time.

if _G._config_reload_timer then
  _G._config_reload_timer:stop()
  _G._config_reload_timer:close()
  _G._config_reload_timer = nil
end
if _G._config_watcher then
  _G._config_watcher:stop()
  _G._config_watcher:close()
  _G._config_watcher = nil
end

_G.ReloadConfig = function()
  local config = vim.fn.stdpath 'config'

  if vim.loader then vim.loader.reset(config) end

  local bare = { options = true, keymaps = true, ['lazy-bootstrap'] = true, ['lazy-plugins'] = true }
  for mod in pairs(package.loaded) do
    if mod:match '^kickstart' or mod:match '^custom' or bare[mod] then package.loaded[mod] = nil end
  end

  local lazy = require 'lazy'
  local _orig_setup = lazy.setup
  lazy.setup = function() end
  local ok, err = pcall(dofile, config .. '/init.lua')
  lazy.setup = _orig_setup
  if not ok then
    vim.notify('Config reload failed:\n' .. tostring(err), vim.log.levels.ERROR, { title = 'nvim config' })
    return
  end

  local spec_ok, LazyPlugin = pcall(require, 'lazy.core.plugin')
  if spec_ok and type(LazyPlugin.load) == 'function' then
    if pcall(LazyPlugin.load) then vim.api.nvim_exec_autocmds('User', { pattern = 'LazyReload', modeline = false }) end
  end

  vim.notify('Config reloaded', vim.log.levels.INFO, { title = 'nvim config' })
end

vim.api.nvim_create_autocmd('User', {
  pattern = 'LazyReload',
  group = vim.api.nvim_create_augroup('NvimConfigLazyReload', { clear = true }),
  callback = function()
    vim.schedule(function()
      local Config = require 'lazy.core.config'
      local to_install = {}
      local to_reload = {}

      for name, plugin in pairs(Config.plugins or {}) do
        if plugin._ then
          if not plugin._.installed then
            table.insert(to_install, name)
          elseif plugin._.dirty then
            table.insert(to_reload, name)
          end
        end
      end

      if #to_install > 0 then
        require('lazy').install { wait = false }
        vim.notify(('Installing %d new plugin(s):\n%s'):format(#to_install, table.concat(to_install, ', ')), vim.log.levels.INFO, { title = 'nvim config' })
      end

      for _, name in ipairs(to_reload) do
        pcall(require('lazy').reload, name)
      end
    end)
  end,
})

vim.keymap.set('n', '<leader>sv', _G.ReloadConfig, { desc = '[S]ource [V]im config' })

_G._config_watcher = vim.uv.new_fs_event()
_G._config_watcher:start(
  vim.fn.stdpath 'config',
  { recursive = true },
  vim.schedule_wrap(function(err, filename, _events)
    if err or not filename then return end
    if not filename:match '%.lua$' then return end

    if _G._config_reload_timer then
      _G._config_reload_timer:stop()
      _G._config_reload_timer:close()
    end
    _G._config_reload_timer = vim.uv.new_timer()
    _G._config_reload_timer:start(
      300,
      0,
      vim.schedule_wrap(function()
        _G._config_reload_timer:close()
        _G._config_reload_timer = nil
        _G.ReloadConfig()
      end)
    )
  end)
)

-- vim: ts=2 sts=2 sw=2 et
