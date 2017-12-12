library(Rcpp)
sourceCpp("rollmean_s.cpp")
args <- commandArgs(TRUE)
n = as.integer(args[1])
k = as.integer(args[2])

x = seq(1,n,1)


res = rollmean_serial(x,k)
cat(res[1])
