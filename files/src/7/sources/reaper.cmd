!COMMAND FILE FOR OBTAINING ALL FILES RELEVANT TO REAPER
INFORMATION LOGICAL-NAMES FROM*:
INFORMATION LOGICAL-NAMES TO*:

;Files required to build product
COPY FROM-SOURCE:REAPER.CMD TO-SOURCE:*.*.-1
COPY FROM-SOURCE:REAPER.CTL TO-SOURCE:*.*.-1
COPY FROM-SOURCE:ARMAIL.MAC TO-SOURCE:*.*.-1
COPY FROM-SOURCE:REAPER.MAC TO-SOURCE:*.*.-1

;Documentation for product
COPY FROM-HLP:REAPER.HLP TO-HLP:*.*.-1
COPY FROM-DOC:REAPER.DOC TO-DOC:*.*.-1

;Final product
COPY FROM-SOURCE:REAPER.EXE TO-SUBSYS:*.*.-1
