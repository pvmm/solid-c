#include <stdio.h>

void main()
{
    FILE *fp;
    fpos_t position;
    char buffer[80];

    fp = fopen("test.txt", "r");
    if(fp != NULL)
      {
        fgetpos(fp, &position);		/* get position */
        fgets(buffer, 80, fp);		/* read record */
        fsetpos(fp, &position);		/* set position */
        fgets(buffer, 80, fp);		/* read same record */
        fclose(fp);			/* close file */
      }
    else
       printf("can't open file\n");
}
