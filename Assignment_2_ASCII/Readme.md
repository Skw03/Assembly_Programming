# Assignment 2 ASCII

## 通过LOOP指令实现小写英文字母的输出

汇编代码如下：

```
.MODEL small           ; 定义内存模型为small
.STACK 100h            ; 申请256字节栈空间

.CODE                  ; 代码段开始
start:                 ; 程序入口位置

    mov  ax, @data     ; 把数据段基址的段地址装入AX
    mov  ds, ax        ; 将ax的值加载到数据段ds
    mov  dl, 'a'       ; DL存放放要输出的字符，初始为 'a'
    mov  cx, 2         ; 外层循环计数：总共要打印 2 行
	
	
outer_loop:            ; 外层循环开始
    push cx            ; 保护外层 CX
    mov  cx, 13        ; 内层循环计数：每行 13 个字符
	
	
inner_loop:            ; 内层循环开始
    mov  ah, 2         ; DOS 功能号=2（显示一个字符到标准输出）
    int  21h           ; 调用 DOS：输出 DL 中的字符
    inc  dl            ; 下一个字符
    loop inner_loop    ; CX=CX-1；若 CX≠0 则跳回 inner_loop

	push dx			   ; 保存当前字符
    mov  ah, 2         ; 输出回车换行：先 CR(13)
    mov  dl, 13		   ; 输出CR
    int  21h		   ; 光标回到当前这一行的行首
    mov  dl, 10        ; 再 LF(10)
    int  21h		   ; 光标从当前行下移一行
	pop dx 			   ; 恢复DL=‘n'

    pop  cx            ; 取回外层 CX
    loop outer_loop    ; 外层：CX=CX-1；若≠0 继续下一行

    mov  ax, 4C00h     ; 退出到 DOS，返回码=00
    int  21h

END start              ; 结束汇编
```

1. 执行命令masm ASCII_~1.asm, Object filename选项回车，表示接受默认文件名，Source listing 选项回车，表示不生产源代码列表文件， Cross-reference 回车，表示不生成交叉引用表。作用是使用编译器将汇编语言的.asm源文件编译成.obj文件。
     <img width="1726" height="1080" alt="image" src="https://github.com/user-attachments/assets/c17986aa-a8e5-490d-9a48-9b366aafea1a" />
2. 执行命令link ASCII_~1.obj,Run File 选项回车，表示接受默认文件名，List File 选项回车，表示不生成列表文件，Libraries 选项回车，表示不链接任何额外的库文件，采用默认设置。这一步通过连接器将编译生成的目标文件链接为.exe文件。
