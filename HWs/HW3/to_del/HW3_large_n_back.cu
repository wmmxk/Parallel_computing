//When you set the numthreadsBlock = 64 or smaller, you can not get the corret answer; still the index is not correct
// when testing the code, k should be an odd number because k is assumed to be odd when computing the truth
#include <stdio.h>
#include <cuda.h>

__global__ void max_each_block(float *dmaxarr, int *dmaxstart, int *dmaxend, float * darr,  int n, int k);
void maxburst(float *x, int n, int k, int *startend, float *bigmax);
void find_max_from_blocks(float *maxarr, int *maxstart, int *maxend, int numBlock,int *startend, float *bigmax);

int main(int argc, char **argv) {
				int n = atoi(argv[1]);
				int k = atoi(argv[2]); 
				
		//generate a 1d array
				float *arr = (float*) malloc(n*sizeof(float));
				int i;
				for (i = n; i > 0; i--) {
							arr[n-i] = (float)i;			
				}

			int startend[2];
			float bigmax;

   maxburst(arr, n,k, startend, &bigmax); 
	 	return 0;
}


__global__ void max_each_block(float *dmaxarr, int *dmaxstart, int *dmaxend, float * darr, int n,int k) {
 // declare three array for the maximum found by each thread 
  extern __shared__ float sh[];
  float *mymaxvals = sh;
  int *mystartmaxes = (int *)&mymaxvals[blockDim.x];
  int *myendmaxes = (int *)&mystartmaxes[blockDim.x];

  int perstart = threadIdx.x + blockDim.x * blockIdx.x;
  int perlen, perend;
  double xbar; // a temporay variable used when computing mean of subsequence

  int i, tid = threadIdx.x;

  if (perstart <= n-k) {
    for (perlen = k ; perlen <= n - perstart ; perlen++) {
      perend = perstart + perlen - 1;
      //compute the mean of subsequence incrementally
      if (perlen ==k) {
         xbar = 0;
         for ( i = perstart; i <= perend; i++) {
           xbar += darr[i];
         }
         xbar /= (perend - perstart + 1);
         mymaxvals[tid] = xbar;
         mystartmaxes[tid] = perstart;
         myendmaxes[tid] = perend;
      } else {
        xbar = ( (perlen-1) * xbar + darr[perend] ) / perlen;
      }
      //update the mymaxvals[tid] if the next subsequence in a thread has a higher mean
      if (xbar >  mymaxvals[tid]) {
         mymaxvals[tid] = xbar;
         mystartmaxes[tid] = perstart;
         myendmaxes[tid] = perend;
      }
    }
  } else {
    mymaxvals[tid] = 0;//initialize it with the smallest number
  }
  __syncthreads(); //sync to make sure each thread in this block has done with the for loop
//  // get the highest among the mymaxvals using reduce
    for (int s = blockDim.x/2; s > 0; s>>=1) {
     if (tid < s ) {
       if(mymaxvals[tid+s] > mymaxvals[tid]) {
          mymaxvals[tid] =  mymaxvals[tid+s];
          mystartmaxes[tid] = mystartmaxes[tid + s];
          myendmaxes[tid] = myendmaxes[tid + s];
       }
     }
     __syncthreads();
  }
  // the maximum among the mymaxvals in this block
 if(tid == 0) {
  dmaxarr[blockIdx.x] = mymaxvals[0];
  dmaxstart[blockIdx.x] =  mystartmaxes[0];
  dmaxend[blockIdx.x] =  myendmaxes[0];
  }
}

void maxburst(float *x, int n, int k, int *startend, float *bigmax) {
		const int numthreadsBlock = 1024;
		int numBlock = ( n + numthreadsBlock - 1)/numthreadsBlock;
		//declare arrays on cpu to store the results from the kernel
		float *maxarr = (float *)malloc(numBlock * sizeof(float));
  int *maxstart = (int *)malloc(numBlock * sizeof(int));
  int *maxend = (int *)malloc(numBlock * sizeof(int));

		// declare GPU memory pointers
		float *darr, * dmaxarr;
		int *dmaxstart, *dmaxend;
		cudaMalloc((void **)&darr, n*sizeof(float));
		cudaMalloc((void **)&dmaxarr, numBlock*sizeof(float));
		cudaMalloc((void **)&dmaxstart, numBlock*sizeof(int));
		cudaMalloc((void **)&dmaxend, numBlock*sizeof(int));

		//copy the input x to device
		cudaMemcpy(darr, x, n*sizeof(float), cudaMemcpyHostToDevice);
  // execution configuration
		dim3 dimGrid(numBlock,1);
		dim3 dimBlock(numthreadsBlock,1,1);
  //call the kernel
		max_each_block<<<dimGrid,dimBlock,(3*numthreadsBlock)*sizeof(float)>>>(dmaxarr,dmaxstart,dmaxend, darr, n, k);
		cudaThreadSynchronize();
		//copy the results from device to cpu
		cudaMemcpy(maxarr, dmaxarr, numBlock*sizeof(float), cudaMemcpyDeviceToHost);
		cudaMemcpy(maxstart, dmaxstart, numBlock*sizeof(int), cudaMemcpyDeviceToHost);
		cudaMemcpy(maxend, dmaxend, numBlock*sizeof(int), cudaMemcpyDeviceToHost);
  //free memory on device
		cudaFree(darr);
		cudaFree(dmaxarr);
		cudaFree(dmaxstart);
		cudaFree(dmaxend);

  find_max_from_blocks( maxarr, maxstart, maxend,  numBlock,startend, bigmax);
  printf("burst start from %d end at %d; max-mean is %f\n", startend[0], startend[1], *bigmax);

}

void find_max_from_blocks(float *maxarr, int *maxstart, int *maxend, int numBlock,int *startend, float *bigmax) {
	*bigmax = 0;
	for (int i = 0; i < numBlock; i++) {
   if (*bigmax < maxarr[i]) {
      *bigmax = maxarr[i];
      startend[0] = maxstart[i];
     	startend[1] = maxend[i];
			}	
 }
}
