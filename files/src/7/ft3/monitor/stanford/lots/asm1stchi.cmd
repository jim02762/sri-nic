!
!Prior to compiling anything, ensure that you have the latest versions of
!MACSYM.UNV,MONSYM.UNV and ACTSYM.UNV available via UNV:.
!
COMPILE/COMPILE MON:SYSFLG.MAC+MON:PROLOG.MAC R:PROLOG	;Common monitor definitions
COMPILE/COMPILE MON:GLOBS.CHI/MAC R:GLOBS		;Global symbols
COMPILE/COMPILE MON:NIPAR.MAC R:NIPAR		;Universal for NISRV users
COMPILE/COMPILE MON:ANAUNV.MAC R:ANAUNV		;Universal for ARPANET TCP/IP
COMPILE/COMPILE MON:PHYPAR.MAC R:PHYPAR		;Universal for PHYSIO and like modules
COMPILE/COMPILE MON:SCAPAR.MAC R:SCAPAR		;Universal for SCA
COMPILE/COMPILE MON:MSCPAR.MAC R:MSCPAR		;Universal for MSCP drivers and servers
COMPILE/COMPILE MON:D36PAR.MAC R:D36PAR		;DECnet symbols
COMPILE/COMPILE MON:SCPAR.MAC R:SCPAR		;Session control symbols
COMPILE/COMPILE MON:CTERMD.MAC R:CTERMD		;CTERM symbols
COMPILE/COMPILE MON:TTYDEF.MAC R:TTYDEF		;Teletype service symbols
COMPILE/COMPILE MON:SERCOD.MAC R:SERCOD		;Codes and fields for SYSERR facility
COMPILE/COMPILE MON:ENQPAR.MAC R:ENQPAR		;Cluster-wide ENQ support
COMPILE/COMPILE MON:CLUPAR.MAC R:CLUPAR		;KLUDGR symbols
COMPILE/COMPILE MON:CFSPAR.MAC R:CFSPAR		;CFS symbols
!
! Stanford Universal libraries
!
COMPILE/COMPILE MON:PUPSYM.MAC R:PUPSYM		;PUP symbols
COMPILE/COMPILE MON:DOMSYM.MAC R:DOMSYM		;GTDOM% symbols
!
COMPILE/COMPILE MON:SCHED.MAC R:SCHED		;Scheduler
COMPILE/COMPILE MON:PAGEM.MAC R:PAGEM		;Page management/working set management
COMPILE/COMPILE MON:PAGUTL.MAC R:PAGUTL		;Page management subroutines/utilities
COMPILE/COMPILE MON:TAPE.MAC R:TAPE		;Label handler and record processor
COMPILE/COMPILE MON:COMND.MAC R:COMND		;Command scanner JSYS
COMPILE/COMPILE MON:CRYPT.MAC R:CRYPT		;Encryption routines
COMPILE/COMPILE MON:DATIME.MAC R:DATIME		;Time and date routines
COMPILE/COMPILE MON:DEVICE.MAC R:DEVICE		;Device table (DEVTAB) routines
COMPILE/COMPILE MON:DIRECT.MAC R:DIRECT		;Disk directory management
COMPILE/COMPILE MON:DISC.MAC R:DISC		;Disk file management
COMPILE/COMPILE MON:ENQ.MAC R:ENQ		;ENQ and DEQ JSYS
COMPILE/COMPILE MON:ENQSRV.MAC R:ENQSRV		;Cluster-wide ENQ
COMPILE/COMPILE MON:FESRV.MAC R:FESRV		;Device code for FE devices
COMPILE/COMPILE MON:FILINI.MAC R:FILINI		;File system initialization
COMPILE/COMPILE MON:FILMSC.MAC R:FILMSC		;DTBs, PTY support
COMPILE/COMPILE MON:FORK.MAC R:FORK		;Fork controlling JSYS and functions
COMPILE/COMPILE MON:FREE.MAC R:FREE		;Storage routines
COMPILE/COMPILE MON:FUTILI.MAC R:FUTILI		;Miscellaneous routines for file system
COMPILE/COMPILE MON:GETSAV.MAC R:GETSAV		;Get and save routines
COMPILE/COMPILE MON:GTJFN.MAC R:GTJFN		;GTJFN and GNJFN JSYS
COMPILE/COMPILE MON:IO.MAC R:IO			;Sequential IO routines and JSYSes
COMPILE/COMPILE MON:IPCF.CHI/MAC R:IPCF		;Interprocess communications facility
COMPILE/COMPILE MON:JSYSA.MAC R:JSYSA		;Non-file system JSYSes
COMPILE/COMPILE MON:JSYSF.MAC R:JSYSF		;File system JSYSes
COMPILE/COMPILE MON:JSYSM.MAC R:JSYSM		;MEXEC JSYi
COMPILE/COMPILE MON:LDINIT.MAC R:LDINIT		;Define JSYS dispatch table, mon vers.
COMPILE/COMPILE MON:LINEPR.MAC+MON:LPFEDV.MAC R:LINEPR	;Line printer device driver
COMPILE/COMPILE MON:LOGNAM.MAC R:LOGNAM		;Logical name JSYSes and support
COMPILE/COMPILE MON:LOOKUP.MAC R:LOOKUP		;File name lookup utilities (for GTJFN)
COMPILE/COMPILE MON:MFLIN.MAC R:MFLIN		;Floating point input routines
COMPILE/COMPILE MON:MFLOUT.MAC R:MFLOUT		;Floating point outputl routines
COMPILE/COMPILE MON:POSTLD.MAC R:POSTLD		;Post-loading one-shot init
COMPILE/COMPILE MON:SWPALC.MAC R:SWPALC		;Swapping space allocation
COMPILE/COMPILE MON:SYSERR.MAC R:SYSERR		;SPEAR routines
COMPILE/COMPILE MON:TIMER.MAC R:TIMER		;TIMER JSYS & schedular clock routines
COMPILE/COMPILE MON:SCAMPI.MAC R:SCAMPI		;Systems communications architecture
COMPILE/COMPILE MON:CFSSRV.MAC R:CFSSRV		;Common File System
COMPILE/COMPILE MON:CFSUSR.MAC R:CFSUSR		; "
COMPILE/COMPILE MON:CLUDGR.MAC R:CLUDGR		;KLUDGR
COMPILE/COMPILE MON:CLUFRK.MAC R:CLUFRK		; "
COMPILE/COMPILE MON:PHYKLP.MAC R:PHYKLP		;Device dependent code for KLIPA port
COMPILE/COMPILE MON:SCSJSY.MAC R:SCSJSY		;The SCS% JSYS
COMPILE/COMPILE MON:PHYMSC.MAC R:PHYMSC		;MSCP driver
COMPILE/COMPILE MON:PHYMVR.MAC R:PHYMVR		;MSCP Server
COMPILE/COMPILE MON:APRSRV.MAC R:APRSRV		;Processor-dependent paging
COMPILE/COMPILE MON:DIAG.MAC R:DIAG		;The DIAG JSYS
COMPILE/COMPILE MON:DSKALC.MAC R:DSKALC		;Device independent disk code
COMPILE/COMPILE MON:PHYH2.MAC R:PHYH2		;Channel dependent code for RH20
COMPILE/COMPILE MON:PHYM2.MAC R:PHYM2		;Device dependent code for TM02/TU45
COMPILE/COMPILE MON:PHYM78.MAC R:PHYM78		;Device dependent code for TM78/TU78
COMPILE/COMPILE MON:PHYP4.MAC R:PHYP4		;Device dependent code for RP04 DISKS
COMPILE/COMPILE MON:PHYSIO.MAC R:PHYSIO		;Device independent physical IO
COMPILE/COMPILE MON:MAGTAP.MAC R:MAGTAP		;MTA routines
COMPILE/COMPILE MON:MEXEC.MAC R:MEXEC		;Swappable monitor routines
COMPILE/COMPILE MON:MSTR.MAC R:MSTR		;Mountable structure monitor call
COMPILE/COMPILE MON:DTESRV.MAC R:DTESRV		;DTE support. RSX20F interface
COMPILE/COMPILE MON:IPIPIP.MAC R:IPIPIP		;Arpanet internet protocols
COMPILE/COMPILE MON:IPCIDV.MAC R:IPCIDV		;Internet CI Driver
COMPILE/COMPILE MON:IPFREE.MAC R:IPFREE		;Internet free storage routines
COMPILE/COMPILE MON:TCPTCP.MAC R:TCPTCP		;Arpanet transmission control
COMPILE/COMPILE MON:TCPCRC.MAC R:TCPCRC		;Cyclic redundancy check routines
COMPILE/COMPILE MON:TCPBBN.MAC R:TCPBBN		;BBN TCP JSYS service routines
COMPILE/COMPILE MON:TCPJFN.MAC R:TCPJFN		;DEC JSYS interface for BBN TCP
COMPILE/COMPILE MON:MNETDV.CHI/MAC R:MNETDV		;Multinet software for ARPANET TCP/IP
COMPILE/COMPILE MON:TTYSRV.MAC R:TTYSRV		;Teletype service routines
COMPILE/COMPILE MON:RSXSRV.MAC R:RSXSRV		;Teletype service routines
COMPILE/COMPILE MON:TVTSRV.MAC R:TVTSRV		;Internet terminal service
COMPILE/COMPILE MON:CIDLL.MAC R:CIDLL		;CI data link layer
COMPILE/COMPILE MON:LATSRV.MAC R:LATSRV		;LAT host server
COMPILE/COMPILE MON:D36COM.MAC R:D36COM		;Common routines for DECnet
!
! SC-30M Modules
!
!COMPIL MON:PHYSAI.MAC R:PHYSAI		;SA10 CROCK (MARS ONLY)
!COMPIL MON:PHYC1.MAC R:PHYC1		;IBM DISK DRIVER (MARS ONLY)
!COMPIL MON:PHYSAT.MAC R:PHYSAT		;IBM TAPE DRIVER (MARS ONLY)
!COMPIL MON:PHYFAD.MAC R:PHYFAD		;SMD/CTL DISK DRIVER (MARS ONLY)
!
! DECnet and KLNI modules (the SC-30M has a KLNI)
!
!COMPIL MON:LLINKS.MAC R:LLINKS		;DECnet NSP (ECL) layer
!COMPIL MON:LLMOP.MAC R:LLMOP		;DECnet low level MOP support
!COMPIL MON:TOPS.MAC+MON:NISRV.MAC+MON:PHYKNI.MAC R:NISRV
					;KLNI device driver
!COMPIL MON:NIUSR.MAC R:NIUSR		;NI% JSYS
!COMPIL MON:NTMAN.MAC R:NTMAN		;Network management
!COMPIL MON:ROUTER.MAC R:ROUTER		;DECnet router layer
!COMPIL MON:SCJSYS.MAC R:SCJSYS		;DECnet JSYSes
!COMPIL MON:SCLINK.MAC R:SCLINK		;DECnet session control layer
!COMPIL MON:DNADLL.MAC R:DNADLL		;Common data link layer interface
!COMPIL MON:JNTMAN.MAC R:JNTMAN		;TOPS20 specific network management 
!COMPIL MON:IPNIDV.MAC R:IPNIDV		;Internet Ethernet Driver
!COMPIL MON:FILNFT.MAC R:FILNFT		;DECNET DAP support
!COMPIL MON:NRTSRV.MAC R:NRTSRV		;NRT service routines
!COMPIL MON:CTHSRV.MAC R:CTHSRV		;CTERM terminal support
!
! Funky peripherals
!
!COMPIL MON:PHYX2.MAC R:PHYX2		;Device dependent code for DX20A/TU70S
!COMPIL MON:PHYP2.MAC R:PHYP2		;Device dependent code for DX20B/RP20
!COMPIL MON:CDPSRV.MAC R:CDPSRV		;Card punch service
!COMPIL MON:CDRSRV.MAC+MON:CDKLDV.MAC R:CDRSRV	;Card reader service
!COMPIL MON:PTP.MAC R:PTP		;Paper tape punch service
!COMPIL MON:PTR.MAC R:PTR		;Paper tape reader service
!COMPIL MON:PLT.MAC R:PLT		;Plotter service
!
! DDT Modules
!
COMPILE/COMPILE L7:F2MDDT.MAC+L7:DDT.MAC R:MDDT	;MDDT
COMPILE/COMPILE L7:F2KDDT.MAC+L7:DDT.MAC R:KDDT	;KDDT
!
! Dump-on-BUGCHK
COMPILE/COMPILE MON:DOB.MAC R:DOB
!
! Stanford monitor modules
!
COMPILE/COMPILE MON:GTDOM.MAC R:GTDOM		;GTDOM% support
COMPILE/COMPILE MON:PHYMEI.MAC R:PHYMEI		;MEIS device driver
COMPILE/COMPILE MON:ENET.MAC R:ENET		;Ethernet support of PUP and IP
COMPILE/COMPILE MON:ARP.MAC R:ARP		;Address Resolution Protocol
COMPILE/COMPILE MON:PKOPR.MAC R:PKOPR		;Network Dependent Packet Operations
COMPILE/COMPILE MON:PUP.MAC R:PUP		;PUP protocol support
COMPILE/COMPILE MON:PUPNM.MAC R:PUPNM		;More PUP protocol support
COMPILE/COMPILE MON:PNVSRV.MAC R:PNVSRV		;PUP NVT support
COMPILE/COMPILE MON:PIPE.MAC R:PIPE		;UNIX-style pipe support (PIP: device)
!
! LOTS-only Modules
!
!COMPIL MON:NSPTOP.MAC R:NSPTOP		;Decnet topology support
!COMPIL MON:GTWAA.MAC R:GTWAA		;Allocation system
!
! AN20 Modules
!
COMPILE/COMPILE MON:IMPANX.MAC R:IMPANX		;IMP driver for AN20
COMPILE/COMPILE MON:IMPDV.MAC R:IMPDV		;Arpanet IMP Communication Protocols
!
! Site specific storage modules
!
COMPILE/COMPILE MON:NAMLOT.MAC+MON:VEDIT.MAC+MON:VERSIO.MAC R:VERSIO
COMPILE/COMPILE MON:PARLOT.MAC+MON:PARNEW.MAC+MON:PARAMS.MAC+MON:STG.CHI/MAC R:STG
