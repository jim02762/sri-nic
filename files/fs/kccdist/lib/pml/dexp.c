/* 09-Apr-88 KLH: modified to reflect change in standard modf() facility
**	(2nd arg is now a ptr to double, not ptr to int)
*/
/*
 *	+++ NAME +++
 *
 *	 DEXP   Double precision exponential
 *
 *	+++ INDEX +++
 *
 *	 DEXP
 *	 machine independent routines
 *	 math libraries
 *
 *	+++ DESCRIPTION +++
 *
 *	Returns double precision exponential of double precision
 *	floating point number.
 *
 *	+++ USAGE +++
 *
 *	 double dexp(x)
 *	 double x;
 *
 *	+++ REFERENCES +++
 *
 *	Fortran IV plus user's guide, Digital Equipment Corp. pp B-3
 *
 *	Computer Approximations, J.F. Hart et al, John Wiley & Sons,
 *	1968, pp. 96-104.
 *
 *	+++ RESTRICTIONS +++
 *
 *	Inputs greater than LN(MAX_POS_DBLF) result in overflow.
 *	Inputs less than LN(MIN_POS_DBLF) result in underflow.
 *
 *	The maximum relative error for the approximating polynomial
 *	is 10**(-16.4).  However, this assumes exact arithmetic
 *	in the polynomial evaluation.  Additional rounding and
 *	truncation errors may occur as the argument is reduced
 *	to the range over which the polynomial approximation
 *	is valid, and as the polynomial is evaluated using
 *	finite-precision arithmetic.
 *
 *	+++ PROGRAMMER +++
 *
 *	 Fred Fish
 *	 Goodyear Aerospace Corp, Arizona Div.
 *	 (602) 932-7000 work
 *	 (602) 894-6881 home
 *
 *	+++ INTERNALS +++
 *
 *	Computes exponential from:
 *
 *		EXP(X)	=	2**Y  *  2**Z  *  2**W
 *
 *	Where:
 *
 *		Y	=	INT ( X * LOG2(e) )
 *
 *		V	=	16 * FRAC ( X * LOG2(e))
 *
 *		Z	=	(1/16) * INT (V)
 *
 *		W	=	(1/16) * FRAC (V)
 *
 *	Note that:
 *
 *		0 =< V < 16
 *
 *		Z = {0, 1/16, 2/16, ...15/16}
 *
 *		0 =< W < 1/16
 *
 *	Then:
 *
 *		2**Z is looked up in a table of 2**0, 2**1/16, ...
 *
 *		2**W is computed from an approximation:
 *
 *			2**W	=  (A + B) / (A - B)
 *
 *			A	=  C + (D * W * W)
 *
 *			B	=  W * (E + (F * W * W))
 *
 *			C	=  20.8137711965230361973
 *
 *			D	=  1.0
 *
 *			E	=  7.2135034108448192083
 *
 *			F	=  0.057761135831801928
 *
 *		Coefficients are from HART, table #1121, pg 206.
 *
 *		Effective multiplication by 2**Y is done by a
 *		floating point scale with Y as scale argument.
 *
 *	---
 */

/*)LIBRARY
*/

#include <stdio.h>
#include "c:pmluse.h"
#include "pml.h"

# define C  20.8137711965230361973	/* Polynomial approx coeff.	*/
# define D  1.0				/* Polynomial approx coeff.	*/
# define E  7.2135034108448192083	/* Polynomial approx coeff.	*/
# define F  0.057761135831801928	/* Polynomial approx coeff.	*/


/************************************************************************
 *									*
 *	This table is fixed in size and reasonably hardware		*
 *	independent.  The given constants were generated on a 		*
 *	DECSYSTEM 20 using double precision FORTRAN.			*
 *									*
 ************************************************************************
 */

static double fpof2tbl [] = {
    1.00000000000000000000,		/*    2 ** 0/16		*/
    1.04427378242741384020,		/*    2 ** 1/16		*/
    1.09050773266525765930,		/*    2 ** 2/16		*/
    1.13878863475669165390,		/*    2 ** 3/16		*/
    1.18920711500272106640,		/*    2 ** 4/16		*/
    1.24185781207348404890,		/*    2 ** 5/16		*/
    1.29683955465100966610,		/*    2 ** 6/16		*/
    1.35425554693689272850,		/*    2 ** 7/16		*/
    1.41421356237309504880,		/*    2 ** 8/16		*/
    1.47682614593949931110,		/*    2 ** 9/16		*/
    1.54221082540794082350,		/*    2 ** 10/16	*/
    1.61049033194925430820,		/*    2 ** 11/16	*/
    1.68179283050742908600,		/*    2 ** 12/16	*/
    1.75625216037329948340,		/*    2 ** 13/16	*/
    1.83400808640934246360,		/*    2 ** 14/16	*/
    1.91520656139714729380		/*    2 ** 15/16	*/
};

double dexp(x)
double x;
{
    double w, v, a, b, t, wpof2, zpof2, fabs(), dscale(), modf();
    double y, index;

    if (x > LN_MAXPOSDBL) {
	pmlerr(DEXP_OVERFLOW);
	return (MAX_POS_DBLF);
    } else if (x <= LN_MINPOSDBL) {
	pmlerr(DEXP_UNDERFLOW);
	return (MIN_POS_DBLF);
    } else {
	t = x * LOG2E;
	v = 16.0 * modf(t, &y);
	modf(fabs(v), &index);
	if (x < 0.0) {
	    zpof2 = 1.0 / fpof2tbl[(int)index];
	} else {
	    zpof2 = fpof2tbl[(int)index];
	}
	w = modf(v, &index) / 16.0;
	a = C + (D * w * w);
	b = w * (E + (F * w * w));
	wpof2 = (a + b) / (a - b);
	return dscale((wpof2 * zpof2), (int)y);
    }
}
