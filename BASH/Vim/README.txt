用户配置：~/.vimrc，相关文件位于：~/.vim/
全局配置：/etc/vimrc，相关文件位于：/usr/share/vim/

vim +'command' filename     	进入文件之后执行任一命令
vim a.txt b.txt c.txt 		打开多个文件，n 下个文件，N 上个文件

普通模式：
	v/V             视图模式（逐字符：v，逐行:V。块选择：CTL+v，编辑后按2次ESC退出，注：大'I'进入编辑)
	H、M、L		当前屏幕上下移动。 Ctrl + f、b  ---> 上下翻页
	p               粘贴  
	dd              删行，3dd删除三行，daw 删1个单词，2daw 删2个单词
	x   		删光标后1个字符
	i、a		i进入单词前编辑，a进入单词后编辑、I进入行首编辑、A进入行尾编辑、- 跳转到上一行的行首
    	o、O            	在当前下行编辑、在当前前一行编辑
	u、.	  	撤销、重复上次操作  . 与 ctl+r 类似	
	cc		删当前行并进入编辑模式，cw 删除单词并编辑
	^、$		至行首、尾。   d^、d$ ---> 从光标到行首、行尾删除
	NG		到第N行，或命令行下执行：vim +number filename
	gg、G		至档头、档尾  n<Enter> ---> 向下移动n行，或：ngg 。  n<space>	---> 向右移动n个字符
	h、j、k、l		上下左右
	Ctrl + N 、P	对当前文本内向下、上查找以自动补全或提示
	Ctrl + a、x	  为变量自增、自减（<num>ctl+a  加指定值，若数字不存在当前光标下则进行正向查找并增、减值）
	w、e		至单词开头或结尾
	yy、y$		复制一行或复制光标所在位置到行末的部分
	[[		跳转到代码块的开头，要求代码块中'{'必须是单独占的一行
	ZZ              不进入命令模式执行wq或x而直接退出
	{、}            	代码块的起使和结束
	s               删除光标当前字符并开始编辑，类似cc，S 清空光标所在行并进入插入模式
	*               跳转到当前光标所处单词的下一出现
	>G              增加与当前行相同缩进的行的缩进层级（从左向右）
	==              自动与前一行的缩进对齐!
	3==             后三行与前一行保持缩进对齐
	f1              搜索并跳转到当前行出现的第一个1字符，; 下个匹配 ","上个匹配
	20.             重复20次之前的修改操作
	<c-[>           同ESC
	<c-o>xxx        在插入模式的环境中执行模式命令xxx
	ga              显示光标所指的字符编码
	r       	替换光标所在的单个字符
	R 	        进入替换模式
	p               在光标之后粘帖，大"P"是在光标之上，"shift + p" 是在光标之前粘帖
	d$              删除光标到行尾的内容
	J               清除光标所处行与下一行间的空格，把光标行与下一行结合为一行
    
命令模式：
	:1，5s/A/B/g	 替换1-5行，全局替换：%s/old/new/g
	:1，$d		从第1行删到尾行（d$当前删到行尾） :1，5y ---> 拷贝贝1-5行（复制当前行：yy，3yy：复制3行）
	:/work ?work	 向下、向上查找
	:s/old/new/g	本行替换	"//"内支持正则表达式
	:set nu		 显示行号（直接输入数字后回车可到达指定行）
	:set ic		 搜索时忽略大小写，即"Ignore Case"的简写
	:set ai		 设置自动缩进（自动对齐）
	:set tabstop=4	  按TAB键时的缩进数
	:set fileencoding=utf8	指定编码
    	:set number numberwidth=3    设置行号及其列宽
	:set incsearch     输入搜索内容时就显示搜索结果
	:set bg=dark	  设置背景色
    	:set autoindent    自动缩进
	:syntax on     	  语法高亮
    	:set hlsearch      对查找的文本高亮显示
	:r Filename	 读取并在本行后插入，指定行后插入 :nr Filename
	:w Filename	 另存为，可指定范围  :n1,n2 w Filename  --->   将n1到n2行之间的数据另存到文件Filename
	:split 		 创建分屏 (vsplit：创建垂直分屏)
	:wq!		 强制保存并离开，:wq! filename 以filename为文件名保存后退出
	:!command	   在Vim内的命令模式下执行系统命令
    	:10,20d            删除指定行
	:x             	 保存并且退出   :X ---> 加密保存（需输入密码）
	:Ex		 开启目录浏览器（可选择当前目录下的文件进行编辑）
	:Sex		 水平分割当前窗口，并在一个窗口中开启文件浏览器,按下<Enter>可以打开
    	:qall              退出所有打开的文件
    	:ls                列出所有打开的文件名
    	:数字             定位文件的第几行
    	:!ls /etc         执行本地命令

寄存器：
	:reg  		查看寄存器
	0     		保存了最新的复制内容
	1-9   		保存了最近9次的删除内容
	"     		默认寄存器，保存了最近复制或删除的内容
	-     		行内的删除内容
	.     		最近插入的内容
	%     		当前的文件名
	#     		当前交替文件名?
	:     		最近输入的命令 
	=     		只读，用于执行表达式命令并将结果保存在寄存器
	/     		最近的搜索模式
	"*    		GUI选择与拖拽寄存器
	"+    		GUI选择与拖拽寄存器 
	"~    		GUI选择与拖拽寄存器
	"_    		黑洞寄存器，不缓存操作内容,使用:reg命令看不到但可以使用
	
附：
	view Filename		以只读模式查看
	vimdiff	F1 F2	  	在vim视图下比较两文件内容的差异
	
	多文件[o/O]：
		上下分布：	vim  -o 	F1 F2
		左右分布：	vim  -O 	F1 F2

---------------------------------------- 笔记 ------------------------------------------------

map l dd            "使用l替代dd
map <space> 2j      "使用空格替代跳转到下2行
map <c-d>   dd      "Ctrl+d ---> dd
nnoremap jyh o<esc>k "当前行后再插入一行
nnoremap fgx i#---------------------------------------------------<esc>j    "分割线  
nnoremap 2gp <esc>:vsplit<cr>   #竖屏分割

Python文件中，新行将在原本缩进的基础上再缩进4个空格：
    autocmd FileType python set breakindentopt=shift:4

多语言语法高亮：
filetype plugin on
syntax on


逐个单词移动
	w	移动到下一个单词词首
	e	跳到当前单词或下一单词的词尾
	b	跳到当前单词或前一单词的词首
	#w	一次跳n个单词

记录上次打开时的光标位置：
	augroup resCur
	  autocmd!
	  autocmd BufReadPost * call setpos(".", getpos("'\""))
	augroup END


Cscope是一个工程浏览工具。通过导航到一个词/符号/函数并通过快捷键调用cscope，能快速找到：函数调用及函数定义等。
mkdir -p ~/.vim/plugin
wget -P ~/.vim/plugin http://cscope.sourceforge.net/cscope_maps.vim
注意:在Vim的7.x版本中，你可能需要在~/.vim/plugin/cscope_maps.vim中取消下列行的注释来启用cscope快捷键：
set timeoutlen=4000
set ttimeout
创建一个文件，该文件包含了你希望cscope索引的文件的清单（cscope可以操作很多语言，下面的例子用于寻找C++中的.c、_.cpp和.h_文件）：
cd /path/to/projectfolder/
find . -type f -print | grep -E '\.(c(pp)?|h)$' > cscope.files
创建cscope将读取的数据文件：
cscope -bq
默认快捷键：
 Ctrl-\ and
      c: Find functions calling this function
      d: Find functions called by this function
      e: Find this egrep pattern
      f: Find this file
      g: Find this definition
      i: Find files #including this file
      s: Find this C symbol
      t: Find assignments to


colorscheme molokai " 设定配色方案
set cursorline " 突出显示当前行
set ruler " 打开状态栏标尺
set shiftwidth=4 " 设定 << 和 >> 命令移动时的宽度为 4
set softtabstop=4 " 使得按退格键时可以一次删掉 4 个空格
set tabstop=4 " 设定 tab 长度为 4
set nobackup " 覆盖文件时不备份
set autochdir " 自动切换当前目录为当前文件所在的目录
filetype plugin indent on " 开启插件
set backupcopy=yes " 设置备份时的行为为覆盖
set ignorecase smartcase " 搜索时忽略大小写，但在有一个或以上大写字母时仍保持对大小写敏感
set nowrapscan " 禁止在搜索到文件两端时重新搜索
set incsearch " 输入搜索内容时就显示搜索结果
set hlsearch " 搜索时高亮显示被找到的文本
set noerrorbells " 关闭错误信息响铃
set novisualbell " 关闭使用可视响铃代替呼叫
set t_vb= " 置空错误铃声的终端代码
" set showmatch " 插入括号时，短暂地跳转到匹配的对应括号
" set matchtime=2 " 短暂跳转到匹配括号的时间
set magic " 设置魔术
set hidden " 允许在有未保存的修改时切换缓冲区，此时的修改由 vim 负责保存
set guioptions-=T " 隐藏工具栏
set guioptions-=m " 隐藏菜单栏
set smartindent " 开启新行时使用智能自动缩进
set backspace=indent,eol,start
" 不设定在插入状态无法用退格键和 Delete 键删除回车符
set cmdheight=1 " 设定命令行的行数为 1
set laststatus=2 " 显示状态栏 (默认值为 1, 无法显示状态栏)
set statusline=\ %<%F[%1*%M%*%n%R%H]%=\ %y\ %0(%{&fileformat}\ %{&encoding}\ %c:%l/%L%)\ 
" 设置在状态行显示的信息
set foldenable " 开始折叠
set foldmethod=syntax " 设置语法折叠
set foldcolumn=0 " 设置折叠区域的宽度
setlocal foldlevel=1 " 设置折叠层数为
" set foldclose=all " 设置为自动关闭折叠 
" nnoremap <space> @=((foldclosed(line('.')) < 0) ? 'zc' : 'zo')<CR>
" 用空格键来开关折叠

" UTF-8 编码
	set encoding=utf-8
	set termencoding=utf-8
	set formatoptions+=mM
	set fencs=utf-8,gbk

" Tab操作快捷方式!
	nnoremap <C-TAB> :tabnext<CR>
	nnoremap <C-S-TAB> :tabprev<CR>


" Python 文件的一般设置，比如不要 tab 等
	autocmd FileType python set tabstop=4 shiftwidth=4 expandtab
	autocmd FileType python map <F12> :!python %<CR>

"-----------------------------------------------------------------
" plugin - NERD_tree.vim 以树状方式浏览系统中的文件和目录
" :ERDtree 打开NERD_tree :NERDtreeClose 关闭NERD_tree
" o 打开关闭文件或者目录 t 在标签页中打开
" T 在后台标签页中打开 ! 执行此文件
" p 到上层目录 P 到根目录
" K 到第一个节点 J 到最后一个节点
" u 打开上层目录 m 显示文件系统菜单（添加、删除、移动操作）
" r 递归刷新当前目录 R 递归刷新当前根目录
"-----------------------------------------------------------------
" F3 NERDTree 切换
map <F3> :NERDTreeToggle<CR>
imap <F3> <ESC>:NERDTreeToggle<CR>
------------------------------------ Linux命令行快捷键 ---------------------------------------------- 
	ctrl + ? 撤消前一次输入
	ctrl + c 另起一行
	ctrl + r 输入单词搜索历史命令
	ctrl + u 删除光标前面所有字符相当于VIM里d shift+^
	ctrl + k 删除光标后面所有字符相当于VIM里d shift+$

删除
	ctrl + d 删除光标所在位置上的字符相当于VIM里x或者dl
	ctrl + h 删除光标所在位置前的字符相当于VIM里hx或者dh
	ctrl + k 删除光标后面所有字符相当于VIM里d shift+$
	ctrl + u 删除光标前面所有字符相当于VIM里d shift+^
	ctrl + w 删除光标前一个单词相当于VIM里db
	ctrl + y 恢复ctrl+u上次执行时删除的字符
	ctrl + ? 撤消前一次输入
	alt + r 撤消前一次动作
	alt + d 删除光标所在位置的后单词

移动
	ctrl + a 将光标移动到命令行开头相当于VIM里shift+^
	ctrl + e 将光标移动到命令行结尾处相当于VIM里shift+$
	ctrl + f 光标向后移动一个字符相当于VIM里l
	ctrl + b 光标向前移动一个字符相当于VIM里h
	ctrl + 方向键左键 光标移动到前一个单词开头
	ctrl + 方向键右键 光标移动到后一个单词结尾
	ctrl + x 在上次光标所在字符和当前光标所在字符之间跳转
	alt + f 跳到光标所在位置单词尾部

替换
	ctrl + t 将光标当前字符与前面一个字符替换
	alt + t 交换两个光标当前所处位置单词和光标前一个单词
	alt + u 把光标当前位置单词变为大写
	alt + l 把光标当前位置单词变为小写
	alt + c 把光标当前位置单词头一个字母变为大写
	^oldstr^newstr 替换前一次命令中字符串

历史命令编辑
	ctrl + p 返回上一次输入命令字符
	ctrl + r 输入单词搜索历史命令
	alt + p 输入字符查找与字符相接近的历史命令
	alt + > 返回上一次执行命令

其它
	ctrl + s 锁住终端
	ctrl + q 解锁终端
	ctrl + l 清屏相当于命令clear
	ctrl + c 另起一行
	ctrl + i 类似TAB健补全功能
	ctrl + o 重复执行命令
	alt + 数字键 操作的次数

