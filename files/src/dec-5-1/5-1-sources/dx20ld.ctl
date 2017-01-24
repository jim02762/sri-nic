!
! NAME: DX20LD.CTL
! DATE: 20-JUNE-78
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
! FUNCTION:	THIS CONTROL FILE BUILDS THE USER MODE
!		DX20 PROGRAM (DX20LD) TO LOAD MICROCODE
!		INTO A DX20 DURING TIMESHARING.
!
! SUBMIT WITH THE SWITCH "/TAG:CREF" TO OBTAIN 
!   A .CRF LISTING OF THE SOURCE FILE
!
!
@DEF FOO: NUL:
@GOTO A
!
CREF:: @DEF FOO: DSK:
!
A::
@TAKE BATCH.CMD
!
@INFORMATION LOGICAL-NAMES ALL
!
! TAKE A CHECKSUMMED DIRECTORY OF ALL THE INPUT FILES
!
@VDIRECT SYS:LINK.EXE,SYS:*DDT.EXE,SYS:CREF.EXE,DX20LD.MAC,
@CHECKSUM SEQ
@
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
!
@LOAD /COMPILE/CREF DX20LD.MAC
!
@ENABLE
@START
!
@INFORMATION MEMORY-USAGE
!
@SAVE DX20LD
%ERR::
%CERR::
%TERR::
%FIN::
!
@GET DX20LD
!
@INFORMATION VERSION
@R CREF
*FOO:DX20LD.LST=DX20LD.CRF
!
@VDIRECT DX20LD.EXE,
@CHECKSUM SEQ
@
!
! DELETE UNNECESSARY .REL FILES
! 
@DELETE DX20LD.REL
!
!
