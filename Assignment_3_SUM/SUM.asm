.MODEL small                 	; 定义程序的内存模型为small
.STACK 100h                  	; 定义栈区大小为256字节

.DATA                        	; 数据段开始
msgReg   db 'Reg(AX): $'     	; 标签字符串：来自寄存器 AX
msgData  db 'Data(sum): $'   	; 标签字符串：来自数据段变量 sum
msgStack db 'Stack (top): $'  	; 标签字符串：来自栈顶

sum      DW 0                	; 数据段变量：保存求和结果
buf      DB 7 DUP (?)        	; 十进制打印缓冲 -- 定义7个字节的缓冲区


.CODE                        	; 代码段开始
start:                       	; 程序入口
    mov     ax, @data        	; @是masm伪符号，表示数据段的段地址
    mov     ds, ax           	; 把ax的内容传入到ds中

    xor     ax, ax           	; 将累加寄存器ax置零 （ax=0）
    mov     bx, 1d            	; 将数据寄存器bx置为1，当前加数从1开始
    mov     cx, 100d          	; CX计数寄存器 = 100，循环100次

sum_loop:                    	; 求和循环起点
    add     ax, bx           	; AX += BX，把当前加数加到累加器
    inc     bx               	; BX++，准备下一个加数
    loop    sum_loop         	; CX--，非 0 则跳回 sum_loop；循环结束后 AX=5050

    mov     sum, ax          	; 把结果 5050 存入数据段变量 sum
    push    ax               	; 同时把结果压入栈顶


								;从寄存器 AX 打印
	push	ax					
    lea     dx, msgReg       	; 寄存器AX装入到dx中的偏移地址
    mov     ah, 9            	; AH=9：DOS 显示以 '$' 结尾的字符串
    int     21h              	; 调用 DOS 打印标签（不换行）
	pop		ax 
	
    mov     byte ptr [buf+6], '$'  ; 在缓冲区末尾写入 '$' 作为字符串终止符
    lea     di, buf+6              ; DI 指向 '$' 位置，准备倒序写入数字
    mov     bx, 10d                 ; BX=10，十进制除数

convA:                         	 ; 十进制转换（寄存器 AX 的值）
    xor     dx, dx               ; 清 DX，准备进行 16 位除法 DX:AX / 10
    div     bx                   ; AX=商，DX=余数(0..9)
    dec     di                   ; DI 左移一格，定位要写入当前数字的位置
    add     dl, '0'              ; 余数(0..9) 转为 ASCII 字符
    mov     [di], dl             ; 把当前数字字符写入缓冲
    or      ax, ax               ; 检查商是否为 0
    jnz     convA                ; 商不为 0：继续分解更高位

    mov     dx, di               ; DX 指向数字串首字符
    mov     ah, 9                ; AH=9：打印以 '$' 结尾的字符串
    int     21h                  ; 打印数字

    mov     ah, 2                ; AH=2：单字符输出
    mov     dl, 13               ; DL=13 (CR 回车)
    int     21h                  ; 输出 CR
    mov     dl, 10               ; DL=10 (LF 换行)
    int     21h                  ; 输出 LF（换行结束该行）

								 ;从数据段变量 sum 打印
	lea		dx,msgData
	mov		ah,9
	int		21h
	mov		ax,sum
	mov		byte ptr[buf+6],'$'
	lea		di,buf+6
	mov		bx,10d
	

convB:                           ; 十进制转换（来自数据段的值）
    xor     dx, dx               ; 清 DX，准备除法 DX:AX / 10
    div     bx                   ; AX=商，DX=余数
    dec     di                   ; DI 左移，准备写入该位
    add     dl, '0'              ; 余数转 ASCII
    mov     [di], dl             ; 写入该位字符
    or      ax, ax               ; 商是否为 0？
    jnz     convB                ; 不是 0 继续分解

    mov     dx, di               ; DX 指向数字串首字符
    mov     ah, 9                ; AH=9：打印数字串
    int     21h                  ; 调用 DOS 打印数字

    mov     ah, 2                ; AH=2：单字符输出
    mov     dl, 13               ; CR
    int     21h                  ; 输出 CR
    mov     dl, 10               ; LF
    int     21h                  ; 输出 LF

								 ;从栈顶弹回打印
	lea		dx,msgStack
	mov		ah,9
	int 	21h
	
	pop		ax
	
	mov		byte ptr [buf+6],'$'
	lea		di,buf+6
	mov		bx,10d

convC:                           ; 十进制转换（来自栈的值）
    xor     dx, dx               ; 清 DX，准备除法 DX:AX / 10
    div     bx                   ; AX=商，DX=余数
    dec     di                   ; DI 左移，准备写入该位
    add     dl, '0'              ; 余数转 ASCII
    mov     [di], dl             ; 写入该位字符
    or      ax, ax               ; 商是否为 0？
    jnz     convC                ; 不是 0 继续分解

    mov     dx, di               ; DX 指向数字串首字符
    mov     ah, 9                ; AH=9：打印数字串
    int     21h                  ; 调用 DOS 打印数字

    mov     ah, 2                ; AH=2：单字符输出
    mov     dl, 13               ; CR
    int     21h                  ; 输出 CR
    mov     dl, 10               ; LF
    int     21h                  ; 输出 LF

    mov     ax, 4C00h            ; AH=4Ch 终止进程，AL=返回码 0
    int     21h                  ; 回到 DOS

END start                       ; 程序结束/入口标记
