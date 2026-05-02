#include <stdio.h>

FILE *fp;
char *s = "Hello, world ! ;)";

main()
{
    fp = fopen("test.txt", "r");
    if(fp == NULL)
        fprintf(stderr, "File test.txt not found\n");
  
    fp = freopen("file.dat", "w+", fp);
    if(fp == NULL)
        fprintf(stderr, "Errors in function freopen\n");
    else
       {
        fprintf(stderr, "Now data will go in file.dat\n");
        fprintf(fp, "%s\n", s);
       }
    fclose(fp);
}
