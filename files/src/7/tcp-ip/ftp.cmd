;
!COMMAND FILE FOR OBTAINING ALL FILES RELEVANT TO BUILDING FTP
;
;INFORMATION LOGICAL-NAMES FROM-*:
;INFORMATION LOGICAL-NAMES TO-*:
;
;Files required to build product
COPY FROM-ARPA:FTP1.MAC TO-SOURCE:
COPY FROM-ARPA:FTP2S.MAC TO-SOURCE:
COPY FROM-ARPA:FTP2U.MAC TO-SOURCE:
COPY FROM-ARPA:FTP4.MAC TO-SOURCE:
COPY FROM-ARPA:FTPSRT.MAC TO-SOURCE:
COPY FROM-ARPA:FTSCTT.MAC TO-SOURCE:
COPY FROM-ARPA:TCPFTP.MAC TO-SOURCE:
COPY FROM-ARPA:TCPSIM.MAC TO-SOURCE:
COPY FROM-source:FTP.CTL TO-SOURCE:
COPY FROM-source:FTP.CMD TO-SOURCE:
;
;Final product
COPY FROM-ARPA:FTP.EXE TO-SUBSYS:
COPY FROM-arpa:FTPSRT.EXE TO-SYSTEM:
COPY FROM-arpa:FTSCTT.EXE TO-SUBSYS: