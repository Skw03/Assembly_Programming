.model small              ;  定义程序的内存模型为small
.stack 100h               ;  定义栈区大小为256字节

.data
msg db 'Hello, World!$'   ;  定义一个字符串常量
                          ;  db = 定义字节，$作为结束符

.code                     ;  开始定义主程序段
main proc                 ;  类似C的main()
                          ;  设置数据段寄存器DS的值，使程序能够正确访问.data段中的变量
    mov ax, @data         ;  @是MASM伪符号，表示数据段的段地址
    mov ds, ax            ;  先把他放入ax中，再传到ds中
                      
                          ;  输出字符串到屏幕
    mov dx, offset msg    ;  把字符串的偏移地址放入寄存器dx
    mov ah, 09h           ;  设置AH=09h(显示字符串)
    int 21h               ;  调用DOS中断21h

                          ;  程序结束，返回DOS
    mov ah, 4Ch           ;  设置ah=4Ch,表示退出程序
    int 21h               ;  调用中断，程序结束
	
main endp
end main