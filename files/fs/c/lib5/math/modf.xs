
<C.LIB.MATH>CEIL.C.7

( 1.12) {modf}
	extern double modf();

( 1.15) {modf}
	if (modf(x, &i) > 0)	/* if there's a fractional part of x, */

<C.LIB.MATH>EXP.C.10

( 3.12) {modf}
	v = 16.0 * modf((x * LOG2E), &y);

( 3.13) {modf}
	w = _sign(modf(fabs(v), &i), v) / 16.0;

<C.LIB.MATH>FLOOR.C.7

( 1.12) {modf}
	extern double modf();

( 1.15) {modf}
	if (modf(x, &i) < 0)	/* if negative and has fractional part */

<C.LIB.MATH>FMOD.C.3

( 1.12) {modf}
	extern double modf();

( 1.15) {modf}
	modf((x / y), &i);	/* integer part in i, forget remainder */

<C.LIB.MATH>MODF.C.85

( 1.4) {modf}
 *	This code conforms with the description of the modf function

( 1.23) {modf}
modf(x, nptr)

( 1.82) {modf}
	 JRST modf5		; Positive shift, left.

( 1.109) {modf}
#error modf() not implemented for this CPU.

<C.LIB.MATH>POW.C.5

( 2.24) {modf}
	if (modf(y, &i) == 0.0) {

<C.LIB.PML>DEXP.C.2

( 3.5) {modf}
    double w, v, a, b, t, wpof2, zpof2, fabs(), dscale(), modf();

( 3.16) {modf}
	v = 16.0 * modf(t, &y);

( 3.17) {modf}
	modf(fabs(v), &index);

( 3.23) {modf}
	w = modf(v) / 16.0;

<C.LIB.STDIO>PRINTF.C.25

( 2.15) {modf}
extern double modf(), floor();

( 13.40) {modf}
 *	Cannot use a single modf call because the integer part may

( 13.43) {modf}
 *	up calling modf on each digit.

( 13.59) {modf}
		  {	d = modf(d * 10.0, &i);

( 13.78) {modf}
	d = modf(d, &junk);		/* Get fractional part */

( 13.83) {modf}
	  {	d = modf(d*10.0, &junk);


	Lines recognized = 23
   String    Matches  Unrecognized Matches
1) "modf"	23	0
Exact match search performed.

Files with no matches: 	<C.LIB>ABORT.C.9	<C.LIB>ATOI.C.10
<C.LIB>BSEARC.C.9	<C.LIB>CLOCK.C.1	<C.LIB>CPU.C.10
<C.LIB>CRT.C.63	<C.LIB>CTERMI.C.3	<C.LIB>CTIME.C.42
<C.LIB>CTYPE.C.3	<C.LIB>GETCWD.C.6	<C.LIB>GETENV.C.18
<C.LIB>GETLOG.C.1	<C.LIB>GETOPT.C.1	<C.LIB>JSYS.C.34
<C.LIB>LIBCKX.C.2	<C.LIB>LJERR.C.1	<C.LIB>MALLOC.C.188
<C.LIB>MEMSTR.C.9	<C.LIB>MUUO.C.2	<C.LIB>OLD-BCOPY.C.12
<C.LIB>OLD-C-HDR.C.3	<C.LIB>OLD-PFORK.C.16	<C.LIB>ONEXIT.C.2
<C.LIB>PERROR.C.11	<C.LIB>PSIGNA.C.2	<C.LIB>QSORT.C.4
<C.LIB>REGEX.C.1	<C.LIB>SETJMP.C.17	<C.LIB>SSIGNA.C.8
<C.LIB>STRERR.C.4	<C.LIB>STRING.C.39	<C.LIB>STRUNG.C.5
<C.LIB>SYSCAL.C.4	<C.LIB>SYSTEM.C.7	<C.LIB>TIMEMK.C.7
<C.LIB>TIMEPA.C.7	<C.LIB>TIMEZN.C.6	<C.LIB>TRMCAP.C.30
<C.LIB.MATH>ABS.C.5	<C.LIB.MATH>ACOS.C.3	<C.LIB.MATH>ASIN.C.3
<C.LIB.MATH>ATAN.C.7	<C.LIB.MATH>ATAN2.C.6	<C.LIB.MATH>COS.C.7
<C.LIB.MATH>COSH.C.3	<C.LIB.MATH>DIV.C.2	<C.LIB.MATH>FABS.C.4
<C.LIB.MATH>FREXP.C.26	<C.LIB.MATH>LABS.C.4	<C.LIB.MATH>LDEXP.C.4
<C.LIB.MATH>LOG.C.8	<C.LIB.MATH>LOG10.C.5	<C.LIB.MATH>MTEST.C.6
<C.LIB.MATH>POLY.C.5	<C.LIB.MATH>RAND.C.24	<C.LIB.MATH>SIGN.C.3
<C.LIB.MATH>SIN.C.6	<C.LIB.MATH>SINH.C.3	<C.LIB.MATH>SQRT.C.5
<C.LIB.MATH>TAN.C.3	<C.LIB.MATH>TANH.C.4	<C.LIB.MATH>XEXP.C.5
<C.LIB.MATH>XMANT.C.3	<C.LIB.NETWORK>GETHST.C.8	<C.LIB.PML>CCTEST.C.1
<C.LIB.PML>DACOS.C.1	<C.LIB.PML>DACOSH.C.1	<C.LIB.PML>DASIN.C.2
<C.LIB.PML>DASINH.C.1	<C.LIB.PML>DATAN.C.1	<C.LIB.PML>DATAN2.C.3
<C.LIB.PML>DATANH.C.1	<C.LIB.PML>DCOS.C.2	<C.LIB.PML>DCOSH.C.1
<C.LIB.PML>DLN.C.1	<C.LIB.PML>DLOG.C.1	<C.LIB.PML>DPOLY.C.1
<C.LIB.PML>DPOWER.C.17	<C.LIB.PML>DSCALE.C.1	<C.LIB.PML>DSIGN.C.2
<C.LIB.PML>DSIN.C.4	<C.LIB.PML>DSINH.C.1	<C.LIB.PML>DSQRT.C.1
<C.LIB.PML>DTAN.C.1	<C.LIB.PML>DTANH.C.1	<C.LIB.PML>DXEXP.C.1
<C.LIB.PML>DXMANT.C.2	<C.LIB.PML>FTEST1.C.8	<C.LIB.PML>FTESTE.C.1
<C.LIB.PML>PMLERR.C.2	<C.LIB.PML>TEST.C.3	<C.LIB.PML>TLN.C.8
<C.LIB.PML>TP.C.7	<C.LIB.PML.COMPLEX>CADD.C.1	<C.LIB.PML.COMPLEX>CASIN.C.1
<C.LIB.PML.COMPLEX>CATAN.C.1	<C.LIB.PML.COMPLEX>CCOS.C.1	<C.LIB.PML.COMPLEX>CCOSH.C.1
<C.LIB.PML.COMPLEX>CDIV.C.1	<C.LIB.PML.COMPLEX>CEXP.C.1	<C.LIB.PML.COMPLEX>CLN.C.1
<C.LIB.PML.COMPLEX>CMULT.C.1	<C.LIB.PML.COMPLEX>CRCP.C.1	<C.LIB.PML.COMPLEX>CSIN.C.1
<C.LIB.PML.COMPLEX>CSINH.C.1	<C.LIB.PML.COMPLEX>CSQRT.C.1	<C.LIB.PML.COMPLEX>CSUBT.C.1
<C.LIB.PML.COMPLEX>CTAN.C.1	<C.LIB.PML.COMPLEX>CTANH.C.1	<C.LIB.PML.COMPLEX>FTEST2.C.1
<C.LIB.PML.COMPLEX>FTEST3.C.1	<C.LIB.STDIO>CLEANU.C.4	<C.LIB.STDIO>FCLOSE.C.22
<C.LIB.STDIO>FDOPEN.C.15	<C.LIB.STDIO>FFLUSH.C.35	<C.LIB.STDIO>FGETC.C.18
<C.LIB.STDIO>FGETS.C.22	<C.LIB.STDIO>FILBUF.C.45	<C.LIB.STDIO>FOPEN.C.27
<C.LIB.STDIO>FPUTC.C.37	<C.LIB.STDIO>FPUTS.C.13	<C.LIB.STDIO>FREAD.C.16
<C.LIB.STDIO>FREOPE.C.51	<C.LIB.STDIO>FSEEK.C.25	<C.LIB.STDIO>FTELL.C.22
<C.LIB.STDIO>FWRITE.C.12	<C.LIB.STDIO>GETS.C.9	<C.LIB.STDIO>GETW.C.6
<C.LIB.STDIO>MKTEMP.C.8	<C.LIB.STDIO>PERROR.C.1	<C.LIB.STDIO>PUTS.C.6
<C.LIB.STDIO>PUTW.C.5	<C.LIB.STDIO>REMOVE.C.2	<C.LIB.STDIO>RENAME.C.2
<C.LIB.STDIO>REWIND.C.2	<C.LIB.STDIO>SCANF.C.187	<C.LIB.STDIO>SETBUF.C.30
<C.LIB.STDIO>SOPEN.C.16	<C.LIB.STDIO>TEST.C.2	<C.LIB.STDIO>TMPFIL.C.3
<C.LIB.STDIO>TMPNAM.C.4	<C.LIB.STDIO>UNGETC.C.22	<C.LIB.STDIO>VPRINT.C.1
<C.LIB.STDIO.NEW>FCLOSE.C.1	<C.LIB.STDIO.NEW>FFLUSH.C.1	<C.LIB.STDIO.NEW>FILBUF.C.1
<C.LIB.STDIO.NEW>FPUTC.C.1	<C.LIB.STDIO.NEW>FREOPE.C.1	<C.LIB.STDIO.NEW>FSEEK.C.1
<C.LIB.STDIO.NEW>S.C.1	<C.LIB.STDIO.NEW>SOPEN.C.1	<C.LIB.TEST>BUGCOS.C.4
<C.LIB.TEST>HELLO.C.1	<C.LIB.TEST>NFILES.C.2	<C.LIB.TEST>PASSON.C.3
<C.LIB.TEST>SHOARG.C.5	<C.LIB.TEST>TALARM.C.3	<C.LIB.TEST>TBCOPY.C.1
<C.LIB.TEST>TBSEAR.C.2	<C.LIB.TEST>TCAT.C.3	<C.LIB.TEST>TCHDIR.C.8
<C.LIB.TEST>TCHMOD.C.5	<C.LIB.TEST>TCHOWN.C.2	<C.LIB.TEST>TCSTI.C.8
<C.LIB.TEST>TCTYPE.C.1	<C.LIB.TEST>TEXEC.C.2	<C.LIB.TEST>TFSEEK.C.4
<C.LIB.TEST>TFTEL1.C.1	<C.LIB.TEST>TFTEL2.C.1	<C.LIB.TEST>TGFRKS.C.1
<C.LIB.TEST>TMALL1.C.1	<C.LIB.TEST>TMALL2.C.1	<C.LIB.TEST>TMATH.C.1
<C.LIB.TEST>TNREAD.C.1	<C.LIB.TEST>TPID.C.1	<C.LIB.TEST>TPRINT.C.1
<C.LIB.TEST>TPSI20.C.1	<C.LIB.TEST>TQUIT.C.3	<C.LIB.TEST>TSGTTY.C.3
<C.LIB.TEST>TSIGS.C.18	<C.LIB.TEST>TSPEED.C.1	<C.LIB.TEST>TSTAT.C.6
<C.LIB.TEST>TSTRIN.C.1	<C.LIB.TEST>TSYSTE.C.1	<C.LIB.TEST>TTIME.C.7
<C.LIB.TEST>TUTIME.C.1	<C.LIB.TEST>TVBUF.C.1	<C.LIB.USYS>ACCESS.C.10
<C.LIB.USYS>ALARM.C.5	<C.LIB.USYS>BUFPOS.C.18	<C.LIB.USYS>CHDIR.C.3
<C.LIB.USYS>CHMOD.C.10	<C.LIB.USYS>CHOWN.C.4	<C.LIB.USYS>CLOSE.C.59
<C.LIB.USYS>DUP.C.19	<C.LIB.USYS>EXIT.C.2	<C.LIB.USYS>FCNTL.C.13
<C.LIB.USYS>FORKEX.C.11	<C.LIB.USYS>GETPID.C.30	<C.LIB.USYS>GETUID.C.3
<C.LIB.USYS>IOCTL.C.59	<C.LIB.USYS>LSEEK.C.32	<C.LIB.USYS>NREAD.C.1
<C.LIB.USYS>OLD-FORK.C.36	<C.LIB.USYS>OPEN.C.223	<C.LIB.USYS>PAUSE.C.3
<C.LIB.USYS>PIPE.C.24	<C.LIB.USYS>READ.C.100	<C.LIB.USYS>RENAME.C.17
<C.LIB.USYS>SBRK.C.29	<C.LIB.USYS>SGTTY.C.4	<C.LIB.USYS>SIGDAT.C.19
<C.LIB.USYS>SIGNAL.C.2	<C.LIB.USYS>SIGVEC.C.161	<C.LIB.USYS>SLEEP.C.15
<C.LIB.USYS>STAT.C.138	<C.LIB.USYS>TIME.C.75	<C.LIB.USYS>TIMES.C.2
<C.LIB.USYS>UIODAT.C.17	<C.LIB.USYS>UNLINK.C.27	<C.LIB.USYS>URT.C.118
<C.LIB.USYS>URTSUD.C.6	<C.LIB.USYS>UTIME.C.6	<C.LIB.USYS>WAIT.C.32
<C.LIB.USYS>WRITE.C.63	<C.LIB.USYS.NEW>CLOSE.C.1	<C.LIB.USYS.NEW>LSEEK.C.1
<C.LIB.USYS.NEW>OPEN.C.1	<C.LIB.USYS.NEW>READ.C.1
237 files searched, 229 without matches.
