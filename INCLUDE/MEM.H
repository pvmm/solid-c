/*
 *	MEM.H
 *
 *	Memory manipulation functions.
 *	(c) 2004, SOLID C  Sprinter-2000
 */


#ifndef	_C_TYPES_
#include <types.h>
#endif


int  memcmp();			/* compare two memory blocks */
void *memcpy();			/* copy memory block */
void *memmove();		/* copy memory block */
void *memset();			/* fill memory with byte */
void movmem();			/* memory copy */
void setmem();			/* memory fill */
