// n should be less than 10000 when k==3
#include <stdio.h>
#include <cuda.h>

__global__ void parallel_max_each_chunk(float *dmaxarr, float * darr,  int n, int k);


int main(int argc, char **argv) {
				int n = atoi(argv[1]);
				int k = atoi(argv[2]); 
				
		//generate a 1d array
				float *arr = (float*) malloc(n*sizeof(float));
				int i;
				for (i = n; i > 0; i--) {
							arr[n-i] = (float)i;			
				}

		const int numthreadsBlock = 1024;
		int numChunk;
		numChunk = ( n + numthreadsBlock - 1)/numthreadsBlock;
		float *maxarr = (float *)malloc(numChunk * sizeof(float));

  int numBlock = numChunk;

		// declare GPU memory pointers
		float *darr, * dmaxarr;
		cudaMalloc((void **)&darr, n*sizeof(float));
		cudaMalloc((void **)&dmaxarr, numChunk*sizeof(float));
		cudaMemcpy(darr, arr, n*sizeof(float), cudaMemcpyHostToDevice);

		dim3 dimGrid(numBlock,1);
		dim3 dimBlock(numthreadsBlock,1,1);

		parallel_max_each_chunk<<<dimGrid,dimBlock,(n+3*numthreadsBlock)*sizeof(float)>>>(dmaxarr, darr, n, k);
		cudaThreadSynchronize();
		cudaMemcpy(maxarr, dmaxarr, numChunk*sizeof(float), cudaMemcpyDeviceToHost);

  //truth
				float *smaxarr = (float *)malloc(numChunk*sizeof(float));
				for (i = 0; i < numChunk; i ++) {
        smaxarr[i] = i*numthreadsBlock + k/2 <=n? arr[i*numthreadsBlock + k/2 ]:0; // k is an odd number
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
		return 0;
}

__global__ void parallel_max_each_chunk(float *dmaxarr, float * darr, int n,int k) {
 	int i, tid = threadIdx.x;
		//copy the whole series to shared memory
  //always round up and if n is a multiple of blockDim.x no rounding
		int chunkSize = (n+blockDim.x-1)/blockDim.x;
  extern __shared__ float sdata[];
  for (i = 0; i < chunkSize; i++) {
			  if (tid * chunkSize + i <n)
     sdata[tid*chunkSize + i ] = darr[tid*chunkSize + i];
			}
  __syncthreads();

  // declare three array for the maximum found by each thread 
  extern __shared__ float mymaxvals[];
  extern __shared__ float mystartmaxes[];
  extern __shared__ float myendmaxes[];
		
		int perstart = threadIdx.x + blockDim.x * blockIdx.x;
		int perlen, perend;
		double xbar; // a temporay variable used when computing mean of subsequence

		if (perstart <= n-k) {
    for (perlen = k ; perlen <= n - perstart ; perlen++) {
				  perend = perstart + perlen - 1;
						//compute the mean of subsequence incrementally
      if (perlen ==k) {
							  xbar = 0;
									for ( i = perstart; i <= perend; i++) {
           xbar += sdata[i];     
									}
									xbar /= (perend - perstart + 1);
									mymaxvals[tid] = xbar;
						} else {
        xbar = ( (perlen-1) * xbar + sdata[perend] ) / perlen;
						}
						//update the mymaxvals[tid] if the next longer subsequence has a higher mean
						if (xbar > mymaxvals[tid]) {
         mymaxvals[tid] = xbar;
									mystartmaxes[tid] = perstart;
									myendmaxes[tid] = perend;
						}
				}
		} else {
    mymaxvals[tid] = 0;//initialize it the smallest number
		}
//  mymaxvals[tid] = sdata[tid]; 
		__syncthreads(); //sync to make sure each thread in this block has done with the for loop

  // get the highest among the mymaxvals using reduce
  for (int s = blockDim.x/2; s > 0; s>>=1) {
     if (tid < s ) {
       if(mymaxvals[tid+s] > mymaxvals[tid]) {
						   	mymaxvals[tid] = 	mymaxvals[tid+s]; 
          mystartmaxes[tid] = mystartmaxes[tid + s];
									 myendmaxes[tid] = myendmaxes[tid + s];	
							}	
     }
     __syncthreads();
  }
  // the maximum among the mymaxvals in this block
  if(tid == 0) {
  dmaxarr[blockIdx.x] = mymaxvals[0];
  }
}

