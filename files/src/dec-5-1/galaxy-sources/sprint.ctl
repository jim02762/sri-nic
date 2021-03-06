!SPRINT.CTL	Phil Taylor	14-Jul-78
!28-Jan-79	LSS	Editted in preparation of R4 Loadtest
!
!
!                  COPYRIGHT (c) 1979,1980,1981,1982
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

!This Control File Assembles, Loads, and saves SPRINT

!System Files

!	MONSYM.UNV
!	ACTSYM.UNV

!Required Files in Your Area

!	GLXMAC.UNV	Library Macro and Symbol Definitions
!	GLXINI.REL	Library Load Module
!	QSRMAC.UNV
!	ORNMAC.UNV

!Source Files

!	SPRINT.MAC

!Output Files

!	SPRINT.EXE

.ASS DSK REL
.SET WATCH VERSION
@DEF REL: DSK:
@DEF UNV: DSK:,UNV:
@VDIR	SPRINT.MAC

.DIRECT	SPRINT.MAC

COMP::
@
.
COMPILE/COMPILE SPRINT.MAC
LOAD SPRINT
SAVE SPRINT

@VDIRECT SPRINT.EXE
.DIRECT SPRINT.EXE

@
.
PLEASE	SPRINT Assembly Successful
NOERROR
@MODIFY BATCH GALAXY/DEP:-1
.SUBMIT GALAXY=/MOD/DEP:-1

%CERR::
%ERR::
@
.
PLEASE	Error During SPRINT Assembly
%FIN::
