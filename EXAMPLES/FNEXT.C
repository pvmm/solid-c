#include <stdio.h>
#include <dos.h>

struct ffblk p;
char done;

void main()
{
    printf("List of directory: *.*\n");
    done = findfirst("*.*", &p, FA_NORMAL | FA_ARCH | FA_DIREC);
    while(!done)
      {
        printf("%s\n", p.ff_name);
        done = findnext(&p);
      }
}
