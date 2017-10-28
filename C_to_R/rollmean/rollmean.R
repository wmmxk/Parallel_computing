library(Rcpp)
sourceCpp("rollmean_s.cpp")

sourceCpp("rollmean_p.cpp")

x = seq(1,10000000,1)

start = proc.time()  
res = rollmean_serial(x,2)


proc.time() - start

start = proc.time()  
res = rollmean_parallel(x,2)


proc.time() - start