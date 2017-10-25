#include <stdio.h>
#include <stdlib.h>
#include <omp.h>
#include <time.h>
#include <string.h>

typedef struct {
	int key;
	int value;
}tuple;


int * to_array(int N, char * file_path){
	int num = 0, i = 0, j = 0;

	int *arr = (int*) malloc(N*2*sizeof(int));

	FILE *fin;
	fin = fopen(file_path,"r");
	while (!feof(fin)) {
		fscanf(fin,"%d",(arr+i*2+j));
		num++;
		i = num/2;
		j = num % 2;
	}
	fclose(fin);

	return arr;
}


tuple* to_tuple_array(int N, int *edges) {
	int num = 0, i = 0, j = 0;

	tuple* tuples = (tuple*)malloc(N* sizeof(tuple));

 for (i=0; i < N;i++)
	{
  tuples[i].key = *(edges + i*2);
		tuples[i].value = *(edges + i*2 +1);
	}
	return tuples;
}


int comparator_using_tuple(const void *p, const void *q) {
	int l = ((tuple*)p)->key;
	int r = ((tuple*)q)->key;

	return (l - r);
}


int iter_binarySearch(tuple* arr, int l, int r, int x)
{
  while (l <= r)
  {
    int m = l + (r-l)/2;

    // Check if x is present at mid
    if (arr[m].key == x)
        return m;

    // If x greater, ignore left half
    if (arr[m].key < x)
        l = m + 1;

    // If x is smaller, ignore right half
    else
         r = m - 1;
  }

  // if we reach here, then element was not present
  return -1;
}

int recippar(int *edges,int nrow)
{
	int N = nrow;

	int score = 0;

 int reflexive_nodes = 0;

	tuple* tuples = to_tuple_array(N, edges);

	qsort(tuples, N, sizeof(tuples[0]), comparator_using_tuple);

	#pragma omp parallel shared(score)
	{
		#pragma omp for
		for (int i = 0; i < N; i++) {

			if(tuples[i].key != tuples[i].value) {	// Otherwise, the node is reflexive
				int index = iter_binarySearch(tuples, 0, N-1, tuples[i].value);
				if (-1 != index) {
					// search right
					int curr_r = index;
					int curr_l = index;
					int found = 0;
					while( found == 0 && curr_r < N && tuples[curr_r].key == tuples[i].value ) {
						if( tuples[i].key == tuples[curr_r].value) {
							#pragma omp critical
							score += 1;
							found = 1;
						}
						curr_r++;
					}
					// curr = index;
					// search left
					while( found == 0 && curr_l >= 0 && tuples[curr_l].key == tuples[i].value ) {
						if( tuples[i].key == tuples[curr_l].value) {
							#pragma omp critical
							score += 1;
							found = 1;
						}
						curr_l--;
					}
				}
			} else {
				reflexive_nodes++;
			}
		}
	}
	// 	printf("we have %d reflexive_nodes\n", reflexive_nodes);
	//
	//
	//
	//
	// clock_t end = clock();
	// double time = (double)(begin - end) / CLOCKS_PER_SEC;
	// printf("time: %d\n", time);
	 printf("score: %d\n", score/2);
	return score/2;
}

// how to run the main function after compile
// ./a.out 1768149 twitter_combined.txt

//int  main(int argc, char *argv[])
//{
//  int N = atoi(argv[1]);
// char file_path[100] = "./data/";
// strcat(file_path,argv[2]);
// printf("file path: %s\n", file_path);
// int * data = to_array(N, file_path); 
// int score = recippar(data, N);
// return 0 ;
//}
