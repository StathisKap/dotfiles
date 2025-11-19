-- Install and setup packer if not already installed
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

-- Plugin management with packer
require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- Theme and UI
  use 'drewtempelmeyer/palenight.vim'
  use 'wilmanbarrios/palenight.nvim'
  use 'itchyny/lightline.vim'

  -- Code functionality
  use {'neoclide/coc.nvim', branch = 'release'}
  use 'preservim/tagbar'
  use 'MaxMEllon/vim-jsx-pretty'              -- Enhanced JSX/React syntax highlighting
  use 'jonsmithers/vim-html-template-literals' -- Tailwind CSS autocomplete in template literals
  use {'nvim-treesitter/nvim-treesitter', run = ':TSUpdate'}
  use 'HiPhish/rainbow-delimiters.nvim'
  use 'tommcdo/vim-lion'
  use 'ntpeters/vim-better-whitespace'

  -- File navigation
  use {'junegunn/fzf', run = function() vim.fn['fzf#install']() end}
  use 'junegunn/fzf.vim'
  use 'stevearc/oil.nvim'
  use 'nvim-tree/nvim-tree.lua'
  use 'nvim-tree/nvim-web-devicons'

  -- Language specific
  use 'evanleck/vim-svelte'
  use 'pangloss/vim-javascript'
  use 'HerringtonDarkholme/yats.vim'
  use 'Einenlum/yaml-revealer'
  use 'HiPhish/jinja.vim'

  -- Markdown Preview options
  use {'iamcco/markdown-preview.nvim', run = 'cd app && yarn install', ft = 'markdown'}
  use {'ellisonleao/glow.nvim', branch = 'main'}

  -- Automatically set up your configuration after cloning packer.nvim
  if packer_bootstrap then
    require('packer').sync()
  end
end)

-- Theme setup
vim.cmd('colorscheme palenight')
vim.opt.termguicolors = true
vim.env.COLORTERM = "truecolor"

-- Basic settings
vim.opt.syntax = 'on'
vim.opt.number = true
vim.opt.ruler = true
vim.opt.visualbell = true
vim.opt.encoding = 'utf-8'
vim.opt.wrap = false
vim.opt.mouse = 'a'
vim.opt.updatetime = 300
vim.opt.cmdheight = 1
vim.opt.shortmess:append('c')
vim.opt.signcolumn = 'yes'
vim.opt.laststatus = 2
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.backup = false
vim.opt.writebackup = false

-- File type settings
vim.cmd('filetype plugin indent on')

-- Function to set tab width to n spaces
local function set_tab(n)
  vim.opt_local.tabstop = n
  vim.opt_local.softtabstop = n
  vim.opt_local.shiftwidth = n
  vim.opt.expandtab = true
end

-- Create commands for tab settings
vim.api.nvim_create_user_command('SetTab', function(opts)
  set_tab(tonumber(opts.args))
end, {nargs = 1})

vim.api.nvim_create_user_command('Trim', 'StripWhitespace', {})

-- Set default tab width to 2 spaces
set_tab(2)

-- Set tab width for specific file types
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'python',
  callback = function()
    set_tab(2)
  end
})

-- Key remappings
vim.keymap.set('n', '<c-z>', '<nop>')
vim.keymap.set({'n', 'i', 'v', 'o'}, '<c-c>', '<esc>')

-- File type associations
vim.api.nvim_create_augroup('file_types', {clear = true})
vim.api.nvim_create_autocmd({'BufNewFile', 'BufRead'}, {
  group = 'file_types',
  pattern = '*.svelte',
  command = 'set filetype=svelte'
})

-- Define common CoC mappings for svelte/js/ts files
for _, filetype in ipairs({'svelte', 'javascript', 'typescript', 'typescriptreact'}) do
  vim.api.nvim_create_autocmd('FileType', {
    group = 'file_types',
    pattern = filetype,
    callback = function()
      vim.api.nvim_buf_set_keymap(0, 'n', 'gd', '<Plug>(coc-definition)', {silent = true})
      vim.api.nvim_buf_set_keymap(0, 'n', 'gi', '<Plug>(coc-implementation)', {silent = true})
      vim.api.nvim_buf_set_keymap(0, 'n', 'gr', '<Plug>(coc-references)', {silent = true})
    end
  })
end

-- Plugin settings
-- Whitespace
vim.g.better_whitespace_enabled = 1
vim.g.strip_whitespace_on_save = 1
vim.g.strip_whitespace_confirm = 0
vim.g.strip_whitelines_at_eof = 1
vim.g.better_whitespace_filetypes_blacklist = {}
vim.g.show_spaces_that_precede_tabs = 1

-- Lion
vim.b.lion_squeeze_spaces = 1

-- TagBar
vim.keymap.set('n', '<F8>', ':TagbarToggle<CR>')

-- Markdown preview
vim.g.mkdp_auto_start = 0
vim.g.mkdp_auto_close = 1
vim.g.mkdp_refresh_slow = 0
vim.g.mkdp_command_for_global = 0
vim.g.mkdp_open_to_the_world = 0
vim.g.mkdp_browser = ''
vim.g.mkdp_echo_preview_url = 1
vim.g.mkdp_page_title = '「${name}」'

-- Glow markdown preview setup
require('glow').setup({
  style = "dark",
  width = 180,
  height_ratio = 0.9,
  border = "rounded",
  pager = false,
  use_terminal_colors = false
})

-- Markdown preview mappings
vim.keymap.set('n', '<leader>mp', ':MarkdownPreview<CR>')
vim.keymap.set('n', '<leader>ms', ':MarkdownPreviewStop<CR>')
vim.keymap.set('n', '<leader>mt', ':MarkdownPreviewToggle<CR>')
vim.keymap.set('n', '<leader>?', ':Glow ~/.config/nvim/Documentation.md<CR>')
vim.keymap.set('n', '<C-w>?', ':Glow ~/.config/nvim/Documentation.md<CR>')
vim.keymap.set('n', '<leader>mg', ':Glow<CR>')
vim.api.nvim_create_user_command('EditDocs', 'edit ~/.config/nvim/Documentation.md', {})

-- TreeSitter configuration
require('nvim-treesitter.configs').setup {
  -- Install specific parsers for commonly used languages
  ensure_installed = {
    "c", "python", "javascript", "typescript",
    "svelte", "sql", "yaml", "json", "html",
    "css", "bash", "lua", "vim", "markdown"
  },
  -- Automatically install missing parsers when entering buffer
  auto_install = true,
  -- Enable syntax highlighting provided by Treesitter
  highlight = {
    enable = true,
  },
}

-- Add custom AppleScript parser
local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
parser_config.applescript = {
  install_info = {
    url = "https://github.com/tree-sitter/tree-sitter-applescript",
    files = {"src/parser.c"},
    branch = "main",
    generate_requires_npm = false,
  },
  filetype = "applescript",
}

-- CoC extensions
vim.g.coc_global_extensions = {
  'coc-tsserver',
  'coc-css',
  'coc-html',
  'coc-json',
  'coc-svelte',
  'coc-tailwindcss',
  'coc-highlight',
  '@yaegassy/coc-tailwindcss3',
  'coc-prettier',
  'coc-snippets',
  'coc-clangd',
  'coc-pyright',
}

-- Use <c-space> to trigger completion
if vim.fn.has('nvim') == 1 then
  vim.api.nvim_set_keymap('i', '<c-space>', 'coc#refresh()', {silent = true, expr = true})
else
  vim.api.nvim_set_keymap('i', '<c-@>', 'coc#refresh()', {silent = true, expr = true})
end

-- Make <CR> auto-select the first completion item
vim.api.nvim_set_keymap('i', '<CR>',
  'coc#pum#visible() ? coc#pum#confirm() : "\\<C-g>u\\<CR>\\<c-r>=coc#on_enter()\\<CR>"',
  {silent = true, expr = true, noremap = true})

-- CoC navigation
vim.api.nvim_set_keymap('n', '[g', '<Plug>(coc-diagnostic-prev)', {silent = true})
vim.api.nvim_set_keymap('n', ']g', '<Plug>(coc-diagnostic-next)', {silent = true})
vim.api.nvim_set_keymap('n', 'gd', '<Plug>(coc-definition)',      {silent = true})
vim.api.nvim_set_keymap('n', 'gy', '<Plug>(coc-type-definition)', {silent = true})
vim.api.nvim_set_keymap('n', 'gi', '<Plug>(coc-implementation)',  {silent = true})
vim.api.nvim_set_keymap('n', 'gr', '<Plug>(coc-references)',      {silent = true})

-- Use K to show documentation
vim.api.nvim_set_keymap('n', 'K', ':lua _G.show_documentation()<CR>', {silent = true, noremap = true})
_G.show_documentation = function()
  local filetype = vim.bo.filetype
  if filetype == 'vim' or filetype == 'help' then
    vim.cmd('h ' .. vim.fn.expand('<cword>'))
  elseif vim.fn['coc#rpc#ready']() then
    vim.fn.CocActionAsync('doHover')
  else
    vim.cmd('!' .. vim.o.keywordprg .. ' ' .. vim.fn.expand('<cword>'))
  end
end

-- Highlight the symbol under cursor
vim.api.nvim_create_autocmd('CursorHold', {
  pattern = '*',
  callback = function()
    vim.fn.CocActionAsync('highlight')
  end
})

-- Define highlight style for symbol highlighting
vim.cmd('highlight CocHighlightText guibg=#4a4a7f guifg=NONE')

-- Symbol renaming and formatting
vim.api.nvim_set_keymap('n', '<leader>rn', '<Plug>(coc-rename)', {})
vim.api.nvim_set_keymap('x', '<leader>f', '<Plug>(coc-format-selected)', {})
vim.api.nvim_set_keymap('n', '<leader>f', '<Plug>(coc-format-selected)', {})

-- CoC actions
vim.api.nvim_set_keymap('x', '<leader>a', '<Plug>(coc-codeaction-selected)', {})
vim.api.nvim_set_keymap('n', '<leader>a', '<Plug>(coc-codeaction-selected)', {})
vim.api.nvim_set_keymap('n', '<leader>ac', '<Plug>(coc-codeaction)', {})
vim.api.nvim_set_keymap('n', '<leader>qf', '<Plug>(coc-fix-current)', {})

-- CoC text objects
vim.api.nvim_set_keymap('x', 'if', '<Plug>(coc-funcobj-i)', {})
vim.api.nvim_set_keymap('o', 'if', '<Plug>(coc-funcobj-i)', {})
vim.api.nvim_set_keymap('x', 'af', '<Plug>(coc-funcobj-a)', {})
vim.api.nvim_set_keymap('o', 'af', '<Plug>(coc-funcobj-a)', {})
vim.api.nvim_set_keymap('x', 'ic', '<Plug>(coc-classobj-i)', {})
vim.api.nvim_set_keymap('o', 'ic', '<Plug>(coc-classobj-i)', {})
vim.api.nvim_set_keymap('x', 'ac', '<Plug>(coc-classobj-a)', {})
vim.api.nvim_set_keymap('o', 'ac', '<Plug>(coc-classobj-a)', {})

-- CoC commands
vim.api.nvim_create_user_command('Format', "call CocAction('format')", {})
vim.api.nvim_create_user_command('Fold', "call CocAction('fold', <f-args>)", {nargs = '?'})
vim.api.nvim_create_user_command('OR', "call CocAction('runCommand', 'editor.action.organizeImport')", {})
vim.api.nvim_create_user_command('CocRestart', "call coc#rpc#restart()", {})

-- CoC status in statusline
vim.opt.statusline:prepend("%{coc#status()}%{get(b:,'coc_current_function','')}")

-- CoC List mappings
vim.api.nvim_set_keymap('n', '<space>a', ':<C-u>CocList diagnostics<cr>', {silent = true, nowait = true})
vim.api.nvim_set_keymap('n', '<space>e', ':<C-u>CocList extensions<cr>', {silent = true, nowait = true})
vim.api.nvim_set_keymap('n', '<space>c', ':<C-u>CocList commands<cr>', {silent = true, nowait = true})
vim.api.nvim_set_keymap('n', '<space>o', ':<C-u>CocList outline<cr>', {silent = true, nowait = true})
vim.api.nvim_set_keymap('n', '<space>s', ':<C-u>CocList -I symbols<cr>', {silent = true, nowait = true})
vim.api.nvim_set_keymap('n', '<space>j', ':<C-u>CocNext<CR>', {silent = true, nowait = true})
vim.api.nvim_set_keymap('n', '<space>k', ':<C-u>CocPrev<CR>', {silent = true, nowait = true})
vim.api.nvim_set_keymap('n', '<space>p', ':<C-u>CocListResume<CR>', {silent = true, nowait = true})

-- Update lightline when CoC status changes
vim.api.nvim_create_autocmd({"User"}, {
  pattern = {"CocStatusChange", "CocDiagnosticChange"},
  callback = function()
    vim.fn['lightline#update']()
  end
})

-- Custom commands for file navigation with FZF
vim.keymap.set('n', '<leader>ff', ':Files<CR>')
vim.keymap.set('n', '<leader>fb', ':Buffers<CR>')
vim.keymap.set('n', '<leader>fg', ':Rg<CR>')
vim.keymap.set('n', '<leader>fh', ':History<CR>')
-- vim.keymap.set('n', '<C-R>', ':sp <CR> :term env python3 % <CR>')

-- File navigation with Oil
vim.keymap.set('n', '<leader>o', ':Oil<CR>')
vim.keymap.set('n', '<C-w>o', ':Oil<CR>')
vim.keymap.set('n', '<C-w>v', ':vsplit<CR>')
vim.keymap.set('n', '<C-w>s', ':split<CR>')

-- Oil Setup
require("oil").setup({
  keymaps = {
    ["<C-w>"] = false,
    ["<C-w>v"] = false,
    ["<C-v>"] = false,
  },
})

-- Nvim-tree Setup
-- Disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Nvim-tree configuration
require("nvim-tree").setup({
  sort_by = "case_sensitive",
  view = {
    width = 30,
    side = "left",
  },
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = false,
  },
  git = {
    enable = true,
    ignore = false,
  },
  actions = {
    open_file = {
      window_picker = {
        enable = false
      }
    }
  }
})

-- Nvim-tree keymappings
vim.keymap.set('n', '<leader>n', ':NvimTreeToggle<CR>')
vim.keymap.set('n', '<C-n>', ':NvimTreeFindFile<CR>')
vim.keymap.set('n', '<leader>r', ':NvimTreeRefresh<CR>')

-- Auto-install missing CoC extensions
vim.api.nvim_create_autocmd('User', {
  pattern = 'CocNvimInit',
  callback = function()
    vim.fn.timer_start(1000, function()
      local installed = vim.fn.CocAction('extensionStats')
      local installed_ids = {}
      for _, ext in ipairs(installed) do
        table.insert(installed_ids, ext.id)
      end

      for _, ext in ipairs(vim.g.coc_global_extensions) do
        if not vim.tbl_contains(installed_ids, ext) then
          vim.cmd('CocInstall ' .. ext)
        end
      end
    end)
  end
})

-- Create coc-settings.json with improved settings
local coc_settings_file = vim.fn.expand('~/.config/nvim/coc-settings.json')
local coc_settings = {
  ['snippets.ultisnips.directories'] = {'~/.config/nvim/snippets'},
  ['snippets.snipmate.enable'] = false,
  ['snippets.textmateSnippetsRoots'] = {'~/.config/nvim/snippets'},
  ['svelte.enable-ts-plugin'] = true,
  ['svelte.plugin.typescript.enable'] = true,
  ['svelte.plugin.css.enable'] = true,
  ['svelte.plugin.html.enable'] = true,
  ['typescript.suggest.autoImports'] = true,
  ['javascript.suggest.autoImports'] = true,
  ['colors.enable'] = true,
  ['semanticTokens.enable'] = true,
  ['semanticTokens.filetypes'] = {'*'},
  ['languageserver'] = {
    ['svelte'] = {
      ['enable'] = true,
      ['filetypes'] = {'svelte'}
    }
  },
  ['prettier.tabWidth'] = 2,
  ['prettier.useTabs'] = false,
  ['prettier.singleQuote'] = true,
  ['prettier.trailingComma'] = 'es5',
  ['prettier.semi'] = true,
  ['prettier.bracketSpacing'] = true,
--  -- Python
  ['pyright.enable'] = true,
--  -- Python Linting
--  ['python.linting.enabled'] = true,
--  ['python.linting.ruffEnabled'] = true,
--  -- Python Formating
--  ['python.formatting.provider'] = 'ruff',
--  ['python.formatting.ruffPath'] = 'ruff',
--   ['python.formatting.ruffArgs'] = {
--     '--config', 'indent-width=2',
--     '--config', 'indent-style="space"',
--     '--ignore=D103',
--     '--fix'
--   },
--  ['pyright.organizeimports.provider'] = 'ruff',
  ['pyright.inlayHints.functionReturnTypes'] = false,
  ['pyright.inlayHints.variableTypes'] = false,
  ['pyright.inlayHints.parameterTypes'] = false,
  ['python.analysis.diagnosticSeverityOverrides'] = {
    ['missing-docstring'] = 'none'
  },

--  ['coc.preferences.formatOnSaveFiletypes'] = {'javascript', 'typescript', 'svelte', 'json', 'css', 'html'},
--  ['typescript.format.insertSpaceAfterOpeningAndBeforeClosingNonemptyBraces'] = true,
--  ['javascript.format.insertSpaceAfterOpeningAndBeforeClosingNonemptyBraces'] = true,
  ['suggest.removeDuplicateItems'] = true,
  ['suggest.defaultSortMethod'] = 'length',
  ['suggest.localityBonus'] = true,
  ['suggest.enablePreselect'] = true,
  ['suggest.floatEnable'] = true,
  ['suggest.selection'] = 'first',
  ['suggest.triggerCompletionWait'] = 50,
  ['suggest.acceptSuggestionOnCommitCharacter'] = true,
  ['tailwindCSS.enable'] = true,
  ['tailwindCSS.includeLanguages'] = {
    ['svelte'] = 'html',
    ['javascript'] = 'javascript',
    ['typescript'] = 'javascript'
  },

  ['tailwindCSS.emmetCompletions'] = true,
  ['tailwindCSS.validate'] = true,
  ['tailwindCSS.colorDecorators'] = true,
  ['suggest.completionItemKindLabels'] = {
    ['keyword'] = '🔑',
    ['variable'] = '📋',
    ['value'] = '📊',
    ['operator'] = '🔧',
    ['function'] = '🔨',
    ['reference'] = '📎',
    ['constant'] = '📒',
    ['method'] = '📝',
    ['struct'] = '🏗️',
    ['class'] = '🏛️',
    ['interface'] = '🔌',
    ['text'] = '📄',
    ['enum'] = '🗃️',
    ['enumMember'] = '📑',
    ['module'] = '📦',
    ['color'] = '🎨',
    ['snippet'] = '🐍',
    ['property'] = '🏷️',
    ['field'] = '🔬',
    ['unit'] = '📏',
    ['event'] = '📅',
    ['file'] = '📁',
    ['folder'] = '📂',
    ['typeParameter'] = '🔠',
    ['default'] = '❓'
  }
}

-- Always update the coc-settings.json file
local file = io.open(coc_settings_file, "w")
if file then
  file:write(vim.fn.json_encode(coc_settings))
  file:close()
end
