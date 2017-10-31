library(Rcpp)
sourceCpp("rollmean_s.cpp")

sourceCpp("rollmean_p.cpp")

x = seq(1,40000000,1)


time_s = as.numeric()
time_p = as.numeric()

# timing the parallel and serial solution
for (i in 1:100) {

  start = proc.time()
  res = rollmean_serial(x,2)
  time_s[i] = (proc.time() - start)[3]
  
  start = proc.time()
  res = rollmean_parallel(x,2)
  time_p[i] = (proc.time() - start)[3]
  
}

time_dif = time_s - time_p
succeed = sum(time_dif > 0)
cat("Among the 100 tests in ",succeed ,"tests, parallel solution is faster")
