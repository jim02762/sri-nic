!
!	COPYRIGHT (C) DIGITAL EQUIPMENT CORPORATION 1986.
!	ALL RIGHTS RESERVED.
!
!	THIS SOFTWARE IS FURNISHED UNDER A LICENSE AND MAY  BE  USED  AND
!	COPIED ONLY IN ACCORDANCE WITH THE TERMS OF SUCH LICENSE AND WITH
!	THE INCLUSION OF THE ABOVE COPYRIGHT NOTICE.   THIS  SOFTWARE  OR
!	ANY  OTHER  COPIES  THEREOF MAY NOT BE PROVIDED OR OTHERWISE MADE
!	AVAILABLE TO ANY OTHER PERSON.  NO TITLE TO AND OWNERSHIP OF  THE
!	SOFTWARE IS HEREBY TRANSFERRED.
!
!	THE INFORMATION IN THIS SOFTWARE IS  SUBJECT  TO  CHANGE  WITHOUT
!	NOTICE  AND  SHOULD  NOT  BE CONSTRUED AS A COMMITMENT BY DIGITAL
!	EQUIPMENT CORPORATION.
!
!	DIGITAL ASSUMES NO RESPONSIBILITY FOR THE USE OR  RELIABILITY  OF
!	ITS SOFTWARE ON EQUIPMENT THAT IS NOT SUPPLIED BY DIGITAL.
!
set trap file-open

DEFINE DSK: DSK:
DEFINE UNV: DSK:,SYS:
DEFINE SYS: DSK:,PKGBLD:[FROZEN],sys:
DEFINE BLI: DSK:,sys:,bli: