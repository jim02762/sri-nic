!
!Prior to compiling anything, ensure that you have the latest versions of
!MACSYM.UNV,MONSYM.UNV and ACTSYM.UNV available via UNV:.
!
COMPIL/COMP MON:SYSFLG.MAC+MON:PROLOG.MAC R:PROLOG ;Common monitor definitions
COMPIL/COMP MON:GLOBS.MAC R:GLOBS	;Global symbols
COMPIL/COMP MON:NIPAR.MAC R:NIPAR	;Universal for NISRV users
COMPIL/COMP MON:ANAUNV.MAC R:ANAUNV	;Universal for ARPANET TCP/IP
COMPIL/COMP MON:PHYPAR.MAC R:PHYPAR	;Universal for PHYSIO and like modules
COMPIL/COMP MON:SCAPAR.MAC R:SCAPAR	;Universal for SCA
COMPIL/COMP MON:MSCPAR.MAC R:MSCPAR	;Universal for MSCP drivers and servers
COMPIL/COMP MON:D36PAR.MAC R:D36PAR	;DECnet symbols
COMPIL/COMP MON:SCPAR.MAC R:SCPAR	;Session control symbols
COMPIL/COMP MON:CTERMD.MAC R:CTERMD	;CTERM symbols
COMPIL/COMP MON:TTYDEF.MAC R:TTYDEF	;Teletype service symbols
COMPIL/COMP MON:SERCOD.MAC R:SERCOD	;Codes and fields for SYSERR facility
COMPIL/COMP MON:ENQPAR.MAC R:ENQPAR	;Cluster-wide ENQ support
COMPIL/COMP MON:CLUPAR.MAC R:CLUPAR	;KLUDGR symbols
COMPIL/COMP MON:CFSPAR.MAC R:CFSPAR	;CFS symbols
!
! Stanford Universal libraries
!
COMPIL/COMP MON:PUPSYM.MAC R:PUPSYM	;PUP symbols
COMPIL/COMP MON:DOMSYM.MAC R:DOMSYM	;GTDOM% symbols
!
COMPIL/COMP MON:SCHED.MAC R:SCHED	;Scheduler
COMPIL/COMP MON:PAGEM.MAC R:PAGEM	;Page management/working set management
COMPIL/COMP MON:PAGUTL.MAC R:PAGUTL	;Page management subroutines/utilities
COMPIL/COMP MON:TAPE.MAC R:TAPE		;Label handler and record processor
COMPIL/COMP MON:COMND.MAC R:COMND	;Command scanner JSYS
COMPIL/COMP MON:CRYPT.MAC R:CRYPT	;Encryption routines
COMPIL/COMP MON:DATIME.MAC R:DATIME	;Time and date routines
COMPIL/COMP MON:DEVICE.MAC R:DEVICE	;Device table (DEVTAB) routines
COMPIL/COMP MON:DIRECT.MAC R:DIRECT	;Disk directory management
COMPIL/COMP MON:DISC.MAC R:DISC		;Disk file management
COMPIL/COMP MON:ENQ.MAC R:ENQ		;ENQ and DEQ JSYS
COMPIL/COMP MON:ENQSRV.MAC R:ENQSRV	;Cluster-wide ENQ
COMPIL/COMP MON:FESRV.MAC R:FESRV	;Device code for FE devices
COMPIL/COMP MON:FILINI.MAC R:FILINI	;File system initialization
COMPIL/COMP MON:FILMSC.MAC R:FILMSC	;DTBs, PTY support
COMPIL/COMP MON:FORK.MAC R:FORK		;Fork controlling JSYS and functions
COMPIL/COMP MON:FREE.MAC R:FREE		;Storage routines
COMPIL/COMP MON:FUTILI.MAC R:FUTILI	;Miscellaneous routines for file system
COMPIL/COMP MON:GETSAV.MAC R:GETSAV	;Get and save routines
COMPIL/COMP MON:GTJFN.MAC R:GTJFN	;GTJFN and GNJFN JSYS
COMPIL/COMP MON:IO.MAC R:IO		;Sequential IO routines and JSYSes
COMPIL/COMP MON:IPCF.MAC R:IPCF		;Interprocess communications facility
COMPIL/COMP MON:JSYSA.MAC R:JSYSA	;Non-file system JSYSes
COMPIL/COMP MON:JSYSF.MAC R:JSYSF	;File system JSYSes
COMPIL/COMP MON:JSYSM.MAC R:JSYSM	;MEXEC JSYi
COMPIL/COMP MON:LDINIT.MAC R:LDINIT	;Define JSYS dispatch table, mon vers.
COMPIL/COMP MON:LINEPR.MAC+MON:LPFEDV.MAC R:LINEPR  ;Line printer device driver
COMPIL/COMP MON:LOGNAM.MAC R:LOGNAM	;Logical name JSYSes and support
COMPIL/COMP MON:LOOKUP.MAC R:LOOKUP	;File name lookup utilities (for GTJFN)
COMPIL/COMP MON:MFLIN.MAC R:MFLIN	;Floating point input routines
COMPIL/COMP MON:MFLOUT.MAC R:MFLOUT	;Floating point outputl routines
COMPIL/COMP MON:POSTLD.MAC R:POSTLD	;Post-loading one-shot init
COMPIL/COMP MON:SWPALC.MAC R:SWPALC	;Swapping space allocation
COMPIL/COMP MON:SYSERR.MAC R:SYSERR	;SPEAR routines
COMPIL/COMP MON:TIMER.MAC R:TIMER	;TIMER JSYS & schedular clock routines
COMPIL/COMP MON:SCAMPI.MAC R:SCAMPI	;Systems communications architecture
COMPIL/COMP MON:CFSSRV.MAC R:CFSSRV	;Common File System
COMPIL/COMP MON:CFSUSR.MAC R:CFSUSR	; "
COMPIL/COMP MON:CLUDGR.MAC R:CLUDGR	;KLUDGR
COMPIL/COMP MON:CLUFRK.MAC R:CLUFRK	; "
COMPIL/COMP MON:PHYKLP.MAC R:PHYKLP	;Device dependent code for KLIPA port
COMPIL/COMP MON:SCSJSY.MAC R:SCSJSY	;The SCS% JSYS
COMPIL/COMP MON:PHYMSC.MAC R:PHYMSC	;MSCP driver
COMPIL/COMP MON:PHYMVR.MAC R:PHYMVR	;MSCP Server
COMPIL/COMP MON:APRSRV.MAC R:APRSRV	;Processor-dependent paging
COMPIL/COMP MON:DIAG.MAC R:DIAG		;The DIAG JSYS
COMPIL/COMP MON:DSKALC.MAC R:DSKALC	;Device independent disk code
COMPIL/COMP MON:PHYH2.MAC R:PHYH2	;Channel dependent code for RH20
COMPIL/COMP MON:PHYM2.MAC R:PHYM2	;Device dependent code for TM02/TU45
COMPIL/COMP MON:PHYM78.MAC R:PHYM78	;Device dependent code for TM78/TU78
COMPIL/COMP MON:PHYP4.MAC R:PHYP4	;Device dependent code for RP04 DISKS
COMPIL/COMP MON:PHYSIO.MAC R:PHYSIO	;Device independent physical IO
COMPIL/COMP MON:MAGTAP.MAC R:MAGTAP	;MTA routines
COMPIL/COMP MON:MEXEC.MAC R:MEXEC	;Swappable monitor routines
COMPIL/COMP MON:MSTR.MAC R:MSTR		;Mountable structure monitor call
COMPIL/COMP MON:DTESRV.MAC R:DTESRV	;DTE support. RSX20F interface
COMPIL/COMP MON:IPIPIP.MAC R:IPIPIP	;Arpanet internet protocols
COMPIL/COMP MON:IPCIDV.MAC R:IPCIDV	;Internet CI Driver
COMPIL/COMP MON:IPFREE.MAC R:IPFREE	;Internet free storage routines
COMPIL/COMP MON:TCPTCP.MAC R:TCPTCP	;Arpanet transmission control
COMPIL/COMP MON:TCPCRC.MAC R:TCPCRC	;Cyclic redundancy check routines
COMPIL/COMP MON:TCPBBN.MAC R:TCPBBN	;BBN TCP JSYS service routines
COMPIL/COMP MON:TCPJFN.MAC R:TCPJFN	;DEC JSYS interface for BBN TCP
COMPIL/COMP MON:MNETDV.MAC R:MNETDV	;Multinet software for ARPANET TCP/IP
COMPIL/COMP MON:TTYSRV.MAC R:TTYSRV	;Teletype service routines
COMPIL/COMP MON:RSXSRV.MAC R:RSXSRV	;Teletype service routines
COMPIL/COMP MON:TVTSRV.MAC R:TVTSRV	;Internet terminal service
COMPIL/COMP MON:CIDLL.MAC R:CIDLL	;CI data link layer
COMPIL/COMP MON:LATSRV.MAC R:LATSRV	;LAT host server
COMPIL/COMP MON:D36COM.MAC R:D36COM	;Common routines for DECnet
!
! SC-30M Modules
!
!COMPIL/COMP MON:PHYSAI.MAC R:PHYSAI	;SA10 CROCK (MARS ONLY)
!COMPIL/COMP MON:PHYC1.MAC R:PHYC1	;IBM DISK DRIVER (MARS ONLY)
!COMPIL/COMP MON:PHYSAT.MAC R:PHYSAT	;IBM TAPE DRIVER (MARS ONLY)
!COMPIL/COMP MON:PHYFAD.MAC R:PHYFAD	;SMD/CTL DISK DRIVER (MARS ONLY)
!
! DECnet and KLNI modules (the SC-30M has a KLNI)
!
!COMPIL/COMP MON:LLINKS.MAC R:LLINKS	;DECnet NSP (ECL) layer
!COMPIL/COMP MON:LLMOP.MAC R:LLMOP	;DECnet low level MOP support
!COMPIL/COMP MON:TOPS.MAC+MON:NISRV.MAC+MON:PHYKNI.MAC R:NISRV
					;KLNI device driver
!COMPIL/COMP MON:NIUSR.MAC R:NIUSR	;NI% JSYS
!COMPIL/COMP MON:NTMAN.MAC R:NTMAN	;Network management
!COMPIL/COMP MON:ROUTER.MAC R:ROUTER	;DECnet router layer
!COMPIL/COMP MON:SCJSYS.MAC R:SCJSYS	;DECnet JSYSes
!COMPIL/COMP MON:SCLINK.MAC R:SCLINK	;DECnet session control layer
!COMPIL/COMP MON:DNADLL.MAC R:DNADLL	;Common data link layer interface
!COMPIL/COMP MON:JNTMAN.MAC R:JNTMAN	;TOPS20 specific network management 
!COMPIL/COMP MON:IPNIDV.MAC R:IPNIDV	;Internet Ethernet Driver
!COMPIL/COMP MON:FILNFT.MAC R:FILNFT	;DECNET DAP support
!COMPIL/COMP MON:NRTSRV.MAC R:NRTSRV	;NRT service routines
!COMPIL/COMP MON:CTHSRV.MAC R:CTHSRV	;CTERM terminal support
!
! Funky peripherals
!
!COMPIL/COMP MON:PHYX2.MAC R:PHYX2	;Device dependent code for DX20A/TU70S
!COMPIL/COMP MON:PHYP2.MAC R:PHYP2	;Device dependent code for DX20B/RP20
!COMPIL/COMP MON:CDPSRV.MAC R:CDPSRV	;Card punch service
!COMPIL/COMP MON:CDRSRV.MAC+MON:CDKLDV.MAC R:CDRSRV ;Card reader service
!COMPIL/COMP MON:PTP.MAC R:PTP		;Paper tape punch service
!COMPIL/COMP MON:PTR.MAC R:PTR		;Paper tape reader service
!COMPIL/COMP MON:PLT.MAC R:PLT		;Plotter service
!
! DDT Modules
!
COMPIL/COMP L7:F2MDDT.MAC+L7:DDT.MAC R:MDDT ;MDDT
COMPIL/COMP L7:F2KDDT.MAC+L7:DDT.MAC R:KDDT ;KDDT
!
! Dump-on-BUGCHK
COMPIL/COMP MON:DOB.MAC R:DOB
!
! Stanford monitor modules
!
COMPIL/COMP MON:GTDOM.MAC R:GTDOM	;GTDOM% support
COMPIL/COMP MON:PHYMEI.MAC R:PHYMEI	;MEIS device driver
COMPIL/COMP MON:ENET.MAC R:ENET		;Ethernet support of PUP and IP
COMPIL/COMP MON:ARP.MAC R:ARP		;Address Resolution Protocol
COMPIL/COMP MON:PKOPR.MAC R:PKOPR	;Network Dependent Packet Operations
COMPIL/COMP MON:PUP.MAC R:PUP		;PUP protocol support
COMPIL/COMP MON:PUPNM.MAC R:PUPNM	;More PUP protocol support
COMPIL/COMP MON:PNVSRV.MAC R:PNVSRV	;PUP NVT support
COMPIL/COMP MON:PIPE.MAC R:PIPE		;UNIX-style pipe support (PIP: device)
!
! LOTS-only Modules
!
!COMPIL/COMP MON:NSPTOP.MAC R:NSPTOP	;Decnet topology support
!COMPIL/COMP MON:GTWAA.MAC R:GTWAA	;Allocation system
!
! AN20 Modules
!
COMPIL/COMP MON:IMPANX.MAC R:IMPANX	;IMP driver for AN20
COMPIL/COMP MON:IMPDV.MAC R:IMPDV	;Arpanet IMP Communication Protocols
!
! Site specific storage modules
!
COMPIL/COMP MON:NAMLOT.MAC+MON:VEDIT.MAC+MON:VERSIO.MAC R:VERSIO
COMPIL/COMP MON:PARLOT.MAC+MON:PARNEW.MAC+MON:PARAMS.MAC+MON:STG.MAC R:STG
