/* How to compile:
	* g++ -std=c++11 hash_solution.cpp
*	 How to run after compilation
*./a.out 1768149 twitter_combined.txt
*
*
*/
#include <stdio.h>
#include <stdlib.h>
#include <omp.h>
#include <time.h>
#include <string.h>
#include <unordered_map>
#include <time.h>

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



int recippar(int *edges,int nrow) {
	int N = nrow;
 std::unordered_map<std::string, int> roster;
	int score = 0;
 int i ; 

 std::string str;	// declare a str variable to hold the string created from integer_integer
	for (i = 0; i < N; i++) {
   if ( *(edges + i*2) >= *(edges + i*2 + 1) ) 
			{
     str = std::to_string(*(edges + i*2)) + "_" + std::to_string(*(edges + i*2 +1 ));
			} else {
     str = std::to_string(*(edges + i*2 + 1)) + "_" + std::to_string(*(edges + i*2));
			}

   auto search = roster.find(str);

			if (search != roster.end()) {
      score += 1; // if already there
			} else {
      roster.insert( {str, 1} );
			}
  }
	return score;
}




//how to run the main function after compile
// ./a.out 1768149 twitter_combined.txt

int  main(int argc, char *argv[])
{
 
	clock_t begin = clock();
	int N = atoi(argv[1]);
 char file_path[100] = "../data/";
 strcat(file_path,argv[2]);
 printf("file path: %s\n", file_path);
 int * data = to_array(N, file_path); 
 int i,j;
	if (N < 10) { // on develop.txt print it out
			for (i = 0; i < N; i++) {
							for (j =0; j< 2; j++)
									printf("%d ", *(data + i*2 +j ));
							printf("\n");
			}
	}

	int score = recippar( data, N);
	clock_t end = clock();
 double time = (double)(begin - end) / CLOCKS_PER_SEC;
	printf("score is %d\n  ", score);
	printf("time taken  is %f\n  ", time);
	return 0 ;
}
