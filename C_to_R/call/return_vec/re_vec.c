//source: http://www.biostat.jhsph.edu/~bcaffo/statcomp/files/dotCall.pdf
#include <R.h>
#include <Rinternals.h>
SEXP ab(SEXP Ra, SEXP Rb){
int i, a, b;
SEXP Rval;
Ra = coerceVector(Ra, INTSXP);
Rb = coerceVector(Rb, INTSXP);
a = INTEGER(Ra)[0];
b = INTEGER(Rb)[0];
PROTECT(Rval = allocVector(INTSXP, b - a + 1));
for (i = a; i <= b; i++)
INTEGER(Rval)[i - a] = i;
UNPROTECT(1);
return Rval;
}
