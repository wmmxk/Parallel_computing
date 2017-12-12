library(Rcpp)
args <- commandArgs(TRUE)
n  <- as.integer(args[1])
k  <- as.integer(args[2])

sourceCpp("rollmean_p.cpp")

x = seq(1,n,1)

res = rollmean_parallel(x,k)
cat(res[1])  
