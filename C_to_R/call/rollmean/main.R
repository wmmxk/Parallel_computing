library(zoo)

dyn.load("rollmean_s.so")
dyn.load("rollmean_p.so")

n = 1e7
vec = seq(1,n,1)
window = 4

# test the correctness
res_s = .Call("rollmean_s",vec,window)
res_p = .Call("rollmean_p",vec,window)
res_true = rollmean(vec,window)

# confirm the results 
all(res_s == res_true)
all(res_p == res_true)

time_s = as.numeric()
time_p = as.numeric()


# compare the performance of the serial so
for (i in 1:10) {
	 start = proc.time()
  res = .Call("rollmean_s",vec,window)
		time_s[i] = (proc.time() - start)[3]
		  
		start = proc.time()
		res = .Call("rollmean_p",vec,window)
		time_p[i] = (proc.time() - start)[3]

}

time_dif = time_s - time_p
succeed = sum(time_dif > 0)
cat("Among the 10 tests in ",succeed ,"tests, parallel solution is faster")
