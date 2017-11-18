//source: http://www.orangeowlsolutions.com/archives/526  (download from the link at the bottom of this website)

// Tiled matrix multiplication using shared memory. As compared to the CUDA SDK example, the matrix dimensions are not required to be multiples of the

// tile dimensions. Limitation: C [DIMX][DIMZ] = A [DIMX][DIMY] * B [DIMY][DIMZ] 
#include <stdio.h>
#include <math.h>
#include <conio.h>

#define TILE_DIM 16						// Tile dimension
#define DIMX 231							
#define DIMY 434
#define DIMZ 332
#define RES 0.1

/********************************/
/* MATRIX MULTIPLICATION KERNEL */
/********************************/

__global__ void MatMul(float* A, float* B, float* C, int ARows, int ACols, int BRows, int BCols, int CRows, int CCols) {
	float CValue = 0;
    int Row = blockIdx.y*TILE_DIM + threadIdx.y;
    int Col = blockIdx.x*TILE_DIM + threadIdx.x;
	__shared__ float As[TILE_DIM][TILE_DIM];

	__shared__ float Bs[TILE_DIM][TILE_DIM];
	for (int k = 0; k < (TILE_DIM + ACols - 1)/TILE_DIM; k++) {
		if (k*TILE_DIM + threadIdx.x < ACols && Row < ARows)	As[threadIdx.y][threadIdx.x] = A[Row*ACols + k*TILE_DIM + threadIdx.x];
		else													As[threadIdx.y][threadIdx.x] = 0.0;

		if (k*TILE_DIM + threadIdx.y < BRows && Col < BCols)	Bs[threadIdx.y][threadIdx.x] = B[(k*TILE_DIM + threadIdx.y)*BCols + Col];
		else													Bs[threadIdx.y][threadIdx.x] = 0.0;
         
		__syncthreads();

		for (int n = 0; n < TILE_DIM; ++n) CValue += As[threadIdx.y][n] * Bs[n][threadIdx.x];
		__syncthreads();

	if (Row < CRows && Col < CCols) C[((blockIdx.y * blockDim.y + threadIdx.y)*CCols)+(blockIdx.x*blockDim.x)+threadIdx.x]=CValue;
}


/* CPU MATRIX MULTIPLICATION CHECK FUNCTION */
/********************************************/

void matrixMultiplyCPU(float* A, float* B, float* C, int ARows, int ACols, int BRows, int BCols, int CRows, int CCols) {
	for (int i = 0; i<ARows; i++)
		for (int j=0; j<BCols; j++){
			float Ctemp = 0.0;
			for (int k=0; k<ACols; k++) Ctemp += A[i*ACols + k] * B[k*BCols+j];
			C[i*CCols+j] = Ctemp;
		}
}

/*****************/
/* MAIN FUNCTION */
/*****************/
int main() {
	int CCols = DIMZ, CRows=DIMX, ACols=DIMY, ARows=DIMX, BCols=DIMZ, BRows=DIMY;
	dim3 dimBlock(TILE_DIM, TILE_DIM, 1);
	dim3 dimGrid;
	dimGrid.x = (CCols + dimBlock.x - 1)/dimBlock.x;
	dimGrid.y = (CRows + dimBlock.y - 1)/dimBlock.y;

	float *deviceA, *deviceB, *deviceC;

	float* hostA	= (float*)malloc(DIMX*DIMY*sizeof(float));
	float* hostB	= (float*)malloc(DIMY*DIMZ*sizeof(float));
	float* hostC	= (float*)malloc(DIMX*DIMZ*sizeof(float));

	float* hostCp	= (float*)malloc(DIMX*DIMZ*sizeof(float));
	for (int x = 0; x<DIMX; x++)
		for (int y = 0; y<DIMY; y++) {
			hostA[x*DIMY+y] = rand()/(float)RAND_MAX;
			hostB[x*DIMY+y] = rand()/(float)RAND_MAX;

		}

	cudaMalloc((void **)&deviceA, DIMX*DIMY*sizeof(float));
	cudaMalloc((void **)&deviceB, DIMY*DIMZ*sizeof(float));
	cudaMalloc((void **)&deviceC, DIMX*DIMZ*sizeof(float));
  
	cudaMemcpy(deviceA, hostA, DIMX*DIMY*sizeof(float), cudaMemcpyHostToDevice);
	cudaMemcpy(deviceB, hostB, DIMY*DIMZ*sizeof(float), cudaMemcpyHostToDevice);
	MatMul<<<dimGrid , dimBlock>>>(deviceA , deviceB , deviceC , ARows , ACols, BRows ,BCols , CRows , CCols);
	cudaMemcpy(hostC, deviceC, DIMX*DIMZ*sizeof(float), cudaMemcpyDeviceToHost);
	matrixMultiplyCPU(hostA, hostB, hostCp, ARows, ACols, BRows, BCols, CRows, CCols);

	for (int y = 0; y<DIMZ; y++)
		for (int x = 0; x<DIMX; x++)
			if (fabs(hostCp[x*DIMZ+y] - hostC[x*DIMZ+y]) > RES)
			{
				printf("Matrix-matrix multiplication: unsuccessful... :-( \n");
				getch();
				return 1;
			}
	
	printf("Matrix-matrix multiplication: successful :-) !\n");
	getch();

	return 0;

}
