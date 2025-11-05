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

1. 执行命令`masm ASCII_~1.asm`, Object filename选项回车，表示接受默认文件名，Source listing 选项回车，表示不生产源代码列表文件， Cross-reference 回车，表示不生成交叉引用表。作用是使用编译器将汇编语言的.asm源文件编译成.obj文件。
     <img width="1726" height="1080" alt="image" src="https://github.com/user-attachments/assets/c17986aa-a8e5-490d-9a48-9b366aafea1a" />
2. 执行命令`link ASCII_~1.obj`,Run File 选项回车，表示接受默认文件名，List File 选项回车，表示不生成列表文件，Libraries 选项回车，表示不链接任何额外的库文件，采用默认设置。这一步通过连接器将编译生成的目标文件链接为.exe文件。
     <img width="1374" height="357" alt="image" src="https://github.com/user-attachments/assets/9dc3f5c4-3d07-4f76-b3bc-c1fe396f28a1" />
3. 执行命令`ASCII_~1`.exe,运行程序
   
   	<img width="620" height="144" alt="image" src="https://github.com/user-attachments/assets/fa3cae66-7fe3-4594-81aa-351b1421f524" />

## 小结

1. 关于 CX 寄存器 与 PUSH/POP

* CX 寄存器的核心角色：在循环控制中，CX 寄存器充当着内置的循环计数器。LOOP 指令会自动递减 CX 的值并判断其是否为零，这简化了循环结构的编写。

* PUSH/POP 的保障作用：在嵌套循环或调用子程序等场景中，PUSH 和 POP 指令用于保护和恢复寄存器的现场。通过将外层循环的 CX 值等关键数据临时压入栈中，并在内层循环结束后弹出，确保了各层循环的执行逻辑不会互相干扰。

2. 关于 CR (13) 与 LF (10)

为了在屏幕上开始新的一行，通常需要连续输出这两个字符（例如 CR, LF 或 LF, CR，取决于系统）。通过 AH=02h 逐个输出它们，让我对“换行”这一在高级语言中简单的操作，在底层是如何由两个精确的步骤构成有了更深刻的认识。

## 通过条件跳转指令实现小写英文字母的输出

汇编代码如下：
```
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
```
1. 执行命令`masm JUMP_A~1.asm`, Object filename选项回车，表示接受默认文件名，Source listing 选项回车，表示不生产源代码列表文件， Cross-reference 回车，表示不生成交叉引用表。作用是使用编译器将汇编语言的.asm源文件编译成.obj文件。
   	 <img width="1727" height="1080" alt="image" src="https://github.com/user-attachments/assets/a3027024-257a-45b6-ab81-ff1529523e61" />

2. 执行命令`link JUMP_A_~1.obj`,Run File 选项回车，表示接受默认文件名，List File 选项回车，表示不生成列表文件，Libraries 选项回车，表示不链接任何额外的库文件，采用默认设置。这一步通过连接器将编译生成的目标文件链接为.exe文件。
     <img width="1337" height="441" alt="image" src="https://github.com/user-attachments/assets/a39fe643-059a-446f-813c-c9988300820f" />

3. 执行命令`JUMP_A_~1`.exe,运行程序
   
	 <img width="520" height="158" alt="image" src="https://github.com/user-attachments/assets/f29ccf4a-197b-466a-a66b-940f164af7a4" />

## 小结
`DEC`（递减）和 `JNZ`（非零跳转）是汇编语言中实现循环和条件判断的一对基础且强大的指令组合。
* DEC 指令：充当循环计数器。它通过对指定操作数进行减 1 操作，来更新循环的进度。

* JNZ 指令：充当流程控制器。它检查上一条指令执行后的结果是否不为零，并据此决定是跳出循环还是继续执行。

## 通过C语言实现并查看反汇编代码
C语言代码如下：
```
#include <stdio.h>

int main() 
{
    char ch = 'a';
    for (int line = 0; line < 2; ++line) 
	{     
        for (int i = 0; i < 13; ++i) 
		{          
            putchar(ch);
            ++ch;
        }
        putchar('\r');                          
        putchar('\n');                         
    }
    return 0;
}
```
部分反汇编代码：
	<img width="1727" height="1080" alt="image" src="https://github.com/user-attachments/assets/8b849484-b3ab-45ed-ac7c-7dcfbce0a08e" />
	<img width="1029" height="775" alt="image" src="https://github.com/user-attachments/assets/08a77248-bfc7-4fb8-a949-5a74a95a8fe6" />
	<img width="1033" height="705" alt="image" src="https://github.com/user-attachments/assets/2a1386ee-e28c-4cd6-9137-92266e196cae" />
	<img width="931" height="740" alt="image" src="https://github.com/user-attachments/assets/ab4f9ca0-332c-42b3-bb40-386bb99f5a91" />

部分反汇编代码解释：

1. `076C:0000 0E PUSH CS`
   将代码段寄存器CS的值压入栈
   
2. '076C:0001 1F POP DS'
   把栈顶弹到DS，使DS=CS。这样数据段和代码段一致

3. `076C:0002 BA 0E00 MOV DX 000E`
   将0x000E移动到DX，设置DX为数据段的某个偏移地址

4. `076C:0005 B4 09 MOV AH,09`
   设置DOS中断21h的功能号为09h-输出字符串

5.`076C:0007 CD 21INT 21h`
   调用DOS中断21h,执行字符串输出

6. `076C:0007 BB 014C MOV AX 4C01`
    将4C01移动到AX，调用DOS的程序结束功能

7.`076C:000C CD 21 INT 21h`
   调用DOS中断21h,结束程序

