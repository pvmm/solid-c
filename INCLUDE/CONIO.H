/*
 *	CONIO.H
 *
 *	Low-level console functions.
 *	(c) 2004, SOLID C  Sprinter-2000
 */


#ifndef	_C_TYPES_
#include <types.h>
#endif


char getch();
char getche();
void putch();
void cputs();
void clrscr();
void home();
void gotoxy();
char *cgets();
char inp();
char outp();
BOOL kbhit();
int cprintf(.);
