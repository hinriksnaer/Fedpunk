# PyTorch Development Neovim Configuration

A production-ready Neovim configuration built specifically for **PyTorch development** and **mixed-mode C++/Python debugging**. Optimized for working on PyTorch source code, C++ extensions, pybind11 bindings, and Python frontends with seamless debugging across both languages.

Built on Kickstart.nvim and enhanced with professional tooling for deep learning systems work.

## Quick start

```bash
# Backup any old config, then clone this repo as your Neovim config
mv ~/.config/nvim ~/.config/nvim.backup-$(date +%Y%m%d) 2>/dev/null || true
git clone https://github.com/hinriksnaer/nvim ~/.config/nvim

# Start Neovim; plugins will install automatically
nvim
```

> Tip: Run `:Mason` once to see installable tools and `:LspInfo` to confirm LSPs are attached.

## Key Features

### 🔥 Mixed-Mode Debugging (Python + C++)
* **debugpy** for Python debugging with full DAP UI integration
* **codelldb** for C++ debugging with LLDB backend
* **Seamless transitions** between Python and C++ stack frames
* **Attach to running Python processes** and step into C++ extensions
* Specialized configurations for PyTorch development workflows

### 🛠️ Language Support
* **C++ (clangd):** Semantic indexing, cross-file navigation, code actions, IntelliSense
* **Python (pyright):** Type checking, intelligent completion, import resolution
* **Treesitter:** Advanced syntax highlighting for C, C++, Python, CMake, CUDA, JSON, TOML, Markdown
* **Auto-formatting:** clang-format (C++), conform.nvim (Python)

### 🔍 Navigation & Search
* **Telescope:** Fuzzy file finding, live grep, LSP symbols, diagnostics
* **Flash.nvim:** Lightning-fast cursor navigation with jump labels
* **Harpoon:** Quick file bookmarking for frequent files
* **Oil.nvim:** File explorer with vim-like buffer editing

### 🪟 Window & Session Management
* **smart-splits.nvim:** Seamless navigation between Neovim and tmux panes
* **persistence.nvim:** Automatic session management
* **Smart window operations** under `<leader>w`

### 📝 Code Intelligence
* **blink.cmp:** Fast, modern completion engine
* **Which-key:** Discoverable keybindings with instant hints
* **Gitsigns:** Inline git hunks, blame, and staging
* **Spectre:** Project-wide search and replace

### 🎨 UI Enhancements
* **Noice.nvim:** Beautiful command-line and notification UI
* **Snacks.nvim:** Utility functions for buffers, notifications, and pickers
* **Todo-comments:** Highlight and search TODO/FIXME/NOTE comments
* **Indent-blankline:** Visual indent guides

> The base kickstart README in this repo was replaced to document these language-specific defaults. (Previously it contained the generic Kickstart install text.) ([GitHub][1])

## PyTorch & Mixed-Mode Debugging Workflows

### Debugging PyTorch C++ Extensions
This configuration excels at debugging PyTorch development scenarios:

1. **Python → C++ debugging:**
   ```
   - Set breakpoints in your Python code
   - Press <leader>ds to start debugging with debugpy
   - Step through Python until you hit pybind11/C API calls
   - Attach codelldb to the Python process (<F8> - custom config)
   - Step into C++ implementation seamlessly
   ```

2. **Debugging PyTorch operators:**
   - Debug Python tests that call custom operators
   - Step into ATen/C++ kernel implementations
   - Inspect tensors at both Python and C++ levels

3. **Standalone C++ debugging:**
   - Launch native binaries directly with codelldb
   - Debug libtorch applications
   - Test C++ kernels in isolation

### Building & Development Workflow
* **CMake/Meson integration:** Run builds in terminal splits
* **Hot reload:** Rebuild C++ extensions and reload Python modules without restarting Neovim
* **Quick iteration:** Edit C++, compile, test Python in one environment

### DAP UI Features
* **Automatic UI toggle:** Debug UI opens on start, closes on exit
* **Two-panel layout:** Variables/watches on left, stack/breakpoints at bottom
* **Evaluate expressions:** `<leader>de` in visual mode to inspect selected code
* **Hover values:** See variable values inline while debugging

## Essential Keybindings

### Finding & Navigation
* `<leader>ff` - Find files
* `<leader>fg` - Live grep (ripgrep)
* `<leader>fb` - Browse buffers
* `<leader>fs` - Grep word under cursor
* `<leader>ft` - Theme picker (colorscheme)
* `<C-h/j/k/l>` - Navigate windows (tmux-aware)
* `s` - Flash jump to any visible location

### LSP & Code
* `gd` - Go to definition
* `gr` - Find references
* `K` - Hover documentation
* `<leader>ca` - Code actions
* `<leader>cn` - Rename symbol
* `<leader>cf` - Format buffer
* `[d` / `]d` - Previous/next diagnostic

### Debugging (DAP)
* `<leader>ds` - Start/continue debugging
* `<leader>db` - Toggle breakpoint
* `<leader>dn` - Step over
* `<leader>di` - Step into
* `<leader>du` - Step out
* `<leader>dx` - Toggle DAP UI
* `<leader>de` - Evaluate expression

### Git
* `<leader>gs` - Stage hunk
* `<leader>gr` - Reset hunk
* `<leader>gb` - Blame line
* `<leader>gD` - Open diffview
* `<leader>gh` - File history
* `<leader>gtb` - Toggle blame line

### Windows & Buffers
* `<leader>wv` - Split vertically
* `<leader>ws` - Split horizontally
* `<leader>wc` - Close window
* `<leader>we` - Equalize windows
* `<leader>bd` - Delete buffer
* `<leader><leader>` - Switch to alternate buffer

### Messages & Sessions
* `<leader>ml` - Last message
* `<leader>mh` - Message history
* `<leader>ss` - Restore session
* `<leader>sl` - Restore last session

## Troubleshooting

* **No completion / LSP not attached:** `:LspInfo` → check server status; run `:Mason` to install missing tools.
* **Formatter not running:** ensure the tool is installed and project config exists (`.clang-format`, `pyproject.toml`).
* **Debugging fails to start:** verify `codelldb`/`debugpy` are installed and the DAP configuration points to the right program.

## License

MIT (see `LICENSE.md`).
