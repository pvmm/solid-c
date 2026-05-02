/*
 *	ERRNO.H
 *
 *	Defines the system error variable errno and the error
 *	numbers set by system calls.
 *	(c) 2004, SOLID C  Sprinter-2000
 */



/* DOS Error Codes */

#define EZERO		0		/* No error		*/
#define EINVFNC		1		/* Invalid function	*/
#define EINVDRV		2		/* Invalid drive number	*/
#define ENOFILE		3		/* File not found	*/
#define ENOPATH		4		/* Path not found	*/
#define EINVHND		5		/* Invalid handle	*/
#define EMFILE		6		/* Too many open files	*/
#define EEXIST		7		/* File already exists	*/
#define EROFILE		8		/* File read only	*/
#define EROOT		9		/* Root overflow	*/
#define ENOSPACE	10		/* No free space	*/
#define ENOEMPTY	11		/* Directory not empty	*/
#define ECURDIR		12		/* Can't delete current directory */
#define EINVMED		13		/* Invalid media	*/
#define EOPER		14		/* Unknown operation	*/
#define EEXISDIR	15		/* Directory exist	*/
#define EINVFNAM	16		/* Invalid filename	*/
#define EINVEXE		17		/* Invalid EXE-file	*/
#define ENSUPEXE	18		/* Not supported EXE-file */
#define EACCES		19		/* Access denied	*/
#define ENORDY		20		/* Not ready		*/
#define ESEEK		21		/* Seek error		*/
#define ENOSECT		22		/* Sector not found	*/
#define ECRC		23		/* CRC error		*/
#define EWRTPRT		24		/* Write protect	*/
#define EREAD		25		/* Read error		*/
#define EWRITE		26		/* Write error		*/
#define EDRVFAIL	27		/* Drive failure	*/
#define EEXTND28	28		/* Extended error: 28	*/
#define EEXTND29	29		/* Extended error: 29	*/
#define ENOMEM		30		/* Not enough memory	*/
#define EINVMEM		31		/* Invalid memory block	*/
#define EEXTND32	32		/* Extended error: 32	*/
#define EEXTND33	33		/* Extended error: 33	*/
#define EEXTND34	34		/* Extended error: 34	*/
#define EERR35		35		/* 35 */
#define EERR36		36		/* 36 */
#define EERR37		37		/* 37 */
#define EERR38		38		/* 38 */
#define EERR39		39		/* 39 */
#define EERR40		40		/* 40 */
#define EERR41		41		/* 41 */
#define EERR42		42		/* 42 */
#define EERR43		43		/* 43 */
#define EERR44		44		/* 44 */
#define EERR45		45		/* 45 */
#define EERR46		46		/* 46 */
#define EERR47		47		/* 47 */
#define EERR48		48		/* 48 */
#define EERR49		49		/* 49 */
#define EERR50		50		/* 50 */
