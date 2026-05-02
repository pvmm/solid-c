/*
 *	STDIO.H
 *
 *      Definitions for stream input/output.
 *	(c) 2004, SOLID C  Sprinter-2000
 */


#ifndef	_C_TYPES_
#include <types.h>
#endif

#ifndef	_STD_LIB_
#include <stdlib.h>
#endif



/* definition of the control structure for streams */
typedef	struct {
	uint flags;		/* +0,1  file status flags		*/
	int  level;		/* +2,3  empty/fill level of buffer	*/
	char *curp;		/* +4,5  current active pointer		*/
	int  fd;		/* +6,7  file descriptor for low-level i/o */
	char *buffer;		/* +8,9  addr data transfer buffer	*/
	char hold;		/* +10   ungetc char if no buffer	*/
	short token;		/* +11,12 reserved			*/
	char dummy;		/* +13   reserved			*/
} FILE;		/* this is the FILE object */


/* "flags" bits definitions */
#define _F_READ  0x0001			/* 0  read only file		*/
#define _F_WRIT  0x0002			/* 1  write only file		*/
#define _F_RDWR  0x0003			/* 0,1 read/write flag		*/
#define _F_BUF   0x0004			/* 2  malloc'ed Buffer data	*/
#define _F_LBUF  0x0008			/* 3  line-buffered file	*/
#define _F_ERR   0x0010			/* 4  error indicator		*/
#define _F_EOF   0x0020			/* 5  EOF indicator		*/
#define _F_BIN   0x0040			/* 6  binary file indicator	*/
#define _F_IN    0x0080			/* 7  data is incoming		*/
#define _F_OUT   0x0100			/* 0 +1  data is outgoing	*/
#define _F_TERM  0x0200			/* 1 +1  stdin stream		*/


#define	EOF	(-1)			/* end of file indicator */

#define	BUFSIZ	512			/* buffer size for high-level i/o */

#define	OPEN_MAX  8			/* able to have 8 files */

extern FILE  _iob[];			/* list of fcb */

/* standard I/O predefined streams */
#define	stdin	(&_iob[0])
#define	stdout	(&_iob[-1])
#define	stderr	(&_iob[-2])
#define	stdaux	(&_iob[-3])
#define	stdprn	(&_iob[-4])


/* for fgetpos, fsetpos functions */
typedef	long fpos_t;		/* file offset type */


#ifndef	_STD_SEEK_
#define	_STD_SEEK_
/* constants to be used as 3rd argument for "fseek" function */
#define	SEEK_SET	0
#define	SEEK_CUR	1
#define	SEEK_END	2
#endif


/* Prototypes */

int printf(.);
int fprintf(.);
int sprintf(.);
int scanf(.);
int sscanf(.);
int fscanf(.);
void clearerr();
FILE *fdopen();
FILE *fopen();
FILE *freopen();
void fclosall();
char fclose();
size_t fread();
size_t fwrite();
struct fpoint *fseek();
struct fpoint *ftell();

char getc();
char putc();
char *gets();
char puts();
char *fgets();
char fputs();
char fgetc();
char fputc();
char ungetc();
char fflush();
void rewind();
char fgetpos();
char fsetpos();



/* The following macros provide for common functions */

#define	fileno(a)	((a)->fd)
#define	ferror(a)	((a)->flags & _F_ERR)
#define	feof(a)		((a)->flags & _F_EOF)

#define	fgetchar	getc(stdin)
#define	fputchar(c)	putc((c),stdout)
