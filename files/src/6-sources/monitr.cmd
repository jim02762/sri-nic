
INFORMATION LOGICAL FROM*:
INFORMATION LOGICAL TO*:

;Documentation files
COPY FROM-SOURCE:ACJ.MEM TO-DOC:*.*.-1
COPY FROM-SOURCE:BOOT.DOC TO-DOC:*.*.-1
COPY FROM-SOURCE:BOOT.TCO TO-DOC:*.*.-1
COPY FROM-SOURCE:BUGS.MAC TO-SYSTEM:*.*.-1
COPY FROM-SOURCE:BUILD.MEM TO-DOC:*.*.-1
COPY FROM-SOURCE:EAPGMG.MEM TO-DOC:*.*.-1
COPY FROM-SOURCE:TOPS20.BWR TO-DOC:*.*.-1
COPY FROM-SOURCE:TOPS20.BWR TO-SYSTEM:*.*.-1
COPY FROM-SOURCE:TOPS20.DOC TO-DOC:*.*.-1
COPY FROM-SOURCE:TOPS20.DOC TO-SYSTEM:*.*.-1
COPY FROM-SOURCE:TOPS20.TCO TO-DOC:*.*.-1
COPY FROM-SOURCE:UTILITY.TCO TO-DOC:*.*.-1

;Monitor CMD files
COPY FROM-SOURCE:ASEMBL.CMD TO-SOURCE:*.*.-1
COPY FROM-SOURCE:MONITR.CMD TO-SOURCE:*.*.-1

;Monitor CTL files
COPY FROM-SOURCE:LN2060.CTL TO-SOURCE:*.*.-1
COPY FROM-SOURCE:SYSTAP.CTL TO-SOURCE:*.*.-1

;Monitor CCL files
COPY FROM-SOURCE:LNKINI.CCL TO-SOURCE:*.*.-1
COPY FROM-SOURCE:LNKMSX.CCL TO-SOURCE:*.*.-1

;Files required to build product
COPY FROM-SOURCE:N60BIG.MAC TO-SOURCE:*.*.-1
COPY FROM-SOURCE:N60MAX.MAC TO-SOURCE:*.*.-1
COPY FROM-SOURCE:NAMAM0.MAC TO-SOURCE:*.*.-1
COPY FROM-SOURCE:P60BIG.MAC TO-SOURCE:*.*.-1
COPY FROM-SOURCE:P60MAX.MAC TO-SOURCE:*.*.-1
COPY NUL: TO-SOURCE:PARAM0.MAC.-1
COPY FROM-SOURCE:PARAMS.MAC TO-SOURCE:*.*.-1
COPY FROM-SOURCE:STG.MAC TO-SOURCE:*.*.-1
COPY FROM-SOURCE:SYSFLG.MAC TO-SOURCE:*.*.-1
COPY FROM-SOURCE:VERSIO.MAC TO-SOURCE:*.*.-1
COPY FROM-SOURCE:MONDDT.REL TO-SUBSYS:*.*.-1

;Library files used for symbols
COPY FROM-SOURCE:ANAUNV.UNV TO-SUBSYS:*.*.-1
COPY FROM-SOURCE:GLOBS.UNV TO-SUBSYS:*.*.-1
COPY FROM-SOURCE:MSCPAR.UNV TO-SUBSYS:*.*.-1
COPY FROM-SOURCE:NSPPAR.UNV TO-SUBSYS:*.*.-1
COPY FROM-SOURCE:PHYPAR.UNV TO-SUBSYS:*.*.-1
COPY FROM-SOURCE:PROLOG.UNV TO-SUBSYS:*.*.-1
COPY FROM-SOURCE:SCAPAR.UNV TO-SUBSYS:*.*.-1
COPY FROM-SOURCE:SERCOD.UNV TO-SUBSYS:*.*.-1

;Final product
COPY FROM-SOURCE:2060-MONBIG.EXE TO-SYSTEM:*.*.-1
COPY FROM-SOURCE:2060-MONMAX.EXE TO-SYSTEM:*.*.-1
COPY FROM-SOURCE:BOOT.EXB TO-SYSTEM:*.*.-1
COPY FROM-SOURCE:BUGSTRINGS.TXT TO-SYSTEM:*.*.-1
COPY FROM-SOURCE:DXMCA.ADX TO-SUBSYS:*.*.-1
COPY FROM-SOURCE:FEDDT.EXE TO-SYSTEM:*.*.-1
COPY FROM-SOURCE:IPADMP.EXE TO-SYSTEM:*.*.-1
COPY FROM-SOURCE:IPALOD.EXE TO-SYSTEM:*.*.*
COPY FROM-SOURCE:LDINIT.REL TO-SOURCE:*.*.-1
COPY FROM-SOURCE:LN2060.REL TO-SOURCE:*.*.-1
COPY FROM-SOURCE:MTBOOT.EXB TO-SYSTEM:*.*.-1
COPY FROM-SOURCE:RSX20F.MAP TO-SYSTEM:*.*.-1
