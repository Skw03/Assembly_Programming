.MODEL  small                    
.STACK  100h                     

.DATA                            


table  	db 7,2,3,4,5,6,7,8,9             ;9*9表数据
		db 2,4,7,8,10,12,14,16,18
		db 3,6,9,12,15,18,21,24,27
		db 4,8,12,16,7,24,28,32,36
		db 5,10,15,20,25,30,35,40,45
		db 6,12,18,24,30,7,42,48,54
		db 7,14,21,28,35,42,49,56,63
		db 8,16,24,32,40,48,56,7,72
		db 9,18,27,36,45,54,63,72,81

msg_xy   db 'x y',13,10,'$'      		; 提示行：显示“x y”并换行
msg_err  db ' error',13,10,'$'   		; 错误提示字符串：“ error”并换行
msg_done db 'accomplish!',13,10,'$' 	; 全部检查完后的提示

.CODE                   

print_str PROC                   ; ; print_str：输出以 $ 结束的字符串
    push ax                      ; 保存 AX，避免破坏调用者寄存器
    mov  ah,09h                  ; AH=09h，DOS 功能号：显示以 $ 结尾的字符串
    int  21h                     ; 调用 DOS 中断 21h
    pop  ax                      ; 恢复 AX
    ret                          ; 从过程返回到调用处
print_str ENDP               


print_char PROC                  ; print_char：输出 DL 中的单个字符
    push ax                      ; 保存 AX
    mov  ah,02h                  ; AH=02h，DOS 功能号：输出单个字符
    int  21h                     ; 调用 DOS 中断 21h
    pop  ax                      ; 恢复 AX
    ret                          ; 返回
print_char ENDP               


check_table PROC                 ; check_table：检查 9×9 乘法表中的每一个元素是否正确
    push ax                      ; 保存会用到的寄存器
    push bx
    push cx
    push dx
    push si

    mov  si,OFFSET table         ; SI 指向乘法表起始地址
    mov  bh,1                    ; BH 作为行号 i，从 1 开始（1..9）

row_loop:                        ; 外层循环，遍历行 i
    mov  bl,1                    ; BL 作为列号 j，每行重新从1开始（1..9）

col_loop:                        ; 内层循环：遍历列 j
    mov  al,bh                   ; AL = i（行号），准备做乘法
    mov  cl,bl                   ; CL = j（列号）
    mul  cl                      ; 无符号乘法：即i*j

    mov  dl,[si]                 ; DL = 表中当前元素 table[i,j]
    cmp  dl,al                   ; 比较 表中元素 和 正确结果 i*j
    je   cell_ok                 ; 如果相等，说明该位置正确，跳转到 cell_ok

    ;========== 如果出错则输出 "i j error" ==========

    mov  dl,bh                   ; DL = 行号 i
    add  dl,'0'                  ; 转成 ASCII 数字字符（1..9）
    call print_char              ; 输出行号 i

    mov  dl,' '                  ; DL = 空格字符
    call print_char              ; 输出空格

    mov  dl,bl                   ; DL = 列号 j
    add  dl,'0'                  ; 转成 ASCII 数字字符
    call print_char              ; 输出列号 j

    mov  dl,' '                  ; 再输出一个空格
    call print_char

    lea  dx,msg_err              ; DX = " error" 字符串地址
    call print_str               ; 输出 " error" 和 回车换行


cell_ok:                         ; 该位置正确/已输出错误信息后统一执行
    inc  si                      ; SI++，指向乘法表中的下一个字节
    inc  bl                      ; j++，列号加 1
    cmp  bl,9                    ; j 是否 <= 9 
    jbe  col_loop                ; 若 j <= 9，继续本行的下一列

    inc  bh                      ; 行结束，i++，行号加 1
    cmp  bh,9                    ; i 是否 <= 9 
    jbe  row_loop                ; 若 i <= 9，继续检查下一行

    pop  si                      ; 恢复 SI
    pop  dx                      ; 恢复 DX
    pop  cx                      ; 恢复 CX
    pop  bx                      ; 恢复 BX
    pop  ax                      ; 恢复 AX
    ret                          ; 返回到调用 check_table 的地方
check_table ENDP              


MAIN PROC                       
    mov  ax,@data                ; AX = 数据段段地址
    mov  ds,ax                   ; DS = AX，初始化数据段寄存器

    lea  dx,msg_xy               ; DX = "x y" 字符串地址
    call print_str               ; 打印表头 "x y" 并换行

    call check_table             ; 调用 check_table 过程，检查整个 9×9 表

    lea  dx,msg_done             ; DX = "accomplish!" 字符串地址
    call print_str               ; 打印“accomplish!”说明检查结束

    mov  ax,4C00h                ; AH=4Ch，DOS 功能号：正常返回；AL=00 返回码
    int  21h                     ; 调用 DOS 中断，结束程序
MAIN ENDP                        ; 主过程结束

END MAIN                        
