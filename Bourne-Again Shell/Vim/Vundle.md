#### ~/.vimrc
```vim
" ------------------------------ Default --------------------------------
" 默认缩进数
set tabstop=4
" 状态栏标尺
set ruler
" 显示状态栏
set laststatus=2
" 实时显示搜索结果
set incsearch
" 高亮显示搜索文本
set hlsearch
" 语法高亮
syntax on
" 文件编码
set fenc=utf-8
" 将TAB转为4个字符
set expandtab 
" 多窗口环境下使用的边界分隔符
set fillchars=vert:\|

" --------------------------------- Map ---------------------------------
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

" 多窗口 "<c-w> + hjkl" 进行切换
map <F6>  <ESC>:vsp #FileName

" 多窗口模式下将当前窗口向右增加10列
map <C-W>  <ESC>:vertical resize+10

" 使用bash解释器执行本文件
map <F7>  <ESC>:! bash %

" 使用python解释器执行本文件
map <F8>  <ESC>:! python %
```
#### Vundle Install VIM Plugin
```bash
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
let g:Powerline_symbols = 'fancy'
set encoding=utf-8
set fillchars+=stl:\ ,stlnc:\
set rtp+=~/.vim/bundle/Vundle.vim
set laststatus=2
let g:Powerline_symbols='unicode'
set t_Co=256

" jedi-vim插件需要的一些设置，用于语法TAB补齐
let g:SuperTabDefaultCompletionType = "context"
let g:jedi#popup_on_dot = 0

" supertab
set expandtab 
set ts=4

" python-syntax 语法高亮
let python_highlight_all = 1

" nerdtree 插件使用，<F3> 对其进行呼入/呼出
map <F3> :NERDTreeMirror<CR>
map <F3> :NERDTreeToggle<CR>
" autocmd vimenter * NERDTree  "自动开启Nerdtree
" autocmd vimenter * if !argc()|NERDTree|endif  "打开vim时如果没有文件自动打开NERDTree
let g:NERDTreeHidden=0      "不显示隐藏文件
let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1
let g:NERDTreeWinSize = 30  "侧边栏宽度
let g:NERDTreeDirArrowExpandable = '▸'  "树的显示图标
let g:NERDTreeDirArrowCollapsible = '▾' "树的显示图标

" 关于Vundle的一些设置，主要用于对插件进行管理
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'
Plugin 'L9'
Plugin 'Lokaltog/vim-powerline'
Plugin 'davidhalter/jedi-vim'
Plugin 'ervandew/supertab'
Plugin 'hdima/python-syntax'
Plugin 'scrooloose/nerdtree'
Plugin '这里写入需要另外安装的插件名称，默认都是从Github进行下载'
call vundle#end()
filetype plugin indent on
# ........................................................
```

#### Plugin Install （ 插件安装后需要在主机执行的命令 ）
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

#如果需要扩展YouCompleteMe的大部分语言补全功能，需要执行此操作
[root@localhost ~]# cd ~/.vim/bundle/YouCompleteMe
[root@localhost YouCompleteMe]# ./install.py --clang-completer

#jedi-vim插件安装后需要进入其目录使用git来更新模块才能使用
[root@localhost ~]# cd ~/.vim/bundle/jedi-vim/ && git submodule update --init
#在vim中执行如下命令开始安装vundle中定义的插件
:PluginInstall
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
