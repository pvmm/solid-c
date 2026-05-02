  Функция ferror проверяет ошибки чтения и записи заданного файла.
При возникновении ошибки, индикатор ошибки файла fp остается уста-
новленным до тех пор, пока файл не закроется или будут вызваны
функции rewind или clearerr.
В случае обнаружения ошибки в файле, функция ferror возвращает нену-
левое значение. Возвращаемое значение 0 свидетельствует об отсутствии
ошибки.


#include <stdio.h>
FILE *fp;
char *string;
            
   /* The following example writes a string to a file and checks
      whether an error occurred during writing. Before writing
      a string to a file, you should first make sure it exists. */
   fprintf(fp, "%s\n", string);
   if(ferror(fp))
     {
       fprintf(stderr, "Write error\n");
       clearerr(fp);
     }
