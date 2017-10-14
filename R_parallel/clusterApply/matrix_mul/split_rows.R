library(parallel)
c2 = makePSOCKcluster(rep("localhost",2))

mmul = function (cls, u,v ) 
{
	rowgrps = splitIndices(nrow(u), length(cls))
    grpmul = function(grp) u[grp,] %*% v
	mout = clusterApply(cls, rowgrps, grpmul)
	Reduce(c,mout)
}	

a = matrix( sample(1:50, 16, replace = T), ncol =2 )

b = c(5,-2)

clusterExport(c2,c('a','b'))

mmul(c2,a,b)
