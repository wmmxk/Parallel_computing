//When you set the numthreadsBlock = 64 or smaller, you can not get the corret answer; still the index is not correct
// when testing the code, k should be an odd number because k is assumed to be odd when computing the truth
#include <stdio.h>
#include <cuda.h>

__global__ void parallel_max_each_chunk(float *dmaxarr, int *dmaxstart, int *dmaxend, float * darr,  int n, int k);


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

		const int numthreadsBlock = 512;
		int numChunk;
		numChunk = ( n + numthreadsBlock - 1)/numthreadsBlock;
		float *maxarr = (float *)malloc(numChunk * sizeof(float));
  int *maxstart = (int *)malloc(numChunk * sizeof(int));
  int *maxend = (int *)malloc(numChunk * sizeof(int));
  
		int numBlock = numChunk;

		// declare GPU memory pointers
		float *darr, * dmaxarr;
		int *dmaxstart, *dmaxend;
		cudaMalloc((void **)&darr, n*sizeof(float));
		cudaMalloc((void **)&dmaxarr, numChunk*sizeof(float));
		cudaMalloc((void **)&dmaxstart, numChunk*sizeof(int));
		cudaMalloc((void **)&dmaxend, numChunk*sizeof(int));

		cudaMemcpy(darr, arr, n*sizeof(float), cudaMemcpyHostToDevice);


		dim3 dimGrid(numBlock,1);
		dim3 dimBlock(numthreadsBlock,1,1);

		parallel_max_each_chunk<<<dimGrid,dimBlock,(3*numthreadsBlock)*sizeof(float)>>>(dmaxarr,dmaxstart,dmaxend, darr, n, k);
		cudaThreadSynchronize();
		cudaMemcpy(maxarr, dmaxarr, numChunk*sizeof(float), cudaMemcpyDeviceToHost);
		cudaMemcpy(maxstart, dmaxstart, numChunk*sizeof(int), cudaMemcpyDeviceToHost);
		cudaMemcpy(maxend, dmaxend, numChunk*sizeof(int), cudaMemcpyDeviceToHost);

		//truth
				float *smaxarr = (float *)malloc(numChunk*sizeof(float));
				for (i = 0; i < numChunk; i ++) {
        smaxarr[i] = (i)*numthreadsBlock +k  <=n? arr[i*numthreadsBlock + k/2 ]:0; // k is an odd number
				}

		//check the results
				bool judge = true;
				for (i=0; i < numBlock; i++) {
						printf("max of block  %d,  %f %f\n ", i, smaxarr[i], maxarr[i]);
						judge = judge && (smaxarr[i] == maxarr[i]);
				}
				printf("\n--------correct or wrong---------\n");
				printf(judge ? "right\n": "wrong\n");

				// This is for developing: print out the 1d array

				printf("\n--------1d array---------\n");
    if ( n < 15) {
				for (i=0; i < n; i++) {
						printf("element  %d,  %f\n ", i, arr[i]);
				}
    }
		// check the exit state of CUDA code
		cudaError_t error = cudaGetLastError();
		if (error !=cudaSuccess) {
				printf("CUDA error: %s\n", cudaGetErrorString(error));
		}

		//free gpu memory
		cudaFree(dmaxarr);
		cudaFree(darr);
  int startend[2];
		float bigmax;

  find_max_from_blocks( maxarr, maxstart, maxend,  numBlock,startend, &bigmax);
  printf("burst start from %d end at %d; max-mean is %f\n", startend[0], startend[1], bigmax);
		return 0;
}

__global__ void parallel_max_each_chunk(float *dmaxarr, float *dmaxstart, float *dmaxend, float * darr, int n,int k) {

  // declare three array for the maximum found by each thread 
  extern __shared__ float mymaxvals[];
		
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
									mymaxvals[tid+blockDim.x] = perstart;
									mymaxvals[tid+blockDim.x*2] = perlen;
						} else {
        xbar = ( (perlen-1) * xbar + darr[perend] ) / perlen;
						}
						//update the mymaxvals[tid] if the next subsequence in a thread has a higher mean
						if (xbar >  mymaxvals[tid]) {
         mymaxvals[tid] = xbar;
									mymaxvals[tid+blockDim.x] = perstart;
									mymaxvals[tid+blockDim.x*2] = perlen;
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
						   	mymaxvals[tid] = 	mymaxvals[tid+s]; 
          mymaxvals[tid+blockDim.x] =  mymaxvals[tid+blockDim.x +s ];
          mymaxvals[tid+blockDim.x*2] =  mymaxvals[tid+blockDim.x*2 +s ];
							}	
     }
     __syncthreads();
  }
  // the maximum among the mymaxvals in this block
 if(tid == 0) {
  dmaxarr[blockIdx.x] = mymaxvals[0];
		dmaxstart[blockIdx.x] =  mystartmaxes[100];
		dmaxend[blockIdx.x] =  myendmaxes[200];
  }
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
