/*
 *	DOS.H
 *
 *	Defines structs, unions, and functions for
 *	dealing with Estex-DOS.
 *	(c) 2004, SOLID C  Sprinter-2000
 */


#ifndef	_C_TYPES_
#include <types.h>
#endif


/* Variables */
extern int _argc;
extern char **_argv;


/* DOS types */
struct WORDREGS {
    unsigned af, bc, de, hl, ix, iy;
};

struct BYTEREGS {
    char flag, a, c, b, e, d, l, h;
};

union REGS {
    struct WORDREGS x;
    struct BYTEREGS h;
};


struct time {
    unsigned char  ti_min;	/* minutes */
    unsigned char  ti_hour;	/* hours */
    unsigned char  ti_hund;	/* hundredths of seconds. Not used. */
    unsigned char  ti_sec;	/* seconds */
};

struct date {
    int  da_year;		/* year */
    char da_day;		/* day of the month */
    char da_mon;		/* month (1 = Jan) */
};


/* ffirst, fnext functions */
typedef struct ffblk {
    char name[8];		/* +0  pattern of a file name */
    char ext[3];		/* +8  pattern of file expansion */
    char attrib;		/* +11 search attribute */
    char ff_resv[10];		/* +12 reserved for DOS */
    uint ff_time;		/* +22 time of last write to file */
    uint ff_date;		/* +24 date of last write to file */
    uint ff_clst;		/* +26 number of first cluster */
    uint ff_lsize;		/* +28 low size of file */
    uint ff_hsize;		/* +30 high size of file */
    char ff_attr;		/* +32 attribute byte of matched file */
    char ff_name[223];		/* +33 null-terminated name of matched file */
} FIND;


/* file attributes */
#define FA_NORMAL   0x00	/* Normal file, no attributes */
#define FA_RDONLY   0x01	/* Read only attribute */
#define FA_HIDDEN   0x02	/* Hidden file */
#define FA_SYSTEM   0x04	/* System file */
#define FA_LABEL    0x08	/* Volume label */
#define FA_DIREC    0x10	/* Directory */
#define FA_ARCH     0x20	/* Archive */




/* Prototypes */

char bdos();			/* DOS call return status */
int  bdosh();			/* DOS call return int */
void intdos();			/* DOS call, parameters and return as REGS */
void enable();			/* enable interrupts */
void disable();			/* disable interrupts */
char absread();			/* read sectors */
char abswrite();		/* write sectors */
char ffirst();			/* found first file */
char _ffirst();			/* found first file, format "FilenameExt" */
char fnext();			/* found next file */
int _setargv();			/* parsing arguments */
void setdisk();			/* set default disk */
char getdisk();			/* get default disk */
void setdate();			/* set system date */
void getdate();			/* get struct date */
void settime();			/* set system time */
void gettime();			/* get struct time */
void sleep();


#define findfirst  ffirst
#define findnext   fnext
