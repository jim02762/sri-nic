!LPTSPL.CTL
!This Control File Assembles, Loads, and saves LPTSPL

!System Files

!	ACTSYM.UNV
!	MONSYM.UNV	T20

!Required Files in Your Area

!	GLXMAC.UNV	Library Macro and Symbol Definitions
!	GLXLIB.REL
!	QSRMAC.UNV
!	ORNMAC.UNV
!	D60JSY.REL	DN60 (IBMCOM) INTERFACE ROUTINES
!	D60UNV.UNV	DN60 (IBMCOM) INTERFACE ROUTINES
!	NURD.REL	T20

!Source Files

!	LPTSPL.MAC

!Output Files

!	LPTSPL.EXE

!  Set up logical names and such

.AS DSK REL
.SET WAT VER
@DEF REL: DSK:
@DEF UNV: DSK:,UNV:
@VDIR	LPTSPL.MAC

.DIRECT	LPTSPL.MAC

COMP::
@
.
COMPILE/COMPILE LPTSPL.MAC

@
.
R LINK
*/LOCALS/SYMSEG:LOW=LPTSPL,D60JSY/GO

@
.
SAVE LPTSPL

FINI::
@VDIRECT LPTSPL.EXE
.DIRECT/CHECK LPTSPL.EXE

@
.
PLEASE	LPTSPL Assembly Successful
NOERROR
@MODIFY BATCH GALAXY/DEP:-1
.SUB GALAXY=/MOD/DEP:-1

%CERR::
%ERR::
@
.
PLEASE	Error During LPTSPL Assembly

%FIN::
