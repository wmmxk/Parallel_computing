/* This is an example in quiz 3, return the maximum value and index
 *
  */
#include <omp.h>
#include <stdio.h>
#include <stdlib.h>

void max(int *x, int nx, int *mx, int *whrmx) {
   *mx = x[0];
   *whrmx = 0;
   for (int i =1; i<nx; i++) {
		   if (x[i] > *mx) {
              *mx = x[i];
			  *whrmx = i;
		   }
   }
}
void wheremax(int *x, int nx, int *mx, int *whrmx) {
    int nth, chunk;
	int *maxvals, *maxivals;
    #pragma omp parallel 
	{
      #pragma omp single
	  {
			maxvals = (int*) malloc(nth*sizeof(int));
			maxivals = (int*) malloc(nth*sizeof(int));
            nth = omp_get_num_threads();
	        chunk = nx/nth;
	  } 
      int me = omp_get_thread_num();
	  int firsti = me*chunk;
	  max( x+firsti,chunk, maxvals+me,maxivals+me );

     #pragma omp barrier
	}
    max(maxvals, nth, mx, whrmx);
	*whrmx = *whrmx * chunk + maxivals[*whrmx];
}

int main() {
    int z[8] = {5,12,13, 6, 2, 22, 15,3};

	int m, wherem;

	omp_set_num_threads(4);

	wheremax(z,8,&m,&wherem);

	printf("the max value was %d\n",m);
	printf("it occured at index %d\n", wherem);


}
