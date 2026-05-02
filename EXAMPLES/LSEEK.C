#include <stdio.h>
#include <io.h>

FD fd;
f_point *pos;

void main()
{

      fd=open("test.txt", O_RDONLY);

      pos->high = 0;
      pos->low = 10;

      if((pos=lseek(fd, pos->high, pos->low, SEEK_SET)) == -1)
          printf("Ошибка перемещения\n");
      printf("\n%04X %04X", pos->high, pos->low);
      close(fd);
}
