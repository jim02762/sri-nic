!
! 
! NAME: JOBDAT.CTL
! DATE 30 JUL 76
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
! TO GET A CREF LISTING OF THE SOURCE FILE, SUBMIT THIS
!   JOB WITH THE SWITCH "/TAG:CREF"
!
!
!
@DEF FOO: NUL:
@GOTO A
CREF:: @DEF FOO: DSK:
!
!
A::
@VDIRECT SYS:MONSYM.UNV,SYS:MACSYM.UNV,SYS:MACREL.REL,SYS:PA1050.EXE,
@CHECKSUM SEQ
@
@
@RUN SYS:MACRO
@INFORMATION VERSION
@GET SYS:LINK
@INFORMATION VERSION
@GET SYS:CREF
@INFORMATION VERSION
@DELETE UNV.MAC
@CREATE UNV.MAC
*	%..UNV==1
*^[
*EU
@COMPILE /COMPILE UNV.MAC+JOBDAT.MAC
@COMPILE /COMPILE JOBDAT.MAC
@DIR JOBDAT.*,
@CHECK SEQ
@
@DELETE UNV.MAC
@
![END JOBDAT.CTL]
  