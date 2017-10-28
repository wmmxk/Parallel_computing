# matrix multiplication; the product u %*% v is computed 
# on cls, and stored in w; w is a big.matrix object

mmulthread <- function(u,v,w) {
   require(parallel)
   myidxs <- splitIndices(nrow(u),myinfo$nwrkrs)[[myinfo$id]]
   w[myidxs,] <- u[myidxs,] %*% v[,]
   0  # don't do expensive return of result
}

test <- function(cls) {
   mgrinit(cls)
   mgrmakevar(cls,"a",6,2)
   mgrmakevar(cls,"b",2,6)
   mgrmakevar(cls,"c",6,6)
   a[,] <- 1:12
   b[,] <- rep(1,12)
   clusterExport(cls,"mmulthread")
   clusterEvalQ(cls,mmulthread(a,b,c))
   print(c[,])
}
