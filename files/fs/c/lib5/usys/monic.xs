<6-1-MONITOR>APRSRV.MAC.1

( 106.53) {.IC}
	    MOVEI 1,.ICILI	;INITIATE ILLEGAL INSTRUCTION INTERRUPT

<6-1-MONITOR>DDT.MAC.1

( 266.41) {.IC}
	TXNN	T1,1B<.ICNXP>	;[570] PAGE CREATES BEING TRAPPED?

( 266.45) {.IC}
	MOVX	T2,1B<.ICNXP>	;[570]  TO DEACTIVATE THE CHANNEL IN ORDER

( 266.61) {.IC}
	MOVX	T2,1B<.ICNXP>	;[570]  PSI CHANNEL SO THE USER CAN'T

<6-1-MONITOR>FORK.MAC.1

( 14.26) {.IC}
	MOVE 2,BITS+.ICMSE	;GOT INT. SEE IF FATAL

<6-1-MONITOR>IO.MAC.1

( 3.16) {.IC}
	 SKIPA T1,BITS+.ICDAE	;NO, GO DO INTERRUPT

( 21.65) {.IC}
	 SKIPA A,BITS+.ICEOF	;NO, CAUSE INTERRUPT ON CHANNEL 10

( 22.30) {.IC}
UNLDS2:	MOVE A,BITS+.ICQTA	;GET CHANNEL BITS

<6-1-MONITOR>IPIPIP.MAC.2

( 25.13) {.IC}
	MOVX T2,1B<.ICEOF>	; End of file channel


<6-1-MONITOR>JSYSA.MAC.1

( 75.47) {.IC}
	MOVEI T1,.ICQTA		;GET QUOTA EXCEEDED INTERRUPT CHANNEL

<6-1-MONITOR>MEXEC.MAC.2

( 7.23) {.IC}
	MOVEI T3,.ICMSE		;ON MACHINE-SIZE EXC CHANNEL, SO PANIC

<6-1-MONITOR>PAGEM.MAC.1

( 8.69) {.IC}
	MOVEI 2,.ICILI		;ERROR CHANNEL

( 8.71) {.IC}
	MOVEI 2,.ICQTA		;YES - USE THIS CHL

( 12.41) {.IC}
	MOVEI A,.ICIRD		;GENERATE ILLEGAL MEM READ

( 22.76) {.IC}
	MOVEI 1,.ICDAE

( 62.12) {.IC}
	MOVX T1,.ICDAE		;INITIATE PSI ON DATA ERROR CHANNEL

( 76.8) {.IC}
	MOVX T1,.ICIWR		;MW INTERRUPT CHANNEL

( 76.22) {.IC}
ILRD1:	MOVX 1,.ICIRD		;MR TRAP CHANNEL

( 80.9) {.IC}
	TXNN 1,1B<.ICNXP>	;USER MAP AND NON-X PAGE CHANNEL ON?

( 80.13) {.IC}
	MOVX 1,.ICNXP		;YES, REQUEST INTERRUPT

( 81.8) {.IC}
	;IFXE. T1,<1B<.ICMSE>>

( 81.12) {.IC}
	MOVX 1,.ICMSE		;MACH SIZE EXCEEDED INT CHANNEL

( 87.29) {.IC}
	MOVX 1,.ICQTA		;QUOTA EXCEDED CHL

( 87.32) {.IC}
	MOVX T1,.ICMSE		;MACH SIZE CHNL

( 93.28) {.IC}
	MOVX 1,.ICDAE		;FILE DATA ERROR PSI CHANNEL

( 94.52) {.IC}
	MOVX T1,.ICDAE		;FILE DATA ERROR PSI CHANNEL

<6-1-MONITOR>SCAPAR.MAC.1

( 29.71) {.IC}
	.ICLST==^D35		;Highest valid PSI channel value

<6-1-MONITOR>SCHED.MAC.1

( 21.124) {.IC}
	MOVEI 1,.ICILI		;INITIATE CHANNEL 15 INTERRUPT

( 40.46) {.IC}
MPEINT:	MOVEI 2,.ICDAE		;GIVES I/O ERROR INTERRUPT

( 146.49) {.IC}
	      MOVE T1,BITS+.ICPOV ;CHANNEL 9 INTERRUPT

( 146.56) {.IC}
		MOVE T1,BITS+.ICIWR ;ILLEGAL MEMORY WRITE

<6-1-MONITOR>SCSJSY.MAC.1

( 23.29) {.IC}
	CAIG T2,.ICLST		;Within range of reasonable PSI channels???

<6-1-MONITOR>SETSPD.MAC.1

( 6.41) {.IC}
.ICLPO==0			;CHANNEL FOR LINE PRINTER OFFLINE

( 6.42) {.IC}
.ICHNG==1			;CHANNEL FOR TIMER INTERRUPT

( 6.49) {.IC}
CHNTAB:	XWD 1,LPTINT		;.ICLPO CHANNEL

( 6.50) {.IC}
	XWD 2,HUNG		;.ICHNG CHANNEL

( 8.14) {.IC,.IC}
	MOVX B,1B<.ICLPO>!1B<.ICHNG>  ;ACTIVATE LINE PRINTER OFFLINE

( 8.29) {.IC}
	MOVEI T3,.ICHNG		;SPECIFY HUNG PSI CHANNEL

( 8.36) {.IC}
	MOVE T2,[1B<.ICHNG>]	;CHANNEL FOR TIMER JSYS

( 23.55) {.IC}
	MOVEI P2,.ICLPO		;LINE PRINTER OFFLINE CHANNEL


	Lines recognized = 81
   String    Matches  Unrecognized Matches
1) ".IC"	82	0
Exact match search performed.

Files with no matches: 	<6-1-MONITOR>ARP.MAC.1	<6-1-MONITOR>BUGS.MAC.1
<6-1-MONITOR>CFSSRV.MAC.1	<6-1-MONITOR>CIDLL.MAC.1	<6-1-MONITOR>COMND.MAC.3
<6-1-MONITOR>CRYPT.MAC.1	<6-1-MONITOR>DATIME.MAC.5	<6-1-MONITOR>DEVICE.MAC.1
<6-1-MONITOR>DIAG.MAC.1	<6-1-MONITOR>DIRECT.MAC.1	<6-1-MONITOR>DISC.MAC.2
<6-1-MONITOR>DOMSYM.MAC.2	<6-1-MONITOR>DSKALC.MAC.1	<6-1-MONITOR>DTESRV.MAC.1
<6-1-MONITOR>ENET.MAC.1	<6-1-MONITOR>ENQ.MAC.1	<6-1-MONITOR>ERBLD.MAC.1
<6-1-MONITOR>F2KDDT.MAC.1	<6-1-MONITOR>F2MDDT.MAC.1	<6-1-MONITOR>FESRV.MAC.1
<6-1-MONITOR>FILINI.MAC.1	<6-1-MONITOR>FILMSC.MAC.1	<6-1-MONITOR>FREE.MAC.2
<6-1-MONITOR>FUTILI.MAC.5	<6-1-MONITOR>GETSAV.MAC.1	<6-1-MONITOR>GLOBS.MAC.5
<6-1-MONITOR>GTDOM.MAC.86	<6-1-MONITOR>GTJFN.MAC.3	<6-1-MONITOR>IMPANX.MAC.1
<6-1-MONITOR>IMPDV.MAC.3	<6-1-MONITOR>IPCF.MAC.1	<6-1-MONITOR>IPCIDV.MAC.1
<6-1-MONITOR>IPFREE.MAC.11	<6-1-MONITOR>JSYSF.MAC.2	<6-1-MONITOR>LATSRV.MAC.1
<6-1-MONITOR>LDINIT.MAC.1	<6-1-MONITOR>LINEPR.MAC.1	<6-1-MONITOR>LOGNAM.MAC.2
<6-1-MONITOR>LOOKUP.MAC.3	<6-1-MONITOR>LPFEDV.MAC.1	<6-1-MONITOR>MFLIN.MAC.1
<6-1-MONITOR>MFLOUT.MAC.1	<6-1-MONITOR>MNETDV.MAC.30	<6-1-MONITOR>MSCPAR.MAC.1
<6-1-MONITOR>MSTR.MAC.1	<6-1-MONITOR>NAMNIC.MAC.1	<6-1-MONITOR>NIPAR.MAC.1
<6-1-MONITOR>PAGUTL.MAC.1	<6-1-MONITOR>PARAMS.MAC.9	<6-1-MONITOR>PARNEW.MAC.6
<6-1-MONITOR>PARNIC.MAC.3	<6-1-MONITOR>PHYH2.MAC.1	<6-1-MONITOR>PHYMEI.MAC.1
<6-1-MONITOR>PHYMVR.MAC.1	<6-1-MONITOR>PHYP4.MAC.1	<6-1-MONITOR>PHYSIO.MAC.1
<6-1-MONITOR>PIPE.MAC.1	<6-1-MONITOR>PKOPR.MAC.1	<6-1-MONITOR>PNVSRV.MAC.1
<6-1-MONITOR>POSTLD.MAC.1	<6-1-MONITOR>PROLOG.MAC.1	<6-1-MONITOR>PUP.MAC.1
<6-1-MONITOR>PUPNM.MAC.1	<6-1-MONITOR>PUPSYM.MAC.1	<6-1-MONITOR>REL1.MAC.1
<6-1-MONITOR>RSXSRV.MAC.1	<6-1-MONITOR>SCAMPI.MAC.1	<6-1-MONITOR>SCPAR.MAC.1
<6-1-MONITOR>SERCOD.MAC.1	<6-1-MONITOR>SITE.MAC.4	<6-1-MONITOR>STG.MAC.11
<6-1-MONITOR>SWPALC.MAC.1	<6-1-MONITOR>SYSERR.MAC.1	<6-1-MONITOR>SYSFLG.MAC.1
<6-1-MONITOR>TAPE.MAC.1	<6-1-MONITOR>TCPBBN.MAC.1	<6-1-MONITOR>TCPCRC.MAC.1
<6-1-MONITOR>TCPJFN.MAC.1	<6-1-MONITOR>TCPTCP.MAC.3	<6-1-MONITOR>TIMER.MAC.1
<6-1-MONITOR>TTYDEF.MAC.1	<6-1-MONITOR>TTYSRV.MAC.1	<6-1-MONITOR>TVTSRV.MAC.1
<6-1-MONITOR>VERSIO.MAC.3
108 files searched, 84 without matches.
