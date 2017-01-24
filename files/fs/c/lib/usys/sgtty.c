/*
**	SGTTY
**
**	(c) Copyright Ken Harrenstien 1989
**		for all changes after v.4, 27-May-1987
**	Copyright (C) 1987 by Ian Macky, SRI International
*/

#include <sgtty.h>

extern int ioctl();	/* Syscall */

/*
 *	Get TTY characteristics
 */

gtty(fd, buf)
int fd;
struct sgttyb *buf;
{
    return ioctl(fd, TIOCGETP, buf);
}

/*
 *	Set TTY characteristics
 */

stty(fd, buf)
int fd;
struct sgttyb *buf;
{
    return ioctl(fd, TIOCSETP, buf);
}
