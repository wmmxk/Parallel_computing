//think about column major and row major
#include <omp.h>
void mat_mul_c_s(double *X, int *dimX, double *Y, int *dimY, double *ans) {
   double sum;
			int i, j, k;
			int nrX = dimX[0], ncX = dimX[1], nrY = dimY[0], ncY = dimY[1];

			for (i=0; i < nrX; i++) {
      for (j=0; j < ncY; j++) {
          sum = 0;
										for (k=0; k < ncX; k++) {
											  sum += X[i+nrX*k]*Y[k+nrY*j];
										}
										ans[i+nrX*j] = sum;
						}
			}
}


void mat_mul_c_p(double *X, int *dimX, double *Y, int *dimY, double *ans) {
   double sum;
			int i, j, k;
			int nrX = dimX[0], ncX = dimX[1], nrY = dimY[0], ncY = dimY[1];

  #pragma omp parallel 
		{  // this brace can not be put in the same line as pragma directive
  #pragma omp for
			for (i=0; i < nrX; i++) {
      for (j=0; j < ncY; j++) {
          sum = 0;
										for (k=0; k < ncX; k++) {
											  sum += X[i+nrX*k]*Y[k+nrY*j];
										}
										ans[i+nrX*j] = sum;
						}
			}
		}
}


