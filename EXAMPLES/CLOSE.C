#include <io.h>

FD fd;

void main()
{
     fd = open("test.txt", O_RDONLY);
     if((close(fd)) == -1)
        perror("close failed on file");
}
