#include <stdio.h>

FILE *fp;
f_point *pos;

void main()
{
      fp=fopen("test.txt", "r");

      pos->high = 0;
      pos->low = 20;

      if((pos=fseek(fp, pos->high, pos->low, SEEK_SET)) == -1)
          printf("Ошибка перемещения\n");
      fprintf(stdout,"\n%04X %04X", pos->high, pos->low);
      fclose(fp);
}
