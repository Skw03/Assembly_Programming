; MUL9_T.ASM —— 9×9 下三角乘法表（Call + Ret + 乘法指令）
; 编译：masm mul9_t.asm
; 连接：link mul9_t.obj
; 运行：mul9_t

.MODEL small
.STACK 100h

.DATA
    header   DB 'The 9mul9 table:',13,10,'$'
    crlf    DB 13,10,'$'

.CODE
;--------------------------------------
; print_str: 输出以 $ 结束的字符串
; 入口：DS:DX = 字符串地址
;--------------------------------------
print_str PROC
    push ax
    mov  ah,09h
    int  21h
    pop  ax
    ret
print_str ENDP

;--------------------------------------
; print_u8: 打印 AX 中的无符号十进制整数 (0..255)
; 使用：AX,BX,CX,DX，自行保存和恢复
;--------------------------------------
print_u8 PROC
    push ax
    push bx
    push cx
    push dx

    mov  bx,10          ; 除数 10
    xor  cx,cx          ; 位数计数器

    cmp  ax,0
    jne  pu_div

    ; AX == 0 直接输出 '0'
    mov  dl,'0'
    mov  ah,2
    int  21h
    jmp  pu_done

pu_div:
pu_d1:
    xor  dx,dx          ; ★ 每轮除法前清 DX，防止余数残留
    div  bx             ; DX:AX / 10，AX=商，DX=余数(0..9)
    push dx             ; 把当前这一位压栈
    inc  cx             ; 位数+1
    cmp  ax,0
    jne  pu_d1          ; 商不为0继续

pu_print:
    pop  dx
    add  dl,'0'         ; 0..9 -> '0'..'9'
    mov  ah,2
    int  21h
    loop pu_print       ; 循环 CX 次

pu_done:
    pop  dx
    pop  cx
    pop  bx
    pop  ax
    ret
print_u8 ENDP

;--------------------------------------
; 主程序：打印 1×1~9×9 的下三角乘法表
; 行：i = 1..9 (用 BL)
; 列：j = 1..i (用 CL)
;--------------------------------------
start:
    mov  ax,@data
    mov  ds,ax

    ; 标题
    lea  dx,header
    call print_str

    mov  bl,1           ; i = 1

outer_loop:             ; 外层循环：行
    mov  cl,1           ; j = 1

inner_loop:             ; 内层循环：列
    ; 输出左操作数 i
    mov  al,bl
    xor  ah,ah
    call print_u8

    ; 输出 '*'
    mov  dl,'*'
    mov  ah,2
    int  21h

    ; 输出右操作数 j
    mov  al,cl
    xor  ah,ah
    call print_u8

    ; 输出 '='
    mov  dl,'='
    mov  ah,2
    int  21h

    ; 计算 i * j，结果放入 AX
    mov  al,bl
    xor  ah,ah
    mul  cl             ; 8位乘法：AL*CL -> AX

    ; 为了对齐，小于 10 的结果前面补一个空格
    cmp  ax,10
    jae  no_pad
    push ax             ; ★ 保护乘积
    mov  dl,' '
    mov  ah,2
    int  21h            ; 打一个空格
    pop  ax             ; ★ 恢复乘积
no_pad:
    call print_u8       ; 输出真正的乘积

    ; 每个式子后打印两个空格分隔
    mov  dl,' '
    mov  ah,2
    int  21h
    mov  dl,' '
    mov  ah,2
    int  21h

    inc  cl
    cmp  cl,bl          ; j <= i ?
    jbe  inner_loop

    ; 一行结束，换行
    lea  dx,crlf
    call print_str

    inc  bl
    cmp  bl,10          ; 只打印 1..9 行，bl==10 时退出
    jne  outer_loop

    mov  ax,4C00h
    int  21h
END start
