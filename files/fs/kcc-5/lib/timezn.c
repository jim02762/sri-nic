/* TIME_LZONE		return local timezone info.
** TIME_TZSET		reset local timezone info.
**
** 	Copyright (c) 1980, 1987 by Ken Harrenstien, SRI International.
**
**	This code is quasi-public; it may be used freely in like software.
**	It is not to be sold, nor used in licensed software without
**	permission of the author.
**	For everyone's benefit, please report bugs and improvements!
**	(Internet: <KLH@SRI-NIC.ARPA>)
*/

#include <c-env.h>	/* For system-dependent switches */
#include <timex.h>

#ifndef SYS_V6
#define SYS_V6 0
#endif
#ifndef SYS_SYSV
#define SYS_SYSV 0
#endif

#if !(SYS_V6||SYS_SYSV)	/* V7 and BSD */
#include <sys/types.h>
#include <sys/timeb.h>
#endif

/* TIME_LZONE - return local timezone structure.
**	First time, asks system for timezone, then stores it so future
** calls can avoid overhead of system call.
**	The system call used is V7 ftime() rather than BSD gettimeofday()
** because the former is more likely to be widely supported, in case this
** code is used elsewhere.  There is however a subtle assumption that ftime()
** will return 1 for "dstflag" if a USA type DST algorithm is to be used.
*/
static int _tlzknown = 0;	/* Non-zero when tmz structure known */
static struct tmz _tlz;

int
time_lzone(zp)
register struct tmz *zp;
{
    if (!_tlzknown) {
	if (time_tzset())
	    _tlzknown++;
	else return 0;
    }
    if (zp) *zp = _tlz;
    return 1;
}

int
time_tzset()
{
#if SYS_V6
    extern int timezone;

    _tlz.tmz_minwest = timezone;
    _tlz.tmz_secwest = timezone * 60L;
    _tlz.tmz_dsttype = 1;		/* Assume USA */
#else
#if SYS_SYSV
    extern long timezone;	/* timezone in secs */
    extern int daylight;
    extern char *tzname[2];
    extern void tzset();

    tzset();
    _tlz.tmz_secwest = timezone;	/* Get zone in secs */
    _tlz.tmz_minwest = timezone/60;	/* Get zone in mins */
    _tlz.tmz_dsttype = daylight;	/* Get type of DST to apply */
    _tlz.tmz_name = tzname[0];
    _tlz.tmz_dname = tzname[1];

#else	/* Vanilla V7 and BSD */
    extern char *timezone();
    struct timeb tmb;
    static char znam[20], znam2[20];

    if (ftime(&tmb) != 0)
	return 0;		/* Failed?? */
    _tlz.tmz_minwest = tmb.timezone;	/* Get zone in mins */
    _tlz.tmz_secwest = tmb.timezone * 60L;	/* and in secs */
    _tlz.tmz_dsttype = tmb.dstflag;		/* Get type of DST to apply */
    strncpy(znam, timezone(tmb.timezone, 0), 20);
    strncpy(znam2,timezone(tmb.timezone, 1), 20);
    _tlz.tmz_name = znam;
    _tlz.tmz_dname = znam2;
#endif /* V7 || BSD */
#endif /* SYS_SYSV */
    return 1;
}
