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


" 按 "F5" 自动运行并分屏输出
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

" 多窗口 使用 <c-w> 进行切换
map <F6>  <ESC>:vs #FILENAME

" 使用bash解释器执行本文件
map <F7>  <ESC>:! bash %

" 使用python解释器执行本文件
map <F8>  <ESC>:! python %


