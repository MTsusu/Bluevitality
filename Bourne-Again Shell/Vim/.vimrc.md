#### Quickly Run Demo 1
```vim
set encoding=utf-8          " 编码
set cursorline              " 突出显示当前行
set tabstop=4               " 制表符4个空格
set incsearch               " 输入搜索内容时就显示搜索结果

" 按 "F5" 自动运行并分屏输出，本段在写入 ~/.vimrc 前要先创建文件： mkdir ~/.vim
function! Exec()
    execute "w"
    execute "silent !chmod +x %:p"
    let n=expand('%:t')
    execute "silent !%:p 2>&1 | tee /tmp/output_".n
    execute "vsplit ~/.vim/output_".n
    execute "redraw!"
    set autoread  
endfunction

:nmap <F5> :call Exec()
```
#### Quickly Run Demo 2
```vim
map <F5> :call Run()<CR>
func! Run()
    exec "w"
    if &filetype == 'c'
                exec "!g++ % -o %<"
                exec "!time ./%<"
    elseif &filetype == 'cpp'
                exec "!g++ % -o %<"
                exec "!time ./%<"
    elseif &filetype == 'java'
                exec "!javac %"
                exec "!time java %<"
    elseif &filetype == 'sh'
                :!time bash %
    elseif &filetype == 'python'
                exec "!time python2.7 %"
    elseif &filetype == 'html'
                exec "!firefox % &"
    elseif &filetype == 'go'
                exec "!go build %<"
                exec "!time go run %"
    elseif &filetype == 'mkd'
                exec "!~/.vim/markdown.pl % > %.html &"
                exec "!firefox %.html &"
    endif
endfunc
```
