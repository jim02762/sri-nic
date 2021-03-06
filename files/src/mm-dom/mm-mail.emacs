!* -*-TECO-*-!
!* [PANDA]MRC:<MM>MM-MAIL.EMACS.9,  1-Feb-86 18:16:29, Edit by MRC!
!~Filename~:! !Macros for fixing various mail files to MM format!
MM-MAIL

!& Setup MM-MAIL Library:! !S Initialization code for MM-MAIL.!
    0

!Fix Message:! !C Patches up the message defined by the region!
    [0 [1  .,(:J .)f u1u0		!* Q0 gets region start, Q1 gets!
					!* region end.!
    q0,q1 M(m.M &_Save_For_Undo) Fix_Message
    Q0,Q1 fs boundaries
    [a [d				!* QA temporary, QD is message date!
    [b					!* QB is temportary!
    [n					!* QN will get the number of chars.!
    :I*;000000000000[t			!* QT will get the line trailer!
    J
    :S
date:_"E
	:I*No_DATE:_lineFG O exit'
    <.ua
	fsfdconvertud
	qd+1"'E;
	qaj
	:FB_"E 0l 1fwl 2c 
	    :I*Error_on_date_lineFG o exit'
	>
    JS
date:_					!* Until first dates are found!
    <.ua
	fsfdconvertud
	qd+1"'E;
	qaj :FB_"E :I*Error_on_date_lineFG oexit'>
    J 000020000000.,qd fsfdconvert i,
    z-b\ w gt 13i10i
!exit!
    J  zU1
    0,FSZ FS BOUNDARIES
    Q1 
    

!Fix MAIL file:! !C Patches up a text copy of mail to look like MM mail file.
A numeric argument does not save for Undo.  A pre-comma argument says to use
the current date and time!

    :S
date:_"E 0'				!* If nothing here to work on then!
					!* quit!
    J < . - (:L.) :;w 1l> 0l -zk	!* kill all previous blank lines!
    FF&2"'N [2			!* Q2 is nonzero if a precomma arg.!
    J 13i 10i -1l
    [a [d				!* QA temporary, QD is message date!
    [b					!* QB is temportary!
    [W
    [n					!* QN will get the number of chars.!
    :I*;000000000000[t			!* QT will get the line trailer!
    
    Q2"E
	J<:S
date:_;
	    0l <:FB,_; w 1r -1d> 0l 6c
	    <.ua
		fsfdconvertud
		qd+1"'E;
		qaj
		:FB_"E 0l 1fwl 2c 
		   :I*Error_on_date_line_in_pass_1FG w'
		>>'
    J 1k
    FF&1"E 0,fszM(m.M &_Save_For_Undo) Fix_Mail_File'
    zj 0,0a-10"N 13i10i'		!* Add a crlf if necessary!
    J M(M.M Flush_Lines);00000000000
    J <:S
Received:_;
	.(W<1l 1 F~_"'N * (0l 1 F~	"'N)"E
		   WM(M.M ^R_Delete_Indentation)'
		"# 0;'>)J>
    J <:S
; W0L1K>
    J 13i 10i -1l
    J <:S
From:_;				!* Fix weird from headers!
	:FB(!)!"L
	    -1d @-f_	k
	    .,(!(!:FB)"L -1d'"#:L'
		@-f_	k
		.) FXW
	    :K
	    0l 6c GW 32I I< :L I>
	    '
	>
    J<:S
date:_;				!* Until all dates are found!
	Q2"E				!* If no precomma argument!
	    0l <:FB,_; w 1r -1d> 0l 6c
	    <.ua
		fsfdconvertud
		qd+1"'E;
		qaj :FB_"E :I*Error_on_date_line_in_pass_2FG w'>'

	< b-.;				!* Done if we are at the beginning!
	    -1l :FB:_"E
		0l 1 F~	"'E;'	!* Done on a non-header line!
	    >

	1l 1 F~	"E 1l'		!* Last line of a message may start!
					!* with a tab!
	.ub .(-1l 2:S
date:_"E zJ'
	    "#
		< b-.;			!* Done if we are at the beginning!
		   -1l :FB:_"E
		      0l 1 F~	"'E;'	!* Done on a non-header line!
		   >
		1l 1 F~	"E
		   1l''			!* Last line of a message may start!
					!* with a tab!
		.ua )J
	QA-QB"E 
	    .(S
date:_ w0l1K)J
	    ocont'
	qa-qb F(un)"L :I*Error_finding_end_of_messageFG w'
	000020000000.,Q2"N -1'"# qd' fsfdconvert i,
	qn\ w gt 13i10i -1l
	:s
date:_;
	!cont!
>
    j 1k
    

!Fix Usenet Messages:! !C Fixes readnews messages.
A Numeric argument says to use the date it was sent!

    0,fszM(m.M &_Save_For_Undo) Fix_Usenet_Messages
    FF&1"'N [V
    J 13i 10i
    J M(M.M &_Flush_USENET_Lines)
    J <:S
Subject:_
Subject:	;
	:FBSubject:_Subject:	"L
	    FKC :K'			!* Fix Multiple Subjects!
	0l :FBROT13ROT_13"LOffensive'
	0l :fb(rot)"L(Offensive)'>	!* And ROTs!

    J <:S
Date:_;
	w:L -1fwl 0a-32"E -1di-'
	0l FXA -1L
	<   :FB:_"E 1l GA 0;'
	    0L 5  F~From:"E GA 0;'
	    -1L b-.;>
	>

    QV"E 1,'1 :M(M.M Fix_Mail_File)
    



!& Flush Usenet Lines:! !S Flush unwanted lines!
    J <!<!:S
From_
>From_; w:FB!"L 0l 1K'>		!* Remove who sent it!
    J <:S
	id_
Relay-Version:_
return-path:_
Posting-Version:_
In-reply-to:_
Path:_
Newsgroups:_
Distribution:_
Message-ID:_
Received:_
References:_
Date-Received:_;

	0l 1k -1l>			!* Remove spurious lines!

    J <:S
Reply-to:_
Expires:_
Lines:_
Approved
xref:_
nf-id:_
nf-from:_
resent-date:_
resent-from:_
resent-to:_
source-info:_;

	0l 1k -1l>			!* Remove spurious lines!
    J


!Fix Babyl Mail File:! !C Fix Babyl mail files to look like MMs.
A numeric argument prevents the buffer being saved for Undo.!
    Jw:s"E 0'		!* If this is not there then stop!
					!* processing!
    FF&1"E 0,fszM(m.M &_Save_For_Undo) Fix_Babyl_Mail_File'
    [T					!* Temporary register!
    0l b,(0l.)k				!* Kill Babyl File Header!
    13i10i
    J<:S
;				!* Separates the message headers!
	2R .UT
	:S
***_EOOH_***
;
	QT,.K				!* Kill the message headers!
	>
    J<:S
date:_;
	<:fb,; w-1d>
	>
    J 1M(m.m Fix_Mail_File)		!* Fix up what is left!
    J 

!* 
/ Local Modes: \
/ MM Compile: M(M.MGenerate Library)MM-MAILMM-MAIL
1:<M(M.MDelete File)MM-MAIL.COMPRS>W \
/ End: \
!