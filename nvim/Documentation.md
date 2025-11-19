# Your Neovim Configuration Features

## Leader Key
- Your "leader" key is set to the default backslash `\` character
- When you see `<leader>` in commands, it means press `\` first, then the following key(s)
- For example, `<leader>ff` means press `\` and then press `ff`
- This is different from `<C-w>` (Ctrl+W), which is the default prefix for window commands

## Theme and UI
- **Color Scheme**: Palenight theme for a pleasant dark appearance
- **Status Line**: Enhanced with vim-airline and lightline
- **Line Numbers**: Enabled by default
- **Mouse Support**: Full mouse integration

## Key Features

### General Navigation and Editing
- `<C-c>` - Mapped to escape for quicker mode switching
- `<F8>` - Toggle Tagbar (code outline)
- `<leader>ff` - Find files with FZF
- `<C-R>` - Run Python file in terminal split
- Auto strip trailing whitespace on save

### Code Navigation
- `gd` - Go to definition (works in Svelte, JavaScript, TypeScript)
- `gi` - Go to implementation
- `gr` - Find references
- `K` - Show documentation hover
- `<leader>rn` - Rename symbol
- `[g` and `]g` - Navigate between diagnostics:
  - `[g` - Move to the previous error/warning/hint in your file
  - `]g` - Move to the next error/warning/hint in your file

### Snippets
- Type snippet keyword and press `<Tab>` to expand
- Use `<Tab>` and `<Shift-Tab>` to navigate between placeholders

**Common Snippets**:
- JavaScript: `fn`, `afn`, `if`, `for`, `cl` (console.log), `imp`
- Svelte: `if`, `each`, `await`, `script`, `style`

**Custom Snippets**: Create in `~/.config/nvim/snippets/`

### Code Actions and Refactoring
- `<leader>a` - Code actions for selected text
- `<leader>ac` - Code actions for current buffer
  - "Code actions" are contextual suggestions offered by the language server, such as:
    - Importing missing modules
    - Converting code to use newer syntax
    - Extracting code to variables/functions
    - Fixing specific errors with suggested solutions
    - Implementing interfaces
    - And more depending on your language and context
- `<leader>qf` - Quick fix for current line
- `<leader>f` - Format selected code
- `:Format` - Format entire buffer
- `:OR` - Organize imports

### Window Management
- Standard Vim window commands work as expected:
  - `<C-w>v` - Vertical split
  - `<C-w>s` - Horizontal split
  - `<C-w>h/j/k/l` - Navigate between splits

### File Navigation
- **Nvim-Tree for file browsing**:
  - `<leader>n` - Toggle Nvim-Tree sidebar
  - `<C-n>`     - Find current file in the tree
  - `<leader>r` - Refresh the file tree
  - Inside Nvim-Tree:
    - `h`, `l`   - or left/right arrows - Collapse/expand directories
    - `j`, `k`   - or up/down arrows    - Navigate tree
    - `Enter`    - Open file or expand directory
    - `<C-v>`    - Open file in vertical split
    - `<C-x>`    - Open file in horizontal split
    - `<C-t>`    - Open file in new tab
    - `-`        - Navigate to parent directory
    - `g?`       - Show full list of available keymappings
    - `a`        - add files or folders
    - `r`        - rename
    - `Ctrl + r` - rename the file regardless of its original name
    - `d`        - delete
    - `x`        - cut
    - `c`        - copy
    - `p`        - paste
    - `y`        - to copy only the file name to the clipboard
    - `Y`        - to copy the relative path
    - `g + y`    - to copy the absolute path


- **Oil.nvim for file browsing**:
  - `<leader>o` or `\o` - Open Oil file explorer in current directory
  - `<C-w>o` - Alternative shortcut to open Oil
  - `-` to go up a directory
  - `Enter` to open a file or directory
  - `^` to go to parent directory
  - `g.` Toggle show hidden files

- **FZF integration for fuzzy finding**:
  - `<leader>ff` or `\ff` - Find files in the current project
  - `<leader>fg` or `\fg` - Search text across files (Ripgrep)
  - `<leader>fb` or `\fb` - List and switch between open buffers
  - `<leader>fh` or `\fh` - Find recently opened files
  - Type in partial names and use arrow keys to navigate results
  - Press `Enter` to open selected file

### Markdown Preview
- Browser-based preview (VSCode-like):
  - `<leader>mp` - Start markdown preview
  - `<leader>ms` - Stop markdown preview
  - `<leader>mt` - Toggle markdown preview
- Terminal-based preview with Glow:
  - `<leader>mg` - View in terminal

### Tab Configuration
- 2-space tabs by default (changed from 4)
- `:SetTab n` - Command to set tab width to n spaces
- `:Trim` - Manually trim whitespace

### CoC Extensions
- Configured to use pnpm for installation
- Auto-installs required extensions for Svelte, TypeScript, CSS, HTML, JSON
- `:CocRestart` - Restart CoC language servers
- `:CocList` commands for various functionalities:
  - `<space>a` - Show diagnostics
  - `<space>e` - Manage extensions
  - `<space>c` - Show commands
  - `<space>o` - Show document outline

## Quick Access
- `<leader>?` or `\?` - View this documentation using Glow
- `<C-w>?` - Alternative way to view documentation
- `:EditDocs` - Edit this documentation file
