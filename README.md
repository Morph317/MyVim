# MyVim

一套在 **Windows GVim** 与 **Linux 终端 vim** 之间共用的 Vim 配置,由 GitHub 同步,
一条命令装到服务器上。

## 设计原则

1. **现有配置一字不改**。`vimrcs/*.vim`、`my_configs.vim`、`colors/vscode_dark.vim`
   是从已经在用的部署里**逐字节拷贝**过来的(有 SHA256 校验)。所有平台差异都写在
   **新增的** `plugin/zz_platform.vim` 里 —— 它位于 rtp 的 `plugin/` 目录,Vim 启动时在
   vimrc 之后加载,天然是"最后生效的覆盖层"。
2. **插件不入库**。`pinned.tsv` 记录 21 个插件的仓库地址与**固定 commit**,由
   `install.sh` 克隆到 `sources_non_forked/`,加载仍走原有的 `pathogen#infect`。
3. **幂等**。`install.sh` 可以反复执行:已存在的插件默认跳过,要覆盖的既有文件先备份成
   `.bak-<时间戳>`,不碰任何无关文件。

## 目录结构

```
vimrc                  bootstrap: 设置 leader -> source 5 个现有配置文件
vimrcs/                现有配置 (原样: basic / filetypes / plugins_config / extended)
my_configs.vim         现有个性化配置 (原样)
colors/vscode_dark.vim 自写配色, VS Code Dark+ 风格 (原样)
plugin/zz_platform.vim 平台层 (新增): 剪贴板分支 / OSC52 / F5 Unix 版 / 运行时目录
autoload/pathogen.vim  插件加载器 (来自 amix/vimrc 分发, MIT)
pinned.tsv             插件清单: 名称 / 仓库 / 固定 commit / 安装位置 / 分支
coc-extensions.txt     coc 语言服务器扩展清单
install.sh             安装 (Linux)
uninstall.sh           卸载 (Linux)
install.ps1            Windows 侧可选脚本 (默认不做任何修改)
sources_non_forked/    插件 (克隆得到, 已 gitignore; peaksea 与 vim-irblack-forked 除外)
my_plugins/            coc.nvim 本体 (克隆得到, 已 gitignore)
coc/                   coc 运行数据与扩展, 约 100MB (已 gitignore)
temp_dirs/undodir/     持久撤销文件 (已 gitignore)
```

## 安装 (Linux 服务器)

```bash
git clone https://github.com/Morph317/MyVim.git ~/.vim
~/.vim/install.sh                 # 装配置 + 插件
~/.vim/install.sh --with-coc      # 再加 coc.nvim 的语言服务器
~/.vim/install.sh --with-tmux     # 同时在 tmux 里透传剪贴板
~/.vim/install.sh --verify        # 只做加载检查
~/.vim/install.sh --update        # 把已装插件切回 pinned.tsv 里的 commit
```

要求:`vim`(9.x)、`git`;`--with-coc` 需要 `node` + `npm`。
在 Ubuntu 上验证过的组合:vim 9.1、node v22、git 2.43。

## 已有的 Windows 环境不受影响

本仓库不改动现有的 `~/_vimrc` 与 `~/.vim_runtime`。想在这台机器上也用仓库版本,
只需用仓库里的 `vimrc` 启动:

```powershell
# 只检查 + 打印用法, 什么都不改
.\install.ps1

# 临时用仓库版本启动 gvim
& 'C:\Program Files\Vim\vim92\gvim.exe' -u 'C:\Users\14314\source\repos\MyVim\vimrc'

# 把插件也克隆进仓库 (之后仓库版就是完整的)
.\install.ps1 -InstallPlugins

# 让 Windows 正式改用仓库版本: 自动备份然后再建立
#   ~/_vimrc       -> 仓库 vimrc            (硬链接, 不需要管理员)
#   ~/.vim_runtime -> 仓库目录              (目录联接, 不需要管理员)
.\install.ps1 -InstallPlugins -TakeOver
```

`-TakeOver` 会先把你现有的 `~/_vimrc` 与 `~/.vim_runtime` 改名成 `.bak-<时间戳>`,
想回退把它们改回来即可。

## 跨平台差异都在平台层

| 差异点 | Windows | Linux |
|---|---|---|
| 剪贴板 | `clipboard=unnamed`(实测 9.2 上 `unnamedplus` 的 yank 不写剪贴板) | 有 `+clipboard` 时 `unnamedplus`;没有则该选项不存在,**不碰它**(否则 E518) |
| 复制到本机剪贴板 | 系统剪贴板直接可用 | 无 `+clipboard` 时用 **OSC 52**:`空格+y` |
| F5 编译运行 | 原 `extended.vim` 的 Windows 版(生成 `.exe`、`!start` 开浏览器) | 平台层重定义 `CompileRun()`:gcc/g++ 输出无后缀、`python3`、`xdg-open` |
| `:W` | `basic.vim` 里那版是 `w !sudo tee %` 后接 `edit!`,Windows 上写盘失败但仍会重载→**丢改动**;平台层改成安全的 `w!` | 保留原样(本来是 Unix 写法) |
| 撤销文件目录 | 沿用 `~/.vim_runtime/temp_dirs/undodir` | 平台层指向仓库内的 `temp_dirs/undodir` |
| 原生边打边弹 | Vim 9.2 + 没有 coc 时启用 `autocomplete` | 9.1 没有该选项;补全靠 coc 或 `<C-n>` |

### 为什么 bootstrap 用 `silent!` 而不是 `try/catch`

实测(而不是猜测):同一个源文件里只要有一处命令报错,

* `try` + `source`:**该文件从出错行起被整体跳过** —— 后面的 `11`/`22`、`Esc Esc`、
  coc 配置全部失效;
* `silent! source`:报错被吞掉,文件**继续执行到底**。

所以 5 个文件统一用 `silent!` 加载。真实错误不会被长期掩盖:`install.sh --verify`
会跑**两趟** —— 第一趟逐个文件严格 source 并报出错误,第二趟用真实 `vimrc` 启动
(插件真正加载)并报告生效的配色、选项与映射。

顺带纠正一个我一开始搞错的事实:Ubuntu 24.04 的 vim 虽然 `--version` 写着
`-clipboard`,但 `exists('&clipboard')=1`、`set clipboard=...` **不会**报错;
只是 `exists('+clipboard')=0` / `has('clipboard')=0`,即功能上拿不到系统剪贴板。
平台层的剪贴板分支用的正是 `exists('+clipboard')`,所以在服务器上会被正确跳过。

## 剪贴板:只能单向透传

服务器上的 vim 是 `-clipboard`,拿不到系统剪贴板。方案是 OSC 52:

* **服务器 → 本机**:`空格+y`(普通模式复制当前内容,可视模式复制选区)。要求本地终端
  支持并允许 OSC 52(Windows Terminal 支持)。
* **本机 → 服务器**:受终端安全策略限制,请用终端自己的粘贴键(Windows Terminal 是
  `Ctrl+Shift+V`)。
* **在 tmux 里**:需要 `set -g set-clipboard on`(用 `install.sh --with-tmux` 写入)。

## 终端光标:做成 gvim 那样的方块

终端里的 Vim 默认**不会**按 `guicursor` 去改光标形状 —— 实测(真实 pty,`TERM` 分别取
`xterm-256color` / `screen-256color` / `tmux-256color`)Ubuntu Vim 9.1 和 Windows
Vim 9.2 的 `t_SI` / `t_SR` / `t_EI` 全是空字符串,于是终端一直用它自己的默认形状
(Windows Terminal 的默认光标就是一根细竖条),看起来自然和 gvim 不一样。

所以 `my_configs.vim` 里显式写入 xterm 的 **DECSCUSR** 序列,形状与 gvim 的默认
`guicursor` 完全一致:

| 模式 | 序列 | 形状 |
|---|---|---|
| 普通 / 可视 | `\e[2 q` | 实心方块 |
| 插入 | `\e[6 q` | 竖条 |
| 替换 | `\e[4 q` | 下划线 |

另外给 `t_ti` / `t_te` 各追加一次:启动就摆成方块(不必先切一次模式),退出 vim 时把
终端原本的形状还原。gvim 不受影响 —— 它本来就是方块。

* 想**全程方块**(插入模式也要方块):`let g:myvim_always_block_cursor = 1`
* 想**关掉**这段(例如终端不支持该序列):`let g:myvim_cursor_shape = 0`

实测验证:在服务器真实入口(`~/.vimrc` 软链 → 仓库)的 pty 里捕获到了完整序列
`[2 q`(启动)→ `[6 q`(进插入)→ `[2 q`(回普通)→ `[0 q`(退出);tmux 3.4 会把该序列
透传给外层终端(捕获 ssh pty 实测),所以在 tmux 里同样有效。

## coc.nvim (可选)

```bash
~/.vim/install.sh --with-coc
```

扩展装在 `<仓库>/coc/extensions`,语言服务器**按需启动**,只有打开对应文件才拉起进程。
启动后用 `:CocInfo` 看状态、`:CocList diagnostics` 看诊断、`空格+dd` 看全部诊断。

> 说明:出现过"coc 本体起来了,但语言服务器没被拉起"的情况,根因是 npm 把 `pyright`
> 提升到了顶层,`coc-pyright` 目录里找不到 `langserver.index.js`。安装时加
> `--install-strategy=nested` 即可规避(两端的 `coc-pyright` 现在都已确认该文件存在)。
> 若仍无补全,用 `:CocInfo` / `:CocList extensions` 看扩展是否加载;另外 pyright 首次
> 索引要几十秒(2C2G 服务器实测约 26 秒),属正常现象。

## 快捷键速查

完整清单在 `my_configs.vim` 末尾。常用:

| 键 | 作用 |
|---|---|
| `空格+w` / `空格+e` | 保存 / 编辑本配置 |
| `空格+j` / `空格+b` / `空格+nn` / `空格+o` / `空格+f` | CtrlP 找文件 / 找缓冲 / NERDTree / 缓冲列表 / 最近文件 |
| `11` / `22` | 行首(第 1 列) / 行尾;`d11`、`y22` 等操作符模式同样可用 |
| `Esc Esc` | 保存(插入模式里连按两下) |
| `Esc` 两下之间的等待由 `timeoutlen=700` 决定 | 慢手速下 `11`/`22` 会被当成计数,`700` 是实测折中 |
| 终端光标 | 普通/可视=实心方块,插入=竖条(同 gvim);`g:myvim_always_block_cursor=1` 改全程方块 |
| `F5` | 编译/运行当前文件 |
| `gc` / `gcc` | 注释 (commentary) |
| `ys` / `cs` / `ds` | 环绕编辑 (surround) |
| `空格+y` | OSC52 复制到本机剪贴板(仅无 `+clipboard` 时注册) |
| `gd` / `gy` / `空格+i` / `空格+r` / `空格+rn` / `空格+a` / `空格+k` | coc:定义 / 类型定义 / 实现 / 引用 / 重命名 / 代码操作 / 悬浮文档 |

## 更新与卸载

```bash
~/.vim/install.sh --update    # 插件切回 pinned commit
git -C ~/.vim pull            # 配置本身更新
~/.vim/uninstall.sh           # 删掉 ~/.vimrc 软链
~/.vim/uninstall.sh --purge           # 再清插件与 coc 数据
~/.vim/uninstall.sh --purge --self    # 连仓库一起删
```

## 来源与许可

* `vimrcs/`、`my_configs.vim`、`autoload/pathogen.vim` 派生自
  [amix/vimrc](https://github.com/amix/vimrc)(MIT,© 2016 Amir Salihefendic),
  原始许可全文见 `LICENSE`。`autoload/pathogen.vim` 来自
  [tpope/vim-pathogen](https://github.com/tpope/vim-pathogen)(MIT)。
* 其余插件**不入库**,由 `install.sh` 从各自上游克隆,各自保留原许可。
  `sources_non_forked/peaksea` 与 `sources_non_forked/vim-irblack-forked` 是 amix
  仓库内自带的 fork,没有独立上游地址,因此随本仓库入库(共 3 个文件)。
* `pinned.tsv` 里的 commit 是生成本文件时的上游 HEAD。**注意**:现有插件目录是
  "去掉了 `.git` 的普通拷贝",原始版本无从考证,所以这是一条"可复现的基线",
  不保证与之前运行的版本逐字节相同;首次安装后建议实际用一遍验证。
