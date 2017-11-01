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



int main() {
    int z[8] = {5,12,13, 6, 2, 22, 15,3};

	int m, wherem;

	max(z+4,4,&m,&wherem);

	printf("the max value was %d\n",m);
	printf("it occured at index %d\n", wherem);


}
