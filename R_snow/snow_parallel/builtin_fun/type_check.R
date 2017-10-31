library(parallel)

cls = makePSOCKcluster(rep("localhost",2))
results = clusterApply(cls,1:6,sin)
cat(typeof(results),"\n")
