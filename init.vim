call plug#begin()
" Theme and UI
Plug 'drewtempelmeyer/palenight.vim'
Plug 'itchyny/lightline.vim'

" Code functionality
Plug 'neoclide/coc.nvim', { 'branch': 'release' }
Plug 'preservim/tagbar'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'HiPhish/rainbow-delimiters.nvim'
Plug 'tommcdo/vim-lion'
Plug 'ntpeters/vim-better-whitespace'

" File navigation
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'stevearc/oil.nvim'

" Language specific
Plug 'evanleck/vim-svelte'
Plug 'pangloss/vim-javascript'
Plug 'HerringtonDarkholme/yats.vim'
Plug 'Einenlum/yaml-revealer'

" Markdown Preview options
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install', 'for': 'markdown' }
Plug 'ellisonleao/glow.nvim', {'branch': 'main'}
call plug#end()

" Theme
colorscheme palenight
set t_Co=256

" Basic settings
syntax on
set number
set ruler
set visualbell
set encoding=utf-8
set nowrap
set mouse=a
set updatetime=300
set cmdheight=1
set shortmess+=c
set signcolumn=yes
set laststatus=2
set hlsearch
set incsearch
set autoindent
set smartindent
set nobackup
set nowritebackup

" Function to set tab width to n spaces
function! SetTab(n)
    let &l:tabstop=a:n
    let &l:softtabstop=a:n
    let &l:shiftwidth=a:n
    set expandtab
endfunction
command! -nargs=1 SetTab call SetTab(<f-args>)
command! Trim :StripWhitespace

" Set default tab width to 2 spaces
call SetTab(2)

" Key remappings
nnoremap <c-z> <nop>
nmap <c-c> <esc>
imap <c-c> <esc>
vmap <c-c> <esc>
omap <c-c> <esc>

" File type settings
filetype plugin indent on

" File type associations
augroup file_types
  au!
  " Svelte
  autocmd BufNewFile,BufRead *.svelte set filetype=svelte
  autocmd FileType svelte,javascript,typescript,typescriptreact nmap <buffer> gd <Plug>(coc-definition)
  autocmd FileType svelte,javascript,typescript,typescriptreact nmap <buffer> gi <Plug>(coc-implementation)
  autocmd FileType svelte,javascript,typescript,typescriptreact nmap <buffer> gr <Plug>(coc-references)
augroup END

" Plugin settings
" Whitespace
let g:better_whitespace_enabled=1
let g:strip_whitespace_on_save=1
let g:strip_whitespace_confirm=0
let g:strip_whitelines_at_eof=1
let g:better_whitespace_filetypes_blacklist=[]
let g:show_spaces_that_precede_tabs=1

" Lion
let b:lion_squeeze_spaces = 1

" TagBar
nmap <F8> :TagbarToggle<CR>

" Markdown preview
let g:mkdp_auto_start = 0
let g:mkdp_auto_close = 1
let g:mkdp_refresh_slow = 0
let g:mkdp_command_for_global = 0
let g:mkdp_open_to_the_world = 0
let g:mkdp_browser = ''
let g:mkdp_echo_preview_url = 1
let g:mkdp_page_title = '「${name}」'

lua << LUABLOCK
require('glow').setup({
  style = "dark",
  width = 180,
  height_ratio = 0.9,
  border = "rounded",
  pager = false,
})
LUABLOCK

" Markdown preview mappings
nmap <leader>mp :MarkdownPreview<CR>
nmap <leader>ms :MarkdownPreviewStop<CR>
nmap <leader>mt :MarkdownPreviewToggle<CR>
nmap <leader>? :Glow ~/.config/nvim/Documentation.md<CR>
nmap <C-w>? :Glow ~/.config/nvim/Documentation.md<CR>
nmap <leader>mg :Glow<CR>
command! EditDocs :edit ~/.config/nvim/Documentation.md

" TreeSitter configuration
lua << TREESITTER_BLOCK
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
  }
}
TREESITTER_BLOCK

" CoC extensions
let g:coc_global_extensions = [
      \ 'coc-tsserver',
      \ 'coc-css',
      \ 'coc-html',
      \ 'coc-json',
      \ 'coc-svelte',
      \ 'coc-tailwindcss',
      \ 'coc-highlight'
      \ ]

" Use <c-space> to trigger completion
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Make <CR> auto-select the first completion item
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" CoC navigation
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation
nnoremap <silent> K :call <SID>show_documentation()<CR>
function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

" Highlight the symbol under cursor
autocmd CursorHold * silent call CocActionAsync('highlight')
" Define highlight style for symbol highlighting
highlight CocHighlightText guibg=#4a4a7f guifg=NONE

" Symbol renaming and formatting
nmap <leader>rn <Plug>(coc-rename)
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

" CoC actions
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>ac <Plug>(coc-codeaction)
nmap <leader>qf <Plug>(coc-fix-current)

" CoC text objects
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Scroll float windows
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif

" CoC selection ranges
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" CoC commands
command! -nargs=0 Format :call CocAction('format')
command! -nargs=? Fold :call CocAction('fold', <f-args>)
command! -nargs=0 OR :call CocAction('runCommand', 'editor.action.organizeImport')
command! -nargs=0 CocRestart :call coc#rpc#restart()

" CoC status in statusline
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" CoC List mappings
nnoremap <silent><nowait> <space>a :<C-u>CocList diagnostics<cr>
nnoremap <silent><nowait> <space>e :<C-u>CocList extensions<cr>
nnoremap <silent><nowait> <space>c :<C-u>CocList commands<cr>
nnoremap <silent><nowait> <space>o :<C-u>CocList outline<cr>
nnoremap <silent><nowait> <space>s :<C-u>CocList -I symbols<cr>
nnoremap <silent><nowait> <space>j :<C-u>CocNext<CR>
nnoremap <silent><nowait> <space>k :<C-u>CocPrev<CR>
nnoremap <silent><nowait> <space>p :<C-u>CocListResume<CR>

" Lightline configuration
let g:lightline = {
  \ 'colorscheme': 'wombat',
  \ 'active': {
  \   'left': [ [ 'mode', 'paste' ],
  \             [ 'cocstatus', 'readonly', 'filename', 'modified' ] ]
  \ },
  \ 'component_function': {
  \   'cocstatus': 'coc#status'
  \ },
  \ }
autocmd User CocStatusChange,CocDiagnosticChange call lightline#update()

" Custom commands
nnoremap <leader>ff :Files<CR>
nnoremap <leader>fb :Buffers<CR>
nnoremap <leader>fg :Rg<CR>
nnoremap <leader>fh :History<CR>
nnoremap <C-R> :sp <CR> :term env python3 % <CR>

" File navigation with Oil
nnoremap <leader>o :Oil<CR>
nnoremap <C-w>o :Oil<CR>
nnoremap <C-w>v :vsplit<CR>
nnoremap <C-w>s :split<CR>

" Oil Setup
lua << OILBLOCK
require("oil").setup({
  keymaps = {
    ["<C-w>"] = false,
    ["<C-w>v"] = false,
    ["<C-v>"] = false,
  },
})
OILBLOCK

" Auto-install missing CoC extensions
function! CheckAndInstallExtensions(timer_id)
  let l:installed = CocAction('extensionStats')
  let l:installed_ids = map(copy(l:installed), 'v:val["id"]')

  for ext in g:coc_global_extensions
    if index(l:installed_ids, ext) == -1
      execute 'CocInstall ' . ext
    endif
  endfor
endfunction

" Wait for CoC to initialize before checking extensions
autocmd User CocNvimInit call timer_start(1000, 'CheckAndInstallExtensions')

" Configure CoC to use pnpm instead of npm if available
if executable('pnpm')
  let g:coc_npm_cmd = 'pnpm'
endif

" Create coc-settings.json with improved settings (without snippet settings)
let s:coc_settings_file = expand('~/.config/nvim/coc-settings.json')
let s:coc_settings = {
  \ 'svelte.enable-ts-plugin': v:true,
  \ 'svelte.plugin.typescript.enable': v:true,
  \ 'svelte.plugin.css.enable': v:true,
  \ 'svelte.plugin.html.enable': v:true,
  \ 'typescript.suggest.autoImports': v:true,
  \ 'javascript.suggest.autoImports': v:true,
  \ 'colors.enable': v:true,
  \ 'semanticTokens.enable': v:true,
  \ 'semanticTokens.filetypes': ['*'],
  \ 'languageserver': {
  \   'svelte': {
  \     'enable': v:true,
  \     'filetypes': ['svelte']
  \   }
  \ },
  \ 'prettier.tabWidth': 2,
  \ 'prettier.useTabs': v:false,
  \ 'coc.preferences.formatOnSaveFiletypes': ['javascript', 'typescript', 'svelte', 'json', 'css', 'html'],
  \ 'typescript.format.insertSpaceAfterOpeningAndBeforeClosingNonemptyBraces': v:true,
  \ 'javascript.format.insertSpaceAfterOpeningAndBeforeClosingNonemptyBraces': v:true,
  \ 'suggest.removeDuplicateItems': v:true,
  \ 'suggest.defaultSortMethod': 'length',
  \ 'suggest.localityBonus': v:true,
  \ 'suggest.enablePreselect': v:true,
  \ 'suggest.floatEnable': v:true,
  \ 'suggest.selection': 'first',
  \ 'suggest.triggerCompletionWait': 50,
  \ 'suggest.acceptSuggestionOnCommitCharacter': v:true,
  \ 'tailwindCSS.enable': v:true,
  \ 'tailwindCSS.includeLanguages': {
  \   'svelte': 'html',
  \   'javascript': 'javascript',
  \   'typescript': 'javascript'
  \ },
  \ 'tailwindCSS.emmetCompletions': v:true,
  \ 'tailwindCSS.validate': v:true,
  \ 'tailwindCSS.colorDecorators': v:true,
  \ 'suggest.completionItemKindLabels': {
  \   'keyword': '🔑',
  \   'variable': '📋',
  \   'value': '📊',
  \   'operator': '🔧',
  \   'function': '🔨',
  \   'reference': '📎',
  \   'constant': '📒',
  \   'method': '📝',
  \   'struct': '🏗️',
  \   'class': '🏛️',
  \   'interface': '🔌',
  \   'text': '📄',
  \   'enum': '🗃️',
  \   'enumMember': '📑',
  \   'module': '📦',
  \   'color': '🎨',
  \   'snippet': '🐍',
  \   'property': '🏷️',
  \   'field': '🔬',
  \   'unit': '📏',
  \   'event': '📅',
  \   'file': '📁',
  \   'folder': '📂',
  \   'typeParameter': '🔠',
  \   'default': '❓'
  \ }
  \ }

" Write settings file only if it doesn't exist or is different
if !filereadable(s:coc_settings_file) || readfile(s:coc_settings_file) != [json_encode(s:coc_settings)]
  call writefile([json_encode(s:coc_settings)], s:coc_settings_file)
endif
