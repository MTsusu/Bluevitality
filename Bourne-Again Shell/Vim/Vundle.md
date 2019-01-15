#### Vundle Install
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

" 关于Vundle的一些设置，主要用于对插件进行管理
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'
Plugin 'L9'
Plugin 'Lokaltog/vim-powerline'
Plugin 'davidhalter/jedi-vim'
Plugin 'ervandew/supertab'
Plugin 'hdima/python-syntax'
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
