# Assignment 4_Multiplication_Table

输出九九乘法表

汇编代码如下：
```
.MODEL small                 ; 使用 small 内存模型：代码段和数据段各不超过 64KB
.STACK 100h                  ; 为程序分配 256 字节的栈空间

.DATA
    header   DB 'The 9mul9 table:',13,10,'$' ; 标题字符串，以 $ 结束，前面带 CRLF
    crlf     DB 13,10,'$'                    ; 换行字符串：回车(13)、换行(10)、以及结束符 '$'

.CODE
print_str PROC
    push ax                  ; 保存 AX，避免破坏调用者的 AX
    mov  ah,09h              ; DOS 功能号 09h：显示以 '$' 结束的字符串
    int  21h                 ; 调用 DOS 中断 21h
    pop  ax                  ; 恢复 AX
    ret                      ; 返回调用点
print_str ENDP


print_u8 PROC
    push ax                  ; 保存 AX
    push bx                  ; 保存 BX
    push cx                  ; 保存 CX
    push dx                  ; 保存 DX

    mov  bx,10               ; BX = 10，作为除数
    xor  cx,cx               ; CX = 0，用来统计数字位数

    cmp  ax,0                ; 判断 AX 是否为 0
    jne  pu_div              ; 如果不为 0，走除法过程

							 ; AX == 0 的特殊情况，直接输出字符 '0'
    mov  dl,'0'              ; DL = '0'
    mov  ah,2                ; DOS 功能号 02h：输出字符 DL
    int  21h                 ; 调用 DOS 中断
    jmp  pu_done             ; 打印完 0，直接结束

pu_div:
pu_d1:
    xor  dx,dx               ; 每轮除法前清 DX，保证 DX:AX / 10 正确
    div  bx                  ; 无符号除法：DX:AX / BX，商 -> AX，余数 -> DX (0..9)
    push dx                  ; 把当前得到的一位数值 (0..9) 压栈
    inc  cx                  ; 位数计数器 CX++
    cmp  ax,0                ; 看商是否为 0
    jne  pu_d1               ; 如果商不为 0，继续除下一轮


pu_print:
    pop  dx                  ; 弹出一位到 DX
    add  dl,'0'              ; 把 0..9 转为 '0'..'9' 的 ASCII 码
    mov  ah,2                ; DOS 功能号 02h：输出 DL 中的字符
    int  21h                 ; 调用 DOS 中断输出该数字字符
    loop pu_print            ; CX--，若不为 0 则跳回继续打印下一位

pu_done:
    pop  dx                  ; 恢复 DX
    pop  cx                  ; 恢复 CX
    pop  bx                  ; 恢复 BX
    pop  ax                  ; 恢复 AX
    ret                      ; 返回调用点
print_u8 ENDP


start:
    mov  ax,@data            ; 将数据段基址装入 AX
    mov  ds,ax               ; 初始化 DS，使 DS 指向数据段

    ; 打印标题行
    lea  dx,header           ; DX 指向 header 字符串
    call print_str           ; 调用 print_str 打印标题

    mov  bl,1                ; BL = 1，表示第一行 i = 1

outer_loop:                  ; 外层循环标签：控制行 i
    mov  cl,1                ; 每新的一行，列 j 从 1 开始

inner_loop:                  ; 内层循环标签：控制列 j

    mov  al,bl               ; AL = BL = 当前行号 i
    xor  ah,ah               ; AH = 0，使 AX = i
    call print_u8            ; 打印 i（左操作数）

    mov  dl,'*'              ; DL = '*'
    mov  ah,2                ; DOS 功能号 02h：输出单个字符
    int  21h                 ; 输出 '*'

    mov  al,cl               ; AL = CL = 当前列号 j
    xor  ah,ah               ; AH = 0，使 AX = j
    call print_u8            ; 打印 j（右操作数）

    mov  dl,'='              ; DL = '='
    mov  ah,2                ; 输出 '='
    int  21h

    mov  al,bl               ; AL = i（BL 中的行号）
    xor  ah,ah               ; AH = 0，使 AX = i
    mul  cl                  ; 无符号 8 位乘法：AL * CL -> AX
                              ; 结果 i*j 存在 AX 中 (最大 9*9=81，安全)

    cmp  ax,10               ; 比较 AX 和 10
    jae  no_pad              ; 若 AX >= 10，则不需要补空格
    push ax                  ; 若 AX < 10，为了后面还要打印结果，先保存 AX
    mov  dl,' '              ; DL = ' '（空格）
    mov  ah,2                ; 输出空格
    int  21h
    pop  ax                  ; 取回原来的乘积结果

no_pad:
    call print_u8            ; 输出真正的乘积 i*j

    mov  dl,' '              ; 第一个空格
    mov  ah,2
    int  21h
    mov  dl,' '              ; 第二个空格
    mov  ah,2
    int  21h

    inc  cl                  ; j++
    cmp  cl,bl               ; 比较 j 和 i：当前列是否仍然 <= 当前行
    jbe  inner_loop          ; 如果 j <= i，继续内层循环打印本行下一个式子


    lea  dx,crlf             ; DX 指向 CRLF 字符串
    call print_str           ; 打印回车换行，开始新的一行


    inc  bl                  ; i++（下一行）
    cmp  bl,10               ; 当 BL == 10 时，说明 i 已经从 1..9 都打印完
    jne  outer_loop          ; 若 BL != 10，继续外层循环打印下一行

    mov  ax,4C00h            ; AH = 4Ch，DOS 退出程序；AL = 返回代码 00
    int  21h                 ; 结束程序，返回 DOS
END start

```

1. 执行命令`masm MUL9_T.asm`, Object filename选项回车，表示接受默认文件名，Source listing 选项回车，表示不生产源代码列表文件， Cross-reference 回车，表示不生成交叉引用表。作用是使用编译器将汇编语言的.asm源文件编译成.obj文件。
   <img width="1726" height="1080" alt="image" src="https://github.com/user-attachments/assets/876d3649-e002-4a3f-ad2c-9f6ef20d20b6" />

2. 执行命令`link MUL9_T.obj`,Run File 选项回车，表示接受默认文件名，List File 选项回车，表示不生成列表文件，Libraries 选项回车，表示不链接任何额外的库文件，采用默认设置。这一步通过连接器将编译生成的目标文件链接为.exe文件。
   <img width="1726" height="464" alt="image" src="https://github.com/user-attachments/assets/afd97b5d-5f37-4eb8-af59-65ad4ef6e1cc" />

3. 执行命令`MUL9_T.exe`,运行程序
   <img width="1726" height="562" alt="image" src="https://github.com/user-attachments/assets/8a8c6112-c940-4594-8ed7-1c8fa87ca244" />

## 小结

1. `JNE`--不相等时跳转--检查零标志位ZF=0时跳转。用法为：
   ```
   cmp operand1,operand2  ; 先比较两个操作数
   jne target_label		  ; 如果不相等则跳转
   ```
2. `JAE`--高于或等于时跳转--检查进位标志CF=0时跳转。用法：
   ```
   cmp operand1,operand2  ; 先比较两个无符号数
   jne target_label		  ; 如果 operand1>= operand2则跳转
   ```
3. `JBE`--低于或等于时跳转--检查CF=1或者ZF=1时跳转。用法：
    ```
   cmp operand1,operand2  ; 先比较两个无符号数
   jne target_label		  ; 如果 operand1<= operand2则跳转
   ```
4.  `call`--调用子程序--它会把返回地址压入栈中，跳转到目标地址开始执行子程序，子程序结束时用RET弹出返回地址到调用点。语法：
	```
	call procedure_name		;调用子程序
	```
	
5. `ret`--从子程序退回--从栈中弹出返回地址并跳转回去。
