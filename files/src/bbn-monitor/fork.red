REDIT 1(104) COMPARE by user CLYNN, 10-Feb-86 18:55:29
File 1: CWL:<DEC-6-1-BASE>FORK.MAC.1
File 2: CWL:<5-4-NET>FORK.MAC.2
***** CHANGE #1; PAGE 20, LINE 15; PAGE 20, LINE 15
	MOVX T1,FKPSI1
	MOVEM 1,FKINT(7)	;DISABLE ANY FURTHER INTERRUPTS
	MOVSI 1,(UMODF)
	MOVEM 1,FFL
	SETZM FPC
	MCENTR			;GET INTO REASONABLE MONITOR STATE
	CALL ABTBUF		;FLUSH TCP BUFFERS IN THIS FORK
	MOVEI 1,0(7)		;GET FORK HANDLE
 ---------------------------------
	MOVX T1,FKPSI1
	MOVEM 1,FKINT(7)	;DISABLE ANY FURTHER INTERRUPTS
	MOVSI 1,(UMODF)
	MOVEM 1,FFL
	SETZM FPC
	MCENTR			;GET INTO REASONABLE MONITOR STATE
	CALL MNTKFK		;RELEASE NETWORK RESOURCES FOR THIS FORK
	MOVEI 1,0(7)		;GET FORK HANDLE

***** CHANGE #2; PAGE 20, LINE 137; PAGE 20, LINE 137
	MOVEM 1,@FREJFK
	SETOM SYSFK(4)		;NOTE SLOT AVAILABLE
KSEF5:	CALL FUNLK
	LOAD T1,NOSTR
	SKIPE T1		;IF NO STRUCTURES MOUNTED, SKIP STR CODE
	CALL RELSTR		;RELEASE ALL STRUCTURE MOUNTS FOR FORK

 ---------------------------------
	MOVEM 1,@FREJFK
	SETOM SYSFK(4)		;NOTE SLOT AVAILABLE
KSEF5:	CALL FUNLK
	LOAD T1,NOSTR
	SKIPE T1		;IF NO STRUCTURES MOUNTED, SKIP STR CODE
	CALL RELSTR		;RELEASE ALL STRUCTURE MOUNTS FOR FORK
;;;101: Do at least one pass through the UPT to be sure pages are gone
	JRST KSEF3A		; Skip the DISMS first time through


***** CHANGE #3; PAGE 20, LINE 150; PAGE 20, LINE 152
KSEF2:	CALL CLNZSC		;DELETE USER'S NON-ZERO SECTIONS
	 JRST [	POP P,2		;STILL SOME LEFT, FIX STACK
		JRST KSEF3]	;GO WAIT FOR A WHILE
	POP P,2			;SHARE COUNT OF UPT
	CAIE 2,1		;UNSHARED?
	JRST KSEF3
	MOVE 7,FORKX
	HRLZ 2,FKPGS(7)
 ---------------------------------
KSEF2:	CALL CLNZSC		;DELETE USER'S NON-ZERO SECTIONS
	 JRST [	POP P,2		;STILL SOME LEFT, FIX STACK
		JRST KSEF3]	;GO WAIT FOR A WHILE
	POP P,2			;SHARE COUNT OF UPT
	CAIE 2,1		;UNSHARED?
	JRST KSEF3
;;;101 deletion
;	MOVE 7,FORKX
	HRLZ 2,FKPGS(7)

***** CHANGE #4; PAGE 20, LINE 163; PAGE 20, LINE 166
	 NOP			;IGNORE FAILURES
	CALL WTFPGS		;WAIT FOR UPT AND PSB TO BE UNMAPPED
	JRST HLTFK1		;GO DELETE UPT AND PSB

KSEF3:	MOVEI 1,^D5000
	DISMS			;WAIT FOR 5 SECS
	HLRZ 1,FKPGS(7)		;THEN CLEAR MAP AGAIN
 ---------------------------------
	 NOP			;IGNORE FAILURES
	CALL WTFPGS		;WAIT FOR UPT AND PSB TO BE UNMAPPED
	JRST HLTFK1		;GO DELETE UPT AND PSB

KSEF3:	MOVEI 1,^D5000
	DISMS			;WAIT FOR 5 SECS
;;;101 addition
KSEF3A:	MOVE 7,FORKX		;Get our fork index

	HLRZ 1,FKPGS(7)		;THEN CLEAR MAP AGAIN

