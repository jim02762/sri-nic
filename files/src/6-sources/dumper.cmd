!COMMAND FILE FOR OBTAINING ALL FILES RELEVANT TO BUILDING DUMPER
INFORMATION LOGICAL-NAMES FROM*:
INFORMATION LOGICAL-NAMES TO*:

;Files required to build product
COPY FROM-SOURCE:DUMPER.CMD TO-SOURCE:*.*.-1
COPY FROM-SOURCE:DUMPER.CTL TO-SOURCE:*.*.-1
COPY FROM-SOURCE:ARMAIL.MAC TO-SOURCE:*.*.-1
COPY FROM-SOURCE:DUMPER.MAC TO-SOURCE:*.*.-1

;Documentation for product
COPY FROM-SOURCE:DUMPER.HLP TO-SUBSYS:*.*.-1
COPY FROM-SOURCE:DUMPER.DOC TO-DOC:*.*.-1

;Final product
COPY FROM-SOURCE:ARMAIL.REL TO-SUBSYS:*.*.-1
COPY FROM-SOURCE:DUMPER.EXE TO-SUBSYS:*.*.-1
