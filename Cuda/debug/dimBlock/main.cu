/*
This code is show errors in Cuda code:
1. The maximum nubmer of threads in a block is 1024, so if you set dimBlock to be dimBlock(64,64,1), you will see an error: 
  invalid configuration argument.

2.If the configuration is correct, when you run, you see another error:
 an illegal memory access was encountered.

*/

#include <stdio.h>
#include <stdlib.h>

__global__ void foo(int *ptr) 
{
  *ptr =7;

}

int main() {

//dim3 dimBlock(64,64,1);
dim3 dimBlock(32,32,1);
foo<<<1,dimBlock>>>(0);

cudaDeviceSynchronize();
cudaError_t error = cudaGetLastError();
if (error !=cudaSuccess) {
  printf("CUDA error: %s\n", cudaGetErrorString(error));
		exit(-1);
}

return 0;
}
