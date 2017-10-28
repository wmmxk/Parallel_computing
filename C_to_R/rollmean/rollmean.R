library(Rcpp)
sourceCpp("rollmean.cpp")
rollmean(seq(1,10,1),2)

start = proc.time()  
res = rollmean(seq(1,10000000,1),2)

proc.time() - start