
/* declare a 1d array and find the maximum of each chunk using reduce method. No shared memory is used
	*
	*chunksize must be an exponential of 2
how to compile: nvcc para

when n is 600,000 or more, the results are not correct probably because there is not enough threads.

The 1d array used for testing is a sequence from 0 to n-1.

How to deal with the incomplete chunk:
 
     if (tid < s && myId < n) { //myId >=n the incomplete chunk is less than blockDim.x/2) 
						 float right_counterpart = (myId+s) >= n? 0:darr[myId+s]; //if the right_counterpart is missing, use 0

	*/

#include <stdio.h>
#include <cuda.h>


float * serial_max_each_chunk(float maxarr[], float arr[], int chunkSize, int n);
__global__ void parallel_max_each_chunk(float *dmaxarr, float * darr, int chunkSize, int n);


int main(int argc, char **argv) {
//generate a 1d array
int n = atoi(argv[1]);
float *arr = (float*) malloc(n*sizeof(float));
int i;
for (i =0; i < n; i++) {
   arr[i] = (float)i/2.0f;			
}

const int chunkSize = 512;
int numChunk = (n + chunkSize -1)/chunkSize;

float *maxarr = (float *)malloc(numChunk * sizeof(float));

// declare GPU memory pointers
float *darr, * dmaxarr;
cudaMalloc((void **)&darr, n*sizeof(float));
cudaMalloc((void **)&dmaxarr, numChunk*sizeof(float));
cudaMemcpy(darr, arr, n*sizeof(float), cudaMemcpyHostToDevice);

dim3 dimGrid(numChunk,1);
dim3 dimBlock(chunkSize,1,1);


parallel_max_each_chunk<<<dimGrid,dimBlock>>>(dmaxarr, darr, chunkSize,n);
cudaThreadSynchronize();
cudaMemcpy(maxarr, dmaxarr, numChunk*sizeof(float), cudaMemcpyDeviceToHost);



for (i=0; i < numChunk; i++) {
printf("%d maximum: %f\n",i,maxarr[i]);
}

float * smaxarr = (float *) malloc(numChunk * sizeof(float));
printf("\nserial solution\n");
serial_max_each_chunk(smaxarr, arr, chunkSize, n);

bool judge = true;
for (i=0; i < numChunk; i++) {
printf("%d maximum: %f\n",i,smaxarr[i]);
judge = judge && (smaxarr[i] == maxarr[i]);
}

printf("\n--------correct or wrong---------\n");
printf(judge ? "right\n": "wrong\n");



// check the exit state of CUDA code
cudaError_t error = cudaGetLastError();
if (error !=cudaSuccess) {
  printf("CUDA error: %s\n", cudaGetErrorString(error));
  exit(-1);
}






return 0;
}


float * serial_max_each_chunk(float maxarr[], float arr[], int chunkSize, int n) {
		int numChunk = (n + chunkSize - 1)/chunkSize; 
		int i,j;
  for (i = 0; i < numChunk; i++){
				 maxarr[i] = -3.0;
					for (j = i * chunkSize; j < (i+1)*chunkSize; j++) {
									if (j >= n) { break;
									} else { 
											if (maxarr[i] < arr[j]) { maxarr[i] = arr[j];}
									}
					}   
		}
		return maxarr;
}



__global__ void parallel_max_each_chunk(float *dmaxarr, float * darr, int chunkSize, int n) {
  int myId = blockIdx.x * blockDim.x + threadIdx.x;
  int tid = threadIdx.x;

  for (int s = blockDim.x/2; s > 0; s>>=1) {
     if (tid < s && myId < n) { //myId >=n the incomplete chunk is less than blockDim.x/2) 
						 float right_counterpart = (myId+s) >= n? 0:darr[myId+s]; //if the right_counterpart is missing, use 0
       darr[myId]= right_counterpart > darr[myId]? right_counterpart : darr[myId];
     }
     __syncthreads();
  }
  if(tid == 0) {
  dmaxarr[blockIdx.x] = darr[myId];
  }
}

