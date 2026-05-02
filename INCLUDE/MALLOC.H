/*
 *	MALLOC.H
 *
 *	Memory management functions.
 *	(c) 2004, SOLID C  Sprinter-2000
 */


#ifndef	_C_TYPES_
#include <types.h>
#endif


int brk();			/* set free memory pointer */
char *sbrk();			/* move free memory pointer arg bytes higher */
char *malloc();			/* allocate memory */
char *calloc();			/* allocate object array, zero memory */
char *realloc();		/* reallocate memory */
void free();			/* free malloc'd memory */
