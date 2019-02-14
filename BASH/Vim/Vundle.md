####  ~/.vimrc ( Vim8.1 + Python3 )
```vim
" ---------------------------------------- Default ------------------------------------------
" Status Line Setting Gather
" set statusline=%F%m%r%h%w\ [FORMAT=%{&ff}]\ [TYPE=%Y]\ [ASCII=\%03.3b]\ [HEX=\%02.2B]\ [POS=%04l,%04v][%p%%]\ [LEN=%L] 
" set statusline=\ %<%F[%1*%M%*%n%R%H]%=\ %y\ %0(%{&fileformat}\ %{&encoding}\ %c:%l/%L%)\

" let mapleader="\"         " 设置<leader>所代表的按键

nmap <leader>s :w!<cr>      " 普通模式 \s 进行保存
" vmap <C-c> "+y            " 选中状态下 Ctrl+c 复制
nmap <leader>c ggVGY        " 全选+复制 Ctrl+a

set history=1000
set backspace=2                                 " 启用退格键
set tabstop=4                                   " 默认缩进数
set ruler                                       " 状态栏标尺
set laststatus=2                                " 显示状态栏
set incsearch                                   " 实时显示搜索结果
set ignorecase					" 搜索时忽略大小写
set hlsearch                                    " 高亮显示搜索文本
syntax on                                       " 语法高亮
set fenc=utf-8                                  " 文件编码
set expandtab                                   " 将TAB转为4个字符
" set paste                          " 粘贴文本时不自动追加缩进，取消：set nopaste 快捷键：set pastetoggle=<F9>

" 可以在buffer的任何地方使用鼠标
set mouse=a
" set selection=exclusive
" set selectmode=mouse,key

set completeopt=longest,menu    "打开文件类型检测, 加了这句才可以用智能补全

" 对搜索时的关键字高亮处理
hi Search cterm=NONE ctermfg=darkred ctermbg=yellow cterm=reverse

" 行号字体颜色与其背景颜色的设置，在控制台下使用cterm，否则使用gui关键字...
highlight LineNr ctermfg=red
highlight LineNr ctermbg=231
set nu

highlight VertSplit ctermfg=green               " 多窗口环境下边界分隔符背景色
set fillchars=vert:\|                           " 多窗口环境下使用的边界分隔符
" <c-r>=strftime("%d/%m/%y %H:%M:%S")<cr>       " 插入模式下写入当前时间

" 中文语言设置参数
set fileencodings=utf-8,ucs-bom,gb18030,gbk,gb2312,cp936 
set termencoding=utf-8
set encoding=utf-8

" 设置IDE环境的背景色，Value部分可以通过设置16进制颜色值来执行，入：=#00FF00
highlight Normal guibg=White        "针对GUI
highlight Normal ctermbg=231        "针对cterm
" ------------------------------------------- Map -------------------------------------------
" map <F8>  <ESC>:! python %              " 使用python解释器执行本文件
" <F5> 运行脚本并分屏输出
function! Exec()
    execute "w"
    execute "silent !chmod +x %:p"
    let n=expand('%:t')
    execute "silent !%:p 2>&1 | tee > /tmp/.output_".n
    execute "vsplit /tmp/.output_".n
    execute "redraw!"
    set autoread 
endfunction
:nmap <F5> :call Exec()

map <F6>  <ESC>:vsp #FileName                   " 多窗口 "<c-w> + hjkl" 进行切换
map <leader>+  <ESC>:vertical resize+10<Cr>     " 多窗口模式下将当前窗口向右增加10列
map <F7>  <ESC>:! bash %                        " 使用bash解释器执行本文件
```
#### Use Vundle for VIM Plugin
```bash
#升级VIM到8.1+ 
[root@localhost ~]# yum -y install ncurses-devel.x86_64  gcc gcc-c++ wget    #注意ncurses最好是64位
[root@localhost ~]# yum -y remove vim 
[root@localhost ~]# git clone https://github.com/vim/vim.git
[root@localhost ~]# cd vim
[root@localhost ~]# ./configure --with-features=huge \
 --enable-multibyte \
 --enable-rubyinterp=yes\
 --enable-pythoninterp=yes \
 --enable-python3interp=yes \
 --enable-shared && cd ..
[root@localhost ~]# make 
[root@localhost ~]# make install
[root@localhost ~]# vim ~/.bash_profile
#--------------------
VIM_BIN=/usr/local/bin/vim
PATH==$VIM_BIN:$PATH:$HOME/bin
#--------------------
[root@localhost ~]# . ~/.bash_profile

#安装插件管理器
[root@localhost ~]# git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
Cloning into '/root/.vim/bundle/Vundle.vim'...
remote: Enumerating objects: 3136, done.
remote: Total 3136 (delta 0), reused 0 (delta 0), pack-reused 3136
Receiving objects: 100% (3136/3136), 933.42 KiB | 591.00 KiB/s, done.
Resolving deltas: 100% (1105/1105), done.

#关于Vundle及部分插件需要的相关设置和参数
[root@localhost ~]# vim ~/.vimrc
# ........................................................
filetype off

" 以下是vim-powerline插件需要的设置选项
set rtp+=~/.vim/bundle/Vundle.vim
set laststatus=2
set encoding=utf-8
set t_Co=256
set fillchars+=stl:\ ,stlnc:\
let g:Powerline_symbols = 'unicode'
let g:airline_powerline_fonts = 1
let g:Powerline_mode_V="V·LINE"
let g:Powerline_mode_cv="V·BLOCK"
let g:Powerline_mode_S="S·LINE"
let g:Powerline_mode_cs="S·BLOCK"

" jedi-vim插件需要的一些设置，用于语法TAB补齐
let g:SuperTabDefaultCompletionType = "context"
let g:jedi#popup_on_dot = 0

" supertab
set expandtab 
set ts=4

" YouCompleteMe
let g:ycm_complete_in_comments = 1                                  "在注释输入中也能补全
let g:ycm_complete_in_strings = 1                                   "在字符串输入中也能补全
let g:ycm_collect_identifiers_from_comments_and_strings = 1         "注释和字符串中的文字也会被收入补全
autocmd InsertLeave * if pumvisible() == 0|pclose|endif             "离开插入模式后自动关闭预览窗口
" nnoremap <c-j> :YcmCompleter GoToDefinitionElseDeclaration<CR>    "跳转到定义处

" python-syntax 语法高亮
let python_highlight_all = 1

" nerdtree 插件使用，<F3> 对其进行呼入/呼出
map <F3> :NERDTreeMirror<CR>
map <F3> :NERDTreeToggle<CR>
" autocmd vimenter * NERDTree  "自动开启Nerdtree
" autocmd vimenter * if !argc()|NERDTree|endif  "打开vim时如果没有文件自动打开NERDTree
" 只剩 NERDTree时自动关闭
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif
let g:NERDTreeHidden=0      "不显示隐藏文件
let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1
let g:NERDTreeWinSize = 22  "侧边栏宽度
let g:NERDTreeDirArrowExpandable = '▸'  "树的显示图标
let g:NERDTreeDirArrowCollapsible = '▾' "树的显示图标

" NERDTress File highlighting
function! NERDTreeHighlightFile(extension, fg, bg, guifg, guibg)
 exec 'autocmd filetype nerdtree highlight ' . a:extension .' ctermbg='. a:bg .' ctermfg='. a:fg .' guibg='. a:guibg .' guifg='. a:guifg
 exec 'autocmd filetype nerdtree syn match ' . a:extension .' #^\s\+.*'. a:extension .'$#'
endfunction

call NERDTreeHighlightFile('jade', 'green', 'none', 'green', '#151515')
call NERDTreeHighlightFile('ini', 'yellow', 'none', 'yellow', '#151515')
call NERDTreeHighlightFile('md', 'blue', 'none', '#3366FF', '#151515')
call NERDTreeHighlightFile('yml', 'yellow', 'none', 'yellow', '#151515')
call NERDTreeHighlightFile('config', 'yellow', 'none', 'yellow', '#151515')
call NERDTreeHighlightFile('conf', 'yellow', 'none', 'yellow', '#151515')
call NERDTreeHighlightFile('json', 'yellow', 'none', 'yellow', '#151515')
call NERDTreeHighlightFile('html', 'yellow', 'none', 'yellow', '#151515')
call NERDTreeHighlightFile('styl', 'cyan', 'none', 'cyan', '#151515')
call NERDTreeHighlightFile('css', 'cyan', 'none', 'cyan', '#151515')
call NERDTreeHighlightFile('coffee', 'Red', 'none', 'red', '#151515')
call NERDTreeHighlightFile('js', 'Red', 'none', '#ffa500', '#151515')
call NERDTreeHighlightFile('php', 'Magenta', 'none', '#ff00ff', '#151515')

" jedi-vim 
execute pathogen#infect()
syntax on
filetype plugin indent on 

nnoremap <leader>r :REPLToggle<Cr>                  "使用普通模式的\r代替命令模式的:REPLToggle
let g:repl_width = 15                               "窗口宽度
let g:repl_height = 10                              "窗口高度
let g:sendtorepl_invoke_key = "<leader>w"           "传送代码快捷键，默认为<leader>w    注:<Leader>默认是\
let g:repl_position = 0                             "0出现在下方，1出现在上方，2在左边，3在右边
let g:repl_stayatrepl_when_open = 0                 "打开REPL时是回到原文件（1）还是停留在REPL窗口中（0）

" 指定REPL程序 （注意\可能导致VIM输入2个，另需注意python版本为3+）
let g:repl_program = {
\	"python": "python",
\	"default": "bash"
\	}

" 指定退出命令
let g:repl_exit_commands = {
\	"python": "quit()",
\	"bash": "exit",
\	"zsh": "exit",
\	"default": "exit",
\	}
"           打开REPL：:REPLToggle
"           退出REPL：:REPLToggle
"           如何向REPL中发送代码：
"             在Normal模式下：按`<leader>w`，光标所在行（包括一个最后的回车）便会输入到REPL中。
"             在Visual模式下：按`<leader>w`，对应的所有行（包括最后的回车）便会输入到REPL中。

" molokai Plugin
set t_Co=256            
color molokai           
let g:molokai_original=1
let g:rehash256=1       

" 关于Vundle的一些设置，主要用于对插件进行管理
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'
Plugin 'L9'
Plugin 'Lokaltog/vim-powerline' "状态栏
Plugin 'davidhalter/jedi-vim'   "自动补全
Plugin 'ervandew/supertab'      "TAB
Plugin 'hdima/python-syntax'    "语法检查
Plugin 'scrooloose/nerdtree'    "目录树
Plugin 'sillybun/vim-repl'      "运行终端
Plugin 'sillybun/vim-async'     "配套
Plugin 'sillybun/zytutil'       "配套
Plugin 'tomasr/molokai'         "高级配色
" Plugin 'Valloric/YouCompleteMe' "自动补全 (暂时保留，使用Jedi-vim进行替代)
" Plugin 'Valloric/ListToggle'
" Plugin 'scrooloose/syntastic'
call vundle#end()
# ........................................................
```

#### Plugin configure （ 插件安装后需要在主机执行的命令 ）
```bash
#解决依赖问题
#在终端执行：
[root@localhost ~]# export TERM="screen-256color"
#Powerline使用特殊符号来为开发者显示特殊的箭头效果和符号内容。因此系统中必须要有符号字体或者补丁过的字体
[root@localhost ~]# wget https://github.com/powerline/powerline/raw/develop/font/PowerlineSymbols.otf
[root@localhost ~]# wget https://github.com/powerline/powerline/raw/develop/font/10-powerline-symbols.conf
#更新系统字体缓存
[root@localhost ~]# yum -y install fontconfig && fc-cache -vf /usr/share/fonts/    
#安装字体
[root@localhost ~]# mv 10-powerline-symbols.conf /usr/share/fonts/
[root@localhost ~]# mv PowerlineSymbols.otf /usr/share/fonts/
#参考：https://www.jianshu.com/p/f0513d18742a/

#VIM-REPL安装后需要进行的操作 ( 需要PYTHON3 )
[root@localhost ~]# cd ~/.vim/bundle/vim-repl/ && bash ./install.sh
[root@localhost ~]# cd ~/.vim/bundle/vim-async/ && bash ./install.sh

#如果需扩展YouCompleteMe的大部分语言补全功能，需要执行此操作
[root@localhost ~]# cd ~/.vim/bundle/YouCompleteMe
[root@localhost YouCompleteMe]# git submodule update --init --recursive
[root@localhost YouCompleteMe]# ./install.py --clang-completer

#jedi-vim插件安装后需要进入其目录使用git来更新模块才能使用
[root@localhost ~]# pip3 install jedi    #建议更新...
[root@localhost ~]# cd ~/.vim/bundle/jedi-vim/ && git submodule update --init
#在vim中执行如下命令开始安装vundle中定义的插件
:PluginInstall
```
#### 新建文件自动插入文件头
```vimrc
"新建.c,.h,.sh,.java文件，自动插入文件头 
autocmd BufNewFile *.cpp,*.[ch],*.sh,*.java exec ":call SetTitle()" 

"定义函数SetTitle，自动插入文件头 
func SetTitle() 
	if &filetype == 'sh' 
		call setline(1, "####################################################################") 
		call append(line("."), "# File Name: ".expand("%")) 
		call append(line(".")+1, "# Author: Wangyu") 
		call append(line(".")+2, "# mail: inmoonlight@163.com") 
		call append(line(".")+3, "# Created Time: ".strftime("%c")) 
		call append(line(".")+4, "###################################################################") 
		call append(line(".")+5, "#!/bin/bash")
		call append(line(".")+6, "")
	else 
		call setline(1, "/*******************************************************************") 
		call append(line("."), "	> File Name: ".expand("%")) 
		call append(line(".")+1, "	> Author: Wangyu") 
		call append(line(".")+2, "	> Mail: inmoonlight@163.com") 
		call append(line(".")+3, "	> Created Time: ".strftime("%c")) 
		call append(line(".")+4, " ******************************************************************/") 
		call append(line(".")+5, "")
	endif
	if &filetype == 'cpp'
		call append(line(".")+6, "#include<iostream>")
    	call append(line(".")+7, "using namespace std;")
		call append(line(".")+8, "")
	endif
	if &filetype == 'c'
		call append(line(".")+6, "#include<stdio.h>")
		call append(line(".")+7, "")
	endif
	"	if &filetype == 'java'
	"		call append(line(".")+6,"public class ".expand("%"))
	"		call append(line(".")+7,"")
	"	endif
	autocmd BufNewFile * normal G   "新建文件后自动定位到文件末尾
endfunc
```
#### nerdtree 快捷键
```bash
# 切换工作台和目录
#     ctrl + w + h    光标 focus 左侧树形目录
#     ctrl + w + l    光标 focus 右侧文件显示窗口
#     ctrl + w + w    光标自动在左右侧窗口切换
#     ctrl + w + r    移动当前窗口的布局位置
#     
#     o       在已有窗口中打开文件、目录或书签，并跳到该窗口
#     go      在已有窗口 中打开文件、目录或书签，但不跳到该窗口
#     t       在新 Tab 中打开选中文件/书签，并跳到新 Tab
#     T       在新 Tab 中打开选中文件/书签，但不跳到新 Tab
#     i       split 一个新窗口打开选中文件，并跳到该窗口
#     gi      split 一个新窗口打开选中文件，但不跳到该窗口
#     s       vsplit 一个新窗口打开选中文件，并跳到该窗口
#     gs      vsplit 一个新窗口打开选中文件，但不跳到该窗口
#     !       执行当前文件
#     O       递归打开选中 结点下的所有目录
#     m       文件操作：复制、删除、移动等
#     x       收起当前打开的目录
#     X       收起所有打开的目录
#     K       跳转到第一个子路径
#     J       跳转到最后一个子路径
# 
#     :tabnew [++opt选项] ［＋cmd］ 文件      建立对指定文件新的tab
#     :tabc   关闭当前的 tab
#     :tabo   关闭所有其他的 tab
#     :tabs   查看所有打开的 tab
#     :tabp   前一个 tab   (pre)
#     :tabn   后一个 tab   (next)
# 
# 标准模式下：
#     gT      前一个 tab
#     gt      后一个 tab
```
