@ENABLE
@diskp 1200
@DEFINE MON: src:<6-1-monitor>
@DEFINE R: MON:
@DEFINE SYS: MON:, SYS:
@DEFINE DSK: DSK:,SYS:
@CONNECT MON:
@TAKE ASMNIC.CMD
@LINK
*@LNKNEW
*@LNKNIC
@RUN MON
@GET MONITR
@START 142
*BUGHLT<HLTADR12B
*BUGCHK<CHKADR11B
*DBUGIP/2
*INTBYP/0
*DBUGSW/0
*EDDTF/0
*^Z
@SAVE MONITR.EXE
@DELETE MON.EXE
@DELETE PARNEW.MAC.0
@CONNECT
