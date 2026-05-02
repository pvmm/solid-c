#include <stdio.h>
#include <io.h>

FD fd;
uint pos,i;

void main()
{
      fd=open("test.txt", O_RDONLY);
      i = 10;
      if((seek(fd, i, SEEK_SET)) == -1)
          printf("Ошибка перемещения\n");
      pos=tell(fd);
      printf("\n%04X",pos);
      close(fd);
}
