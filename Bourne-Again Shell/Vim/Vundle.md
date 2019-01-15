#### Vundle Install
```bash
[root@localhost ~]# git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
Cloning into '/root/.vim/bundle/Vundle.vim'...
remote: Enumerating objects: 3136, done.
remote: Total 3136 (delta 0), reused 0 (delta 0), pack-reused 3136
Receiving objects: 100% (3136/3136), 933.42 KiB | 591.00 KiB/s, done.
Resolving deltas: 100% (1105/1105), done.

vim ~/.vimrc
# ........
" 关于Vundle的一些设置，主要用于对插件进行管理
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'
Plugin 'L9'
Plugin 'Valloric/YouCompleteMe'
Plugin '这里写入需要另外安装的插件名称，默认都是从Github进行下载'
call vundle#end()
filetype plugin indent on
#.........
```

##### Plugin Install
```vim
" 参考：https://www.jianshu.com/p/f0513d18742a/
:PluginInstall
```
