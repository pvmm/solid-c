#include <stdio.h>
#include <dos.h>

FIND p;
char done;

void main()
{
    printf("List of directory: *.*\n");
    done = ffirst("*.*", &p, FA_NORMAL | FA_ARCH | FA_DIREC);
    while(!done)
      {
        printf("%s\n", p.ff_name);
        done = fnext(&p);
      }
}
