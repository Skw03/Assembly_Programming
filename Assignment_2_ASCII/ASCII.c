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