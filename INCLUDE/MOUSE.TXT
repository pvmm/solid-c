/*
 *	MOUSE.H
 *
 *	Defines structures, macros, and functions.
 *	(c) 2004, SOLID C  Sprinter-2000
 */


#ifndef	_C_TYPES_
#include <types.h>
#endif


#define LEFT_BUTTON	1
#define RIGHT_BUTTON	2


/* getStatMouse() */
typedef	struct {
	char button;		/* buttons: 0/1 bits - left/right */
	char x;			/* colon */
	char y;			/* line */
} MSSTAT;


/* getGStatMouse() */
typedef	struct {
	char button;		/* buttons: 0/1 bits - left/right */
	int x;			/* X pos */
	int y;			/* Y pos */
} MSGSTAT;


/* getCursMouse() */
typedef	struct {
	char width;		/* width curs */
	char high;		/* high curs */
	char xpoint;		/* X active point */
	char ypoint;		/* Y active point */
	char *buff;		/* addr cursor buffer */
} MSCURS;


/* setTxtMouse() */
typedef	struct {
	char xattr;		/* XOR attribut mask */
	char aattr;		/* AND attribut mask */
	char xsym;		/* XOR simbol mask */
	char asym;		/* AND simbol mask */
} MSTXT;


/* getSensMouse(), setSensMouse() */
typedef	struct {
	char xsens;		/* horiz. sensitive */
	char ysens;		/* vert. sensitive */
} MSSENS;



//	0 - нет ошибок
//	1 - неизвестная функция
//	3 - курсор уже на экране
//	4 - курсор отсутствует на экране
//	5 - изображение курсора слишком велико

/* Mouse Error Codes */
#define MSEZERO		0		/* No error		*/
#define MSUNKNW		1		/* Unknown function	*/
#define MSEXIST		3		/* Exists cursor	*/
#define MSNOCUR		4		/* No cursor		*/
#define MSTOOBIG	5		/* Too big image	*/


/* prototypes */

char ms_init();
char ms_show();
char ms_hide();
MSSTAT  *ms_stat();
MSGSTAT *msgstat();
char ms_spos();
char mssgpos();
char ms_ybnd();
char ms_xbnd();
char ms_scur();
char ms_tcur();
MSCURS *ms_gcur();
MSSENS *ms_gsen();
char ms_ssen();
char ms_hard();
char ms_vmod();
char ms_ref();


#define initMouse	ms_init
#define showMouse	ms_show
#define hideMouse	ms_hide
#define getStatMouse	ms_stat
#define getGStatMouse	msgstat
#define setPosMouse	ms_spos
#define setGPosMouse	mssgpos
#define yLimMouse	ms_ybnd
#define xLimMouse	ms_xbnd
#define setTxtMouse	ms_tcur
#define getCursMouse	ms_gcur
#define setCursMouse	ms_scur
#define getSensMouse	ms_gsen
#define setSensMouse	ms_ssen
#define hardMouse	ms_hard
#define vmodeMouse	ms_vmod
#define refreshMouse	ms_ref
