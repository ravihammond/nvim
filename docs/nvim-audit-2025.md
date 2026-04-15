# Neovim Holy Grail Audit — April 2025

> **Purpose**: This is a living reference document. The intent is NOT to add everything at once.
> Instead, pick items one at a time, point Claude at this file, and say "install that part now."
>
> Each section includes a **bring-back recommendation** and a rough **priority tier**:
> - `P1` — High value, low friction, commonly needed
> - `P2` — Good to have, moderate complexity
> - `P3` — Optional, niche, or situational

---

## Table of Contents

1. [Old Config Audit (nvim.bak)](#1-old-config-audit)
2. [Vim Options Worth Restoring](#2-vim-options)
3. [Keymaps Worth Restoring](#3-keymaps)
4. [Plugins From Old Config — Keep vs Skip](#4-old-plugins)
5. [ThePrimeagen's Setup — Key Lessons](#5-theprimeagen)
6. [LazyVim Ecosystem — What's Changed](#6-lazyvim)
7. [Best Plugins by Category (2025 Ecosystem)](#7-best-plugins-by-category)
8. [Deprecated Plugins — Avoid](#8-deprecated)
9. [Repo Structure Options](#9-repo-structure)
10. [Recommended "Next Steps" Queue](#10-next-steps-queue)

---

## 1. Old Config Audit

**Source**: `~/.config/nvim.bak` — a LazyVim-based setup (install version 7/8).

### What the old config was

A minimal LazyVim wrapper. Almost everything was inherited from LazyVim defaults.
Custom config files (options, keymaps, autocmds) were all **empty** — 100% LazyVim defaults.
The only real customization was:
- `colorscheme`: `vim-monokai-tasty`
- `auto-session` plugin with custom keymaps
- LazyVim extras enabled: Copilot, Markdown, TOML, JSON

### Old Plugin List (from lazy-lock.json)

All 42 plugins — noting which are worth bringing back:

| Plugin | Purpose | Bring Back? |
|--------|---------|-------------|
| `LazyVim/LazyVim` | Meta-framework | No (using Kickstart now) |
| `rmagatti/auto-session` | Session save/restore | **Yes — P2** |
| `blink.cmp` | Completion engine | **Yes — P1** (already best-in-class) |
| `blink-cmp-copilot` | Copilot source for blink.cmp | Yes if adding Copilot — P2 |
| `bufferline.nvim` | Tab/buffer UI bar | Maybe — P3 |
| `catppuccin` | Color theme | **Yes — P1** (top community theme) |
| `conform.nvim` | Code formatter | **Yes — P1** |
| `copilot.lua` | GitHub Copilot inline completions | **Yes — P2** |
| `flash.nvim` | Enhanced motions/jump | **Yes — P1** |
| `friendly-snippets` | Snippet collection | Yes if using LuaSnip/blink — P2 |
| `fzf-lua` | Fuzzy file/grep picker | **Yes — P1** (or use snacks.picker) |
| `gitsigns.nvim` | Git hunk signs, blame | **Yes — P1** |
| `grug-far.nvim` | Find and replace UI | Yes — P2 |
| `lazydev.nvim` | LuaLS support for nvim configs | **Yes — P1** |
| `lualine.nvim` | Status line | **Yes — P1** |
| `markdown-preview.nvim` | Preview .md in browser | Yes — P2 |
| `mason.nvim` | LSP server installer | **Yes — P1** |
| `mason-lspconfig.nvim` | Mason/lspconfig bridge | **Yes — P1** |
| `mini.ai` | Better text objects (a,i) | Yes — P2 |
| `mini.icons` | Icon provider (replaces nvim-web-devicons) | Yes — P1 |
| `mini.pairs` | Auto-close brackets/quotes | Yes — P1 |
| `neo-tree.nvim` | File explorer sidebar | Maybe — P2 (see oil.nvim) |
| `noice.nvim` | Fancy cmdline/notifications UI | Maybe — P3 (heavy) |
| `nvim-lint` | Linter integration | **Yes — P1** |
| `nvim-lspconfig` | LSP client config | **Yes — P1** |
| `nvim-treesitter-textobjects` | TS-based text objects | Yes — P2 |
| `nvim-ts-autotag` | Auto-close HTML/JSX tags | Yes if doing web dev — P2 |
| `persistence.nvim` | Session persistence (simpler) | P3 (vs auto-session) |
| `plenary.nvim` | Lua utilities (dep) | As needed |
| `render-markdown.nvim` | In-buffer markdown rendering | **Yes — P1** |
| `SchemaStore.nvim` | JSON schema validation | Yes with JSON LSP — P2 |
| `snacks.nvim` | Collection of small utilities | **Yes — P1** (see section 7) |
| `todo-comments.nvim` | Highlight TODO/FIXME/NOTE | **Yes — P1** |
| `tokyonight.nvim` | Fallback theme | Keep as fallback |
| `trouble.nvim` | Diagnostics list viewer | Yes — P2 |
| `ts-comments.nvim` | Correct comment strings | Yes — P2 |
| `vim-monokai-tasty` | Old colorscheme | Skip (pick a better one) |
| `which-key.nvim` | Keymap hint popup | **Yes — P1** |
| `nui.nvim` | UI lib (dep for neo-tree, noice) | As dep only |

### Active LazyVim Extras (from lazyvim.json)

These represent categories of functionality you had enabled:

| Extra | What it gave you | Standalone equivalent |
|-------|-----------------|----------------------|
| `extras.ai.copilot` | GitHub Copilot | `copilot.lua` + `blink-cmp-copilot` |
| `extras.lang.markdown` | Markdown preview, render, LSP | `render-markdown.nvim` + `markdown-preview.nvim` |
| `extras.lang.toml` | TOML LSP (taplo) | Install `taplo` via Mason |
| `extras.lang.json` | JSON LSP + SchemaStore | Install `jsonls` via Mason + `SchemaStore.nvim` |

---

## 2. Vim Options

Your old config used 100% LazyVim defaults with zero custom options.
Current Kickstart sets sensible options but here are the **LazyVim defaults worth adding** if missing.

Compare against current `init.lua` and add selectively.

### LazyVim default options worth auditing

```lua
-- Appearance
vim.opt.number = true
vim.opt.relativenumber = true       -- relative line numbers (very useful with motions)
vim.opt.signcolumn = "yes"          -- always show sign column (prevents layout shift)
vim.opt.cursorline = true           -- highlight current line
vim.opt.colorcolumn = "80"          -- optional column guide
vim.opt.termguicolors = true        -- 24-bit color

-- Indentation
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false            -- LazyVim turns this off; use incsearch instead
vim.opt.incsearch = true

-- UX
vim.opt.scrolloff = 8               -- keep 8 lines above/below cursor (ThePrimeagen uses this)
vim.opt.sidescrolloff = 8
vim.opt.wrap = false                -- no line wrap
vim.opt.splitbelow = true           -- new h-splits go below
vim.opt.splitright = true           -- new v-splits go right
vim.opt.confirm = true              -- prompt instead of error on unsaved close

-- Performance
vim.opt.updatetime = 200            -- faster CursorHold (default 4000ms)
vim.opt.timeoutlen = 300            -- whichkey appears after 300ms

-- Undo
vim.opt.undofile = true             -- persist undo history across sessions
vim.opt.undolevels = 10000

-- Completion
vim.opt.completeopt = "menu,menuone,noselect"

-- Fold (optional — can be set by treesitter plugin later)
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldenable = false          -- start with folds open
```

**Priority**: `P1` — `relativenumber`, `scrolloff=8`, `wrap=false`, `splitbelow/right`
**Priority**: `P2` — `cursorline`, `updatetime`, `undolevels`
**Priority**: `P3` — fold settings (let treesitter handle when ready)

---

## 3. Keymaps

Your old config had **zero custom keymaps** (beyond auto-session). Everything came from LazyVim.

### High-value keymaps to add (P1)

These are widely used, come from LazyVim defaults or ThePrimeagen, and add significant productivity:

```lua
-- Better window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to below window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to above window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Move lines up/down (LazyVim standard)
vim.keymap.set("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move line up" })
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Better indenting (stay in visual mode)
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- Clear search highlight
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Save file
vim.keymap.set({ "n", "i", "x" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })

-- Quit all
vim.keymap.set("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })

-- Buffers
vim.keymap.set("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
vim.keymap.set("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer" })

-- ThePrimeagen favorites
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down, center cursor" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up, center cursor" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result, center" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Prev search result, center" })

-- Paste without overwriting register
vim.keymap.set("x", "<leader>p", '"_dP', { desc = "Paste without yanking" })

-- Yank to system clipboard explicitly
vim.keymap.set({ "n", "v" }, "<leader>y", '"+y', { desc = "Yank to clipboard" })
vim.keymap.set("n", "<leader>Y", '"+Y', { desc = "Yank line to clipboard" })

-- Delete without yanking
vim.keymap.set({ "n", "v" }, "<leader>d", '"_d', { desc = "Delete without yanking" })
```

### Session keymaps (from old auto-session config) — P2

```lua
vim.keymap.set("n", "<leader>wr", "<cmd>SessionSearch<CR>", { desc = "Session search" })
vim.keymap.set("n", "<leader>ws", "<cmd>SessionSave<CR>", { desc = "Save session" })
vim.keymap.set("n", "<leader>wa", "<cmd>SessionToggleAutoSave<CR>", { desc = "Toggle autosave" })
```

### LazyVim leader groups (needs which-key) — P2

```lua
-- Register leader key groups with which-key for discoverability
require("which-key").add({
  { "<leader>b", group = "buffer" },
  { "<leader>c", group = "code" },
  { "<leader>f", group = "find/file" },
  { "<leader>g", group = "git" },
  { "<leader>s", group = "search" },
  { "<leader>u", group = "ui/toggle" },
  { "<leader>w", group = "window/session" },
  { "<leader>x", group = "diagnostics" },
})
```

---

## 4. Old Plugins — Bring-Back Decisions

### Definite YES (P1)

| Plugin | Why |
|--------|-----|
| `blink.cmp` | Best completion engine right now; faster than nvim-cmp |
| `conform.nvim` | Standard formatter; lightweight |
| `nvim-lint` | Standard linter integration |
| `gitsigns.nvim` | Near-universal; git hunks, blame, staging |
| `lazydev.nvim` | Required for proper LuaLS when editing this config |
| `lualine.nvim` | Easiest, most-featured statusline |
| `mason.nvim` + `mason-lspconfig.nvim` | LSP installer (Kickstart already has this) |
| `mini.icons` | Modern icon provider; replaces nvim-web-devicons |
| `render-markdown.nvim` | Excellent in-buffer markdown rendering |
| `todo-comments.nvim` | Very low-effort, high-value annotation highlighting |
| `which-key.nvim` | Keymap discoverability (Kickstart already has this) |
| `flash.nvim` | Enhanced motions; worth learning |

### Probably YES (P2)

| Plugin | Why |
|--------|-----|
| `auto-session` or `persistence.nvim` | Session restore on open; pick one |
| `copilot.lua` | You had it before; useful for completions |
| `fzf-lua` or `snacks.picker` | Faster than telescope for large projects |
| `grug-far.nvim` | Better find-replace than vim's `:s` |
| `mini.ai` | Better `a`/`i` text objects (e.g. `vaf` = visual around function) |
| `mini.pairs` | Auto-close brackets |
| `neo-tree.nvim` OR `oil.nvim` | You need a file explorer — pick one |
| `noice.nvim` | Great UI for cmdline/messages, but heavier — optional |
| `SchemaStore.nvim` | Only useful alongside JSON LSP |
| `snacks.nvim` | Replaces ~10 small plugins; see section 7 |
| `trouble.nvim` | Better diagnostics list than native |
| `ts-comments.nvim` | Correct comment strings per-language |

### Maybe (P3 / situational)

| Plugin | Notes |
|--------|-------|
| `bufferline.nvim` | Buffer tabs at top; some love it, some disable it |
| `markdown-preview.nvim` | Only useful if you write a lot of docs |
| `nvim-ts-autotag` | Only if you write HTML/JSX regularly |
| `nvim-treesitter-textobjects` | Powerful but requires learning; add when ready |
| `persistence.nvim` | Lighter alternative to auto-session |

### Skip

| Plugin | Why |
|--------|-----|
| `vim-monokai-tasty` | Pick a better theme (catppuccin, kanagawa, rose-pine) |
| `LazyVim/LazyVim` | Not using LazyVim framework anymore |
| `catppuccin` (from bak) | Good choice — bring back if you want it |

---

## 5. ThePrimeagen's Setup — Key Lessons

**Repo**: `github.com/ThePrimeagen/init.lua` (4k stars, lazy.nvim-based)

### His stack

| Category | Choice |
|----------|--------|
| Fuzzy finder | telescope.nvim |
| File nav | harpoon2 (no file tree!) |
| Git | vim-fugitive |
| LSP | nvim-lspconfig + mason + nvim-cmp |
| Completion | nvim-cmp (not blink.cmp — he hasn't switched) |
| Undo | undotree |
| Theme | rose-pine |
| Formatter | conform.nvim |

### Philosophy worth adopting

1. **`<C-d>/<C-u>zz`** — scroll half-page and re-center cursor. One of his most-shared tips. Simple and very effective.

2. **`nzzzv` / `Nzzzv`** — jump to next search result AND center the screen. Huge quality-of-life.

3. **No file tree** — he navigates by fuzzy finding + harpoon marks. Controversial but worth knowing about.

4. **Harpoon** — marks specific files (not MRU) so you can jump between 4–5 "active" files instantly. Completely different from a file tree. `P2` — worth adding if you work across small sets of files.

5. **Undotree** — visual undo history. Very useful, very low cost. `P2`.

6. **Keep it small** — he has publicly said he tries plugins and removes them if they don't improve his actual workflow. Good philosophy.

### ThePrimeagen-specific keymaps worth taking

```lua
-- Center on scroll (very popular)
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- Center on search jump
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Paste over without losing register
vim.keymap.set("x", "<leader>p", '"_dP')

-- Yank explicitly to system clipboard
vim.keymap.set({"n","v"}, "<leader>y", '"+y')
vim.keymap.set("n", "<leader>Y", '"+Y')

-- Delete without polluting default register
vim.keymap.set({"n","v"}, "<leader>d", '"_d')

-- Quick fix navigation
vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")
```

---

## 6. LazyVim Ecosystem — What's Changed (2024–2026)

This tracks what LazyVim did with each major release so you can understand which plugins are "current winners."

### LazyVim v14 (Dec 2024) — Big switches

| Old | New | Why |
|-----|-----|-----|
| `telescope.nvim` (default) | `fzf-lua` | Speed — fzf-lua is faster with large repos |
| `nvim-cmp` | `blink.cmp` | Rust fuzzy core; faster; fewer packages needed |
| `dressing.nvim` | `snacks.input` | Consolidated into snacks |
| `nvim-notify` | `snacks.notifier` | Consolidated into snacks |
| `indent-blankline.nvim` | `snacks.indent` | Consolidated into snacks |
| `alpha.nvim` | `snacks.dashboard` | Consolidated into snacks |
| `nvim-spectre` | `grug-far.nvim` | Better UX for find/replace |
| `headlines.nvim` | `render-markdown.nvim` | Better markdown rendering |

### LazyVim v15 (2025) — Neovim 0.11 native APIs

- **Requires Neovim >= 0.11.2**
- LSP configured with **native `vim.lsp.config`** API (no lspconfig needed for simple servers)
- Mason v2 + mason-lspconfig v2
- nvim-treesitter switched to `main` branch
- Native LSP folding

### LazyVim Extras worth knowing about

These are "batteries" you can pull in selectively:

**Language extras** (each installs LSP + formatter + linter for that language):
- `lang.python` — pyright/basedpyright + ruff
- `lang.typescript` — vtsls (not tsserver)
- `lang.rust` — rust_analyzer
- `lang.go` — gopls + gofumpt
- `lang.markdown` — marksman + render-markdown + markdown-preview
- `lang.json` — jsonls + SchemaStore
- `lang.toml` — taplo
- `lang.yaml` — yamlls + SchemaStore
- `lang.docker` — dockerls
- `lang.sql` — sqls/sqlls

**Editor extras worth knowing**:
- `editor.harpoon2` — ThePrimeagen's harpoon
- `editor.telescope` — if you prefer telescope over fzf-lua
- `editor.trouble-v3` — new trouble.nvim
- `editor.aerial` — code outline sidebar
- `editor.refactoring` — ThePrimeagen's refactoring.nvim

**AI extras**:
- `ai.copilot` — inline completions
- `ai.copilot-chat` — chat interface
- `ai.avante` — Cursor-style AI
- `ai.codeium` — free Copilot alternative
- `ai.supermaven` — very fast inline completions

---

## 7. Best Plugins by Category (2025 Ecosystem)

### Completion

| Plugin | Repo | Notes |
|--------|------|-------|
| **blink.cmp** ⭐ | `saghen/blink.cmp` | **Current standard**. Rust core, fast, built-in sources (LSP/buffer/path/snippets), no extra cmp-* packages |
| nvim-cmp | `hrsh7th/nvim-cmp` | Still works, still maintained, but blink.cmp is faster and simpler |

**Verdict**: Use blink.cmp. Kickstart may already be in the process of switching.

---

### LSP

| Plugin | Repo | Notes |
|--------|------|-------|
| **nvim-lspconfig** ⭐ | `neovim/nvim-lspconfig` | Still standard for most configs |
| mason.nvim | `williamboman/mason.nvim` | Installer for LSP servers, formatters, linters |
| mason-lspconfig | `williamboman/mason-lspconfig.nvim` | Bridge between mason and lspconfig |
| **lazydev.nvim** ⭐ | `folke/lazydev.nvim` | LuaLS types for Neovim API — essential for this config |
| Native `vim.lsp.config` | (built-in, Neovim 0.11+) | Future direction; lspconfig may become optional |

**Key LSP servers to install via Mason**:
- `lua_ls` — Lua (essential for this config)
- `pyright` or `basedpyright` — Python
- `vtsls` — TypeScript/JavaScript (modern, replaces tsserver)
- `rust_analyzer` — Rust
- `gopls` — Go

---

### Fuzzy Finder / Picker

| Plugin | Repo | Notes |
|--------|------|-------|
| **fzf-lua** ⭐ | `ibhagwan/fzf-lua` | LazyVim v14+ default; requires `fzf` binary; extremely fast |
| **snacks.picker** | `folke/snacks.nvim` | Newest; true Normal mode; 40+ sources; part of snacks.nvim |
| telescope.nvim | `nvim-telescope/telescope.nvim` | Most popular historically; very extensible; still fine |

**Kickstart ships with telescope** — you can stay with it or swap to fzf-lua/snacks.picker.

---

### File Explorer

| Plugin | Repo | Philosophy |
|--------|------|-----------|
| **oil.nvim** ⭐ | `stevearc/oil.nvim` | Edit filesystem like a Neovim buffer; Vim-native feel |
| neo-tree.nvim | `nvim-neo-tree/neo-tree.nvim` | Sidebar; feature-rich; supports git/buffers/remote |
| nvim-tree.lua | `nvim-tree/nvim-tree.lua` | Traditional sidebar; NvChad default |
| snacks.explorer | `folke/snacks.nvim` | Part of snacks; actually a picker |
| No tree (ThePrimeagen) | — | Use fuzzy finder + harpoon instead |

**Recommendation**: Oil.nvim is the philosophically "vim-correct" choice. neo-tree.nvim if you want a traditional sidebar with more features.

---

### Statusline

| Plugin | Repo | Notes |
|--------|------|-------|
| **lualine.nvim** ⭐ | `nvim-lualine/lualine.nvim` | Most popular; easy; lots of themes; ~15min to set up |
| heirline.nvim | `rebelot/heirline.nvim` | Most powerful; fully custom; steeper learning curve |
| mini.statusline | `echasnovski/mini.nvim` | Minimal; part of mini.nvim |

**You had lualine before** — it's a safe, excellent default.

---

### Git

| Plugin | Repo | Role |
|--------|------|------|
| **gitsigns.nvim** ⭐ | `lewis6991/gitsigns.nvim` | Near-universal; hunk signs, blame, staging — install this first |
| neogit | `NeogitOrg/neogit` | Magit clone; interactive staging UI; pairs with diffview |
| diffview.nvim | `sindrets/diffview.nvim` | Beautiful side-by-side diff; works standalone + with neogit |
| vim-fugitive | `tpope/vim-fugitive` | ThePrimeagen's choice; full git from cmdline |
| lazygit.nvim / snacks.lazygit | `kdheepak/lazygit.nvim` | Float the lazygit TUI inside Neovim |

**You already have lazygit installed** — `snacks.lazygit` or `lazygit.nvim` would wire it to a keymap.

---

### Motion / Navigation

| Plugin | Repo | Style |
|--------|------|-------|
| **flash.nvim** ⭐ | `folke/flash.nvim` | Enhanced `/` search with jump labels; TS node selection |
| leap.nvim | `ggandor/leap.nvim` | 2-char atomic jumping; "autopilot" feel |
| hop.nvim | `smoka7/hop.nvim` | EasyMotion-style; less popular now |
| **harpoon2** | `ThePrimeagen/harpoon` | Persistent file marks; instant switching between active files |
| undotree | `mbbill/undotree` | Visual undo history tree |

---

### AI Coding

| Plugin | Repo | Style |
|--------|------|-------|
| **copilot.lua** ⭐ | `zbirenbaum/copilot.lua` | Inline ghost-text completions; what you had before |
| **avante.nvim** | `yetone/avante.nvim` | Cursor-style: sidebar chat + apply diffs; 17k+ stars |
| codecompanion.nvim | `olimorris/codecompanion.nvim` | Vim-native feel; slash commands; less intrusive |
| CopilotChat.nvim | `CopilotC-Nvim/CopilotChat.nvim` | Chat interface on top of Copilot |
| supermaven.nvim | `supermaven-inc/supermaven-nvim` | Very fast free inline completions |

**You had Copilot before** — easy to restore. Avante is the exciting new entrant for a Cursor-like experience inside Neovim.

---

### Theming

| Theme | Repo | Character |
|-------|------|-----------|
| **catppuccin** ⭐ | `catppuccin/nvim` | Warm pastels; 4 variants; most popular trend |
| tokyonight | `folke/tokyonight.nvim` | Cool blues; LazyVim default; #1 by install count |
| kanagawa | `rebelot/kanagawa.nvim` | Muted Japanese aesthetic; #3 overall |
| rose-pine | `rose-pine/neovim` | Muted pinks/earth; ThePrimeagen's choice |
| everforest | `sainnhe/everforest` | Green-forest; easy on eyes |
| cyberdream | `scottmckendry/cyberdream.nvim` | High-contrast neon; fast-growing |
| gruvbox-material | `sainnhe/gruvbox-material` | Warm brown retro |

**You had vim-monokai-tasty** — consider switching to catppuccin or kanagawa.

---

### Utilities / QoL

| Plugin | Repo | What it does |
|--------|------|-------------|
| **snacks.nvim** ⭐ | `folke/snacks.nvim` | 30+ small utilities in one package (see below) |
| **todo-comments.nvim** | `folke/todo-comments.nvim` | Highlight TODO/FIXME/HACK/NOTE in all files |
| **grug-far.nvim** | `MagicDuck/grug-far.nvim` | Nicer project-wide find & replace |
| **render-markdown.nvim** | `MeanderingProgrammer/render-markdown.nvim` | Beautiful in-buffer markdown rendering |
| noice.nvim | `folke/noice.nvim` | Fancy cmdline, messages, notifications UI |
| trouble.nvim | `folke/trouble.nvim` | Better diagnostics/quickfix list |
| nvim-treesitter-textobjects | `nvim-treesitter/...` | `vaf` = select function; `vac` = select class |
| mini.surround | `echasnovski/mini.nvim` | Add/delete/change surrounding chars |
| mini.ai | `echasnovski/mini.nvim` | Better `a`/`i` text objects |
| fidget.nvim | `j-hui/fidget.nvim` | LSP progress spinner |
| inc-rename.nvim | `smjonas/inc-rename.nvim` | Live preview of LSP rename in cmdline |
| auto-session | `rmagatti/auto-session` | Session save on exit, restore on open |

### snacks.nvim — What it replaces

`folke/snacks.nvim` is a single-package collection of 30+ small utilities. You get to enable only what you want:

| snacks module | Replaces |
|---------------|---------|
| `snacks.picker` | telescope.nvim / fzf-lua |
| `snacks.dashboard` | alpha.nvim |
| `snacks.notifier` | nvim-notify |
| `snacks.input` | dressing.nvim |
| `snacks.indent` | indent-blankline.nvim |
| `snacks.scroll` | neoscroll.nvim |
| `snacks.zen` | zen-mode.nvim |
| `snacks.dim` | twilight.nvim |
| `snacks.lazygit` | lazygit.nvim |
| `snacks.terminal` | toggleterm.nvim |
| `snacks.words` | vim-illuminate (LSP reference nav) |
| `snacks.bigfile` | bigfile.nvim |
| `snacks.git` / `snacks.gitbrowse` | vim-rhubarb |
| `snacks.image` | image.nvim (Kitty terminal) |
| `snacks.statuscolumn` | statuscol.nvim |

---

## 8. Deprecated Plugins — Avoid

If you encounter any of these, don't add them:

| Plugin | Status | Use instead |
|--------|--------|------------|
| `packer.nvim` | **Archived/dead** | lazy.nvim |
| `neodev.nvim` | **Officially EOL** | lazydev.nvim |
| `null-ls.nvim` | **Archived** | conform.nvim + nvim-lint |
| `none-ls.nvim` | Fork of null-ls; moving away | conform.nvim + nvim-lint |
| `nvim-lsp-installer` | Superseded | mason.nvim |
| `lightspeed.nvim` | Same author made leap.nvim | leap.nvim or flash.nvim |
| `hop.nvim` | Less popular | flash.nvim |
| `alpha.nvim` | Replaced in LazyVim | snacks.dashboard |
| `dressing.nvim` | Replaced in LazyVim | snacks.input |
| `nvim-spectre` | Replaced in LazyVim | grug-far.nvim |
| `headlines.nvim` | Replaced in LazyVim | render-markdown.nvim |
| `tsserver` (LSP) | Deprecated by TypeScript team | vtsls |
| `nvim-cmp` (as new choice) | Being superseded | blink.cmp |
| `nvim-treesitter` `master` branch | Old branch | use `main` branch |
| `telescope-fzf-native.nvim` | Replaced | fzf-lua (standalone) |

---

## 9. Repo Structure Options

### Current structure (Kickstart single-file)

```
~/.config/nvim/
├── init.lua              ← everything in here (978 lines)
├── lazy-lock.json
├── docs/
│   └── nvim-audit-2025.md
└── lua/
    ├── kickstart/plugins/  ← optional kickstart plugins (already split)
    └── custom/plugins/     ← user additions
```

### Option A: Stay single-file (recommended for now)

Keep everything in `init.lua`. Kickstart is designed this way.
The `lua/kickstart/plugins/` directory already exists as an escape hatch for optional plugins.

**When to split**: When `init.lua` exceeds ~1000–1200 lines and becomes hard to navigate.

### Option B: Kickstart modular split (natural next step)

The official kickstart modular fork: `dam9000/kickstart-modular.nvim`

```
~/.config/nvim/
├── init.lua                    ← just: require("config")
├── lazy-lock.json
└── lua/
    └── config/
        ├── init.lua            ← lazy.nvim setup
        ├── options.lua
        ├── keymaps.lua
        ├── autocmds.lua
        └── plugins/
            ├── lsp.lua
            ├── completion.lua
            ├── treesitter.lua
            ├── telescope.lua
            ├── git.lua
            ├── ui.lua
            └── theme.lua
```

lazy.nvim can auto-import all files in a directory:
```lua
require("lazy").setup({ import = "config.plugins" })
```

### Option C: ThePrimeagen style

```
~/.config/nvim/
├── init.lua                    ← requires lua/theprimeagen/
└── lua/theprimeagen/
    ├── lazy_init.lua
    ├── lazy.lua
    ├── remap.lua
    ├── set.lua
    └── after/plugin/
        ├── telescope.lua
        ├── treesitter.lua
        ├── lsp.lua
        └── ...
```

`after/plugin/` files run after each plugin loads — clean separation but less declarative than lazy.nvim `config = function()`.

### Recommendation

**Stay with the current single-file structure** until you've added 5–10 more plugins. Then do Option B (kickstart-modular). It's the lowest-friction upgrade path and well-documented.

---

## 10. Recommended "Next Steps" Queue

This is a suggested order for bringing things back, one at a time. Each item is self-contained.

### Batch 1 — Core QoL (do these first, each is ~5–15 lines)

- [ ] **`relativenumber` + `scrolloff=8`** — add to vim options. Zero deps.
- [ ] **Primeagen scroll keymaps** — `<C-d>zz`, `<C-u>zz`, `nzzzv`, `Nzzzv`. Zero deps.
- [ ] **`<C-s>` to save** — tiny keymap, universal habit.
- [ ] **`<S-h>`/`<S-l>` for buffer nav** — if using multiple buffers.
- [ ] **Paste-without-clobbering register** — `<leader>p` in visual mode.

### Batch 2 — Theming

- [ ] **catppuccin** or **kanagawa** — swap out the default theme.
- [ ] **lualine.nvim** — status line with theme support.

### Batch 3 — LSP / Completion Enhancement

- [ ] **lazydev.nvim** — LuaLS types for this config (very useful while editing init.lua).
- [ ] **blink.cmp** — swap nvim-cmp → blink.cmp (Kickstart may already have done this).
- [ ] **fidget.nvim** — LSP progress spinner in corner.

### Batch 4 — Git

- [ ] **gitsigns.nvim** — already in Kickstart; configure keymaps.
- [ ] **snacks.lazygit** or `lazygit.nvim` — bind `<leader>gg` to open lazygit float.
- [ ] **diffview.nvim** — for visual git diff navigation.

### Batch 5 — File Navigation

- [ ] **oil.nvim** — open parent dir with `-`, edit like a buffer.
- [ ] **todo-comments.nvim** — highlight TODOs across project; `<leader>st` to search.
- [ ] **flash.nvim** or **harpoon2** — motion enhancement.

### Batch 6 — Code Quality

- [ ] **conform.nvim** — formatter (Kickstart likely already has this; configure servers).
- [ ] **nvim-lint** — linter (configure per-language).
- [ ] **trouble.nvim** — better diagnostic list.
- [ ] **grug-far.nvim** — project-wide find & replace.

### Batch 7 — Rich Extras

- [ ] **render-markdown.nvim** — if you write markdown.
- [ ] **snacks.nvim** — enable the modules you want one by one.
- [ ] **auto-session** — session save/restore (your old config had this).
- [ ] **mini.ai** + **mini.surround** — better text objects.
- [ ] **noice.nvim** — fancy UI (optional, heavier).

### Batch 8 — AI

- [ ] **copilot.lua** — inline completions; you had this before.
- [ ] **avante.nvim** — Cursor-style AI assistant, if you want that workflow.
- [ ] **codecompanion.nvim** — more Vim-native AI alternative.

---

*Last updated: April 2025*
*Sources: nvim.bak audit, ThePrimeagen/init.lua, LazyVim docs/changelog, dotfyle.com, rockerBOO/awesome-neovim*
