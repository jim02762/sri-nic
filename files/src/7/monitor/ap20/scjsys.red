REDIT 1(103) COMPARE by user MKL, 31-Mar-89 15:27:00
File 1: SRC:<7.MONITOR>SCJSYS.MAC.1
File 2: SRC:<7.MONITOR.AP20>SCJSYS.MAC.1
***** CHANGE #1; PAGE 1, LINE 1; PAGE 1, LINE 1
 ---------------------------------
; Edit= 8938 to SCJSYS.MAC on 24-Aug-88 by RASPUZZI
;Remove annoying helper line from source code.

***** CHANGE #2; PAGE 75, LINE 38; PAGE 75, LINE 38
	STOR T1,SAAFN,(SAB)	; CODE.
	SETZRO SAEOM,(SAB)	;NEVER DISCARD DATA.
	LOAD T1,FLLNK,(JFN)	;PUT PORT
	STOR T1,SAACH,(SAB)	; NUMBER INTO SAB
	CALL SCLFNC		;GET SOME BYTES FROM DECNET
;[7244] Change 1 line at DNETIN:+30	hmp	17-Feb-86
	 NOP			;[7244]
 ---------------------------------
	STOR T1,SAAFN,(SAB)	; CODE.
	SETZRO SAEOM,(SAB)	;NEVER DISCARD DATA.
	LOAD T1,FLLNK,(JFN)	;PUT PORT
	STOR T1,SAACH,(SAB)	; NUMBER INTO SAB
	CALL SCLFNC		;GET SOME BYTES FROM DECNET
	 NOP			;[7244]

