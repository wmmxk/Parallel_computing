# This codes is experiment on the clusterExport function. It seems the first argument don't have
# to be exported


library(parallel)
c2 <- makePSOCKcluster(rep("localhost",2))


mmul <-  function(cls, u,v) {
  rowgrps <- splitIndices(nrow(u), length(cls))
  grpmul <- function(grp) u[grp,] %*% v
  mout <- clusterApply(cls, rowgrps,grpmul)
  Reduce(c,mout)
}

a <- matrix(sample(1:50,16,replace = T), ncol =2)
b <- c(5,-2)

# If I comment out the following line, it will not work. But I don't have to export the varialbe "a"
clusterExport(c2,"b")
mmul(c2,a,b)
