#include <stdio.h>

FILE *fp;

void main(argc, argv)
int argc;
char *argv[];
{
    if((fp=fopen(argv[0], "r")) == NULL)
      {
        fprintf(stderr,"can't open file: %s\n", argv[0]);
        exit(1);
      }
}
