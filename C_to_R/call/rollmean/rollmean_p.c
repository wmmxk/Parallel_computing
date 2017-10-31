#include <omp.h>
#include <R.h>
#include <Rinternals.h>
SEXP rollmean_p (SEXP Rvec, SEXP window) {
   int i,j, n,k; // n is the length of the input vec; k is window size; 
   double *vec;
   vec = REAL(Rvec);
   n = length(Rvec);

			window = coerceVector(window, INTSXP);
			k = INTEGER(window) [0];
   
   // declare a RStruct to store the results
 		SEXP Rmeans;
   PROTECT(Rmeans = allocVector(REALSXP, n- k +1 ));
   #pragma omp parallel for
   for (i=0; i < n-k+1; i++) {
     REAL(Rmeans)[i] = vec[i];
     for (j=1; j < k; j++) {
						  REAL(Rmeans)[i] += vec[i+j];
					}
					REAL(Rmeans)[i] /= k;
			}
			UNPROTECT(1);
   return Rmeans;
}
