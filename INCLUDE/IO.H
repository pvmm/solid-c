/*
 *	IO.H
 *
 *	Low-level nonbuffered file I/O.
 *	(c) 2004, SOLID	C  Sprinter-2000
 */


#ifndef	_C_TYPES_
#include <types.h>
#endif

#ifndef	_STD_LIB_
#include <stdlib.h>
#endif


#ifndef	_STD_SEEK_
#define	_STD_SEEK_
/* constants to be used as 3rd argument for "fseek" function */
#define	SEEK_SET	0
#define	SEEK_CUR	1
#define	SEEK_END	2
#endif


/* Definition "open flags" */
#define	O_WRONLY	0x01		/* 0  file write only */
#define	O_RDONLY	0x02		/* 1  file read only */
#define	O_RDWR		0x03		/* 1,0 file read/write */
#define	O_TRUNC		0x04		/* 2  open with truncation */
#define	O_CREAT		0x08		/* 3  create and open file */
#define	O_EXCL		0x10		/* 4  exclusive open */
#define	O_APPEND	0x20		/* 5  to end of file */



uint open();			/* opens/creates a file */
uint creat();			/* creates file */
size_t read();			/* read file */
size_t write();			/* write file */
uint close();			/* close file */
uint seek();			/* sets file pointer (range 0..65534) */
uint tell();			/* returns current position (range 0..65534) */
struct fpoint *lseek();		/* sets file pointer */
struct fpoint *ltell();		/* returns current position */
char unlink();			/* delete file */
char remove();			/* delete file */
char rename();			/* rename file */
BOOL isatty();			/* return "true" if FD is console I/O */
int ioctl();			/* control i/o for devices or files */
