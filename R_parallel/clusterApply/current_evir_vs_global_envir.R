
# This code is to show tricky pitfall when exporting variables to snow cluster

#Because by default clusterExport() searches only the global environment, \
#and my.var is not in the global environment, it is "only" in the current environment, created by the call to b.func().

#source:http://hansekbrand.se/code/clusterExport.html

library(snow)
a.func <- function(chunk){
  rep(paste(chunk, collapse = ""), times = my.var)
}
b.func <- function(){
  library(parallel)
  cl <- makeCluster(rep("localhost", times = 2), type = "SOCK")
  my.var <- 13
  clusterExport(cl, "my.var")
  chunks <- list(rep("what is", times = 2), rep("wrong here?", times = 3))
  clusterLapply(cl, chunks, a)
}

b.func()

