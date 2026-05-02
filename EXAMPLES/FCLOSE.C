#include <stdio.h>

FILE *fp;

void main()
{
     fp = fopen("test.txt", "r");
     if((fclose(fp)) == -1)
         perror("close failed on file");
}
