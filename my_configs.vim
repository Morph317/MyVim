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

" === 终端光标形状: 做成 gvim 那样的方块 ===
" 症状: 在终端里跑 vim (例如 Windows Terminal 里 SSH 上服务器), 普通模式的光标
"       是一根细竖条, 和 gvim 的实心方块不一样。
" 原因(实测, 2025):
"   Vim 并不会按 'guicursor' 自动给终端发送光标形状 ——
"   本机 Windows Vim 9.2 与服务器 Ubuntu Vim 9.1 的 t_SI / t_SR / t_EI
"   全都是空字符串(在真实 pty 里用 TERM=xterm-256color / screen-256color 均如此),
"   于是终端一直用它自己的默认形状: Windows Terminal 的默认光标就是竖条。
" 办法: 用 xterm 的 DECSCUSR 转义序列显式指定各模式的形状, 与 gvim 的默认完全一致:
"       普通/可视 = 实心方块    插入 = 竖条    替换 = 下划线
" 只在终端里生效 (gvim 本来就是方块, 不碰它); 退出 vim 会把终端原本的形状还原。
" tmux 3.x 会把该序列透传给它外面的终端(已在服务器 tmux 3.4 上实测捕获到), 所以
" 在 tmux 里同样有效。
" 想全程都是方块(插入模式也要方块): 在 vimrc 里加一行
"   let g:myvim_always_block_cursor = 1
" 想彻底关掉这一段: 在 vimrc 里加一行
"   let g:myvim_cursor_shape = 0
if get(g:, 'myvim_cursor_shape', 1) && exists('&t_SI') && !has('gui_running')
      \ && &term =~# 'xterm\|screen\|tmux\|rxvt\|st-\|alacritty\|foot\|win32\|cygwin\|msys'
  let s:cur_block = "\e[2 q"   " 稳定方块
  let s:cur_bar   = "\e[6 q"   " 稳定竖条
  let s:cur_line  = "\e[4 q"   " 稳定下划线
  if get(g:, 'myvim_always_block_cursor', 0)
    let s:cur_bar  = s:cur_block
    let s:cur_line = s:cur_block
  endif
  let &t_EI = s:cur_block      " 普通/可视模式
  let &t_SI = s:cur_bar        " 插入模式
  let &t_SR = s:cur_line       " 替换模式
  let &t_ti ..= s:cur_block    " 启动就摆成方块, 不必先切一次模式
  let &t_te ..= "\e[0 q"       " 退出 vim 时还原终端原本的形状
endif

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

" === 连击两下 Esc 保存文件 (等价于 :w) ===
" 用法: 插入模式里连按两下 Esc —— 第一下退出插入模式, 第二下写盘;
"       普通模式 / 可视模式里连按两下 Esc 同样有效; 只按一下不会写。
"   没有改动、无名缓冲 (如 NERDTree 列表)、只读缓冲会自动跳过, 不报错。
"
" 【为什么不能写成 inoremap <Esc><Esc> —— 实测踩过的坑, 2025】
"   终端里方向键发过来的是 ESC 开头的序列 (\eOA / \e[A)。先按 Esc 退出插入模式,
"   紧接着按方向键, 字节流就是  \e + \eOA  —— 头两个字节恰好凑成 <Esc><Esc>,
"   于是 Vim 把"退出插入模式 + 方向键"错当成"连击两下 Esc": 文件被静默写盘(误触!),
"   剩下的 OA 继续在普通模式里执行 —— O 在当前行上方开一行、A 进入插入模式并插入字母 A。
"   四个方向键分别对应 A/B/C/D, 这就是"Esc 加方向键会蹦出 ABCD"的真正原因。
"   实测复现(服务器, 真实入口): iXYZ [Esc] [Up] → 缓冲区多出一行 "A",
"   而且文件在完全没执行 :w 的情况下被写到了磁盘上。
" 【现在的做法】
"   插入模式不再占用 Esc(退出插入模式零延迟、也不参与映射);
"   普通模式的 Esc 交给一个 0.7 秒的连击判定: "刚退出插入模式/可视模式" 或
"   "刚按过一下 Esc" 都会把下一次 Esc 当成第二下来写盘。
"   方向键是完整的终端序列, 会被正常识别成 <Up> 等按键, 不再和映射撞车。
let s:esc_window   = 0.7        " 两下 Esc 的最大间隔(秒), 与下面 timeoutlen=700 对齐
let s:esc_armed_at = []         " 刚退出插入/可视模式的时间 (reltime)
let s:esc_last_at  = []         " 普通模式里上一次按 Esc 的时间

function! s:EscWrite() abort
  if &buftype !=# '' || !&modifiable || expand('%') ==# '' || !&modified
    return
  endif
  silent! write
endfunction

function! s:EscArm() abort
  let s:esc_armed_at = reltime()
endfunction

function! s:EscSave() abort
  if !empty(s:esc_armed_at) && reltimefloat(reltime(s:esc_armed_at)) < s:esc_window
    let s:esc_armed_at = []
    let s:esc_last_at = []
    call s:EscWrite()
  elseif !empty(s:esc_last_at) && reltimefloat(reltime(s:esc_last_at)) < s:esc_window
    let s:esc_last_at = []
    call s:EscWrite()
  else
    let s:esc_last_at = reltime()
  endif
endfunction

augroup MyEscSave
  autocmd!
  autocmd InsertLeave * call s:EscArm()
augroup END

" 注意: timeoutlen 决定"一个键按下去后还能等多久, 去凑成一个多键映射"。
"   太短: 多键映射会散架 —— 实测 300ms 时, "11"(行首)只要两个 1 相隔超过 300ms,
"         就会被当成"计数 11", 于是 11j 变成向下 11 行 (服务器上走 SSH 时必踩)。
"   太长: 按了空格 leader 之后停顿过久, 空格会被当成普通空格 (右移一格)。
"   700ms 是折中: 实测 0.5 秒/键的慢节奏下 11/22 仍然有效, leader 与连击 Esc 手感尚可。
"   参考: 插入模式按 Esc 的延迟与 timeoutlen 无关 (300/1000 实测均为 1ms),
"         所以调大它不会让"连击 Esc 保存"变卡。
set timeoutlen=700
nnoremap <silent> <Esc> :<C-u>call <SID>EscSave()<CR>
vnoremap <silent> <Esc> <Esc>:<C-u>call <SID>EscArm()<CR>

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
" 编辑:     连按两下 Esc = 保存 (:w), 插入/普通/可视模式都行; 单按一下不会写
" 跳转:     11 行首 (第1列) | 22 行尾 | 0 首个非空白字符 | $ 行尾
"           带操作符也能用: d11 删到行首, y22 复制到行尾
" 其他:     ,m 去行尾空格 | 空格+pp 粘贴模式
" 光标:     终端里也是 gvim 样式 —— 普通/可视=实心方块, 插入=竖条, 替换=下划线
"           想全程方块: let g:myvim_always_block_cursor = 1
"           想关掉:     let g:myvim_cursor_shape = 0
