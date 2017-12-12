#include <stdio.h>
#include <stdlib.h>
#include <omp.h>

void rollmean_s(float* arr, float* meanarr, int n, int k) {
   #pragma omp for
   for (int i=0; i < n-k+1; i++) {
     meanarr[i] = arr[i];
     for (int j=1; j < k; j++) {
						  meanarr[i] += arr[i+j];
					}
					meanarr[i] /= k;
			}
}

void display(float * arr, int n){
	for (int i =0; i< 2; i++) {
		printf("%f  ", arr[i]);
	}
	printf("%f \n", arr[n-1]);
}


int main(int argc, char *argv[]){
	int n = atoi(argv[1]);
  int k = atoi(argv[2]);

	float *arr = (float*) malloc(n*sizeof(float));
	float *meanarr = (float *) malloc((n-k+1)*sizeof(float));

	for (int i =0; i <n; i++) {
     arr[i] = i;
  }
  rollmean_s(arr, meanarr,n,k);
	  display(arr, n);
		display(meanarr,n-k+1);
return 0;
}
