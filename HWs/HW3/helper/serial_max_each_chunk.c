/* declare a 1d array and find the maximum of each chunk
	*
	*
	* If you compile using g++, you need to include the cstdlib for malloc
	*/

#include <stdio.h>
#include <cstdlib>

float * serial_max_each_chunk(float maxarr[], float arr[], int chunkSize, int n); 
int main(int argc, char **argv) {

int n = atoi(argv[1]);
float *arr = (float*) malloc(n*sizeof(float));

for (int i =0; i < n; i++) {
   arr[i] = (float)i/2.0f;			
}

const int chunkSize = 5;
int numChunk = (n + chunkSize -1)/chunkSize;

float *maxarr = (float *)malloc(numChunk * sizeof(float));


serial_max_each_chunk(maxarr, arr,chunkSize,n);
for (int i =0; i < numChunk; i++){
printf("%d element %.2f\n",i, maxarr[i]);
}

// print out the element in the 1d array
printf("---------------- \n");

for (int j = 0; j < n; j++)
{
printf("%d element %.2f \n", j, arr[j]);

}

return 0;
}

float * serial_max_each_chunk(float maxarr[], float arr[], int chunkSize, int n) {
int numChunk = (n + chunkSize - 1)/chunkSize; 
	for (int i = 0; i < numChunk; i++){
		maxarr[i] = -3.0;
			for (int j = i * chunkSize; j < (i+1)*chunkSize; j++) {
       if (j >= n) { break;
							} else { 
         if (maxarr[i] < arr[j]) { maxarr[i] = arr[j];}
							}
		 }
printf("%d element %.1f \n", i, maxarr[i]);
}
return maxarr;
}
