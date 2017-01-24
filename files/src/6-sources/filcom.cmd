!COMMAND FILE FOR OBTAINING ALL FILES RELEVANT TO BUILDING FILCOM
INFORMATION LOGICAL FROM*:
INFORMATION LOGICAL TO*:

;Files required to build product
COPY FROM-SOURCE:FILCOM.CMD TO-SOURCE:*.*.-1
COPY FROM-SOURCE:FILCOM.CTL TO-SOURCE:*.*.-1
COPY FROM-SOURCE:FILCOM.MAC TO-SOURCE:*.*.-1

;Documentation for product
COPY FROM-SOURCE:FILCOM.HLP TO-SUBSYS:*.*.-1
COPY FROM-SOURCE:FILCOM.DOC TO-DOC:*.*.-1

;Final product
COPY FROM-SOURCE:FILCOM.EXE TO-SUBSYS:*.*.-1
