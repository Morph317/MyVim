#!/usr/bin/env bash
# ============================================================================
# MyVim 安装脚本 (幂等: 重复执行安全, 不会覆盖无关文件)
#
#   Linux 服务器:  git clone <repo> ~/.vim && ~/.vim/install.sh
#   带 coc:        ~/.vim/install.sh --with-coc
#   更新:          ~/.vim/install.sh --update
#   只检查:        ~/.vim/install.sh --verify
#
# 设计要点:
#   * 现有配置(5 个文件)逐字节入库, 平台差异全部由 plugin/zz_platform.vim 处理
#   * 插件按 pinned.tsv 克隆并固定到指定 commit, 因此安装结果可复现
#   * 任何要覆盖的已有文件都会先备份成 .bak-<时间戳>
# ============================================================================
set -euo pipefail

REPO_URL_DEFAULT="https://github.com/Morph317/MyVim.git"
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"

DO_PLUGINS=1
DO_COC=0
DO_TMUX=0
DO_LINK=1
DO_VERIFY=1
UPDATE=0
DRY=0

usage() {
  cat <<'EOF'
用法: install.sh [选项]

  --with-coc      额外安装 coc.nvim 的语言服务器扩展 (需要 node/npm)
  --with-tmux     若存在 tmux, 写入 ~/.tmux.conf 让 OSC52 剪贴板能透传
  --update        已存在的插件也执行 fetch + 切回 pinned commit
  --no-plugins    只装配置, 不装插件
  --no-link       不创建 ~/.vimrc 软链 (自己管理)
  --no-verify     跳过安装后的加载检查
  --dry-run       只打印将要做什么, 不落盘
  -h, --help      显示本帮助

安装后: 打开 vim 即生效。
  Linux 无 +clipboard 时, 用 "空格+y" 把内容通过 OSC52 送去本地终端剪贴板;
  反方向(本机 -> 服务器)请用终端自己的粘贴键 (Windows Terminal 是 Ctrl+Shift+V)。
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --with-coc)   DO_COC=1 ;;
    --with-tmux)  DO_TMUX=1 ;;
    --update)     UPDATE=1 ;;
    --no-plugins) DO_PLUGINS=0 ;;
    --no-link)    DO_LINK=0 ;;
    --no-verify)  DO_VERIFY=0 ;;
    --dry-run)    DRY=1 ;;
    -h|--help)    usage; exit 0 ;;
    *) echo "未知参数: $1" >&2; usage; exit 2 ;;
  esac
  shift
done

say()  { printf '%s\n' "$*"; }
step() { printf '\n== %s ==\n' "$*"; }
run()  { if [ "$DRY" = 1 ]; then say "  [dry-run] $*"; else "$@"; fi; }

backup_if_exists() {   # 把已存在的非本仓库文件挪走
  local f="$1"
  if [ -e "$f" ] || [ -L "$f" ]; then
    run mv "$f" "$f.bak-$STAMP"
    say "  已备份: $f -> $f.bak-$STAMP"
  fi
}

# ---------------------------------------------------------------- 0. 环境
step "0. 环境"
if ! command -v vim >/dev/null 2>&1; then
  say "!! 找不到 vim, 请先安装 (Ubuntu: sudo apt install vim)"
  exit 1
fi
say "  vim: $(vim --version | head -1)"
say "  特性: $(vim --version | tr ' ' '\n' | grep -E '^[+-](clipboard|xterm_clipboard|terminal|channel|job|timers|python3|eval)$' | tr '\n' ' ')"
say "  仓库: $ROOT"
[ -f "$ROOT/vimrc" ] || { say "!! $ROOT/vimrc 不存在, 这不像 MyVim 仓库"; exit 1; }
if command -v git >/dev/null 2>&1; then say "  git: $(git --version)"; else say "  !! 没有 git"; fi

# ---------------------------------------------------------------- 1. vimrc 软链
step "1. 链接 ~/.vimrc"
TARGET="$ROOT/vimrc"
if [ "$DO_LINK" = 1 ]; then
  if [ -L "$HOME/.vimrc" ] && [ "$(readlink -f "$HOME/.vimrc" 2>/dev/null || true)" = "$(readlink -f "$TARGET")" ]; then
    say "  已是正确软链, 跳过"
  else
    backup_if_exists "$HOME/.vimrc"
    run ln -sfn "$TARGET" "$HOME/.vimrc"
    say "  ~/.vimrc -> $TARGET"
  fi
else
  say "  --no-link, 跳过 (请自行保证 vim 能加载 $TARGET)"
fi

# ---------------------------------------------------------------- 2. 插件
step "2. 插件 (pinned.tsv)"
if [ "$DO_PLUGINS" = 1 ]; then
  if ! command -v git >/dev/null 2>&1; then
    say "  !! 没有 git, 跳过插件安装"
  else
    count_ok=0; count_skip=0; count_fail=0
    while IFS=$'\t' read -r name url sha dest ref; do
      case "$name" in ''|\#*) continue ;; esac
      [ -n "${dest:-}" ] || continue
      # 第 5 列是分支名 (留空 = 用远端默认分支); 顺手去掉可能的 CR 与空白
      ref="$(printf '%s' "${ref:-}" | tr -d '[:space:]')"
      target="$ROOT/$dest/$name"
      if [ -d "$target/.git" ]; then
        if [ "$UPDATE" = 1 ]; then
          say "  更新 $name -> ${sha:0:8}"
          run git -C "$target" fetch --quiet --all --tags || true
          run git -C "$target" checkout --quiet "$sha" && count_ok=$((count_ok+1)) || count_fail=$((count_fail+1))
        else
          count_skip=$((count_skip+1))
        fi
        continue
      fi
      if [ -e "$target" ]; then
        say "  !! $target 已存在但不是 git 仓库, 跳过 (请手工处理)"
        count_fail=$((count_fail+1)); continue
      fi
      say "  安装 $name @ ${sha:0:8}"
      clone_args=()
      [ -n "$ref" ] && clone_args=(--branch "$ref")
      if [ "$DRY" = 1 ]; then
        say "  [dry-run] git clone ${clone_args[*]} $url $target && git checkout $sha"
        count_ok=$((count_ok+1))
        continue
      fi
      if git clone --quiet ${clone_args[@]+"${clone_args[@]}"} "$url" "$target" 2>/dev/null && git -C "$target" checkout --quiet "$sha" 2>/dev/null; then
        count_ok=$((count_ok+1))
        # coc.nvim 只有 release 分支带编译产物; 走错分支会得到一个无法启动的 coc
        if [ "$name" = "coc.nvim" ] && [ ! -f "$target/build/index.js" ]; then
          say "  !! coc.nvim 里没有 build/index.js: pin 到的提交不在 release 分支上"
        fi
      else
        say "  !! $name 安装失败 (网络? commit 不存在?)"
        count_fail=$((count_fail+1))
      fi
    done < "$ROOT/pinned.tsv"
    say "  结果: 新装 $count_ok, 已存在跳过 $count_skip, 失败 $count_fail"
    [ "$count_fail" = 0 ] || say "  (有失败项: 网络不通时可以先手动 clone, 或稍后 --update 重试)"
  fi
else
  say "  --no-plugins, 跳过"
fi

# ---------------------------------------------------------------- 3. coc
step "3. coc.nvim (可选)"
if [ "$DO_COC" = 1 ]; then
  if [ ! -d "$ROOT/my_plugins/coc.nvim" ] && [ "$DRY" = 0 ]; then
    say "  !! coc.nvim 本体没装上 (见上一步), 跳过"
  elif ! command -v node >/dev/null 2>&1; then
    say "  !! 没有 node, 跳过。Ubuntu 上可: sudo apt install nodejs npm"
  else
    say "  node $(node -v) / npm $(command -v npm >/dev/null 2>&1 && npm -v || echo '缺失')"
    EXTDIR="$ROOT/coc/extensions"
    run mkdir -p "$EXTDIR"
    if [ ! -f "$EXTDIR/package.json" ] && [ "$DRY" = 0 ]; then
      printf '{"name":"coc-extensions","version":"1.0.0","private":true,"dependencies":{}}\n' > "$EXTDIR/package.json"
    fi
    # 去掉注释行与行内注释, 再拼成一行 (注意: 行内注释必须剥掉, 否则会被当成包名)
    PKGS="$(sed -e 's/#.*//' "$ROOT/coc-extensions.txt" | grep -vE '^[[:space:]]*$' | tr '\n' ' ')"
    say "  扩展: $PKGS"
    say "  (首次约 50-100MB, 装在 $EXTDIR, 已加入 .gitignore)"
    if [ "$DRY" = 1 ]; then
      say "  [dry-run] npm install --prefix $EXTDIR $PKGS"
    else
      # 与 coc 自身的安装参数保持一致
      npm install --prefix "$EXTDIR" --ignore-scripts --no-package-lock --no-audit --no-fund $PKGS \
        && say "  扩展安装完成" || say "  !! 扩展安装失败 (检查网络/npm 代理)"
    fi
  fi
else
  say "  未指定 --with-coc, 跳过 (需要时执行: $ROOT/install.sh --with-coc)"
fi

# ---------------------------------------------------------------- 4. tmux
step "4. tmux 剪贴板透传 (可选)"
if [ "$DO_TMUX" = 1 ]; then
  if ! command -v tmux >/dev/null 2>&1; then
    say "  没有 tmux, 跳过"
  else
    TMUXCONF="$HOME/.tmux.conf"
    if grep -qs 'set-clipboard' "$TMUXCONF" 2>/dev/null; then
      say "  $TMUXCONF 里已有 set-clipboard, 跳过"
    else
      if [ -f "$TMUXCONF" ] && [ "$DRY" = 0 ]; then
        cp "$TMUXCONF" "$TMUXCONF.bak-$STAMP"
        say "  已备份: $TMUXCONF -> $TMUXCONF.bak-$STAMP"
      fi
      if [ "$DRY" = 1 ]; then
        say "  [dry-run] 向 $TMUXCONF 追加 set -g set-clipboard on"
      else
        { echo ''; echo '# MyVim: 让 OSC52 剪贴板序列能透传到外层终端'; echo 'set -g set-clipboard on'; } >> "$TMUXCONF"
        say "  已写入 $TMUXCONF (如已有会话: tmux source-file ~/.tmux.conf)"
      fi
    fi
  fi
else
  say "  未指定 --with-tmux, 跳过"
fi

# ---------------------------------------------------------------- 5. 验证
step "5. 加载验证"
if [ "$DO_VERIFY" = 1 ]; then
  REPORT="$ROOT/temp_dirs/install-report.txt"
  mkdir -p "$ROOT/temp_dirs"
  CHECKER="$ROOT/temp_dirs/.install-check.vim"
  cat > "$CHECKER" <<'VIMEOF'
" 严格加载检查: 逐个 source, 捕获每个文件的第一处错误
" 仓库根由 install.sh 通过环境变量 MYVIM_ROOT 传入;
" 并先按 bootstrap 的做法把仓库加进 runtimepath, 否则 plugins_config.vim 里的
" pathogen#infect 会因为找不到 autoload/pathogen.vim 而假报 E117。
let s:root = $MYVIM_ROOT
execute 'set runtimepath+=' . fnameescape(s:root)
let mapleader = " "
let s:out = []
let s:files = ['vimrcs/basic.vim', 'vimrcs/filetypes.vim', 'vimrcs/plugins_config.vim', 'vimrcs/extended.vim', 'my_configs.vim']
let s:benign = 0
for s:f in s:files
  if !filereadable(s:root . '/' . s:f)
    call add(s:out, 'MISSING ' . s:f)
    continue
  endif
  try
    execute 'source ' . fnameescape(s:root . '/' . s:f)
    call add(s:out, 'OK      ' . s:f)
  catch
    " -clipboard 构建上的 E518 是已知且无害的(平台层会兜住), 单独标注
    if v:exception =~# 'E518' && v:exception =~? 'clipboard'
      call add(s:out, 'KNOWN   ' . s:f . ' -> ' . v:exception . '  (-clipboard 构建, 无害)')
      let s:benign += 1
    else
      call add(s:out, 'ERROR   ' . s:f . ' -> ' . v:exception)
    endif
  endtry
endfor
let s:plug = 0
for s:d in ['sources_non_forked', 'my_plugins']
  let s:plug += len(filter(globpath(s:root . '/' . s:d, '*', 0, 1), 'isdirectory(v:val)'))
endfor
call add(s:out, 'PLUGINS ' . s:plug . ' 个插件目录')
call add(s:out, 'COC     ' . (exists(':CocInstall') ? '已加载' : '未加载'))
call add(s:out, 'VIM     ' . v:versionlong . '  clipboard=' . has('clipboard'))
call writefile(s:out, s:root . '/temp_dirs/install-report.txt')
qa!
VIMEOF
  if [ "$DRY" = 1 ]; then
    say "  [dry-run] vim -Nu NONE -i NONE -es -S $CHECKER"
  else
    MYVIM_ROOT="$ROOT" vim -Nu NONE -i NONE -es -S "$CHECKER" >/dev/null 2>&1 || true
    if [ -f "$REPORT" ]; then
      while IFS= read -r line; do say "  $line"; done < "$REPORT"
      if grep -q '^ERROR' "$REPORT"; then
        say "  !! 有加载错误, 请把上面内容发给我"
      else
        say "  (KNOWN 是 -clipboard 构建的预期现象, 不影响功能)"
      fi
    else
      say "  !! 验证没产出报告, 请手工跑一次 vim 看报错"
    fi
    rm -f "$CHECKER"
  fi
else
  say "  --no-verify, 跳过"
fi

# ---------------------------------------------------------------- 6. 收尾
step "6. 完成"
say "  打开 vim 即生效。常用:"
say "    空格+e   编辑本配置(仓库里的 my_configs.vim)"
say "    空格+y   OSC52 复制到本地剪贴板 (仅无 +clipboard 时注册)"
say "    空格+j   模糊找文件 | 空格+nn 文件树 | 11/22 行首行尾 | Esc Esc 保存"
if [ "$DO_COC" = 1 ]; then
  say "    coc: 首次启动会拉起语言服务器; 用 :CocInfo 看状态, :CocList diagnostics 看诊断"
fi
say "  卸载: $ROOT/uninstall.sh  (加 --purge 连仓库和 coc 数据一起删)"
