!
! NAME: UUOSYM.CTL
! DATE: 28-AUG-84
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
! FUNCTION:	THIS CONTROL FILE BUILDS UUOSYM FROM ITS
!		BASIC SOURCES.  THE FILE CREATED IS:
!
!			     UUOSYM.UNV
!
!		THIS JOB OPTIONALLY PRODUCES A .CRF LISTING
!		OF THE SOURCE CODE.
!
! SUBMIT WITH THE SWITCH "/TAG:CREF" TO OBTAIN
!   A .CRF LISTING OF THE SOURCE FILE
!
!
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
@VDIRECT SYS:MACRO.EXE,SYS:CREF.EXE,SYS:LINK.EXE,SYS:PA1050.EXE,
@CHECKSUM SEQ
@
@VDIRECT SYS:MACTEN.UNV,UUOSYM.MAC,
@CHECKSUM SEQ
@
@GET SYS:MACRO
@INFORMATION VERSION
@GET SYS:LINK
@INFORMATION VERSION
!
@COMPILE /COMPILE/CREF UUOSYM.MAC
!
@R CREF
*FOO:UUOSYM.LST=UUOSYM.CRF
!
@VDIRECT UUOSYM.UNV,
@CHECKSUM SEQ
@
!
@DELETE UUOSYM.REL
!
![END UUOSYM.CTL]