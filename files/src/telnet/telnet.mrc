	TITLE TELNET Multi-Network User TELNET
	SUBTTL Written by Mark Crispin - March 1979/MRC 22 July 1985

; Version components

TELWHO==0			; who last edited TELNET (0=MRC)
TELVER==5			; TELNET's release version (matches monitor's)
TELMIN==4			; TELNET's minor version
TELEDT==^D944			; TELNET's edit version

;  TELNET is the user subsystem to communicate with other systems via a
; network.  TELNET runs on TOPS-20 release 5.3 and later monitors.  TELNET
; will not run on Tenex; the "Twenex" operating system is a figment of the
; imagination of certain individuals.  There ain't no such thing as a free
; lunch.
;
;  TELNET was written by Mark Crispin at Stanford University starting March
; 1979 and continuously enhanced since that time.
	SUBTTL Definitions

	SEARCH MACSYM,MONSYM	; system definitions
	SALL			; suppress macro expansions
	.DIRECTIVE FLBLST	; sane listings for ASCIZ, etc.
	.TEXT "/NOINITIAL"	; suppress loading of JOBDAT
	.TEXT "TELNET/SAVE"	; save as TELNET.EXE
	.TEXT "/SYMSEG:PSECT:CODE" ; put symbol table and patch area in CODE
	.REQUIRE HSTNAM		; host name routines
	.REQUIRE SYS:MACREL	; MACSYM support routines

; Routines invoked externally

	EXTERN $GTPRO,$GTLCL
	EXTERN $GTHSN,$GTHNS,$PUPSN,$PUPNS,$CHSSN,$CHSNS,$DECSN,$DECNS

; Assembly switches

IFNDEF TPRPRT,<TPRPRT==^D23>	; Internet TELNET protocol port
IFNDEF NRTOBJ,<NRTOBJ==^D23>	; NRT object type (some sites may need 200)
IFNDEF FTXTND,<FTXTND==1>	; non-zero for unsupported "extended" features
IFNDEF DEFESC,<DEFESC==.CHCCF>	; default escape character
IFNDEF PDLLEN,<PDLLEN==^D100>	; stack lengths
IFNDEF TIMTCK,<TIMTCK==^D6>	; # of 5 second ticks before timeout
IFNDEF TTIBSZ,<TTIBSZ==^D50>	; size of TTY input buffer in words
IFNDEF TTOBSZ,<TTOBSZ==^D100>	; size of TTY output buffer in words
IFNDEF NTIBSZ,<NTIBSZ==^D100>	; size of NET input buffer in words
			; ^^ ** can't be less than ^D32, see DECnet ICP
IFNDEF NTOBSZ,<NTOBSZ==^D50>	; size of NET output buffer in words
IFNDEF CMDBSZ,<CMDBSZ==^D30>	; size of command text buffer
IFNDEF ATMBSZ,<ATMBSZ==^D10>	; size of atom buffer
IFNDEF PURBEG,<PURBEG==100000>	; origin of pure code
IFNDEF DDTADR,<DDTADR=770000>	; well known entry address of DDT

; AC's

A=:1				; JSYS, temporary AC's
B=:2
C=:3
D=:4
T=:5				; non-JSYS temporary AC's
TT=:6
P=:17				; stack pointer

; Pup Ethernet definitions (in case assembling with a non-Pup MONSYM)

; Pup SMON% functions

.SFDIR==:62			; initialize Pup directory
.SFBUG==:64			; enable/disable Pup bug logging
.SFPUP==:67			; enable/disable Pup Ethernet

; Pup MTOPR% functions

.MOPEF==:20			; send Mark
.MOPRM==:23			; return most recent Mark byte
.MOPRA==:26			; return abort data

; Pup GDSTS% flags

BS.MRK==:1B4			; BSP Mark seen
BS.END==:1B5			; BSP End seen

; Pup BSP Mark types

MK.DAT==:1			; Data Mark
MK.TIM==:5			; Timing Mark
MK.TMR==:6			; Timing Mark reply

; Miscellaneous definitions

CH%PAR==200			; parity bit
CH%CHR==^--CH%PAR		; character sans parity
	SUBTTL Macro definitions

; Fatal assembly error macro

DEFINE .FATAL (MESSAGE) <
 PASS2
 PRINTX ?'MESSAGE
 END
>;DEFINE .FATAL

; TELCMD protocol-command-list
; Sends a protocol command

DEFINE TELCMD (CMDLST) <
 TELCM1 <CMDLST>
 CALL NETFRC
>;DEFINE TELCMD

; Same as TELCMD, but don't do a NETFRC

DEFINE TELCM1 (CMDLST) <
 SKIPN DEBUGP
 IFSKP.
   TMSG<*S*'CMDLST'*
>
 ENDIF.
  MOVEI B,[BYTE (9) CMDLST,777]
  CALL NETSTR
>;DEFINE TELCM1

; TPC protocol-command-name,value
; Defines a protocol command and generates a string for it

DEFINE TPC (CODE,VALUE) <
 CODE==VALUE
 [ASCIZ/,'CODE'/]
>;DEFINE TPC

; CMD command-name
; Generates an entry in a keyword table

DEFINE CMD (COMMAND) <[ASCIZ/COMMAND/],,.'COMMAND>

; PARSE FLDDB.-list
; Parses the specified FLDDB., skip returns if successful parse

DEFINE PARSE (DATA) <
 PARSEA <[FLDDB. DATA]>
>;DEFINE PARSE

; PARSEA address
;  Parses an FLDDB. item found at the specified address.  Skip returns if
; successful parse

DEFINE PARSEA (ADDR) <
 MOVEI B,ADDR			;; load function block
 COMND%				;; this is the only COMND% in the source!
  ERJMP ERROR			;; some cases legitimately fail
 TXNE A,CM%NOP			;; skip if success
>;DEFINE PARSEA

; NOISE noise-word-string
; Outputs a noise word string if appropriate

DEFINE NOISE (STRING) <
 PARSE <.CMNOI,,<-1,,[ASCIZ/STRING/]>>
  JRST ERROR
>;DEFINE NOISE

; CONFIRM
; Requires carriage return confirmation, finishes up command parse

DEFINE CONFIRM <
 PARSE <.CMCFM>
  JRST ERROR
>;DEFINE CONFIRM

; EMSG string
; Types out an error message

DEFINE EMSG (STRING) <
 HRROI A,[ASCIZ/'STRING'/]
 ESOUT%
 SKIPE TAKEP
  CALL UNTAKE
>;DEFINE EMSG

; ERMSG string
; Types out an error message and RETs

DEFINE ERMSG (STRING) <
 IFNSK.
   EMSG <STRING>
   RET
 ENDIF.
>;DEFINE ERMSG

; ERNOP
; Ignores a JSYS error

DEFINE ERNOP <ERJMP .+1>

; REPORT flag,false-string,true-string
; Prints appropriate string depending upon status of flag

DEFINE REPORT (FLAG,FSTR,TSTR) <
 SKIPN FLAG
  SKIPA A,[-1,,[ASCIZ/
'FSTR'/]]
   HRROI A,[ASCIZ/
'TSTR'/]
 PSOUT%
>;DEFINE REPORT
	SUBTTL Data area

	LOC 20			; low core for PC/AC storage

FATACS:	BLOCK 20		; AC save area for FATAL routine
IF1,<IFN <.-40>,<.FATAL .JBUUO in wrong location>>
.JBUUO:	BLOCK 1			; instruction stored here on UUO execution
.JB41:	JSR UUOPC		; instruction executed on LUUO
IN1ACS:	BLOCK 20		; PSI level 1 AC save area
LEV1PC:	BLOCK 1			; PSI level 1 PC
LEV2PC:	BLOCK 1			; PSI level 2 PC
LEV3PC:	BLOCK 1			; PSI level 3 PC
REENTP:	BLOCK 1			; -1 => invoked by REENTER command
ESCCHR:	BLOCK 1			; escape character
TTYMOD:	BLOCK 1			; virgin TTY mode
TTYCOC:	BLOCK 1			; virgin TTY COC words
TTYTIW:	BLOCK 1			; virgin TTY interrupt word
UUOPC:	BLOCK 1			; PC of LUUO
	MOVEM 17,FATACS+17	; save AC's in FATACS for debugging
	MOVEI 17,FATACS		; save from 0 => FATACS
	BLT 17,FATACS+16	; ...to 16 => FATACS+16
	MOVE 17,FATACS+17	; restore AC17
	EMSG <Invalid instruction >
	MOVX A,.PRIOU		; output the losing LUUO
	MOVE B,.JBUUO
	MOVX C,^D8		; in octal
	NOUT%
	 NOP
	TMSG < at >
	HRRZ TT,UUOPC
	CALL SYMOUT
	JRST DEATH		; now die
	BLOCK <116-.>		; free space here
.JBSYM:	BLOCK 1			; symbol table from LINK
.JBUSY:	BLOCK 1			; undefined symbol table from LINK
IN2ACS:	BLOCK 20		; PSI level 2 AC save area

	RELOC			; .LOW. PSECT

	.PSECT DATA,1000	; enter data PSECT

PDL:	BLOCK PDLLEN		; main program stack
RPDL:	BLOCK PDLLEN		; receive fork stack

CORBEG==.			; first loc zeroed in main loop

; Flags

TTYINP:	BLOCK 1			; -1 => terminal TTYINI'd
NOCMDP:	BLOCK 1			; -1 => NO command seen
CHAOSP:	BLOCK 1			; -1 => Chaosnet connection
DCNP:	BLOCK 1			; -1 => DECnet connection
PUPP:	BLOCK 1			; -1 => Pup Ethernet connection
INTP:	BLOCK 1			; -1 => Internet connection
TTYP:	BLOCK 1			; -1 => TTY connection
TPROTP:	BLOCK 1			; -1 => using TELNET protocol
NETCMP:	BLOCK 1			; -1 => IAC in progress
WILLP:	BLOCK 1			; -1 => IAC WILL in progress
WONTP:	BLOCK 1			; -1 => IAC WONT in progress
DOP:	BLOCK 1			; -1 => IAC DO in progress
DONTP:	BLOCK 1			; -1 => IAC DONT in progress
ECHOP:	BLOCK 1			; -1 => remote host is echoing
SUPGAP:	BLOCK 1			; -1 => suppress GA mode
RCBINP:	BLOCK 1			; -1 => receiving binary
TRBINP:	BLOCK 1			; -1 => transmitting binary
NTOINP:	BLOCK 1			; <0 => output should be suppressed

; I/O buffers.  They must be in order PTR, CTR, BFR.

TTIPTR:	BLOCK 1			; TTY input buffer pointer
TTICTR:	BLOCK 1			; TTY input buffer counter
TTIBFR:	BLOCK TTIBSZ		; TTY input buffer
TTOPTR:	BLOCK 1			; TTY output buffer pointer
TTOCTR:	BLOCK 1			; TTY output buffer counter
TTOBFR:	BLOCK TTOBSZ		; TTY output buffer
NTIPTR:	BLOCK 1			; NET input buffer pointer
NTICTR:	BLOCK 1			; NET input buffer counter
NTIBFR:	BLOCK NTIBSZ		; NET input buffer
NTOPTR:	BLOCK 1			; NET output buffer pointer
NTOCTR:	BLOCK 1			; NET output buffer counter
NTOBFR:	BLOCK NTOBSZ		; NET output buffer

; JFNs

NETJFN:	BLOCK 1			; network JFN
TMPJFN:	BLOCK 1			; temporary file JFN

; Connection parameters

	; Following 2 lines must be in this order
HOST:	BLOCK 1			; host to connect to
PORT:	BLOCK 1			; port ditto

; Other stuff

REPARP:	BLOCK 1			; reparse P
OREPAP:	BLOCK 1			; connection open reparse P
RCVFRH:	BLOCK 1			; receive fork handle
TIMOUT:	BLOCK 1			; <0 means timer is running
FILBUF:	BLOCK ^D20		; buffer for net GTJFN% filename
GTJBLK:	BLOCK .GJATR+1		; GTJFN% block

COREND==.-1			; last loc zeroed in main loop

; Cells preserved across commands

INICBG==.			; first location cleared at once-only init
EXCFRH:	BLOCK 1			; inferior EXEC's fork handle
LOGJFN:	BLOCK 1			; log file JFN
CMDBUF:	BLOCK CMDBSZ		; command buffer
ATMBUF:	BLOCK ATMBSZ		; atom buffer

; Preserved flags

PARITP:	BLOCK 1			; -1 => parity enabled
MONCMP:	BLOCK 1			; -1 => saw a monitor command, exit when done
DEBUGP:	BLOCK 1			; -1 => debugging (show protocol negotiations)
OPAQUP:	BLOCK 1			; -1 => use stupid OPAQUE mode
PAGEP:	BLOCK 1			; -1 => use local page mode
TAKEP:	BLOCK 1			; -1 => TAKE file in progress
EXTENP:	BLOCK 1			; -1 => enter extended command mode on ^^
LINEDP:	BLOCK 1			; -1 => use line editor

INICEN==.-1			; last location cleared at once-only init time

	.ENDPS			; back to .LOW. PSECT
	SUBTTL Command parser data

; COMND% JSYS block

CMDBLK:	REPARS			; reparse address
	.PRIIN,,.PRIOU		; using the TTY
	0			; ^R buffer
	-1,,CMDBUF		; start of text buffer
	-1,,CMDBUF		; next input
	CMDBSZ*5		; size of command buffer
	0			; # of unparsed characters
	-1,,ATMBUF		; start of atom buffer
	ATMBSZ*5		; size of atom buffer
	GTJBLK			; GTJFN% block

	.PSECT CODE,PURBEG	; pure code begins here

; Top-level command parser

CMDCMD:	FLDDB. .CMKEY,,CMDTAB,<command,>,,HSTCMD
NETCMD:	FLDDB. .CMKEY,,NETTAB,<network name,>,,HSTCMD
HSTCMD:	FLDBK. .CMFLD,,,host name,,HNMMSK

; Break mask for slurping up a hostname

HNMMSK:	777777777760		; no controls
	737744001760		; "#", "-", ".", numerics
	400000000260		; upper case alphabetics, "[", "]"
	400000000760		; lower case alphabetics

; Network parse list

NETTAB:	NETTBL,,NETTBL		; number of entries
IFN FTXTND,<
	[ASCIZ/CHAOSNET/],,CHSICP
	[ASCIZ/DECNET/],,DCNICP
>;IFN FTXTND
	[ASCIZ/INTERNET/],,INTICP
IFN FTXTND,<
	[ASCIZ/PUP-ETHERNET/],,PUPICP
	[ASCIZ/TTY/],,TTYICP
>;IFN FTXTND
NETTBL==<.-NETTAB>-1

; $GTPRO format lookup list

PROTAB:
IFN FTXTND,<
	[ASCIZ/Pup/],,PUPIC1
	[ASCIZ/Chaos/],,CHSIC1
>;IFN FTXTND
	[ASCIZ/TCP/],,INTIC1
IFN FTXTND,<
	[ASCIZ/DECnet/],,DCNIC1
>;IFN FTXTND
	0			; terminate for $GTPRO

; Top-level command table

CMDTAB:	CMDTBL,,CMDTBL		; TBLUK% table
	CMD CONNECT		; connect to a remote host
	[CM%FW!CM%INV!CM%ABR
	 ASCIZ/D/],,.D		; make DDT truly invisible
	[CM%FW!CM%INV
	 ASCIZ/DDT/],,.DDT	; enter DDT
.D:!	CMD DEBUG		; enable protocol trace printout
	CMD ESCAPE		; set escape character
	[CM%FW!CM%INV!CM%ABR
	 ASCIZ/EX/],,.EX	; make EX mean EXIT
.EX:!	CMD EXIT		; return to superior
	CMD EXTENDED		; automatic entry to extended command mode
	CMD HELP		; print HLP:<name>.HLP
	CMD LINE		; enable line editor
	CMD LOG			; open typescript file
	CMD NETWORK		; various network functions
	CMD NO			; use negative options below
	CMD OPAQUE		; use local padding, etc.
	CMD PAGE		; use local page mode
	CMD PUSH		; push to inferior EXEC
	CMD QUIT		; quit out of TELNET
	CMD STATUS		; where am I
	CMD TAKE		; take command file
CMDTBL==<.-CMDTAB>-1		; number of entries

; Top-level NO command table

CNDTAB:	CNDTBL,,CNDTBL		; TBLUK% table
	CMD DEBUG		; disable protocol trace printout
	CMD EXTENDED		; no automatic entry to extended command mode
	CMD LINE		; disable line editor
	CMD LOG			; close typescript file
	CMD NETWORK		; network control commands
	CMD OPAQUE		; don't use local padding, etc.
	CMD PAGE		; don't use local page mode
CNDTBL==<.-CNDTAB>-1

; Connection open command table

CMOTAB:	CMOTBL,,CMOTBL
	CMD ABORT		; abort output signal
	CMD ATTN		; interrupt process signal
	CMD BREAK		; break signal
	CMD CLOSE		; close connection
	CMD CONTROL		; send control character
	CMD DEBUG		; enable protocol trace printout
	CMD ECHO		; remote host echos (yay!)
	CMD ESCAPE		; set escape character
	CMD EXIT		; return to superior
	CMD EXTENDED		; automatic entry to extended command mode
	CMD HELP		; print HLP:<name>.HLP
	CMD LINE		; enable line editor
	CMD LOG			; open typescript file
	CMD NO			; use negative options below
	CMD OPAQUE		; use local padding, etc.
	CMD PAGE		; use local page mode
	CMD PUSH		; push to inferior EXEC
	CMD QUIT		; quit out of TELNET
	CMD STATUS		; are you there signal
	CMD TAKE		; take command file
	CMD TRANSPARENT		; enable 8-bit I/O
CMOTBL==<.-CMOTAB>-1

; Connection open NO command table

CNOTAB:	CNOTBL,,CNOTBL
	CMD DEBUG		; disable protocol trace printout
	CMD ECHO		; local host echos (boo!)
	CMD EXTENDED		; no automatic entry to extended command mode
	CMD LINE		; enable line editor
	CMD LOG			; close typescript file
	CMD OPAQUE		; don't use local padding, etc.
	CMD PAGE		; don't use local page mode
	CMD TRANSPARENT		; disable 8-bit I/O
CNOTBL==<.-CNOTAB>-1
	SUBTTL TELNET protocol codes

TPLTAB:				; IAC xx codes
	TPC SE,^D240		; subnegotiation end
	TPC NNOP,^D241		; no-op
	TPC DM,^D242		; data mark
	TPC BRK,^D243		; break key
	TPC IP,^D244		; interrupt process
	TPC AO,^D245		; abort output
	TPC AYT,^D246		; are you there?
	TPC EC,^D247		; erase character
	TPC EL,^D248		; erase line
	TPC GA,^D249		; go ahead
	TPC SB,^D250		; subnegotiation
	TPC WILL,^D251		; sender will do
	TPC WONT,^D252		; sender won't do
	TPC DO,^D253		; receiver asked to do
	TPC DONT,^D254		; receiver must not do
	TPC IAC,^D255		; interpret as command
TPLMIN==400-<.-TPLTAB>

WDOTAB:				; various WILL/WONT/DO/DONT options
	TPC TRNBIN,^D0		; transmit binary
	TPC ECHO,^D1		; echo
	TPC RCP,^D2		; reconnect
	TPC SUPRGA,^D3		; suppress GA
	TPC NAMS,^D4		; negotiate approx. message size
	TPC STATUS,^D5		; status option
	TPC TIMMRK,^D6		; timing mark
	TPC RCTE,^D7		; remote controlled trans/echo
	TPC NAOL,^D8		; negotiate output line width
	TPC NAOP,^D9		; negotiate page size
	TPC NAOCRD,^D10		; negotiate output CR
	TPC NAOHTS,^D11		; negotiate output horizontal tab stops
	TPC NAOHTD,^D12		; negotiate output HT
	TPC NAOFFD,^D13		; negotiate output FF
	TPC NAOVTS,^D14		; negotiate output vertical tab stops
	TPC NAOVTD,^D15		; negotiate output VT
	TPC NAOLFD,^D16		; negotiate output LF
	TPC EXTASC,^D17		; Tovar's idea of extended ASCII
	TPC LOGOUT,^D18		; logout option
	TPC BM,^D19		; byte macro
	TPC DET,^D20		; data entry terminal option
	TPC SUPDUP,^D21		; SUPDUP (not TELNET) protocol
	TPC SDOTPT,^D22		; SUPDUP output
WDOMAX==.-WDOTAB-1
	EXOPL==^D255		; extended options
	SUBTTL Start of program

; Entry vector

IFNDEF VI%DEC,<			; in case MACSYM is prior to release 6
 VI%DEC==1B18
>;IFNDEC VI%DEC

EVEC:	JRST TELNET		; START address
	JRST TELREE		; REENTER address
	VI%DEC!<FLD TELWHO,VI%WHO>!<FLD TELVER,VI%MAJ>!<FLD TELMIN,VI%MIN>!<FLD TELEDT,VI%EDN>
EVECL==.-EVEC

; First initialization

TELNET:	TDZA A,A		; normal entry
TELREE:	 SETO A,		; REENTER address
	MOVEM A,REENTP		; remember whether START or REENTER
	RESET%			; flush all I/O
	MOVE P,[IOWD PDLLEN,PDL] ; init stack context
	SETZM INICBG		; clear once-only area
	MOVE A,[INICBG,,INICBG+1]
	BLT A,INICEN
	CALL CAPINI		; initialize capabilities
	MOVX A,.FHSLF		; set level/channel tables
	MOVE B,[LEVTAB,,CHNTAB]
	SIR%
	 ERCAL FATAL
	EIR%			; enable PSIs
	 ERCAL FATAL
	MOVX B,<1B<TIMCHN>!1B<.ICIFT>> ; on these channels
	AIC%
	 ERCAL FATAL
	CALL SETTIM		; start the timer
	MOVX A,.PRIIN		; get current TTY modes
	GDSTS%			; check if terminal allows parity
	IFNJE.
	  TXNE B,GD%PAR
	   SETOM PARITP		; flag we must do parity computation
	ENDIF.
	RFMOD%
	 ERCAL FATAL
	MOVEM B,TTYMOD
	RFCOC%			; get COC words
	 ERCAL FATAL
	DMOVEM B,TTYCOC
	MOVX A,.FHJOB		; get terminal interrupt word
	RTIW%
	 ERCAL FATAL
	MOVEM B,TTYTIW
	MOVX A,DEFESC		; set up escape character
	MOVEM A,ESCCHR

; Process RSCAN% buffer and TELNET.CMD

	MOVX A,.RSINI		; get RSCAN% buffer if any
	RSCAN%
	 ERCAL FATAL
	IFN. A			; RSCAN% buffer seen
	  DO.
	    PBIN%		; flush leading whitespace
	    CAIE A,.CHTAB
	     CAIN A,.CHSPC
	      LOOP.
	    CAIE A,.CHFFD
	     CAIN A,.CHLFD	; this shouldn't happen, but...
	      EXIT.
	    CAIE A,"N"		; allow NTN, etc.
	     CAIN A,"n"
	      MOVX A,"T"
	    CAIE A,"T"		; look like a TELNET command?
	     CAIN A,"t"
	      TDZA B,B		; yes, alright to scan for delimiters
	       SETO B,		; no, just flush command line
	    DO.
	      PBIN%		; flush to LF or delimiter
	      CAIE A,.CHFFD
	       CAIN A,.CHLFD
		EXIT.		; obviously no command
	      JUMPN B,TOP.
	      CAIN A,.CHTAB
	      IFSKP.
		CAIE A,.CHSPC
		 LOOP.
	      ENDIF.
	      SETOM MONCMP	; flag a command seen
	    ENDDO.
	  ENDDO.
	ENDIF.
	GJINF%			; get user number
	MOVE B,A		; convert to login directory
	SETZ A,
	RCDIR%			; get login directory number
	 ERCAL FATAL
	HRROI A,FILBUF		; create filename string
	MOVE B,C		; using login directory
	DIRST%
	 ERCAL FATAL
	HRROI B,[ASCIZ/TELNET.CMD/] ; copy in rest of file name
	SETZ C,
	SOUT%
	MOVX A,GJ%OLD!GJ%SHT	; see if TELNET.CMD exists
	HRROI B,FILBUF
	GTJFN%
	IFNJE.
	  CALL TAKE1		; it does, TAKE it
	  SKIPGE MONCMP		; saw a monitor command?
	   SOS MONCMP		; yes, fool the AOSN first time in
	ENDIF.
	SUBTTL Main program

	DO.			; here's the top-level loop
	  MOVE P,[IOWD PDLLEN,PDL] ; re-init stack in case timeout
	  SETZM CORBEG		; init data area
	  MOVE A,[CORBEG,,CORBEG+1]
	  BLT A,COREND
	  CALL PARSER		; parse and execute command
CLSRET:	  SKIPE TAKEP		; TAKE in progress?
	   LOOP.		; yes, continue as if part of same command
	  SKIPE LOGJFN		; no, log file JFN open?
	  IFSKP.
	    SETO A,		; no, flush all JFN's
	    CLOSF%
	     ERNOP		; don't die, DECnet CLOSF% can fail...
	  ENDIF.
TIMRET:	  AOSN MONCMP		; coming back from a monitor command?
	   CALL EXIT		; yes, return to EXEC
	  LOOP.
	ENDDO.
	SUBTTL Command parser

;  Get a command, do it, and return.  These are subroutines because errors
; break out by doing RET.

PARSER:	MOVEM P,REPARP		; save stack context
	MOVEI A,REPARS		; set reparse address
	MOVEM A,CMDBLK+.CMFLG
	MOVEI A,CMDBLK		; get host name
	SKIPGE MONCMP		; if invoked by monitor command, no prompt
	 SKIPA B,[-1,,[ASCIZ//]] ; monitor command, no prompt
	  HRROI B,[ASCIZ/TELNET>/] ; otherwise normal prompt
	MOVEM B,CMDBLK+.CMRTY
	PARSE <.CMINI>		; initialize parse state
	 JRST ERROR
REPARS:	MOVE P,REPARP		; restore stack context
	SETZM NOCMDP		; won, flag NO command not in progress
	SETZM GTJBLK+.GJEXT	; clear extension default
	PARSEA CMDCMD
	 JRST CMDERR		; command bad
	IFQE. CM%FNC,(C)	; (.CMKEY=0) if a command
	  HRRZ B,(B)		; get address for continued parsing
	  CALLRET (B)		; and dispatch to it
	ENDIF.
	HRROI A,ATMBUF		; must parse host name
	MOVEI C,PROTAB		; under our supported protocols
	CALL $GTPRO
	 JRST NAMERR		; doesn't match anything
	MOVEM B,HOST		; save host address
	HRRZ C,(C)		; get address for continued parsing
	CALLRET (C)		; now dispatch to it

; Parser when connection open

OPARSE:	MOVEM P,OREPAP		; save stack context
	MOVEI A,OREPAR		; set reparse address
	MOVEM A,CMDBLK+.CMFLG
	MOVEI A,CMDBLK		; get command block pointer
	HRROI B,[ASCIZ/TELNET!/] ; do prompt
	MOVEM B,CMDBLK+.CMRTY
	PARSE <.CMINI>
	 JRST ERROR
OREPAR:	MOVE P,OREPAP		; restore stack context
	PARSE <.CMCFM,CM%SDH,,RETURN to get back to talk mode,,<[
		FLDDB. .CMKEY,,CMOTAB,<command,>]>>
	 JRST CMDERR
	SETZM NOCMDP		; flag no NO command in progress
	JN CM%FNC,(C),R		; (.CMKEY=0) just return if confirm
	HRRZ B,(B)		; dispatch to it
	CALLRET (B)

; Talk mode commands

TLKCMD:	SKIPE EXTENP		; enter extended mode immediately?
	IFSKP.
	  DO.
	    MOVX A,.PRIIN	; get command from terminal
	    SKIPN ECHOP		; see if possible line editor
	     SKIPN LINEDP
	    IFSKP.
	      SOSGE TTICTR	; looks like line editor - anything there?
	    ANSKP.
	      ILDB B,TTIPTR	; snarf byte from buffer and charge in
	    ELSE.
	      BIN%		; yes, get following character
	    ENDIF.
	    ANDX B,CH%CHR	; ignoring parity
	    CAMN B,ESCCHR	; send it if doubled escape character
	     JRST RSKP
	    CAIE B,"?"
	    IFSKP.
	      CALL TTYRST	; normalize TTY in case OPAQUE
	      TMSG <
Type a single character command:
?  This message
A  Send ATTN
B  Send Break
C  Close connection
O  Abort output
P  Push to inferior EXEC
S  Status of TELNET connection
Q  Quit
T  Transparent mode toggle
X  Enter extended command mode
Typing the escape character twice sends it to the host.

Command:>
	      CALL TTYINI	; reinit TTY
	      LOOP.
	    ENDIF.
	  ENDDO.
	  CAIL B,"a"		; convert lower case to upper case
	   CAILE B,"z"
	    CAIA
	     SUBI B,"a"-"A"
	  SKIPN TPROTP		; talking TELNET protocol?
	  IFSKP.
	    CAIN B,"A"		; I hope there will never be many of these!
	     JRST ATTN1
	    CAIN B,"B"
	     JRST BREAK1
	    CAIN B,"O"
	     JRST ABORT1
	  ENDIF.
	  CAIE B,"T"
	  IFSKP.
	    MOVE A,TRBINP	; get current state of binary flags
	    IOR A,RCBINP	; we want OR of state
	    MOVEM A,NOCMDP	; if either set, NO TRANSPARENT implied
	    CALLRET TRANS1
	  ENDIF.
	  CAIE B,"C"
	  IFSKP.
	    CALL TTYRST		; reset terminal mode before message output
	    CALLRET CLOSE1
	  ENDIF.
	  CAIE B,"P"
	  IFSKP.
	    CALL TTYRST		; normalize TTY
	    CALL PUSH1		; enter inferior EXEC
	    CALLRET TTYINI	; reinit TTY
	  ENDIF.
	  CAIE B,"S"
	  IFSKP.
	    CALL TTYRST		; normalize TTY in case OPAQUE
	    CALL STATU1		; show status
	    CALLRET TTYINI	; reinit TTY and return
	  ENDIF.
	  CAIE B,"Q"
	  IFSKP.
	    CALL TTYRST		; normalize TTY
	    CALL QUIT1
	    CALLRET TTYINI	; reinit TTY and return to talk mode
	  ENDIF.
	  CAIN B,"X"		; extended command?
	ANSKP.
	  MOVX A,.CHBEL		; feep at bad command
	  PBOUT%
	  RET			; invalid command, ignore it
	ENDIF.
	CALL TTYRST		; put TTY in ordinary mode
	DO.
	  CALL OPARSE		; parse "connection open" commands
	  SKIPE TAKEP		; out of TAKE file yet?
	   LOOP.		; not yet
	ENDDO.
	SKIPN NETJFN		; connection open?
	 RET			; if not, don't TTYINI again
	CALLRET TTYINI		; reinit TTY and return
	SUBTTL Command service routines

; ABORT command

.ABORT:	SKIPN TPROTP
	 ERMSG <Not implemented with this protocol>
	NOISE <OUTPUT>
	CONFIRM
ABORT1:	TELCMD <IAC,AO,IAC,DM>
	RET

; ATTN command

.ATTN:	SKIPN TPROTP
	 ERMSG <Not implemented with this protocol>
	NOISE <KEY>
	CONFIRM
ATTN1:	TELCMD <IAC,IP,IAC,DM>
	RET

; BREAK command

.BREAK:	SKIPN TPROTP
	 ERMSG <Not implemented with this protocol>
	NOISE <KEY>
	CONFIRM
BREAK1:	TELCMD <IAC,BRK,IAC,DM>
	RET

; CLOSE command

.CLOSE:	NOISE <CONNECTION>
	CONFIRM
CLOSE1:	MOVX A,.PRIIN		; flush TTY input
	CFIBF%
	 ERCAL FATAL
	SETZM TIMOUT		; prevent any timeouts
	SKIPE A,RCVFRH		; kill receive fork
	 KFORK%
	  ERNOP			; don't die if some hacker zapped our fork
	SETZM RCVFRH
	SKIPE A,NETJFN		; close network JFN
	 CLOSF%
	  ERNOP			; don't die, DECnet can do this
	SETZM NETJFN
	TMSG <Connection closed>
	SKIPN A,LOGJFN		; is a log file open?
	IFSKP.
	  TXO A,CO%NRJ		; yes, close the file without releasing the JFN
	  CLOSF%
	   ERCAL FATAL
	ELSE.
	  SKIPE TAKEP		; don't do this if TAKE in progress
	  IFSKP.
	    SETO A,		; flush all files
	    CLOSF%
	     ERNOP		; don't die, DECnet CLOSF% can fail...
	  ENDIF.
	ENDIF.
	RET

; CONTROL command

.CONTR:	NOISE <CHARACTER>
	PARSE <.CMQST,CM%SDH,,character to send in control form in quotes,<"^">,[
	       FLDDB. .CMNUM,CM%SDH,^D8,ASCII code for control character in octal]>
	 JRST ERROR
	LOAD C,CM%FNC,(C)	; get function code of parse
	CAIE C,.CMNUM		; did user specify a number?
	IFSKP.
	  SKIPL D,B		; barf if number invalid
	   CAILE B,.CHDEL
	    ERMSG <Invalid ASCII value>
	ELSE.
	  LDB D,[POINT 7,ATMBUF,6] ; no, try for character
	  CAIL D,"a"		; see if lower case
	   CAILE D,"z"
	    CAIA
	     SUBI D,"a"-"A"	; yes, convert to upper case
	  CAIL D,"@"		; is it a meaningful to CTRL this character?
	   CAILE D,"_"
	    ERMSG <Character doesn't have a control form>
	  SUBI D,"@"-.CHNUL	; controllify
	ENDIF.
	CONFIRM
	MOVE B,D		; get character back
	CALL NETOUT		; output it
	CALLRET NETFRC		; and force the data out

; CONNECT command

.CONNE:	NOISE <TO>
	PARSEA NETCMD		; get network/host spec
	 JRST CMDERR
	IFQE. CM%FNC,(C)	; (.CMKEY=0) if a command
	  HRRZ B,(B)		; get address for continued parsing
	  CALLRET (B)		; and dispatch to it
	ENDIF.
	HRROI A,ATMBUF		; must parse host name
	MOVEI C,PROTAB		; under our supported protocols
	CALL $GTPRO
	 JRST NAMERR		; doesn't match anything
	MOVEM B,HOST		; save host address
	HRRZ C,(C)		; get address for continued parsing
	CALLRET (C)		; now dispatch to it

; DDT command

.DDT:	NOISE <MODE>
	CONFIRM
	MOVE A,[.FHSLF,,DDTADR/1000] ; see if a page of DDT exists
	RPACS%			; get page accessability
	 ERCAL FATAL
	TXNN B,PA%PEX		; does page exist?
	 TDZA A,A		; no
	  MOVE A,DDTADR		; get DDT start location
	CAMN A,[JRST DDTADR+2]	; look like a DDT?
	IFSKP.
	  MOVX A,GJ%OLD!GJ%SHT ; get a JFN on DDT
	  HRROI B,[ASCIZ/SYS:UDDT.EXE/]
	  GTJFN%
	   ERJMP ERROR		; DDT not available
	  HRLI A,.FHSLF		; load DDT in
	  GET%
	   ERCAL FATAL
	  DMOVE A,.JBSYM	; give DDT our symbol table pointers
	  DMOVEM A,@DDTADR+1
	  MOVX A,.FHSLF		; reset entry vector back to us
	  MOVE B,[EVECL,,EVEC]
	  SEVEC%
	   ERCAL FATAL
	ENDIF.
	TMSG <Type R$G to return to TELNET.  You're in >
	CALLRET DDTADR

; DEBUG command

.DEBUG:	NOISE <PROTOCOL NEGOTIATIONS>
	CONFIRM
	MOVE A,NOCMDP
	SETCAM A,DEBUGP		; flag protocol logging
	RET

; ECHO command

.ECHO:	NOISE <BY REMOTE HOST>
	CONFIRM
	SKIPN NOCMDP		; NO ECHO?
	IFSKP.
	  CALL LCLECO		; yes, enter local echo mode
	ELSE.
	  CALL RMTECO		; ECHO command, enable remote echoing
	  CALL NETFRC		; force out the command
	ENDIF.
	RET

; ESCAPE command

.ESCAP:	NOISE <CHARACTER IS>
	PARSE <.CMQST,CM%SDH,,escape character in quotes,<"">,[
	       FLDDB. .CMNUM,CM%SDH,^D8,ASCII code for character in octal]>
	 JRST ERROR
	LOAD C,CM%FNC,(C)	; get function code of parse
	CAIE C,.CMNUM		; did user specify a number?
	 LDB B,[POINT 7,ATMBUF,6] ; no, try for character
	SKIPL D,B		; barf if number invalid
	 CAILE B,.CHDEL
	  ERMSG <Invalid ASCII value>
	CONFIRM
	MOVEM D,ESCCHR
	RET

; EXIT command

.EXIT:	NOISE <FROM TELNET>
	CONFIRM
	SKIPN RCVFRH		; have a connection?
	IFSKP.
	  CALL TTYRST		; reset terminal mode before message output
	  CALL CLOSE1
	ENDIF.

; Continuable exit point from TELNET

EXIT:	HALTF%			; return to superior
	SETZM MONCMP		; flag no more monitor command since exited
;	JRST CAPINI		; (not CALLRET since CAPINI can come back here)

; Initialize capabilities (in case EXEC tries to mess us up)

CAPINI:	MOVX A,.FHSLF		; enable all my capabilities
	RPCAP%
	IOR C,B
	IFXE. C,SC%CTC		; better have ^C capability
	  EMSG <Must have CONTROL-C capability to run TELNET>
	  JRST EXIT
	ENDIF.
	EPCAP%
	 ERCAL FATAL
	RET

; EXTENDED command

.EXTEN:	NOISE <COMMAND MODE AUTOMATICALLY WHEN ESCAPE CHARACTER TYPED>
	CONFIRM
	MOVE A,NOCMDP
	SETCAM A,EXTENP		; EXTEND mode
	RET

; LINE command

.LINE:	NOISE <EDITOR FOR LOCAL ECHO CONNECTIONS>
	CONFIRM
	MOVE A,NOCMDP
	SETCAM A,LINEDP		; flag line editor
	RET

; HELP command

.HELP:	NOISE <IN USING TELNET>
	CONFIRM
	HRROI A,HLPTXT		; have inline help text so no need for a
	PSOUT%			;  separate help file
	RET

HLPTXT:	ASCIZ\
     TELNET is a subsystem to allow users to communicate with
other systems via a network.  The simplest way to run TELNET is
to enter the host name in response to TELNET's prompt.  For
example, typing "SU-SCORE.ARPA" will connect you to Score,
Stanford University Computer Science Department's DECSYSTEM-20,
assuming your system can reach Score via some network.

     While talking to the foreign host, you may type commands to
TELNET by typing the ^^ character (CTRL/^, 036 octal) followed by
a single character command character.  The most useful command
characters are:

	C	Close the connection and return to command level
	^^	Send a CTRL/^ character to the foreign host.
	?	List the CTRL/^ command options

     This is just the tip of the iceberg.  For more information
read the file [SU-SCORE]DOC:TELNET.DOC.  Bugs should be reported
to Mark Crispin at Internet address MRC@SU-SCORE.ARPA.
\

; LOG file command

.LOG:	SKIPN NOCMDP
	IFSKP.
	  NOISE <FILE>
	  CONFIRM
	  SKIPN A,LOGJFN
	  IFSKP.
	    TXO A,CO%NRJ
	    CLOSF%
	     NOP
	    MOVE A,LOGJFN
	    RLJFN%
	     ERCAL FATAL
	    SETZM LOGJFN
	  ENDIF.
	ELSE.
	  NOISE <FILE IS>
	  PARSE <.CMFIL,CM%SDH,,file to append transcript to,TELNET.LOG>
	   JRST ERROR
	  MOVEM B,TMPJFN
	  CONFIRM
	  SKIPN A,LOGJFN	; close previous file
	  IFSKP.
	    TXO A,CO%NRJ
	    CLOSF%
	     NOP
	    MOVE A,LOGJFN
	    RLJFN%
	     ERCAL FATAL
	  ENDIF.
	  MOVE A,TMPJFN		; and make new JFN the log file JFN
	  MOVEM A,LOGJFN
	  SETZM TMPJFN
	  SKIPN NETJFN		; connection open?
	  IFSKP.
	    MOVX B,<<FLD 7,OF%BSZ>!OF%APP> ; yes, open for append
	    OPENF%
	    IFJER.
	      EMSG <Log file error - >
	      SETZM LOGJFN
	      CALL ERROUT	; output last error message
	      CALLRET CRLF	; output newline and return
	    ENDIF.
	  ENDIF.
	ENDIF.
	RET

; NETWORK command

.NETWO:	PARSE <.CMKEY,,NFNTAB,,INTERNET>
	 JRST ERROR
	HRRZ B,(B)		; get address of command server
	CALLRET (B)		; and dispatch to it

NFNTAB:	NFNTBL,,NFNTBL
IFN FTXTND,<
	[ASCIZ/ETHERNET/],,.ETHER
>;IFN FTXTND
	[ASCIZ/INTERNET/],,.INTER
NFNTBL==<.-NFNTAB>-1

; NETWORK INTERNET command

.INTER:	PARSE <.CMKEY,,IFNTAB,,SERVICE>
	 JRST ERROR
	HRRZ B,(B)		; get address of command server
	CALLRET (B)		; and dispatch to it

IFNTAB:	IFNTBL,,IFNTBL
	[ASCIZ/CYCLE/],,..ICYC
	[ASCIZ/INITIALIZE/],,..IINI
	[ASCIZ/SERVICE/],,..ISER
IFNTBL==<.-IFNTAB>-1

; NETWORK ETHERNET command

.ETHER:	PARSE <.CMKEY,,EFNTAB,,PUP-SERVICE>
	 JRST ERROR
	HRRZ B,(B)		; get address of command server
	CALLRET (B)		; dispatch to subcommand server

EFNTAB:	EFNTBL,,EFNTBL
	[ASCIZ/BUG-LOGGING/],,..EBUG
	[ASCIZ/INITIALIZE/],,..EINI
	[ASCIZ/PUP-SERVICE/],,..EPUP
EFNTBL==<.-EFNTAB>-1

..IINI:	NOISE <HOST TABLE>
	CONFIRM
	MOVX A,.IPINI		; initialize host table function
	IPOPR%
	 ERJMP ERROR
	RET

..ICYC:	NOISE <DOWN THEN UP NETWORK>
	PARSE <.CMNUM,CM%SDH,^D10,network number,10>
	 JRST ERROR
	MOVE D,B		; save network number
	CONFIRM
	MOVX A,.IPSNT		; set state function
	MOVE B,D		; network number
	MOVX C,1		; request cycling the network
	IPOPR%
	 ERJMP ERROR
	RET

..ISER:	NOISE <FOR NETWORK>
	PARSE <.CMNUM,CM%SDH,^D10,network number,10>
	 JRST ERROR
	MOVE D,B		; save network number
	CONFIRM
	MOVX A,.IPSNT		; set state function
	MOVE B,D		; network number
	SETCM C,NOCMDP		; 0 = net off, -1 = net on
	IPOPR%
	 ERJMP ERROR
	RET

..EBUG:	CONFIRM
	MOVX A,.SFBUG		; frob the Pup NCP state
	JRST ..ESET

..EINI:	NOISE <PUP NETWORK DIRECTORY>
	CONFIRM
	MOVX A,.SFDIR		; initialize Pup directory
	JRST ..ESET

..EPUP:	NOISE <UP>
	CONFIRM
	MOVX A,.SFPUP		; frob the Pup NCP state
..ESET:	SETCM B,NOCMDP		; using complement of NO state
	SMON%
	 ERJMP ERROR
	RET

; NO set of commands

.NO:	SKIPE RCVFRH		; have a connection?
	IFSKP.
	  PARSE <.CMKEY,,CNDTAB,<command,>>
	   JRST CMDERR
	ELSE.
	  PARSE <.CMKEY,,CNOTAB,<command,>>
	   JRST CMDERR
	ENDIF.
	SETOM NOCMDP
	HRRZ B,(B)
	CALLRET (B)

; OPAQUE and PAGE commands

.OPAQU:	SKIPA D,[SETOM OPAQUP]
.PAGE:	 MOVE D,[SETOM PAGEP]
	NOISE <MODE>
	CONFIRM
	SKIPE NOCMDP		; NO [OPAQUE | PAGE] command?
	 XORX D,<<SETOM>^!<SETZM>> ; yes, change SETOM to SETZM
	XCT D
	RET

; PUSH command

.PUSH:	NOISE <COMMAND LEVEL>
	CONFIRM
PUSH1:	STKVAR <EXCJFN>
	SETO A,			; get subsystem/program names into T/TT
	MOVE B,[-2,,T]
	MOVX C,.JISNM		; note .JIPNM = .JISNM + 1
	GETJI%
	 ERCAL FATAL
	MOVX A,.FHSLF		; disable PSIs
	DIR%
	 ERCAL FATAL
	SKIPN A,EXCFRH		; have an EXEC already?
	IFSKP.
	  MOVE A,EXCFRH		; yes, continue the extant fork
	  TXO A,SF%CON
	  SFORK%
	   ERNOP		; fork vanished or something
	ELSE.
	  MOVX A,GJ%OLD!GJ%SHT ; try to get an EXEC
	  HRROI B,[ASCIZ/SYSTEM:EXEC.EXE/]
	  GTJFN%
	   ERJMP ERROR
	  MOVEM A,EXCJFN	; save EXEC's JFN
	  MOVX A,CR%CAP		; make an inferior fork
	  CFORK%
	  IFJER.
	    MOVE A,EXCJFN	; get JFN back
	    RLJFN%		; flush it
	     NOP
	    JRST ERROR		; report it
	  ENDIF.
	  MOVEM A,EXCFRH	; remember this EXEC's fork handle
	  MOVE A,EXCJFN		; save fork handle, get JFN
	  HRL A,EXCFRH		; stuff the fork
	  GET%
	   ERCAL FATAL
	  MOVX A,.FHSLF		; get my current capabilities
	  RPCAP%
	  MOVE A,EXCFRH		; get back fork handle of inferior
	  TXZ B,SC%LOG		; don't let inferior log out
	  SETZ C,		; and don't enable any capabilities
	  EPCAP%
	   ERCAL FATAL
	  SETZ B,		; run it and wait for it to stop
	  SFRKV%
	   ERCAL FATAL
	ENDIF.
	WFORK%
	 ERCAL FATAL
	MOVX A,.FHSLF		; re-enable PSIs
	EIR%
	 ERCAL FATAL
	DMOVE A,T		; restore old names
	SETSN%
	 ERCAL FATAL
	RET

; QUIT command

.QUIT:	NOISE <OUT OF TELNET>
	CONFIRM
QUIT1:	SKIPN A,RCVFRH		; if connection is not open
	 JRST EXIT		; this is easy
	FFORK%			; freeze net input fork so it doesn't die
	 ERCAL FATAL		;  if you enter DDT or something
	CALL EXIT		; return to EXEC
	MOVE A,RCVFRH		; resume net input fork
	RFORK%
	 ERCAL FATAL
	RET

; STATUS command

STABSZ==^D20			; size of status buffer

.STATU:	NOISE <OF TELNET CONNECTION>
	CONFIRM
STATU1:	STKVAR <<STABUF,STABSZ>>
	HRROI A,STABUF		; get our local name
	CALL $GTLCL
	IFSKP.
	  HRROI A,STABUF	; output it if success (shouldn't fail)
	  PSOUT%
	ENDIF.
	TMSG < TELNET >
	MOVX A,.PRIOU		; set up for primary output
	LOAD B,VI%MAJ,EVEC+2	; get major version
	TMNN VI%DEC,EVEC+2	; decimal versions?
	 SKIPA C,[^D8]		; no, octal for typeout
	  MOVX C,^D10		; yes, output in decimal
	NOUT%
	 ERCAL FATAL
	LOAD B,VI%MIN,EVEC+2	; get minor version
	IFN. B			; ignore if no minor version
	  MOVEI A,"."		; output delimiting dot
	  PBOUT%
	  MOVX A,.PRIOU		; now output the minor version
	  NOUT%
	   ERCAL FATAL
	ENDIF.
	LOAD B,<VI%EDN&^-VI%DEC>,EVEC+2	; get edit version
	IFN. B			; ignore if no edit version
	  MOVEI A,"("		; edit delimiter
	  PBOUT%
	  MOVX A,.PRIOU		; now output the edit version
	  NOUT%
	   ERCAL FATAL
	  MOVEI A,")"		; edit close delimiter
	  PBOUT%
	ENDIF.
	LOAD B,VI%WHO,EVEC+2	; get who last edited
	IFN. B			; ignore if last edited at DEC
	  MOVEI A,"-"		; output delimiting hyphen
	  PBOUT%
	  MOVX A,.PRIOU		; now output the who version
	  NOUT%
	   ERCAL FATAL
	ENDIF.
	TMSG <
This is >
	HRROI A,.SYSVER		; length of SYSVER table
	GETAB%
	 ERCAL FATAL
	HRLZ B,A		; get up AOBJN pointer for name
	ADDI A,STABSZ		; make sure there's enough space!
	SKIPGE A		; a-okay
	 MOVSI B,-STABSZ	; otherwise use buffer size as a maximum
	MOVEI C,STABUF		; resolve address
	DO.
	  MOVX A,.SYSVER	; table number
	  HRLI A,(B)		; index into table
	  GETAB%
	   ERCAL FATAL
	  MOVEM A,(C)		; store in buffer
	  ADDI C,1		; index to next word
	  AOBJN B,TOP.		; get next word
	ENDDO.
	HRROI A,STABUF
	PSOUT%
	CALL CRLF		; newline
	SKIPN NETJFN		; connection open?
	 RET			; no, all done
	TMSG <Connected to >
	SKIPN TTYP		; TTY port?
	IFSKP.
	  TMSG <TTY>
	  MOVX A,.PRIOU		; output TTY number
	  MOVE B,HOST
	  MOVX C,^D8
	  NOUT%
	   NOP
	ELSE.
	  TMSG <host >
	  HRROI A,STABUF	; get host string
	  MOVE B,HOST		; from host number
	  SKIPN DCNP		; DECnet?
	  IFSKP.
	    CALL $DECNS		; translate number to string
	     NOP		; can't fail
	    HRROI B,[ASCIZ/, object type /]
	    SETZ C,
	    SOUT%
	    MOVE B,PORT		; output the object type
	    MOVX C,^D10		; in decimal
	    NOUT%
	     ERCAL FATAL
	  ENDIF.
	  SKIPN CHAOSP		; Chaosnet?
	  IFSKP.
	    CALL $CHSNS		; translate number to string
	     NOP		; can't fail
	    HRROI B,[ASCIZ/, contact name /]
	    SETZ C,
	    SOUT%
	    MOVE B,NETJFN	; get contact name from JFN
	    MOVX C,<FLD .JSAOF,JS%TYP>
	    JFNS%
	     ERCAL FATAL
	  ENDIF.
	  SKIPN INTP		; Internet?
	  IFSKP.
	    CALL $GTHNS		; translate number to string
	     NOP		; can't fail
	    HRROI B,[ASCIZ/, port /]
	    SETZ C,
	    SOUT%
	    LDB B,[POINT 8,PORT,27] ; high port byte
	    MOVX C,^D10		; in decimal
	    NOUT%
	     ERCAL FATAL
	    MOVX B,"."		; dotted delimiter
	    IDPB B,A
	    LDB B,[POINT 8,PORT,35] ; low port byte
	    MOVX C,^D10		; in decimal
	    NOUT%
	     ERCAL FATAL
	  ENDIF.
	  SKIPN PUPP		; Pup Ethernet?
	  IFSKP.
	    CALL $PUPNS		; translate number to string
	     NOP		; can't fail
	    HRROI B,[ASCIZ/, socket /]
	    SETZ C,
	    SOUT%
	    PUSH P,A		; save string over this
	    HRROI A,ATMBUF	; get socket name from JFN
	    MOVE B,NETJFN
	    MOVX C,<FLD .JSAOF,JS%TYP>
	    JFNS%
	     ERCAL FATAL
	    POP P,A		; restore destination string pointer
	    MOVE B,[POINT 7,ATMBUF] ; now search for "+"
	    DO.
	      ILDB C,B		; get byte from string
	      CAIE C,"+"	; saw the "+" yet?
	       LOOP.
	    ENDDO.
	    SETZ C,		; now copy remainder of string
	    SOUT%
	  ENDIF.
	  HRROI A,STABUF	; output the string
	  PSOUT%
	ENDIF.
	REPORT ECHOP,<Local host is echoing>,<Remote host is echoing>
	REPORT LINEDP,<Line editor disabled>,<Line editor enabled>
	REPORT RCBINP,<Host is not sending binary>,<Host is sending binary>
	REPORT TRBINP,<Transparent mode disabled>,<Transparent mode enabled>
	REPORT OPAQUP,<Opaque mode disabled>,<Opaque mode enabled>
	REPORT PAGEP,<Page mode disabled>,<Page mode enabled>
	REPORT LOGJFN,<No log file>,<Log file open>
	REPORT TAKEP,<No TAKE file>,<TAKE file in progress>
	REPORT EXTENP,<Simple talk command mode>,<Extended talk command mode>
	SKIPN TPROTP		; don't do this if not TELNET protocol
	 JRST CRLF
	TMSG <
Using Internet TELNET protocol>
	REPORT SUPGAP,<Host wants GA's>,<GA's are suppressed>
	TMSG <
Remote host status reply:
>
	TELCMD <IAC,AYT>
	RET

	ENDSV.

; TAKE command

.TAKE:	SKIPE TAKEP		; TAKE in progress?
	 ERMSG <TAKE command in progress>
	NOISE <COMMANDS FROM FILE>
	HRROI [ASCIZ/CMD/]	; default extension is .CMD
	MOVEM GTJBLK+.GJEXT
	PARSE <.CMFIL>		; now get input file
	 JRST ERROR
	MOVEM B,TMPJFN		; save JFN over CONFIRM
	SETZM GTJBLK+.GJEXT	; clear default extension
	CONFIRM
	MOVE A,TMPJFN		; now open the file
TAKE1:	MOVX B,<<FLD 7,OF%BSZ>!OF%RD>
	OPENF%
	 ERJMP ERROR
	SETZM TMPJFN
	HRLM A,CMDBLK+.CMIOJ	; input JFN in left half
	MOVX A,.NULIO		; no output
	HRRM A,CMDBLK+.CMIOJ	; set as new I/O JFNs
	SETOM TAKEP		; flag TAKE in progress
	RET

UNTAKE:	SETZM TAKEP		; flag no more TAKE file
	HLRZ A,CMDBLK+.CMIOJ	; get TAKE file JFN back
	CLOSF%			; close it
	 ERCAL FATAL		; yeegs
	MOVE A,[.PRIIN,,.PRIOU]	; restore command input from primaries
	MOVEM A,CMDBLK+.CMIOJ
	RET

; TRANSPARENT command

.TRANS:	NOISE <MODE>
	CONFIRM
TRANS1:	MOVE A,NOCMDP
	SETCAM A,TRBINP		; set binary states accordingly
	SETCAM A,RCBINP

;  Strictly speaking, this violates TELNET protocol because it can send a
; protocol option when the connection is already in the desired state.  The
; code is simpler and easier to read this way, though, and it provides a way
; for the user to set the state at the host if it's set the wrong way there.

	SKIPN TPROTP		; no need to do protocol if not a protocol net
	IFSKP.
	  SKIPE TRBINP
	  IFSKP.
	    TELCMD <IAC,WONT,TRNBIN>
	  ELSE.
	    TELCMD <IAC,WILL,TRNBIN>
	  ENDIF.
	  SKIPE RCBINP
	  IFSKP.
	     TELCMD <IAC,DONT,TRNBIN>
	  ELSE.
	    TELCMD <IAC,DO,TRNBIN>
	  ENDIF.
	ENDIF.
	RET
	SUBTTL Internet ICP setup routine

INTICP:	NOISE <HOST>		; prompt for host
	PARSEA [FLDBK. .CMFLD,,,Internet host name,,HNMMSK]
	 JRST CMDERR
	HRROI A,ATMBUF		; got host name, now parse it
	CALL $GTHSN		; get its address
	 JRST NAMERR
	MOVEM B,HOST		; save host address
INTIC1:	MOVEI A,CMDBLK		; restore CSB
	NOISE <ON PORT>
	PARSE <.CMKEY,,IPRTAB,<port name,>,TELNET,[FLDDB. .CMNUM,CM%SDH,^D10,decimal port number]>
	 JRST ERROR
	LOAD C,CM%FNC,(C)	; get function code of parse
	CAIE C,.CMKEY		; if keyword
	IFSKP.
	  HRRZ B,(B)		; get port datum
	  MOVEM B,PORT		; save port number
	ELSE.
	  SKIPL B		; validate port number
	   CAILE B,377
	    ERMSG <Invalid port number>
	  MOVEM B,PORT		; save high order byte in a safe place
	  PARSE <.CMTOK,CM%SDH,<-1,,[ASCIZ/./]>,<"." to delimit high and low bytes of port number>>
	ANSKP.
	  SKIPE PORT		; if first byte zero, default second to 23
	  IFSKP.
	    PARSE <.CMNUM,CM%SDH,^D10,low order byte of port number,23>
	     JRST ERROR
	  ELSE.
	    PARSE <.CMNUM,CM%SDH,^D10,low order byte of port number>
	     JRST ERROR
	  ENDIF.
	  SKIPL B		; validate port number
	   CAILE B,377
	    ERMSG <Invalid port number>
	  EXCH B,PORT		; swap first and second inputs
	  LSH B,^D8		; shift first input to high order byte
	  IORM B,PORT		; merge and store port
	ENDIF.
	DMOVE A,[POINT 7,FILBUF+1
		 ASCII/TCP:./]
	MOVEM B,FILBUF
	MOVE B,HOST		; destination host number
	MOVX C,^D8		; in octal
	NOUT%			; output to file string
	 ERCAL FATAL
	MOVX B,"-"		; port delimiter (do it this way in case some
	IDPB B,A		;  cretin ever tries to use port 0)
	MOVE B,PORT		; get port
	CAIN B,TPRPRT		; TELNET protocol port?
	 SETOM TPROTP		; make sure we know TELNET protocol
	MOVX C,^D10		; ports are decimal
	NOUT%			; output to file string
	 ERCAL FATAL
	HRROI B,[ASCIZ/;CONNECTION:ACTIVE;PERSIST:30/] ; quit after 30 seconds
	SETZ C,
	SOUT%
	MOVEI A,CMDBLK		; restore CSB
	CONFIRM
	SETOM INTP
	MOVX C,<FLD .TCMWH,OF%MOD> ; buffered mode, wait for connection
	CALLRET ICP		; now go do ICP

; Table of well-known Internet ports

IPRTAB:	IPRTBL,,IPRTBL
	[ASCIZ/CSNET-MAILBOX/],,^D103
	[ASCIZ/DAYTIME/],,^D13
	[ASCIZ/DISCARD/],,^D9
	[ASCIZ/ECHO/],,^D7
	[ASCIZ/FINGER/],,^D79
	[ASCIZ/FTP/],,^D21
	[ASCIZ/HOSTS2-NAME/],,^D81
	[ASCIZ/METAGRAM/],,^D99
	[ASCIZ/NAME/],,^D42
	[ASCIZ/NETSTAT/],,^D15
	[ASCIZ/NIC-NAME/],,^D101
	[ASCIZ/OLD-FTP/],,^D3
	[ASCIZ/OLD-TELNET/],,^D1
	[ASCIZ/SMTP/],,^D25
	[ASCIZ/SYSTAT/],,^D11
	[ASCIZ/TELNET/],,TPRPRT	; TELNET (our default)
	[ASCIZ/TEXT/],,^D17
	[ASCIZ/TN-TUNNEL/],,^D89
	[ASCIZ/TTYTST/],,^D19
	[ASCIZ/WHOIS/],,^D43
IPRTBL==<.-IPRTAB>-1
	SUBTTL Chaosnet ICP setup routine

CHSICP:	NOISE <HOST>		; prompt for host
	PARSEA [FLDBK. .CMFLD,,,Chaosnet host name,,HNMMSK]
	 JRST CMDERR
	HRROI A,ATMBUF		; got host name, now parse it
	CALL $CHSSN
	 JRST NAMERR
	MOVEM B,HOST		; save host address
CHSIC1:	MOVEI A,CMDBLK		; restore CSB
	NOISE <AT CONTACT NAME>
	PARSE <.CMFLD,CM%SDH,,contact name,TELNET>
	 JRST ERROR
	DMOVE A,[POINT 7,FILBUF,27
		 ASCII/CHA:/]	; build CHA: filename
	MOVEM B,FILBUF
	MOVE B,HOST		; first put in host number
	MOVX C,^D8
	NOUT%
	 ERCAL FATAL
	MOVX B,"."
	IDPB B,A
	MOVE B,[POINT 7,ATMBUF]	; add contact name to string
	DO.
	  ILDB C,B		; string copy including null
	  IDPB C,A		; save in filename string
	  JUMPN C,TOP.
	ENDDO.
	MOVEI A,CMDBLK		; restore CSB
	CONFIRM
	SETOM ECHOP		; normal state is remote echo
	SETOM CHAOSP		; flag Chaosnet connection
	SETZ C,
	CALLRET ICP
	SUBTTL DECnet ICP setup routine

DCNICP:	NOISE <HOST>		; prompt for host
	PARSEA [FLDBK. .CMFLD,,,DECnet host name,,HNMMSK]
	 JRST CMDERR
	HRROI A,ATMBUF		; got host name, now parse it
	CALL $DECSN		; get its address
	 JRST NAMERR
	MOVEM B,HOST		; save host address
DCNIC1:	MOVEI A,CMDBLK		; restore CSB
	NOISE <AT OBJECT TYPE>
	PARSE <.CMNUM,CM%SDH,^D10,decimal object type number,23>
	 JRST ERROR
	SKIPL B			; validate object type
	 CAILE B,377
	  ERMSG <Invalid object type>
	MOVEM B,PORT
	DMOVE A,[POINT 7,FILBUF,27 ; build DCN: filename
		 ASCII/DCN:/]
	MOVEM B,FILBUF
	MOVE B,HOST		; now insert host name
	DO.
	  SETZ C,		; clear out crud from before
	  ROTC B,6		; get a byte of the name
	  IFN. C		; if non-null
	    ADDI C,"A"-'A'	; convert from SIXBIT to ASCII
	    IDPB C,A		; insert in string
	    LOOP.		; and continue
	  ENDIF.
	ENDDO.
	MOVN B,PORT		; delimited by a hyphen
	MOVX C,^D10
	NOUT%
	 ERCAL FATAL
	MOVEI A,CMDBLK
	CONFIRM
	SETOM ECHOP		; always echo on DECnet
	SETOM RCBINP		; remote side does parity stuff
	SETOM DCNP		; flag DECnet connection
	SETZ C,
	CALLRET ICP
	SUBTTL Pup Ethernet ICP setup routine

PUPICP:	NOISE <HOST>		; prompt for host
	PARSEA [FLDBK. .CMFLD,,,Ethernet host name,,HNMMSK]
	 JRST CMDERR
	HRROI A,ATMBUF		; got host name, now parse it
	CALL $PUPSN		; get its address
	 JRST NAMERR
	MOVEM B,HOST		; save host address
PUPIC1:	MOVEI A,CMDBLK		; restore CSB
	NOISE <SOCKET>
	PARSE <.CMFLD,CM%SDH,,socket name or number,Telnet>
	 JRST ERROR
	DMOVE A,[ASCII/PUP:0!J./] ; job-relative socket
	DMOVEM A,FILBUF
	MOVE A,[POINT 7,FILBUF+1,27]
	HLRZ B,HOST		; output network number
	MOVX C,^D8
	NOUT%
	 ERCAL FATAL
	MOVX B,.CHCNV
	IDPB B,A
	MOVX B,"#"		; network/host delimiter
	IDPB B,A
	HRRZ B,HOST		; output host number
	NOUT%
	 ERCAL FATAL
	SETZ C,			; null-terminated strings
	HRROI B,[ASCIZ/#+/]	; host/socket delimiter
	SOUT%
	HRROI B,ATMBUF		; now socket
	SOUT%
	MOVEI A,CMDBLK		; restore CSB
	CONFIRM
	SETOM ECHOP		; always remote echo with Pup TELNET
	SETOM PUPP		; flag Pup Ethernet connection
	MOVX C,<<^D8>B17>	; 30 second timeout
	CALLRET ICP
	SUBTTL TTY ICP setup routine

TTYICP:	NOISE <LINE NUMBER>	; prompt for host
	PARSE <.CMNUM,CM%SDH,^D8,octal TTY number>
	 JRST CMDERR
	MOVEM B,HOST		; set as "host number"
	DMOVE A,[POINT 7,FILBUF,20
		 ASCII/TTY/]	; build TTY: filename
	MOVEM B,FILBUF
	MOVE B,HOST		; TTY number
	MOVX C,^D8
	NOUT%
	 ERCAL FATAL
	MOVX B,":"
	IDPB B,A
	SETZ B,
	IDPB B,A
	MOVEI A,CMDBLK
	CONFIRM
	SETOM ECHOP		; always echo on TTYs
	SETOM RCBINP		; remote side does parity stuff
	SETOM TRBINP		; pass on binary from keyboard
	SETOM TTYP
	SETZ C,
	CALLRET ICP
	SUBTTL ICP completion routine

; Do ICP, called with OPENF% mode bits in C

ICP:	TMSG < Trying... >
	MOVX A,GJ%SHT		; short form, restricted
	HRROI B,FILBUF		; pointer to file string we made
	GTJFN%			; make a JFN on it
	 ERJMP ERROUT		; failed?
	MOVEM A,NETJFN		; save JFN
	MOVX B,<<FLD ^D8,OF%BSZ>!OF%RD!OF%WR> ; 8 bit read/write
	IOR B,C			; with network-dependent other bits
	OPENF%			; open it
	IFJER.
	  CAIE A,OPNX7		; some other job has the TTY line?
	  IFSKP.
	    TMSG <In use by job >
	    MOVE A,NETJFN	; get back JFN
	    DVCHR%		; find out who has it
	     ERCAL FATAL
	    HLRE B,C		; get job number in B
	    MOVX A,.PRIOU	; output the job number in decimal
	    MOVX C,^D10
	    NOUT%
	     ERCAL FATAL
	    RET
	  ENDIF.
	  CAIE A,OPNX10		; better than "Entire file structure full"
	  IFSKP.
	    TMSG <Insufficient system resources>
	    RET
	  ENDIF.
	  CAIE A,OPNX19		; better than "IMP is not up"
	  IFSKP.
	    TMSG <Network service is down>
	    RET
	  ENDIF.
	  CALL ERROUT		; otherwise use last error's string
	  CAIN A,OPNX21		; refused?
	   SKIPN PUPP		; yes, is it Pup?
	  IFSKP.
	    MOVE A,NETJFN	; yes, get abort data
	    MOVX B,.MOPRA
	    HRROI D,FILBUF	; get its string into FILBUF
	    MTOPR%
	  ..TAGF (ERJMP,)	; I sure wish ANNJE. existed!
	    TMSG <: >
	    HRROI A,FILBUF	; it won, output the code
	    PSOUT%
	  ENDIF.
	  SKIPN INTP		; Internet?
	   RET			; no, all done
	  MOVX A,.GTHHN		; find out what's going down with this host
	  MOVE C,HOST
	  GTHST%
	   ERJMP R		; ignore error
	  JXE D,HS%VAL,R	; valid host status?
	  JXN D,HS%UP,R		; yes, did we get an 1822 host dead message?
	  LOAD A,HS%RSN,D	; get host down reason code
	  HRRO A,[[ASCIZ/, network trouble/]
		  [ASCIZ/, system down/]
		  [ASCIZ/, foreign TCP down/]
		  [ASCIZ/, doesn't exist/]
		  [ASCIZ/, foreign IMP initialization/]
		  [ASCIZ/, scheduled PM/]
		  [ASCIZ/, hardware work/]
		  [ASCIZ/, software work/]
		  [ASCIZ/, emergency restart/]
		  [ASCIZ/, power failure/]
		  [ASCIZ/, software breakpoint/]
		  [ASCIZ/, hardware error/]
		  [ASCIZ/, scheduled down/]
		  [ASCIZ/, down code #13/]
		  [ASCIZ/, down code #14/]
		  [ASCIZ/, coming up now/]](A)
	  PSOUT%
	  LOAD A,HS%DAY!HS%HR!HS%MIN,D ; get expected up time
	  JUMPE A,R		; 0 means unknown
	  CAIE A,7777		; -1 means a long while
	  IFSKP.
	    TMSG <, up over a week from now>
	    RET
	  ENDIF.
	  CAIN A,7776		; -2 means unspecified
	   RET
	  STKVAR <SAVTIM>
	  MOVEM D,SAVTIM
	  SETO B,		; time now
	  SETZ D,		; use local time zone, etc.
	  ODCNV%		; get time zone flags in D
	  EXCH D,SAVTIM		; get back time, put flags on stack
	  LOAD B,HS%HR,D	; hours
	  LOAD C,HS%MIN,D	; 5-minute interval
	  CAIGE B,^D24		; ensure in bounds
	   CAIL C,^D12
	    RET			; no, forget it
	  IMULI C,5		; minutes in C
	  MOVE T,SAVTIM
	  LOAD D,HS%DAY,D	; day of week
	  LOAD A,IC%TMZ,T	; get timezone
	  TXNE A,40		; if east of the line (unlikely)
	   IOR A,[-1,,777700]	; extend the sign bit
	  SUB B,A		; now account for timezone in hours
	  TXNE T,IC%ADS		; if daylight losing time
	   ADDI B,1		; we go an hour east
	  IFL. B		; same day?
	    ADDI B,^D24		; no, make hours positive
	    SOSGE D		; and day the previous day
	     MOVX D,6		; underflow, back into Sunday
	  ENDIF.
	  HRRO A,[[ASCIZ/, up on Monday at /]
		  [ASCIZ/, up on Tuesday at /]
		  [ASCIZ/, up on Wednesday at /]
		  [ASCIZ/, up on Thursday at /]
		  [ASCIZ/, up on Friday at /]
		  [ASCIZ/, up on Saturday at /]
		  [ASCIZ/, up on Sunday at /]
		  [ASCIZ/, up on April Fool's Day at /]](D) ; shouldn't happen
	  PSOUT%
	  CAIGE B,^D11		; afternoon?
	   TDZA D,D		; no, AM
	    MOVX D,1		; yes, set PM flag
	  SKIPN B		; midnight?
	   MOVX B,^D12		; yes, convert hour to 12
	  IFE. C		; if minutes non-zero, not noon or midnight
	    CAIN B,^D12		; noon or midnight?
	     ADDI D,2		; yes, set noon/midnight flag
	  ENDIF.
	  MOVEM C,SAVTIM	; save minutes
	  MOVX A,.PRIOU
	  CAILE B,^D12		; afternoon?
	   SUBI B,^D12		; yes, fix for 12 hour clock
	  MOVX C,^D10
	  NOUT%
	   ERCAL FATAL
	  MOVX B,":"
	  BOUT%
	  MOVE B,SAVTIM
	  TXO C,<NO%LFL!NO%ZRO!<FLD 2,NO%COL>> ; leading filler, zeros
	  NOUT%
	   ERCAL FATAL
	  HRRO A,[[ASCIZ/ AM /]
		  [ASCIZ/ PM /]
		  [ASCIZ/ midnight /]
		  [ASCIZ/ noon /]](D)
	  PSOUT%
	  LOAD A,IC%TMZ,T	; get timezone
	  IFE. A
	    TXNE T,IC%ADS	; Greenwich Daylight time(!)?
	     SKIPA A,[-1,,[ASCIZ/GDT/]]
	      HRROI A,[ASCIZ/GMT/]
	    PSOUT%
	  ELSE.
	    CAIG A,^D11		; USA or Canada timezone?
	     CAIGE A,^D4
	      RET
	    MOVE B,[ASCII/AST/	; Atlantic
		    ASCII/EST/	; Eastern
		    ASCII/CST/	; Central
		    ASCII/MST/	; Mountain
		    ASCII/PST/	; Pacific
		    ASCII/YST/	; Yukon
		    ASCII/HST/	; Alaska-Hawaii
		    ASCII/BST/]-4(A) ; Bering
	    TXNE T,IC%ADS	; if daylight losing time
	     XORX B,<<ASCII/ S/>^!<ASCII/ D/>>
	    HRROI A,B
	    PSOUT%
	  ENDIF.
	  RET
	ENDIF.
	SKIPN DCNP		; special post-OPENF% actions for DECnet
	IFSKP.
	  MOVE B,[POINT 8,NTIBFR] ; read status message
	  MOVNI C,200		; known size of status message
	  SINR%
	   ERJMP DCNERR
	  LDB A,[POINT 8,NTIBFR,7] ; check first byte, should be a 1
	  CAIN A,1		; is it?
	  IFSKP.
	    MOVE B,[POINT 8,NTIBFR] ; doesn't look like a status message
	    ADDI C,200		; set up as text then
	    DMOVEM B,NTIPTR
	  ELSE.
	    LDB A,[POINT 8,NTIBFR+1,23] ; get host type
	    CAIE A,^D9		; TOPS-10?
	     CAIN A,^D8		; TOPS-20?
	  ANSKP.
	    TMSG <Can't connect to non-TOPS-10/20 host>
	    RET
	  ENDIF.
	ENDIF.
	SKIPN TTYP		; special post-OPENF% actions for TTY
	IFSKP.
	  MOVX B,.CHCRT		; send a CR down the line to get things going
	  BOUT%
	   ERCAL FATAL
	  RFMOD%		; get current mode for this line
	   ERCAL FATAL
	  TXZ B,<TT%ECO!TT%DAM!TT%PGM> ; no echo, binary mode, no paging
	  SFMOD%
	   ERCAL FATAL
	  STPAR%
	   ERCAL FATAL
	ENDIF.
	TMSG <Open
>
	CALL TTYINI		; init TTY modes for talk mode
	SKIPN A,LOGJFN		; log file?
	IFSKP.
	  MOVX B,<<FLD 7,OF%BSZ>!OF%APP> ; yes, open for append
	  OPENF%
	  IFJER.
	    EMSG <Log file error - >
	    SETZM LOGJFN	; flag no more log file
	    CALL ERROUT		; output last error message
	    CALLRET CRLF	; output newline and return
	  ENDIF.
	ENDIF.
	DMOVE A,[POINT 8,NTOBFR
		 4*NTOBSZ]
	DMOVEM A,NTOPTR		; init NET output buffer pointer/counter
	DMOVE A,[POINT 8,TTOBFR
		 4*TTOBSZ]
	DMOVEM A,TTOPTR		; init TTY output buffer pointer/counter
	SKIPN TPROTP		; send initial commands if TELNET protocol
	IFSKP.
	  SETOM SUPGAP		; will always suppress GA's
	  TELCM1 <IAC,DO,SUPRGA>
	  SKIPN LINEDP		; is line editor enabled?
	   CALL RMTECO		; no, want remote echo
	ENDIF.
	MOVX A,<CR%MAP!CR%CAP!CR%ST!RCVFRK>
	CFORK%			; create receive fork
	 ERCAL FATAL
	MOVEM A,RCVFRH		; save the handle
	CALL NETFRC		; force initial negotiations now
	SUBTTL Keyboard input loop

	DO.
	  SKIPN RCVFRH		; possibly a command closed the connection
	   RET			; quit if receive fork went away
	  SOSGE TTICTR		; any characters left in the buffer?
	  IFSKP.
	    ILDB B,TTIPTR	; yes, read a byte
	    CAIE B,.CHCRT	; did we just get a CR?
	    IFSKP.
	      SOSGE TTICTR	; yes, there is probably an LF to eat!
	    ANSKP.
	      ILDB A,TTIPTR	; get the LF
	      CAIN A,.CHLFD	; well??
	    ANSKP.
	      AOS TTICTR	; this shouldn't happen, but do the right thing
	      SETO A,
	      ADJBP A,TTIPTR
	      MOVEM A,TTIPTR
	    ENDIF.
	  ELSE.
	    SKIPN ECHOP		; local echoing?
	     SKIPN LINEDP	; yes, using line editor?
	    IFSKP.
	      DMOVE A,[POINT 7,TTIBFR ; set up pointer to TTY input buffer
		       RD%BEL!<5*TTIBSZ>] ; return on EOL, # of characters
	      MOVEM A,TTIPTR
	      SETZ C,		; no ^R buffer
	      RDTTY%		; get the line
	       ERCAL FATAL
	      MOVX A,5*TTIBSZ	; compute number of characters read
	      SUBI A,(B)
	      MOVEM A,TTICTR	; set up counter
	      LOOP.
	    ELSE.
	      MOVX A,.PRIIN	; no line editor, get a byte from user
	      BIN%
	    ENDIF.
	  ENDIF.
	  LOAD C,CH%CHR,B	; get a copy of the character without parity
	  SKIPE OPAQUP		; opaque mode?
	   CAIE C,.CHCRT	; yes, character a CR?
	  IFSKP.
	    PBIN%		; yes, eat the LF
	    ANDX A,CH%CHR	; ignore parity
	    CAIN A,.CHLFD	; saw LF?
	  ANSKP.
	    MOVX A,.PRIIN	; shouldn't happen, but...
	    BKJFN%
	     ERCAL FATAL
	  ENDIF.
	  CAME C,ESCCHR		; intercept character?
	  IFSKP.
	    CALL TLKCMD		; yes, process command
	    LOOP.		; no command to do
	  ENDIF.
	  DO.
	    SKIPN TRBINP	; toss out parity if not binary
	     TXZ B,CH%PAR
	    SKIPE ECHOP		; see if have to echo
	    IFSKP.
	      MOVX A,.PRIOU	; echo the byte
	      SKIPN LINEDP	; if line editor, already did it to terminal
	       BOUT%
	      SKIPE A,LOGJFN	; and put it in the log file too
	       BOUT%
	    ENDIF.
	    CALL NETOUT		; output it
	    SKIPN TPROTP	; new protocol?
	    IFSKP.
	      CAIN B,IAC	; yes, double it if an IAC
	       CALL NETOUT
	    ENDIF.
	    SKIPN INTP		; Internet?
	     SKIPE CHAOSP	; no, Chaosnet?
	    IFNSK.
	      SKIPN TRBINP	; yes, in binary mode?
	       CAIE B,.CHCRT	; no, saw a CR?
	    ANSKP.
	      MOVX B,.CHLFD	; yes, must follow with LF, fake entered
	      LOOP.		;  from terminal
	    ENDIF.
	  ENDDO.
	  MOVX A,.PRIIN		; any more bytes in TTI buffer?
	  SKIPG TTICTR		; or any line editor stuff?
	   SIBE%
	    LOOP.		; yes, get them before doing network output
	  CALL NETFRC		; otherwise force the buffer out
	  LOOP.
	ENDDO.
	SUBTTL Interrupt stuff

; PSI blocks

LEVTAB:	LEV1PC			; priority level table
	LEV2PC
	LEV3PC

CHNTAB:	PHASE 0			; channel table
INSCHN:!2,,INSINT		; INS channel
TIMCHN:!1,,TIMINT		; timer channel
	REPEAT .ICIFT-.,<0>
.ICIFT:!1,,CLSINT		; receive fork termination channel
	REPEAT ^D36-.,<0>
	DEPHASE

; Interrupt from sender interrupt

INSINT:	MOVEM 17,IN2ACS+17	; save all ACs
	MOVEI 17,IN2ACS
	BLT 17,IN2ACS+16
	MOVE 17,IN2ACS+17
	SOSL NTOINP		; count up another INS
	IFSKP.
	  MOVX A,.PRIOU
	  CFOBF%		; flush output buffer
	  DMOVE A,[POINT 8,TTOBFR
		   4*TTOBSZ]
	  DMOVEM A,TTOPTR	; init buffer pointer/counter
	  HRRZ A,LEV2PC		; get PC of interrupt
	  CAIL A,TTOPC		; are we doing our moby TTY SOUT%?
	   CAILE A,TTOPC+1
	ANSKP.
	  MOVX A,<PC%USR!TTOPC+1> ; yes, dismiss to after the SOUT%
	  MOVEM A,LEV2PC
	ENDIF.
	SKIPN DEBUGP
	IFSKP.
	  TMSG <*R*INS*
>
	ENDIF.
	MOVSI 17,IN2ACS		; restore ACs
	BLT 17,17
	DEBRK%

; Connection closed interrupt

CLSINT:	MOVEM 17,IN1ACS+17	; save all ACs
	MOVEI 17,IN1ACS
	BLT 17,IN1ACS+16
	MOVE 17,IN1ACS+17
	SKIPN A,RCVFRH		; is there a receive fork?
	IFSKP.
	  RFSTS%
	   ERCAL FATAL
	  LOAD A,RF%STS,A	; get fork status code
	  CAIE A,.RFFPT		; did somebody zap me?
	  IFSKP.
	    CALL TTYRST		; no, restore TTY to normal mode
	    EMSG <Abnormal fork termination interrupt
>
	    CALL CLOSE1		; flush JFNs, etc.
	    MOVX A,PC%USR!CLSRET ; dismiss back to top level
	    MOVEM A,LEV1PC
	  ELSE.
	    CAIE A,.RFHLT	; stopped voluntarily?
	  ANSKP.		; if not then some other fork caused the int
	    CALL TTYRST		; restore TTY to normal mode for message
	    SKIPE DCNP		; give DECnet diagnostic if appropriate
	     CALL DCNERR
	    CALL CLOSE1
	    TMSG < by foreign host>
	    MOVX A,PC%USR!CLSRET ; dismiss back to top level
	    MOVEM A,LEV1PC
	  ENDIF.
	ENDIF.
	MOVSI 17,IN1ACS		; restore ACs
	BLT 17,17
	DEBRK%

; Initialize the timer

SETTIM:	MOVE A,[.FHSLF,,.TIMEL]	; tick the timer every 5 seconds
	MOVX B,^D5*^D1000
	MOVX C,TIMCHN
	TIMER%
	 ERCAL FATAL
	RET

; Timer interrupt

TIMINT:	MOVEM 17,IN1ACS+17	; save all ACs
	MOVEI 17,IN1ACS
	BLT 17,IN1ACS+16
	MOVE 17,IN1ACS+17
	CALL SETTIM		; reinitialize the timer
	AOSE TIMOUT		; has timer run out yet?
	IFSKP.
	  CALL TTYRST		; yes, reset TTY status, forcibly
	  EMSG <Time out>
	  MOVX A,.PRIIN		; flush TTY input
	  CFIBF%
	   ERCAL FATAL
	  SKIPE A,RCVFRH	; kill receive fork
	   KFORK%
	    ERNOP		; don't die if some hacker zapped our fork
	  MOVX A,<PC%USR!TIMRET> ; dismiss back to top level
	  MOVEM A,LEV1PC
	ENDIF.
	MOVSI 17,IN1ACS		; restore ACs
	BLT 17,17
	DEBRK%
	SUBTTL Network input fork

RCVFRK:	MOVE P,[IOWD PDLLEN,RPDL] ; set up fork's stack
	MOVX A,.FHSLF
	MOVE B,[LEVTAB,,CHNTAB]	; init inferior's PSI's (sigh...)
	SIR%
	 ERCAL FATAL
	EIR%
	 ERCAL FATAL
	MOVX B,<1B<INSCHN>>
	AIC%
	 ERCAL FATAL
	SKIPN INTP		; Internet?
	IFSKP.
	  MOVE A,NETJFN		; set up INS PSI for Urgent data
	  MOVX B,.TCSPC
	  MOVX C,<<FLD INSCHN,TC%TPU>!TC%TER!TC%TSC!TC%TXX>
	  TCOPR%
	   ERNOP
	ENDIF.
	SKIPN PUPP		; Pup Ethernet?
	IFSKP.
	  MOVE A,NETJFN		; set up INS PSI
	  MOVX B,.MOAIN
	  HRLOI C,007777	; Interrupt on channel 0, no other PSI's
	  MTOPR%
	   ERNOP		; connection may have closed very quickly
	ENDIF.

; Network input fork main loop

	DO.
	  SOSL NTICTR		; anything in net input buffer?
	  IFSKP.
	    MOVE A,NETJFN	; no, any input in the system for me?
	    SIBE%
	    IFSKP.
	      CALL TTOSND	; no, force out TTY buffer
	      MOVE A,NETJFN	; and read in exactly one byte
	      MOVX B,1
	    ENDIF.
	    CAILE B,4*NTIBSZ	; bounds check
	     MOVX B,4*NTIBSZ	; guess we should reassemble!
	    MOVEM B,NTICTR	; note number of words this buffer
	    MOVNI C,(B)
	    MOVE B,[POINT 8,NTIBFR]
	    MOVEM B,NTIPTR	; re-initialize pointer
	    SIN%		; slurp up the net data
	    IFJER.
	      SKIPN PUPP	; Pup Ethernet connection?
	       JRST DEATH	; no, assume the connection has died
	      SETZ C,		; not interested in port status cruft
	      GDSTS%		; find out what happened
	       ERCAL FATAL
	      JXN B,BS.END,DEATH ; End encountered?
	      TXZN B,BS.MRK	; Mark encountered?
	       LOOP.		; no, must be randomness then
	      SDSTS%		; clear Mark condition
	       ERCAL FATAL
	      MOVX B,.MOPRM	; get the Mark byte that did us in
	      MTOPR%
	       ERCAL FATAL
	      CAIN C,MK.DAT	; Data Mark?
	       AOSA NTOINP
		CAIE C,MK.TIM	; Timing Mark?
		 LOOP.		; get out of this cruft now
	      MOVE A,NETJFN	; need output JFN to send data mark
	      MOVX B,.MOPEF	; send Mark
	      MOVX C,MK.TMR	; Timing Mark Reply
	      MTOPR%
	       ERCAL FATAL
	    ENDIF.
	    LOOP.
	  ENDIF.
	  ILDB B,NTIPTR		; read a single byte
	  SKIPN TPROTP		; using TELNET protocol?
	  IFSKP.
	    AOSN NETCMP		; yes, IAC in progress?
	    IFSKP.
	      CAIE B,IAC	; no, network command?
	      IFSKP.
		SETOM NETCMP	; yes, remember that one is coming
		LOOP.
	      ENDIF.
	    ELSE.
	      CAIN B,IAC	; IAC in progress, quoted IAC?
	    ANSKP.
	      SKIPN DEBUGP	; no, log the message if debugging
	      IFSKP.
		TMSG <*R*IAC>
		CAIL B,TPLMIN ; known option?
		IFSKP.
		  MOVX A,.CHSPC ; no, output it numerically
		  PBOUT%
		  MOVX A,.PRIOU
		  MOVX C,^D8
		  NOUT%
		   ERCAL FATAL
		ELSE.
		  HRRO A,TPLTAB-TPLMIN(B)
		  PSOUT%	; output option name
		ENDIF.
		CAIL B,WILL	; three byte command?
	      ANSKP.
		TMSG <*
>
	      ENDIF.
	      CAIN B,DM		; Data Mark?
	       AOS NTOINP
	      CAIN B,WILL	; WILL option?
	       SETOM WILLP
	      CAIN B,WONT	; WONT
	       SETOM WONTP
	      CAIN B,DO		; DO
	       SETOM DOP
	      CAIN B,DONT	; DONT
	       SETOM DONTP
	      CAIE B,SB		; subnegotiations are losers!
	      IFSKP.
		TMSG <
******************************
* Foreign host sent a subnegotiation.  Either there was a
* transmission error in the network or there is a bug in
* somebody's network code.  Please report that this happened.
* You will probably see some garbage after this message.
******************************
>
	      ENDIF.
	      LOOP.
	    ENDIF.
	    AOSE WILLP		; WILL in progress?
	    IFSKP.
	      CALL OPTLST
	      CAIE B,SUPRGA	; WILL SUPPRESS-GA?  (yay!)
	      IFSKP.
		SKIPE SUPGAP
		 LOOP.
		SETOM SUPGAP
		TELCMD <IAC,DO,SUPRGA>
		LOOP.
	      ENDIF.
	      CAIE B,ECHO	; WILL ECHO?
	      IFSKP.
		CALL RMTECO
		CALL NETFRC	; force out the command
		LOOP.
	      ENDIF.
	      CAIE B,TRNBIN	; WILL TRANSMIT-BINARY?
	      IFSKP.
		SKIPE RCBINP
		 LOOP.
		SETOM RCBINP
		TELCMD <IAC,DO,TRNBIN>
		LOOP.
	      ENDIF.
	      PUSH P,B
	      MOVX B,IAC
	      CALL NETOUT
	      MOVX B,DONT
	      CALL NETOUT
	      POP P,B
	      CALL NETOUT
	      SKIPN DEBUGP
	      IFSKP.
		TMSG <*S*IAC,DONT>
		CALL OPTLST
	      ENDIF.
	      CALL NETFRC
	      LOOP.
	    ENDIF.
	    AOSE WONTP		; WONT in progress?
	    IFSKP.
	      CALL OPTLST
	      CAIE B,ECHO	; WONT ECHO?
	      IFSKP.
		CALL LCLECO	; yes, enter that mode
		LOOP.
	      ENDIF.
	      CAIE B,TRNBIN	; WON'T TRANSMIT-BINARY?
	      IFSKP.
		SKIPN RCBINP	; yes, already in that mode?
		 LOOP.
		SETZM RCBINP	; yes, change modes and confirm it
		TELCMD <IAC,DONT,TRNBIN>
		LOOP.
	      ENDIF.
	      CAIN B,SUPRGA	; WONT SUPPRESS-GA?
	       SKIPL SUPGAP
		LOOP.
	      TELCMD <IAC,DONT,SUPRGA> ; confirm it, but we'll never send any
	      SETZM SUPGAP	;  GA's anyway
	      LOOP.
	    ENDIF.
	    AOSE DOP		; DO in progress?
	    IFSKP.
	      CALL OPTLST
	      CAIE B,TRNBIN	; DO TRANSMIT-BINARY?
	      IFSKP.
		SKIPE TRBINP
		 LOOP.
		SETOM TRBINP
		TELCMD <IAC,WILL,TRNBIN>
		LOOP.
	      ENDIF.
	      CAIE B,TIMMRK	; is it this cretinous timing-mark option?
	      IFSKP.
		TELCMD <IAC,WILL,TIMMRK>
		LOOP.
	      ENDIF.
	      PUSH P,B		; unsupported DO option, refuse it
	      MOVX B,IAC
	      CALL NETOUT
	      MOVX B,WONT
	      CALL NETOUT
	      POP P,B
	      CALL NETOUT
	      SKIPN DEBUGP
	      IFSKP.
		TMSG <*S*IAC,WONT>
		CALL OPTLST
	      ENDIF.
	      CALL NETFRC
	      LOOP.
	    ENDIF.
	    AOSE DONTP		; DONT in progress?
	    IFSKP.
	      CALL OPTLST
	      CAIN B,TRNBIN	; DONT TRANSMIT-BINARY?
	       SKIPN TRBINP
		LOOP.
	      TELCMD <IAC,WONT,TRNBIN> ; yes, confirm it
	      SETZM TRBINP
	      LOOP.
	    ENDIF.
	  ELSE.
	    SKIPN INTP		; not TELNET protocol, but enter it if see an
	     SKIPE CHAOSP	;  escape on Internet or Chaosnet
	  ANNSK.
	    CAIE B,IAC		; saw a protocol escape?
	  ANSKP.
	    SETOM TPROTP	; yes, note that we entered TELNET protocol
	    SETOM NETCMP	; flag IAC in progress
	    CALL RMTECO		; try for remote echoing (don't NETFRC)
	    SETOM SUPGAP	; and GA suppression
	    TELCM1 <IAC,DO,SUPRGA>
	    LOOP.		; get next (command) byte
	  ENDIF.
	  SKIPGE NTOINP		; flush if output abort in progress
	   LOOP.
	  SKIPN PARITP		; are we required to do parity?
	   TXZA B,CH%PAR	; no, clear parity bit
	    SKIPE RCBINP	; yes, remote host sending binary?
	  IFSKP.
	    MOVEI A,(B)		; no, must comput parity
	    LSH A,-4		; get high order 4 bits of character
	    XORI A,(B)		; fold into 4 bits
	    TXCE A,14		; left two bits both 0 or 1?
	     TXNN A,14
	      XORX B,CH%PAR	; yes, set parity
	    TXCE A,3		; right two bits both 0 or 1?
	     TXNN A,3
	      TXCA B,CH%PAR	; set parity
	       TXZ B,CH%PAR	; parity must be clear
	  ENDIF.
	  IDPB B,TTOPTR		; else stick it in buffer
	  SOSG TTOCTR		; buffer full now?
	   CALL TTOSND		; force it out then
	  LOOP.
	ENDDO.

; Output an option code in B

OPTLST:	SKIPN DEBUGP
	 RET
	CAIE B,EXOPL		; this option is way out in the boonies
	IFSKP.
	  TMSG < EXOPL*>
	  RET
	ENDIF.
	CAIG B,WDOMAX		; new option I don't know yet?
	IFSKP.
	  MOVX A,.CHSPC
	  PBOUT%
	  MOVX A,.PRIOU
	  MOVX C,^D8
	  NOUT%
	   ERCAL FATAL
	  RET
	ENDIF.
	HRRO A,WDOTAB(B)	; otherwise print the option name
	PSOUT%
	TMSG <*
>
	RET
	SUBTTL Network I/O subroutines

; Add a single byte to the network output buffer

NETOUT:	IDPB B,NTOPTR		; stuff byte in buffer
	SOSLE NTOCTR		; any space left in buffer?
	 RET			; yes, just return
;	CALLRET NETFRC		; no, force buffer out

; Force the accumulated buffer out to the network

NETFRC:	DMOVE B,[POINT 8,NTOBFR	; get pointer/counter to net output buffer
		 4*NTOBSZ]
	CAMN C,NTOCTR		; no-op if buffer empty
	 RET
	MOVX A,TIMTCK		; set a timeout over this code
	MOVNM A,TIMOUT
	MOVEM B,NTOPTR		; reset pointer
	EXCH C,NTOCTR		; reset counter, get old counter
	SUB C,NTOCTR		; C := negative count of bytes in buffer
	MOVE A,NETJFN		; force network buffer out
	MOVE B,NTOPTR		; from start of buffer
	SOUTR%			; send it now
	 ERJMP R		; don't ITRAP on this guy
	SETZM TIMOUT		; clear timeout
	RET			; return

; Output a string to the network, pointer to string in 9-bit bytes in B

NETSTR:	STKVAR <NETPTR>
	HRLI B,(<POINT 9,>)	; make 9-bit bytes
	MOVEM B,NETPTR		; save pointer
	DO.
	  ILDB B,NETPTR		; get a byte
	  CAIN B,777		; end of string byte?
	  IFSKP.
	    CALL NETOUT		; output it
	    LOOP.		; loop until finished
	  ENDIF.
	ENDDO.
	RET
	SUBTTL TTY I/O subroutines

; Force out accumulated TTY buffer (called when full or net input buffer empty)

TTOSND:	DMOVE B,[POINT 8,TTOBFR
		 4*TTOBSZ]
	CAMN C,TTOCTR		; no-op if buffer empty
	 RET
	MOVEM B,TTOPTR		; re-init buffer pointer/counter
	EXCH C,TTOCTR
	SUB C,TTOCTR		; C := negative count of bytes in buffer
	PUSH P,C		; save the counter in case log file
	SKIPE A,LOGJFN		; is there a log file?
	 SOUT%			; yes, output the text to the file
	MOVX A,.PRIOU		; buffer full, output it
	MOVE B,[POINT 8,TTOBFR]
	POP P,C
TTOPC:	SOUT%			; output the buffer
	RET

; Outputs a CRLF iff it is necessary

CRLF:	SAVEAC <A,B>
	MOVX A,.PRIOU
	RFPOS%			; get cursor position
	JXE B,.RHALF,R		; is it necessary?
	TMSG <
>
	RET

; Initialize TTY state for talk mode

TTYINI:	SKIPGE TTYINP		; are we already TTYINI'd?
	 RET			; yes, ignore
	SETOM TTYINP		; flag terminal TTYINI'd
	MOVX A,.FHJOB		; disable all TTY interrupts
	SETZ B,
	STIW%
	 ERCAL FATAL
	MOVX A,.PRIIN
	MOVE B,TTYMOD		; get nominal TTY mode
	SKIPN OPAQUP		; opaque mode?
	 TXZ B,TT%DAM		; yes, enter binary mode
	SKIPN LINEDP		; using line editor?
	 TXZ B,TT%ECO		; no, disable echo as well
	SFMOD%
	 ERCAL FATAL
	SKIPE PAGEP		; PAGE mode enabled?
	 TXOA B,TT%PGM		; enable page mode
	  TXZ B,TT%PGM		; disable page mode
	STPAR%
	 ERCAL FATAL
	SKIPN OPAQUP		; opaque mode?
	 RET			; no, no need to do CCOC hackery
	DMOVE B,[BYTE (2) 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
		 BYTE (2) 2,2,2,2,2,2,2,2,2,2,2,2,2,2]
	SFCOC%			; diddle CCOC words
	 ERCAL FATAL
	RET

; Reset TTY state when leaving talk to remote host mode

TTYRST:	SKIPL TTYINP		; are we TTYINI'd?
	 RET			; no, ignore
	SETZM TTYINP		; no longer TTYINI'd
	TMSG <
>				; output (unconditional) newline
	MOVX A,.FHJOB
	MOVE B,TTYTIW		; restore old TTY interrupt word
	STIW%
	 ERCAL FATAL
	MOVX A,.PRIIN		; restore old TTY state
	MOVE B,TTYMOD
	SFMOD%
	 ERCAL FATAL
	STPAR%
	 ERCAL FATAL
	SKIPN OPAQUP		; opaque mode?
	 RET			; no, no need to do CCOC hackery
	DMOVE B,TTYCOC		; restore CCOC words
	SFCOC%
	 ERCAL FATAL
	RET

; Enter remote echo, note that TELCM1 is used so caller must NETFRC

RMTECO:	SKIPE ECHOP		; already in the state?
	 RET			; yes, no-op
	SETOM ECHOP		; flag remote echo
	SKIPN LINEDP		; using line editor?
	IFSKP.
	  MOVX A,.PRIIN		; get current TTY modes
	  RFMOD%
	   ERCAL FATAL
	  TXZ B,TT%ECO		; disable echoing
	  SFMOD%
	   ERCAL FATAL
	ENDIF.
	SKIPN TPROTP		; doing protocol?
	IFSKP.
	  TELCM1 <IAC,DO,ECHO>
	ENDIF.
	RET			; return to caller

; Enter local echo

LCLECO:	SKIPN ECHOP		; were we already in local echo mode?
	 RET			; yes, no-op this routine
	SETZM ECHOP		; flag local echo
	MOVX A,.PRIIN		; get current TTY modes
	RFMOD%
	 ERCAL FATAL
	SKIPN LINEDP		; using line editor?
	 TXZA B,TT%ECO		; no, disable echo as well
	  TXO B,TT%ECO		; yes, enable echoing
	SFMOD%
	 ERCAL FATAL
	SKIPN TPROTP		; doing protocol?
	IFSKP.
	  TELCMD <IAC,DONT,ECHO>
	ENDIF.
	RET			; return to caller
	SUBTTL Error handling stuff

; DECnet connection failed.  Report why

DCNERR:	MOVE A,NETJFN		; set up JFN in case called from CLSINT
	MOVX B,.MORLS		; get link status
	MTOPR%
	 ERJMP ERROR		; JFN screwed up or something
	HRRZ B,C
	CAIGE B,MXDNER		; reasonable error code?
	 SKIPN A,DCNETB(B)	; yes, get message
	 IFSKP.
	   PSOUT%		; win, output message text
	 ELSE.
	   TMSG <NSP error #>	; no message or off the wall error code
	   MOVX A,.PRIOU	; sigh, output number
	   MOVX C,^D10		; in decimal
	   NOUT%
	    ERCAL FATAL
	 ENDIF.
	MOVE A,NETJFN
	MOVX B,.MORDA		; read optional data
	HRROI C,TTOBFR		; into TTOBFR
	SETZ D,
	MTOPR%
	 ERNOP
	IFN. D			; done if no host name
	  SETZ D,		; tie off string with a null
	  IDPB D,C
	  TMSG < at host >
	  HRROI A,TTOBFR	; print the losing host
	  PSOUT%
	ENDIF.
	CALLRET CRLF

; Table of NSP error codes and their messages

DCNETB:	PHASE 0
.DCX0::!-1,,[ASCIZ/No special error/]
.DCX1::!-1,,[ASCIZ/Resource allocation failure/]
.DCX2::!-1,,[ASCIZ/Destination node does not exist/]
.DCX3::!-1,,[ASCIZ/Node shutting down/]
.DCX4::!-1,,[ASCIZ/Destination NRT process does not exist/]
.DCX5::!-1,,[ASCIZ/Invalid name field/]
.DCX6::!0
.DCX7::!0
.DCX8::!0
.DCX9::!-1,,[ASCIZ/NRT server aborted link/]
.DCX10::!0
.DCX11::!-1,,[ASCIZ/Undefined error/]
.DCX12::!0
.DCX13::!0
.DCX14::!0
.DCX15::!0
.DCX16::!0
.DCX17::!0
.DCX18::!0
.DCX19::!0
.DCX20::!0
.DCX21::!-1,,[ASCIZ/CI with invalid destination address/]
.DCX22::!0
.DCX23::!0
.DCX24::!-1,,[ASCIZ/Flow control violation/]
.DCX25::!0
.DCX26::!0
.DCX27::!0
.DCX28::!0
.DCX29::!0
.DCX30::!0
.DCX31::!0
.DCX32::!-1,,[ASCIZ/Too many connections to node/]
.DCX33::!-1,,[ASCIZ/Too many connections to destination NRT process/]
.DCX34::!-1,,[ASCIZ/Access not permitted/]
.DCX35::!-1,,[ASCIZ/Logical link services mismatch/]
.DCX36::!-1,,[ASCIZ/Invalid account/]
.DCX37::!-1,,[ASCIZ/Segment size too small/]
.DCX38::!-1,,[ASCIZ/Process aborted/]
.DCX39::!-1,,[ASCIZ/No path to destination node/]
.DCX40::!-1,,[ASCIZ/Link aborted due to data loss/]
.DCX41::!-1,,[ASCIZ/Destination logical link address does not exist/]
.DCX42::!-1,,[ASCIZ/Confirmation of disconnect initiate/]
.DCX43::!-1,,[ASCIZ/Image data field too long/]
	DEPHASE
MXDNER==.-DCNETB

NAMERR:	EMSG <No such host name>
	CALLRET CMDER1

CMDERR:	EMSG <>
	CALL ERROUT		; output last error message
CMDER1:	TMSG < - ">
	HRROI A,ATMBUF		; output last atom
	PSOUT%
	TMSG <"
>
	SKIPE A,TMPJFN		; flush possible JFN
	 RLJFN%
	  NOP			; don't loop in error output
	SETZM TMPJFN
	RET

; Other non-fatal JSYS error

ERROR:	SKIPN TAKEP		; TAKE file in progress?
	IFSKP.
	  MOVX A,.FHSLF		; yes, check last error
	  GETER%
	  HRRZS B		; only want error code
	  CAIN B,IOX4		; end of TAKE file?
	   JRST UNTAKE		; leave TAKE file and return to user
	ENDIF.
	EMSG <>
	CALL ERROUT		; output last error message
	SKIPE A,TMPJFN		; flush possible JFN
	 RLJFN%
	  NOP			; don't loop in error output
	SETZM TMPJFN
	CALLRET CRLF		; output newline and return

; Common routine called to output last error code's message

ERROUT:	SAVEAC <A>		; save error code if here
	MOVX A,.PRIOU
	HRLOI B,.FHSLF		; dumb ERSTR%
	SETZ C,
	ERSTR%
	 NOP			; ERSTR% has TWO failure returns...ugh!
	 TRNA
	  RET
	TMSG <Undefined error >
	MOVX A,.FHSLF		; get error number
	GETER%
	MOVX A,.PRIOU		; output it
	HRRZS B			; only right half where error code is
	MOVX C,^D8		; in octal
	NOUT%
	 ERJMP R		; ignore error here
	RET

; Fatal errors arrive here

FATAL:	MOVEM 17,FATACS+17	; save all ACs
	MOVEI 17,FATACS
	BLT 17,FATACS+16
	MOVE 17,FATACS+17
	EMSG <>
	CALL ERROUT
	TMSG <, >
	MOVE TT,(P)		; get PC
	MOVE TT,-2(TT)		; get instruction which lost
	CALL SYMOUT
	TMSG < at PC >
	POP P,TT
	MOVEI TT,-2(TT)		; point PC at actual location of the JSYS
	CALL SYMOUT
	CALL CRLF
DEATH:	DO.
	  HALTF%		; non-continuable TELNET exit point
	  EMSG <Can't continue>
	  LOOP.
	ENDDO.

;  Clever symbol table lookup routine.  For details, read "Introduction to
; DECSYSTEM-20 Assembly Language Programming", by Ralph Gorin, published by
; Digital Press, 1981.  Called with desired symbol in F.

SYMOUT:	SETZB C,T		; no current program name or best symbol
	MOVE D,.JBSYM		; symbol table pointer
	HLRO A,D
	SUB D,A			; -count,,ending address +1
	DO.
	  LDB A,[POINT 4,-2(D),3] ; symbol type
	  IFN. A		; program names are uninteresting
	    CAILE A,2		; 0=prog name, 1=global, 2=local
	  ANSKP.
	    MOVE A,-1(D)	; value of the symbol
	    CAME A,TT		; exact match?
	    IFSKP.
	      MOVE T,D		; yes, select it
	      EXIT.
	    ENDIF.
	    CAML A,TT		; smaller than value sought?
	  ANSKP.
	    SKIPE B,T		; get best one so far if there is one
	     CAML A,-1(B)	; compare to previous best
	      MOVE T,D		; current symbol is best match so far
	  ENDIF.
	  ADD D,[2000000-2]	; add 2 in the left, sub 2 in the right
	  JUMPL D,TOP.		; loop unless control count is exhausted
	ENDDO.
	IFN. T			; did we have anything that could help?
	  MOVE B,TT		; yes, get desired value
	  SUB B,-1(T)		; less symbol's value = offset
	  CAIL B,200		; is offset small enough?
	ANSKP.
	  MOVE A,-2(T)		; symbol name
	  TXZ A,<MASKB 0,3>	; clear flags
	  CALL SQZTYO		; print symbol name
	  SUB TT,-1(T)		; value we wanted less this symbol's value
	  JUMPE TT,R		; if no offset, don't print "+0"
	  MOVX A,"+"		; add + to the output line
	  PBOUT%
	ENDIF.
	MOVX A,.PRIOU		; and copy numeric offset to output
	MOVE B,TT		; getting the offset first...
	MOVX C,^D8
	NOUT%
	 NOP
	RET

; Convert a 32-bit quantity in A from squoze to ASCII

SQZTYO:	IDIVI A,50		; divide by 50
	PUSH P,B		; save remainder, a character
	SKIPE A			; if A is now zero, unwind the stack
	 CALL SQZTYO		; call self again, reduce A
	POP P,A			; get character
	ADJBP A,[POINT 7,[ASCII/ 0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ.$%/],6]
	LDB A,A			; convert squoze code to ASCII
	PBOUT%
	RET
	SUBTTL Other randomness

; Constants

...VAR:!VAR			; generate variables (there shouldn't be any)
IFN .-...VAR,<.FATAL Variables can't be in this program>
...LIT:	XLIST			; save trees during LIT
	LIT			; generate literals
	LIST

	END EVECL,,EVEC		; The End
