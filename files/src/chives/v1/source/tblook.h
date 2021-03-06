/*
 * Copyright (c) 1987,1988 Massachusetts Institute of Technology.
 *
 * Note that there is absolutely NO WARRANTY on this software.
 * See the file COPYRIGHT.NOTICE for details and restrictions.
 */

/*
 * String lookup routines and definitions (see tblook.c).
 */

extern int tblook();			/* convert name to value */

extern char *looktb();			/* convert value to name */

extern struct tblook_table {		/* data structure for tables */
    int code;
    char *name;
} *tbload();				/* load table from text file */
