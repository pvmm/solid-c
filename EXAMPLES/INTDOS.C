#include <conio.h>
#include <dos.h>

union REGS inregs, outregs;

void main()
{
      /* следующие операторы выбирают текущую дату,
         используя вызов функции DOS 21h. */
     inregs.h.c = 0x21;
     intdos(&inregs, &outregs);
     cprintf("date is %02d/%02d/%04d\n", outregs.h.d,
                                         outregs.h.e,
                                         outregs.x.ix);
}
