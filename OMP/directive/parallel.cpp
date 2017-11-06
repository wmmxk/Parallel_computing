// this code is to show every line of code is run each thread unless you specify

#include <omp.h>
#include <stdio.h>

int main() {
   
	int i=0;
	int j;
    #pragma omp parallel
	{
            int nth = omp_get_num_threads();
			printf("Number of threads in total, %d\n", nth);
//            #pragma omp for
			for (j=1; j < 3; j++) {
					printf("The value of i  %d,j  %d \n", i ,j );
			} 


	}
    return 0;
}
