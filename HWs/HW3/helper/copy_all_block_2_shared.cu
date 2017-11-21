/* declare a 1d array and copy it to each block
	  each thread find the maximum of the 1d array. This will be replaced by the inner loop in HW 
	  use reduce sum up the mymaximum found by each thread
	  finally each block return a sum of maximum.		
	
  parallel_max_each_chunk<<<dimGrid,dimBlock,(n+numthreadsBlock)*sizeof(float)>>>(dmaxarr, darr, n);
     It seems you can request less memory
	*/
#include <stdio.h>
#include <cuda.h>

__global__ void parallel_max_each_chunk(float *dmaxarr, float * darr,  int n);


int main(int argc, char **argv) {
//generate a 1d array
int n = atoi(argv[1]);
float *arr = (float*) malloc(n*sizeof(float));
int i;
for (i =0; i < n; i++) {
   arr[i] = (float)i/2.0f;			
}

const int numthreadsBlock = 8;
int numChunk = atoi(argv[2]);

float *maxarr = (float *)malloc(numChunk * sizeof(float));

// declare GPU memory pointers
float *darr, * dmaxarr;
cudaMalloc((void **)&darr, n*sizeof(float));
cudaMalloc((void **)&dmaxarr, numChunk*sizeof(float));
cudaMemcpy(darr, arr, n*sizeof(float), cudaMemcpyHostToDevice);

dim3 dimGrid(numChunk,1);
dim3 dimBlock(numthreadsBlock,1,1);

parallel_max_each_chunk<<<dimGrid,dimBlock,(n+numthreadsBlock)*sizeof(float)>>>(dmaxarr, darr, n);
cudaThreadSynchronize();
cudaMemcpy(maxarr, dmaxarr, numChunk*sizeof(float), cudaMemcpyDeviceToHost);


//check the results
bool judge = true;
for (i=0; i < numChunk; i++) {
printf("%d sum of max %f\n ", i, maxarr[i]);
judge = judge && ( (n-1)*numthreadsBlock/2.0 == maxarr[i]);
}
printf("\n--------correct or wrong---------\n");
printf(judge ? "right\n": "wrong\n");

// check the exit state of CUDA code
cudaError_t error = cudaGetLastError();
if (error !=cudaSuccess) {
  printf("CUDA error: %s\n", cudaGetErrorString(error));
}


for (i=0; i < n; i++) {
printf("%d element  %f\n ", i, arr[i]);
}

return 0;
}

__global__ void parallel_max_each_chunk(float *dmaxarr, float * darr, int n) {
  int tid = threadIdx.x;
  int j;
		int chunkSize = (n+blockDim.x-1)/blockDim.x;

  extern __shared__ float sdata[];
  for (j = 0; j < chunkSize; j++) {
			  if (tid * chunkSize +j <n)
     sdata[tid*chunkSize + j ] = darr[tid*chunkSize + j];
			}
  __syncthreads();


 // each thread find the maximum of the sdata 
  extern __shared__ float mymaxval[];

		int mymax = 0;
		for ( j =0; j < n; j++)
		{
    if (mymax < sdata[j]) { mymax = sdata[j];}
		}
  mymaxval[tid] = mymax;

//do reduce on the chunk of array on the shared memory
  for (int s = blockDim.x/2; s > 0; s>>=1) {
     if (tid < s ) {
       mymaxval[tid] += mymaxval[tid+s]; 
     }
     __syncthreads();
  }

// the sum of the maximum found by each thread
  if(tid == 0) {
  dmaxarr[blockIdx.x] = mymaxval[0];
  }
}

