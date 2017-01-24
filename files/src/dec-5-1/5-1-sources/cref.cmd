INFORMATION LOGICAL-NAMES

;Files required to build product
COPY FROM-SOURCE:CREF.CMD TO-SOURCE:*.*.-1
COPY FROM-SOURCE:CREF.CTL TO-SOURCE:*.*.-1
COPY FROM-SOURCE:CREF.MAC TO-SOURCE:*.*.-1

;Documentation for product
COPY FROM-SOURCE:CREF.HLP TO-SUBSYS:*.*.-1
COPY FROM-SOURCE:CREF.DOC TO-DOC:*.*.-1

;Library files used for symbols
;COPY FROM-SUBSYS:HELPER.REL TO-SUBSYS:*.*.-1

;Final product
COPY FROM-SUBSYS:CREF.EXE TO-SUBSYS:*.*.-1
