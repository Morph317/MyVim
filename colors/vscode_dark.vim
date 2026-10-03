" ============================================================================
" vscode_dark.vim  --  VS Code "Default Dark+" 风格配色
" ----------------------------------------------------------------------------
" 依据 VS Code 内置主题 Dark+ 的 TextMate 配色规范编写：
"   背景 #1E1E1E / 前景 #D4D4D4 / 注释 #6A9955 / 关键字 #569CD6
"   控制流 #C586C0 / 字符串 #CE9178 / 数字 #B5CEA8 / 函数 #DCDCAA
"   类型 #4EC9B0 / 变量 #9CDCFE / 选区 #264F78 / 当前行 #2A2D2E
" 使用:  :colorscheme vscode_dark
" ============================================================================

let s:save_cpo = &cpo
set cpo&vim

hi clear
if exists('syntax_on')
  syntax reset
endif
let g:colors_name = 'vscode_dark'
set background=dark

" ---- VS Code Dark+ 调色板 ----
let s:bg        = '#1E1E1E'   " 编辑器背景        (cterm 234)
let s:bg_alt    = '#252526'   " 侧栏/标签栏背景    (cterm 235)
let s:bg_panel  = '#333333'   " 建议框/输入框背景  (cterm 236)
let s:fg        = '#D4D4D4'   " 默认前景           (cterm 252)
let s:comment   = '#6A9955'   " 注释               (cterm 107)
let s:keyword   = '#569CD6'   " 关键字/存储        (cterm 75)
let s:control   = '#C586C0'   " 控制流 if/for/return (cterm 176)
let s:string    = '#CE9178'   " 字符串             (cterm 173)
let s:number    = '#B5CEA8'   " 数字/字面量        (cterm 150)
let s:function  = '#DCDCAA'   " 函数名             (cterm 223)
let s:type      = '#4EC9B0'   " 类型/类名          (cterm 79)
let s:variable  = '#9CDCFE'   " 变量/属性          (cterm 117)
let s:operator  = '#D4D4D4'   " 运算符/标点        (cterm 252)
let s:selection = '#264F78'   " 选区/匹配          (cterm 24)
let s:linehl    = '#2A2D2E'   " 当前行高亮         (cterm 235)
let s:linenr    = '#858585'   " 行号               (cterm 245)
let s:linenrcur = '#C6C6C6'   " 当前行号           (cterm 251)
let s:tabfg     = '#969696'   " 非激活标签文字     (cterm 246)
let s:error     = '#F44747'   " 错误               (cterm 203)
let s:warning   = '#CCA700'   " 警告               (cterm 178)
let s:search    = '#613214'   " 搜索命中           (cterm 94)
let s:searchcur = '#EA5C00'   " 当前搜索命中       (cterm 202)
let s:regex     = '#D16969'   " 正则表达式         (cterm 131)
let s:addbg     = '#1F3B23'   " diff 新增背景      (cterm 235)
let s:delbg     = '#3B1F1F'   " diff 删除背景      (cterm 237)
let s:chgbg     = '#1F2B3B'   " diff 修改背景      (cterm 236)

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => 编辑器界面
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
exe 'hi Normal          guifg='.s:fg.'       guibg='.s:bg.'       ctermfg=252 ctermbg=234'
exe 'hi NormalNC        guifg='.s:fg.'       guibg='.s:bg.'       ctermfg=252 ctermbg=234'
exe 'hi EndOfBuffer     guifg='.s:bg.'       guibg='.s:bg.'       ctermfg=234 ctermbg=234'
exe 'hi Cursor          guifg='.s:bg.'       guibg=#AEAFAD        ctermfg=234 ctermbg=251'
exe 'hi CursorLine                    guibg='.s:linehl.'         ctermbg=235'
exe 'hi CursorColumn                  guibg='.s:linehl.'         ctermbg=235'
exe 'hi CursorLineNr    guifg='.s:linenrcur.'  gui=bold           ctermfg=251 cterm=bold'
exe 'hi LineNr          guifg='.s:linenr.'                       ctermfg=245'
exe 'hi LineNrAbove     guifg=#3A3D41                             ctermfg=237'
exe 'hi LineNrBelow     guifg=#3A3D41                             ctermfg=237'
exe 'hi Visual          guifg='.s:fg.'       guibg='.s:selection.' ctermfg=252 ctermbg=24'
exe 'hi VisualNOS       guifg='.s:fg.'       guibg=#3A3D41        ctermfg=252 ctermbg=237'
exe 'hi Search          guifg='.s:fg.'       guibg='.s:search.'    ctermfg=252 ctermbg=94'
exe 'hi IncSearch       guifg='.s:bg.'       guibg='.s:searchcur.' ctermfg=234 ctermbg=202'
exe 'hi CurSearch                       guibg='.s:searchcur.'     ctermbg=202'
exe 'hi MatchParen      guifg=#FFFFFF       guibg='.s:selection.' gui=bold ctermfg=231 ctermbg=24 cterm=bold'
exe 'hi MatchWord                       guibg='.s:selection.'    ctermbg=24'
exe 'hi WildMenu        guifg='.s:fg.'       guibg='.s:selection.' ctermfg=252 ctermbg=24'
exe 'hi QuickFixLine    guifg='.s:fg.'       guibg='.s:selection.' ctermfg=252 ctermbg=24'
exe 'hi SignColumn                       guibg='.s:bg.'           ctermbg=234'
exe 'hi Folded          guifg='.s:linenr.'   guibg='.s:bg.'        ctermfg=245 ctermbg=234'
exe 'hi FoldColumn      guifg='.s:linenr.'   guibg='.s:bg.'        ctermfg=245 ctermbg=234'
exe 'hi Conceal         guifg=#808080                             ctermfg=244'
exe 'hi NonText         guifg=#3A3D41                              ctermfg=237'
exe 'hi SpecialKey      guifg=#3A3D41                              ctermfg=237'

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => 窗口 / 标签 / 状态栏
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
exe 'hi VertSplit       guifg=#444444        guibg='.s:bg.'        ctermfg=238 ctermbg=234'
hi link WinSeparator VertSplit
exe 'hi StatusLine      guifg=#FFFFFF        guibg=#007ACC        gui=bold ctermfg=231 ctermbg=32 cterm=bold'
exe 'hi StatusLineNC    guifg='.s:tabfg.'    guibg='.s:bg_alt.'    ctermfg=246 ctermbg=235'
hi link StatusLineTerm   StatusLine
hi link StatusLineTermNC StatusLineNC
exe 'hi TabLine         guifg='.s:tabfg.'    guibg='.s:bg_alt.'    ctermfg=246 ctermbg=235'
exe 'hi TabLineSel      guifg=#FFFFFF        guibg='.s:bg.'        gui=bold ctermfg=231 ctermbg=234 cterm=bold'
exe 'hi TabLineFill     guifg='.s:tabfg.'    guibg='.s:bg_alt.'    ctermfg=246 ctermbg=235'
exe 'hi Pmenu           guifg='.s:fg.'       guibg='.s:bg_panel.'  ctermfg=252 ctermbg=236'
exe 'hi PmenuSel        guifg=#FFFFFF        guibg='.s:selection.' ctermfg=231 ctermbg=24'
exe 'hi PmenuSbar                        guibg='.s:bg_panel.'    ctermbg=236'
exe 'hi PmenuThumb                       guibg=#505050           ctermbg=239'

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => 信息 / 诊断
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
exe 'hi Error           guifg='.s:error.'                           ctermfg=203'
exe 'hi ErrorMsg        guifg='.s:error.'     gui=bold             ctermfg=203 cterm=bold'
exe 'hi WarningMsg      guifg='.s:warning.'                         ctermfg=178'
exe 'hi MoreMsg         guifg='.s:type.'                            ctermfg=79'
exe 'hi ModeMsg         guifg='.s:fg.'                              ctermfg=252'
exe 'hi Question        guifg='.s:keyword.'                         ctermfg=75'
exe 'hi Title           guifg='.s:keyword.'   gui=bold             ctermfg=75 cterm=bold'
exe 'hi Todo            guifg='.s:comment.'   gui=bold             ctermfg=107 cterm=bold'
exe 'hi Debug           guifg='.s:warning.'                         ctermfg=178'
exe 'hi Directory       guifg='.s:type.'                            ctermfg=79'
exe 'hi Ignore          guifg='.s:bg.'                              ctermfg=234'
exe 'hi Underlined      guifg='.s:variable.'  gui=underline        ctermfg=117 cterm=underline'

" 拼写错误: 下划线波浪线 (仅 GUI 显示彩色)
exe 'hi SpellBad        guisp='.s:error.'     gui=undercurl        cterm=underline ctermfg=203'
exe 'hi SpellCap        guisp='.s:keyword.'   gui=undercurl        cterm=underline ctermfg=75'
exe 'hi SpellLocal      guisp='.s:variable.'  gui=undercurl        cterm=underline ctermfg=117'
exe 'hi SpellRare       guisp='.s:control.'   gui=undercurl        cterm=underline ctermfg=176'

" diff
exe 'hi DiffAdd         guifg='.s:fg.'        guibg='.s:addbg.'     ctermfg=252 ctermbg=235'
exe 'hi DiffDelete      guifg='.s:fg.'        guibg='.s:delbg.'     ctermfg=252 ctermbg=237'
exe 'hi DiffChange      guifg='.s:fg.'        guibg='.s:chgbg.'     ctermfg=252 ctermbg=236'
exe 'hi DiffText        guifg='.s:fg.'        guibg='.s:selection.' ctermfg=252 ctermbg=24'

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => 语法高亮 (VS Code Dark+ 映射)
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
exe 'hi Comment         guifg='.s:comment.'                         ctermfg=107'
exe 'hi Constant        guifg='.s:keyword.'                         ctermfg=75'
exe 'hi String          guifg='.s:string.'                          ctermfg=173'
hi link Character  String
exe 'hi Number          guifg='.s:number.'                          ctermfg=150'
hi link Float      Number
exe 'hi Boolean         guifg='.s:keyword.'                         ctermfg=75'
exe 'hi Identifier      guifg='.s:variable.'                        ctermfg=117'
exe 'hi Function        guifg='.s:function.'                        ctermfg=223'
exe 'hi Statement       guifg='.s:control.'                         ctermfg=176'
hi link Conditional Statement
hi link Repeat      Statement
hi link Label       Statement
hi link Exception   Statement
exe 'hi Keyword         guifg='.s:keyword.'                         ctermfg=75'
exe 'hi Operator        guifg='.s:operator.'                        ctermfg=252'
exe 'hi PreProc         guifg='.s:control.'                         ctermfg=176'
hi link Include     PreProc
hi link Define      PreProc
hi link Macro       PreProc
hi link PreCondit   PreProc
exe 'hi Type            guifg='.s:type.'                            ctermfg=79'
hi link StorageClass Keyword
hi link Structure    Keyword
hi link Typedef      Type
exe 'hi Special         guifg='.s:function.'                        ctermfg=223'
hi link SpecialChar Special
hi link Tag         Keyword
exe 'hi Delimiter       guifg='.s:operator.'                        ctermfg=252'
hi link SpecialComment Comment

" 帮助文件
exe 'hi helpHypertextJump guifg='.s:keyword.'  gui=underline       ctermfg=75 cterm=underline'
exe 'hi helpHypertextEntry guifg='.s:function.'                    ctermfg=223'
exe 'hi helpNote        guifg='.s:control.'                         ctermfg=176'
exe 'hi vimCommentTitle guifg='.s:comment.'   gui=bold             ctermfg=107 cterm=bold'

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => 语言专属 (HTML/CSS/JS/Python/Markdown)
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" HTML: 标签=蓝 属性=浅蓝
exe 'hi htmlTag         guifg='.s:keyword.'                         ctermfg=75'
exe 'hi htmlEndTag      guifg='.s:keyword.'                         ctermfg=75'
exe 'hi htmlTagName     guifg='.s:keyword.'                         ctermfg=75'
hi link htmlSpecialTagName htmlTagName
exe 'hi htmlArg         guifg='.s:variable.'                        ctermfg=117'
exe 'hi htmlTitle       guifg='.s:fg.'                              ctermfg=252'

" CSS: 选择器=米黄 属性=浅蓝 数值=浅绿
exe 'hi cssIdentifier   guifg=#D7BA7D                              ctermfg=180'
exe 'hi cssClassName    guifg=#D7BA7D                              ctermfg=180'
exe 'hi cssTagName      guifg='.s:keyword.'                         ctermfg=75'
exe 'hi cssProp         guifg='.s:variable.'                        ctermfg=117'
exe 'hi cssValueNumber  guifg='.s:number.'                          ctermfg=150'
exe 'hi cssColor        guifg='.s:string.'                          ctermfg=173'
exe 'hi cssImportant    guifg='.s:keyword.'                         ctermfg=75'
exe 'hi cssSelectorOp   guifg='.s:operator.'                        ctermfg=252'

" JavaScript
exe 'hi javaScriptFunction    guifg='.s:keyword.'                   ctermfg=75'
exe 'hi javaScriptIdentifier  guifg='.s:variable.'                  ctermfg=117'
exe 'hi javaScriptNumber      guifg='.s:number.'                    ctermfg=150'
exe 'hi javaScriptStringS     guifg='.s:string.'                    ctermfg=173'
exe 'hi javaScriptStringD     guifg='.s:string.'                    ctermfg=173'
exe 'hi javaScriptRegexpString guifg='.s:regex.'                    ctermfg=131'

" Python
exe 'hi pythonStatement  guifg='.s:keyword.'                        ctermfg=75'
hi link pythonConditional Statement
hi link pythonFunction   Function
hi link pythonDecorator  Function
hi link pythonBuiltin    Function
hi link pythonString     String
hi link pythonNumber     Number
hi link pythonComment    Comment

" Markdown: 标题/加粗/链接=蓝 行内代码=橙
exe 'hi markdownH1            guifg='.s:keyword.'  gui=bold        ctermfg=75 cterm=bold'
exe 'hi markdownH2            guifg='.s:keyword.'  gui=bold        ctermfg=75 cterm=bold'
exe 'hi markdownH3            guifg='.s:keyword.'  gui=bold        ctermfg=75 cterm=bold'
exe 'hi markdownH4            guifg='.s:keyword.'  gui=bold        ctermfg=75 cterm=bold'
exe 'hi markdownH5            guifg='.s:keyword.'  gui=bold        ctermfg=75 cterm=bold'
exe 'hi markdownH6            guifg='.s:keyword.'  gui=bold        ctermfg=75 cterm=bold'
exe 'hi markdownCode          guifg='.s:string.'                   ctermfg=173'
exe 'hi markdownCodeBlock     guifg='.s:fg.'                        ctermfg=252'
exe 'hi markdownLinkText      guifg='.s:keyword.'                   ctermfg=75'
exe 'hi markdownBold          guifg='.s:keyword.'  gui=bold        ctermfg=75 cterm=bold'
exe 'hi markdownItalic        guifg='.s:keyword.'  gui=italic      ctermfg=75 cterm=italic'
exe 'hi markdownListMarker    guifg='.s:number.'                   ctermfg=150'
exe 'hi markdownBlockquote    guifg='.s:comment.'                  ctermfg=107'

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => coc.nvim / LSP 诊断
"    VS Code Default Dark+ 的诊断取色:
"      错误 #F44747   警告 #CCA700   信息 #3794FF   提示 #7F848E
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 符号列图标
hi CocErrorSign        guifg=#F44747 ctermfg=203
hi CocWarningSign      guifg=#CCA700 ctermfg=178
hi CocInfoSign         guifg=#3794FF ctermfg=75
hi CocHintSign         guifg=#7F848E ctermfg=245

" 行内波浪线 (GUI 用 undercurl, 终端退化为下划线)
hi CocErrorHighlight   gui=undercurl guisp=#F44747 ctermfg=203 cterm=underline
hi CocWarningHighlight gui=undercurl guisp=#CCA700 ctermfg=178 cterm=underline
hi CocInfoHighlight    gui=undercurl guisp=#3794FF ctermfg=75  cterm=underline
hi CocHintHighlight    gui=undercurl guisp=#7F848E ctermfg=245 cterm=underline

" 行尾虚拟文本
hi CocErrorVirtualText   guifg=#F44747 ctermfg=203
hi CocWarningVirtualText guifg=#CCA700 ctermfg=178
hi CocInfoVirtualText    guifg=#3794FF ctermfg=75
hi CocHintVirtualText    guifg=#7F848E ctermfg=245

" 光标停留时整行底色
hi CocErrorLine        guibg=#3B1F1F ctermbg=237
hi CocWarningLine      guibg=#3A3117 ctermbg=236
hi CocInfoLine         guibg=#1F2B3B ctermbg=236
hi CocHintLine         guibg=#2A2D2E ctermbg=235

" 悬浮窗口 (文档/签名/诊断气泡)
hi CocFloating          guifg=#D4D4D4 guibg=#252526 ctermfg=252 ctermbg=235
hi CocFloatBorder       guifg=#454545 guibg=#252526 ctermfg=238 ctermbg=235
hi CocFloatActive       guifg=#569CD6 guibg=#252526 ctermfg=75  ctermbg=235
hi CocFloatSbar         guibg=#252526 ctermbg=235
hi CocFloatThumb        guibg=#4E4E4E ctermbg=239
hi CocFloatDividingLine guifg=#3A3D41 ctermfg=237
hi CocErrorFloat        guifg=#F44747 ctermfg=203
hi CocWarningFloat      guifg=#CCA700 ctermfg=178
hi CocInfoFloat         guifg=#3794FF ctermfg=75
hi CocHintFloat         guifg=#7F848E ctermfg=245
hi CocHoverRange        guibg=#264F78 ctermbg=24

" 补全菜单
hi CocMenuSel         guibg=#264F78 ctermbg=24
hi CocPumSearch       guifg=#569CD6 ctermfg=75
hi CocPumDetail       guifg=#7F848E ctermfg=245
hi CocPumShortcut     guifg=#7F848E ctermfg=245
hi CocPumDeprecated   guifg=#7F848E ctermfg=245
hi CocPumVirtualText  guifg=#7F848E ctermfg=245
hi CocSuggestion      guifg=#569CD6 ctermfg=75

" 列表窗口 (:CocList / 诊断列表)
hi CocListLine        guifg=#D4D4D4 guibg=#1E1E1E ctermfg=252 ctermbg=234
hi CocListSearch      guifg=#DCDCAA ctermfg=223
hi CocListCurrent     guibg=#264F78 ctermbg=24
hi CocListMode        guifg=#C586C0 ctermfg=176
hi CocListPath        guifg=#7F848E ctermfg=245
hi CocListResume      guifg=#4EC9B0 ctermfg=79
hi CocListCancel      guifg=#F44747 ctermfg=203

" 诊断分级 + 文档悬浮里的 Markdown 排版
hi CocDiagnostics     guifg=#D4D4D4 ctermfg=252
hi link CocDiagnosticsError   CocErrorSign
hi link CocDiagnosticsWarning CocWarningSign
hi link CocDiagnosticsInfo    CocInfoSign
hi link CocDiagnosticsHint    CocHintSign
hi CocMarkdownHeader  guifg=#569CD6 gui=bold ctermfg=75 cterm=bold
hi CocMarkdownCode    guifg=#CE9178 ctermfg=173
hi CocMarkdownLink    guifg=#569CD6 gui=underline ctermfg=75 cterm=underline
hi CocBold            gui=bold cterm=bold
hi CocItalic          gui=italic cterm=italic
hi CocUnderline       gui=underline cterm=underline
hi CocStrikeThrough   gui=strikethrough cterm=strikethrough

" 文档高亮 / 未使用 / 已废弃 / 内联提示
hi CocHighlightText       guibg=#264F78 ctermbg=24
hi CocHighlightRead       guibg=#264F78 ctermbg=24
hi CocHighlightWrite      guibg=#264F78 ctermbg=24
hi CocCurrentLine         guibg=#2A2D2E ctermbg=235
hi CocUnusedHighlight     guifg=#7F848E ctermfg=245
hi CocDeprecatedHighlight guifg=#7F848E gui=strikethrough ctermfg=245 cterm=strikethrough
hi CocDisabled            guifg=#7F848E ctermfg=245
hi CocDisabledHighlight   guifg=#7F848E ctermfg=245
hi CocCodeLens            guifg=#7F848E ctermfg=245
hi CocInlayHint           guifg=#7F848E guibg=#1E1E1E ctermfg=245 ctermbg=234
hi CocInlayHintType       guifg=#4EC9B0 ctermfg=79
hi CocInlayHintParameter  guifg=#9CDCFE ctermfg=117
hi CocSearch              guifg=#DCDCAA ctermfg=223

let &cpo = s:save_cpo
unlet s:save_cpo
