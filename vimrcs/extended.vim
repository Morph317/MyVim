"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Windows 适配版 extended.vim
"    基于 amix/vimrc 的 extended.vim，为 Windows GVim 调整：
"      - GUI 字体改为 Consolas 等 Windows 常见等宽字体
"      - F5 编译运行适配 cmd.exe（去掉 time / ./ 等 Unix 写法）
"      - 移除依赖 Ack/ag 的映射（未安装 ack.vim）
"      - 配色主题改由 my_configs.vim 统一设置（gruvbox）
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => GUI related
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Set font according to system
if has("mac") || has("macunix")
    set gfn=IBM\ Plex\ Mono:h14,Hack:h14,Source\ Code\ Pro:h15,Menlo:h15
elseif has("win16") || has("win32")
    set gfn=Consolas:h11,Source\ Code\ Pro:h12,IBM\ Plex\ Mono:h14,Cascadia\ Mono:h11
elseif has("gui_gtk2")
    set gfn=IBM\ Plex\ Mono\ 14,:Hack\ 14,Source\ Code\ Pro\ 12,Bitstream\ Vera\ Sans\ Mono\ 11
elseif has("linux")
    set gfn=IBM\ Plex\ Mono\ 14,:Hack\ 14,Source\ Code\ Pro\ 12,Bitstream\ Vera\ Sans\ Mono\ 11
elseif has("unix")
    set gfn=Monospace\ 11
endif

" Disable scrollbars (real hackers don't use scrollbars for navigation!)
set guioptions-=r
set guioptions-=R
set guioptions-=l
set guioptions-=L

" Colorscheme is set in my_configs.vim (gruvbox, dark)
set background=dark


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Fast editing and reloading of vimrc configs
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
map <leader>e :e! ~/.vim_runtime/my_configs.vim<cr>
autocmd! bufwritepost ~/.vim_runtime/my_configs.vim source ~/.vim_runtime/my_configs.vim


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Turn persistent undo on
"    means that you can undo even when you close a buffer/VIM
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
try
    set undodir=~/.vim_runtime/temp_dirs/undodir
    set undofile
catch
endtry


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Command mode related
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Smart mappings on the command line
cno $h e ~/
cno $d e ~/Desktop/
cno $j e ./
cno $c e <C-\>eCurrentFileDir("e")<cr>

" $q is super useful when browsing on the command line
" it deletes everything until the last slash
cno $q <C-\>eDeleteTillSlash()<cr>

" Bash like keys for the command line
cnoremap <C-A>		<Home>
cnoremap <C-E>		<End>
cnoremap <C-K>		<C-U>

cnoremap <C-P> <Up>
cnoremap <C-N> <Down>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Parenthesis/bracket
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
vnoremap $1 <esc>`>a)<esc>`<i(<esc>
vnoremap $2 <esc>`>a]<esc>`<i[<esc>
vnoremap $3 <esc>`>a}<esc>`<i{<esc>
vnoremap $$ <esc>`>a"<esc>`<i"<esc>
vnoremap $q <esc>`>a'<esc>`<i'<esc>
vnoremap $e <esc>`>a`<esc>`<i`<esc>

" Map auto complete of (, ", ', [
inoremap $1 ()<esc>i
inoremap $2 []<esc>i
inoremap $3 {}<esc>i
inoremap $4 {<esc>o}<esc>O
inoremap $q ''<esc>i
inoremap $e ""<esc>i


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => General abbreviations
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
iab xdate <C-r>=strftime("%d/%m/%y %H:%M:%S")<cr>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Omni complete functions
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" [Windows 适配] 用 setlocal 而非 set: 'omnifunc' 是 buffer-local 且有全局默认值,
" 写成 set 会污染全局, 导致之后新开的无 omnifunc 的缓冲(如 .go/.sh/.lua)
" 继承 csscomplete#CompleteCSS
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Quickfix navigation (works with :grep / :make results)
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
map <leader>cc :botright cope<cr>
map <leader>co ggVGy:tabnew<cr>:set syntax=qf<cr>pgg
map <leader>n :cn<cr>
map <leader>p :cp<cr>

" Make sure that enter is never overriden in the quickfix window
autocmd BufReadPost quickfix nnoremap <buffer> <CR> <CR>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Helper functions
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
func! DeleteTillSlash()
    let g:cmd = getcmdline()

    if has("win16") || has("win32")
        let g:cmd_edited = substitute(g:cmd, "\\(.*\[\\\\\]\\).*", "\\1", "")
    else
        let g:cmd_edited = substitute(g:cmd, "\\(.*\[/\]\\).*", "\\1", "")
    endif

    if g:cmd == g:cmd_edited
        if has("win16") || has("win32")
            let g:cmd_edited = substitute(g:cmd, "\\(.*\[\\\\\]\\).*\[\\\\\]", "\\1", "")
        else
            let g:cmd_edited = substitute(g:cmd, "\\(.*\[/\]\\).*/", "\\1", "")
        endif
    endif

    return g:cmd_edited
endfunc

func! CurrentFileDir(cmd)
    return a:cmd . " " . escape(expand("%:p:h"), " ") . "/"
endfunc

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => F5 一键编译/运行 (Windows 适配版)
"    C/C++/Java 需要安装对应编译器并在 PATH 中
"    Python 需要 python 在 PATH 中；HTML 用默认浏览器打开
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
map <F5> :call CompileRun()<CR>
imap <F5> <Esc>:call CompileRun()<CR>
vmap <F5> <Esc>:call CompileRun()<CR>

func! CompileRun()
exec "w"
if &filetype == 'c'
    exec '!gcc "' . expand('%') . '" -o "' . expand('%<') . '.exe"'
    exec '!"' . expand('%<') . '.exe"'
elseif &filetype == 'cpp'
    exec '!g++ "' . expand('%') . '" -o "' . expand('%<') . '.exe"'
    exec '!"' . expand('%<') . '.exe"'
elseif &filetype == 'java'
    exec '!javac "' . expand('%') . '"'
    exec '!java -cp "' . expand('%:p:h') . '" ' . expand('%:t:r')
elseif &filetype == 'sh'
    exec '!bash "' . expand('%') . '"'
elseif &filetype == 'python'
    exec '!python "' . expand('%') . '"'
elseif &filetype == 'html'
    exec '!start "" "' . expand('%') . '"'
elseif &filetype == 'go'
    exec '!go build "' . expand('%') . '"'
    exec '!go run "' . expand('%') . '"'
else
    echo "F5: 暂不支持该文件类型 (支持 c/cpp/java/sh/python/html/go)"
endif
endfunc
