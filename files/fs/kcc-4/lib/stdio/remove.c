/*
 *	REMOVE - remove or delete a file (CARM 2, sec 17.15)
 *
 *	Copyright (C) 1987 by Ken Harrenstien, SRI International
 *
 *	Returns 0 if succeeded or file didn't exist, non-zero otherwise.
 */

#include "errno.h"

int
remove(filename)
char *filename;
{
    int res;
    if ((res = unlink(filename)) == 0	/* If delete won, */
      || errno == ENOENT)		/* or failed cuz file not there */
	return 0;			/* then return Success */
    return res;			/* else return whatever failure value was */
}
