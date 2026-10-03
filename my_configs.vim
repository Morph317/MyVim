"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => 我的个性化配置 (根据问卷生成)
"    修改此文件后保存，GVim 会自动重新加载；
"    也可以在 GVim 中按 空格+e 直接编辑本文件
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" === 快捷键前缀: 空格 ===
let mapleader = " "

" === 行号: 绝对行号 ===
set number

" === 缩进: 4 空格 ===
set expandtab smarttab shiftwidth=4 tabstop=4

" === 深色主题: VS Code Dark+ 风格 (自写配色 vscode_dark) ===
set background=dark
try
  colorscheme vscode_dark
catch
  try
    colorscheme gruvbox
  catch
    colorscheme desert
  endtry
endtry

" === GVim 界面: 极简 (隐藏工具栏/菜单栏/滚动条) ===
if has("gui_running")
  set guioptions-=T   " 隐藏工具栏
  set guioptions-=m   " 隐藏菜单栏
  set guioptions-=rRlL " 隐藏滚动条
  set guioptions-=e   " 标签页使用原生样式
endif

" === GVim 深色标题栏 (Windows 11) ===
" 'go-d' 让标题栏+菜单栏走系统深色变体;
" 'go-C' 则改用下面两个高亮组自绘标题栏, 用来精确匹配 vscode_dark 的底色。
" 想恢复系统默认标题栏配色: :set guioptions-=C  或把两组设为 NONE
" 想关掉深色变体:           :set guioptions-=d
if has("gui_running")
  set guioptions+=d
  set guioptions+=C

  " 换配色方案后要重新套用, 否则会被 colorscheme 清掉
  augroup MyWinTitleBar
    autocmd!
    autocmd ColorScheme * hi TitleBar   guibg=#1E1E1E guifg=#D4D4D4 gui=NONE
    autocmd ColorScheme * hi TitleBarNC guibg=#232323 guifg=#858585 gui=NONE
  augroup END

  hi TitleBar   guibg=#1E1E1E guifg=#D4D4D4 gui=NONE   " 活动窗口标题栏
  hi TitleBarNC guibg=#232323 guifg=#858585 gui=NONE   " 非活动窗口标题栏
endif

" === y / p 自动使用系统剪贴板 ===
" 用 clipboard 选项实现，而不是映射 y/p：
"   若写成 nnoremap y "+y，那 y 就变成一个"单次动作"，
"   yy / yiw / y$ / 3yy / yap 等所有组合都会失效。
"
" 为什么是 unnamed 而不是 unnamedplus (实测结论, 2025):
"   本机 Vim 9.2 (MS-Windows, vim64.dll) 在 clipboard=unnamedplus 时,
"   yank 类操作不会写系统剪贴板 —— yy 之后 "+ 寄存器里仍是旧内容,
"   而 dd / x / c 和显式的 "+yy 都正常。用 gvim --clean 最小环境同样复现,
"   所以和 amix 配置、yankstack 插件都无关, 是 Vim 自身的问题。
"   改用 clipboard=unnamed 后: yy / dd / x / 可视模式复制 / p /
"   "+p / "*p / 插入模式 <C-r>+ 全部实测正常。
"   Windows 上 "*" 与 "+" 指向同一个系统剪贴板, 功能上完全等价。
set clipboard=unnamed

" === Windows 便利 ===
set showtabline=2                " 总是显示标签栏

" === 解决 leader=空格 与 空格=搜索 的冲突 ===
" basic.vim 默认把空格映射为搜索，这里取消它，
" 让空格专心作为 leader 前缀使用
silent! unmap <Space>

" === 快速跳转行首 / 行尾 ===
"   11 = 跳转行首      22 = 跳转行尾
" 注: amix 的 basic.vim 已把 0 键重映射为 ^ (首个非空白字符)，
"     所以这里用 11 补回"真正的第 1 列"。
"     若你想要的"行首"是"缩进之后的第一个字符"，把下面的 0 改成 ^ 即可。
"     顺带: 操作符模式下也能用 —— d11 删除到行首, d22/y22 到行尾。
" 注意: 映射命令后面不能写行内注释(!)，因为 " 会被当成映射内容的一部分，
"       所以下面所有说明都写在单独的行上。
nnoremap 11 0
xnoremap 11 0
onoremap 11 0
nnoremap 22 $
xnoremap 22 $
onoremap 22 $

" === 连击两下 Esc 保存文件 ===
" 用法: 插入模式里连按两下 Esc (第一下退出插入模式, 第二下保存)。
"   只有当文件确实被修改过才写入, 不会每次都刷磁盘。
"   无名缓冲 (如 NERDTree 列表) 或只读缓冲会自动跳过, 不报错。
function! s:SaveFile() abort
  if &buftype !=# '' || !&modifiable || expand('%') ==# ''
    return
  endif
  silent! update
endfunction

" 注意: 为了让 Esc 只在"真的想连击"时才等待, 把 timeoutlen 由默认 1000ms 调短。
"       副作用: 空格开头的组合键 (空格+w 等) 和 11/22 也要在 300ms 内按完。
"       觉得太快就把下面的 300 改成 500 或 700。
set timeoutlen=300
nnoremap <silent> <Esc><Esc> :<C-u>call <SID>SaveFile()<CR>
inoremap <silent> <Esc><Esc> <Esc>:<C-u>call <SID>SaveFile()<CR>
vnoremap <silent> <Esc><Esc> <Esc>:<C-u>call <SID>SaveFile()<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => coc.nvim (LSP: 智能补全 / 实时诊断 / 跳转 / 重命名)
"    插件本体: ~/.vim_runtime/my_plugins/coc.nvim (release 分支, 免编译)
"    数据与配置都收在 .vim_runtime 下, 方便整体卸载或搬迁:
"      ~/.vim_runtime/coc/extensions        <- 各语言服务器扩展
"      ~/.vim_runtime/coc/coc-settings.json <- :CocConfig 打开的设置
"    卸载: 删掉 my_plugins/coc.nvim 和 .vim_runtime/coc 即可
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 用 globpath 判断插件是否还在, 删掉插件后本段自动失效, 不会报 E117
if !empty(globpath(&runtimepath, 'autoload/coc/pum.vim'))
  let g:coc_data_home   = expand('~/.vim_runtime/coc')
  let g:coc_config_home = expand('~/.vim_runtime/coc')

  " coc 靠 CursorHold 刷新诊断, 默认 updatetime=4000 太慢
  set updatetime=300
  set signcolumn=yes    " 固定符号列, 诊断图标不挤动文本
  set shortmess+=c      " 补全时不再刷 "match x of y" 消息

  " Tab / S-Tab: 补全菜单可见时在候选间移动, 否则保持原义
  inoremap <silent><expr> <Tab>   coc#pum#visible() ? coc#pum#next(1) : "\<Tab>"
  inoremap <silent><expr> <S-Tab> coc#pum#visible() ? coc#pum#prev(1) : "\<S-Tab>"
  " 回车: 菜单可见时确认选中项, 否则正常换行 (和 VS Code 一致)
  " 注意: auto-pairs 默认也会接管 <CR>(在括号间自动多缩进一行),
  "       两者会打架 —— 这里让 <CR> 归 coc, 括号补全本身不受影响。
  "       想要回 auto-pairs 的智能回车: 把下面这行改成 =1, 并删掉 <CR> 映射,
  "       然后用 <C-y>(coc 自带) 或 Tab 来确认候选。
  let g:AutoPairsMapCR = 0
  inoremap <silent><expr> <CR>    coc#pum#visible() ? coc#pum#confirm() : "\<CR>"

  " 跳转 / 重构 / 诊断
  " 注: gd 覆盖了 Vim 内建的"跳转本文件声明"; 内建那个依赖 ctags,
  "     而机器上没装 ctags, 所以覆盖没有实际损失。
  "     gi(上次插入位置)、gr(虚拟替换)、K(:help) 都故意保留了内建含义。
  nmap <silent> gd <Plug>(coc-definition)
  nmap <silent> gy <Plug>(coc-type-definition)
  nmap <silent> <leader>i  <Plug>(coc-implementation)
  nmap <silent> <leader>r  <Plug>(coc-references)
  nmap <silent> <leader>rn <Plug>(coc-rename)
  nmap <silent> <leader>a  <Plug>(coc-codeaction-cursor)
  nmap <silent> <leader>k  :call CocActionAsync('doHover')<CR>
  nmap <silent> [g <Plug>(coc-diagnostic-prev)
  nmap <silent> ]g <Plug>(coc-diagnostic-next)
  nmap <silent> <leader>dd :CocList diagnostics<CR>
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => 常用快捷键速查 (leader 键 = 空格)
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 文件:     空格+w 保存 | 空格+e 编辑本配置 | 空格+q 速记缓冲 | 空格+x markdown 速记
" 搜索:     / ? 查找 | 空格+回车 清除高亮 | 空格+ss 拼写检查
" 窗口:     Ctrl+h/j/k/l 窗口间移动 | 空格+tn 新标签 | 空格+tl 切换标签
" 缓冲区:   空格+o 缓冲区列表 | 空格+bd 关闭缓冲 | 空格+ba 关闭全部
" 插件:
"   空格+nn   NERDTree 文件树开关
"   空格+j    CtrlP 模糊查找文件
"   空格+b    CtrlP 查找缓冲区
"   空格+f    最近打开的文件 (MRU)
"   空格+v    复制当前行 GitHub 链接 (:GBrowse, fugitive)
"   空格+d    开关 Git 改动标记 (gitgutter)
"   :Git      打开 Git 状态窗口 (新版 fugitive，旧 :Gstatus 已废弃)
"   gc / gcc  注释/取消注释 (commentary)
"   ys/cs/ds  环绕编辑 (surround)
"   v         扩展选区，连续按 v 扩大 (expand-region)
"   F5        编译运行当前文件 (C/C++/Java/Python/Shell/HTML/Go)
" 编辑:     Esc Esc 连击两下 = 保存 (插入模式里连按两下即可)
" 跳转:     11 行首 (第1列) | 22 行尾 | 0 首个非空白字符 | $ 行尾
"           带操作符也能用: d11 删到行首, y22 复制到行尾
" 其他:     ,m 去行尾空格 | 空格+pp 粘贴模式
