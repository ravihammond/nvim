-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

---@module 'lazy'
---@type LazySpec
return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    'MunifTanjim/nui.nvim',
  },
  lazy = false,
  deactivate = function()
    vim.cmd [[Neotree close]]
  end,
  keys = {
    {
      '<leader>fe',
      function()
        local current = vim.api.nvim_buf_get_name(0)
        local start = current ~= '' and current or vim.fn.getcwd()
        local root = vim.fs.root(start, { '.git' }) or vim.fn.getcwd()

        require('neo-tree.command').execute {
          toggle = true,
          dir = root,
          source = 'filesystem',
        }
      end,
      desc = 'Explorer NeoTree (Root Dir)',
      silent = true,
    },
    {
      '<leader>fE',
      function()
        require('neo-tree.command').execute {
          toggle = true,
          dir = vim.fn.getcwd(),
          source = 'filesystem',
        }
      end,
      desc = 'Explorer NeoTree (cwd)',
      silent = true,
    },
    { '<leader>e', '<leader>fe', desc = 'Explorer NeoTree (Root Dir)', remap = true },
    { '<leader>E', '<leader>fE', desc = 'Explorer NeoTree (cwd)', remap = true },
    {
      '<leader>ge',
      function()
        require('neo-tree.command').execute { source = 'git_status', toggle = true }
      end,
      desc = 'Git Explorer',
      silent = true,
    },
    {
      '<leader>be',
      function()
        require('neo-tree.command').execute { source = 'buffers', toggle = true }
      end,
      desc = 'Buffer Explorer',
      silent = true,
    },
  },
  ---@module 'neo-tree'
  ---@type neotree.Config
  opts = {
    close_if_last_window = false,
    enable_diagnostics = true,
    enable_git_status = true,
    enable_modified_markers = true,
    sources = { 'filesystem', 'buffers', 'git_status' },
    open_files_do_not_replace_types = { 'terminal', 'Trouble', 'trouble', 'qf', 'Outline' },
    filesystem = {
      bind_to_cwd = false,
      follow_current_file = {
        enabled = true,
        leave_dirs_open = false,
      },
      use_libuv_file_watcher = true,
      window = {
        mappings = {
          ['\\'] = 'close_window',
          ['<bs>'] = 'navigate_up',
          ['.'] = 'set_root',
          ['H'] = 'toggle_hidden',
          ['/'] = 'fuzzy_finder',
          ['D'] = 'fuzzy_finder_directory',
          ['#'] = 'fuzzy_sorter',
          ['f'] = 'filter_on_submit',
          ['<C-x>'] = 'clear_filter',
          ['[g'] = 'prev_git_modified',
          [']g'] = 'next_git_modified',
          ['i'] = 'show_file_details',
          ['b'] = 'rename_basename',
          ['o'] = { 'show_help', nowait = false, config = { title = 'Order by', prefix_key = 'o' } },
          ['oc'] = { 'order_by_created', nowait = false },
          ['od'] = { 'order_by_diagnostics', nowait = false },
          ['og'] = { 'order_by_git_status', nowait = false },
          ['om'] = { 'order_by_modified', nowait = false },
          ['on'] = { 'order_by_name', nowait = false },
          ['os'] = { 'order_by_size', nowait = false },
          ['ot'] = { 'order_by_type', nowait = false },
        },
      },
    },
    window = {
      position = 'left',
      width = 36,
      mappings = {
        ['l'] = 'open',
        ['h'] = 'close_node',
        ['<space>'] = 'none',
        ['Y'] = {
          function(state)
            local node = state.tree:get_node()
            local path = node:get_id()
            vim.fn.setreg('+', path, 'c')
          end,
          desc = 'Copy Path to Clipboard',
        },
        ['O'] = {
          function(state)
            require('lazy.util').open(state.tree:get_node().path, { system = true })
          end,
          desc = 'Open with System Application',
        },
        ['P'] = { 'toggle_preview', config = { use_float = false } },
      },
    },
    default_component_configs = {
      indent = {
        indent_size = 2,
        padding = 1,
        with_markers = true,
        with_expanders = true,
        indent_marker = vim.g.have_nerd_font and '│' or '|',
        last_indent_marker = vim.g.have_nerd_font and '└' or '\\',
        expander_collapsed = vim.g.have_nerd_font and '' or '+',
        expander_expanded = vim.g.have_nerd_font and '' or '-',
      },
      icon = {
        folder_closed = vim.g.have_nerd_font and '' or '+',
        folder_open = vim.g.have_nerd_font and '' or '-',
        -- These values are known-safe replacements for glyphs that moved between Nerd Font releases.
        folder_empty = vim.g.have_nerd_font and '󰜌' or '*',
        folder_empty_open = vim.g.have_nerd_font and '󰜌' or '-',
        use_filtered_colors = true,
        default = '*', -- nvim-web-devicons handles individual file type icons
        provider = function(icon, node)
          if node.type == 'file' or node.type == 'terminal' then
            local success, web_devicons = pcall(require, 'nvim-web-devicons')
            local name = node.type == 'terminal' and 'terminal' or node.name
            local ext = node.type == 'terminal' and nil or vim.fn.fnamemodify(node.name, ':e')
            if success then
              local devicon, hl = web_devicons.get_icon(name, ext, { default = true, strict = true })
              icon.text = devicon or icon.text
              icon.highlight = hl or icon.highlight
            end
          end
        end,
      },
      git_status = {
        symbols = {
          added = vim.g.have_nerd_font and '✚' or '+',
          modified = vim.g.have_nerd_font and '' or '~',
          deleted = '✖',
          renamed = vim.g.have_nerd_font and '󰁕' or '>',
          untracked = vim.g.have_nerd_font and '' or '?',
          ignored = vim.g.have_nerd_font and '' or '!',
          unstaged = vim.g.have_nerd_font and '󰄱' or 'U',
          staged = vim.g.have_nerd_font and '' or 'S',
          conflict = vim.g.have_nerd_font and '' or '!',
        },
      },
    },
  },
}

-- vim: ts=2 sts=2 sw=2 et
