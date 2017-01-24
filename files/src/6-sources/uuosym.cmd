!COMMAND FILE FOR OBTAINING ALL FILES RELEVANT TO BUILDING UUOSYM
INFORMATION LOGICAL FROM*:
INFORMATION LOGICAL TO*:

;Files required to build product
COPY FROM-SOURCE:UUOSYM.CMD TO-SOURCE:*.*.-1
COPY FROM-SOURCE:UUOSYM.CTL TO-SOURCE:*.*.-1
COPY FROM-SOURCE:UUOSYM.MAC TO-SOURCE:*.*.-1

;Documentation for product
COPY FROM-SOURCE:UUOSYM.DOC TO-DOC:*.*.-1

;Final product
COPY FROM-SOURCE:UUOSYM.UNV TO-SUBSYS:*.*.-1