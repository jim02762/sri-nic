; UPD ID= 106, SNARK:<6.1.UTILITIES>PTYCON.CMD.3,  26-Mar-85 08:29:02 by DMCDANIEL
!COMMAND FILE FOR OBTAINING ALL FILES RELEVANT TO BUILDING PTYCON
INFORMATION LOGICAL-NAMES FROM*:
INFORMATION LOGICAL-NAMES TO*:

;Files required to build product
COPY FROM-SOURCE:PTYCON.CMD TO-SOURCE:*.*.-1
COPY FROM-SOURCE:PTYCON.CTL TO-SOURCE:*.*.-1
COPY FROM-SOURCE:PTYCON.MAC TO-SOURCE:*.*.-1

;Documentation for product
COPY FROM-HLP:PTYCON.HLP TO-HLP:*.*.-1
COPY FROM-DOC:PTYCON.DOC TO-DOC:*.*.-1

;Final product
COPY FROM-SUBSYS:PTYCON.EXE TO-SUBSYS:*.*.-1
COPY FROM-SOURCE:7-PTYCON.ATO TO-SYSTEM:*.*.-1



