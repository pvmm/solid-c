#include <stdio.h>

FILE *fp;
f_point *pos;

void main()
{
      fp=fopen("test.txt", "r");

      pos->high = 0;
      pos->low = 20;

      if((fseek(fp, pos->high, pos->low, SEEK_SET)) == -1)
          printf("Seek error\n");
      pos=ftell(fp);
      fprintf(stdout,"\n%04X %04X", pos->high, pos->low);
      fclose(fp);
}
