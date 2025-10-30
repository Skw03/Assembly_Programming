# Assignment 1 Helloworld

* ## 传统编译方式

### 环境配置

1. 在DOSBox中输入 `config -writeconf dosbox.conf` 会生成一个配置文件 dosbox.conf。
   
   <img width="457" height="740" alt="image" src="https://github.com/user-attachments/assets/8b38f507-b795-4a43-97a4-9d35d5292b23" />
   
   
  在打开的`dosbox.conf`划到最后一部分`[autoexec]`，在底部添加：
  ```
  mount d d:\Assembly_Programming
  D:
  path d:\MP\Tools
  cd MP\Code
  ```


  <img width="614" height="236" alt="image" src="https://github.com/user-attachments/assets/ad097301-acf4-408b-a821-13b396475d65" />
  

  保存后，每次启动 DOSBox，它会自动挂载、设置路径并进入你的code文件夹
  

2. 在`D:\Assembly_Programming\MP\Tools`中添加`DEBUG.EXE`,`LINK.EXE` 和 `MASM.EXE`


     <img width="1038" height="159" alt="image" src="https://github.com/user-attachments/assets/09341164-9d7f-4450-8ab4-6a3ce7a568d1" />
     

## 创建汇编文件

   在文本编辑器中写入代码：
   
   ```
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
```

## 编译并运行

1. 启动DOSBox0.74-3
   
     <img width="1710" height="984" alt="image" src="https://github.com/user-attachments/assets/24f775be-7f32-481d-814d-def83b08ec00" />
     

2. 执行命令`masm Hello.asm`, Object filename选项回车，表示接受默认文件名，Source listing 选项回车，表示不生产源代码列表文件， Cross-reference 回车，表示不生成交叉引用表。作用是使用编译器将汇编语言的.asm源文件编译成.obj文件。
   
     <img width="1729" height="1117" alt="image" src="https://github.com/user-attachments/assets/6694b05c-457c-4be7-b80f-b315c199f31a" />

     
3. 执行命令`link Hello.obj`,Run File 选项回车，表示接受默认文件名，List File 选项回车，表示不生成列表文件，Libraries 选项回车，表示不链接任何额外的库文件，采用默认设置。这一步通过连接器将编译生成的目标文件链接为.exe文件。
   
     <img width="1703" height="457" alt="image" src="https://github.com/user-attachments/assets/ab73e7f3-2ebf-42fe-9afa-354aadbe7eb4" />

     
4. 执行命令Hello.exe,运行程序
   
     <img width="1540" height="147" alt="image" src="https://github.com/user-attachments/assets/8427e134-66ea-4412-af23-5fe349c48ff1" />
     

5. 执行命令`debug Hello.exe`, 再使用`-u`命令，可以反汇编可执行文件的机器代码，逐条显示汇编指令
    
    <img width="1727" height="1166" alt="image" src="https://github.com/user-attachments/assets/10f6c725-3771-4488-aa81-4efe3d0f6ad7" />
    

## 反汇编结果分析

1. `076C:0000 B86D07 MOV AX,076D`

     这条指令把076D（数据段地址）加载到AX寄存器中。
2. `076C:0003 8ED8 MOV DS,AX`

     这条指令将AX寄存器的值加载到数据段寄存器DS中。
3. `076C:0005 BA0000 MOV DX,0000`

     这条指令将DX置为数据段中字段的偏移地址。
4. `076C:0008 B409 MOV AH,09`

     这条指令将值09加载到AH寄存器中，准备调用DOS中断21H的09H功能->打印字符串功能。
5. `076C:000A CD21 INT 21`

     这条指令触发DOS中断21h，09h功能号，显示以$结尾的字符串。
6. `076C:000C B44C MOV AH,4C`

    这条指令将值4C加载到AH寄存器，准备调用DOS打印字符串功能。
7. `076C:000E CD21 INT 21`

    再次触发DOS中断21h终止程序执行->退出程序

* ## 内存写入数据方式

1. 启动DOSBox0.74-3
   
     <img width="1720" height="978" alt="image" src="https://github.com/user-attachments/assets/eee0f5ac-1d7b-4419-832b-56e8d6d322ba" />
     

2. 执行命令`debug`,进入调试交互（出现`-`提示符）
   
3. 执行命令`-e 076B:0000`，将代码的机器码`b8 6d 07 8e d8 ba 00 00 b4 09 cd 21 b4 4c cd 21`写入内存。
   
     <img width="1726" height="1080" alt="image" src="https://github.com/user-attachments/assets/5186d801-ad7f-46ae-aa00-9ae9a292a39e" />

     
4. 执行命令`-e 076D:0000`,将“Hello,World!$”对应的ASCII码`48 65 6c 6c 6f 2c 20 57 6f 72 6c 64 21 24`写入内存。

     <img width="1726" height="1080" alt="image" src="https://github.com/user-attachments/assets/6e30f005-17d7-436d-8c73-b19fad698a1f" />

     
5. 执行命令`-g=076B:0000`,表示从段`076B`，偏移`0000`开始执行程序。

     <img width="1726" height="1080" alt="image" src="https://github.com/user-attachments/assets/5ad4e1a8-13f4-458f-9cd4-c2822d009111" />




