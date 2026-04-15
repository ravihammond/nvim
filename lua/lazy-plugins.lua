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
  require 'core.plugins.devicons',
  require 'core.plugins.gitsigns',
  require 'core.plugins.which-key',
  require 'core.plugins.telescope',
  require 'core.plugins.lspconfig',
  require 'core.plugins.conform',
  require 'core.plugins.blink-cmp',
  require 'core.plugins.monokai',
  require 'core.plugins.tokyonight',
  require 'core.plugins.todo-comments',
  require 'core.plugins.mini',
  require 'core.plugins.treesitter',

  -- NOTE: Next step on your Neovim journey: Add/Configure additional plugins for Kickstart
  --
  --  Here are some example plugins that I've included in the Kickstart repository.
  --  Uncomment any of the lines below to enable them (you will need to restart nvim).
  --
  -- require 'core.plugins.debug',
  -- require 'core.plugins.indent_line',
  -- require 'core.plugins.lint',
  -- require 'core.plugins.autopairs',
  require 'core.plugins.neo-tree',

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
    if mod:match '^core' or mod:match '^custom' or bare[mod] then package.loaded[mod] = nil end
  end

  local lazy = require 'lazy'
  local _orig_setup = lazy.setup
  local _captured_spec = nil
  -- Intercept lazy.setup to capture the new spec without triggering re-initialisation.
  -- Previously this was a bare no-op, which silently discarded any newly-added plugins —
  -- Config.options.spec was never updated, so Plugin.load() always re-processed the
  -- original startup spec and new plugins were invisible to the install checker.
  lazy.setup = function(spec, _opts) _captured_spec = spec end
  local ok, err = pcall(dofile, config .. '/init.lua')
  lazy.setup = _orig_setup
  if not ok then
    vim.notify('Config reload failed:\n' .. tostring(err), vim.log.levels.ERROR, { title = 'nvim config' })
    return
  end

  local LazyConfig = require 'lazy.core.config'

  -- Feed the captured spec into lazy's config so Plugin.load() sees new plugins
  if _captured_spec then LazyConfig.options.spec = _captured_spec end

  -- Snapshot spec function refs BEFORE Plugin.load(). All core modules were
  -- cleared from package.loaded above, so Plugin.load() will re-require them —
  -- producing NEW Lua function objects. Comparing refs before/after lets us detect
  -- which plugins had their local config changed, independently of _.dirty (which
  -- only tracks git changes and would miss local file edits entirely).
  local before = {}
  for name, p in pairs(LazyConfig.plugins or {}) do
    before[name] = { config = p.config, opts = p.opts, keys = p.keys, init = p.init }
  end

  local spec_ok, LazyPlugin = pcall(require, 'lazy.core.plugin')
  if spec_ok and type(LazyPlugin.load) == 'function' then
    if pcall(LazyPlugin.load) then
      -- Collect plugins whose spec function refs changed (i.e. their module was re-executed)
      local config_changed = {}
      for name, p in pairs(LazyConfig.plugins or {}) do
        local b = before[name]
        if b and (p.config ~= b.config or p.opts ~= b.opts or p.keys ~= b.keys or p.init ~= b.init) then
          table.insert(config_changed, name)
        end
      end
      _G._nvim_config_changed = config_changed

      vim.api.nvim_exec_autocmds('User', { pattern = 'LazyReload', modeline = false })
    end
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

      -- Merge in plugins whose local config files changed (detected by comparing
      -- spec function refs before/after Plugin.load() in ReloadConfig).
      -- _.dirty only tracks git changes so it misses local edits entirely.
      for _, name in ipairs(_G._nvim_config_changed or {}) do
        local already = vim.tbl_contains(to_reload, name) or vim.tbl_contains(to_install, name)
        if not already and Config.plugins[name] then
          table.insert(to_reload, name)
        end
      end
      _G._nvim_config_changed = nil

      if #to_install > 0 then
        -- Cross-process install lock — vim.fn.mkdir() is atomic on POSIX, so only
        -- one nvim instance wins the race and runs lazy.install. Without this, two
        -- instances both see _.installed=false (in-memory flag) and both attempt
        -- git-clone simultaneously, causing "destination path already exists" errors.
        local lock = vim.fn.stdpath 'data' .. '/lazy-install.lock'

        -- Remove stale lock left by a previously-crashed nvim (older than 5 min).
        local lock_stat = vim.uv.fs_stat(lock)
        if lock_stat and os.time() - lock_stat.mtime.sec > 300 then
          vim.fn.delete(lock, 'd')
        end

        if vim.fn.mkdir(lock) == 1 then
          -- We won the lock: run a silent async install.
          -- show=false → lazy never opens its UI window (kills the hit-enter prompt).
          -- wait=false → async, nvim stays responsive while git clones happen.
          -- We hook User LazyInstall to reload and release the lock when done.
          local install_au = vim.api.nvim_create_augroup(
            'NvimConfigInstallDone-' .. vim.uv.os_getpid(),
            { clear = true }
          )
          vim.api.nvim_create_autocmd('User', {
            pattern = 'LazyInstall',
            group = install_au,
            once = true,
            callback = function()
              vim.fn.delete(lock, 'd') -- release lock
              for _, name in ipairs(to_install) do
                pcall(require('lazy').reload, name)
              end
              vim.notify(
                'Installed ' .. #to_install .. ' new plugin(s)',
                vim.log.levels.INFO,
                { title = 'nvim config' }
              )
            end,
          })
          require('lazy').install { show = false, wait = false }
        else
          -- Another instance holds the lock and is installing.
          -- Poll until every plugin dir appears on disk, then reload into this session.
          local attempts = 0
          local function poll()
            attempts = attempts + 1
            local LazyConf = require 'lazy.core.config'
            local still_missing = vim.tbl_filter(function(name)
              local p = LazyConf.plugins[name]
              return p and p.dir and not vim.uv.fs_stat(p.dir)
            end, to_install)
            if #still_missing == 0 or attempts >= 30 then
              for _, name in ipairs(to_install) do
                pcall(require('lazy').reload, name)
              end
            else
              vim.defer_fn(poll, 1000)
            end
          end
          vim.defer_fn(poll, 500)
        end
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
