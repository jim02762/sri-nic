!COMMAND FILE FOR OBTAINING ALL FILES RELEVANT TO BUILDING MAKRAM
INFORMATION LOGICAL-NAMES FROM*:
INFORMATION LOGICAL-NAMES TO*:

;Files required to build product
COPY FROM-SOURCE:MAKRAM.CMD TO-SOURCE:*.*.-1
COPY FROM-SOURCE:MAKRAM.CTL TO-SOURCE:*.*.-1
COPY FROM-SOURCE:MAKRAM.MAC TO-SOURCE:*.*.-1

;Documentation for product
COPY FROM-SOURCE:MAKRAM.HLP TO-SUBSYS:*.*.-1
COPY FROM-SOURCE:MAKRAM.DOC TO-DOC:*.*.-1

;Final product
COPY FROM-SOURCE:MAKRAM.EXE TO-SUBSYS:*.*.-1
COPY FROM-SOURCE:LP64.RAM TO-SUBSYS:*.*.-1
COPY FROM-SOURCE:LP96.RAM TO-SUBSYS:*.*.-1