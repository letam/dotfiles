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

" Function to use tabs for indentation
function! UseTabs()
   set noexpandtab
   set tabstop=3
   set shiftwidth=3
   set autoindent
   echo "Indenting with tabs (tabstop=3, shiftwidth=3)"
endfunction

" Function to use spaces for indentation (default 4)
function! UseSpaces4()
   set expandtab
   set tabstop=4
   set shiftwidth=4
   set autoindent
   echo "Indenting with spaces (tabstop=4, shiftwidth=4)"
endfunction

" Function to use spaces for indentation (2 spaces)
function! UseSpaces2()
   set expandtab
   set tabstop=2
   set shiftwidth=2
   set autoindent
   echo "Indenting with spaces (tabstop=2, shiftwidth=2)"
endfunction

" Mappings for easy switching
nnoremap <leader>it :call UseTabs()<CR>
nnoremap <leader>is4 :call UseSpaces4()<CR>
nnoremap <leader>is2 :call UseSpaces2()<CR>

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

" # BEGIN nvim-related plugin config {
if has('nvim')
	lua require('config.lazy')
	lua require('config.lsp')
	lua require('config.lsp/formatter')
endif
" # } END nvim-related plugin config


" # BEGIN Telescope config {
if has('nvim')
	" Find files using Telescope command-line sugar.
	nnoremap <leader>ff <cmd>Telescope find_files<cr>
	nnoremap <leader>fg <cmd>Telescope live_grep<cr>
	nnoremap <leader>fb <cmd>Telescope buffers<cr>
	nnoremap <leader>fh <cmd>Telescope help_tags<cr>
endif
" # } END Telescope config


if has('nvim')
	" Neotree shortcuts
	nnoremap <leader>n :Neotree focus<CR>
	nnoremap <C-n> :Neotree<CR>
	nnoremap <C-t> :Neotree toggle<CR>
	nnoremap <leader>tf :NERDTreeFind<CR>
	nnoremap <leader>tt :Neotree toggle<CR>
	nnoremap <leader>tr :Neotree reveal<CR>

	" Multiple Plug commands can be written in a single line using | separators
	" Plug 'SirVer/ultisnips' | Plug 'honza/vim-snippets'
	" let g:UltiSnipsExpandTrigger="<tab>"
	" let g:UltiSnipsJumpForwardTrigger="<c-b>"
	" let g:UltiSnipsJumpBackwardTrigger="<c-z>"
endif

" Plug 'itchyny/lightline.vim'
set laststatus=2

" Plug 'airblade/vim-gitgutter'
nmap <leader>gj :GitGutterNextHunk<CR>
nmap <leader>gk :GitGutterPrevHunk<CR>
nmap <leader>gs :GitGutterStageHunk<CR>
nmap <leader>gu :GitGutterUndoHunk<CR>

" Plug 'sbdchd/neoformat'
"format entire file
nmap <leader>cf  :Neoformat<CR>
"format selected text
xnoremap <leader>cf  :Neoformat<CR>

" Plug 'luochen1990/rainbow'
let g:rainbow_active = 1 "set to 0 if you want to enable it later via :RainbowToggle

" Plug 'pangloss/vim-javascript'
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

" Plug 'wellle/context.vim'
let g:startify_session_before_save = [
	\ "ContextDisable"
	\ ]


" # } END plugins


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
				\ strftime('%H') >= 7 && strftime('%H') < 17 ? "light" : "dark"

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

" Insert timestamp at cursor position
nnoremap <leader>dt "=strftime('%Y-%m-%d %H:%M:%S')<CR>p
inoremap <C-d>t <C-r>=strftime('%Y-%m-%d %H:%M:%S')<CR>

" Insert time only at cursor position
nnoremap <leader>ds "=strftime('%H:%M:%S')<CR>p
inoremap <C-d>s <C-r>=strftime('%H:%M:%S')<CR>

" # } END commands

if filereadable(expand("~/.nvimrc.local")) | source ~/.nvimrc.local | endif

