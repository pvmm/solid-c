/*
 *	SETJMP.H
 *
 *	Defines typedef and functions for setjmp/longjmp.
 *	(c) 2004, SOLID	C  Sprinter-2000
 */


#ifndef	_C_TYPES_
#include <types.h>
#endif


typedef	struct {
	uint j_sp;
	uint j_iy;
	uint j_pc;
} jmp_buf;


int setjmp();		/* set nonlocal jump return point */
void longjmp();		/* do a nonlocal jump */
