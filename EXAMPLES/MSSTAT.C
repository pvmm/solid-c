#include <conio.h>
#include <mouse.h>

MSSTAT *p;

void main()
{
    initMouse();
    showMouse();

    while(!kbhit())
      {
        p = getStatMouse();
        cprintf("BUTTON: %d  Col: %02d Line: %02d\r",
                                   (char *)p->button,
                                   (char *)p->x,
                                   (char *)p->y);
      }
}
