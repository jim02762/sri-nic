/* STAT.H
**	Structure returned by stat() and fstat() calls.
**	Not all of this is meaningful for T20, and some extended
** components were added for xstat/xfstat.
*/

#define UNIX_OWNER_MASK		0700
#define UNIX_OWNER_OFFSET	0
#define UNIX_GROUP_MASK		0070
#define UNIX_GROUP_OFFSET	3
#define UNIX_WORLD_MASK		0007
#define UNIX_WORLD_OFFSET	6

struct	stat
{
	dev_t	st_dev;		/* The .DVxxx device type */
	ino_t	st_ino;		/* .FBADR - Disk address of file index blk */
	unsigned int st_mode;	/* Un*x-style mode bits */
	int	st_nlink;	/* 1 (always) */
	int	st_uid;		/* T20: User #, 10X: directory # */
	int	st_gid;		/* 0 (always, for now) */
	dev_t	st_rdev;	/* 0 (always, for now) */
	off_t	st_size;	/* .FBSIZ - size in bytes (any bytesize) */
	time_t	st_atime;	/* .FBREF - last ref (Un*x format time) */
	int	st_spare1;
	time_t	st_mtime;	/* .FBWRT - last write (Un*x format time) */
	int	st_spare2;
	time_t	st_ctime;	/* .FBCRE - last mod (Un*x format time) */
	int	st_spare3;
	long	st_blksize;	/* # bytes in a page (derived from FB%BSZ) */
	long	st_blocks;	/* # pages in file (FB%PGC of .FBBYV) */
	long	st_spare4[2];
};

struct xstat {
    struct stat st;			/* include original structure */
    union {				/* device-dependant portion */
	struct {
	    int state;			/* connection state */
	    int fhost;			/* foreign host# */
	    int fport;			/* foreign port# */
	} tcp;
	struct {
	    int version;		/* version# of file */
	    int pagcnt;			/* count of # pages in file */
	    int bytsiz;			/* byte size of file */
	} disk;
    } dev_dep;
};

#define xst_fhost	dev_dep.tcp.fhost
#define xst_fport	dev_dep.tcp.fport
#define xst_state	dev_dep.tcp.state
#define xst_version	dev_dep.disk.version
#define xst_pagcnt	dev_dep.disk.pagcnt
#define xst_bytsiz	dev_dep.disk.bytsiz

#define ST_DEV_DSK	0
#define ST_DEV_MTA	2
#define ST_DEV_LPT	7
#define ST_DEV_CDR	010
#define ST_DEV_FE	011
#define ST_DEV_TTY	012
#define ST_DEV_PTY	013
#define ST_DEV_NUL	015
#define ST_DEV_NET	016	/* old stuff? */
#define ST_DEV_DCN	022	/* DECnet active component */
#define ST_DEV_SRV	023	/* DECnet passive component */
#define ST_DEV_TCP	025

#define	S_IFMT	0170000		/* type of file */
#define		S_IFDIR	0040000	/* directory */
#define		S_IFCHR	0020000	/* character special */
#define		S_IFBLK	0060000	/* block special */
#define		S_IFREG	0100000	/* regular */
#define		S_IFLNK	0120000	/* symbolic link */
#define		S_IFSOCK 0140000/* socket */
#define	S_ISUID	0004000		/* set user id on execution */
#define	S_ISGID	0002000		/* set group id on execution */
#define	S_ISVTX	0001000		/* save swapped text even after use */
#define	S_IREAD	0000400		/* read permission, owner */
#define	S_IWRITE 0000200	/* write permission, owner */
#define	S_IEXEC	0000100		/* execute/search permission, owner */
