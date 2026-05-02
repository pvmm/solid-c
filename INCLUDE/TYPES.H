/*
 *	TYPES.H
 *
 *	General types definition for SOLID C.
 *	(c) 2004, SOLID C  Sprinter-2000
 */


#ifndef	_C_TYPES_
#define _C_TYPES_

typedef	unsigned uint;

typedef	char BYTE;
typedef	char TINY;
typedef	char BOOL;
typedef	char STATUS;
typedef	uint WORD;
typedef	int  FD;			/* file discripter type */


/* for "seeks","tells" functions */
typedef struct fpoint {
        uint	low;
        uint	high;
} f_point;


typedef	struct {
	uint low;
	uint high;
} LONG;


#define	NULL		0
#define OK		0
#define EXIT_SUCCESS	0
#define EXIT_FAILURE	1
#define ERROR		(-1)
#define	FALSE		0
#define	TRUE		1
#define YES		1
#define NO		0
#define FLOAT		LONG

#ifndef	_SIZE_T
#define	_SIZE_T
typedef	uint  size_t;
#endif

#endif
