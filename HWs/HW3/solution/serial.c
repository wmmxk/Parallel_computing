#include <stdio.h>
#include <stdlib.h>

float mean(float *y, int s, int e){
  int i; 
		float tot =0;
		for (i=s; i<=e; i++) tot += y[i];
		return tot / (e -s + 1);
}

void s_max_burst(float *arr, int n, int k);

int main(int argc, char **argv) {
				int n = atoi(argv[1]);
				int k = atoi(argv[2]); 
				
		//generate a 1d array
				float *arr = (float*) malloc(n*sizeof(float));
				int i;
				for (i = n; i > 0; i--) {
							arr[n-i] = (float)(rand() % 50);			
				}
    s_max_burst(arr, n,k);
				for (i=0; i<n; i++) printf("%d element %f\n", i, arr[i]);
	 	return 0;
}


void s_max_burst(float *arr, int n, int k) {
			float mymaxval = -1;
   int perstart, perlen,perend, mystart, myend;
			float xbar;
   for (perstart = 0; perstart <= n-k; perstart++) {
     for (perlen = k; perlen <= n - perstart; perlen++) {
        perend = perstart + perlen -1;
					   xbar = mean(arr, perstart, perend);
					if (xbar > mymaxval) {
        mymaxval = xbar;
        mystart = perstart;
								myend = perend;
					}
					}
			}
   printf("burst start from %d end %d, max-mean is %f\n", mystart, myend,mymaxval);
}
