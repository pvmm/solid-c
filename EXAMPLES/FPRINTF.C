#include <stdio.h>

FILE *fp;
char *s = "This is string.";

void main()
{
     fp = fopen("test.txt", "w");
     fprintf(fp,"%s",s);
     fclose(fp);
}
