.MODEL small			; 定义内存模型为small
.STACK 100h				; 申请256字节栈空间

.CODE					; 代码段开始
start:					; 程序入口位置
    mov  ax, @data      ; 初始化数据段
    mov  ds, ax			; 将ax的值加载到数据段ds

    mov  dl, 'a'        ; DL存放当前要输出的字符，初始为'a'
    mov  cx, 2          ; 外层循环次数 = 2行

outer_loop:				; 外层循环开始
    push cx             ; 保存外层计数器
    mov  cx, 13         ; 内层计数，每行 13 个字符

inner_loop:				; 内层循环开始
    mov  ah, 2          ; DOS功能号=2 （输出字符）
    int  21h            ; 调用DOS，显示 DL中的字符
    inc  dl             ; DL++，下一个字符
    dec  cx             ; CX--，计数减一
    jnz  inner_loop     ; 若 CX ≠ 0，则继续输出下一个字母

    push dx             ; 保存当前 DX（其中 DL 是下一行首字符 'n'）
    mov  ah, 2			; DOS功能号=2 （输出字符）
    mov  dl, 13         ; 输出 CR（回车）
    int  21h			; 光标回到行首的位置
    mov  dl, 10         ; 输出 LF（换行）
    int  21h			; 光标从当前行下移一行
    pop  dx             ; 恢复 DL='n'，保证下一行正常从 'n' 开始

    pop  cx             ; 取回外层计数器
    dec  cx             ; 外层循环计数减一
    jnz  outer_loop     ; 若还没结束，继续下一行

    mov  ax, 4C00h      ; 程序正常返回 DOS
    int  21h
END start
