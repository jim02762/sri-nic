IDENTIFICATION DIVISION. 

PROGRAM-ID.
	IDXINI.

AUTHOR.
	DIGITAL EQUIPMENT CORPORATION.

	COPYRIGHT (C) DIGITAL EQUIPMENT CORPORATION 1982, 1983.

	This software is furnished under a license and may be used and
	copied only in accordance with  the terms of such license  and
	with the  inclusion  of  the  above  copyright  notice.   This
	software or any other  copies thereof may  not be provided  or
	otherwise made available to any other person.  No title to and
	ownership of the software is hereby transferred.

	The information in this software is subject to change  without
	notice and should not be construed as a commitment by  Digital
	Equipment Corporation.

	Digital assumes no responsibility  for the use or  reliability
	of its software on equipment which is not supplied by Digital.


	This  program  is  a  portion  of  the  DIL  Load  Test sample
	application.  It is used to initialize the RMS indexed file on
	the DEC-20.

INSTALLATION.
	DEC-MARLBOROUGH.

DATE-WRITTEN.
	JUNE 24, 1982.


* Facility: DIL-SAMPLE
* 
* Edit History:
* 
* new_version (1, 0)
* 
* Edit (%O'1', '29-Oct-82', 'Sandy Clemens')
* %(  Clean up DIL sample application and place in library.
*     Files: JTSERV.CBL (NEW), JTTERM.CBL (NEW), IDXINI.CBL (NEW),
*     JTTERM.VAX-COB (NEW), JTVRPT.CBL (NEW), PROCES.MAC (NEW) )%
* 
* Edit (%O'6', '20-Jan-83', 'Sandy Clemens')
* %(  Add copyright notice for 1983. Files: DSHST.TXT, IDXINI.CBL,
*     JTSERV.CBL, JTTERM.CBL, JTTERM.VAX-COB, JTVRPT.CBL, PROCES.MAC )%
* 
* Edit (%O'7', '24-Jan-83', 'Sandy Clemens')
* %(  Add liability waiver to copyright notice. Files: DSHST.TXT,
*     IDXINI.CBL, JTSERV.CBL, JTTERM.CBL, JTTERM.VAX-COB, JTVRPT.CBL,
*     PROCES.MAC )%
* 
* Edit (%O'10', '25-Jan-83', 'Sandy Clemens')
* %(  Standardize "Author" entry.  Files: DSHST.TXT, IDXINI.CBL,
*     JTSERV.CBL, JTTERM.CBL, JTTERM.VAX-COB, JTVRPT.CBL )%
*
* new_version (2, 0)
*
* Edit (%O'12', '17-Apr-84', 'Sandy Clemens')
* %(  Add V2 files to DS2:.  )%

ENVIRONMENT DIVISION.

CONFIGURATION SECTION.

SOURCE-COMPUTER.
	DECSYSTEM-20.

OBJECT-COMPUTER.
	DECSYSTEM-20.

INPUT-OUTPUT SECTION.

FILE-CONTROL.

    SELECT JT-FIL ASSIGN TO DSK
	   ORGANIZATION IS RMS INDEXED
	   ACCESS MODE IS DYNAMIC
	   RECORD KEY IS JT-BADGE-NUM.

DATA DIVISION.

FILE SECTION.

FD  JT-FIL LABEL RECORDS ARE STANDARD
	VALUE OF IDENTIFICATION IS "JOBTICRMS".

01  JT-REC.
    05  JT-NAME PIC X(30).
    05  JT-BADGE-NUM PIC 9(7).
    05  JT-COST-CENTER PIC X(4).
    05  JT-WK-END-DATE PIC 9(6).
    05  JT-TOTAL-HRS COMP-1.
    05  JT-DETAIL-LINES OCCURS 10.
        10  JT-ACTIV-CD PIC X(4).
        10  JT-PL-NUM PIC X(4).
        10  JT-DIS-NUM PIC 9(5) COMP.
        10  JT-MFG-NUM PIC 9(5) COMP.
        10  JT-HOURS COMP-1.
        10  JT-OP-CD PIC X(4).

WORKING-STORAGE SECTION.

PROCEDURE DIVISION.

INITIALIZE-FILE.

    OPEN OUTPUT JT-FIL.
    CLOSE JT-FIL.

    STOP RUN.
