/*								-*-C-*-
***************************************************************
**	C-ENV.H - C Environment definition file
**		All C library routines should include this file
**		for any system/configuration definitions.
**
**		User programs should generally not be so site
**		dependent, but may also include this file to
**		deal with any unavoidable dependencies.
***************************************************************
*/

/* SYSTEM specification: (prefix with SYS_)
 *	Define only one of the following to be 1.
 */
#ifndef SYS_T20
#define SYS_T20 0	/* DEC TOPS20 system */
#endif
#ifndef SYS_10X
#define SYS_10X 0	/* BBN TENEX system */
#endif
#ifndef SYS_T10
#define SYS_T10 0	/* DEC TOPS10 system */
#endif
#ifndef SYS_WAITS
#define SYS_WAITS 0	/* Stanford WAITS system */
#endif
#ifndef SYS_ITS
#define SYS_ITS 0	/* MIT ITS system */
#endif
#ifndef SYS_BSD		/* BSD Unix system */
#define SYS_BSD	0
#endif
#ifndef SYS_SYSV	/* System V Unix */
#define SYS_SYSV 0
#endif
#ifndef SYS_V7		/* Another Unix thing */
#define SYS_V7 0
#endif
#ifndef SYS_MSDOS	/* gross MSDOS!!  gross gross */
#define SYS_MSDOS 0
#endif

/* Assign default if none of the above were furnished */
#if (SYS_T20+SYS_10X+SYS_T10+SYS_WAITS+SYS_ITS+SYS_BSD+SYS_SYSV+SYS_V7+SYS_MSDOS)==0
#undef SYS_ITS
#define SYS_ITS 1	/* Default is ITS */
#endif

#define SYS_UNIX	(SYS_BSD+SYS_SYSV+SYS_V7)

/* PROCESSOR specification: (prefix with CPU_)
 *	Define only one of the following to be 1.
 */

#ifndef CPU_KA
#define CPU_KA 0	/* DEC KA-10 */
#endif
#ifndef CPU_KI
#define CPU_KI 0	/* DEC KI-10 */
#endif
#ifndef CPU_KS
#define CPU_KS 0	/* DEC KS-10 (2020) or KL-10 (single section) */
#endif
#ifndef CPU_KL0
#define CPU_KL0 0	/* DEC KL-10 (extended, section 0) */
#endif
#ifndef CPU_KLX
#define CPU_KLX 0	/* DEC KL-10 (extended, non-zero section) */
#endif

/* Assign default if none of above are specified */
#if (CPU_KA+CPU_KI+CPU_KS+CPU_KL0+CPU_KLX)==0
#undef CPU_KS
#define CPU_KS 1	/* Default is KS-10 */
#endif

/* CPU_KL is true if processor is some kind of DEC PDP-10 KL */
#define CPU_KL (CPU_KS|CPU_KL0|CPU_KLX)

/* CPU_PDP10 is true if processor is any kind of DEC PDP-10 */
#define CPU_PDP10 (CPU_KA+CPU_KI+CPU_KL)


/* COMPILER specification: (prefix with COMPILER_)
 *	Define only one of the following to be 1.
 */

#ifndef COMPILER_KCC
#define COMPILER_KCC 0	/* KCC - PDP-10 only, Stanford/SRI */
#endif

/* Assign default if none of above are specified */
#if (COMPILER_KCC)==0
#undef  COMPILER_KCC
#define COMPILER_KCC 1
#endif

/* Data Type parameters: (prefix with CENV_) */

#define CENV_MAXCHAR (0777)		/* Max char value */

/* Other parameters: (prefix with CENV_) */

/* PDP-10 Hardware defs (used with #asm) */
#ifndef CENV_DMOVX
#define CENV_DMOVX (CPU_KI+CPU_KL)	/* Has DMOVx instructions */
#endif
#ifndef CENV_ADJSP
#define CENV_ADJSP (CPU_KL)		/* Has ADJSP instruction */
#endif
#ifndef CENV_ADJBP
#define CENV_ADJBP (CPU_KL)		/* Has ADJBP instruction */
#endif
#ifndef CENV_DFL_S
#define CENV_DFL_S (CPU_KA)		/* Use Software double prec fmt */
#endif
#ifndef CENV_DFL_H
#define CENV_DFL_H (CPU_KI+CPU_KL)	/* Use Hardware double prec fmt */
#endif
#ifndef CENV_DFL_G
#define CENV_DFL_G 0			/* Use "G" extended double prec fmt */
#endif
#ifndef CENV_EXADR
#define CENV_EXADR (CPU_KLX)		/* Has extended addressing */
#endif

#if 0
	The following is the file "c_env.h" from David Yost, as
	used for the Rand Editor.  It seems useful as an example
	of other things that may someday need to be known.
/*
 *   C Environment.
 *   Information about the machine and the compiler.
 *
 *   VAX 4.1bsd & 4.2bsd
 */

/*
 *  In the #define's that follow, define the first n to 'register'
 *  and the rest to nothing, where 'n' is the number of registers
 *  supported by your compiler.
 */
#define Reg1  register
#define Reg2  register
#define Reg3  register
#define Reg4  register
#define Reg5  register
#define Reg6  register
#define Reg7
#define Reg8
#define Reg9
#define Reg10
#define Reg11
#define Reg12

#define CHARMASK   0xFF
#define CHARNBITS  8
#define MAXCHAR	   0x7F

#define SHORTMASK  0xFFFF
#define SHORTNBITS 16
#define MAXSHORT   0x7FFF

#define LONGMASK  0xFFFFFFFF
#define LONGNBITS 32
#define MAXLONG	  0x7FFFFFFF

#define INTMASK	 0xFFFFFFFF
#define INTNBITS 32
#define MAXINT	 0x7FFFFFFF

#define BIGADDR		/* text address space > 64K */
/* fine ADDR64K		/* text and data share 64K of memory (no split I&D */

#define INT4		/* sizeof (int) == 4 */
/* fine INT2		/* sizeof (int) == 2 */

#define PTR4		/* sizeof (char *) == 4 */
/* fine PTR2		/* sizeof (char *) == 2 */

			/* unsigned types supported by the compiler: */
#define UNSCHAR		/* unsigned char  */
#define UNSSHORT	/* unsigned short */
#define UNSLONG		/* unsigned long  */

/* fine NOSIGNEDCHAR	/* there is no signed char type */

#define STRUCTASSIGN	/* Compiler does struct assignments */

#define UNIONS_IN_REGISTERS	/* compiler allows unions in registers */

/* fine void int	/* Fake the new 'void' type to an int */

/* Byte order: */
#define SHORT_10	/* pdp11, vax, 16000, 8086, 8080, ... */
#define LONG_3210	/* vax, 16000, 8086, 8080, ... */
/* fine LONG_0123	/* ibm, perkin-elmer, 68000, pyramid, ... */
/* fine LONG_1032	/* pdp11 */

#endif /* comment */
