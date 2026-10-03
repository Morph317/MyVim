#!/usr/bin/env bash
# ============================================================================
# MyVim 卸载脚本 —— 只动自己创建的东西
#
#   ./uninstall.sh            删掉 ~/.vimrc 软链 (若指向本仓库)
#   ./uninstall.sh --purge    再删掉 coc 运行数据、插件目录
#   ./uninstall.sh --purge --self  连仓库目录本身一起删
# ============================================================================
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PURGE=0
SELF=0
DRY=0

while [ $# -gt 0 ]; do
  case "$1" in
    --purge) PURGE=1 ;;
    --self)  SELF=1 ;;
    --dry-run) DRY=1 ;;
    -h|--help)
      sed -n '2,12p' "${BASH_SOURCE[0]}"
      exit 0 ;;
    *) echo "未知参数: $1" >&2; exit 2 ;;
  esac
  shift
done

say() { printf '%s\n' "$*"; }
run() { if [ "$DRY" = 1 ]; then say "  [dry-run] $*"; else "$@"; fi; }

say "== 1. 移除 ~/.vimrc =="
if [ -L "$HOME/.vimrc" ]; then
  if [ "$(readlink -f "$HOME/.vimrc" 2>/dev/null || true)" = "$(readlink -f "$ROOT/vimrc")" ]; then
    run rm -f "$HOME/.vimrc"; say "  已删除软链 ~/.vimrc"
  else
    say "  ~/.vimrc 指向别处, 不动它"
  fi
elif [ -e "$HOME/.vimrc" ]; then
  say "  ~/.vimrc 是普通文件(不是本仓库的软链), 不动它"
else
  say "  ~/.vimrc 不存在"
fi

if [ "$PURGE" = 1 ]; then
  say "== 2. 清理插件与 coc 数据 =="
  for d in "$ROOT/sources_non_forked" "$ROOT/my_plugins" "$ROOT/coc"; do
    [ -d "$d" ] || continue
    say "  删除 $d 的内容"
    run find "$d" -mindepth 1 -maxdepth 1 ! -name '.gitkeep' -exec rm -rf {} +
  done
fi

if [ "$SELF" = 1 ]; then
  say "== 3. 删除仓库目录 =="
  say "  $ROOT"
  if [ "$DRY" = 1 ]; then say "  [dry-run] rm -rf $ROOT"; else
    cd "$HOME" && rm -rf "$ROOT"
    say "  已删除 (当前 shell 所在目录可能已失效)"
  fi
fi

say ""
say "完成。备份文件 (若有) 形如 ~/.vimrc.bak-<时间戳>, 需要的话自行清理。"
