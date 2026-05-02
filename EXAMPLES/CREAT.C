#include <io.h>

FD fd;

void main()
{
     fd = creat("test.txt", O_RDWR | O_CREAT);
     if(fd == -1)
         perror("create failed on file");
     else
        close(fd);
}
