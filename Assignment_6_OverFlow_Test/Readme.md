# Assignment6_OverFlow Test

## 背景知识

什么是标志寄存器？

标志寄存器本质上不是用来存数据的，而是用来存"状态位"（FLAG）。每当CPU做完一次算数逻辑或逻辑运算时会自动修改这些标志位，用来记录这些运算的结果的状态，比如结果是不是"0"， 是不是"负数"，有没有产生"进位"或"错位"，有没有"溢出"等。在x86里最常见的状态标志位有ZF(Zero,结果是否为0)，SF（Sign,结果符号位--判断是否为负数），CF（Carry,无符号运算时的进位/错位），OF(Overflow,有符号运算时是否溢出)，这些标志不会直接打印出来，而是被后续的条件跳转指令使用，比如JE/JZ会检查ZF。JC/JB会检查CF。 JO/NO会检查OF，从而实现if/else比较大小，循环等高级语言里面的控制流程。

程序代码如下：

```
#include <stdio.h>

int add_with_overflow(int a, int b, int *has_overflow)
{
    int result = 0;
    unsigned char of = 0;   // 用来接收 OF 的值（0 或 1）

    __asm {
        mov eax, a          ; eax = a
        add eax, b          ; eax = a + b （有符号加法，OF 会被设置）
        seto al             ; 如果 OF = 1，则 AL = 1；否则 AL = 0
        mov of, al          ; 把 AL 的值保存到 C 变量 of 里
        mov result, eax     ; 把计算结果写回 result
    }

    if (has_overflow)
{
        *has_overflow = (of != 0);   // 告诉外面有没有溢出
    }

    return result;
}

int main(void) {
    int x, y;
    printf("请输入两个有符号整数：");
    if (scanf("%d %d", &x, &y) != 2) {
        printf("输入错误！\n");
        return 1;
    }

    int overflow = 0;
    int sum = add_with_overflow(x, y, &overflow);

    if (overflow) {
        printf("发生溢出！(OF = 1)，计算结果已失真。\n");
    } else {
        printf("没有溢出，结果为：%d + %d = %d\n", x, y, sum);
    }

    return 0;
}

```

