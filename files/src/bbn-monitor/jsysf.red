REDIT 1(104) COMPARE by user CLYNN, 10-Feb-86 18:56:42
File 1: CWL:<DEC-6-1-BASE>JSYSF.MAC.1
File 2: CWL:<5-4-NET>JSYSF.MAC.1
***** CHANGE #1; PAGE 24, LINE 6; PAGE 24, LINE 6

;ROUTINE CALLED FOR EACH FORK SPECIFIED

CLZFF1:
	PUSH P,P6		;PRESERVE THIS AC
	CALL ABTJCS		;CLOSE ALL THE JCNS
	POP P,P6		;RESTORE THE AC
 ---------------------------------

;ROUTINE CALLED FOR EACH FORK SPECIFIED

CLZFF1:
	PUSH P,P6		;PRESERVE THIS AC
	CALL MNTCZF		;RELEASE NETWORK FILES (OTHER THAN JFNS)
	POP P,P6		;RESTORE THE AC
