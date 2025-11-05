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



