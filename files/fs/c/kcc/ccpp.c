/*	CCPP.C - New KCC Preprocessor
**
**	(c) Copyright Ken Harrenstien 1989
**
*/

#ifndef DEBUG_PP
#define DEBUG_PP 1	/* Include debugging printout capability */
#endif

#include "cc.h"
#include "ccchar.h"
#include "cclex.h"
#include <time.h>	/* Needed for __DATE__ and __TIME__ */
#include <string.h>
#include <stdlib.h>	/* malloc, free, atoi */

/* Imported functions used here */
extern SYMBOL *symfind();	/* CCSYM to look up macro or identifier */
extern SYMBOL *symgcreat();	/* CCSYM to create a macro name */
extern SYMBOL *symfnext(),	/* CCSYM */
		*shmacsym();
extern void freesym();		/* CCSYM */
extern long pconst();		/* CCSTMT to parse constant expr */
extern char *estrcpy(), *fstrcpy();	/* CCASMB */
extern int symval();		/* CCASMB */
extern int nextoken();		/* CCLEX */

/* Exported functions */
void ppinit();		/* Initialize the input preprocessor. (CC) */
void ppdefine();	/* Called to initialize predefined macros (CC) */
void passthru();	/* Invoked by -E for simple pass-thru processing (CC)*/
int nextpp();		/* Read next token from input (CCLEX) */
void pushpp();		/* Push back current token (CCLEX) */

/* Internal functions */
static void dotad();
static int nextch(), tchesc(), pushstr();
static void pushch(), bstrpush(), bstrpop();
static int nextrawpp(), scanhwsp(), ppnconst(), ppunknwn();
static void ppsconst(), scancomm();
static int nextmacpp();
static void pushmp(), mtlpush(), mtlpop();
static int findident();
static int mdefinp();

static void directive();
static int d_define(), d_undef(), d_asm(), d_endasm(),
	d_ifdef(), d_if(), d_else(), d_elif(), d_endif(),
	d_include(), d_line(), d_error(), d_pragma();
static int iftest();
static void iffwarn(), ifpush(), ifpopchk();
static void flushcond(), filepush();
static SYMBOL *findmacsym();
static void freemacsym();
static int tskipwsp(), tskiplwsp(), cskiplwsp(), flushtoeol();
static void checkeol();
static int getfile();

/* The main global variables of interest to callers (i.e. CCLEX) are those
** set by nextpp(), as follows:
**
**	curpp - Current token (a tokdef enum)
**	curval - Token value (either unused or a string pointer)
**	curptr - Pointer to corresponding pptok in tokenlist, if any.
**	cursym - Pointer to symbol, if curpp == T_IDENT.  This will have
**			class SC_UNDEF if sym didn't exist previously.
*/

/* Note that most routines operate, or begin to operate, on the current
 * character in "ch", rather than immediately reading the next char.  When
 * a character is completely processed and is not needed any more, nextch()
 * must be called in order to get rid of it and set up a new char for
 * whatever will be next looking at the input.  Occasionally "ch" is
 * set directly for proper "priming".
 * This is to avoid having to call pushch() whenever a token ends.
 */

/* Include file nesting stack - holds saved input file context.
 *	Indexed by inlevel.
 */
static int inlevel;	/* 0 - top level */
static struct {
	FILE	*cptr;	/* file pointer  */
	filename cname;	/* filename      */
	int	cpage;	/* page number   */
	int	cline;	/* line number in page */
	int	cfline;	/* line number in file */
} inc[MAXINCLNEST];

/* #if handling variables.  Arrays are indexed by iflevel. */
static int iflevel,	/* #if-type command nesting level (0 = none) */
    flushing;		/* Set = iflevel when inside failing conditional */
static int ifline[MAXIFLEVEL];	/* Line # that last if/elif/else was on */
static int iffile[MAXIFLEVEL];	/* File # for ditto. 0 for current file, */
				/* -1 for expired file, N for inc[N-1] */
static int iftype[MAXIFLEVEL];	/* iftype[lvl] set to one of the following: */
#define IN_ELSE	0		/* inside an #else, or nothing.  Must be 0 */
#define IN_IF	1		/* inside an #if */
#define IN_ELIF	2		/* inside an #elif */
static char *ifname[] = { "else", "if", "elif" };	/* Indexed by iftype */


static int indirp;	/* Set when handling a directive */
static int inasm;	/* Set when inside assembly passthrough */
static FILE *prepfp;	/* Set to output stream when doing -E */

/* Pre-Processing TokenList definitions */

#ifndef MAXPPTOKS
#define MAXPPTOKS 2000
#endif
#ifndef MAXPOOLSIZE
#define MAXPOOLSIZE 4000
#endif

typedef struct {		/* TokenList descriptor type */
	PPTOK *tl_head;
	PPTOK *tl_tail;
} tlist_t;

static PPTOK *pptptr;		/* Ptr to last allocated token */
static PPTOK pptoks[MAXPPTOKS];	/* Tokens allocated from here */
#define PPTMAX (&pptoks[MAXPPTOKS-1])	/* Highest valid ptr */

#define pptreset() (pptptr = pptoks)	/* Flush all tokens, start over */

#define tokn2p(n) (n)		/* Return ptr, given next-ptr */
#define tokp2n(p) (p)		/* Return next-ptr, given ptr */
#define tokpcre() (++pptptr <= PPTMAX ? pptptr : ppterror())	/* Create */
#define tlpinit(tl,p) ((tl).tl_head=(tl).tl_tail=(p))	/* Init w/ptr to tok */
#define tlzinit(tl) tlpinit(tl,0)		/* Init empty list */
#define tlpcur(tl) ((tl).tl_head)		/* Get ptr to 1st token */
#define tltcur(tl) (*tlpcur(tl))		/* Get 1st token */
#define tlppeek(tl) ((tl).tl_head->pt_nxt)	/* Ptr to next token */
#define tltpeek(tl) (*tlppeek(tl))		/* Peek at next token */
#define tlpskip(tl) ((tl).tl_head=tlppeek(tl))	/* Skip this token */

#define tlpadd(tl,p) (!(tl).tl_head \
	? tlpinit(tl,p) \
	: ((tl).tl_tail = (tl).tl_tail->pt_nxt = (p))) /* Add ptr at tail */
#define tltadd(tl,t) (*tlpadd(tl,tokpcre()) = (t))	/* Add tok at tail */
#define tlpins(tl,p) (!((p)->pt_nxt = (tl).tl_head) \
	? tlpinit(tl,p) \
	: ((tl).tl_head = (p)))		/* Insert ptr at head of list */

#define tllapp(tl,il) ((tl).tl_tail->pt_nxt = tokp2n((il).tl_head), \
			(tl).tl_tail = (il).tl_tail)	/* Append list */
#define tllins(tl,il) ((il).tl_tail->pt_nxt = tokp2n((tl).tl_head), \
			(tl).tl_head = (il).tl_head)	/* Insert list */


/* Various TokenList declarations */
static tlist_t tlfrmac(), tlfrstr(), tlmake(), tlimake(), tlcopy(), tlstrize();
static char *tltostr(), *tltomac();
static PPTOK tokize();
static void tlrawadd();
static void ppcqstr(), ppctstr();
static int pptfput(), tkerr();
static tlist_t getlinetl(), tlwspdel();
static tlist_t asmrefill();

/* PP-Token char pool.  This is reset and the contents flushed whenever
** nextpp() is asked to read a new token at top level, by setting ppcptr NULL.
** Several handy macros are defined to use this pool.
**	ppcreset() - Resets pool, flushes all chars
**	ppcbeg() - Start depositing into pool, returns ptr to start
**	ppcput(c) - Put char into pool, returns c
**	ppclast() - Returns last char put into pool
**	ppclen() - Returns # chars deposited thus far
**	ppcend() - Ends deposit into pool, returns # chars
**			(invokes fatal error if overflowed)
**	ppcbackup() - Backs up over last char, can be used to undo ppcend().
**	ppcsave(st) - Saves state in "st" (type "ppcstate_t")
**	ppcrest(st) - Restores state from "st"
*/
static char *ppcptr = NULL;	/* Ptr into ppcpool */
static int ppcleft;		/* # chars left in ppcpool */
static int ppcocnt;		/* Saved ppcleft for deriving string lens */
typedef struct {		/* State struct for saving above vars */
	char *cptr; int cleft; int cocnt;
} ppcstate_t;
static char ppcpool[MAXPOOLSIZE];
#define ppcreset() (ppcptr = NULL)
#define ppcbeg() (!ppcptr?(ppcocnt=ppcleft=MAXPOOLSIZE-1,(ppcptr=ppcpool)+1) \
			: (ppcocnt=ppcleft, ppcptr+1))
#define ppcput(c) (--ppcleft > 0 ? *++ppcptr = (c) : (c))
#define ppclast() (*ppcptr)
#define ppclen() (ppcocnt - ppcleft)
#define ppcend() (--ppcleft > 0 ? (*++ppcptr = 0, ppclen()-1) : ppcerror())
#define ppcbackup() (++ppcleft, *--ppcptr)
#define ppcsave(st) \
	(void)(st.cptr = ppcptr, st.cleft = ppcleft, st.cocnt = ppcocnt)
#define ppcrest(st) \
	(void)(ppcptr = st.cptr, ppcleft = st.cleft, ppcocnt = st.cocnt)

static int ppcerror();		/* Just invokes efatal(CPOOL) */

/* Raw Tokenizer variables - nextrawpp() */
static int rawpp;		/* Current raw token type from nextrawpp() */
static union pptokval rawval;	/* Current raw token value */
static int rawpplen;		/* Length of token string, if any */
static PPTOK *rawptr;		/* Ptr to current raw pptoken, if any */

/* Macro Tokenizer - nextmacpp() */
static int mactlev = 0;		/* # levels nesting for nextmacpp() input */
static tlist_t mactl;		/* Current tokenlist nextmacpp() is using */
static tlist_t mactls[MAXMACNEST];	/* Stack of input tokenlists */

/* Cooked Tokenizer - nextpp()  (also declared by CCLEX.H)*/
extern int curpp;		/* Current cooked token type from nextpp() */
extern union pptokval curval;	/* Current cooked token value */
static tlist_t curtl;		/* Current cooked token list, if any */
extern PPTOK *curptr;		/* Ptr to current cooked pptoken, if any */
extern SYMBOL *cursym;		/* Ptr to symbol, if token is T_IDENT */

/* Raw character input variables - nextch() */
static int ch;			/* Current char awaiting tokenizer */
#define MAXBKSTRS (MAXINCLNEST+2)	/* Rough guess */
static char *backstr = NULL;	/* If non-NULL, ptr to pushback string */
static int bkstrlev = 0;	/* # of ptrs on saved pushback string stack */
static char *bkstrs[MAXBKSTRS];

#define TCH_ESC '\305'		/* Input string escape char */
#define TCH_EOF 'E'		/* Input string EOF */


/* MACRO DETAILS:
**	A defined macro is stored in the symbol table as a symbol with
** class SC_MACRO.  It has no type and uses these components:
**	Smacptr	- char pointer to the macro body (allocated by malloc)
**	Smacnpar - # of params/arguments (or special value)
**	Smacparlen - # chars at start of body that are actually param names.
**	Smaclen - total # chars in macro body string, not counting final NUL.
** The value of Smacnpar has the following meanings:
**	>= 0	# of arguments in argument list.  0 = mac(), 1 = mac(a), etc.
**	< 0	Special value, one of:
*/
#define MACF_ATOM (-1)	/* Normal atomic, no argument list (i.e. "mac") */
#define MACF_DEFD (-2)	/* "defined" operator.  No body. */
#define MACF_LINE (-3)	/* "__LINE__" macro.  No body. */
#define MACF_FILE (-4)	/* "__FILE__" macro.  No body. */
#define MACF_DATE (-5)	/* "__DATE__" macro.  No body. */
#define MACF_TIME (-6)	/* "__TIME__" macro.  No body. */
#define MACF_STDC (-7)	/* "__STDC__" macro.  No body. */
#define MACF_KCC  (-8)	/* "__COMPILER_KCC__" macro.  No body. */
#define MACF_SYMF (-9)	/* "_KCCsymfnd("file","sym")" macro. No body. */
#define MACF_SYMV (-10)	/* "_KCCsymval("file","sym")" macro. No body. */
/* All special macros other than MACF_ATOM cannot be redefined or
** undefined except by the command-line -U or -D switches.
*/

/* MACRO BODY FORMAT:
**
** Smacptr (if not null) points to the macro body, which consists of
** the tokenized text of the macro, perhaps prefixed by parameter names.
**	Smacptr ->  <"Smacparlen" chars of param-names>
**		    <tokenized text, see below>
**
** The parameter names are only checked during redefinition of a macro
** to see whether the new macro's params have the same spelling (CHOKE BLETCH).
**
** The text is entirely tokenized.  The first char of each token is the
** token type value, such as T_WSP or T_IDENT.  Following chars depend
** entirely on the token type.  There are currently three general types:
**	Simple token: just one char of token type and nothing else.
**	String token: token type is followed by the chars of the string, ending
**		with a zero byte.
**	Param token: the char after the token type is an encoded macro
**		parameter # -- see MAC_ARGOFF.
**
** In all cases, the next char after any of the above begins another token.
** A zero token marks the end of the macro body; this and not Smaclen is
** normally used to stop a scan.  This zero token is not included in the
** Smaclen count.
*/
#define MAC_ARGOFF '0'	/* Number to encode param # with */


/* Macro Frame definitions */
struct macframe {
	SYMBOL *mf_sym;		/* Pointer to macro symbol def */
	int mf_nargs;		/* # args we have */
	int mf_parlen;		/* # chars in param name prefix (bletch) */
	int mf_len;		/* # chars total in macro body string */
	char *mf_body;		/* Ptr to body of macro def */
	union {
	    tlist_t mfp_tls[MAXMARG];	/* Argument token lists (for expand) */
	    char *  mfp_cps[MAXMARG];	/* Parameter name strs (for define) */
	} mf_p;
	int mf_used[MAXMARG];	/* # times each arg is invoked */
};
#define mf_argtl mf_p.mfp_tls
#define mf_parcp mf_p.mfp_cps

#if 0
static nhidemacs = 0;		/* # macros in hideset */
#endif
static SYMBOL *hidemacs[MAXMACNEST];	/* Used by hspush() and mishid() */

static int maclevel;	/* Macro expansion level (used???) */

static char defcdmy;			/* Needed if not using "define" */
static char *defcsname = &defcdmy;	/* Ptr to "defined" macro sym name */

static int tadset;		/* True if date/time strings are set */
static char datestr[14] = "\"Jun 07 1989\"";	/* __DATE__ string */
static char timestr[11] = "\"01:23:45\"";	/* __TIME__ string */

static SYMBOL *mdefstr(), *mdefsym();
static int mexptop(), margs();
static tlist_t mexpand(), mexplim(), mexpsym(), msubst(), mpaste();
static int hspush(), tkhide(), mishid();

#if DEBUG_PP
static int debpp = 0;
static FILE *fpp = stderr;
static int debppt = 1;
static void pmacframe(), pmactl(), tlfput(), tkfput();
static char *plevindent();
#endif

/* PPINIT() - Invoke to initialize preprocessor at start of file scan.
**	Called once for each file compiled.
*/
void
ppinit()
{
    /* Set globals */
    eof = 0;
    tline = 0;
    fline = page = line = 1;

    /* Set variables local to preprocessor */
    ppcreset();
    pptreset();
    inlevel = iflevel = flushing = inasm = indirp = maclevel = 0;
    iftype[0] = 0;		/* Just in case */
    tadset = 0;			/* Date/time strings not set */
    erptr = errlin;		/* Init pointer to error-context buffer */
    erpleft = ERRLSIZE;		/* Set countdown of chars left in errlin */
    memset(erptr, 0, erpleft);	/* Clear the circular buffer */
    pushstr("\n");		/* Prime input with EOL, set up 1st char! */

    /* Enter special macro pre-definitions into symbol table. */
    mdefstr("__COMPILER_KCC__", MACF_KCC, NULL);
    mdefstr("__LINE__",		MACF_LINE, NULL);
    mdefstr("__FILE__",		MACF_FILE, NULL);
    if (clevel >= CLEV_CARM) {
	mdefstr("__DATE__", MACF_DATE, NULL);
	mdefstr("__TIME__", MACF_TIME, NULL);
	/* "defined" is a bit more special.  Need to remember ptr to
	** 1st char of the symbol name, so it can be turned on and off.
	*/
	defcsname = &(mdefstr("defined", MACF_DEFD, NULL)->Sname[0]);
	*defcsname = SPC_MACDEF;	/* Hide sym by smashing 1st char */
    }
    if (clevel >= CLEV_STDC) {		/* When we're fully ready */
	mdefstr("__STDC__", MACF_STDC, "1");
    }
    if (clevkcc) {
	mdefstr("_KCCsymfnd", MACF_SYMF, NULL);
	mdefstr("_KCCsymval", MACF_SYMV, NULL);
    }
}

/* DOTAD - Initialize datestr and timestr for __DATE__ and __TIME__.
**	This is only invoked if one of those macros is seen; otherwise,
**	the overhead is avoided.
*/
static void
dotad()
{
    register char *cp;
    time_t utad;

    if (time(&utad) == (time_t)-1) {
	warn("Cannot get date/time, using %s %s", timestr, datestr);
	return;			/* Leave both strings alone */
    }
    cp = ctime(&utad);		/* Get pointer to ascii date and time */

    /* Now have "Dow Mon dd hh:mm:ss yyyy\n\0" */
    /*		 012345678901234567890123 4 5  */
    strncpy(datestr+1, cp+4, 6);	/* Copy "Mon dd" */
    strncpy(datestr+8, cp+20, 4);	/* Copy "yyyy" */
    strncpy(timestr+1, cp+11, 8);	/* Copy "hh:mm:ss" */
    tadset = 1;				/* Strings now set! */
}

/* PPDEFINE(cruft) - Process startup #undefs and #defines requested by the
**	-U and -D switches in the main CC loop.
**	We assume the syntax has already been checked by chkmacname() in CC.
*/
void
ppdefine(unum, utab, dnum, dtab)
int unum, dnum;		/* # of strings in table */
char **utab, **dtab;	/* Address of char-pointer array */
{
    int savch;
    char *cp;
    SYMBOL *sym;

    /* First handle all -U undefinitions... */
    for ( ; --unum >= 0; utab++) {
	if (sym = findmacsym(*utab))	/* Look up the macro symbol */
	    freemacsym(sym);		/* Found it, flush it! */
	else note("Macro in -U%s doesn't exist", *utab);
    }

    /* Now handle all -D definitions. */
    for ( ; --dnum >= 0; dtab++) {
	cp = *dtab;			/* Get this -D string */
	while (*++cp && *cp != '=') ;	/* Scan for start of body if any */
	savch = *cp;			/* Remember terminator char */
	*cp = '\0';			/* Tie name off in case of '=' */
	if (sym = findmacsym(*dtab)) {	/* See if already defined */
	    advise("Redefining macro: -D%s", *dtab);	/* Ugh! */
	    freemacsym(sym);
	}
	mdefstr(*dtab, MACF_ATOM,	/* Define object-like macro */
		savch ? cp+1 : "1");	/* with "1" if no body. */
	*cp = savch;			/* Restore zapped char if any */
    }
}

/* PASSTHRU(fp) - Pass through text to file
**	Used only by -E (i.e. prepf is set)
**
** General strategy:
**	Attempts to do a fast scan through the input whenever possible, just
** reading and outputting on the character level.
** It necessarily has to simulate some of what nextrawpp() and nextpp()
** do.
**	(nextrawpp: handle comments, string-type literals)
**	(nextpp: handle directives, macro expansion)
**
** When it encounters a directive or macro, it punts and asks nextpp() to
** handle it, whereupon it just translates tokens until it determines
** that things are back at top level again.  This return of control may
** be tricky.
*/
static void pass_ident(), pass_num(), pass_hwsp(), pass_line(), pass_comm();
static int pass_str();
static FILE *passfp;

void
passthru(fp)
FILE *fp;
{
    prepfp = fp;		/* Set for benefit of ppasm() */
    passfp = fp;

#if DEBUG_PP
    if (debpp && debppt) {		/* Do trivial passthru */
	while (nextpp() != T_EOF) {
	    pptreset(); ppcreset();
	    pptfput(tlpcur(tlmake(curpp, curval)), fp);
	}
	return;
    }
#endif

    /* Note at start of file, ch should always contain \n as "first" char */
    for (;;) switch (ch) {	/* Scan starting with current char */
    case EOF:			/* Done when hit EOF */
	 return;

    /* Check for whitespace other than new-line */
    case '\r':			/* Include CR here */
    case '\v':			/* Vert tab */
    case '\f':			/* Ditto FF */
    case '\t':			/* Horiz tab */
    case ' ':			/* Space */
	if (keepcmts) {		/* If keeping comments, */
	    putc(ch, fp);	/* just pass it all */
	    nextch();
	} else pass_hwsp();	/* Flushing, so try to be clever */
	continue;

    /* Newline needs special handling (maybe directives, etc) */
    case '\n':
	pass_line(0);
	continue;

    /* Check for possible start of comment */
    case '/':
	if (nextch() == '*')
	    pass_comm();
	else putc('/', fp);
	continue;

    default:
	if (iscsymf(ch)) {	/* If start of identifier, check for macro */
	    pass_ident(fp);
	    continue;
	}
	putc(ch, fp);		/* Normal char, pass it on */
	nextch();		/* Get next */
	continue;

    case '.':			/* '.' may start a pp-number */
	putc('.', fp);
	if (!isdigit(nextch()))
	    continue;		/* Nope, handle whatever it is */
	/* Is pp-number, drop thru to handle it */

    case '0': case '1': case '2': case '3': case '4':
    case '5': case '6': case '7': case '8': case '9':
	pass_num();
	continue;

	/* Pass through string constants.  Note that character constants
	** (e.g. 'a') are handled a little differently because they shouldn't
	** be longer than the largest possible char constant.
	*/
    case '\'':	pass_str(tgcpw+2);	continue;	/* Char constant */
    case '"':	pass_str(0);		continue;	/* String literal */

    case '`':			/* Quoted identifier (maybe) */
	if (clevkcc) {		/* If KCC extensions allowed, */
	    pass_str(0);	/* parse like string! */
	    continue;
	}
	putc(ch, fp);		/* Normal char, pass it on */
	nextch();		/* Get next */
	continue;

    }				/* End of loop */
}

/* PASS_IDENT - auxiliary for passthru() and d_asm() to parse an
**	identifier and either pass it along or expand it if it's a macro.
**	Current char is the first char of the identifier.
**	Returns with current char the 1st thing after ident (or expansion).
*/
static void
pass_ident(fp)
FILE *fp;
{
    SYMBOL *sym;
    register PPTOK *p;
    register char *cp;

    cp = ppcbeg();
    do { ppcput(ch);		/* Gobble up ident starting with current ch */
    } while (iscsym(nextch()));
    (void)ppcend();		/* Tie off so can look it up */

    if (!(sym = findmacsym(cp))	/* If not a macro, */
      || !mexptop(sym, 0)) {	/* or can't expand it, */
	fputs(cp, fp);		/* just output the identifier. */
	ppcreset();		/* Clean up token char pool */
	return;
    }
    /* Expanded macro!
    ** Since mexptop() leaves a tokenlist in curtl, we grab that and
    ** translate it into a string that is then output, with special
    ** quoting if in #asm.
    */
    if (!inasm)
	for (; p = tlpcur(curtl); tlpskip(curtl))
	    pptfput(p, fp);
    else {			/* in #asm, must do special quoting */
	curtl = tlstrize(curtl);	/* Turn into giant string literal */
	cp = curtl.tl_head->pt_val.cp;	/* Get ptr to start */
	cp[strlen(cp)-1] = '\0';	/* Chop '"' off end */
	fputs(cp+1, fp);		/* And skip '"' at beg */
    }
    tlzinit(curtl);	/* Ensure curtl flushed out */
    ppcreset();		/* Also be safe and flush stg used */
    pptreset();
}

/* PASS_NUM - auxiliary for PASSTHRU() to pass a PP-number.
**	Returns with delimiting char still in CH, not yet output.
*/
static void
pass_num()
{
    register int i;

    for (;;) {
	putc((i = ch), passfp);	/* Pass char, remember it */
	switch (nextch()) {
	case '+':
	case '-':		/* Sign chars are part of number, */
	    if (toupper(i) != 'E')	/* if prev char was E */
		return;		/* Oops, gotta stop */
	case '.':
	    break;
	default:
	    if (!iscsym(ch))
		return;
	    break;
	}
    }
}

/* PASS_STR - auxiliary for PASSTHRU() to parse a string-type literal
**	Returns with delimiting char still in CH, not yet output.
**	Return value is 0 if EOF encountered, else non-zero.
*/
static int
pass_str(cnt)
int cnt;		/* If non-zero, max # chars of string to read */
{
    int delim = ch;		/* Delimiter char */

    putc(ch, passfp);		/* Send initial delimiter */
    while (nextch() != EOF
      && ch != '\n'
      && --cnt != 0) {		/* Note test is != not > */
	putc(ch, passfp);
	if (ch == delim) {	/* If that was end of string, */
	    nextch();		/* set up next char and return. */
	    return;
	}
	if (ch == '\\')		/* Handle backslash */
	    putc(nextch(), passfp);	/* by quoting next char */
    }

    /* Either EOF, or char length exceeded, or illegal char (newline).
    ** For now, we don't complain about anything but EOF.
    */
    if (ch == EOF)
	error("Unexpected EOF within %s",
		(  delim == '\"' ? "string literal"
		: (delim == '\'' ? "char constant"
				 : "quoted identifier")));
}

/* PASS_HWSP - auxiliary for PASSTHRU() to scan horiz whitespace NOT at
**	start of a line, and not being kept.  Just reduce to one space,
**	unless hit EOL in which case do nothing.
**	Returns with delimiting char still in CH, not yet output.
*/
static void
pass_hwsp()
{
    for (;;) {
	while (ischwsp(nextch()));	/* Flush all horiz wsp */
	if (ch == '/') {
	    if (nextch() == '*') {	/* Start of comment? */
		scancomm();		/* Flush it!  Leaves last '/' in ch */
		continue;
	    } else {
		fputs(" /", passfp);
		return;
	    }
	}
	break;
    }
    if (ch != '\n')
	putc(' ', passfp);
}

/* PASS_NL - auxiliary for PASSTHRU() to handle start of a line.
**	Must check for directives, etc.
**	If keeping comments, pass on all whitespace & comments, up to
**		first non-whitespace.
**	If not keeping comments, store all whitespace in temp buffer
**		(using 1 space for each comment) up to 1st non-wsp.
**	If 1st non-wsp is "#" then invoke directive processing.
**	If 1st non-wsp is EOL just re-invoke without outputting an EOL.
**	Returns with delimiting char still in CH, not yet output.
*/
static void
pass_line(suppress)
{
    char wspbuf[120];	/* # chars of leading whitespace to save */
    register char *cp = wspbuf;
    register int cnt = sizeof(wspbuf)-2;

    if (!suppress)
	putc('\n', passfp);		/* First must end any current line */
    if (!keepcmts || inasm) {
	for (;;) {			/* Flush whitespace and comments */
	    switch (nextch()) {
	    case '/':
		if (nextch() != '*') {
		    pushch(ch);
		    ch = '/';
	    default:
		    break;
		}
		pass_comm();
		/* Drop thru to output single space */
	    case ' ': case '\t':
	    case '\r': case '\v': case '\f':
		if (--cnt > 0) *cp++ = ch;
		continue;
	    case '\n':
		pass_line(++suppress);	/* Tail recurse, don't output EOL */
		return;
	    }
	    *cp = 0;			/* Tie off */
	    break;
	}
    } else {			/* Keeping comments */
	for (;;) {			/* Flush whitespace and comments */
	    if (ischwsp(nextch()))
		putc(ch, passfp);
	    else if (ch != '/')
		break;
	    else if (nextch() == '*')
		pass_comm();
	    else {
		pushch(ch);
		ch = '/';
		break;
	    }
	}
    }

    if (ch == '#') {
	nextch();		/* Must move past it to set up... */
	directive();		/* Process directive! */
	while (inasm && nextpp() != T_EOF) {	/* If in #asm, do hack */
	    pptreset(); ppcreset();
	    pptfput(tlpcur(tlmake(curpp, curval)), passfp);
	}
	if (ch != EOF)		/* Sigh, must put back */
	    pushch(ch);		/* the 1st char of beg of line */
	pass_line(++suppress);		/* Then can tail recurse! */
	return;
    } else if (!keepcmts)
	fputs(wspbuf, passfp);	/* Output saved whitespace up to here */
}

/* PASS_COMM - auxiliary for PASSTHRU() to scan over a comment.
**	Current char is the '*' starting comment.
**	Returns with a space in CH; next input char will be 1st char
**	after the '/' that ended comment.
*/
static void
pass_comm()
{
    if (!keepcmts) {
	scancomm();		/* Flush the comment! */
    } else {
	/* Comment skip for -E when retaining comments (-C) */
	fputs("/*", passfp);		/* Pass comment start */
	nextch();
	for (;;) {			/* until we break */
	    putc(ch, passfp);		/* send char off */
	    if (ch != '*') nextch();	/* find a star */
	    else if (nextch() == '/') {	/* and a slash to terminate */
		putc('/', passfp);
		break;			/* Stop loop */ 
	    }
	    if (eof) {			/* Also stop if input gone */
		error("Unexpected EOF in comment");
		break;
	    }
	}
    }

    ch = ' ';		/* Pretend current char now a space */
}

#if 0

nextch() 	Phase 1, 2 - produce source chars & logical lines
			(handles trigraphs, \-newlines)
nextrawpp()	Phase 3 - produce raw PP tokens
			(handles comments, flushes WSP)
nextmacpp()	Phase 3.5 - used to redirect source of raw tokens
			during macro expansion
nextpp()	Phase 4 - produce clean expanded PP tokens
			(handles directives, macro expansion, flushes EOLs)
nextoken()	Phase 5, 6, 7 - Produce C tokens from clean PP tokens
			(handles char escapes, string concatenation, token
				conversion & constant parsing)

There are 4 types of scanning, differentiated by the different end results
of the scan.  Each of them invokes at some point the types below it.
	A. Toplevel (language) tokenizing	(Phase 1-7)
	B. Macro/directive (preproc) tokenizing	(Phase 1-4)
	C. Passthru scanning (for -E and #asm)	(Phase 1-4)
	D. Passover scanning (for #if skipping)	(Phase 1-3)
#endif

/* NEXTCH() - Get next character.
**	Implements Translation Phase 1 and 2.
**	Handles trigraphs and quoted newlines ('\\' '\n').
**
**	Because the value returned by nextch() must be pushable by pushch(),
**	and because we cannot call pushch() twice in a row on file input
**	(otherwise STDIO's ungetc() complains), we have to divert input
**	to come from a string whenever this routine does need to call pushch().
**	This is why the calls to pushstr() exist.
**
**	Note: implement IESC escape char similar to MACESC so can
**	easily insert special tokens (like temporary EOF) into input.
*/
static int
nextch()
{
    register int prevch = ch;		/* Remember previous char */

    /* First check for pushed-back string */
    if (backstr) {			/* Pushback string exists? */
	if (ch = *backstr++)		/* Yes, are there more chars? */
	    return (ch != TCH_ESC)	/* Yes, is this a special escape? */
		? ch			/* Nope, just return char. */
	        : (ch = tchesc());	/* Aha!  Handle escape stuff! */
	bstrpop();			/* End of a pushback string, pop it */
	ch = prevch;			/* Ensure "prev chr" isn't NUL */
	return nextch();		/* and try for a new char */
    }

    /* Just get normal input char */
    ch = getc(in);

    /* Add char to small circular buffer for possible error messages */
    *erptr++ = ch;		/* Add to saved input line. */
    if (--erpleft <= 0) {	/* If reached end of buffer, */
	erptr = errlin;		/* wrap back around. */
	erpleft = ERRLSIZE;
    }

    switch (ch) {
    case EOF:			/* End Of File on input */
				/* Do a couple of checks to verify */
	if (ferror(in))
	    error("I/O error detected while reading file %s", inpfname);
	else if (!feof(in))
	    int_error("nextch: spurious EOF");

	if (prevch != '\n'	/* Was last char in file an EOL? */
	  && prevch != EOF) {
	    warn("File does not end with EOL (\\n)");	/* Nope */
	    return pushstr("\n");	/* Attempt graceful termination */
	}				/* by providing EOL as last char. */

	if (inlevel > 0) {		/* Drop level.  If more, pop input. */
	    ifpopchk(inlevel);		/* Do balanced conditional check */
	    fclose(in);			/* Close this file */
	    --inlevel;
	    in = inc[inlevel].cptr;	/* then set vars from popped level */
	    page = inc[inlevel].cpage;
	    line = inc[inlevel].cline;
	    fline = inc[inlevel].cfline;
	    strcpy(inpfname, inc[inlevel].cname);
#if DEBUG_PP
	    if (debpp) {
		fprintf(fpp, "#include %d: restored \"%s\", new char %#o\n",
			inlevel+1, inpfname, nextch());
		return ch;
	    }
#endif
	    return nextch();		/* try for another char */
	}

	/* EOF at top level (main input file).  We DON'T close the
	** stream at this point, so that it's OK to call this routine again.
	** Some preproc/parsing routines want to just punt on EOF and let a
	** higher level take care of it.  The CC mainline fcloses the stream.
	*/
	if (eof) break;		/* If already seen EOF, needn't redo stuff. */
	eof = 1;		/* Flag end of file at top level. */
	if (iflevel)		/* Error if preprocessor unbalanced */
	    ifpopchk(0);	/* Spit out helpful error message */
	break;			/* Return EOF char */

    case '?':			/* Goddam fucked-up trigraph hackery */
    {	static int skipflg;	/* TRUE if skipped a '?' */
	static int intrig = 0;	/* TRUE if in this code already */

	if (clevel < CLEV_STDC)	/* Only if STDC */
	    break;
	if (intrig) break;	/* If already scanning, just return char. */
	++intrig;		/* Say scanning trigraph! */
	if (!skipflg		/* If we didn't skip a '?' already, */
	  && nextch() != '?') {	/* OK to read next char.  Two in a row? */
	    pushch(ch);			/* Nope, push back peeked-at char */
	    intrig = 0;			/* No longer scanning */
	    return pushstr("?");	/* Return original q-mark */
	}
	nextch();		/* Got two '?'s in row!  Scan for third... */
	intrig = 0;		/* No longer scanning */
	skipflg = 0;		/* Skip hackery done */
	switch (ch) {		/* Dispatch on 3rd char! */
	    case '=':	ch = '#'; break;
	    case '(':	ch = '['; break;
	    case '/':	ch = '\\'; break;
	    case ')':	ch = ']'; break;
	    case '\'':	ch = '^'; break;
	    case '<':	ch = '{'; break;
	    case '!':	ch = '|'; break;
	    case '>':	ch = '}'; break;
	    case '-':	ch = '~'; break;
	    default:		/* Not a trigraph, but simple pushback. */
		pushch(ch);	/* Make use of our 1-char file backup */
		return pushstr("??");	/* and OK to use string for other 2 */

	    case '?':		/* ARGH BARF not a trigraph, big screwup. */
		/* This is a screw because on the next call we have to
		** make sure that re-examination starts again -- just pushing
		** a string back won't work right.  We also can't count on
		** having more than 1 char of file backup!
		** The solution is to realize that we'll come here again when
		** the pushch'd '?' is read from getc(), so we don't try to
		** push back the middle '?' at all, and instead set a flag
		** that says it was "skipped"; when we do come back, we'll
		** check that flag and do the right thing.
		*/
		pushch(ch);		/* Push back 3rd '?' */
		skipflg = 1;		/* Say 2nd is skipped */
		return pushstr("?");	/* Return 1st */
	    }
	}
	break;

    case '\\':
	if (isceol(nextch())) {	/* Check next char */
	    ch = 0;		/* Quoted EOL is ignored totally, to extent */
	    return nextch();	/* of forgetting last char was EOL! */
	}
	pushch(ch);		/* otherwise put char back */
	return pushstr("\\");	/* and set up a pushch-able input */
				/* and return backslash */

    case '\f':			/* Form-feed */
	page++;			/* Starts new page */
	line = 1;		/* at first line */
	break;
    case '\r':
    case '\v':
    case '\n':
	line++;			/* new line, same page */
	fline++;
	tline++;
	break;
    }
    return ch;
}

/* TCHESC() - Handle token char escape.
**	backstr is set, and char it points to says what to do.
**	Returns char to be given to caller of nextch().
*/
static int
tchesc()
{
    int i;
    switch (i = *backstr++) {	/* Handle it */
	default:
	    int_error("tchesc: token escape char %d='%c'", i, i);

	case TCH_ESC:		/* Quoting escape char */
	    return i;

	case TCH_EOF:
	    backstr -= 2;	/* Bump back to point at TCH_ESC */
	    return EOF;		/* and return EOF as char */
    }
}


/* SINBEG(cp) - Make nextch() return input from given string.
** SINEND() - Stop using string input, restore previous source.
**	Note that nextch() will return EOF when the string input is done,
**	instead of popping input and continuing.
**	SINEND() must be called to proceed further.
** These routines are recursive, but could be simplified by forbidding
** recursion and just saving/restoring CH rather than calling pushch/nextch.
*/
static char eofstr[] = { TCH_ESC, TCH_EOF };

static void
sinbeg(cp)
char *cp;
{
    pushch(ch);		/* Save current char (since not tokenized yet) */
    bstrpush(eofstr);	/* Put EOF on end of input string */
    pushstr(cp);	/* and set up string for input! */
}
static void
sinend()
{
    while (backstr != eofstr) {		/* We should have hit string EOF... */
	int_error("sinend: leftover input");
	bstrpop();			/* Will get error if overpop */
    }
    bstrpop();		/* Take off EOF string, restore previous source */
    nextch();		/* Set up next char for tokenizer */
}

/* PUSHCH - Push back char for nextch()
** PUSHSTR - Push back string, sets up 1st char as current char
** BSTRPUSH - Push back string for ditto (save any current string)
** BSTRPOP - Pop pushback string, restore previous string
*/
static void
pushch(c)
int c;
{
    if (backstr) {
	backstr--;		/* pushed string input, back up over it */
	if(c != *backstr)
	    int_error("pushch: bad backup char");
	return;
    }

    /* File input, back up over that.
    ** Note that errlin and t/f/line only need to be fixed up for file input.
    */
    if (c != ungetc(c, in))
	int_error("pushch: ungetc failed: %o", c);
    if (isceol(c)) {
	line--;				/* dont lose track of line count */
	fline--;
	tline--;
    }
    /* Back up over char of saved context */
    if (erptr == errlin) {		/* If at start of buffer */
	erptr = errlin + ERRLSIZE;	/* Wrap back to end */
	erpleft = 0;
    }
    *--erptr = '\0';		/* Back up and zap what we previously stored */
    ++erpleft;
}

static int
pushstr(cp)
char *cp;
{
    bstrpush(cp);
    return nextch();
}

static void
bstrpush(cp)
char *cp;
{
    if (bkstrlev >= MAXBKSTRS-1) {
	int_error("bstrpush: bkstrs overflow");
	bkstrlev = MAXBKSTRS-1;
    } else {
	bkstrs[bkstrlev++] = backstr;
	backstr = cp;
    }
}

static void
bstrpop()
{
    if (--bkstrlev < 0) {
	int_error("bstrpop: bkstrs underflow");
	backstr = NULL, bkstrlev = 0;
    } else backstr = bkstrs[bkstrlev];
}

/* NEXTRAWPP()	Phase 3 - produce raw PP tokens
**			(handles comments, flushes WSP)
**
*/
static int
nextrawpp()
{
    rawval.i = 0;
    switch (ch) {

    case EOF:
	return rawpp = T_EOF;

    /* Check for "bad" horiz whitespace (may give error msg) */
    case '\r':			/* Include CR here for now */
    case '\v':			/* Vert tab */
    case '\f':			/* Ditto FF */
	pushch(ch);		/* Ensure scanhwsp will see this char */
	/* Drop thru to call scanner */

    /* Check for "good" horiz whitespace */
    case '\t':			/* Horiz tab */
    case ' ':			/* Space */
	return scanhwsp();

    case '\n':
	rawpp = T_EOL;
	break;

    case '0': case '1': case '2': case '3': case '4':
    case '5': case '6': case '7': case '8': case '9':
	return ppnconst(0);		/* Numerical constant */

    case '\'':
	ppsconst(0);			/* Char constant */
	return rawpp = T_CCONST;

    case '"':
	ppsconst(0);			/* String constant */
	return rawpp = T_SCONST;

    case '.':
	if (isdigit(nextch()))		/* If followed by digit, */
	    return ppnconst('.');	/* is pp-number */
	if (ch != '.')
	    return rawpp = Q_DOT;	/* Not num constant, say op */
	if (nextch() != '.') {		/* Ellipsis "..."? */
	    pushch(ch);			/* Nope, push it back */
	    ch = '.';			/* And restore prev char */
	    return rawpp = Q_DOT;	/* Settle for just "." */
	}
	rawpp = T_ELPSIS;		/* ... */
	break;

#define retchk(chr,no,yes) { \
	if (nextch() != chr) \
	    return rawpp = no; \
	nextch(); \
	return rawpp = yes; \
	}

    case '#':	retchk('#', T_SHARP, T_SHARP2)		/* #  and ## */
    case '=':	retchk('=', Q_ASGN, Q_EQUAL)		/* =  and == */
    case '!':	retchk('=', Q_NOT, Q_NEQ)		/* !  and != */
    case '*':	retchk('=', Q_MPLY, Q_ASMPLY)		/* *  and *= */
    case '%':	retchk('=', Q_MOD, Q_ASMOD)		/* %  and %= */
    case '^':	retchk('=', Q_XORT, Q_ASXOR)		/* ^  and ^= */
    case '/':	/* Special, to check for comments! */
	switch (nextch()) {
	default:	    return rawpp = Q_DIV;	/* /  */
	case '=': nextch(); return rawpp = Q_ASDIV;	/* /= */
	case '*': scancomm(); return scanhwsp();	/* Start comment! */
	}

#define retchk2(ch1,ch2,no,yes1,yes2) \
	switch (nextch()) { \
	case ch1: nextch(); return rawpp = yes1; \
	case ch2: nextch(); return rawpp = yes2; \
	default:	    return rawpp = no; \
	}

    case '|':
	retchk2('=','|', Q_OR, Q_ASOR, Q_LOR)		/* |  and |= and || */

    case '&':
	retchk2('=','&', Q_ANDT, Q_ASAND, Q_LAND)	/* &  and &= and && */

    case '+':
	retchk2('=','+', Q_PLUS, Q_ASPLUS, T_INC)	/* +  and += and ++ */

    case '-':
	switch (nextch()) {
	    case '-':	rawpp = T_DEC; break;	/* -- */
	    case '=':	rawpp = Q_ASMINUS;break;/* -= */
	    case '>':	rawpp = Q_MEMBER; break;/* -> */
	    default: return rawpp = Q_MINUS;	/* -  */
	}
	break;

    case '>':
	switch (nextch()) {
	    default: return rawpp = Q_GREAT;		/* >  */
	    case '=':	rawpp = Q_GEQ; break;		/* >= */
	    case '>':	retchk('=', Q_RSHFT, Q_ASRSH)	/* >> and >>= */
	}
	break;

    case '<':
	switch (nextch()) {
	    default: return rawpp = Q_LESS;		/* <  */
	    case '=':	rawpp = Q_LEQ; break;		/* <= */
	    case '<':	retchk('=', Q_LSHFT, Q_ASLSH)	/* << and <<= */
	}
	break;

    case '(': rawpp = T_LPAREN; break;
    case ')': rawpp = T_RPAREN;	break;
    case ',': rawpp = T_COMMA;	break;
    case ':': rawpp = T_COLON;	break;
    case ';': rawpp = T_SCOLON; break;
    case '?': rawpp = Q_QUERY;	break;
    case '[': rawpp = T_LBRACK; break;
    case ']': rawpp = T_RBRACK; break;
    case '{': rawpp = T_LBRACE; break;
    case '}': rawpp = T_RBRACE; break;
    case '~': rawpp = Q_COMPL;	break;

    case '`':			/* KCC extension: identifier quoter */
	if (clevkcc) {		/* If extensions in effect, */
	    ppsconst(0);	/* parse like string literal! */
	    return rawpp = T_IDENT;
	}
	return ppunknwn();	/* Else return unknown token */

    default:
	if (!iscsymf(ch))	/* Can char be start of identifier? */
	    return ppunknwn();	/* Nope, return unknown token */

	/* Handle identifier! */
	rawval.cp = ppcbeg();	/* Assume will be ident, harmless if not */
	if (ch == 'L') {	/* Possible "wide char" indicator? (BARF!!) */
	    switch (nextch()) {
		case '\'':	ppsconst('L'); return rawpp = T_CCONST;
		case '"':	ppsconst('L'); return rawpp = T_SCONST;
	    }
	    ppcput('L');	/* Not a wide char, recover from peekahead */
	    if (!iscsym(ch))	/* Was it just "L"?  Barf, barf */
		return rawpplen = ppcend(), rawpp = T_IDENT;
	}
	do { ppcput(ch);	/* Gobble up identifier */
	} while (iscsym(nextch()));
	rawpplen = ppcend();
	return rawpp = T_IDENT;
    }				/* End of switch(ch) */

    nextch();			/* Done, set up next char after this token */
    return rawpp;
}

/* SCANHWSP - gobbles all horiz whitespace starting with current char, and
**	returns a T_WSP token.
*/
static int
scanhwsp()
{
    for (;;) {
	while (iscppwsp(nextch())) ;	/* Skip all valid PP whitespace */
	switch (ch) {
	case '\r':
	    if (nextch() == '\n') {	/* Peek ahead */
		note("Stray '\\r' seen, ignoring");
		break;
	    } else {
		pushch(ch);
		ch = '\r';	/* put back and drop through */
	    }
	case '\v':
	case '\f':
	    if (indirp) {	/* Processing directive between # and EOL? */
		error("invalid whitespace in directive: '\\%#o'", ch);
		nextch();
		return rawpp = T_EOL;
	    }
	    continue;
	case '/':		/* Possible comment! */
	    if (nextch() == '*') {
		scancomm();	/* Yep, flush comment */
		continue;	/* and go get next char after comment */
	    }
	    /* Ugh, not a comment, must back up and leave '/' there */
	    pushch(ch);		/* Push '*' back */
	    ch = '/';
	    break;
	}
	break;
    }
    return rawpp = T_WSP;
}

/* SCANCOMM - Skips over a comment; current char must be the '*' opening
**	a comment.  On return, current char is the '/' closing the
**	comment (or EOF).
*/
static void
scancomm()
{
    for (;;) {
	switch (nextch()) {
	    case EOF: 
		error("Unexpected EOF in comment");
		break;			/* Get out of loop */
	    case '/':			/* Special helpful check  */
		do {
		    if (nextch() == '*') {
			advise("Nested comment");
			break;
		    }
		} while (ch == '/');
		if (ch != '*') continue;
		/* Drop thru to handle the * we just got */

	    case '*':
		while (nextch() == '*') ;	/* Skip all '*'s */
		if (ch == '/')
		    break;			/* End of comment, stop! */
	    default:
		continue;			/* Not ended yet */
	}
	break;			/* Break from switch is break from loop */
    }
}

/* Various preprocessor token parsing routines. */

/* PPNCONST - Parse a pp-number, starting with char in "ch", unless
**	arg is non-zero in which case arg is the 1st char, "ch" the 2nd.
**	This only happens if the first char was '.', ie a floating constant.
*/
static int
ppnconst(ch1)
{
    static int hexconst;
    hexconst = 0;		/* Set kludge flag */
    rawval.cp = ppcbeg();	/* Get ptr into char pool */
    if (ch1) ppcput(ch1), rawpp = T_FCONST;	/* Aha, float const */
    else rawpp = T_ICONST;	/* Assume integer until detect otherwise */
    ppcput(ch);
    for (;; ppcput(ch)) {
	switch (nextch()) {
	case 'x':
	case 'X':		/* Remember if hex constant */
	    if (ppclen() == 1 && ppclast() == '0')
		++hexconst;
	    continue;
	case 'E':
	case 'e':			/* 'E' means float const, */
	    if (!hexconst)		/* unless already hex const! */
	case '.':
		rawpp = T_FCONST;	/* Remember float const */
	    continue;
	case '-':
	case '+':		/* If prev char not 'E' or 'e', stop now */
	    if (toupper(ppclast()) != 'E')
		break;
	    continue;
	default:
	    if (!iscsym(ch))	/* Any identifier char (BARF BARF) */
		break;
	    continue;
	}
	break;			/* Break from switch is break from loop */
    }
    rawpplen = ppcend();	/* Done with string */
    return rawpp;		/* Return either T_ICONST or T_FCONST */
}

/* PPSCONST - Parse a string literal or char constant, starting with char
**	in "ch", unless
**	arg is non-zero in which case arg is the 1st char, "ch" the 2nd.
**	"ch" will always contain '\"' or '\'' to indicate type of constant.
**	Note no token value is set or returned; the caller must do this.
*/
static void
ppsconst(ch1)
{
    int delim = ch;		/* Remember delimiter we're using */

    rawval.cp = ppcbeg();	/* Get ptr into char pool */
    if (ch1) ppcput(ch1);
    ppcput(ch);
    for (;; ppcput(ch)) {
	switch (nextch()) {
	case EOF:
	case '\n':
	    break;
	case '\\':			/* Escape (just treat as quoter) */
	    ppcput(ch);
	    switch (nextch()) {
	    case EOF:
	    case '\n':	break;
	    default:	continue;
	    }
	    break;
	default:
	    if (ch != delim)
		continue;
	    ppcput(delim);		/* Succeeded! */
	    rawpplen = ppcend();	/* Done with string */
	    nextch();			/* Advance past delimiter */
	    return;			/* Done, return */
	}
	break;			/* Break from switch is break from loop */
    }

    /* Stopped because hit erroneous char.  Fix up and barf about it. */
    ppcput(delim);		/* Ensure token is well-formed */
    rawpplen = ppcend();	/* Finish off string */

    error("%s in %s",
	(ch=='\n' ? "EOL" : (ch==EOF ? "EOF" : "Illegal char")),
	(delim=='\'' ? "char constant"
		: (delim=='\"' ? "string literal"
		: "quoted identifier")));
}


/* PPUNKNWN - "Parse" the unknown char in "ch" into a T_UNKNWN token.
*/
static int
ppunknwn()
{
    rawval.cp = ppcbeg();	/* Get ptr into char pool */
    ppcput(ch);
    nextch();			/* Consume it, get next */
    rawpplen = ppcend();	/* Done with string */
    return rawpp = T_UNKNWN;
}


static PPTOK *
ppterror()
{
    efatal("Preprocessor token table overflow");
}

/* Translation Phase 4 - directive & macro expansion handling
**	If a current token list exists (curtl), uses that; all tokens on
**	that list are "cooked" and no longer subject to macro expansion.
**	Returns curpp after setting all current stuff.
*/
int
nextpp()
{
    if (curptr = curtl.tl_head) {	/* If using token list, */
	curpp = curptr->pt_typ;		/* consume first token on it */
	curval = curptr->pt_val;
	if (tlpskip(curtl) == NULL) {
	    /* Token list ran out.  Clean up for next call. */
	    tlzinit(curtl);		/* No active cooked token list */
	    pptreset();			/* Free all tokens (curptr still OK) */
	    if (inasm)			/* If in #asm, refill token list */
		return curtl = asmrefill(), nextpp();	
	}
	return (curpp != T_IDENT) ? curpp : findident();
    }

    /* Get a new token from input */
    ppcreset();				/* Free all token string storage */
    if (nextrawpp() == T_EOL) {		/* At EOL must start directive scan */
	while (tskiplwsp()==T_SHARP) {	/* Get 1st non-wsp token */
	    directive();		/* Handle directive! */
	    if (curtl.tl_head)		/* If it set up a cooked list, */
		return nextpp();	/* get input from that. */
	}
    }
    curval = rawval;
    return ((curpp = rawpp) != T_IDENT) ? curpp : findident();
}

/* PUSHPP() - push back current token.
**	So far, only needed by one call in CCLEX.
*/
void
pushpp()
{
    if (curptr)			/* If current token is from list, */
	tlpins(curtl, curptr);	/* backup is trivial! */
    else    /* If current token not from a list, must fake one up -- barf. */
	curtl = tlmake(curpp, curval);	/* Make a token list with this */
}

/* FINDIDENT - auxiliary for NEXTPP that checks for macro expansion at
**	top level.
*/
static int
findident()
{
    register char *cp = curval.cp;

    if (*cp == SPC_IDQUOT) {		/* Special quoted ident? */
	cursym = NULL;			/* Just punt to CCLEX */
	return curpp;
    }

    /* See if this symbol is already defined as a macro or C sym. */
    /* Note that if curptr is set, token came from cooked tokenlist and so
    ** is not to be expanded.
    */
    cursym = symfind(cp, 1);	/* Find sym or create global symbol! */
    if (cursym->Sclass == SC_MACRO) {
	if (!curptr && mexptop(cursym, 0))	/* Is macro! OK to expand? */
	    return nextpp();		/* Yes, return cooked tokens!*/
	    
	/* Sym is macro, but not being expanded, so search again to find
	** the C symbol that the macro was shadowing.
	** This is tricky since the search has to be continued from AFTER
	** the point where the macro symbol exists.
	** Even trickier is the requirement that, if no
	** existing symbol is found, we must create
	** a new global symbol which comes AFTER the macro symbol.
	*/
	if (!(cursym = symfnext(cursym))) {	/* Find next sym.  If none, */
	    cursym = shmacsym(symgcreat(cp));	/* create shadow sym */
	}
    }
    return curpp;
}

/* FINDMACSYM - Find macro name symbol if one exists
*/
static SYMBOL *
findmacsym(id)
char *id;
{   SYMBOL *macsym;

    if (macsym = symfind(id, 0)) {	/* Scan for macro or identifier */
	if (macsym->Sclass == SC_MACRO)	/* Found symbol, see if macro */
	    return macsym;		/* Yup, return the pointer */
	else --(macsym->Srefs);	/* Compensate for spurious symfind ref */
    }
    return NULL;
}

/* NEXTMACPP() - Token input for macro expansion, which is called in place
**	of nextrawpp() so input can easily be redirected to token lists.
**	"rawptr" is set if the token is a pptok.
**	NOTE that the returned token is no longer needed since the
**	list pointer has been bumped prior to return, so it is OK to
**	mung the token (assuming nothing else needs the overall list).
**	The exception is T_EOF, which leaves the list pointer alone so that
**	all further calls will return T_EOF until a mtlpop() is done.
*/
static int
nextmacpp()
{
    if (rawptr = mactl.tl_head) {	/* If using token list, */
	rawval = rawptr->pt_val;	/* get from list */
	if (((rawpp = rawptr->pt_typ) != T_EOF)	/* If not EOF, */
	  && (tlpskip(mactl) == NULL)) {	/* set up for next call */
	    mtlpop();			/* List ran out, pop it off */
	}
	return rawpp;
    }
    /* No token list, now emulate nextpp() without directive processing */
    if (curptr = curtl.tl_head) {	/* If using token list, */
	rawptr = curptr;
	rawpp = curpp = curptr->pt_typ;	/* Consume first token on it */
	rawval = curval = curptr->pt_val;
	if (tlpskip(curtl) == NULL) {
	    /* Token list ran out.  Clean up for next call. */
	    tlzinit(curtl);		/* No active cooked token list */
	}
	return curpp;
    }
    /* Get new token from file input */
    return nextrawpp();
}

/* PUSHMP() - Push current token back for nextmacpp().
*/
static void
pushmp()
{
    if (rawptr)	tlpins(mactl, rawptr);
    else pushpp();
}

/* MTLPUSH(tl) - Push a token list on stack for nextmacpp() to read from.
*/
static void
mtlpush(tl)
tlist_t tl;
{
    if (mactlev >= MAXMACNEST-1) {
	int_error("mtlpush: mactls overflow");
    } else {
	mactls[mactlev++] = mactl;
	mactl = tl;
    }
}

/* MTLPOP() - Pop off an exhausted token list
*/
static void
mtlpop()
{
    if (--mactlev < 0) {
	int_error("mtlpop: mactls underflow");
	mactlev = 0, mactl.tl_head = NULL;
    } else
	mactl = mactls[mactlev];
}

/* Auxiliary token handling routines */

/* TLTOMAC(tl,cp) - Convert token list to macro body string
**	Returns updated ptr to end of string
*/
static char *
tltomac(tl,cp)
tlist_t tl;
char *cp;
{
    register int i;
    register PPTOK *p;

    for (p = tlpcur(tl); p; p = p->pt_nxt) {
	if ((i = p->pt_typ) && i < NTOKDEFS) {
	    *cp++ = i;			/* Always stick token type in */
	    if (!tokstr[i]) switch (i) {	/* Token not op or punct? */
		case T_MACARG:
		case T_MACSTR:
		case T_MACINS:		/* Value is param # */
		    *cp++ = p->pt_val.i + MAC_ARGOFF;
		case T_MACCAT:
		    break;
		default:		/* Assume rest of string is token */
		    cp = estrcpy(cp, p->pt_val.cp);
		    ++cp;		/* Move over NUL char */
		    break;
	    }
	} else tkerr("tltomac", i);
    }
    *cp++ = '\0';		/* Add final terminator to whole thing */
    return cp;
}


/* TLFRMAC(cp) - Convert macro body string to token list
**	Returns token list.  List will be empty if string is NULL or "".
*/
static tlist_t
tlfrmac(cp)
char *cp;
{
    tlist_t tl;
    register int i;
    static PPTOK zpptok;
    PPTOK pptok;

    tlzinit(tl);			/* Init to zero */
    if (!cp || !*cp)
	return tl;
    while (i = *cp++) {		/* Stop when see zero token */
	if (i < NTOKDEFS) {
	    pptok = zpptok;
	    pptok.pt_typ = i;		/* Stick in token # */
	    if (!tokstr[i]) switch(i) {	/* Token not an op or punct? */
		case T_MACARG:
		case T_MACSTR:
		case T_MACINS:
		    pptok.pt_val.i = *cp++ - MAC_ARGOFF; /* Value is param # */
		case T_MACCAT:
		    break;
		default:	/* Assume rest of string is token */
		    pptok.pt_val.cp = cp;	/* Remember ptr to start */
		    if (*cp) while (*++cp);	/* Skip over */
		    break;
	    }
	    tltadd(tl, pptok);	/* Add to end of list */
	} else tkerr("tltomac", i);
    }		
    return tl;
}

/* TLTOSTR(tl,cp,n) - Convert token list to char string
**	Only writes up to a max of N chars, plus 1 additional NUL.
**	Returns updated ptr to the NUL at end of string.
*/
static char *
tltostr(tl,cp,n)
tlist_t tl;
char *cp;
{
    register int i;
    register char *str;
    for (; tlpcur(tl); tlpskip(tl)) {
	if ((i = tlpcur(tl)->pt_typ) < NTOKDEFS) {
	    if (!(str = tokstr[i]))
		str = tlpcur(tl)->pt_val.cp;
	    if (!str) {
		tkerr("tltostr", i);
		break;
	    }
	    if ((i = strlen(str)) <= n) {
		cp = estrcpy(cp, str);
		n -= i;
	    } else {
		*cp = 0;
		strncat(cp, str, n);
		cp += n;
		break;
	    }	
	} else tkerr("tltostr", i);
    }
    return cp;
}

/* TLFRSTR(cp) - Convert string to token list
**	Returns token list.
*/
static tlist_t
tlfrstr(cp)
char *cp;
{
    tlist_t tl;

    tlzinit(tl);
    sinbeg(cp);		/* Set up input from this string */
    while (nextrawpp() != T_EOF)
	tltadd(tl, tokize());
    sinend();		/* Done, restore previous input */
    return tl;
}

/* TLIMAKE(typ, val) - Make a tokenlist consisting of just one T_ICONST
**	token, with the given value.  String is expressed in terms of
**	the given base (current choices are 0 for octal, 1 decimal)
*/
static tlist_t
tlimake(val, baseflg)
int val;
{
    tlist_t tl;
    static PPTOK itok = { T_ICONST };
    char *cp;

    if (ppcleft < (TGSIZ_WORD/3)+2) {	/* If might overflow buffer, */
	ppcleft = -1, (void)ppcend();	/* trigger fatal error msg now */
    }
    *(tl.tl_head = tl.tl_tail = tokpcre()) = itok;
    cp = ppcbeg();
    if (baseflg && val >= 0)		/* Deposit num string in char pool */
	sprintf(cp, "%d", val);		/* Decimal */
    else sprintf(cp, "%#o", val);	/* Octal */
    tl.tl_head->pt_val.cp = cp;
    ppcleft -= (val = strlen(cp)+1);	/* Update char pool vars */
    ppcptr += val;
    return tl;
}


/* TOKIZE() - Make current raw token into a pptok.
*/
static PPTOK
tokize()
{
    static PPTOK ztok;	/* Zero pptok, for initialization */
    PPTOK tok;
    tok = ztok;
    tok.pt_typ = rawpp;		/* Token type */
    tok.pt_val = rawval;	/* Token value */
    return tok;
}

/* TLRAWADD(&tl) - Make current raw token into a pptok at tail of specified list.
*/
static void
tlrawadd(atl)
tlist_t *atl;
{
    static PPTOK ztok;	/* Zero pptok, for initialization */
    PPTOK tok;
    tok = ztok;
    tok.pt_typ = rawpp;		/* Token type */
    tok.pt_val = rawval;	/* Token value */
    tltadd(*atl,tok);
}

/* TLCOPY(tl) - Make copy of a tokenlist.
*/
static tlist_t
tlcopy(il)
tlist_t il;
{
    tlist_t ol;
    PPTOK *p;

    tlzinit(ol);		/* Set OL to empty list */
    for (; tlpcur(il); tlpskip(il)) {
	*(p = tokpcre()) = tltcur(il);	/* Get copy of pptok */
	p->pt_nxt = 0;		/* Ensure it doesn't point to anything */
	tlpadd(ol, p);		/* Add onto list */
    }
    return ol;
}

/* TLSTRIZE(tl) - Make a single string-literal token from a tokenlist.
**	If the list was empty, a null-string literal is returned.
*/
static tlist_t
tlstrize(tl)
tlist_t tl;
{
    char *cp = ppcbeg();	/* Start deposit into token char pool */

    ppcput('"');
    for (; tlpcur(tl); tlpskip(tl))
	switch (tlpcur(tl)->pt_typ) {
	    case T_SCONST:	/* These have to be handled specially */
	    case T_CCONST:
		ppcqstr(tlpcur(tl)->pt_val.cp);
		break;
	    default:
		ppctstr(tlpcur(tl));
	}
    ppcput('"');
    (void) ppcend();
    return tlmake(T_SCONST, cp);
}

/* PPTFPUT(p, fp) - Output token's string.
*/
static int
pptfput(p, fp)
register PPTOK *p;
FILE *fp;
{
    register char *cp;
    if (p->pt_typ < NTOKDEFS
      && ((cp = tokstr[p->pt_typ])
	|| (cp = p->pt_val.cp)))
	    return fputs(cp, fp);
    tkerr("pptfput", p->pt_typ);
    return EOF;
}

/* SLTOSTR(p, cp, i) - Copy string-literal token to string literal.
**	Observes specified limit on length of string.
**	Returns pointer to end of string (null char)
*/
static char *
sltostr(p, cp, max)
PPTOK *p;
char *cp;
{
    register char *frm = p->pt_val.cp;
    register int c;

    while (--max > 0) {
	switch (c = *++frm) {
	case '\\':
	    *cp++ = *++frm;	/* For now, don't hack escapes, just quote */
	    continue;
	case '\"':
	    if (*++frm)
	case 0:
		int_error("slttostr: bad lit");
	    break;
	default:
	    *cp++ = c;
	    continue;
	}
	break;
    }
    *cp = 0;
    return cp;
}

/* Routines for PPC stuff (PP char pool) */

/* PPCQSTR(cp) - Deposit string in token char pool, quoting anything
**	that would cause trouble for a string literal (" and \)
*/
static void
ppcqstr(cp)
register char *cp;
{
    --cp;
    for (;;) {
	switch (*++cp) {
	    case 0: return;
	    case '"':
	    case '\\': ppcput('\\'); break;
	}
	(void)ppcput(*cp);
    }
}

/* PPCTSTR(p) - Deposit token's string in token char pool, except for
**	terminating null.
*/
static void
ppctstr(p)
register PPTOK *p;
{
    register char *cp;
    if (p->pt_typ < NTOKDEFS) {
	if (!(cp = tokstr[p->pt_typ]))
	    cp = p->pt_val.cp;
	if (!cp) tkerr("ppctstr", p->pt_typ);
	--cp;
	while (*++cp)
	    (void)ppcput(*cp);
    } else tkerr("ppctstr", p->pt_typ);
}

static int
tkerr(rtn, i)
char *rtn;
{
    int_error("%s: bad token %Q", rtn, i);
}

static int
ppcerror()
{
    efatal("Preprocessor token char pool overflow");
}

/* MEXPTOP() - Expand a macro invocation at top level.
**	Takes input from nextmacpp(), which can be either a tokenlist or
**	file input, and inserts resulting token list into curtl.
*/
static int
mexptop(sym, hs)
SYMBOL *sym;
{
    tlist_t tl;

    /* Special check.  If fn-like macro, there must be a '('
    ** as next token or we mustn't expand it.  Gross hack needed here.
    */
    if (sym->Smacnpar >= 0) {	/* Function-like macro? */
	if (cskiplwsp() != '(')	/* Do special check for left-paren */
	    return 0;		/* Say macro not expanded */
    }
    /* OK to expand, do internal check that input source is correct */
    if (curtl.tl_head || mactl.tl_head)
	int_error("mexptop: not toplev");

    tl = mexpsym(sym, hs);	/* Expand macro! */
    if (tl.tl_head) {		/* May expand to empty list... */
	if (curtl.tl_head)
	    tllapp(tl, curtl);	/* Append old input list to new one! */
	curtl = tl;		/* Start reading from new input list */
    }
    return 1;
}

/* MPEEKPAR() - Returns TRUE if next token will be a T_LPAREN, but without
**	actually reading it.  This is needed because toplevel stuff
**	really wants to avoid gobbling a token, if possible.
*/
static int
mpeekpar()
{
    PPTOK *p;
    if (p = mactl.tl_head) {
	if (p->pt_typ == T_LPAREN) return 1;
	if (p->pt_typ != T_WSP) return 0;
	if (p = p->pt_nxt)
	    return (p->pt_typ == T_LPAREN);
    }
    /* No tokenlist input, or is going to run out.  Check raw input chars. */
    return (cskiplwsp() == '(');
}

/* MEXPSYM(sym, hs) - Expand macro identified by symbol ptr.
**	Input is taken from nextmacpp(), and next token will be the
**	first token after the macro identifier that invoked us.
**	Reads arguments and completely expands the macro, returning
**	a tokenlist of the results.
*/
static tlist_t
mexpsym(sym, hs)
SYMBOL *sym;
{
    tlist_t tl, tl2;
    struct macframe mf;		/* Current macro frame */
    int i, parens, symv;
    char *cp1, *cp2;

#if DEBUG_PP
    if (debpp)
	fprintf(fpp,"mexpsym(%#o->\"%s\", %d)\n", sym, sym->Sname, hs);
#endif

    tlzinit(tl);
    if (sym->Sflags & SF_MACEXP) {	/* This sym already being expanded? */
	if (clevel < CLEV_ANSI)		/* Give error unless ANSI. */
	    error("Recursive macro expansion: %s", sym->Sname);
	return tl;			/* Then just ignore it. */
    }

    /* Check for exceeding macro nesting depth.  If exceeded, we complain
    ** and ignore this expansion attempt, flushing the macro args if any.
    */
    if (maclevel >= MAXMACNEST-1) {
	error("Macro nesting depth exceeded: %s", sym->Sname);
	(void) margs((tlist_t *)NULL, -1, sym->Smacnpar); /* Flush args */
	return tl;			/* Empty list */
    }

    if ((mf.mf_nargs = sym->Smacnpar) < 0) {	/* Special macro type? */
	/* Special macro!  Handle it... */
	switch (mf.mf_nargs) {
	    case MACF_ATOM:	/* Simple case, normal macro without arglist */
	    case MACF_STDC:
		mf.mf_body = sym->Smacptr;
		break;		/* Get out and return substituted stuff */

	    case MACF_KCC:	/* __COMPILER_KCC__ */
		{
		    static char verstr[40];
		    if (!verstr[0])
			sprintf(verstr, "\"KCC-%d.%d(c%dl%d)\"",
					cverdist, cverkcc, cvercode, cverlib);
		    return tlmake(T_SCONST, verstr);
		}
	    case MACF_LINE:	/* __LINE__ */
		return tlimake(fline, 10);	/* Return a T_ICONST list */

	    case MACF_FILE:	/* __FILE__ */
		{
		    char *cp = ppcbeg();
		    ppcput('"'); ppcqstr(inpfname); ppcput('"');
		    (void) ppcend();
		    return tlmake(T_SCONST, cp);
		}
	    case MACF_DATE:	/* __DATE__ */
		if (!tadset) dotad();
		return tlmake(T_SCONST, datestr);

	    case MACF_TIME:	/* __TIME__ */
		if (!tadset) dotad();
		return tlmake(T_SCONST, timestr);

	    case MACF_DEFD:	/* "defined" operator */
		/* We allow either "defined NAME" or "defined(NAME)" as per
		** H&S 3.5.5.  Note that input had better not be expanded.
		*/
		while (nextmacpp() == T_WSP) ;	/* Flush any whitespace */
		parens = 0;
		if (rawpp == T_LPAREN) {
		    parens++;
		    while (nextmacpp() == T_WSP);
		}
		if (rawpp != T_IDENT) {
		    error("Bad arg to \"defined\" operator");
		    pushmp();			/* Re-read bad token */
		    return tl;			/* Empty list */
		}
		tl = tlmake(T_ICONST,		/* Expand into true or false */
			(findmacsym(rawval.cp) ? "1" : "0"));
		if (parens) {
		    while (nextmacpp() == T_WSP) ;	/* Skip more blanks */
		    if (rawpp != T_RPAREN) {
			error("Missing ')' for \"defined\" operator");
			pushmp();		/* Re-read bad token */
		    }
		}
		return tl;

	    case MACF_SYMF: if (1) symv = 0;	/* Set flag 0 for existence, */
				else
	    case MACF_SYMV: symv = 1;		/* 1 for value */
		/* Do common code for _KCCsymfnd and _KCCsymval */
		i = margs(&mf.mf_argtl[0], 2, 2);	/* Parse args */
		if (i == 2) {
		    tl = tlwspdel(mexplim(mf.mf_argtl[0], hs), 1);
		    tl2 = tlwspdel(mexplim(mf.mf_argtl[1], hs), 1);
		}
		if (i != 2
		  || tlpcur(tl)->pt_typ != T_SCONST
		  || tlpcur(tl)->pt_nxt
		  || tlpcur(tl2)->pt_typ != T_SCONST
		  || tlpcur(tl2)->pt_nxt) {
		    error("Args to \"_KCCsym%s\" must be two string literals",
			symv? "val" : "fnd");
		    return tlmake(T_ICONST, "0");	/* Return 0 if err */
		} else {
		    char sbuf[200];		/* Arbitrary big size */
		    cp1 = sbuf;			/* Must copy string lits */
		    cp2 = sltostr(tlpcur(tl), sbuf, (int)sizeof(sbuf))+1;
		    (void) sltostr(tlpcur(tl2), cp2, (int)sizeof(sbuf)-(cp2-sbuf));
		    return tlimake(symval(cp1, cp2, symv), 0);
		}

	    default:
		int_error("mexpsym: bad mac val: %d", mf.mf_nargs);
		return tl;
	}
    } else {			/* Macro expects an arg list */
	/* Get ptr to macro body, skipping over idiotic params at front */
	mf.mf_body = sym->Smacptr + sym->Smacparlen;
	i = margs(&mf.mf_argtl[0], mf.mf_nargs, mf.mf_nargs); /* Parse args */

	/* Complain if not exactly the right number of args.  Sigh. */
	if (mf.mf_nargs != i) {
	    error("Wrong number of macro args - %d expected, %d seen",
			mf.mf_nargs, i);
	    if (i < 0) i = 0;		/* Handle case of MACF_ATOM */
	    while (i < mf.mf_nargs)	/* Ensure arg table filled out */
		mf.mf_argtl[i++] = tl;	/* so no refs to wild ptrs */
	}
    }

    /* Have body and args, now turn it into a tokenlist */
    maclevel++;			/* Is this really necessary? */
    mf.mf_sym = sym;
    tl = msubst(&mf, hs);	/* Do it and return! */
    tl = mexpand(tl, hspush(sym, hs));
#if 0
    tl = tlhide(tl, hspush(sym, hs));	/* Apply hideset to all tokens */
#endif
    --maclevel;
    return tl;
}

/* MARGS() - Gobble arguments for macro, from nextmacpp().
**	On entry, opening left-paren hasn't yet been read.
**	Returns # of args seen: -1 if no open paren, 0 if no args,
**	else # of args (some may be empty).
**	On return, current token will be either T_RPAREN, T_EOF, or
**	(for an atomic macro) whatever was seen instead of an open-paren,
**	pushed on the mactl stack.
*/
static int
margs(tabptr, maxsto, nexpected)
tlist_t *tabptr;		/* Pointer to array of tlists */
int maxsto;			/* Max # of args to store in array */
int nexpected;			/* # of args we expect to parse */
{
    int nargs;			/* # args parsed */
    int plev;
    tlist_t tl;			/* Token list for current arg */
    PPTOK *prevlast;		/* Remember ptr to previous last */

    /* Allow whitespace (plus EOL) between name and arglist. */
    while (nextmacpp() == T_WSP || rawpp == T_EOL);
    if (rawpp != T_LPAREN) {		/* Any args there? */
	pushmp();			/* No, must put token back */
	return -1;			/* and say no arglist at all. */
    }

    /* Now loop, parsing args */
    nargs = 0;
    plev = 1;			/* Start with 1 left-paren already seen */
    tlzinit(tl);		/* Init current tokenlist to nothing */
    prevlast = NULL;
    while (plev > 0) {
	switch (nextmacpp()) {
	    case T_EOL:
		/* Handle newline in arg list scan.
		** Standard def of C seems to prohibit these, but we allow
		** them by changing into a space.  The new ANSI draft
		** specifically permits this.
		** However, in order to
		** prevent a missing ')' from allowing the arg scan to
		** gobble all the rest of the file, we check to see whether
		** we have already found all of our args.
		*/
		if (nargs >= nexpected) { /* If see \n when too many args */
		    error("Missing ')' in macro arg list");
		    return nargs;	/* Stop now with what we got */
		}
		/* Drop thru to handle like normal whitespace */

	    case T_WSP:
		if (tl.tl_head == NULL		/* Ignore wsp if at start */
		  || (tl.tl_tail->pt_typ == T_WSP))	/* or last was wsp */
		    continue;			/* Ignore, get next token */
		break;				/* OK to deposit it */

	    case T_EOF:		/* Uh-oh... stopped unexpectedly */
		if (eof)	/* Check for running off end of world */
		    error("Unexpected EOF during macro arg scan");
		else error("Macro arg scan truncated");
		plev = 0;	/* Must stop loop! */
		/* Drop thru to store arg before quitting */

	    case T_RPAREN:	/* Close paren counted for balancing */
		if (--plev > 0)
		    break;	/* Just add to arg */
		if (nargs == 0 && tl.tl_head == NULL)	/* No args at all? */
		    return 0;	/* None read... */
		/* Arg (and all args) done, drop thru to store current arg */

	    case T_COMMA:	/* Comma stops arg unless paren-protected */
		if (plev > 1)	/* If still within an arg, */
		    break;	/* just gobble the comma too */

		/* Store argument thus far! */
		/* Only set arg if we know there's room in table. */
		if (++nargs <= maxsto) {
		    if (prevlast && tl.tl_tail->pt_typ == T_WSP) {
			/* Truncate whitespace off arglist */
			(tl.tl_tail = prevlast)->pt_nxt = 0;
		    }
		    *tabptr++ = tl;	/* Store the arg list! */
		}
		if (plev <= 0) continue;	/* Check for done */
		tlzinit(tl);		/* Start a new arg */
		continue;		/* Get next token */

	    case T_LPAREN:	/* Open paren counted for balancing */
		plev++;		/* and always included in arg */
	    default:
		break;		/* All other tokens included in arg */
	}	/* End of switch */

	/* Add token to current arg, get next, and continue loop */
	prevlast = tl.tl_tail;	/* Remember previous last-ptr */
	tltadd(tl, tokize());	/* Always copy token for now */
    }    	/* End of loop */

    return nargs;		/* Return # of args parsed into array */
}

/* MEXPLIM(tl, hs) - Expand a tokenlist, using no additional tokens.
**	This is used to expand macro arguments and directive lines.
**	Note that the furnished list is munged; thus, a copy must be
**	given by the caller if the original must be preserved.
*/
static tlist_t
mexplim(il, hs)
tlist_t il;		/* Input list */
{
    static PPTOK eoftok = { T_EOF };
    tlist_t ml;

    tltadd(il, eoftok);		/* Add EOF to end of input list */
    ml = mexpand(il, hs);	/* Read from it, expand macros, get new list */
    if (mactl.tl_tail != il.tl_tail)		/* Input must still be there */
	int_error("mexplim: lost input list");
    if (mactl.tl_head != il.tl_tail)
	int_error("mexplim: input not all read");
    mtlpop();			/* Done, pop EOF-terminated list off input */
    return ml;
}

/* MEXPAND(tl,hs) - Expand a tokenlist, using additional input from
**	nextmacpp() if any is needed to read the arguments of a function-like
**	macro.
**	This is used to rescan macro bodies.
**	On return, all identifiers will have been marked to indicate whether
**	they are macros, hidden macros, or known not to be macros.
**	Note that the furnished list is munged; thus, a copy must be
**	given by the caller if the original must be preserved.
*/
static tlist_t
mexpand(il, hs)
tlist_t il;
{
    SYMBOL *sym;
    int ourlev;
    tlist_t ml, ol;

#if DEBUG_PP
    if (debpp) pmactl("enter mexpand", il, hs);
#endif
    if (!il.tl_head)		/* If list is empty, */
	return il;		/* just return empty list */
    mtlpush(il);		/* Push into input for nextmacpp */
    tlzinit(ol);		/* Start with empty output list */
    ourlev = mactlev;		/* Remember level we're reading at */
    while (ourlev <= mactlev) {
	switch (nextmacpp()) {
	case T_EOF:		/* Premature EOF can happen from mexplim */
	    if (ol.tl_tail)		/* Ensure list is terminated */
		ol.tl_tail->pt_nxt = 0;
#if DEBUG_PP
	    if (debpp) pmactl("leave mexpand", ol, hs);
#endif
	    return ol;

	case T_MACRO:		/* Macro, always expand */
	    sym = rawptr->pt_val.sym;
	    break;
	case T_IDENT:		/* Ident, must check it. */
	    switch (rawptr->pt_is) {
		case IS_MHID:			/* Hidden macro */
		case IS_MNOT:			/* Not a macro */
		    tlpadd(ol, rawptr);
		    continue;
		case IS_MEXP:			/* Expandable macro */
		    if (!(sym = findmacsym(rawval.cp))) {
			int_error("mexpand: Cannot lookup IS_MEXP \"%s\"",
					rawval.cp);
			rawptr->pt_is = IS_MNOT;
			tlpadd(ol, rawptr);
			continue;
		    }
		    break;			/* Break out to expand! */

		case IS_UNK:			/* Unknown identifier */
		    if (!(sym = findmacsym(rawval.cp))) {
			rawptr->pt_is = IS_MNOT;	/* Found not a macro */
			tlpadd(ol, rawptr);
			continue;
		    }
		    if (mishid(sym, hs)) {
			rawptr->pt_is = IS_MHID;	/* Macro, now hidden */
			tlpadd(ol, rawptr);
			continue;
		    }
		    break;			/* Break out to expand! */

		default:
		    int_error("mexpand: Bad IS_ type (%d)", rawptr->pt_is);
	    }
	    /* Come here when ident is expandable macro */
	    if (sym->Smacnpar < 0	/* If object-like macro, */
	      || mpeekpar())		/* or fn-like and followed by ( */
		break;			/* then OK to expand macro! */
	    /* Fall through if cannot expand macro */
#if 0	/* This is wrong.  Perhaps save sym by making T_MACRO?? */
	    rawptr->pt_is = IS_MHID;	/* Hide it forever */
#endif
	default:
	    tlpadd(ol, rawptr);
	    continue;		/* Just leave on token list */
	}

	/* Handle expansion of the macro pointed to by "sym".
	** This is a simple-minded method that has the virtue of working.
	*/
	ml = mexpsym(sym, hs);		/* Expand into ml */
	if (ml.tl_head)			/* If anything was returned, */
	    mtlpush(ml);		/* put it on input for rescan! */
	continue;
#if 0
	/* Handle expansion of the macro pointed to by "sym".
	** Most of the following hair is because we're trying to be
	** efficient and mung the input tokenlist in place.
	*/
	if (p == tl.tl_tail)	/* Cons up input tokenlist (IL) to rest */
	    tlzinit(il);
	else {
	    il.tl_head = tokn2p(p->pt_nxt);
	    il.tl_tail = tl.tl_tail;
	}
	tltadd(il, eoftok);	/* Add EOF to end of it */
	mtlpush(il);		/* Push list on input stack */
	ml = mexpsym(sym, hs);	/* Read from it, expand macro, get new list */
	if (mactl.tl_tail != il.tl_tail		/* Input must still be there */
	  || !(il.tl_head = mactl.tl_head))	/* Update IL for amt read */
	    int_error("mexpand: lost input list");
	mtlpop();				/* Done, pop list off input */

	/* Clean up IL to contain remaining input */
	if (il.tl_head->pt_typ == T_EOF)	/* If all gone, */
	    tlzinit(il);			/* just clear it */
	else (il.tl_tail = tl.tl_tail)->pt_nxt = 0;	/* remove the EOF */

	/* Set pointer such that loop will get correct next token from it */
	p = lastp;		/* This will be NULL if no prev token */

	/* Now add expanded list (ML) to scan list (TL) */
	if (tl.tl_tail = p) {	/* Truncate current scan list */
	    if (ml.tl_head)	/* Add expanded list to current list */
		tllapp(tl, ml);
	} else tl = ml;		/* TL truncated to empty, just use ML now */

	/* Now add remaining input (IL) back onto scan (TL) */
	if (tl.tl_tail) {	/* If there's something on TL */
	    if (il.tl_head)	/* Add whatever's left on IL */
		tllapp(tl, il);
	} else tl = il;		/* Nothing on TL, just use IL */

	/* If we replaced the first token, there wasn't any prev token, so
	** loop can't continue by getting next token from P; have to start
	** over by calling ourselves on the new TL.
	*/
	if (!p) return mexptl(tl, hs);
#endif
    }
    if (ol.tl_tail)		/* Ensure list is terminated */
	ol.tl_tail->pt_nxt = 0;
#if DEBUG_PP
    if (debpp) pmactl("leave mexpand", ol, hs);
#endif
    return ol;
}

/* MSUBST() - Substitute and expand args to a macro.
**	Given a macro frame with body string and array of arglists,
**	returns a tokenlist of the completely substituted result.
*/
static tlist_t
msubst(mf, hs)
struct macframe *mf;
{
    tlist_t tl, argl;
    register int typ, i;
    register char *cp;
    static PPTOK zpptok;
    PPTOK pptok;
    int ncats = 0;		/* # of concat ops seen */

#if DEBUG_PP
    if (debpp) pmacframe("msubst", mf);
#endif
    tlzinit(tl);		/* Init list to zero */
    if (cp = mf->mf_body) while (typ = *cp++) {
	if (typ < 0 || typ >= NTOKDEFS)
	    int_error("msubst: illegal token %d in body of macro %S",
				i, mf->mf_sym);
	switch (typ) {
	case T_MACSTR:		/* Stringize argument */
	case T_MACINS:		/* Insert argument */
	case T_MACARG:		/* Expand argument */
	    if ((i = *cp++ - MAC_ARGOFF) < 0 || i >= mf->mf_nargs)
		int_error("msubst: illegal param %d in body of macro %S",
				i, mf->mf_sym);
	    argl = mf->mf_argtl[i];
	    switch (typ) {	/* Handle arg as directed */
	    case T_MACSTR: argl = tlstrize(argl);   break;	/* Stringize */
	    case T_MACINS: argl = tlcopy(argl);     break;	/* Insert */
	    case T_MACARG: argl = mexplim(tlcopy(argl), hs); break;	/* Expand */
	    }
	    if (argl.tl_head) {	/* Add resulting arglist to accumulation */
		if (tl.tl_head) tllapp(tl, argl);
		else tl = argl;
	    }
	    continue;

	case T_MACCAT:		/* Op: concatenate tokens */
	    ++ncats;		/* Remember how many seen */
	    pptok = zpptok;
	    pptok.pt_typ = typ;
	    tltadd(tl, pptok);	/* Add to end of list */
	    continue;
	}

	/* Default for plain old body tokens - transform into pptok */
	pptok = zpptok;		/* Init pptok to zero */
	pptok.pt_typ = typ;	/* Stick in token # */
	if (!tokstr[typ]) {	/* Token not an op or punct? */
	    /* Assume rest of string is token */
	    pptok.pt_val.cp = cp;	/* Remember ptr to start */
	    if (*cp) while (*++cp);	/* Skip over */
	    ++cp;
	}
	tltadd(tl, pptok);	/* Add to end of list */
    }				/* Stop loop when hit end of macro body */

    /* All tokens present in list, now do concatenation if needed */
    if (ncats)
	mpaste(tl, hs, ncats);
    return tl;
}

static tlist_t
mpaste(tl, hs, ncats)
tlist_t tl;
{
    register PPTOK *p, *lastp = NULL;
    tlist_t nl;
    char *cp;

#if DEBUG_PP
    if (debpp) fprintf(fpp, "%smpaste: %d cats in:", plevindent(), ncats),
		tlfput(tl,fpp,0), putc('\n',fpp);
#endif
    for (p = tlpcur(tl); p; lastp = p, p = tokn2p(p->pt_nxt)) {
	if (p->pt_typ != T_MACCAT)
	    continue;
	/* Start concatenation!  Concatenate previous token with next one */
	cp = ppcbeg();
	ppctstr(lastp);			/* Dump prev token */
	do {
	    p = tokn2p(p->pt_nxt);
	    if (!lastp || !p)
		int_error("mpaste: ## arg missing");
	    ppctstr(p);			/* Dump next token */
	    p = tokn2p(p->pt_nxt);
	} while(--ncats > 0 && p && p->pt_typ == T_MACCAT);
	(void) ppcend();		/* Token done... */

	/* Everything concatenated for this stretch, now retokenize it.
	** If it cannot be parsed, it is left as T_UNKWN for possible later
	** salvage by higher levels, or at worst an error message.
	*/
	lastp->pt_val.cp = cp;		/* Default is to make it "unknown" */
	lastp->pt_typ = T_UNKNWN;
	nl = tlfrstr(cp);		/* Retokenize! */
#if DEBUG_PP
	if (debpp) fprintf(fpp, "%sRetokenized ", plevindent()),
		tkfput(lastp, fpp, 1),
		fputs(" into", fpp),
		tlfput(nl,fpp,1),
		putc('\n',fpp);
#endif
	if (nl.tl_head == nl.tl_tail) {	/* Got exactly one token? */
	    *lastp = *(nl.tl_head);	/* Yes, hurray!  Shove it onto list */
	    lastp->pt_nxt = tokp2n(p);	/* Skip over junked tokens */
	    /* Now decide how to (or whether to) "hide" this, if T_IDENT */
	    tkhide(lastp, hs);
	}

	if (ncats <= 0)
	    break;			/* If no more, leave loop! */
    }
}

/* Macro Hideset hackery.
*/

/* HSPUSH(sym,hs) - Add symbol to given hideset, return new hideset
*/
static int
hspush(sym, hs)
SYMBOL *sym;
{
    if (hs >= MAXMACNEST) {
	int_error("Macros nested too deep (%d)", hs);
    } else
	hidemacs[hs] = sym;		/* Remember ptr to macro sym */
    return hs+1;
}

/* TKHIDE(p, hs) - hide given token, if applicable
**	Returns resulting IS_ code.
*/
static int
tkhide(p, hs)
PPTOK *p;
{
    SYMBOL *sym;

    if (p->pt_typ == T_IDENT) {
	if (!(sym = findmacsym(p->pt_val.cp)))
	    return p->pt_is = IS_MNOT;	/* Known not to be macro */
	else if (mishid(sym, hs))
	    return p->pt_is = IS_MHID;	/* Is hidden macro */
	return p->pt_is = IS_MEXP;	/* Is expandable macro */
    }
    return IS_UNK;
}

/* MISHID(sym, hs) - Return TRUE if macro symbol is being hidden
**	by given hideset.
*/
static int
mishid(sym, hs)
SYMBOL *sym;
{
    if (hs < 0 || hs > MAXMACNEST)
	return int_error("mishid: bad arg"), 1;
    while (--hs >= 0)
	if (hidemacs[hs] == sym) {
#if DEBUG_PP
	    if (debpp) fprintf(fpp, "%smishid() suppressed %s!\n",
			plevindent(), sym->Sname);
#endif
	    return 1;
	}
    return 0;
}

/* Debugging Support */

#if DEBUG_PP

static char *
plevindent()
{
    static char sps[] = "                                                    ";
    return (maclevel <= 0 ? "" :
		(maclevel*4 > sizeof(sps) ? sps
			: &sps[sizeof(sps) - maclevel*4]));
}

/* PMACFRAME - print macro frame
*/
static void
pmacframe(str, mf)
char *str;
struct macframe *mf;
{
    int i;
    char *cp;
    SYMBOL *s = mf->mf_sym;
    char *ind = plevindent();	/* Get indentation to use */

    fprintf(fpp,
"%s%s: Macframe for %#o->\"%s\" (npar: %d, parlen: %d, len: %d)\n",
		ind, str, s, s->Sname, s->Smacnpar, s->Smacparlen, i = s->Smaclen);
    fprintf(fpp,"%sBody: %#o-> \"", ind, cp = s->Smacptr);
    if (cp) while (--i >= 0)
	if (iscntrl(*cp)) fprintf(fpp, "^%c", (*cp++)^0100);
	else putc(*cp++, fpp);
    fprintf(fpp, "\"\n");

    for (i = 0; i < mf->mf_nargs; ++i) {
	fprintf(fpp, "%sArg %d:", ind, i);
	tlfput(mf->mf_argtl[i], fpp, 0);
	putc('\n', fpp);
    }
}

static void
pmactl(s, tl, hs)
char *s;
tlist_t tl;
{
    char *ind = plevindent();

    fprintf(fpp, "%sTokenlist %s (hs %d): ", ind, s, hs);
    tlfput(tl, fpp, 1);
    putc('\n', fpp);
}

static void
tlfput(tl, fp, vrbflg)	/* vrbflg TRUE for more verbose output */
tlist_t tl;
FILE *fp;
{
    register PPTOK *p;
    for (p = tlpcur(tl); p; p = p->pt_nxt)
	tkfput(p, fp, vrbflg);
}

static char *
tkids(p)
PPTOK *p;
{
    static char buf[30];
    switch (p->pt_is) {
	case IS_UNK:	return "IS_UNK";
	case IS_MNOT:	return "IS_MNOT";
	case IS_MHID:	return "IS_MHID";
	case IS_MEXP:	return "IS_MEXP";
    }
    sprintf(buf, "T_IDENT+%#o", p->pt_is);
    return buf;
}

static void
tkfput(p, fp, vrbflg)	/* vrbflg TRUE for more verbose output */
PPTOK *p;
FILE *fp;
{
    register int i;
    char *cp;

    if ((i = p->pt_typ) < 0 || i >= NTOKDEFS
      || ( !(cp = tokstr[i])
        && !(cp = p->pt_val.cp)))
	fprintf(fp, " <%d=%s %#o>", i,
		((i < NTOKDEFS) ? nopname[i] : ""),
		p->pt_val.i);
    else {
	if (vrbflg) {
	    fprintf(fp," <%s %s>",(i == T_IDENT ? tkids(p) : nopname[i]), cp);
	} else fprintf(fp, " <%s>", cp);
    }
}
#endif

/* DIRECTIVE() - Process a PP directive.
**	Current raw token is T_SHARP.
**	On return, raw token is either T_EOL or T_EOF, and the
**	current char is either T_EOF or the first char of the next line.
**	Callers must check again for a possible directive on the next line!
**	Note that all token storage is flushed before and after processing.
*/
/* Return values for PP handling rtns */
#define PPR_UNKNOWN	-1	/* Unknown directive */
#define PPR_FLUSH	0	/* Flush everything up to EOL */
#define PPR_ATEOL	1	/* We're at EOL, just return */
#define PPR_CHECKEOL	2	/* Verify that no non-whitespace exists
				** between here and EOL.
				*/
static void
directive()
{
    int res = PPR_UNKNOWN;
    int len;

    /* Use ident length as quick hash into switch table.
    ** Result value is a PPR_ type.
    */
    indirp++;			/* Set this for scanhwsp checking */
    ppcreset();			/* Reset tokenizer storage */
    pptreset();
    len = (tskipwsp() == T_IDENT ? strlen(rawval.cp) : 0);
#if DEBUG_PP
    if (debpp && len) fprintf(fpp, "#-DIRECTIVE seen: \"%s\"\n", rawval.cp);
#endif
    switch (len) {

	/* Note that if we are in the middle of a failing conditional
	** (flushing stuff) then only #else, #endif, and #if-type commands
	** are acted upon.  All others are ignored, including
	** unknown #-type "commands", altho the latter generate a warning.
	*/
	case 0:
	    if (rawpp != T_EOL && !flushing)	/* If not EOL or identifier, */
		error("Preprocessor directive expected");	/* barf. */
	    res = PPR_FLUSH;			/* Nothing else to do */
	    break;

	case 2:
	    if (!strcmp(rawval.cp,"if")) res = d_if();
	    break;
	case 3:
	    if (!strcmp(rawval.cp,"asm") && clevkcc)
		res = flushing ? PPR_FLUSH : d_asm();	/* KCC-only */
	    break;
	case 4:
		 if (!strcmp(rawval.cp,"else")) res = d_else();
	    else if (!strcmp(rawval.cp,"elif") && clevel >= CLEV_CARM) res = d_elif();
	    else if (!strcmp(rawval.cp,"line"))
		res = flushing ? PPR_FLUSH : d_line();
	    break;
	case 5:
		 if (!strcmp(rawval.cp,"endif")) res = d_endif();
	    else if (!strcmp(rawval.cp,"ifdef")) res = d_ifdef(1);
	    else if (!strcmp(rawval.cp,"undef"))
		res = flushing ? PPR_FLUSH : d_undef();
	    else if (!strcmp(rawval.cp,"error"))
		res = flushing ? PPR_FLUSH : d_error();
	    break;
	case 6:
		 if (!strcmp(rawval.cp,"ifndef")) res = d_ifdef(0);
	    else if (!strcmp(rawval.cp,"define"))
		res = flushing ? PPR_FLUSH : d_define();
	    else if (!strcmp(rawval.cp,"pragma"))
		res = flushing ? PPR_FLUSH : d_pragma();
	    else if (!strcmp(rawval.cp,"endasm") && clevkcc)
		res = flushing ? PPR_FLUSH : d_endasm();	/* KCC-only */
	    break;
	case 7:
	    if (!strcmp(rawval.cp,"include"))
		res = flushing ? PPR_FLUSH : d_include();
	    break;
    }

    /* Now do common cleanup code by examining result */
    switch (res) {
	case PPR_CHECKEOL:
	    checkeol();
	case PPR_ATEOL:
	    break;
	case PPR_UNKNOWN:
	    if (flushing)
		warn("Unsupported preprocessor command: \"%s\"", rawval.cp);
	    else error("Unsupported preprocessor command: \"%s\"", rawval.cp);
	case PPR_FLUSH:
	    indirp = 0;		/* Avoid whitespace err msgs */
	    flushtoeol();
	    break;
    }
    indirp = 0;			/* No longer scanning directive */
    ppcreset();			/* Reset tokenizer storage */
    pptreset();
}

/* D_DEFINE() - Process #define directive
*/
static int
d_define()
{
    char *name;		/* Name of new macro (in ppcpool) */
    SYMBOL *sym;
    struct macframe m;
    int i;

    if (tskipwsp() != T_IDENT) {	/* Get first non-whitespace token */
	error("Macro name expected");	/* complain if nothing. */
	return PPR_FLUSH;
    }
    name = rawval.cp;		/* Remember ptr to ident */
    if (*name == '`') {
	error("Macro name cannot be quoted identifier");
	return PPR_FLUSH;
    }

    /* Look for parameter names */
    m.mf_nargs = -1;		/* Initially assume no params */
    m.mf_parlen = 0;		/* Keep track of # chars that params need */
    if (nextrawpp() == T_LPAREN) {
	m.mf_nargs = 0;			/* It's a fncall macro! */
	while (1) {
	    if (tskipwsp() == T_RPAREN)	/* Skip over whitespace */
		break;			/* Macro params done! */
	    if (rawpp != T_IDENT) {	/* Better be a param ident */
		error("Macro formal parameter must be identifier");
		m.mf_parlen = m.mf_nargs = 0;
					/* Ugh!  Don't try to hack args on */
					/* expansion, but remember that */
		break;			/* this is a fncall macro. */
	    }
	    if (m.mf_nargs >= MAXMARG - 1)
		error("More than %d args in macro definition of \"%s\"",
			MAXMARG, name);
	    else {
		/* Have arg, store it.  Must also check for
		** duplicate arg names (yes it happens)
		*/
		m.mf_parcp[m.mf_nargs] = rawval.cp;	/* Remember arg name */
		for (i = 0; i < m.mf_nargs; i++)	/* Scan to find dups */
		    if (!strcmp(m.mf_parcp[i], rawval.cp)) {
			error("Duplicate formal parameter in macro def; \"%s\"", rawval.cp);
			break;
		    }
		m.mf_nargs++;
		m.mf_parlen += strlen(rawval.cp)+1;	/* Sigh */
	    }
	    if (tskipwsp() != T_COMMA)	/* If comma next, continue loop */
		break;			/* else stop now */
	}
	if (rawpp != T_RPAREN)
	    error("Close paren needed to end formal parameter list");
	else nextrawpp();		/* Set up next token */
    }

    /* Arguments read, now read rest of line into a tokenlist. */
    if (!mdefinp(&m))			/* If failed somehow, */
	return PPR_FLUSH;		/* just flush rest of line */

    /* OK, now can check for macro already being defined */
    *defcsname = 'd';			/* Allow "defined" to be found */
    sym = findmacsym(name);
    *defcsname = SPC_MACDEF;		/* Hide "defined" again */
    if (sym != NULL) {			/* If already defined, compare it */
	if (m.mf_nargs == sym->Smacnpar	/* Args and body must match */
	  && m.mf_len == sym->Smaclen
	  && (m.mf_len == 0		/* OK if both bodies null */
	    || memcmp(m.mf_body, sym->Smacptr, m.mf_len) == 0)) {
		if (m.mf_body) free(m.mf_body);	/* Identical, we win! */
		return PPR_CHECKEOL;
	}

	if (sym->Smacnpar < MACF_ATOM) {	/* Check for specialness */
	    error("Illegal to redefine \"%s\"", name);
	    if (m.mf_body) free(m.mf_body);
	    return PPR_FLUSH;
	}
	/* Later just output "note" if macro is functionally identical,
	** i.e. differs only in parameter names (gark bletch)
	*/
	warn("Macro redefined: \"%s\"", name);
	freemacsym(sym);		/* Flush old sym completely */
    }

    /* Now define the new macro! */
    mdefsym(name, &m);
    return PPR_CHECKEOL;
}

/* MDEFINP - auxiliary that defines a macro body given input from nextrawpp().
**	Returns true if everything went OK, else wants rest of input flushed.
*/
static int
mdefinp(mf)
struct macframe *mf;
{
    register int i;
    register char *cp;
    static PPTOK sptok = { T_WSP };
    tlist_t tl;
    int wspf;

    /* Current token is the first token of the macro body. */
    tlzinit(tl);		/* Init tokenlist */
    wspf = 0;			/* No whitespace seen yet */
    mf->mf_len = 0;		/* Keep track of # chars that body needs */
    while (rawpp == T_WSP)	/* Skip initial whitespace first... */
	nextrawpp();
    while (wspf >= 0) {
	switch (rawpp) {
	case T_EOF:
	case T_EOL:
	    /* Done, ignore any trailing whitespace */
	    if (tl.tl_tail && tl.tl_tail->pt_typ == T_MACCAT) {
		error("## operator cannot end macro body");
		tl.tl_tail->pt_typ = T_SHARP2;	/* Too hard to flush, so sub */
	    }
	    wspf = -1;		/* Leave loop now */
	    continue;

	case T_WSP:		/* Whitespace just sets flag */
	    wspf = 1;
	    if (tl.tl_tail && tl.tl_tail->pt_typ == T_MACCAT)
		wspf = 0;	/* Ignore wsp if ## was previous token */
	    nextrawpp();
	    continue;

	case T_IDENT:
	    for (i = 0; i < mf->mf_nargs; i++)	/* Scan to see if a param */
		if (!strcmp(mf->mf_parcp[i], rawval.cp))
		    break;
	    if (i < mf->mf_nargs) {	/* If found param, fix token */
		if (tl.tl_tail && tl.tl_tail->pt_typ == T_MACCAT)
		    rawpp = T_MACINS;	/* Say token is inserted param */
		else {
		    if (wspf) tltadd(tl, sptok), mf->mf_len++;
		    rawpp = T_MACARG;	/* Say token is expanded param */
		}
		rawval.i = i;		/* with this param # */ 
		mf->mf_len += 2;
		break;
	    }
	    /* Drop thru to add normal ident token to list */

	default:
	    if (wspf) tltadd(tl, sptok), mf->mf_len++;
	    mf->mf_len++;	/* Bump for token type */
	    if (rawval.cp)	/* Len is 1 extra for NUL terminator */
		mf->mf_len += strlen(rawval.cp) + 1;
	    break;		/* Add token */

	case T_SHARP:
	    if (tskipwsp() != T_IDENT) {
		error("Formal parameter must follow the # operator");
		continue;	/* Sigh, skip the # */
	    }
	    for (i = 0; i < mf->mf_nargs; i++)	/* Scan to see if param */
		if (!strcmp(mf->mf_parcp[i], rawval.cp))
		    break;
	    if (i >= mf->mf_nargs) {	 /* Check again */
		error("Formal parameter must follow the # operator");
		continue;		/* Sigh, skip the # */
	    }
	    if (wspf) tltadd(tl, sptok), mf->mf_len++;
	    rawpp = T_MACSTR;		/* Stringize this macro arg! */
	    rawval.i = i;
	    mf->mf_len += 2;
	    break;			/* Add to list and continue */

	case T_SHARP2:
	    /* Ignore any preceding whitespace.
	    ** Param preceding this op becomes inserted, not expanded!
	    */
	    if (!tl.tl_tail) {
		error("## operator cannot begin macro body");
		nextrawpp();		/* Flush it and continue */
		continue;
	    }
	    if (tl.tl_tail->pt_typ == T_MACARG)		/* Preceding param? */
		tl.tl_tail->pt_typ = T_MACINS;		/* Yes, say insert! */
	    rawpp = T_MACCAT;
	    mf->mf_len++;
	    break;
	}
	wspf = 0;
	tlrawadd(&tl);		/* Add token to list */
   	nextrawpp();		/* and get next and continue */
    }

    /* If no body, we win with nothing else to do. */
    if ((mf->mf_len += mf->mf_parlen) == 0) {
	mf->mf_body = NULL;
	return 1;
    }

    /* We now have the macro body tokenlist in TL.
    ** Using the computed length, we allocate dynamic storage for it and
    ** transform it into a body string.  Unfortunately this has to be done
    ** before we can check for a definition clash.
    */
    if ((cp = mf->mf_body = malloc(mf->mf_len+1)) == NULL) {
	error("Out of memory for macro body");
	mf->mf_len = mf->mf_parlen = 0;	/* Recover by saying no body */
	return 1;
    }

    /* First copy TRULY ASSININE parameter names, thanks to some
    ** anonymous moronic anal-retentive cretins on X3J11.  Really.
    */
    if (mf->mf_nargs > 0) {
	for (i = 0; i < mf->mf_nargs; i++) {
	    cp = estrcpy(cp, mf->mf_parcp[i]);
	    *cp++ = ',';
	}
	cp[-1] = ')';		/* Minor touch for easier debugging */
    }
    /* Copy tokenlist into a body in memory, with safety checks */
    if (((cp - mf->mf_body) != mf->mf_parlen)
      || ((tltomac(tl, cp) - mf->mf_body) != (mf->mf_len+1)))
	int_error("mdefinp: bad mac len");

    return 1;
}

/* MDEFSTR - auxiliary for use by startup code which defines macros given
**	a name, macro type, and string.
**	This cannot be used to define macros with arguments.
*/
static SYMBOL *
mdefstr(name, mactyp, body)
char *name;			/* Macro symbol name */
int mactyp;			/* Special MACF_ type */
char *body;			/* Text of macro definition */
{
    struct macframe m;

    m.mf_nargs = mactyp;
    m.mf_parlen = 0;
    if (body) {
	PPTOK *savppt = pptptr;	/* Save these values so can flush stg used */
	ppcstate_t savppc;

	ppcsave(savppc);
	sinbeg(body);		/* Redirect input to come from string */
	nextmacpp();		/* Set up first token */
	mdefinp(&m);		/* Gobble body from input, fill macframe */
	sinend();		/* Stop input, check for gobbling all! */
	ppcrest(savppc);	/* Flush all strings & pptoks used */
	pptptr = savppt;
    } else m.mf_body = NULL, m.mf_len = 0;
    return mdefsym(name, &m);	/* Always define macro, and return! */
}

/* MDEFSYM(name, &mf) - auxiliary that actually creates the macro symbol and
**	sets its definition, given a macro frame argument already set up
**	by other calls.
*/
static SYMBOL *
mdefsym(name, mf)
char *name;			/* Macro symbol name */
register struct macframe *mf;
{
    register SYMBOL *s;

    s = symfind(name, 1);	/* Find or create symbol so barfs on trunc */
    if (s->Sclass != SC_UNDEF) {
	s->Srefs--;
        s = symgcreat(name);	/* Create global symbol */
    }
    s->Sclass = SC_MACRO;	/* Say it's a macro */
    s->Sflags |= SF_MACRO;	/* Say ditto, with flag. */
    s->Smacnpar = mf->mf_nargs;	/* Set # args or MACF_ type */
    s->Smacparlen = mf->mf_parlen;	/* # chars in param-name prefix */
    s->Smaclen = mf->mf_len;	/* # chars total in macro body */
    s->Smacptr = mf->mf_body;	/* Body string already set up! */
    return s;			/* Return pointer to defined macro */
}

/* D_UNDEF() - Process #undef directive
*/
static int
d_undef()
{
    SYMBOL *sym;

    if (tskipwsp() != T_IDENT) {
	error("Macro name expected");	/* Bad identifier */
	return PPR_FLUSH;
    }

    *defcsname = 'd';			/* Allow "defined" to be found */
    sym = findmacsym(rawval.cp);
    *defcsname = SPC_MACDEF;		/* Hide "defined" again */
    if (sym != NULL) {			/* If already defined, */
	if (sym->Smacnpar >= MACF_ATOM)	/* Check for specialness */
	    freemacsym(sym);		/* OK to flush it, do so. */
	else error("Illegal to undefine \"%s\"", rawval.cp);
    }
}

static void
freemacsym(sym)
SYMBOL *sym;
{
    if (sym->Smacptr)		/* If it has a macro body, */
	free(sym->Smacptr);	/* free it up. */
    freesym(sym);		/* Then flush the symbol definition. */
}

/* D_ASM() - Process #asm directive
**
** All text between #asm and #endasm is turned into a series of
** asm() expressions, one per line.  Each line is macro-expanded before
** being put into the asm() string literal argument.
** Thus, the sequence
**	#asm
**		text1
**		text2
**	#endasm
** becomes:
**	asm("text1");
**	asm("text2");
** This is consequently only meaningful inside functions.
*/
static int asmfline;

static int
d_asm()
{
    flushtoeol();			/* ignore rest of line */
    if (inasm) {			/* bump level.  if nested, complain */
	error("Already in #asm, can't nest");
	return PPR_ATEOL;
    }
    inasm = 1;				/* Say processing assembler input */
    asmfline = fline;
    if (curtl.tl_head)
	int_error("d_asm: cooked top-level input");
    curtl = tlmake(T_EOL, 0);		/* Set up curtl with dummy */
    return PPR_CHECKEOL;
}

/* ASMREFILL() - refill nextpp's token list with an #asm input line.
**	Current char is 1st of line to crunch.
*/
static tlist_t
asmrefill()
{
    tlist_t tl;
    static PPTOK lptok = { T_LPAREN },
		stok = { T_SCONST },
		rptok = { T_RPAREN },
		sctok = { T_SCOLON },
		eoltok = { T_EOL };
    tlzinit(tl);
    ppcreset();		/* Clear token char pool and token stg */
    pptreset();

    for (;;) {
	while (cskiplwsp() == '\n')	/* Flush whitespace and lines */
	    nextch();
	if (ch == '#') {	/* If hit directive */
	    nextch();		/* Set up next char */
	    directive();	/* and process directive! */
	    if (!inasm) {	/* If it included an #endasm, */
		if (ch != '\n') {
		    pushch(ch);
		    pushstr("\n");
		}
		return tl;	/* then just return empty list. */
	    }
	    continue;
	}
	break;
    }
    tl = tlmake(T_IDENT, "asm");	/* Make start of returned tokenlist */
    tltadd(tl, lptok);		/* Add left-paren */
    stok.pt_val.cp = ppcbeg();	/* Got something real, start a literal! */
    ppcput('"');

    for (;;) { switch (ch) {	/* Scan starting with current char */
    case EOF:
	error("EOF within unterminated #asm beginning at line %d", asmfline);
	inasm = 0;		/* Stop now */
	break;			/* Still try to finish up cleanly */

    case '\n':			/* Newline means done, return tokenlist! */
	break;

    case '/':			/* Check for possible start of comment */
	if (nextch() == '*')
	    scancomm(), nextch(), ppcput(' ');
	else ppcput('/');
	continue;

    case '\\':			/* Must quote these chars */
    case '"':
	ppcput('\\'); ppcput(ch); nextch();
	continue;

    default:
	if (!iscsymf(ch)) {	/* Start of identifier? */
	    ppcput(ch);		/* Nope, just pass char on */
	    nextch();
	    continue;
	} else {
	    SYMBOL *sym;
	    register char *cp;
	    tlist_t strtl;

	    ppcput(ch);			/* Store first char of ident */
	    cp = ppcptr;		/* Remember pointer to it */
	    while (iscsym(nextch()))	/* Gobble all of identifier */
		ppcput(ch);
	    (void)ppcend();

	    if (!(sym = findmacsym(cp))		/* If not a macro, */
	      || !mexptop(sym, 0)) {		/* or can't expand it, */
		(void)ppcbackup();		/* just undo the ppcend() */
		continue;			/* and carry on! */
	    }
	    /* Expanded macro!
	    ** First do tricky stuff to recover the string literal
	    ** token we were collecting, by clobbering the collected
	    ** macro identifier with '"' and NUL.  There will always be
	    ** enough room for this because the identifier had at least one
	    ** char and was null-terminated.
	    */
	    *cp = '"';			/* Set end quote of string literal */
	    *++cp = 0;			/* Tie off string */
	    tltadd(tl, stok);		/* And add literal to token list */

	    /* Now get the expanded macro tokens, which mexptop() left
	    ** in a tokenlist in curtl.  We swipe that and translate it into
	    ** a single string literal which is appended to our tokenlist.
	    */
	    strtl = tlstrize(curtl);	/* Make string lit from it */
	    tlzinit(curtl);		/* Done with that list */
	    tllapp(tl, strtl);		/* Append lit to our list */

	    stok.pt_val.cp = ppcbeg();	/* Now start a new string literal */
	    ppcput('"');
	    continue;

	}
    }				/* End of switch */
    break;
    }				/* End of loop */

    ppcput('\\');
    ppcput('n');
    ppcput('"');		/* Done, stop literal */
    (void)ppcend();
    tltadd(tl, stok);		/* And add to list */
    tltadd(tl, rptok);		/* Add right paren */
    tltadd(tl, sctok);		/* And semicolon */
    tltadd(tl, eoltok);		/* And EOL for niceness to passthru() */
    tltadd(tl, eoltok);		/* Another one to sacrifice to nextpp() */
    return tl;			/* Return the tokenlist! */
}

/* D_ENDASM() - Process #endasm directive
*/
static int
d_endasm()
{
    if (inasm == 0)			/* If not inside #asm, complain */
	error("Not in #asm, ignoring #endasm");
    else inasm = 0;			/* Tell d_asm() to stop */
    return PPR_FLUSH;
}

#if 0
	This page contains all of the "conditional commands", i.e.
if, ifdef, ifndef, elif, else, and endif.  ifdef and ifndef are merely
variants of #if.
	flush  means if flushing.
	flush= means if flushing at current level.
	flush* means if flushing at any other level.

Action table:
   Encounter	Prev	Flush?	Action to take:
	if	*	flush	push lev, set in-if, keep flushing.
		*	ok	push lev, set in-if, test.  Fail: set flush lev
	elif	if	flush*	Set in-elif, keep flushing.
		if	flush=	Test.  Win: set in-elif; fail: set in-if,flush.
		if	ok	Set in-elif, set flush lev.
		elif	flush	Stay in elif, keep flushing.
		elif	ok	Set in-elif, set flush lev.
		other = Error.
	else	if	flush=	Set in-else, stop flush.
		if	flush*	Set in-else, keep flushing.
		elif	flush	Set in-else, keep flushing.
		if	ok	Set in-else, set flush lev.
		elif	ok	Set in-else, set flush lev.
		other = Error.
	endif	*	flush=	Pop level.
		*	flush*	Pop level, keep flushing.
		*	ok	Pop level.
		not if/elif/else = Error.

	The tricky part is that elif only sets in-elif if the initial
if (or one of the previous elifs) was true.  As long as no test has succeeded
the setting is always kept at in-if.  This allows both elif and else to
know whether they are part of a elif chain that succeeded or not.
#endif

/* D_IFDEF() - Process #ifdef and #ifndef directives
*/
static int
d_ifdef(cond)
int cond;		/* 1 == ifdef, 0 == ifndef */
{

    if (++iflevel >= MAXIFLEVEL-1) {	/* this is a new if level */
	error("#if nesting depth exceeded");
	--iflevel;
    }
    iftype[iflevel] = IN_IF;	/* Say IF seen for this level */
    iffile[iflevel] = 0;	/* In current input file */
    ifline[iflevel] = fline;	/* At this line */
    if (flushing) return PPR_FLUSH;	/* if in false condition, that's all */

    if (nextrawpp() != T_WSP
      || nextrawpp() != T_IDENT) {
	error("Macro name expected");		/* Bad identifier */
	return PPR_FLUSH;
    }
    if (cond == ((findmacsym(rawval.cp) != NULL)))
	return PPR_CHECKEOL;	/* good condition, return */
    checkeol();
    flushcond();		/* Failed, flush body */
    return PPR_ATEOL;
}

/* D_IF() - Process #if directive
*/
static int
d_if()
{
    if (++iflevel >= MAXIFLEVEL-1) {	/* this is a new if level */
	error("#if nesting depth exceeded");
	--iflevel;
    }
    iftype[iflevel] = IN_IF;		/* Say IF seen for this level. */
    iffile[iflevel] = 0;		/* In current input file */
    ifline[iflevel] = fline;		/* At this line */
    if (flushing) return PPR_FLUSH;	/* If already flushing, that's all. */

    if (!iftest())		/* Do the test.  If fail, */
	flushcond();		/* then flush body. */
    return PPR_ATEOL;
}

/* D_ELIF() - Process #elif directive
*/
static int
d_elif()
{
    /* Make sure an #if or #elif preceeded this #elif */
    if (iftype[iflevel] == IN_ELSE) {	/* If not IN_IF or IN_ELIF */
	error("#elif without preceding #if, treating as #if");
	d_if();				/* Handle as if plain #if */
	return;
    }

    /* For helpfulness, check to see if active conditional is in same file */
    if (iffile[iflevel] > 0)
	iffwarn("elif");	/* Matches condit from different file */

    /* See if OK for elif to test its expression.  This is only allowed
    ** if we are in an #if that just failed, or part of an elif chain
    ** that has never succeeded yet (which looks just the same).
    */
    if (flushing == iflevel && iftype[iflevel] == IN_IF) {
	if (iftest()) {		/* OK, do the test!! */
	    flushing = 0;		/* Won!  Stop flushing */
	    iftype[iflevel] = IN_ELIF;	/* and say inside an elif. */
	    iffile[iflevel] = 0;	/* In current input file */
	    ifline[iflevel] = fline-1;	/* At this line (note EOL gobbled) */
	}			/* Else, stay in-if and keep flushing. */
	return PPR_ATEOL;
    }

    /* No need to perform test; this elif body must always fail at this point.
    **  Just ensure we're marked in-elif and see whether to start flushing
    ** or not.
    */
    iftype[iflevel] = IN_ELIF;	/* Set or stay in-elif */
    iffile[iflevel] = 0;	/* In current input file */
    ifline[iflevel] = fline;	/* At this line */

    if (flushing) return PPR_FLUSH;	/* If already flushing, just keep flushing. */
    flushtoeol();		/* No, start flushing to start of next line */
    flushcond();		/* And start flush checking now. */
    return PPR_ATEOL;
}


/* D_ELSE() - Process #else directive
*/
static int
d_else()
{
    int prev = iftype[iflevel];	/* Remember current level type */

    if (prev == IN_ELSE) {	/* Not IN_IF or IN_ELIF */
	error("#else without preceding #if");
	if (iflevel == 0) {	/* If not already inside a conditional */
	    prev = iftype[++iflevel] = IN_IF;	/* Pretend we were in an #if */
	    iffile[iflevel] = 0;
	    ifline[iflevel] = fline;
	    flushing = 0;			/* that was winning. */
	}
    }

    /* For helpfulness, check to see if active conditional is in same file */
    if (iffile[iflevel] > 0)
	iffwarn("else");		/* Matches condit from diff file */

    iftype[iflevel] = IN_ELSE;	/* Whatever, say #if no longer last thing */
    iffile[iflevel] = 0;
    ifline[iflevel] = fline;

    /* Now invert sense of flushing:
    **	If not flushing, start doing so.
    **	If already flushing at this level, stop.  EXCEPT if prev was elif,
    **		in which case keep flushing!
    **	If flushing at a different level, keep going.
    */
    if (flushing == 0) {
	checkeol();		/* Move to start of next line */
	flushcond();		/* Start flushing if not */
    } else if (flushing == iflevel && prev != IN_ELIF) {
	flushing = 0;		/* Stop flushing! */
    } else if (flushing != iflevel)	/* Else just keep flushing. */
	flushtoeol();
    return PPR_CHECKEOL;
}

/* D_ENDIF() - Process #endif directive
*/
static int
d_endif()
{
    if (iflevel) {		/* Are we in a conditional? */
	if (iflevel == flushing) flushing = 0; /* stop flushing */
	if (iffile[iflevel] > 0)	/* Verify balanced within file! */
	    iffwarn("endif");		/* Barf, condit is from diff file */
	iflevel--;		/* drop a level */
    } else
	error("Unmatched #endif");

    if (flushing) flushtoeol();
    return PPR_CHECKEOL;
}

/* FLUSHCOND - Auxiliary for if, elif, else.
**	Flush the body of a failing conditional command.
**	Assumes next token is 1st of next line (ie current char is 1st char).
**	When it returns, the current char will either be EOF
**	or will be the EOL which terminated the command that
**	caused flushing to stop.  See nextc()'s cmdlev variable.
*/
static void
flushcond()
{
    flushing = iflevel;		/* not ok, set flushing */
    indirp = 0;			/* No longer hacking directive */
    do {
	if (tskipwsp() == T_SHARP)	/* Check start of line */
	    directive();		/* Handle directive! */
	else flushtoeol();
    } while (flushing && !eof);		/* If still flushing, keep going. */
}

/* IFTEST - auxiliary for #if and #elif.
**	Parses the conditional expression and returns its value.
** This works by gobbling the rest of the line as a token list,
** expanding it, and then substituting this token list as if a macro
** to the C expression parser.
**	On return, current token is garbage (usually T_EOF after the
** mexplim()) but current char is 1st of next line after the #if.
** Be careful not to try to examine the "current token" after iftest().
** Sigh.
*/
static int
iftest()
{
    PPTOK *p;
    static PPTOK scoltok = { T_SCOLON };	/* Token for ";" */
    static PPTOK eoltok = { T_EOL };
    int won = 0;		/* Set non-zero if expr parse wins. */
    long val;

    /* Set up to parse a one-line constant expression */
    if (tlpcur(curtl))		/* Make sure we can hack curtl */
	int_error("iftest: parsing #if with active curtl");

    *defcsname = 'd';		/* Restore proper 1st char to "defined" sym */
    curtl = mexplim(getlinetl(), 0);	/* Read line, expand it */
    *defcsname = SPC_MACDEF;	/* Re-Zap 1st char of "defined" macro sym */

    /* Check to make sure no identifiers left */
    for (p = tlpcur(curtl); p; p = tokn2p(p->pt_nxt))
	if (p->pt_typ == T_IDENT) {
	    note("Undefined identifier \"%s\" - substituting \"0L\"",
			p->pt_val.cp);
	    p->pt_typ = T_ICONST;
	    p->pt_val.cp = "0L";
	}
    if (tlpcur(curtl)) {	/* Add ";" on end */
	tltadd(curtl, scoltok);
	tltadd(curtl, eoltok);	/* Plus EOL in case of inasm */
	p = curtl.tl_tail;	/* Remember ptr to last token */
#if DEBUG_PP
	if (debpp) pmactl("iftest", curtl, 0);
#endif
	nextoken();		/* Initialize top-level token parser */
	val = pconst();		/* Parse input into value */
	curptr = NULL;		/* Clean up from recursive nextpp() */
	if (!tlpcur(curtl)	/* Make sure everything gobbled */
	  || tlpcur(curtl) == p) {	/* If anything left, better be EOL */
	    ++won;		/* Yep to either, parse won! */
	}
	tlzinit(curtl);		/* Ensure input tokenlist is flushed */
    }
    if (!won) {
	error("Bad syntax for #if expression, using 0");
	val = 0;
    }
    return val != 0;		/* Return logical result */
}

/* Various auxiliaries that exist only to provide helpful warnings or
** error messages if conditionals appear to be unbalanced across file
** boundaries.
*/

/* IFFWARN - Called when changing or ending an active conditional which
**	started in another file.
*/
static void
iffwarn(typ)
char *typ;
{
    warn("#%s matches #%s from different file (\"%s\", line %d)",
	typ,
	ifname[iftype[iflevel]],
	inc[iffile[iflevel]-1].cname,
	ifline[iflevel]);
}

/* IFPUSH - Called when file input pushed by #include, to fix up
**	the info saved about active conditionals.
*/
static void
ifpush(inlev)
{
    register int i;
    ++inlev;				/* Bump up so never zero */
    for (i = iflevel; i > 0; --i) {	/* For all active conditionals */
	if (iffile[i] == 0)		/* If in condit for this file */
	    iffile[i] = inlev;		/* remember its place in inc[] */
    }
}

/* IFPOPCHK - Current input file just ended, popping input or stopping
**	altogether.  Check for unterminated or unbalanced conditionals,
**	and output helpful messages if necessary.
*/
static void
ifpopchk(inlev)
{
    register int i;

    if (inlev) {		/* Just popping an include file? */
	for (i = iflevel; i > 0; --i) {
	    if (iffile[i] == 0) {	/* If still in condit for this file */
		warn("Unterminated #%s (starting at line %d)",
				ifname[iftype[i]], ifline[i]);
		iffile[i] = -1;		/* Say name no longer available */
	    } else if (iffile[i] == inlev)
		iffile[i] = 0;		/* This will become current file! */
	}
    } else {

	/* EOF of whole input, check for unterminated stuff and give errors */
	for (i = iflevel; i > 0 ; --i)		/* For each active condit */
	    error("Unterminated #%s (starting at line %d%s)",
			ifname[iftype[i]], ifline[i],
			iffile[i] ? " of an included file"	/* Gone file */
				: "");				/* Main file */
    }
}

/* D_INCLUDE() - Process #include directive
**
**	 Note that this emulates the Un*x compiler behavior by
** starting the search for "" files in the current source directory,
** rather than in the process' connected directory.
*/
static int cinctry();	/* Auxiliary just for cinclude() */

static int
d_include()
{
    char f[FNAMESIZE], f2[FNAMESIZE];
    int ftype, done = 0;
    FILE *fp = NULL;

    if ((ftype = getfile(f, FNAMESIZE)) == 0)
	return PPR_FLUSH;	/* If failed to get name, ignore */

    /* A filename starting with '/' (ie an absolute pathname)
    ** tries just that name; nothing would else make sense.
    */
    if (*f == '/') {
	fp = fopen(strcpy(f2, f), "r");	/* Try to open just this one */
	++done;				/* Always done now */
    } else if (ftype != '>') {
	/* File specified with "file" instead of <file>.  Must look in
	** several places, starting with the directory the input source is in.
	*/
	estrcpy(estrcpy(estrcpy(f2,	/* Use source filename pref+suff */
		inpfdir), f), inpfsuf);
	if (fp = fopen(f2, "r"))
	    ++done;
	else    /* Unsuccessful open, try -I switches if any, in order given */
	    if (nincpaths)
		done = cinctry(nincpaths, incpaths, f2, f, &fp);
    }
    /* Now drop thru, so if nothing worked for a ""-type include, we
    ** try looking in the standard places for <>.
    */
    if (!done) {		/* Look in <> places */

	/* If redirecting <sys/ > files, try alternate paths from -h switches.
	** Note that default entries (if they exist) are tried last.
	*/
	if ((nhfsypaths || nihfsypaths) && (strncmp(f, "sys/", 4) == 0)
	  && (nhfsypaths <= 0
		|| !cinctry(nhfsypaths, hfsypaths, f2, f+4, &fp)))
	    cinctry(nihfsypaths, ihfsypaths, f2, f+4, &fp);

	/* If not, or didn't succeed, just handle basic <> file with -H sws.
	** Note that default entries (if they exist) are tried last.
	*/
	if (!fp
	  && (nhfpaths <= 0 || !cinctry(nhfpaths, hfpaths, f2, f, &fp)))
	    cinctry(nihfpaths, ihfpaths, f2, f, &fp);
    }

    if (!fp)				/* If nothing worked, complain */
	error("Can't open include file, last tried \"%s\"", f2);
    else filepush(fp, f2, 1, 1, 1);	/* Won, push to new input file! */
    return PPR_ATEOL;
}

/* CINCTRY - Attempt to open an include file using the specified array
**	of directory pathnames.
**	Succeeds if file is opened OR if a NULL entry is encountered.
*/
static int
cinctry(n, ptab, f2, f, fp)
register int n;			/* # paths in table */
char **ptab;			/* Addr of table */
char *f2, *f;			/* Places to deposit built and orig names */
FILE **fp;
{
    for(; --n >= 0; ++ptab) {
	if (!*ptab || !**ptab)		/* If we hit enforced stop, */
	    return 1;			/* always done now. */
	fstrcpy(f2, *ptab, f);		/* Build filename to try */
	if ((*fp = fopen(f2, "r")) != NULL)
	    return 1;			/* Won! */
    }
    return 0;				/* No stop and no opens... */
}

/* FILEPUSH - auxiliary for #include and #asm
**	Similar to bstrpush(), but for file input rather than string input.
**	Note that the current char needs to be saved; for both #include and
**	#asm this will be the 1st char on the next line after the directive,
**	due to the tokenizer's peek-ahead strategy.
*/
static void
filepush(fp, fname, lin, pag, flin)
FILE *fp;
char *fname;
int lin, pag, flin;
{
    if (inlevel >= MAXINCLNEST-1) {	/* Make sure we have room */
	error("Include file nesting depth exceeded -- ignoring %s",fname);
	return;				/* Just ignore it if not */
    }

    pushch(ch);				/* Remember current file input char */
    if (eof)				/* If read-ahead has left us at */
	eof = 0;			/* top-level EOF, undo it. */
    strcpy(inc[inlevel].cname, inpfname);	/* Save old context */
    inc[inlevel].cptr = in;
    inc[inlevel].cpage = page;
    inc[inlevel].cline = line;
    inc[inlevel].cfline = fline;
    ifpush(inlevel);			/* Fix up conditional info */

    inlevel++;				/* Create new context */
    strcpy(inpfname, fname);		/* Set new current file name */
    in = fp;				/* Set new current input stream */
    fline = flin;
    line = lin;
    page = pag;
#if DEBUG_PP
    if (debpp) {
	int savch = ch;
	nextch();
	fprintf(fpp, "#include %d: saved char %#o, new file \"%s\", new char %#o\n",
			inlevel, savch, fname, ch);
	return;
    }
#endif
    nextch();				/* Set up new current char */
}

/* D_LINE() - Process #line directive
**
**	Note macro substitution is performed on the input.
*/
static int
d_line()
{
    tlist_t tl;
    PPTOK *pint, *pstr;

    /* Gobble rest of line into tokenlist, expand it, and strip wsp */
    tl = tlwspdel(mexplim(getlinetl(),0), 1);	/* Flush all wsp */

    if (!(pint = tlpcur(tl)))
	return warn("Empty #line"), PPR_CHECKEOL;
    if (pint->pt_typ != T_ICONST)
	return warn("Bad #line number"), PPR_CHECKEOL;
    if (pstr = tokn2p(pint->pt_nxt)) {
	if (pstr->pt_typ != T_SCONST)
	    return warn("Bad #line filename"), PPR_CHECKEOL;
	if (pstr->pt_nxt)
	    return warn("Bad #line syntax"), PPR_CHECKEOL;
    }
    /* Complete winnage, process stuff. */
    fline = atoi(pint->pt_val.cp);	/* Set up number */
    if (pstr)				/* Copy filename w/o quotemarks */
	(void) sltostr(pstr, inpfname, FNAMESIZE-1);

    return PPR_CHECKEOL;
}

/* D_ERROR() - Process #error directive
*/
static int
d_error()
{
    char errstr[120];		/* Max size of err msg */

    /* Gobble in pp-tokens and turn carefully into a string */
    tltostr(getlinetl(), errstr, (int)sizeof(errstr)-1);
    error("#error: %s", errstr);	/* Provoke error! */
    return PPR_CHECKEOL;
}

/* D_PRAGMA() - Process #pragma directive (barf choke vomit puke bletch)
*/
static int
d_pragma()
{
    flushtoeol();
    note("Unknown #pragma");
    return PPR_CHECKEOL;
}

/* GETFILE(cp, n) - Read an include file name into specified loc,
**	using only up to N chars (plus NUL).
**	Returns 0 if name was bad, else '"' for "file" and '>' for <file>.
*/

static int
getfile(f, n)
char *f;
{
    int i, type;
    char *s = f;

    pushch(ch);		/* Set up current char for re-read by scanhwsp */
    scanhwsp();		/* Flush horiz whitespace */
    switch (ch) {
	case '"': type = '"';	break;
	case '<': type = '>';	break;
	case '\n':
	    error("No filename for #include");
	    return 0;
	default:	/* Neither one, it better be some macros */
	    /* Get line of tokens, expand, and trim wsp from ends */
	    tltostr(tlwspdel(mexplim(getlinetl(), 0), 0), f, n);
	    type = 0;
	    if (*f == '"') type = '"';
	    else if (*f == '<') type = '>';
	    if (!type || (f[(i = strlen(f))-1] != type)) {
		error("Bad syntax for #include file: %s", f);
		return 0;
	    }
	    memmove(f, f+1, i -= 2);	/* Shift string up */
	    f[i] = '\0';		/* And tie off properly */
	    return type;
    }

    /* Got first delimiter char, try to find terminating one.
    ** The only thing that stops our scan is EOL, EOF, or terminator.
    ** If more stuff exists in line after terminator, we complain.
    */
    nextch();			/* Skip over 1st delimiter */
    i = n;
    while (--i > 0) {
	if (isceol(ch) || ch == EOF) {
	    type = 0;		/* Failed, term not found */
	    break;
	}
	if (ch != type) {
	    *s++ = ch;		/* Nothing special, store char */
	    nextch();
	    continue;
	}

	/* Char is delimiter */
	*s = '\0';		/* Tie string off! */
	nextch();		/* Move over delimiter */
	if (tskipwsp() != T_EOL) {
	    type = 0;		/* Error, more junk on line */
	    error("Bad #include syntax, junk follows filename");
	}
	break;
    }

    if (i <= 0) {
	error("Filename too long");
	type = 0;
    }
    *s = 0;
    flushtoeol();
    return(type);
}

/* Various misc auxiliaries for directive parsing */

/* TSKIPWSP() - (Token-based) Skip PP whitespace starting with current char.
**	Returns first non-WSP token.
**	For use in directives - complains and stops if non-PP whitespace
**	is seen, specifically \r, \v, \f (CR, VT, FF)
*/
static int
tskipwsp()
{
    while (nextrawpp() == T_WSP) ;
    return rawpp;
}

/* TSKIPLWSP() - (Token-based) Skip Lines & Whitespace starting with
**	current char.
**	Returns first non-WSP, non-EOL token.
**	This skips anything that qualifies as C whitespace.
*/
static int
tskiplwsp()
{
    for (;;) switch (nextrawpp()) {
	case T_WSP:
	case T_EOL:	continue;
	default:	return rawpp;
    }
}

/* FLUSHTOEOL() - Flushes all input up to next EOL, including comments,
**	starting with current token (current char is 1st char of next token)
**	Stops with T_EOL as current token, and current char the 1st
**	after the EOL.
**	Except for EOF, of course.
**	Does it fast.  Ignores string literals since they shouldn't include
**	newlines anyway.
*/
static int
flushtoeol()
{
    if (rawpp == T_EOL) return rawpp;	/* Make sure not already there */
    for (;;) switch (ch) {
	case EOF: return rawpp = T_EOF;
	case '\n': return nextch(), rawpp = T_EOL;
	case '/': if (nextch() == '*')
		    scancomm();
	default: nextch();
    }
}

/* CSKIPLWSP() - (Char-based) Special routine for top-level macro expansion.
**	Starting with current char,
**	scans character stream to find next non-whitespace char,
**	without going through or affecting tokenizer.
**	Whitespace includes line breaks and comments.
**	Returns new current char (first non-whitespace).
**	If first non-LWSP char is '#' and an EOL has been skipped, then
**	a \n is pushed back and returned so that directives will be
**	recognized.  Hack, hack.
*/
static int
cskiplwsp()
{
    int eolseen = 0;
    for (;;) switch (ch) {
	case '/':
	    if (nextch() != '*') {
		pushch(ch);
		return pushstr("/");
	    }
	    scancomm();
	    nextch();
	    break;
	case '\n':
	    ++eolseen;
	default:
	    if (!iscwsp(ch)) {	/* See if any kind of C whitespace */
		if (eolseen && ch == '#') {	/* If possible directive, */
		    pushch(ch);			/* push back char */
		    pushstr("\n");		/* and make EOL be current */
		}
		return ch;
	    }
	    nextch();
    }
}


/* CHECKEOL - finish up after directive has parsed everything it wants.
**	Makes sure that there is nothing but whitespace between the
**	current token and EOL; checks for already being at EOL to avoid
**	gobbling a line by accident.
*/
static void
checkeol()
{
    if (rawpp == T_EOL || rawpp == T_EOF)	/* Check for already at EOL */
	return;
    for (;;) switch (nextrawpp()) {	/* Not there, start skipping wsp */
	case T_WSP: continue;
	default:
	    warn("Non-whitespace following directive");
	    flushtoeol();
	case T_EOL:
	case T_EOF:
	    return;
    }
}

#if 0
/* GETIDREST - Get an identifier string when current char known to be OK.
**	Returns # of chars read in the identifier.
*/
static int
getidrest(str)
char *str;
{
    char *s = str;
    int i = IDENTSIZE-1;		/* Leave room for null terminator */

    *s = ch;				/* First char always goes in */
    while (iscsym(nextch()))		/* If succeeding char is alphanum */
	if (--i > 0) *++s = ch;		/* is legal, add to ident */
    *++s = '\0';			/* null terminate */
    if (i <= 0) {
	note("Identifier truncated: \"%s\"", str);
	i = 1;				/* Set i so return value is correct */
    }
    return IDENTSIZE - i;		/* Return number of chars in string */
}
#endif

/* GETLINETL() - Gobble rest of raw input line into a tokenlist
**	and return that.
**	On return, current token will be T_EOL (or T_EOF) and
**	current char the first one past the EOL.
*/
static tlist_t
getlinetl()
{
    tlist_t tl;

    tlzinit(tl);
    while (nextrawpp() != T_EOL && rawpp != T_EOF)
	tlrawadd(&tl);
    return tl;
}

/* TLWSPDEL(tl) - Removes T_WSP tokens from a tokenlist,
**	to simplify life for other routines.
**	If allf 0, only flushes from start and end.
**	Otherwise, flushes all T_WSP from entire list.
*/
static tlist_t
tlwspdel(tl, allf)
tlist_t tl;
int allf;			/* TRUE to flush all whitespace */
{
    register PPTOK *p, *lastp = NULL;

    for (p = tlpcur(tl); p;)
	if (p->pt_typ == T_WSP
	  && (allf || p == tl.tl_head || p == tl.tl_tail)) {
	    if (lastp) lastp->pt_nxt = p->pt_nxt;	/* Fix up prev */
	    else tl.tl_head = tokn2p(p->pt_nxt);
	    if (!(p = tokn2p(p->pt_nxt)))		/* Fix up tail */
		tl.tl_tail = (lastp ? lastp : tl.tl_head);
	} else lastp = p, p = tokn2p(p->pt_nxt);	/* Just pass non-wsp */
    return tl;
}

/* TLMAKE(typ, val) - Make a tokenlist consisting of just one token,
**	with the given token-type and value.
**	This routine is at the end of CCPP for now to avoid lots of warning
**	messages about mismatched argument types.
*/
static tlist_t
tlmake(typ, val)
int typ;
union pptokval val;
{
    tlist_t tl;
    static PPTOK ztok;
    *(tl.tl_head = tl.tl_tail = tokpcre()) = ztok;
    tl.tl_head->pt_typ = typ;
    tl.tl_head->pt_val = val;
    return tl;
}

