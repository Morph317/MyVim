"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" MyVim 平台层 —— 唯一存放跨平台差异的地方
"
" 为什么放在 plugin/ :
"   Vim 的启动顺序是 vimrc -> plugin/**/*.vim, 而本目录属于 rtp,
"   所以本文件一定在 my_configs.vim 之后加载, 天然成为"最后生效的覆盖层"。
"   于是所有平台修正都能写在这里, 而现有配置文件一个字都不用改。
"
" 覆盖的三件事:
"   1) 剪贴板: Windows 只能 unnamed; Linux 有 +clipboard 才用 unnamedplus
"   2) 没有系统剪贴板时 (-clipboard) 的 OSC 52 终端透传
"   3) F5 编译/运行命令的 Unix 版 (现有 extended.vim 里那版是 Windows 写法)
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let s:root = expand('<sfile>:p:h:h')   " plugin/ 的上一级 = 仓库根

"""""""""""""""""""""""""""""""""""""""
" 1. 剪贴板
"""""""""""""""""""""""""""""""""""""""
" 本机 (Windows GVim, Vim 9.2) 实测: clipboard=unnamedplus 时 yank 类操作
" 不会写系统剪贴板, 只有 unnamed 正常, 所以 Windows 侧保持 unnamed。
" Linux 侧相反: unnamed 指向 X11 primary selection(鼠标选中即是), unnamedplus
" 才是真正的剪贴板。而 Ubuntu 的 vim 包是 -clipboard 构建, 那里 'clipboard'
" 选项不存在, 碰它就会抛 E518, 因此必须先探测。
if exists('+clipboard')
  if has('win32') || has('win64')
    set clipboard=unnamed
  else
    set clipboard=unnamedplus
  endif
endif

"""""""""""""""""""""""""""""""""""""""
" 2. 无系统剪贴板时的 OSC 52 透传
"""""""""""""""""""""""""""""""""""""""
" 服务器上的 vim 是 -clipboard, 自身拿不到系统剪贴板; 但终端模拟器支持 OSC 52,
" 所以把 yank 的内容用 base64 编码后直接写给本地终端即可实现"服务器里复制,
" 本机直接粘"。
"
" 用法:  空格+y        (普通模式: 复制当前行/寄存器内容)
"        空格+y        (可视模式: 复制选区)
" 注意:  只能"服务器 -> 本机"这一个方向。反方向受终端安全策略限制,
"        请用终端自己的粘贴快捷键 (Windows Terminal 是 Ctrl+Shift+V);
"        若在 tmux 里, 需要 ~/.tmux.conf 里 set -g set-clipboard on
"        (install.sh --with-tmux 可以帮你写这一行)。
if !has('clipboard') && executable('base64')
  function! s:Osc52Copy(text) abort
    if empty(a:text)
      return
    endif
    let s:b64 = substitute(system('base64 -w0', a:text), '\n', '', 'g')
    if empty(s:b64)
      return
    endif
    let s:seq = "\033]52;c;" . s:b64 . "\007"
    try
      " 直接写控制终端, 不经 stdout (OSC 序列会被终端吃掉, 不显示在屏幕上)
      call writefile([s:seq], '/dev/tty', 'b')
    catch
      echohl WarningMsg
      echomsg 'OSC52: 无法写入 /dev/tty (' . v:exception . ')'
      echohl None
    endtry
  endfunction

  function! s:Osc52CopyVisual() abort
    normal! gvy
    call s:Osc52Copy(getreg('"'))
  endfunction

  nnoremap <silent> <leader>y :call <SID>Osc52Copy(getreg('"'))<CR>
  xnoremap <silent> <leader>y :<C-u>call <SID>Osc52CopyVisual()<CR>
endif

"""""""""""""""""""""""""""""""""""""""
" 3. F5 编译/运行 —— Unix 版
"""""""""""""""""""""""""""""""""""""""
" 现有 extended.vim 里的 CompileRun() 输出 .exe、用 !start 调浏览器, 是 Windows
" 写法。本文件在它之后加载, 这里重新定义同名函数即可覆盖, 不动原文件。
if !has('win32') && !has('win64')
  function! CompileRun() abort
    write
    let s:f = expand('%')
    if &filetype ==# 'c' || &filetype ==# 'cpp'
      let s:cc = (&filetype ==# 'c') ? 'gcc' : 'g++'
      if !executable(s:cc)
        echo 'F5: 未找到 ' . s:cc
        return
      endif
      execute '!' . s:cc . ' "' . s:f . '" -o "' . expand('%<') . '" && "' . expand('%<') . '"'
    elseif &filetype ==# 'python'
      let s:py = executable('python3') ? 'python3' : 'python'
      execute '!' . s:py . ' "' . s:f . '"'
    elseif &filetype ==# 'sh'
      execute '!bash "' . s:f . '"'
    elseif &filetype ==# 'go'
      if !executable('go')
        echo 'F5: 未找到 go'
        return
      endif
      execute '!go run "' . s:f . '"'
    elseif &filetype ==# 'java'
      execute '!javac "' . s:f . '" && java -cp "' . expand('%:p:h') . '" ' . expand('%:t:r')
    elseif &filetype ==# 'html' || &filetype ==# 'markdown'
      if executable('xdg-open')
        execute '!xdg-open "' . s:f . '"'
      else
        echo 'F5: 这台机器上没有 xdg-open, 请在本地打开该文件'
      endif
    else
      echo 'F5: 暂不支持该文件类型 (支持 c/cpp/java/sh/python/html/go)'
    endif
  endfunction
endif

"""""""""""""""""""""""""""""""""""""""
" 4. 仓库内的运行时目录 (不再依赖 ~/.vim_runtime 这个硬编码路径)
"""""""""""""""""""""""""""""""""""""""
" 现有 extended.vim 写的是 undodir=~/.vim_runtime/temp_dirs/undodir,
" my_configs.vim 写的是 coc 数据目录 ~/.vim_runtime/coc。仓库布局下这两个
" 路径都不成立, 这里指向仓库内部, 于是无需在 $HOME 里造兼容软链。
if exists('+undodir')
  let s:undod = s:root . '/temp_dirs/undodir'
  if !isdirectory(s:undod)
    call mkdir(s:undod, 'p')
  endif
  let &undodir = s:undod
  set undofile
endif

if !empty(globpath(&runtimepath, 'autoload/coc/pum.vim'))
  let g:coc_data_home   = s:root . '/coc'
  let g:coc_config_home = s:root . '/coc'
endif

"""""""""""""""""""""""""""""""""""""""
" 5. Windows 上 :W 是个坑, 就地改成安全的强制写盘
"""""""""""""""""""""""""""""""""""""""
" basic.vim 里的 :W 是 `w !sudo tee % > /dev/null` 后面接 `edit!`。Windows 上
" 没有 sudo: 写盘必然失败, 但后面的 edit! 仍会从磁盘重载缓冲区 —— 未保存的
" 修改会静默丢失。在 Windows 上把它改成普通的强制写盘, 消除这个数据丢失风险。
if has('win32') || has('win64')
  command! W w!
endif

"""""""""""""""""""""""""""""""""""""""
" 6. 没有 coc 但 vim 够新时, 用原生边打边弹兜底
"""""""""""""""""""""""""""""""""""""""
" 'autocomplete' 是 Vim 9.2 新增; 服务器是 9.1 没有这个选项, 所以必须探测。
" 装了 coc 时不启用, 避免两套补全菜单打架。
if exists('&autocomplete') && empty(globpath(&runtimepath, 'autoload/coc/pum.vim'))
  set autocomplete
  if exists('&completepopup')
    set completeopt=menuone,noinsert,noselect,popup
  else
    set completeopt=menuone,noinsert,noselect
  endif
endif
