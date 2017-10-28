  library(Rcpp)
  sourceCpp("mean_s.cpp")
  sourceCpp("mean_p.cpp")

  n <- 1e7
  x <- rnorm(n)
  

 system.time(mean_serial(x))
  
 system.time(mean_parallel(x))