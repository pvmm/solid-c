/*
 *	STRING.H
 *
 *	String manipulation functions.
 *	(c) 2004, SOLID C  Sprinter-2000
 */


#ifndef	_C_TYPES_
#include <types.h>
#endif


void *memchr();			/* search for a character in memory block */
char *strcat();
char *strncat();
char *strchr();
int  strcmp();
int  strncmp();
char *strcpy();
char *strncpy();
size_t strcspn();
size_t strlen();
char *strlwr();
char *strpbrk();
char *strrchr();
size_t strspn();
char *strstr();
char *strtok();
char *strupr();
char *strerr();

#define strerror   strerr;
