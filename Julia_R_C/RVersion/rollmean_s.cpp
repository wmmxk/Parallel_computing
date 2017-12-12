#include <Rcpp.h>
#include <omp.h>

using namespace Rcpp;

//[[Rcpp::plugins(openmp)]]
//[[Rcpp::export]]
NumericVector rollmean_serial(NumericVector v, int k) {
    int n = v.size();
	NumericVector means(n-k+1);
    int i, j;
	for (i=0; i < n-k+1; i++) {
			means[i] = v[i];
			for (j=1; j<k; j++) {
             means[i] = means[i] + v[i+j];
			}
			means[i] = means[i]/k;
	}
    return means;
}
