!
! NAME: C.CTL
! DATE: 30-JUN-81
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
! FUNCTION:	THIS CONTROL FILE BUILDS C.UNV
!
!
! TAKE A CHECKSUMMED DIRECTORY OF ALL THE INPUT FILES
!
@DIRECT C.MAC,
@CHECKSUM SEQ
@
!
! CHECK THE LOGICAL NAMES USED
!
;@DEFINE SYS: DSK:,FIELDI:,SYS:
@INFORMATION LOGICAL-NAMES SYS:
@INFORMATION LOGICAL-NAMES DSK:
!
@SET TRAP FILE
! CHECK VERSION NUMBERS OF CUSPS
!
@GET SYS:PA1050
@INFORMATION VERSION
!
@GET SYS:MACRO
@INFORMATION VERSION
!
! BUILD C.UNV
!
@COPY TTY: U.MAC
@	%.C==-3
@
!
@COMPILE /COMPILE /NOBIN DSK:U.MAC+DSK:C.MAC
!
@DELETE U.MAC
@EXPUNGE
!
! TAKE A CHECKSUMMED DIRECTORY OF THE OUTPUT FILE
!
@DIRECT C.UNV,
@CHECKSUM SEQ
@
!
![END OF C.CTL]