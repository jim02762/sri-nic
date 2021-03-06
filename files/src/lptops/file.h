/*
**	Definitions for various file-oriented calls
**		access(2), lseek(2), open(2)
*/

/*
**	access(2) mode flags
*/

#define F_OK	0	/* test for presence of file */
#define X_OK	1	/* test for execute (search) permission */
#define W_OK	2	/* test for write permission */
#define R_OK	4	/* test for read permission */

/*
**	lseek(2) "whence" values
*/

#define L_SET	0	/* set the seek pointer */
#define L_INCR	1	/* increment the seek pointer */
#define L_XTND	2	/* extend the file size */

/*
**	open(2) mode flags
*/

#define O_RDONLY	(0)		/* open for reading only */
#define O_WRONLY	(01)		/* open for writing only */
#define O_RDWR		(02)		/* open for reading and writing */
#define O_NDELAY	(04)		/* do not block on open */
#define O_APPEND	(010)		/* append on each write */
/*			(020)*/		/* reserved */
/*			(040)*/		/* reserved */
#define O_CREAT		(01000)		/* create file if it does not exist */
#define O_TRUNC		(02000)		/* truncate size to 0 */
#define O_EXCL		(04000)		/* error if create and file exists */
	/* KCC specific flags */
#define O_BINARY	(0100)		/* Open in binary mode (sys-dep) */
#define O_CONVERTED	(0200)		/* Forced conversion requested */
#define O_UNCONVERTED	(0400)		/* Forced NO conversion requested */
#define O_BSIZE_MASK	(070000)	/* Mask: Force specified byte size */
#define  O_BSIZE_7	(010000)	/*  Bytesize value: 7-bit */
#define  O_BSIZE_8	(020000)	/*  Bytesize value: 8-bit */
#define  O_BSIZE_9	(030000)	/*  Bytesize value: 9-bit */
	/* T20 and 10X specific flags */
#define O_T20_WILD	(1<<18)		/* Allow wildcards on GTJFN% */
#define O_T20_WROLD	(1<<19)		/* For writes, do NOT use GJ%FOU */

