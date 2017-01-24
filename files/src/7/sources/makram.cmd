!COMMAND FILE FOR OBTAINING ALL FILES RELEVANT TO BUILDING MAKRAM
INFORMATION LOGICAL-NAMES FROM*:
INFORMATION LOGICAL-NAMES TO*:

;Files required to build product
COPY FROM-SOURCE:MAKRAM.CMD TO-SOURCE:*.*.-1
COPY FROM-SOURCE:MAKRAM.CTL TO-SOURCE:*.*.-1
COPY FROM-SOURCE:MAKRAM.MAC TO-SOURCE:*.*.-1

;Documentation for product
COPY FROM-HLP:MAKRAM.HLP TO-HLP:*.*.-1
COPY FROM-DOC:MAKRAM.DOC TO-DOC:*.*.-1

;Final product
COPY FROM-SUBSYS:MAKRAM.EXE TO-SUBSYS:*.*.-1
COPY FROM-Source:LP64.RAM TO-hlp:*.*.-1
COPY FROM-Source:LP96.RAM TO-hlp:*.*.-1