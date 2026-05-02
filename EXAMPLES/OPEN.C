#include <io.h>

FD fd;

void main()
{
     fd = open("test.txt", O_RDONLY);
     if(fd == -1)
         perror("open failed on input file");
     else
        close(fd);
}
