#include <Rcpp.h>

// [[Rcpp::export]]
double mean_serial(Rcpp::NumericVector x)
{
  double sum = 0.0;
  for (int i=0; i<x.size(); i++)
    sum += x[i];
  
  return sum / x.size();
}
