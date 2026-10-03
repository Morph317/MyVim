# ============================================================================
# MyVim 的 Windows 侧可选脚本
#
# 默认什么都不会改: 只做检查 + 打印"如何用仓库版本启动 gvim"的命令。
# 现有 ~/_vimrc 与 ~/.vim_runtime 完全不受影响。
#
#   .\install.ps1                 只检查并打印用法
#   .\install.ps1 -InstallPlugins 把插件按 pinned.tsv 克隆进仓库 (需要 git)
#   .\install.ps1 -TakeOver       让 Windows 也改用仓库版本:
#                                 备份 ~/_vimrc 与 ~/.vim_runtime, 再建立
#                                 ~/_vimrc 硬链接 + ~/.vim_runtime 目录联接
#                                 (两者都不需要管理员权限; 会自动先备份)
# ============================================================================
[CmdletBinding()]
param(
  [switch]$InstallPlugins,
  [switch]$TakeOver,
  [switch]$VerifyOnly
)

$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$Git  = 'C:\Program Files\Git\cmd\git.exe'
if (-not (Test-Path $Git)) { $Git = 'git' }

function Say([string]$m) { Write-Host $m }

$VimExe = $null
foreach ($c in @("$env:ProgramFiles\Vim\vim92\gvim.exe", "$env:ProgramFiles\Vim\vim92\vim.exe", "$env:ProgramFiles\Vim\vim91\gvim.exe")) {
  if (Test-Path $c) { $VimExe = $c; break }
}
if (-not $VimExe) {
  $cmd = Get-Command gvim.exe -ErrorAction SilentlyContinue
  if ($cmd) { $VimExe = $cmd.Source }
}

Say "== 0. 环境 =="
Say "  仓库: $Root"
if (-not (Test-Path "$Root\vimrc")) { throw "$Root\vimrc 不存在, 这不像 MyVim 仓库" }
if ($VimExe) { Say "  vim : $VimExe"; Say "  版本: $(& $VimExe --version | Select-Object -First 1)" }
else { Say "  !! 没找到 gvim.exe / vim.exe" }
Say "  git : $(& $Git --version 2>&1)"

if ($InstallPlugins) {
  Say ""
  Say "== 1. 安装插件 (pinned.tsv) =="
  $ok = 0; $skip = 0; $fail = 0
  foreach ($line in Get-Content "$Root\pinned.tsv") {
    if ($line -match '^\s*#') { continue }
    $parts = $line -split "`t"
    if ($parts.Count -lt 4) { continue }
    $name, $url, $sha, $dest = $parts[0..3]
    $target = Join-Path $Root (Join-Path $dest $name)
    if (Test-Path (Join-Path $target '.git')) { $skip++; continue }
    if (Test-Path $target) { Say "  !! $target 已存在且不是 git 仓库, 跳过"; $fail++; continue }
    Say "  安装 $name @ $($sha.Substring(0,8))"
    & $Git clone --quiet $url $target 2>$null
    if ($LASTEXITCODE -eq 0) { & $Git -C $target checkout --quiet $sha 2>$null }
    if ($LASTEXITCODE -eq 0) { $ok++ } else { Say "  !! $name 失败"; $fail++ }
  }
  Say "  结果: 新装 $ok, 已存在跳过 $skip, 失败 $fail"
}

if ($TakeOver) {
  Say ""
  Say "== 2. 接管 Windows 侧 (会先备份) =="
  $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
  $existing = Join-Path $env:USERPROFILE '.vim_runtime'
  if (Test-Path $existing) {
    if ((Get-Item $existing).LinkType) { Say "  ~/.vim_runtime 已经是链接, 跳过" }
    else {
      Rename-Item $existing "$existing.bak-$stamp"
      Say "  已备份: ~/.vim_runtime -> .vim_runtime.bak-$stamp"
      cmd /c mklink /J "$existing" "$Root" | Out-Null
      Say "  已建立目录联接: ~/.vim_runtime -> $Root"
    }
  } else {
    cmd /c mklink /J "$existing" "$Root" | Out-Null
    Say "  已建立目录联接: ~/.vim_runtime -> $Root"
  }
  $vimrc = Join-Path $env:USERPROFILE '_vimrc'
  if (Test-Path $vimrc) {
    $isLink = [bool](Get-Item $vimrc).LinkType
    if ($isLink) { Say "  ~/_vimrc 已经是链接, 跳过" }
    else {
      Rename-Item $vimrc "$vimrc.bak-$stamp"
      Say "  已备份: ~/_vimrc -> _vimrc.bak-$stamp"
      cmd /c mklink /H "$vimrc" "$Root\vimrc" | Out-Null
      Say "  已建立硬链接: ~/_vimrc -> $Root\vimrc"
    }
  } else {
    cmd /c mklink /H "$vimrc" "$Root\vimrc" | Out-Null
    Say "  已建立硬链接: ~/_vimrc -> $Root\vimrc"
  }
  Say "  提示: 硬链接下 :e `$MYVIMRC 编辑的就是仓库里的 vimrc, 改完直接 git commit"
}

if (-not $InstallPlugins -and -not $TakeOver) {
  Say ""
  Say "== 没有做任何修改 (默认安全模式) =="
  Say "  想临时用仓库版本启动:"
  Say "    & '$VimExe' -u '$Root\vimrc'"
  Say "  想装插件:      .\install.ps1 -InstallPlugins"
  Say "  想让 Windows 也改用仓库: .\install.ps1 -InstallPlugins -TakeOver"
}

Say ""
Say "== 3. 加载验证 =="
if ($VimExe) {
  $probe = Join-Path $env:TEMP 'myvim-verify.vim'
  $out   = Join-Path $env:TEMP 'myvim-verify.txt'
  $lines = @(
    'let g:o = []',
    'call add(g:o, ''rtp_ok='' . (stridx(&runtimepath, ''MyVim'') >= 0))',
    'call add(g:o, ''leader=['' . get(g:, ''mapleader'', ''?'') . '']'')',
    'call add(g:o, ''colors_name='' . get(g:, ''colors_name'', ''?''))',
    'call add(g:o, ''map11=['' . maparg(''11'', ''n'') . ''] map22=['' . maparg(''22'', ''n'') . '']'')',
    'call add(g:o, ''undodir='' . &undodir)',
    'let g:n = 0',
    'for g:p in globpath(&runtimepath, ''plugin/*.vim'', 0, 1)',
    '  if stridx(g:p, ''sources_non_forked'') >= 0 || stridx(g:p, ''my_plugins'') >= 0 | let g:n += 1 | endif',
    'endfor',
    'call add(g:o, ''plugins='' . g:n)',
    'call writefile(g:o, ''__OUT__'')',
    'qa!'
  )
  $lines = $lines | ForEach-Object { $_ -replace '__OUT__', ($out -replace '\\','/') }
  Set-Content -Path $probe -Value ($lines -join "`n") -Encoding ASCII
  & $VimExe -V1"$env:TEMP\myvim-verify.log" -u "$Root\vimrc" -es -S $probe 2>$null
  if (Test-Path $out) { Get-Content $out | ForEach-Object { Say "  $_" } }
  $errs = Select-String -Path "$env:TEMP\myvim-verify.log" -Pattern 'E\d{3}' -ErrorAction SilentlyContinue
  if ($errs) { Say "  --- 日志中的错误 ---"; $errs | ForEach-Object { Say "  $($_.Line)" } }
  else { Say "  (日志无 E 错误)" }
}
