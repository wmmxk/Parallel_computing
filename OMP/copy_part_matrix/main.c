/* This code is to show how to copy the few columns of a matrix to another matrix;
 * how to compile and run:
 *   gcc -fopenmp ./main.c
 *   ./a.out
 *
 *You don't have to specify which thread does which row
 *
 *
 *
 */
#include<omp.h>
#include<stdio.h>
#include<stdlib.h>
#include<string.h>

int onedim(int row, int col, int nCols) { return row * nCols + col; }

// nColsSubM consecutive columns of m will be extracted, starting with
// column firstCol
int *getCols(int *m, int nRowsM, int nColsM, int firstCol, int nColsSubM) {
   int *subMat;
   subMat = malloc(nRowsM * nColsSubM * sizeof(int));
   #pragma omp parallel

   {  int *startFrom,*startTo;
      #pragma omp for
      for (int row = 0; row < nRowsM; row++) {
         startFrom = m+row*nColsM+firstCol;
         startTo = subMat + row*nColsSubM;
         memcpy(startTo, startFrom, nColsSubM*sizeof(int));
      }
   }
   return subMat;
}

int main() {
   // intended as a 4x3 matrix
   int z[12] = {5,12,13,6,2,22,15,3,1,2,3,4};

   // print the original matrix
   for (int i=0; i < 4; i++) {
      printf("%d %d %d \n", z[3*i],z[3*i+1],z[3*i+2]);
   }
   printf("\n");


   omp_set_num_threads(2);
   // extract the last 2 cols
   int *outM = getCols(z,4,3,1,2);
   // check output
   for (int i = 0; i < 4; i++) {
      printf("%d %d\n",outM[2*i],outM[2*i+1]);
   }
}
