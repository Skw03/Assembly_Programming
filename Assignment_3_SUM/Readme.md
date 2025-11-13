# Assignment 3_SUM

## 计算1~100的累加和

汇编代码如下：

```
..MODEL small                 	; 定义程序的内存模型为small
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

```
1. 执行命令`masm SUM.asm`, Object filename选项回车，表示接受默认文件名，Source listing 选项回车，表示不生产源代码列表文件， Cross-reference 回车，表示不生成交叉引用表。作用是使用编译器将汇编语言的.asm源文件编译成.obj文件。
   <img width="1727" height="1080" alt="image" src="https://github.com/user-attachments/assets/70116dd0-105e-46bb-a26c-b85f9a624a9e" />

2. 执行命令`link SUM.obj`,Run File 选项回车，表示接受默认文件名，List File 选项回车，表示不生成列表文件，Libraries 选项回车，表示不链接任何额外的库文件，采用默认设置。这一步通过连接器将编译生成的目标文件链接为.exe文件。
   <img width="1727" height="443" alt="image" src="https://github.com/user-attachments/assets/f6a2412c-5d65-4c46-8035-d3c513191730" />

3. 执行命令`SUM.exe`,运行程序
   <img width="1727" height="448" alt="image" src="https://github.com/user-attachments/assets/0480d3f3-20fc-43e3-a793-9e7d4b03b0b7" />

   
## 小结

1. `buf db xx DUP(?)` --数据缓冲区--在数据段中预留一块连续的内存空间(xx为想要预留的字节数)。 DUP(?)表示存放转换后的十进制数字的ASCII字符，类似于在高级语言中声明一个字符数组。
2. `Lea` --取有效地址--用于计算一个内存地址的有效地址，并将计算结果直接存入目标寄存器，而不是从内存中读取数据。在程序中`lea di, buf+6`将缓冲区中的第7个字节的地址存入di寄存器，这使得di寄存器成为一个指针，后续操作通过[di]来修改缓冲区中该位置的内容。
3. `XOR`--异或操作--对两个操作数进行按位异或运算。在程序中`xor dx,dx`这是一个非常景点的将寄存器清零的操作，因为任何书与自己异或结果都为0，这在做除法`div`前是必须的步骤。
4. `DIV`--无符号除法--执行无符号除法，当除数为16位时，它把DX：AX组成的32位数作为被除数，除以指定的16位寄存器。结果，商在ax中，余数在dx中。在这个过程中，不断除以10，每次得到的余数就是十进制的个位。
5. `DEC`--递减--将操作数的值减1，程序中`dec di`并非用于循环计数，而是为了将指针di向内存低地址方向移动一个字节。这样确保了每次转换出新数字字符被存放在前一个位置，实现了从右向左填充缓冲区。
6. `OR`--或操作-- 对两个操作数进行按位或运算。
7. `Byte ptr`--类型指明符-- 明确告诉汇编器，在后续的内存操作中，是以字节(8位)为单位进行访问的

## 通过C语言实现并查看反汇编代码

C语言代码如下：
```
#include <stdio.h>

int main() 
{
    int sum = 0;
    for (int i = 1; i <= 100; i++) {
        sum += i;
    }
    printf("%d\n", sum);

    return 0;
}
```

部分反汇编代码：
<img width="1726" height="1080" alt="image" src="https://github.com/user-attachments/assets/3c0f4ad2-422d-4a5e-921c-19cccd23247e" />
<img width="1726" height="812" alt="image" src="https://github.com/user-attachments/assets/30b0b915-5d21-432e-b500-2ecb1829951b" />

部分反汇编代码解释如下：

`076c:0000 0E PUSH CS` 将当前代码段寄存器的值压入栈中

`076C:0001 1F POP DS` 从栈中弹出一个值并存储到数据段寄存器(DS)

`076C:0002 BA0E00 MOV DX,000E` 将常熟000E移动到数据寄存器DX中

`076C:0005 B409 MOV AH,09` 将09移动到寄存器AH中，通常用于输出字符串

`076C:0007 CD21 INT 21` 调用DOS中断21h,处理系统调用--如输出字符串

`076C:0009 B8014C MOV AX,4C01` 将4C01移动到AX寄存器--通常用于退出程序

`076C:000C CD21 INT 21` 再次调用DOS中断21h--程序的正常退出

`076C:000E 54 PUSH SP` 将堆栈指针(SP)的值压入栈中

`076C:00XX xxxx DB XX` 定义字节(ASCII字符或数据)

`076C:0011 7320 JNB 0033` 如果无法进位标志(CF)被设置，则跳转到地址0033

`076C:0013 7072 JO 0087` 如果有溢出标志(OF)被设置，则跳转到地址0087

`076C:0017 7261 jb 007a` 如果CF被设置，则跳转到地址007A

`076C:001A 206361 AND [BP+DI+61],AH` 对内存地址[BP+DI+61]中的值与AH寄存器的值进行按位与操作


## 用户输入 1~100 内的任何一个数，完成对1 ~ n求和后的十进制结果输出

汇编代码如下：
```
.MODEL SMALL                      		; 定义程序的内存模型为small
.STACK 100h                       		; 定义栈区大小为256字节

.DATA                             					 ; 数据段开始
    msg_InputPrompt  	DB 'Input (1-100): $'        ; 输入提示字符串
    msg_Result     		DB 13,10,'Output: $'         ; 输出结果提示字符
  
    number      		DW ?                         ; 保存用户输入的 N
    sum         		DW 0                         ; 保存 1..N 的求和结果(初始化为 0)

.CODE                             
START:                            
    mov  	ax, @data                ; 将数据段地址加载到ax寄存器中
    mov  	ds, ax                   ; 将数据段地址传到ds寄存器
    mov  	es, ax                   ; 将数据段地址传给es寄存器(未使用)

MAIN_LOOP:                        	 ; 主循环：提示→读取→计算→输出→再次提示
    lea  	dx, msg_InputPrompt      ; 将提示字符串的偏移地址存入到dx寄存器中
    mov  	ah, 09h                  ; DOS功能调用，显示字符串
    int  	21h                      ; 执行DOS中断21h,显示提示信息

    xor  	cx, cx                   ; CX 清零，作为当前输入的十进制数值累加器

READ_INPUT:                      
    mov  	ah, 01h                  ; DOS功能调用，读取键盘输入字符
    int  	21h                      ; 调用 DOS，等待按键
	
    cmp  	al, 'q'                  ; 比较是否为小写 q
    je   	EXIT_PROGRAM             ; 若是，跳转到退出流程
    cmp  	al, 'Q'                  ; 比较是否为大写 Q
    je   	EXIT_PROGRAM             ; 若是，跳转到退出流程

    cmp  	al, 0Dh                  ; 比较al中字符是否为回车符
    je   	CALCULATE_SUM            ; 若是结束本次读入并进入求和

    cmp  	al, '0'                  ; 比较是否为0（al<0）
    jb   	READ_INPUT               ; 若是则忽略该字符，继续读取
    cmp  	al, '9'                  ; 比较是否为9（9<al）
    ja   	READ_INPUT               ; 若是则忽略该字符，继续读取

    sub  al, '0'                  ; 将字符转换为数值(减去ASCII码'0')
    xor  bx, bx                   ; bx清零，避免残留脏数据影响后续 add
    mov  bl, al                   ; 转换后的数值存储到bl中
	
    mov  ax, cx                   ; 将当前cx的值存入ax中
    mov  si, 10                   ; 设置SI=10，作为乘数
    mul  si                       ; ax=ax*10
    add  ax, bx                   ; 加上当前输入的数字
    mov  cx, ax                   ; 更新cx为新的累积值
    jmp  READ_INPUT               ; 继续读取下一个键

CALCULATE_SUM:                    ; 
    mov  ax, cx                   ; 将输入的数字存入ax中
    mov  number, ax               ; 将ax的值存入到变量number

    mov  bx, 1                    ; 设置bx=1,从1开始累加
    xor  ax, ax                   ; 将ax清零，作为 sum 累加器

SUM_LOOP:                         
    cmp  bx, number               ; 比较 BX 是否大于输入的数字
    ja   END_SUM_LOOP             ; 若 BX > 输入数字，跳到循环结束
    add  ax, bx                   ; sum += BX
    inc  bx                       ; BX 自增 1
    jmp  SUM_LOOP                 ; 继续循环累加

END_SUM_LOOP:                     
    mov  sum, ax                  ; 将累加和保存到变量 sum

    lea  dx, msg_Result           ; 加载输出消息地址到dx寄存器
    mov  ah, 09h                  ; 调用DOS功能09h,显示字符串
    int  21h                      ; 调用DOS，显示输出消息

    mov  ax, sum                  ; 将累加和存入到ax寄存器中
    call PRINT_DECIMAL            ; 调用十进制打印子程序

    mov  ah, 02h                  ; AH = 02h：输出单个字符（DL）
    mov  dl, 13                   ; DL = 0x0D (CR)
    int  21h                      ; 打印回车
    mov  dl, 10                   ; DL = 0x0A (LF)
    int  21h                      ; 打印换行

    jmp  MAIN_LOOP                ; 回到主循环，继续下一轮输入

EXIT_PROGRAM:                     ; 退出流程
    
    mov  ah, 09h                  ; AH = 09h：打印字符串
    int  21h                      ; 调用 DOS 
    mov  ah, 4Ch                  ; AH = 4Ch：进程终止，返回 DOS
    int  21h                      ; 结束程序（返回码在 AL，未显式设置则为 0）

PRINT_DECIMAL PROC                ; 子程序：以十进制打印 AX（无符号）
    push ax                       ; 保存被调用者寄存器 AX
    push bx                       ; 保存 BX
    push cx                       ; 保存 CX
    push dx                       ; 保存 DX

    xor  cx, cx                   ; CX 作为位数计数器，清零
    mov  bx, 10                   ; BX = 10，作为除数

    cmp  ax, 0                    ; 检查是否为 0
    jne  CONVERT_LOOP             ; 非 0 转换处理
    mov  dl, '0'                  ; 为 0 时直接输出字符 '0'
    mov  ah, 02h                  ; AH = 02h：输出单字符
    int  21h                      ; 打印 '0'
    jmp  PRINT_DONE               ; 跳过一般转换流程

CONVERT_LOOP:                     ; 将 AX 反复除以 10，余数依次入栈
    xor  dx, dx                   ; DX 清零，确保 DX:AX 正确用于除法
    div  bx                       ; DX:AX / 10 -> 商 AX、余数 DX(0..9)
    push dx                       ; 将当前余数压栈（稍后倒序输出）
    inc  cx                       ; 位数 +1
    cmp  ax, 0                    ; 若商不为 0 则继续
    jne  CONVERT_LOOP             ; 继续分解下一位

PRINT_LOOP:                       ; 依次出栈并打印各位字符（高位先出）
    pop  dx                       ; 取出一位余数到 DX（DL 有效）
    add  dl, '0'                  ; 0..9 转为 '0'..'9'
    mov  ah, 02h                  ; AH = 02h：输出单字符
    int  21h                      ; 打印该数字字符
    loop PRINT_LOOP               ; 循环 CX 次（直到位数用尽）

PRINT_DONE:                       ; 十进制打印结束
    pop  dx                       ; 恢复 DX
    pop  cx                       ; 恢复 CX
    pop  bx                       ; 恢复 BX
    pop  ax                       ; 恢复 AX
    ret                            ; 返回到调用点

PRINT_DECIMAL ENDP                

END START                         

```
1. 执行命令`masm inputsum.asm`, Object filename选项回车，表示接受默认文件名，Source listing 选项回车，表示不生产源代码列表文件， Cross-reference 回车，表示不生成交叉引用表。作用是使用编译器将汇编语言的.asm源文件编译成.obj文件。
   <img width="1727" height="1080" alt="image" src="https://github.com/user-attachments/assets/a62255d0-7211-48de-a1cb-10defbbffb56" />

2. 执行命令`link inputsum.obj`,Run File 选项回车，表示接受默认文件名，List File 选项回车，表示不生成列表文件，Libraries 选项回车，表示不链接任何额外的库文件，采用默认设置。这一步通过连接器将编译生成的目标文件链接为.exe文件。
   <img width="1727" height="448" alt="image" src="https://github.com/user-attachments/assets/d3f91c90-69a7-483c-a08b-3a54c972a835" />

3. 执行命令`inputsum.exe`,运行程序
  <img width="1727" height="700" alt="image" src="https://github.com/user-attachments/assets/52c5c24d-18a9-43f2-b260-d8418d3c570c" />
  
## 小结

1. `lea`--装载有效地址--把内存操作数的计算后地址装进寄存器。语法为`lea reg, mem`(目的地必须是寄存器)
2. `cmp`--比较--执行一次暗中减法OP1-0P2，只设置标志位，不保存结果。常用于条件跳转。语法为`cmp r,r`比较两边大小一致。
3. `je`--相等则跳--比较相等时分支。通常来自前面的cmp结果来决定。
4. `jb`--无符号低于则跳--只用于无符号数的“小于”，触发条件：CF=1。
5. `ja`--无符号大于则跳--只用于无符号数的“大于”，触发条件：CF=0。
6. `RET`--从子程序退回--与`CALL`配对使用，从栈顶弹出返回地址并跳回调用点。
7. `call`--调用子程序--它会把返回地址压栈，跳转到目标地址开始执行子程序，子程序结束时用RET弹出返回地址回到调用点。
