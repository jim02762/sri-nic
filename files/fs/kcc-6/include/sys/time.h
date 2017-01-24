/* <SYS/TIME.H> - definitions for BSD gettimeofday(2) and KCC "tadl" rtns.
**
**	(c) Copyright Ken Harrenstien 1989
**
**	Note that getitimer/setitimer are not supported, so their cruft
**	isn't defined here.
*/

#ifndef _SYS_TIME_INCLUDED
#define _SYS_TIME_INCLUDED 1

/* Structures returned by gettimeofday() system call. */
struct timeval {
	long	tv_sec;		/* seconds since 1/1/70 */
	long	tv_usec;	/* and microseconds */
};
struct timezone {
	int	tz_minuteswest;	/* minutes west of Greenwich (UTC) */
	int	tz_dsttime;	/* type of DST correction */
};

/* Additional definitions (mainly struct tm) for the benefit of
** programs which are using the BSD convention of including <sys/time.h>
** in order to get the struct tm declaration!
*/
#include <time.h>	/* Get ANSI defs, OK to include more than once */

/* KCC-specific additional definitions.
**	These are used by time() and gettimeofday() but may also be
**	used (carefully) by user programs.  Better names should be
**	picked for these, however.
*/
#define tadl_t		_tadl_t
#define tadl_get	_tadlg
#define tadl_to_utime	_tadlt
#define tadl_from_utime	_tadlf
#define tad64s_to_utime	_tad6t
#define tad64s_from_utime _tad6f

typedef long tadl_t;		/* Local TAD format */
extern tadl_t tadl_get();	/* Get Local TAD */
extern time_t tadl_to_utime();	/* Convert Local TAD to Un*x TAD */
extern tadl_t tadl_from_utime(); /* Convert Un*x TAD to Local TAD */
extern time_t tad64s_to_utime();	/* Cvt 64S TAD to Un*x TAD */
extern tadl_t tad64s_from_utime();	/* Cvt Un*x TAD to 64S TAD */

/* Define DST correction types.  Not sure what BSD uses, but it's OK
** to make ours up since the only things that should use them are
** gettimeofday() and the C library's time manipulation facilities.
** See localtime(3).
** Also see <sys/sitdep.h> which defines _SITE_DSTTIME to one of these.
*/
#define _DST_OFF 0	/* Never use DST.  This must be 0. */
#define _DST_USA 1	/* Use USA DST algorithm.  Must be 1. */
#define _DST_ON  2	/* Use DST always. */

#endif /* #ifndef _SYS_TIME_INCLUDED */
