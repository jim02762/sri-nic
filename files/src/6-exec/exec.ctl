@ENABLE
@DEFINE EXEC: SRC:<6-EXEC>
@DEFINE R: EXEC:
@DEFINE SYS: MON:, SYS:
@DEFINE DSK: DSK:,SYS:
@CONNECT EXEC:
@TAKE ASEXEC.CMD
@LINK
*@ASEXEC.CCL
@GET EXEC
@START
*Y
@
