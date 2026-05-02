/*
 *	CTYPE.H
 *
 *	Character type classification.
 *	(c) 2004, SOLID C  Sprinter-2000
 */



char tolower();			/* convert to lowercase */
char toupper();			/* convert to uppercase */
BOOL islower();			/* lowercase test */
BOOL isupper();			/* uppercase test */
BOOL isalnum();			/* A..Z a..z 0..9 */
BOOL isalpha();			/* A..Z a..z */
BOOL isascii();			/* !..~ */
BOOL isdigit();			/* 0..9 */
BOOL isxdigit();		/* hex digit test */
BOOL isspace();			/* space test */
BOOL iscntrl();			/* unprintable control symbol */
BOOL isgraph();			/* has graphic reprezentation */
BOOL isprint();			/* printable test */
BOOL ispunct();			/* punctuation sign test */
