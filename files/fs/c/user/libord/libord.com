C
C LIBORD.COM - DEFINE COMMON BLOCKS AND PARAMETERS FOR LIBORD
C
      IMPLICIT INTEGER (A-Z)
C FILES:
      PARAMETER (RELFIL=21, LSTFIL=22, MICFIL=23)
C Max number of MODULES
      PARAMETER (MODSIZ=1000)
      PARAMETER (SPCENT=1,  SPCCOM=2,  SPCEXT=3,  SPCFIL=4,
     +           SPCEPC=5,  SPCCBC=6,  SPCERC=7,  SPCCHD=8,
     +           SPCCHC=9,  SPCCNM=10, SPCLEV=11)
C Max number of modules to force
      PARAMETER (FRCSIZ=30, FRCCNT=1, FRCCNM=2, FRCMOD=3)
C Max number of ENTRYs
      PARAMETER (ENTSIZ=5000)
      PARAMETER (ENTNAM=1, ENTMOD=2, ENTLEV=3)
C Max number of GLOBAL symbols
      PARAMETER (DATSIZ=20000,CHDSIZ=5000,CHDFLG=1,CHDMOD=2)
C Max number of .REL files on input
      PARAMETER (MAXRLS=100,MODPTR=1,MODCNT=2)
      PARAMETER (BUFSIZ=512,STKSIZ=32000)
      PARAMETER (HWORD="777777)
C
      CHARACTER*20 RELFS(MAXRLS)
      CHARACTER*6 MODNAM(MODSIZ)
      COMMON /STRING/ RELFS, MODNAM
C
      COMMON /STORE/ RELMOD(2,MAXRLS),NRELS,
     1               CB(11,MODSIZ),NMOD,
     2               DATBUF(DATSIZ),DATPTR
      COMMON /CHAIN/ CHDAT(2,CHDSIZ),CHDPTR
      COMMON /ENTABL/ ENTTAB(3,ENTSIZ),NUMENT
      COMMON /FORCEB/ FORCE(3,FRCSIZ),NFORCE
      LOGICAL TOPS20
      COMMON /OPSYS/ TOPS20
      LOGICAL EOFF
      COMMON /BUFF/ EOFF
C
C END OF LIBORD.COM
C
