"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" MyVim — 跨平台 bootstrap
"   Windows GVim 与 Linux 终端 vim 共用同一份仓库
"   仓库根 = 本文件所在目录 (Linux 上通常就是 ~/.vim)
"
"   加载顺序:
"     本文件 -> vimrcs/basic.vim -> filetypes.vim -> plugins_config.vim
"            -> extended.vim -> my_configs.vim   (以上均为原样未改动的现有配置)
"            -> plugin/*.vim 由 Vim 自动加载 (所有平台差异都在那里)
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set nocompatible

let s:root = expand('<sfile>:p:h')

" 把仓库根加入 runtimepath。
" Windows 上 vim 默认不看 ~/.vim, 必须显式加;
" Linux 上 ~/.vim 已在 rtp 中, 所以要先做"规范化路径去重" ——
" rtp 里出现重复条目会让 plugin/ 下的脚本被加载两次。
let s:already = 0
for s:p in split(&runtimepath, ',')
  if fnamemodify(expand(s:p), ':p') ==# fnamemodify(s:root, ':p')
    let s:already = 1
  endif
endfor
if !s:already
  execute 'set runtimepath+=' . fnameescape(s:root)
endif

" leader 必须在 basic.vim 之前设置: 映射在"定义的那一刻"就解析 leader
let mapleader = " "

" —— 现有配置, 逐字节原样加载 ——
"
" 为什么用 silent! 而不是 try/catch (这一点很重要, 是实测结论):
"   Linux 的 vim 往往是 -clipboard 构建, 那种构建里 'clipboard' 选项根本不存在,
"   my_configs.vim 中的 set clipboard=... 会抛 E518。实测行为:
"     try/catch  : 该文件从出错行起被整体跳过 —— 后面的 11/22、Esc-Esc、coc 配置全部失效
"     silent!    : 报错被吞掉, 但文件继续执行到底
"   所以这里用 silent!。真实错误由 `install.sh --verify` 的严格检查兜住, 不会被掩盖。
execute 'silent! source ' . fnameescape(s:root . '/vimrcs/basic.vim')
execute 'silent! source ' . fnameescape(s:root . '/vimrcs/filetypes.vim')
execute 'silent! source ' . fnameescape(s:root . '/vimrcs/plugins_config.vim')
execute 'silent! source ' . fnameescape(s:root . '/vimrcs/extended.vim')
execute 'silent! source ' . fnameescape(s:root . '/my_configs.vim')
