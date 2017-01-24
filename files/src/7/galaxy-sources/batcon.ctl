!BATCON.CTL
!This Control File Assembles, Loads, and saves BATCON

!
!
!                COPYRIGHT (C) 1979,1980,1981,1982,1984,1987,1988
!                    DIGITAL EQUIPMENT CORPORATION
!
!     THIS SOFTWARE IS FURNISHED UNDER A LICENSE AND MAY  BE  USED
!     AND COPIED ONLY IN ACCORDANCE WITH THE TERMS OF SUCH LICENSE
!     AND WITH THE INCLUSION OF THE ABOVE COPYRIGHT NOTICE.   THIS
!     SOFTWARE  OR ANY OTHER COPIES THEREOF MAY NOT BE PROVIDED OR
!     OTHERWISE MADE AVAILABLE TO ANY OTHER PERSON.  NO  TITLE  TO
!     AND OWNERSHIP OF THE SOFTWARE IS HEREBY TRANSFERRED.
!
!     THE INFORMATION  IN  THIS  SOFTWARE  IS  SUBJECT  TO  CHANGE
!     WITHOUT  NOTICE  AND SHOULD NOT BE CONSTRUED AS A COMMITMENT
!     BY DIGITAL EQUIPMENT CORPORATION.
!
!     DIGITAL ASSUMES NO RESPONSIBILITY FOR THE USE OR RELIABILITY
!     OF  ITS  SOFTWARE  ON  EQUIPMENT  WHICH  IS  NOT SUPPLIED BY
!     DIGITAL.

!System Files

!	MONSYM.UNV

!Required Files in Your Area

!	GLXMAC.UNV	Library Macro and Symbol Definitions
!	GLXLIB.REL
!	QSRMAC.UNV
!	ORNMAC.UNV

!Source Files

!	BATCON.MAC
!	BATMAC.MAC
!	BATLOG.MAC

!Output Files

!	BATCON.EXE

@TAKE BATCH.CMD

@DEF REL: DSK:
@DEF UNV: DSK:

@VDIR	BATCON.MAC
@VDIR	BATMAC.MAC
@VDIR	BATLOG.MAC

COMP::
@COMPILE/COMPILE BATMAC.MAC
@COMPILE/COMPILE BATCON.MAC
@COMPILE/COMPILE BATLOG.MAC
@COMPILE OPRPAR.MAC

LOAD::
CHKPNT LOAD:
@LOAD BATCON.REL,BATLOG.REL
@SAVE BATCON
@VDIRECT BATCON.EXE,
@CHECK
@
@PLEASE	BATCON Assembly Successful
NOERROR

@MODIFY BATCH GALAXY/DEP:-1

%CERR::
%ERR::
@PLEASE	Error During BATCON Assembly
%FIN::
