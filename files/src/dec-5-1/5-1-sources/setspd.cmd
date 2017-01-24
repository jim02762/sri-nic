!COMMAND FILE FOR OBTAINING ALL FILES RELEVANT TO BUILDING SETSPD
INFORMATION LOGICAL-NAMES

;Files required to build product
COPY FROM-SOURCE:SETSPD.CMD TO-SOURCE:*.*.-1
COPY FROM-SOURCE:SETSPD.CTL TO-SOURCE:*.*.-1
COPY FROM-SOURCE:SETSPD.MAC TO-SOURCE:*.*.-1

;Documentation for product
COPY FROM-SOURCE:SETSPD.TCO TO-DOC:*.*.-1
COPY FROM-SOURCE:SETSPD.DOC TO-DOC:*.*.-1

;Library files used for symbols
;COPY FROM-SUBSYS:MACREL.REL TO-SUBSYS:*.*.-1
;COPY FROM-SUBSYS:SERCOD.REL TO-SUBSYS:*.*.-1
;COPY FROM-SUBSYS:CMD.REL TO-SUBSYS:*.*.-1
;COPY FROM-SUBSYS:MACSYM.UNV TO-SUBSYS:*.*.-1
;COPY FROM-SUBSYS:MONSYM.UNV TO-SUBSYS:*.*.-1
;COPY FROM-SUBSYS:SERCOD.UNV TO-SUBSYS:*.*.-1
;COPY FROM-SUBSYS:CMD.UNV TO-SUBSYS:*.*.-1

;Final product
COPY FROM-SOURCE:5-1-SETSPD.EXE TO-SYSTEM:*.*.-1
