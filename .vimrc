" Vim Configuration
" Lesson 1:
" Copy and paste from examples in the README.md of projects
" Readme-based copypasta development


" # BEGIN base config {

set number
set ruler
set hidden
set ignorecase
set smartcase

set mouse=a  " Enable mouse support (:help mouse)

" Set tab width
set shiftwidth=3
set tabstop=3

" Map Space key to Leader key
map <Space> <Leader>

" Switch to buffer by number, quickly
nnoremap <leader>b :buffers<CR>:buffer<Space>

" Open current buffer in new tab
nnoremap <leader>tn <C-w>s <C-w>T

" Open new buffer in new window rendering Startify dashboard
nnoremap <leader>ts :tabnew<CR>:Startify<CR>

" Clear highlighted search matches
nnoremap <leader>ho :nohlsearch<CR>

" # } END base config


" # BEGIN plugins {
"
" Specify a directory for plugins
" - For Neovim: stdpath('data') . '/plugged'
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.vim/plugged')

" Make sure you use single quotes

" Shorthand notation; fetches https://github.com/junegunn/vim-easy-align
Plug 'junegunn/vim-easy-align'

" Any valid git URL is allowed
Plug 'https://github.com/junegunn/vim-github-dashboard.git'

" Multiple Plug commands can be written in a single line using | separators
if has('nvim')
  " Plug 'SirVer/ultisnips' | Plug 'honza/vim-snippets'
  " let g:UltiSnipsExpandTrigger="<tab>"
  " let g:UltiSnipsJumpForwardTrigger="<c-b>"
  " let g:UltiSnipsJumpBackwardTrigger="<c-z>"
endif

" On-demand loading
Plug 'preservim/nerdtree', { 'on':  'NERDTreeToggle' }
"Plug 'tpope/vim-fireplace', { 'for': 'clojure' }

" Using a non-default branch
"Plug 'rdnetto/YCM-Generator', { 'branch': 'stable' }

" Using a tagged release; wildcard allowed (requires git 1.9.2 or above)
"Plug 'fatih/vim-go', { 'tag': '*' }

" Plugin options
"Plug 'nsf/gocode', { 'tag': 'v.20150303', 'rtp': 'vim' }

" Plugin outside ~/.vim/plugged with post-update hook
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }

" Unmanaged plugin (manually installed and updated)
"Plug '~/my-prototype-plugin'


" # BEGIN my plugins {
"

Plug 'tpope/vim-vinegar'  " file explorer-navigation goodies and related sugar
Plug 'tpope/vim-eunuch'  " provides UNIX shell commands

" NERDTree shortcuts
nnoremap <leader>n :NERDTreeFocus<CR>
nnoremap <C-n> :NERDTree<CR>
nnoremap <C-t> :NERDTreeToggle<CR>
nnoremap <C-f> :NERDTreeFind<CR>
nnoremap <leader>tf :NERDTreeFind<CR>
nnoremap <leader>tt :NERDTreeToggle<CR>

Plug 'Xuyuanp/nerdtree-git-plugin'

Plug 'ryanoasis/vim-devicons'  " file type icons

Plug 'wakatime/vim-wakatime'
Plug 'mhinz/vim-startify'

Plug 'junegunn/fzf.vim'

Plug 'itchyny/lightline.vim'
set laststatus=2

Plug 'tpope/vim-fugitive'  " Git plugin
Plug 'tpope/vim-rhubarb'  " GitHub extension for fugitive.vim
Plug 'junegunn/gv.vim'  " Git commit browser

Plug 'airblade/vim-gitgutter'
nmap <leader>gj :GitGutterNextHunk<CR>
nmap <leader>gk :GitGutterPrevHunk<CR>
nmap <leader>gs :GitGutterStageHunk<CR>
nmap <leader>gu :GitGutterUndoHunk<CR>

Plug 'tpope/vim-commentary'

Plug 'luochen1990/rainbow'
let g:rainbow_active = 1 "set to 0 if you want to enable it later via :RainbowToggle

Plug 'pangloss/vim-javascript'
let g:javascript_plugin_jsdoc = 1
let g:javascript_conceal_function             = "ƒ"
let g:javascript_conceal_null                 = "ø"
let g:javascript_conceal_this                 = "@"
let g:javascript_conceal_return               = "⇚"
let g:javascript_conceal_undefined            = "¿"
let g:javascript_conceal_NaN                  = "ℕ"
let g:javascript_conceal_prototype            = "¶"
let g:javascript_conceal_static               = "•"
let g:javascript_conceal_super                = "Ω"
let g:javascript_conceal_arrow_function       = "⇒"
map <leader>l :exec &conceallevel ? "set conceallevel=0" : "set conceallevel=1"<CR>


" Syntax highlighting for JSX-TypeScript
Plug 'leafgarland/typescript-vim'
Plug 'peitalin/vim-jsx-typescript'


Plug 'honza/vim-snippets'

" Plug 'dense-analysis/ale'
"let g:ale_fixers = {
"\   'javascript': ['prettier'],
"\   'css': ['prettier'],
"\}
"let g:ale_fix_on_save = 1
""let g:ale_javascript_prettier_options = '--single-quote --trailing-comma all --no-semi'
"let g:ale_javascript_prettier_options = '--trailing-comma all --no-semi'
"

Plug 'neoclide/coc.nvim', {'branch': 'release'}
" TextEdit might fail if hidden is not set.
set hidden

" Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup

" Give more space for displaying messages.
set cmdheight=2

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
if has("patch-8.1.1564")
  " Recently vim can merge signcolumn and number column into one
  set signcolumn=number
else
  set signcolumn=yes
endif

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Make <CR> auto-select the first completion item and notify coc.nvim to
" format on enter, <cr> could be remapped by other vim plugin
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
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

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current buffer.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Remap <C-f> and <C-b> for scroll float windows/popups.
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif

" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of language server.
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Mappings for CoCList
" Show all diagnostics.
nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions.
nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
" Show commands.
nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document.
nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols.
nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list.
nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>


" coc-lists (https://github.com/neoclide/coc-lists)
" grep word under cursor
command! -nargs=+ -complete=custom,s:GrepArgs Rg exe 'CocList grep '.<q-args>

function! s:GrepArgs(...)
  let list = ['-S', '-smartcase', '-i', '-ignorecase', '-w', '-word',
        \ '-e', '-regex', '-u', '-skip-vcs-ignores', '-t', '-extension']
  return join(list, "\n")
endfunction

" Keymapping for grep word under cursor with interactive mode
nnoremap <silent> <Leader>/f :exe 'CocList -I --input='.expand('<cword>').' grep'<CR>

" How to grep by motion?
	" Create custom keymappings like:
vnoremap <leader>g :<C-u>call <SID>GrepFromSelected(visualmode())<CR>
nnoremap <leader>g :<C-u>set operatorfunc=<SID>GrepFromSelected<CR>g@

function! s:GrepFromSelected(type)
  let saved_unnamed_register = @@
  if a:type ==# 'v'
    normal! `<v`>y
  elseif a:type ==# 'char'
    normal! `[v`]y
  else
    return
  endif
  let word = substitute(@@, '\n$', '', 'g')
  let word = escape(word, '| ')
  let @@ = saved_unnamed_register
  execute 'CocList grep '.word
endfunction

" How to grep current word in current buffer?
	" Create kep-mapping like:
nnoremap <silent> <space>w  :exe 'CocList -I --normal --input='.expand('<cword>').' words'<CR>


" coc-snippets (https://github.com/neoclide/coc-snippets)
" Use <C-l> for trigger snippet expand.
imap <C-l> <Plug>(coc-snippets-expand)

" Use <C-j> for select text for visual placeholder of snippet.
vmap <C-j> <Plug>(coc-snippets-select)

" Use <C-j> for jump to next placeholder, it's default of coc.nvim
let g:coc_snippet_next = '<c-j>'

" Use <C-k> for jump to previous placeholder, it's default of coc.nvim
let g:coc_snippet_prev = '<c-k>'

" Use <C-j> for both expand and jump (make expand higher priority.)
imap <C-j> <Plug>(coc-snippets-expand-jump)

" Use <leader>x for convert visual selected code to snippet
xmap <leader>x  <Plug>(coc-convert-snippet)

" Make <tab> used for trigger completion, completion confirm, snippet expand and jump like VSCode.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? coc#_select_confirm() :
      \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

let g:coc_snippet_next = '<tab>'


" Prettier
command! -nargs=0 Prettier :CocCommand prettier.formatFile
nmap <leader>F  :Prettier<CR>


" Black formatter for Python files
Plug 'psf/black', { 'branch': 'stable' }
autocmd FileType python  nmap <buffer> <leader>F  :Black<CR>


" Markdown Preview (for .md files)
" If run into issues with post-update hook: https://github.com/iamcco/markdown-preview.nvim/issues/50
" tl;dr: Run ':call mkdp#util#install()' After installing
" Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
Plug 'iamcco/markdown-preview.nvim', { 'do': ':call mkdp#util#install()', 'for': ['markdown']}


" Ruby langauge support
Plug 'vim-ruby/vim-ruby'

Plug 'ap/vim-css-color'


" Themes
Plug 'dracula/vim', { 'as': 'dracula' }
Plug 'junegunn/seoul256.vim'
Plug 'jnurmine/Zenburn'
Plug 'rakr/vim-one'
Plug 'preservim/vim-colors-pencil'
if has('nvim')
	Plug 'rose-pine/neovim', { 'as': 'rose-pine' }
endif

" # } END my plugins

" Initialize plugin system
call plug#end()

" # } END plugins
"

" # BEGIN theme {

" Colorschemes

" Unified color scheme (default: dark)
"colors seoul256

" Light color scheme
"colors seoul256-light

" Dark color schemes
"colors dracula
"colors zenburn

" Suports both dark and light
"colorscheme one
"colorscheme rose-pine

"colorscheme pencil
let g:pencil_terminal_italics = 1

" Switch dark vs light
"set background=dark
set background=light

" Initialize lightline config map
let g:lightline = {}

fun! Lightline(scheme)
	let g:lightline.colorscheme = a:scheme
	call lightline#disable()
	call lightline#enable()
endf

" Load dark color scheme
fun! Colorsdark()
	set background=dark
	colorscheme dracula
	call Lightline('darcula')

	if (has("termguicolors"))
		set notermguicolors
	endif

	" Set transparent background
	hi Normal guibg=NONE ctermbg=NONE
endf
command -nargs=* Colorsdark call Colorsdark(<f-args>)

" Load light color scheme
fun! Colorslight()
	set background=light
	colorscheme pencil
	call Lightline('one')

	if (has("termguicolors"))
		set termguicolors
	endif
endf
command -nargs=* Colorslight call Colorslight(<f-args>)

" Load color scheme as light or dark based on time of day
fun! Colorsdefault(...)
	let theme = a:0 > 0 ? a:1 :
				\ strftime('%H') >= 7 && strftime('%H') < 20 ? "light" : "dark"

	if theme == "light"
		Colorslight
	else
		Colorsdark
	endif
endf
command -nargs=* Colorsdefault call Colorsdefault(<f-args>)
Colorsdefault


" # } END theme


" # BEGIN misc {
" Fix CSS indentation inside of HTML files
" Reference: https://www.reddit.com/r/vim/comments/97e33c/autoindent_bugs_regarding_html_style_tags/
let g:html_indent_style1 = "inc"
"
" # } END misc

