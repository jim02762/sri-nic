!COMMAND FILE FOR OBTAINING ALL FILES RELEVANT TO BUILDING MONRD
INFORMATION LOGICAL-NAMES FROM-*:
INFORMATION LOGICAL-NAMES TO-*:

;Files required to build product
COPY FROM-SOURCE:MONRD.CMD TO-SOURCE:MONRD.CMD
COPY FROM-SOURCE:MONRD.CTL TO-SOURCE:MONRD.CTL
COPY FROM-SOURCE:MONRD.MAC TO-SOURCE:MONRD.MAC

;Documentation for product
COPY FROM-SOURCE:MONRD.HLP TO-SUBSYS:MONRD.HLP

;Final product
COPY FROM-SOURCE:MONRD.EXE TO-SUBSYS:MONRD.EXE