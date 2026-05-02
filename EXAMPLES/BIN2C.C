/*
 *  BIN2C V1.0 CODED BY CHRISTIAN PADOVANO ON 17-MAY-1995
 *
 *  this little utility translates a binary file in a useful C structure
 *  that can be included in a C source.
 */

#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <conio.h>


#define BUF_LEN   1
#define LINE      9

FILE *fp, *fp1;
f_point *pos;



/* lower chars --> upper chars */
void upper_chars(buff)
char *buff;
{
   char c;
   for(c=0; c <= strlen(buff)-1; c++)
        *(buff+c) = toupper(*(buff+c));
}


void main(argc, argv)
int argc;
char *argv[];
{
    char buffer[BUF_LEN], dummy[20];
    char c;

    if((argc < 4))
      {
        puts("- <<< BIN2C V1.0 >>> by Christian Padovano -\n");
        puts("Usage: Bin2C  <BINARY file name> <TARGET file name> <STRUCT name>\n");
        puts(" <STRUCT > = name of the C structure in the destination file name");
        puts(" <TARGET > = without extension '.h' it will be added by program");
        exit(0);
      }

    if((fp=fopen(argv[1], "rb")) == NULL)
      {
        cprintf("ERROR: I can't find source file  %s\n", argv[1]);
        exit(1);
      }

    strcpy(dummy, argv[2]);
    strcat(dummy, ".H");		/* add suffix .h to target name */

    if((fp1=fopen(dummy, "w+")) == NULL)
      {
        cprintf("ERROR: I can't open destination file  %s\n", dummy);
        exit(1);
      }

    strcpy(dummy, argv[3]);
    upper_chars(dummy);		/* lower to upper chars */
    strcat(dummy, "_LEN");	/* add the suffix _LEN to the struct name */
				/* for the #define stantment              */

     /* file size in bytes */
    fseek(fp, 0, 0, SEEK_END);
    pos = ftell(fp);
    fseek(fp, 0, 0, SEEK_SET);

     /* It writes the header information */
    fprintf(fp1, "#define %s %u\n\n", dummy, pos->low);
    fprintf(fp1, " static unsigned char %s[]={\n  ", argv[3]);

    if(ferror(fp1))
      {
        cprintf("ERROR writing on target file:  %s\n", argv[2]);
        exit(1);
      }

    do {
       for(c=0; ((c <= LINE) && (! feof(fp))); c++)
          {
            fread(buffer, 1, 1, fp);
            fprintf(fp1,"0x%02X", (char *) *buffer);
            if(! feof(fp))
                fputc(',', fp1);
          }
       fprintf(fp1,"\n  ");
    } while(! feof(fp));

    fprintf(fp1,"};\n");

    fclose(fp);
    fclose(fp1);
}
