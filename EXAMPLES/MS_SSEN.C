#include <stdio.h>
#include <mouse.h>

void main()
{
    MSSENS *p;

    p->xsens = 2;
    p->ysens = 3;

    setSensMouse(p);

    p = getSensMouse();

    printf("X: %x  Y: %x\n", (char*)p->xsens, (char *)p->ysens);
}
