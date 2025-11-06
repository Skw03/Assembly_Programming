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
