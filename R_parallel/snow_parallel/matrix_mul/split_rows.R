library(parallel)
c2 = makePSOCKcluster(rep("localhost",2))

a = matrix( sample(1:50, 16, replace = T), ncol =2 )
b = c(5,-2)



mmul = function (cls, u,v ) 
{
	rowgrps = splitIndices(nrow(u), length(cls))
    grpmul = function(grp) u[grp,] %*% v
	mout = clusterApply(cls, rowgrps, grpmul)
	Reduce(c,mout)
}	



clusterExport(c2,c('a'))

clusterExport(c2,c('a','b'))
clusterEvalQ(c2,b)

mmul(c2,a,b) #the two variable can be passed as argument if they are made visible by clusterExport
