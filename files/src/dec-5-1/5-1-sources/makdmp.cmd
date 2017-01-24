!COMMAND FILE FOR OBTAINING ALL FILES RELEVANT TO BUILDING MAKDMP
INFORMATION LOGICAL-NAMES

;Files required to build product
COPY (FROM) FROM-SOURCE:MAKDMP.CMD.0 (TO) TO-SOURCE:*.*.-1
COPY (FROM) FROM-SOURCE:MAKDMP.CTL.0 (TO) TO-SOURCE:*.*.-1
COPY (FROM) FROM-SOURCE:MAKDMP.MAC.0 (TO) TO-SOURCE:*.*.-1

;Documentation for product
COPY (FROM) FROM-SOURCE:MAKDMP.TCO.0 (TO) TO-DOC:*.*.-1

;Final product
COPY (FROM) FROM-SOURCE:MAKDMP.EXE.0 (TO) TO-SUBSYS:*.*.-1