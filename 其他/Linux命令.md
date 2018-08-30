回声：

`echo content`

echo创建文件：

`echo > filename`		>表示重定向，这里创建的文件的内容为空

`echo >> filename`	>>表示追加

`echo content > filename`

`echo content >> filename`

vim操作：

定位到指定行	`行数gg`

删除当前行	`dd`

显示和关闭行数	`vim .vimrc -> set nu 或者 set nonu`

显示和关闭高亮语法	`vim .vimrc -> syntax on 或者 syntax off`

设置缩Tab键为4个空格	`vim .vimrc -> set ts=4`

映射快捷键	输入模式	：`inoremap 键盘键 映射内容`	命令模式：	`map 键盘键 映射内容`