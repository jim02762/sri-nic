!
! NAME: REDIT.CTL
! DATE: 23-APR-84
!
!
!THIS CONTROL FILE IS PROVIDED FOR INFORMATION PURPOSES ONLY.  THE
!PURPOSE OF THE FILE IS TO DOCUMENT THE PROCEDURES USED TO BUILD
!THE DISTRIBUTED SOFTWARE.  IT IS UNLIKELY THAT THIS CONTROL FILE
!WILL BE ABLE TO BE SUBMITTED WITHOUT MODIFICATION ON CONSUMER
!SYSTEMS.  PARTICULAR ATTENTION SHOULD BE GIVEN TO ERSATZ DEVICES
!AND STRUCTURE NAMES, PPN'S, AND OTHER SUCH PARAMETERS.  SUBMIT
!TIMES MAY VARY DEPENDING ON SYSTEM CONFIGURATION AND LOAD.  THE
!AVAILABILITY OF SUFFICIENT DISK SPACE AND CORE IS MANDATORY.
!
! 
! FUNCTION:	THIS CONTROL FILE BUILDS REDIT FROM ITS
!		BASIC SOURCES.  THE FILE CREATED IS REDIT.EXE
!
! SUBMIT WITH THE SWITCH "/TAG:CREF" TO OBTAIN
!   A .CRF LISTING OF THE SOURCE FILE
!
!REQUIRED FILES:	(LATEST RELEASED VERSIONS)
!SYS:	MACRO.EXE
!	LINK.EXE
!	CREF.EXE
!	MONSYM.UNV
!	MACSYM.UNV
!	MACREL.REL
!FILES TO BE SHIPPED:
!	REDIT.CMD
!	REDIT.CTL
!	REDIT.DOC
!	REDIT.EXE
!	REDIT.MAC
!	REDIT.MEM
!
@DEF FOO: NUL:
@GOTO A
!
CREF:: @DEF FOO: DSK:
!
!
A::
@TAKE BATCH.CMD
!
@INFORMATION LOGICAL-NAMES ALL
!
!
! TAKE A CHECKSUMMED DIRECTORY OF ALL THE INPUT FILES
!
@VDIRECT SYS:MACRO.EXE,SYS:CREF.EXE,SYS:LINK.EXE,REDIT.MAC,
@CHECKSUM SEQ
@
@VDIRECT SYS:MONSYM.UNV,SYS:MACSYM.UNV,SYS:MACREL.REL,
@CHECKSUM SEQ
@
@
@GET SYS:MACRO
@INFORMATION VERSION
@GET SYS:LINK
@INFORMATION VERSION
@GET SYS:CREF
@INFORMATION VERSION
!
@COMPILE /COMPILE/CREF REDIT.MAC
!
@R CREF
*FOO:REDIT.LST=REDIT.CRF
!
@LOAD REDIT
!
@SAVE REDIT
@INFORMATION VERSION
!
@DIRECT REDIT.EXE,
@CHECKSUM SEQ
@
!
@DELETE REDIT.REL
!
![END REDIT.CTL]
