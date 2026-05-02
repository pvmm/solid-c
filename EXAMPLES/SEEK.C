#include <stdio.h>
#include <io.h>

FD fd;
uint pos,i;

void main()
{
      fd=open("test.txt", O_RDONLY);
      i = 10;
      if((pos=seek(fd, i, SEEK_SET)) == -1)
          printf("Ошибка перемещения\n");
      printf("\n%04X",pos);
      close(fd);
}
