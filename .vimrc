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
"	Note that for nvim, <Space>q and <Space>e are taken

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

Plug 'tpope/vim-sleuth'  " auto-detect indentation settings
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

if has('nvim')
	Plug 'nvim-lua/plenary.nvim'
	Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.1' }

	" Get FZF as sorter for telescope
	Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build' }
endif

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

Plug 'sbdchd/neoformat'
"format entire file
nmap <leader>cf  :Neoformat<CR>
"format selected text
xnoremap <leader>cf  :Neoformat<CR>

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


Plug 'mattn/emmet-vim'


" Plug 'dense-analysis/ale'
"let g:ale_fixers = {
"\   'javascript': ['prettier'],
"\   'css': ['prettier'],
"\}
"let g:ale_fix_on_save = 1
""let g:ale_javascript_prettier_options = '--single-quote --trailing-comma all --no-semi'
"let g:ale_javascript_prettier_options = '--trailing-comma all --no-semi'
"

if has('nvim')
	Plug 'neovim/nvim-lspconfig'
	Plug 'jose-elias-alvarez/null-ls.nvim'
endif

" Markdown Preview (for .md files)
" If run into issues with post-update hook: https://github.com/iamcco/markdown-preview.nvim/issues/50
" tl;dr: Run ':call mkdp#util#install()' After installing
" Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
Plug 'iamcco/markdown-preview.nvim', { 'do': ':call mkdp#util#install()', 'for': ['markdown']}


" Ruby langauge support
Plug 'vim-ruby/vim-ruby'

Plug 'ap/vim-css-color'

Plug 'github/copilot.vim'


" Themes
Plug 'dracula/vim', { 'as': 'dracula' }
Plug 'junegunn/seoul256.vim'
Plug 'jnurmine/Zenburn'
Plug 'rakr/vim-one'
Plug 'preservim/vim-colors-pencil'
if has('nvim')
	Plug 'rose-pine/neovim', { 'as': 'rose-pine' }
endif
Plug 'zacanger/angr.vim'

" # } END my plugins

" Initialize plugin system
call plug#end()

" # } END plugins


" # BEGIN nvim-related plugin config {
if has('nvim')
	lua require('lsp')
	lua require('lsp/formatter')
endif
" # } END nvim-related plugin config


" # BEGIN Telescope config {
if has('nvim')
	" Find files using Telescope command-line sugar.
	nnoremap <leader>ff <cmd>Telescope find_files<cr>
	nnoremap <leader>fg <cmd>Telescope live_grep<cr>
	nnoremap <leader>fb <cmd>Telescope buffers<cr>
	nnoremap <leader>fh <cmd>Telescope help_tags<cr>

	lua require('telescope').load_extension('fzf')
endif
" # } END Telescope config


" # BEGIN theme {

" Colorschemes

" Unified color scheme (default: dark)
"colors seoul256

" Light color scheme
"colors seoul256-light

" Dark color schemes
"colors dracula
"colors zenburn
"colors angr

" Suports both dark and light
"colors one
"colors rose-pine

"color pencil
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
	call Lightline('darcula')
	colorscheme angr

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
	call Lightline('one')
	if has('nvim')
		colorscheme rose-pine
	else
		colorscheme pencil
	endif

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

" # } END misc


" # BEGIN commands {

" Execute file currently in buffer
function! ExecuteFile()
	execute "!./" . expand("%")
endfunction
command! ExecuteFile call ExecuteFile()
nnoremap <leader>ef :ExecuteFile<cr>
nnoremap <leader>xf :ExecuteFile<cr>

" # } END commands
