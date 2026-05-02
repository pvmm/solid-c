#include <stdio.h>
int feof(FILE *fp);
            
/* The function (implemented as a macro) determines whether the end of file
(EOF) has been reached. If the end of file (EOF) is reached, it is set by standard
read functions, i.e., after each read function call, the EOF indicator will be set
until the file is closed or until the rewind, fsetpos, fseek, or clearerr functions
are called.
If the current position is at the end of file (EOF), the function returns a non-zero
value. If the current position is not at the end of file - the function returns
a value of 0. The feof function does not report errors. */

FILE *fp;
main()
{
   if((fp=fopen("file.dat", "r")) == NULL)
     {
       printf("File open error\n");
       exit(1);
     }
   while(!feof(fp))
       fgetc(fp);
   printf("\nFile reading completed, EOF reached\n");
   fclose(fp);
}
