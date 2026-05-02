#include <stdio.h>
#include <io.h>

FILE *fp;
FD fd;

main()
{
    fd = open("test.txt", O_WRONLY);
    if(fd == -1)
        fprintf(stderr, "File test.txt not found\n");
  
    fp = fdopen(fd, "a");
    if(fp == NULL)
        fprintf(stderr, "Errors in function fdopen\n");
    else
       {
         fprintf(fp, "Hello, world !\n");
         fclose(fp);
       }
}
