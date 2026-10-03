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
" 为什么用 silent! 而不是 try/catch (实测结论, 不是猜测):
"   实测: 一个源文件里只要有一处命令报错,
"     try/catch : 该文件从出错行起被整体跳过 —— 后面的映射与配置全部失效
"     silent!   : 报错被吞掉, 文件继续执行到底
"   容易踩的例子是 'clipboard' 这样可能被裁掉的选项。顺带纠正一个常见误解:
"   Ubuntu 24.04 的 vim 虽然 --version 显示 -clipboard, 但 exists('&clipboard')=1、
"   set clipboard=... 并不报错(只是功能上 has('clipboard')=0, 拿不到系统剪贴板)。
"   所以这里对 5 个文件统一用 silent! 兜底; 真实错误由 `install.sh --verify`
"   的严格检查暴露, 不会被长期掩盖。
execute 'silent! source ' . fnameescape(s:root . '/vimrcs/basic.vim')
execute 'silent! source ' . fnameescape(s:root . '/vimrcs/filetypes.vim')
execute 'silent! source ' . fnameescape(s:root . '/vimrcs/plugins_config.vim')
execute 'silent! source ' . fnameescape(s:root . '/vimrcs/extended.vim')
execute 'silent! source ' . fnameescape(s:root . '/my_configs.vim')

" —— coc.nvim 的数据目录必须在这里定, 不能放到 plugin/zz_platform.vim ——
"
" 实测结论: pathogen#infect 是把插件目录**前插**到 runtimepath 的, 所以在服务器上
" runtimepath 的第 1 项就是 my_plugins/coc.nvim, 而仓库根(plugin/zz_platform.vim 所在)
" 排在后面。结果是 coc 的 plugin/coc.vim 先加载、先读走 g:coc_data_home, 那时
" my_configs.vim 里写的还是旧路径 ~/.vim_runtime/coc, 于是 coc 跑去那个(不存在的)
" 目录找扩展 —— 表现为 coc 服务能起、但 :CocList extensions 是 "No results",
" 所有语言服务器都不启动。
"
" 写在 vimrc 里就万无一失: vimrc 一定在任何 plugin/ 脚本之前执行完。
" 注意必须放在 source my_configs.vim 之后, 否则会被它覆盖。
if !empty(globpath(&runtimepath, 'autoload/coc/pum.vim'))
  let g:coc_data_home   = s:root . '/coc'
  let g:coc_config_home = s:root . '/coc'
endif
