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

## 通过C语言实现并查看反汇编代码

C语言代码如下：
```
#include <stdio.h>

int main() {
    printf("九九乘法表：\n");
    
    for (int i = 1; i <= 9; i++) {
        for (int j = 1; j <= i; j++) {
            printf("%d×%d=%-2d ", j, i, i * j);
        }
        printf("\n");
    }
return 0;
}
```
通过Ghidrac查看反汇编代码：
<img width="2840" height="1563" alt="image" src="https://github.com/user-attachments/assets/c038e466-9c7e-4de8-a251-5e326ccdd5c2" />

部分反汇编代码：
```
;---------------- MUL9.c:3 ----------------
140001458  e8 33 01
		      00 00     CALL 	__main               	; 调用编译器生成的初始化函数 __main()，完成C运行时环境初始化
;---------------- MUL9.c:4 ----------------
14000145d  48 8d 05
		   9c 2b 00		LEA  	RAX, [DAT_140004000] 	; 把字符串常量 DAT_140004000 的地址装入 RAX（LEA=取地址，不访问内存）
		   00

140001464  48 89 c1    	MOV  	_Argc, RAX          	; 把 RAX 中的地址放入 RCX（IDA 起名为 _Argc）

140001467  e8 bc 14	 	CALL 	puts  					; 调用 puts(_Str)，打印开头标题字符串
		   00 00                    

;---------------- MUL9.c:6 外层循环初始化 ----------------
14000146c  c7 45 fc		MOV 	dword ptr [RBP + i], 0x1	; 把局部变量 i 设为 1，等价于 C 代码：i = 1;
		   01 00 00
		   00 

;---------------- 跳到外层 for 条件检查处 ----------------
140001473  eb 45     	JMP  	LAB_1400014ba       	; 无条件跳转到 0x1400014ba，去做外层 for(i<10) 的条件判断

;---------------- 内层循环入口标签 ----------------
						LAB_140001475                 	; 对应内层 for 的“初始化”位置

;---------------- MUL9.c:7 内层循环初始化 j=1 --------
140001475  c7 45 f8		MOV 	dword ptr [RBP + j], 0x1	; 把局部变量 j 设为 1，等价于 C：j = 1;
		   01 00 00
		   00

14000147c  eb 26        JMP 	LAB_1400014a4        	; 跳到内层循环的条件判断处（j <= i ?）

;---------------- 内层循环体标签 ----------------
						LAB_14000147e                  	; 真正循环体开始位置

;---------------- MUL9.c:8 计算 i*j 并准备 printf 参数 --------
14000147e  8b 45 fc    	MOV  	EAX, dword ptr [RBP + i]	; 把 i 的值读到 EAX 中，EAX = i
140001481  0f af 45  	IMUL 	EAX, dword ptr [RBP + j]	; 有符号整数乘法：EAX = EAX * j = i * j
		   f8
140001485  89 c1       	MOV  	_Argc, EAX					; 把乘积 i*j 放到 ECX（_Argc）中，暂存，之后会作为 printf 的第4个参数传给 R9D
140001487  44 8b 45		MOV  	_Env, dword ptr [RBP + i]	; 把 i 的值读到 R8D 中（_Env 是 R8D），这是 printf 的第3个参数
		   fc          
14000148b  8b 55 f8    	MOV  	_Argv, dword ptr [RBP + j]	; 把 j 的值读到 EDX 中（_Argv 是 EDX），这是 printf 的第2个参数
14000148e  48 8d 05		LEA  	RAX, [DAT_140004013]		; 取出格式字符串 DAT_140004013 的地址到 RAX
		   7e 2b 00											; 这个字符串很可能是 "%d*%d=%2d " 之类的格式
		   00 

140001495  41 89 c9    	MOV  	R9D, _Argc					; 把之前暂存在 ECX(_Argc) 中的乘积 i*j 复制到 R9D，
140001498  48 89 c1    	MOV  	_Argc, RAX					; 把格式字符串地址 RAX 放进 RCX（_Argc），作为 printf 的第1个参数 _Format
14000149b  e8 60 11		CALL 	printf						; 调用 printf(_Format, j, i, i*j);
		   00 00      										; 对应 C 代码：printf("%d*%d=%2d ", j, i, i*j);

;---------------- MUL9.c:7 内层循环的 j++ ----------------
1400014a0  83 45 f8		ADD 	dword ptr [RBP + j], 0x1	; j 自增 1：j = j + 1;
		   01          
;---------------- 内层循环条件判断 ----------------
						LAB_1400014a4                     	; 内层 for 的条件检查位置
1400014a4  8b 45 f8    	MOV  	EAX, dword ptr [RBP + j]	; 取出当前 j 的值到 EAX
1400014a7  3b 45 fc    	CMP  	EAX, dword ptr [RBP + i]	; 比较 j 与 i：实际上是做 j - i，用来设置标志位

1400014aa  7e d2        JLE  	LAB_14000147e				; 如果 j <= i（小于等于，ZF=1 ），
															; 则跳回 LAB_14000147e 继续执行循环体
															; 对应 C：if (j <= i) goto loop_body;

;---------------- MUL9.c:10 一行结束，输出换行 ----------------
1400014ac  b9 0a 00	 	MOV  	_Argc, 0xa					; 把常数 0x0A（十进制 10，ASCII 换行 '\n'）放入 ECX（_Argc），
		   00 00      										; 准备作为 putchar 的参数 _Ch
1400014b1  e8 6a 14 00 00       CALL putchar				; 调用 putchar(10)，输出 '\n'，结束当前一行的乘法表
```
## 九九乘法表纠错

汇编代码如下：
```
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
```
1. 执行命令`masm MUL9_C.asm`, Object filename选项回车，表示接受默认文件名，Source listing 选项回车，表示不生产源代码列表文件， Cross-reference 回车，表示不生成交叉引用表。作用是使用编译器将汇编语言的.asm源文件编译成.obj文件。
 <img width="1726" height="1080" alt="image" src="https://github.com/user-attachments/assets/bd47873b-9612-4068-8670-000a8bde27c5" />

2. 执行命令`link MUL9_C.obj`,Run File 选项回车，表示接受默认文件名，List File 选项回车，表示不生成列表文件，Libraries 选项回车，表示不链接任何额外的库文件，采用默认设置。这一步通过连接器将编译生成的目标文件链接为.exe文件。
<img width="1727" height="438" alt="image" src="https://github.com/user-attachments/assets/d956d742-e118-4df4-9c44-65c6894231d9" />

3. 执行命令`MUL9_C.exe`,运行程序
  <img width="1727" height="443" alt="image" src="https://github.com/user-attachments/assets/5e3ed879-6aa4-4abd-aa33-6e9e711eae8c" />

## 小结

