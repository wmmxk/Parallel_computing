#include <R.h>
#include <Rinternals.h>

SEXP vecSum (SEXP Rvec) {
   int i, n;
   double *vec, value = 0;
   vec = REAL(Rvec);
   n = length(Rvec);

   for (i=0; i < n; i++) 
		   value += vec[i];

   printf("The value is : %4.6f \n",value);
   return R_NilValue;



}
