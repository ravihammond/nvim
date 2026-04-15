# Neovim Holy Grail Audit — April 2025

> **Purpose**: This is a living reference document. The intent is NOT to add everything at once.
> Instead, pick items one at a time, point Claude at this file, and say "install that part now."
>
> **How to read this doc**: Each item is marked with its current status and a priority tier:
>
> | Symbol | Meaning |
> |--------|---------|
> | ✅ INSTALLED | Already in your config and working right now |
> | ⚙️ INSTALLED (not configured) | The package is installed but the specific module/feature isn't set up yet |
> | ❌ NOT INSTALLED | Needs to be added |
> | `P1` | High value, low friction — do these first |
> | `P2` | Good to have, moderate complexity |
> | `P3` | Optional, niche, or situational |

---

## What is a "plugin" in Neovim?

Neovim's core is deliberately minimal — it's a text editor. Plugins are Lua programs that extend it. They're managed by **lazy.nvim** (your plugin manager), which automatically downloads them from GitHub, keeps them updated, and loads them efficiently so your editor starts fast.

When you add a plugin to your `init.lua`, lazy.nvim clones its repo the next time you open Neovim and runs whatever setup code you configure.

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

**Source**: `~/.config/nvim.bak` — your previous setup, built on LazyVim (a Neovim distribution).

### What LazyVim was

LazyVim is an opinionated "starter kit" that pre-configures ~40 plugins for you so you don't have to set things up from scratch. Think of it like a curated bundle — you got a lot of features for free, but it was hard to know exactly what was doing what. You've now moved to **Kickstart**, which is a minimal starting point where you own and understand every line. Less magic, more control.

Your old LazyVim config was almost entirely default settings — the custom files (options, keymaps, autocmds) were all empty. The only real additions you made were:

- **Colorscheme**: vim-monokai-tasty (a dark Monokai-style theme)
- **auto-session**: a plugin that saved and restored your editing sessions
- **LazyVim extras enabled**: GitHub Copilot, Markdown tooling, TOML language support, JSON language support

### Old Plugin List (from lazy-lock.json)

All 42 plugins you had — with plain-English explanations and whether to bring them back:

| Plugin | What it actually does | Status | Bring Back? |
|--------|----------------------|--------|-------------|
| `LazyVim/LazyVim` | The LazyVim framework itself — the meta-plugin that pulled in everything else | N/A | No — you're on Kickstart now |
| `rmagatti/auto-session` | Automatically saves your open files, cursor position, and window layout when you close Neovim, then restores them next time you open it in the same directory | ❌ NOT INSTALLED | **Yes — P2** |
| `blink.cmp` | The autocomplete popup that appears as you type — suggests completions from your LSP server, open buffers, file paths, and snippets | ✅ INSTALLED | Already here |
| `blink-cmp-copilot` | Adds GitHub Copilot as a source inside blink.cmp's completion popup (so Copilot suggestions appear alongside LSP suggestions in the same menu) | ❌ NOT INSTALLED | Yes if adding Copilot — P2 |
| `bufferline.nvim` | Puts a tab bar at the top of the screen showing all your open files (buffers), like browser tabs | ❌ NOT INSTALLED | Maybe — P3 |
| `catppuccin` | A popular color theme with warm pastel tones — comes in 4 variants (latte/frappe/macchiato/mocha) | ❌ NOT INSTALLED | **Yes — P1** |
| `conform.nvim` | Runs code formatters automatically when you save — e.g. prettier for JS, black for Python, stylua for Lua | ✅ INSTALLED | Already here |
| `copilot.lua` | GitHub Copilot integration — shows AI-generated code suggestions as "ghost text" while you type, press Tab to accept | ❌ NOT INSTALLED | **Yes — P2** |
| `flash.nvim` | Supercharges jumping around the file — type a few letters and it overlays labels on every match so you can jump precisely with one more keypress | ❌ NOT INSTALLED | **Yes — P1** |
| `friendly-snippets` | A large collection of pre-made code snippets for dozens of languages (for-loops, function templates, etc.) that work with your snippet engine | ❌ NOT INSTALLED | Yes if using LuaSnip — P2 |
| `fzf-lua` | A very fast fuzzy file finder — type partial filenames or grep patterns and it shows matches instantly. Faster than Telescope for large projects | ❌ NOT INSTALLED | **Yes — P1** (you currently have Telescope instead) |
| `gitsigns.nvim` | Shows git change indicators in the left margin of the editor (green `+` for added lines, orange `~` for modified, red `-` for deleted). Also lets you stage/unstage individual changed sections ("hunks") | ✅ INSTALLED | Already here |
| `grug-far.nvim` | A project-wide find-and-replace UI — search across all files with regex or ripgrep, preview matches, and apply replacements interactively | ❌ NOT INSTALLED | Yes — P2 |
| `lazydev.nvim` | Makes your Lua language server (lua_ls) aware of all the Neovim-specific APIs while editing your config — so you get autocomplete and type hints for `vim.o`, `vim.keymap`, etc. | ❌ NOT INSTALLED | **Yes — P1** |
| `lualine.nvim` | A fully customizable status bar at the bottom of your screen — shows current mode, filename, git branch, LSP diagnostics, line/column number, etc. | ❌ NOT INSTALLED | **Yes — P1** (you currently have mini.statusline, a simpler version) |
| `markdown-preview.nvim` | Opens your current Markdown file in a browser tab and live-reloads it as you type | ❌ NOT INSTALLED | Yes — P2 |
| `mason.nvim` | A package manager for LSP servers, formatters, and linters — lets you install things like `pyright`, `lua_ls`, `prettier` with a simple UI using `:Mason` | ✅ INSTALLED | Already here |
| `mason-lspconfig.nvim` | The bridge between Mason and nvim-lspconfig — automatically connects LSP servers that Mason installed to Neovim's LSP client | ✅ INSTALLED | Already here |
| `mini.ai` | Enhances Vim's built-in text objects. Normally `vib` = select inside brackets. mini.ai adds smarter objects like `vaf` (select around a function), `vac` (select around a class), `via` (select inside an argument) | ✅ INSTALLED (configured) | Already here |
| `mini.icons` | A modern icon provider that supplies file-type icons used by other plugins. Meant to replace the older `nvim-web-devicons` package | ⚙️ INSTALLED (not configured) | Could replace nvim-web-devicons — P2 |
| `mini.pairs` | Automatically inserts the closing bracket/quote when you type an opening one — type `(` and you get `()` with cursor in the middle | ⚙️ INSTALLED (not configured) | **Yes — P1** — easy to enable |
| `neo-tree.nvim` | A traditional sidebar file explorer — shows your project directory tree on the left side, like VS Code's file panel | ❌ NOT INSTALLED | Maybe — P2 (see oil.nvim below) |
| `noice.nvim` | Replaces Neovim's plain command-line area and notification system with a polished floating UI — commands appear in a pop-up, errors in styled notifications | ❌ NOT INSTALLED | Maybe — P3 (heavier plugin) |
| `nvim-lint` | Runs linters (code quality checkers) asynchronously as you type — e.g. eslint for JS, ruff for Python — and shows warnings/errors as diagnostics | ❌ NOT INSTALLED | **Yes — P1** |
| `nvim-lspconfig` | Pre-written configurations for 100+ language servers — without this you'd have to write all the LSP setup code yourself for each language | ✅ INSTALLED | Already here |
| `nvim-treesitter-textobjects` | Adds more intelligent text objects powered by Treesitter syntax trees — e.g. select the next function, move to the previous class, swap function arguments | ❌ NOT INSTALLED | Yes — P2 |
| `nvim-ts-autotag` | Automatically closes and renames HTML/JSX/XML tags as you type — type `<div` and you get `<div></div>` | ❌ NOT INSTALLED | Yes if doing web dev — P2 |
| `persistence.nvim` | A simpler session manager than auto-session — saves open files per-directory and restores them. Less features but zero configuration | ❌ NOT INSTALLED | P3 (vs auto-session) |
| `plenary.nvim` | A Lua utility library that other plugins depend on (Telescope requires it). You don't interact with it directly | ✅ INSTALLED | Already here (as a dependency) |
| `render-markdown.nvim` | Renders Markdown formatting INSIDE Neovim while you edit — headings get styled, code blocks get background colors, checkboxes become actual boxes. No browser needed | ❌ NOT INSTALLED | **Yes — P1** |
| `SchemaStore.nvim` | Provides JSON/YAML schema validation — when editing `package.json`, `.eslintrc`, `docker-compose.yml`, etc., it gives you autocomplete and type checking for valid field names | ❌ NOT INSTALLED | Yes alongside JSON LSP — P2 |
| `snacks.nvim` | A Swiss Army knife plugin from the author of lazy.nvim and LazyVim — bundles 30+ small utilities (file picker, dashboard, notifications, lazygit integration, etc.) into one package you enable à la carte | ❌ NOT INSTALLED | **Yes — P1** (see section 7) |
| `todo-comments.nvim` | Scans all your files for comments like `TODO:`, `FIXME:`, `HACK:`, `NOTE:` and highlights them in distinct colors. Also lets you search/jump to all of them across your project | ✅ INSTALLED | Already here |
| `tokyonight.nvim` | A cool blue/purple color theme — the default for LazyVim and the most-installed Neovim theme overall | ✅ INSTALLED | Already here (currently active theme) |
| `trouble.nvim` | A better diagnostics panel — shows all LSP errors, warnings, and hints from your entire project in a clean organized list at the bottom of the screen | ❌ NOT INSTALLED | Yes — P2 |
| `ts-comments.nvim` | Makes comment toggling (`gcc` to comment/uncomment a line) use the correct comment syntax per language — important in JSX files where different parts of a file need different comment styles | ❌ NOT INSTALLED | Yes — P2 |
| `vim-monokai-tasty` | Your old color theme — a dark Monokai style | ❌ NOT INSTALLED | Skip — pick a better one |
| `which-key.nvim` | Shows a popup menu of available key combinations when you pause after pressing a prefix key — e.g. press `<leader>` and wait, and it shows all `<leader>` keymaps. Essentially a keymap cheat sheet that appears on demand | ✅ INSTALLED | Already here |
| `nui.nvim` | A UI component library used by neo-tree and noice internally. You don't use it directly | ❌ NOT INSTALLED | Only needed as a dependency |

### Active LazyVim Extras you had enabled (from lazyvim.json)

These were "batteries included" feature packs in LazyVim. Here's what each one gave you and how to recreate that functionality in your current Kickstart setup:

| Extra | What it gave you | How to get it now |
|-------|-----------------|-------------------|
| `extras.ai.copilot` | GitHub Copilot inline suggestions as you type | Install `copilot.lua` — P2 |
| `extras.lang.markdown` | Markdown preview in browser + in-buffer rendering + LSP | Install `render-markdown.nvim` + `markdown-preview.nvim` — P1/P2 |
| `extras.lang.toml` | Autocomplete and validation in `.toml` files | Install `taplo` LSP server via `:Mason` |
| `extras.lang.json` | Autocomplete field names in JSON files + schema validation | Install `jsonls` via `:Mason` + `SchemaStore.nvim` |

---

## 2. Vim Options

**What are "vim options"?** These are settings that control how the editor behaves — like whether line numbers show, how indentation works, how search operates. They live at the top of `init.lua` before any plugins.

Your old LazyVim config used 100% defaults with zero custom options. Your current Kickstart already sets many good ones. Below is the full list with what each option actually does, and whether it's already configured.

### Options already set in your current config ✅

| Option | Current Value | What it does |
|--------|--------------|--------------|
| `number` | `true` | Shows line numbers on the left |
| `relativenumber` | `true` | Shows line numbers relative to your cursor (e.g. the line 3 above says "3" instead of the actual line number). Incredibly useful for jump commands like `5j` (go down 5 lines) or `d3k` (delete 3 lines up) |
| `mouse` | `'a'` | Enables mouse support — you can click to move the cursor, scroll, resize windows |
| `showmode` | `false` | Hides the `-- INSERT --` / `-- VISUAL --` text at the bottom (your statusline already shows this) |
| `breakindent` | `true` | When a long line wraps visually, the wrapped part is indented to match — makes wrapped text much more readable |
| `undofile` | `true` | Saves your undo history to disk — so even after closing and reopening a file, you can still undo changes from your last session |
| `ignorecase` | `true` | Search is case-insensitive by default (`/foo` finds "foo", "Foo", "FOO") |
| `smartcase` | `true` | UNLESS you type a capital letter — then search becomes case-sensitive. Works together with ignorecase |
| `signcolumn` | `'yes'` | Always reserves a column on the left for signs (git changes, LSP errors). Without this the editor would jump left/right as signs appear/disappear |
| `updatetime` | `250` | How many milliseconds of inactivity before Neovim writes the swap file and fires `CursorHold` events (which some plugins use). 250ms = snappier LSP responses |
| `timeoutlen` | `300` | How long Neovim waits after a key prefix before giving up. Affects how quickly which-key shows its popup |
| `splitright` | `true` | When you open a vertical split (`<C-w>v`), the new window opens on the RIGHT instead of left |
| `splitbelow` | `true` | When you open a horizontal split (`<C-w>s`), the new window opens BELOW instead of above |
| `list` | `true` | Makes invisible characters visible (tabs, trailing spaces) using the listchars below |
| `inccommand` | `'split'` | Shows a live preview of `:substitute` replacements in a split window as you type |
| `cursorline` | `true` | Highlights the entire line your cursor is on |
| `scrolloff` | `10` | Always keeps at least 10 lines visible above and below your cursor — so you're never editing right at the edge of the screen |
| `confirm` | `true` | Instead of erroring on `:q` with unsaved changes, it asks you "Save changes?" |

### Options NOT yet set — worth adding

| Option | Value to set | What it does | Priority |
|--------|-------------|--------------|---------|
| `wrap` | `false` | Turns off line wrapping — long lines go off-screen rather than wrapping. Most programmers prefer this; vertical space is precious | **P1** |
| `tabstop` | `2` | How many spaces a tab character displays as | P2 |
| `shiftwidth` | `2` | How many spaces the `>>` indent command uses | P2 |
| `expandtab` | `true` | Inserts spaces instead of real tab characters when you press Tab | P2 |
| `undolevels` | `10000` | How many undo steps to remember (default is only 1000) | P2 |
| `colorcolumn` | `"80"` | Draws a vertical line at column 80 as a soft reminder to keep lines short | P3 |
| Fold settings | (see below) | Code folding — collapse function bodies, etc. Best set by Treesitter when you're ready | P3 |

---

## 3. Keymaps

**What are keymaps?** Custom keyboard shortcuts you define. In Neovim, `<leader>` is a configurable prefix key — yours is set to `<Space>`. So `<leader>sf` means press Space, then `s`, then `f`.

**Modes**: `n` = Normal mode (navigating), `i` = Insert mode (typing), `v` = Visual mode (selection), `x` = Visual mode only (not select mode).

### Keymaps already set ✅

| Keys | Mode | What it does |
|------|------|-------------|
| `<C-h>` | Normal | Move cursor focus to the window on the LEFT (`C-` means Ctrl) |
| `<C-j>` | Normal | Move cursor focus to the window BELOW |
| `<C-k>` | Normal | Move cursor focus to the window ABOVE |
| `<C-l>` | Normal | Move cursor focus to the window on the RIGHT |
| `<Esc>` | Normal | Clears search highlighting (the yellow/orange matches that stay after a search) |
| `<leader>q` | Normal | Opens the diagnostic quickfix list — a list of all LSP errors/warnings in the current file |
| `<Esc><Esc>` | Terminal | Exits terminal mode (Neovim has a built-in terminal; this gets you back to Normal mode) |
| `<leader>sv` | Normal | Manually reload your config (added by us — equivalent to "save and hot-reload") |
| `<leader>sh` | Normal | Telescope: search Neovim help documentation |
| `<leader>sf` | Normal | Telescope: fuzzy-find files in your project |
| `<leader>sg` | Normal | Telescope: search inside all files using grep |
| `<leader>sd` | Normal | Telescope: show all LSP diagnostics across the project |
| `<leader>sr` | Normal | Telescope: resume the last search |
| `<leader><leader>` | Normal | Telescope: show open buffers (files currently loaded in memory) |

### High-value keymaps NOT yet set — worth adding (P1)

These are widely used across the community and ThePrimeagen's config. Each one is just a few lines to add:

| Keys | Mode | What it does | Why it's great |
|------|------|-------------|----------------|
| `<C-d>` → `<C-d>zz` | Normal | Scroll down half a page AND re-center the cursor | Without `zz`, the cursor jumps to the edge after scrolling — very disorienting. This keeps you centered |
| `<C-u>` → `<C-u>zz` | Normal | Scroll up half a page AND re-center | Same reason |
| `n` → `nzzzv` | Normal | Jump to NEXT search match AND re-center | Same pattern — you always know where you are |
| `N` → `Nzzzv` | Normal | Jump to PREVIOUS search match AND re-center | Same |
| `<A-j>` | Normal + Visual | Move the current line (or selection) DOWN one line | Drag lines around without cutting and pasting |
| `<A-k>` | Normal + Visual | Move the current line (or selection) UP one line | Same |
| `<` in visual | Visual | Indent left AND stay in visual mode so you can keep indenting | Without `gv`, Vim exits visual mode after indent — frustrating |
| `>` in visual | Visual | Indent right AND stay in visual mode | Same |
| `<C-s>` | Normal + Insert | Save the file | Universal muscle memory from every other editor |
| `<leader>qq` | Normal | Quit all windows (`:qa`) | Fast exit |
| `<S-h>` | Normal | Go to previous buffer (Shift+H) | Cycle through open files |
| `<S-l>` | Normal | Go to next buffer (Shift+L) | Same |
| `<leader>bd` | Normal | Close (delete) the current buffer without closing the window | Different from `:q` — keeps your layout intact |
| `<leader>p` | Visual | Paste over selection WITHOUT overwriting your clipboard | Normally if you paste over selected text, the selected text goes into your register and overwrites what you wanted to paste. This prevents that |
| `<leader>y` | Normal + Visual | Yank (copy) to the SYSTEM clipboard explicitly | Neovim's default register is internal — this copies to the clipboard you can paste in other apps |
| `<leader>Y` | Normal | Yank the whole line to system clipboard | Same |
| `<leader>d` | Normal + Visual | Delete WITHOUT putting the deleted text in the register | Normally delete overwrites your clipboard. `"_d` throws it away instead |

### Session keymaps (from old auto-session config) — P2

These only work once you install `auto-session`:

| Keys | What it does |
|------|-------------|
| `<leader>wr` | Open a fuzzy search popup to find and restore a saved session |
| `<leader>ws` | Manually save the current session |
| `<leader>wa` | Toggle whether sessions auto-save on exit |

### which-key group labels — P2

**What is this?** which-key shows a popup when you pause after pressing `<leader>`. By default it shows raw keymap names. Adding "group" labels makes it show friendly headings like "Git" or "Search" instead of just a flat list.

```lua
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

These are high-value, low-friction plugins that most serious Neovim users have:

| Plugin | What it does in plain English | Status |
|--------|------------------------------|--------|
| `blink.cmp` | The autocomplete dropdown as you type | ✅ INSTALLED |
| `conform.nvim` | Auto-formats your code on save using prettier/black/stylua/etc | ✅ INSTALLED |
| `nvim-lint` | Runs eslint/ruff/etc as you type and shows errors as LSP diagnostics | ❌ NOT INSTALLED |
| `gitsigns.nvim` | Git change markers in the gutter + stage hunks | ✅ INSTALLED |
| `lazydev.nvim` | Gives your Lua LSP full knowledge of Neovim's API while editing this config | ❌ NOT INSTALLED |
| `lualine.nvim` | A much richer status bar at the bottom (currently you have mini.statusline) | ❌ NOT INSTALLED |
| `mason.nvim` + `mason-lspconfig.nvim` | Install and manage LSP servers via a UI | ✅ INSTALLED |
| `mini.icons` | Modern icon set for file types (you have nvim-web-devicons instead, which is older) | ⚙️ INSTALLED (not configured) |
| `render-markdown.nvim` | Renders Markdown formatting inside the editor, no browser needed | ❌ NOT INSTALLED |
| `todo-comments.nvim` | Highlights TODO/FIXME/NOTE/HACK comments in vivid colors across all files | ✅ INSTALLED |
| `which-key.nvim` | Shows available keymaps on demand | ✅ INSTALLED |
| `flash.nvim` | Lets you jump anywhere on screen in 2–3 keystrokes | ❌ NOT INSTALLED |

### Probably YES (P2)

Worth adding once your baseline is solid:

| Plugin | What it does in plain English | Status |
|--------|------------------------------|--------|
| `auto-session` | Saves and restores your editing session per-directory | ❌ NOT INSTALLED |
| `copilot.lua` | GitHub Copilot ghost-text suggestions as you type | ❌ NOT INSTALLED |
| `fzf-lua` | Faster alternative to Telescope for file/grep searching in large projects | ❌ NOT INSTALLED |
| `grug-far.nvim` | A polished find-and-replace UI across your whole project | ❌ NOT INSTALLED |
| `mini.ai` | Smarter text objects like "select around this function" | ✅ INSTALLED |
| `mini.pairs` | Auto-closes brackets and quotes | ⚙️ INSTALLED (not configured) |
| `neo-tree.nvim` OR `oil.nvim` | A file explorer (sidebar tree OR edit-files-as-a-buffer — pick one) | ❌ NOT INSTALLED |
| `noice.nvim` | Completely replaces the command line and notification UI with a polished floating design | ❌ NOT INSTALLED |
| `SchemaStore.nvim` | Validates JSON/YAML field names (e.g. warns when you typo a key in `package.json`) | ❌ NOT INSTALLED |
| `snacks.nvim` | A bundle of 30+ small utilities — notifications, lazygit float, dashboard, etc. | ❌ NOT INSTALLED |
| `trouble.nvim` | A proper project-wide diagnostics panel | ❌ NOT INSTALLED |
| `ts-comments.nvim` | Correct comment syntax per language (JSX needs `{/* */}` not `//`) | ❌ NOT INSTALLED |

### Maybe (P3 / situational)

| Plugin | What it does | Status |
|--------|-------------|--------|
| `bufferline.nvim` | Tab-like bar at the top showing open files — some love it, some find it noisy | ❌ NOT INSTALLED |
| `markdown-preview.nvim` | Live-renders your Markdown in a browser as you type | ❌ NOT INSTALLED |
| `nvim-ts-autotag` | Auto-closes `<div>` → `<div></div>` when writing HTML/JSX | ❌ NOT INSTALLED |
| `nvim-treesitter-textobjects` | Adds "select the next function" / "swap arguments" type motions | ❌ NOT INSTALLED |
| `persistence.nvim` | Lighter session manager — simpler than auto-session but fewer features | ❌ NOT INSTALLED |

### Skip

| Plugin | Why |
|--------|-----|
| `vim-monokai-tasty` | Your old theme — the newer alternatives (catppuccin, kanagawa) look better and are better maintained |
| `LazyVim/LazyVim` | The LazyVim framework — you've moved to Kickstart intentionally |

---

## 5. ThePrimeagen's Setup — Key Lessons

**Who is ThePrimeagen?** He's a former Netflix infrastructure engineer and now a popular programming streamer. His Neovim config (`github.com/ThePrimeagen/init.lua`, 4k+ stars) is one of the most referenced setups in the community. He's known for a minimal, deliberate approach — if a plugin doesn't clearly improve his workflow, it gets removed.

### His stack

| Category | His choice | Status in your config |
|----------|-----------|----------------------|
| Fuzzy finder | telescope.nvim | ✅ INSTALLED (same) |
| File navigation | harpoon2 — NO file tree | ❌ NOT INSTALLED |
| Git | vim-fugitive (full git via cmdline) | ❌ NOT INSTALLED |
| LSP | nvim-lspconfig + mason | ✅ INSTALLED (same) |
| Completion | nvim-cmp (he hasn't switched to blink.cmp yet) | N/A — you have blink.cmp which is better |
| Undo history | undotree — visual tree of all undo branches | ❌ NOT INSTALLED |
| Theme | rose-pine (muted earthy pink tones) | ❌ NOT INSTALLED |
| Formatter | conform.nvim | ✅ INSTALLED (same) |

### Philosophy worth adopting

1. **Centered scrolling** — `<C-d>zz` and `<C-u>zz`. When you scroll half a page, Neovim normally leaves your cursor near the edge of the screen. Adding `zz` re-centers it. Sounds small, but this is one of the single most popular Neovim tips he's shared. Very disorienting without it once you've used it.

2. **Centered search jumps** — `nzzzv` and `Nzzzv`. Same idea: when you hit `n` to jump to the next search match, `zz` keeps you centered. The extra `v` preserves visual mode if you were in it.

3. **No file tree philosophy** — He navigates entirely through Telescope (fuzzy finding files by name) plus Harpoon (which marks 4–5 specific files you're actively working on and lets you jump between them instantly). The argument is that a sidebar tree is usually slower than typing part of a filename.

4. **Harpoon** — Not a file tree. Instead, you "mark" the files you're actively working on right now (e.g. the 4 files you're jumping between in this feature), then jump between them with a single keypress. It's like browser bookmarks for your active work. `P2` — worth trying once you're comfortable.

5. **Undotree** — Neovim (like Vim) has a branching undo history, not a linear one. If you undo 5 changes then make a new change, the "undone" changes aren't lost — they're on a branch. Undotree shows you this visually so you can navigate to any previous state. `P2`.

6. **Keep it small** — He publicly removes plugins that don't serve his workflow. Good philosophy: add something, actually use it for a week, remove it if it doesn't stick.

### ThePrimeagen-specific keymaps worth taking (all NOT YET SET ❌)

```lua
-- Scroll and keep cursor centered (his most popular tip)
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- Search jumps keep cursor centered
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Paste over selected text without losing what's in your register
-- Normally: select text, paste → selected text overwrites your register
-- With this: selected text is discarded, your register is preserved
vim.keymap.set("x", "<leader>p", '"_dP')

-- Copy to system clipboard (not just Neovim's internal register)
vim.keymap.set({"n","v"}, "<leader>y", '"+y')
vim.keymap.set("n", "<leader>Y", '"+Y')

-- Delete without saving to register (so it doesn't clobber your clipboard)
vim.keymap.set({"n","v"}, "<leader>d", '"_d')

-- Navigate the quickfix list (used for search results, LSP references, etc.)
vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")   -- next item
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")   -- previous item
```

---

## 6. LazyVim Ecosystem — What's Changed (2024–2026)

**Why does this matter?** LazyVim is the most popular Neovim distribution and its maintainer (folke) also makes lazy.nvim and many other widely-used plugins. When LazyVim switches its default plugin for a category, it's a strong signal that the community has a new winner. This section tracks those switches so you know which plugins are current.

### LazyVim v14 (Dec 2024) — Major defaults switch

| Was the default | Now the default | Why the switch |
|-----------------|-----------------|----------------|
| `telescope.nvim` | `fzf-lua` | fzf-lua uses the external `fzf` binary which is written in Go and is significantly faster when searching large codebases |
| `nvim-cmp` | `blink.cmp` | blink.cmp has a Rust-written fuzzy matching core — much faster, and bundles all sources (LSP, buffer, path, snippets) so you don't need 5+ separate `cmp-*` packages |
| `dressing.nvim` | `snacks.input` | Replaced by a module inside snacks.nvim |
| `nvim-notify` | `snacks.notifier` | Replaced by a module inside snacks.nvim |
| `indent-blankline.nvim` | `snacks.indent` | Replaced by a module inside snacks.nvim |
| `alpha.nvim` (startup dashboard) | `snacks.dashboard` | Replaced by a module inside snacks.nvim |
| `nvim-spectre` (find & replace) | `grug-far.nvim` | Better UX — results are editable inline, no regex gotchas |
| `headlines.nvim` (markdown) | `render-markdown.nvim` | Much richer rendering, actively maintained |

### LazyVim v15 (2025) — Neovim native API adoption

- Neovim 0.11+ has a new native API `vim.lsp.config()` — you can now configure LSP servers without needing nvim-lspconfig for simple cases
- Mason updated to v2 (cleaner API)
- nvim-treesitter moved to `main` branch (you already have this ✅)
- Native code folding via LSP built into Neovim core

### LazyVim "Extras" — language packs worth knowing about

These are modular bundles that install LSP + formatter + linter for a specific language in one go. You can replicate these individually in Kickstart:

**Language extras** — each one wires up the full toolchain for that language:

| Extra | What it installs | How to get in Kickstart |
|-------|-----------------|------------------------|
| `lang.python` | pyright or basedpyright (LSP) + ruff (linter/formatter) | Install via `:Mason` |
| `lang.typescript` | vtsls (LSP — replaces old tsserver) | Install via `:Mason` |
| `lang.rust` | rust_analyzer (LSP) + rustfmt | Install via `:Mason` |
| `lang.go` | gopls (LSP) + gofumpt (formatter) | Install via `:Mason` |
| `lang.markdown` | marksman (LSP) + render-markdown.nvim + preview | Install plugins + LSP via `:Mason` |
| `lang.json` | jsonls (LSP with field autocomplete) + SchemaStore | Install jsonls via `:Mason` + SchemaStore plugin |
| `lang.toml` | taplo (LSP + formatter for .toml files) | Install taplo via `:Mason` |

**AI extras** — different approaches to AI assistance:

| Extra | What it gives you |
|-------|------------------|
| `ai.copilot` | Ghost-text inline completions from GitHub Copilot |
| `ai.copilot-chat` | A chat sidebar for having conversations with Copilot about your code |
| `ai.avante` | Cursor-style AI — select code, describe a change, it generates a diff to accept/reject |
| `ai.codeium` | Free alternative to Copilot, similar ghost-text suggestions |
| `ai.supermaven` | Very fast free inline completions |

---

## 7. Best Plugins by Category (2025 Ecosystem)

### Completion — how autocomplete works in Neovim

**What is "completion"?** When you type in Insert mode and a popup appears with suggestions — that's the completion engine. It pulls suggestions from your LSP server (language-aware completions), open buffers, file paths, and code snippets.

| Plugin | What it is | Status | Verdict |
|--------|-----------|--------|---------|
| **blink.cmp** ⭐ | The current gold standard. Written with a Rust fuzzy-matching core so it's noticeably faster. Bundles all sources in one package — no need for separate `cmp-nvim-lsp`, `cmp-buffer`, `cmp-path` packages. Also has built-in snippet support | ✅ INSTALLED | Already using the best one |
| nvim-cmp | The previous standard — still works and is maintained, but blink.cmp is faster and simpler | ❌ NOT INSTALLED | No need to add |

---

### LSP — what "Language Server Protocol" means

**What is LSP?** A language server is a separate program that understands a specific language deeply — it can tell you "this variable is undefined", "this function signature is wrong", "here are all the places this function is called". LSP is the standard protocol Neovim uses to talk to these servers.

The stack has three parts:
1. **mason.nvim** — downloads and installs the language server programs onto your machine
2. **nvim-lspconfig** — configures how Neovim connects to each server
3. **mason-lspconfig.nvim** — the bridge that connects them automatically

| Plugin | What it does | Status |
|--------|-------------|--------|
| **nvim-lspconfig** ⭐ | Pre-written connection configs for 100+ language servers | ✅ INSTALLED |
| **mason.nvim** | GUI package manager for LSP servers — run `:Mason` to browse/install | ✅ INSTALLED |
| **mason-lspconfig.nvim** | Auto-connects Mason-installed servers to Neovim | ✅ INSTALLED |
| **lazydev.nvim** ⭐ | Gives lua_ls full Neovim API knowledge while editing this config | ❌ NOT INSTALLED — P1 |
| Native `vim.lsp.config` | Built into Neovim 0.11+ — may eventually reduce reliance on nvim-lspconfig | Built-in |

**Key language servers to install via `:Mason`** (none are installed yet by default):

| Server | Language | Notes |
|--------|---------|-------|
| `lua_ls` | Lua | Essential for editing this config with proper autocomplete |
| `pyright` or `basedpyright` | Python | basedpyright is a more actively maintained fork |
| `vtsls` | TypeScript / JavaScript | Modern replacement for the old tsserver |
| `rust_analyzer` | Rust | Official LSP for Rust |
| `gopls` | Go | Official LSP for Go |

---

### Fuzzy Finder / Picker

**What is a "fuzzy finder"?** It's the floating search popup — you type part of a filename or text string and it instantly narrows down matches across all your files. This is how most Neovim users navigate — type a few letters of a filename rather than browsing a file tree.

| Plugin | What it is | Status | Notes |
|--------|-----------|--------|-------|
| **telescope.nvim** | The most popular fuzzy finder — highly customizable, huge ecosystem of extensions | ✅ INSTALLED | This is what you currently have |
| **fzf-lua** ⭐ | Uses the external `fzf` binary — significantly faster than Telescope for large repos. LazyVim's default since v14 | ❌ NOT INSTALLED | Worth switching eventually — P2 |
| **snacks.picker** | The newest entrant from folke — built into snacks.nvim, has a true Normal mode (unlike fzf-lua), 40+ built-in search sources | ❌ NOT INSTALLED | Part of snacks.nvim — P2 |

**Telescope currently gives you these commands** (all ✅ working now):
- `<leader>sf` — find files by name
- `<leader>sg` — search text across all files (grep)
- `<leader>sh` — search Neovim help docs
- `<leader>sd` — show LSP diagnostics
- `<leader><leader>` — show open buffers

---

### File Explorer

**What is a file explorer?** A way to browse your project's directory structure without leaving Neovim. The two main philosophies are: (1) a sidebar panel like VS Code, or (2) edit the filesystem as if it were a text buffer.

| Plugin | Philosophy | Status | Notes |
|--------|-----------|--------|-------|
| **oil.nvim** ⭐ | Opens the current directory as a regular buffer — you can rename/delete/move files by editing the text, then saving. Very "Vim" in its approach | ❌ NOT INSTALLED — P2 | Press `-` to open parent dir |
| **neo-tree.nvim** | Traditional sidebar panel — shows your directory tree, integrates with git to show changed files | ❌ NOT INSTALLED — P2 | Full-featured, familiar |
| **nvim-tree.lua** | Another traditional sidebar, used by NvChad distribution | ❌ NOT INSTALLED | Pick neo-tree if you want a sidebar |
| **snacks.explorer** | Built into snacks.nvim — actually a picker interface to browse files | ❌ NOT INSTALLED | Part of snacks.nvim |
| No tree (Primeagen approach) | Use Telescope for file finding + Harpoon for quick switching | N/A | Viable once you know Telescope well |

---

### Statusline

**What is the statusline?** The bar at the bottom of the screen showing current mode, filename, git branch, LSP status, line/column number, etc.

| Plugin | What it is | Status | Notes |
|--------|-----------|--------|-------|
| **mini.statusline** | A minimal statusline from mini.nvim — simple, fast, good enough for getting started | ✅ INSTALLED (configured) | This is your current statusline |
| **lualine.nvim** ⭐ | The most popular full-featured statusline — easy to configure, lots of themes, shows more information | ❌ NOT INSTALLED — P1 | Most configs use this; worth upgrading to |
| **heirline.nvim** | The most powerful/customizable statusline — you build it from scratch. Steeper learning curve | ❌ NOT INSTALLED | Enthusiast choice |

---

### Git

**What do git plugins do?** Neovim has no built-in git UI — these plugins add various levels of git integration, from simple gutter indicators to full interactive commit UIs.

| Plugin | What it does | Status | Notes |
|--------|-------------|--------|-------|
| **gitsigns.nvim** ⭐ | Shows `+`/`~`/`-` in the left gutter for added/changed/deleted lines. Also lets you stage individual sections (hunks), preview diffs, and see git blame | ✅ INSTALLED | Already have this — configure keymaps |
| **neogit** | A Magit-style interactive git UI — stage specific lines, write commit messages, view diffs, all inside Neovim | ❌ NOT INSTALLED — P2 | Pairs well with diffview |
| **diffview.nvim** | Beautiful side-by-side diff viewer — see exactly what changed in each file, navigate through changed files | ❌ NOT INSTALLED — P2 | Very useful for code review |
| **vim-fugitive** | ThePrimeagen's choice — run git commands (`:Git commit`, `:Git push`) from inside Neovim with full interactivity | ❌ NOT INSTALLED — P2 | More "command-line git inside Neovim" |
| **lazygit.nvim / snacks.lazygit** | Opens the lazygit TUI in a floating window inside Neovim — full lazygit experience without leaving your editor | ❌ NOT INSTALLED — P2 | You already have lazygit installed! Just needs wiring up |

**Note**: You already have lazygit installed via Homebrew. `snacks.lazygit` or `lazygit.nvim` would bind it to a keymap like `<leader>gg` so it opens as a floating window.

---

### Motion / Navigation

**What are "motions"?** In Vim, motions are how you move around — `w` jumps forward a word, `$` goes to end of line, `/pattern` searches. These plugins supercharge that.

| Plugin | What it does | Status | Notes |
|--------|-------------|--------|-------|
| **flash.nvim** ⭐ | Enhanced jump-anywhere: type any characters in your search and labels appear on every match. One more keypress jumps you there. Also integrates with Treesitter to select whole syntax nodes | ❌ NOT INSTALLED — P1 | LazyVim's default motion plugin |
| **leap.nvim** | Type exactly 2 characters and jump to any occurrence of that pair on screen. Very low mental overhead once learned | ❌ NOT INSTALLED — P2 | Different feel than flash |
| **harpoon2** ⭐ | Mark up to 4–5 "active" files you're working on right now. Jump to each with a single keypress. Not MRU — you manually decide what's marked. Like Cmd+1/2/3/4 for your current task | ❌ NOT INSTALLED — P2 | ThePrimeagen's own plugin |
| **undotree** | Visual display of your undo history as a branching tree. Neovim's undo is non-linear (it never loses undone changes) — this makes it navigable | ❌ NOT INSTALLED — P2 | Low cost, surprisingly useful |

---

### AI Coding

| Plugin | What it does | Status | Notes |
|--------|-------------|--------|-------|
| **copilot.lua** ⭐ | GitHub Copilot as "ghost text" — grey suggestions appear as you type, press Tab to accept. Learns from your codebase context | ❌ NOT INSTALLED — P2 | You had this before |
| **avante.nvim** | Cursor-style AI: select code, type a description of the change, it generates a diff you can accept or reject. Has a sidebar chat. 17k+ stars. Supports Claude, GPT-4, Gemini | ❌ NOT INSTALLED — P2 | Most exciting new AI plugin |
| **codecompanion.nvim** | More Vim-native AI — slash commands in a chat buffer, less intrusive, integrates with the buffer as a tool rather than taking over | ❌ NOT INSTALLED — P2 | Better if you want AI that doesn't interrupt flow |
| **CopilotChat.nvim** | Chat interface layered on top of Copilot — have conversations about your code, generate tests, explain code | ❌ NOT INSTALLED — P2 | Requires Copilot subscription |
| **supermaven.nvim** | Very fast free inline completions — similar ghost-text experience to Copilot but free | ❌ NOT INSTALLED — P2 | Good free alternative |

---

### Theming

**What is a "color theme"?** It controls all the syntax colors, background, UI element colors in your editor. You currently have `tokyonight` active.

| Theme | What it looks like | Status | Notes |
|-------|------------------|--------|-------|
| **tokyonight** | Cool blues and purples — the default LazyVim theme | ✅ INSTALLED (active) | Currently active |
| **catppuccin** ⭐ | Warm, soft pastels — Latte (light), Frappe, Macchiato, Mocha variants. Fastest-growing theme in the community | ❌ NOT INSTALLED — P1 | Most popular trend right now |
| **kanagawa** | Muted, ink-like Japanese aesthetic — calm greens and deep blues | ❌ NOT INSTALLED — P1 | Beautiful for long sessions |
| **rose-pine** | Earthy muted pink/cream tones — ThePrimeagen's theme | ❌ NOT INSTALLED — P2 | Very easy on the eyes |
| **everforest** | Green forest tones — one of the easiest themes on your eyes for long sessions | ❌ NOT INSTALLED — P2 | Great for daytime use |
| **cyberdream** | High-contrast neon — bold, distinctive, fast-growing | ❌ NOT INSTALLED — P3 | Striking but polarizing |
| **gruvbox-material** | Warm brown/orange retro — the classic "programmer theme" | ❌ NOT INSTALLED — P3 | Nostalgic |

---

### Utilities / Quality of Life

| Plugin | What it does in plain English | Status | Priority |
|--------|------------------------------|--------|---------|
| **snacks.nvim** ⭐ | 30+ small utilities in one plugin — each module can be enabled/disabled independently. Replaces many separate plugins (see full breakdown below) | ❌ NOT INSTALLED | **P1** |
| **todo-comments.nvim** | Highlights `TODO:`, `FIXME:`, `HACK:`, `NOTE:`, `BUG:` comments in bright colors. `<leader>st` to telescope-search all of them across your project | ✅ INSTALLED | Already here |
| **grug-far.nvim** | Find-and-replace across your whole project — with real-time preview, regex support, and inline editing of the results | ❌ NOT INSTALLED | P2 |
| **render-markdown.nvim** | Renders Markdown formatting inside Neovim as you edit — headings become big and bold, code blocks get syntax-highlighted backgrounds, `- [ ]` becomes an actual checkbox | ❌ NOT INSTALLED | P1 |
| **noice.nvim** | Completely redesigns Neovim's command-line area and notifications — everything becomes floating, styled windows instead of text at the bottom | ❌ NOT INSTALLED | P3 (heavy) |
| **trouble.nvim** | A dedicated panel for LSP errors/warnings/hints that shows your entire project's issues in a clean organized list | ❌ NOT INSTALLED | P2 |
| **nvim-treesitter-textobjects** | Treesitter-powered text objects: `]f` jump to next function, `[c` jump to previous class, `vaf` select around function body | ❌ NOT INSTALLED | P2 |
| **mini.surround** | Add/change/delete surrounding characters — `ysiw"` wraps word in quotes, `ds"` deletes surrounding quotes, `cs"'` changes `"` to `'` | ✅ INSTALLED (configured) | Already here |
| **mini.ai** | Smarter text objects — `vaf` = select around function, `vac` = select around class, `via` = select inside argument | ✅ INSTALLED (configured) | Already here |
| **fidget.nvim** | Shows a small spinner in the corner while an LSP server is loading/processing — so you know it's working and not stuck | ✅ INSTALLED | Already here |
| **inc-rename.nvim** | When you rename a symbol via LSP (`grn`), this shows a live preview of all the places it will change as you type the new name | ❌ NOT INSTALLED | P2 |
| **auto-session** | Automatically saves your open files, splits, cursor positions when you close Neovim. Next time you open in the same directory, everything is restored | ❌ NOT INSTALLED | P2 |

### snacks.nvim — full breakdown of what it replaces

`folke/snacks.nvim` — instead of installing 10 small plugins, you install one and enable the modules you want:

| snacks module | What it does | What it replaces |
|---------------|-------------|-----------------|
| `snacks.picker` | Full fuzzy finder with 40+ sources and true Normal mode | telescope.nvim / fzf-lua |
| `snacks.dashboard` | A startup screen when you open Neovim with no file — recent files, shortcuts | alpha.nvim |
| `snacks.notifier` | Styled floating notification popups instead of cmdline messages | nvim-notify |
| `snacks.input` | Styled floating input prompt for things like rename | dressing.nvim |
| `snacks.indent` | Draws indent guide lines down the left of code blocks | indent-blankline.nvim |
| `snacks.scroll` | Smooth animated scrolling instead of instant jumps | neoscroll.nvim |
| `snacks.zen` | Distraction-free writing mode — hides everything but the current buffer | zen-mode.nvim |
| `snacks.dim` | Dims all code except the function you're currently editing | twilight.nvim |
| `snacks.lazygit` | Opens lazygit in a floating window | lazygit.nvim |
| `snacks.terminal` | A toggleable floating terminal | toggleterm.nvim |
| `snacks.words` | Highlights all occurrences of the word under your cursor | vim-illuminate |
| `snacks.bigfile` | Disables heavy features (LSP, treesitter) for very large files to keep them fast | bigfile.nvim |
| `snacks.git` / `snacks.gitbrowse` | Open the current file/line on GitHub in your browser | vim-rhubarb |
| `snacks.image` | Display images inline in the editor (requires Kitty terminal) | image.nvim |
| `snacks.statuscolumn` | Custom left column — line numbers, sign column, fold markers | statuscol.nvim |

---

## 8. Deprecated Plugins — Avoid

**What does "deprecated" mean here?** These plugins are either officially abandoned, have been replaced by something better, or have become outdated enough that the community has moved on. If you ever encounter them in a guide or config you find online, don't use them — use the modern replacement instead.

| Plugin | Status | What to use instead | Why it was replaced |
|--------|--------|--------------------|--------------------|
| `packer.nvim` | **Dead — archived Aug 2023** | lazy.nvim | lazy.nvim is dramatically better in every way |
| `neodev.nvim` | **Officially End of Life** | lazydev.nvim | lazydev is faster and more accurate; neodev's own author replaced it |
| `null-ls.nvim` | **Archived** | conform.nvim + nvim-lint | null-ls was a "bridge" for running formatters/linters via LSP; conform and nvim-lint do the same thing more cleanly |
| `none-ls.nvim` | Community fork of null-ls; losing traction | conform.nvim + nvim-lint | Same reason |
| `nvim-lsp-installer` | Superseded | mason.nvim | Same author wrote mason.nvim as the proper replacement |
| `lightspeed.nvim` | Author moved on | leap.nvim (or flash.nvim) | The same author wrote leap.nvim as the successor |
| `hop.nvim` | Less popular now | flash.nvim | flash.nvim has a better design and more features |
| `alpha.nvim` | Replaced as LazyVim default | snacks.dashboard | snacks bundles the same functionality |
| `dressing.nvim` | Replaced as LazyVim default | snacks.input | snacks bundles the same functionality |
| `nvim-spectre` | Replaced as LazyVim default | grug-far.nvim | grug-far has a better UX; spectre had regex quirks |
| `headlines.nvim` | Replaced as LazyVim default | render-markdown.nvim | render-markdown is much more fully-featured |
| `tsserver` (LSP) | Deprecated by the TypeScript team | `vtsls` | TypeScript team officially deprecated tsserver in favour of vtsls |
| `nvim-cmp` (as a new addition) | Being superseded | blink.cmp | You already have blink.cmp — no need for cmp |
| `nvim-treesitter` on `master` branch | Outdated | use `main` branch | You're already on main ✅ |
| `telescope-fzf-native.nvim` | Still installed but becoming redundant | fzf-lua (standalone) | fzf-lua is faster and more full-featured; telescope-fzf-native just speeds up telescope |

---

## 9. Repo Structure Options

**What is "repo structure"?** How you organize the files in your `~/.config/nvim/` folder. Right now everything lives in one `init.lua` file. As you add more plugins and settings, you may want to split it up.

### Your current structure

```
~/.config/nvim/
├── init.lua              ← everything lives here (~1000+ lines and growing)
├── lazy-lock.json        ← auto-generated: locks all plugin versions
├── docs/
│   └── nvim-audit-2025.md
└── lua/
    ├── kickstart/
    │   └── plugins/      ← optional kickstart plugins (already split out here)
    └── custom/
        └── plugins/      ← where you put your own extra plugins
```

### Option A: Stay single-file (recommended for now) ✅ Current approach

Keep everything in `init.lua`. This is exactly what Kickstart is designed for — the whole point is that you can read top-to-bottom and understand everything.

**When to split**: Once `init.lua` grows past ~1200 lines and scrolling through it becomes genuinely annoying.

### Option B: Kickstart modular split (natural next step)

The official "grown-up" version of Kickstart: `dam9000/kickstart-modular.nvim`. Instead of one giant file, each logical section gets its own file:

```
~/.config/nvim/
├── init.lua                    ← just 1 line: require("config")
├── lazy-lock.json
└── lua/
    └── config/
        ├── init.lua            ← lazy.nvim setup
        ├── options.lua         ← all your vim.o settings
        ├── keymaps.lua         ← all your keymaps
        ├── autocmds.lua        ← autocommands
        └── plugins/
            ├── lsp.lua         ← LSP config
            ├── completion.lua  ← blink.cmp
            ├── treesitter.lua  ← treesitter
            ├── telescope.lua   ← finder
            ├── git.lua         ← git plugins
            ├── ui.lua          ← themes, statusline
            └── theme.lua
```

lazy.nvim can auto-import every file in a directory, so adding a plugin is as simple as creating a new file:
```lua
require("lazy").setup({ import = "config.plugins" })
```

### Option C: ThePrimeagen style

He puts all his config inside a `lua/theprimeagen/` namespace and uses `after/plugin/` files that run after each plugin loads:

```
~/.config/nvim/
├── init.lua                    ← just: require("theprimeagen")
└── lua/theprimeagen/
    ├── lazy_init.lua           ← lazy.nvim setup
    ├── remap.lua               ← all keymaps
    ├── set.lua                 ← vim options
    └── after/plugin/
        ├── telescope.lua       ← runs after telescope loads
        ├── lsp.lua             ← runs after lspconfig loads
        └── ...
```

**Recommendation**: Stay single-file until you've added 5–10 more plugins. Then do Option B. It's well-documented and the upgrade path from Kickstart is smooth.

---

## 10. Recommended "Next Steps" Queue

This is a suggested order — each item is self-contained and won't break anything else. Pick one, tell Claude "install X from the audit", and it will handle it.

### Batch 1 — Zero-dependency QoL (pure settings, no plugins needed)

These are just lines to add to `init.lua`. No plugin installs, no risk of breaking anything.

- [ ] **Primeagen scroll keymaps** — `<C-d>zz`, `<C-u>zz`, `nzzzv`, `Nzzzv` — keeps cursor centered during scroll/search jumps. Very impactful. ❌ NOT YET SET
- [ ] **`<C-s>` to save** — saves from Normal AND Insert mode. Universal muscle memory ❌ NOT YET SET
- [ ] **`<S-h>` / `<S-l>` for buffer navigation** — cycle through open files like browser tabs ❌ NOT YET SET
- [ ] **`<leader>p` paste-without-clobbering** — the "paste over selection without destroying clipboard" trick ❌ NOT YET SET
- [ ] **`<leader>y` / `<leader>d`** — explicit system clipboard yank + register-free delete ❌ NOT YET SET
- [ ] **`wrap = false`** — turn off line wrapping ❌ NOT YET SET
- [ ] **Enable `mini.pairs`** — auto-close brackets. Already installed (part of mini.nvim), just not turned on ⚙️ INSTALLED BUT NOT CONFIGURED

### Batch 2 — Theming

- [ ] **catppuccin** — install a new theme. Zero risk, huge visual upgrade ❌ NOT INSTALLED
- [ ] **lualine.nvim** — upgrade from mini.statusline to a richer status bar ❌ NOT INSTALLED

### Batch 3 — LSP / Completion Polish

- [ ] **lazydev.nvim** — once installed, editing this `init.lua` gets full Neovim API autocomplete. Very useful while building your config ❌ NOT INSTALLED
- [ ] **fidget.nvim** — already installed — may just need keymap/config review ✅ INSTALLED
- [ ] **Language servers via `:Mason`** — install `lua_ls` at minimum, plus whatever languages you use

### Batch 4 — Git

- [ ] **Wire up lazygit** — you already have lazygit installed on your machine. Just needs `snacks.lazygit` or `lazygit.nvim` to bind `<leader>gg` to open it as a floating window ❌ NOT INSTALLED
- [ ] **diffview.nvim** — beautiful side-by-side git diffs ❌ NOT INSTALLED

### Batch 5 — File Navigation

- [ ] **oil.nvim** — open the current directory as an editable buffer with `-`. The most Vim-native file explorer ❌ NOT INSTALLED
- [ ] **flash.nvim** — jump anywhere on screen in 2–3 keystrokes ❌ NOT INSTALLED

### Batch 6 — Code Quality

- [ ] **nvim-lint** — run eslint/ruff/etc as diagnostics as you type ❌ NOT INSTALLED
- [ ] **Configure conform.nvim** — it's installed but you may not have formatters configured per-language ✅ INSTALLED (check config)
- [ ] **trouble.nvim** — dedicated project-wide diagnostics panel ❌ NOT INSTALLED
- [ ] **grug-far.nvim** — project-wide find & replace with a proper UI ❌ NOT INSTALLED

### Batch 7 — Rich Extras

- [ ] **render-markdown.nvim** — if you write any Markdown ❌ NOT INSTALLED
- [ ] **snacks.nvim** — start with 2–3 modules (notifier, lazygit, dashboard) and add more over time ❌ NOT INSTALLED
- [ ] **auto-session** — session save/restore on open — you had this before ❌ NOT INSTALLED
- [ ] **mini.ai is already on** — explore `vaf`, `vac`, `via` text objects ✅ INSTALLED
- [ ] **mini.surround is already on** — learn `ysiw"`, `ds"`, `cs"'` ✅ INSTALLED

### Batch 8 — AI

- [ ] **copilot.lua** — inline completions while typing — you had this before ❌ NOT INSTALLED
- [ ] **avante.nvim** — Cursor-style AI (select code, describe change, accept diff) ❌ NOT INSTALLED
- [ ] **codecompanion.nvim** — more Vim-native AI assistant alternative ❌ NOT INSTALLED

---

## Current Install Summary

Quick reference of everything in your config right now:

### ✅ Already installed and working

| Plugin | What it's doing for you right now |
|--------|----------------------------------|
| `lazy.nvim` | The plugin manager itself — downloads, updates, loads all plugins |
| `blink.cmp` | Autocomplete dropdown as you type |
| `LuaSnip` | Snippet engine (powers the snippet completions in blink.cmp) |
| `conform.nvim` | Code formatter — runs on save (may need per-language configuration) |
| `fidget.nvim` | LSP loading spinner in the corner |
| `gitsigns.nvim` | Git change markers in the left gutter |
| `guess-indent.nvim` | Automatically detects the indentation style of whatever file you open |
| `mason.nvim` | `:Mason` command to install LSP servers |
| `mason-lspconfig.nvim` | Bridges Mason and lspconfig |
| `mason-tool-installer.nvim` | Auto-installs specific Mason tools on startup |
| `mini.nvim` | The mini bundle — provides mini.ai, mini.surround, mini.statusline (all configured) |
| `nvim-lspconfig` | LSP connection configs for language servers |
| `nvim-treesitter` | Syntax parsing for highlighting, indentation, text objects |
| `nvim-web-devicons` | File type icons used by Telescope etc. |
| `plenary.nvim` | Lua utility library (required by Telescope) |
| `telescope.nvim` | Fuzzy file/grep picker — your main search tool |
| `telescope-fzf-native.nvim` | Makes Telescope faster using a C extension |
| `telescope-ui-select.nvim` | Routes Neovim's built-in `vim.ui.select` popups through Telescope |
| `todo-comments.nvim` | Highlights TODO/FIXME/NOTE/HACK/BUG comments |
| `tokyonight.nvim` | Your current active color theme |
| `which-key.nvim` | Shows available keymaps on demand |

### ❌ Not installed — notable gaps

| Plugin | Priority | What you're missing |
|--------|---------|---------------------|
| `lazydev.nvim` | **P1** | No Neovim API autocomplete while editing this config |
| `catppuccin` | **P1** | Limited to tokyonight theme |
| `lualine.nvim` | **P1** | Using mini.statusline (minimal) instead of full-featured statusbar |
| `nvim-lint` | **P1** | No linter diagnostics (eslint, ruff, etc.) |
| `flash.nvim` | **P1** | No jump-anywhere-in-3-keystrokes motion |
| `render-markdown.nvim` | **P1** | Plain text when editing Markdown |
| `lazygit.nvim` / `snacks.lazygit` | **P2** | lazygit is installed but can't open it from inside nvim |
| `copilot.lua` | **P2** | No AI inline completions (had this before) |
| `oil.nvim` | **P2** | No file explorer |
| `auto-session` | **P2** | No session restore on open (had this before) |
| `snacks.nvim` | **P2** | Missing: notifier, dashboard, lazygit integration, etc. |
| `trouble.nvim` | **P2** | Native diagnostic panel only |
| `grug-far.nvim` | **P2** | No project-wide find & replace UI |

---

*Last updated: April 2025*
*Sources: nvim.bak audit, ThePrimeagen/init.lua, LazyVim docs/changelog, dotfyle.com, rockerBOO/awesome-neovim*
