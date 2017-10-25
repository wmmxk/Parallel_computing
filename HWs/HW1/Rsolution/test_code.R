# This codes is experiment on the clusterExport function. It seems the first argument don't have
# to be exported


library(parallel)

cls <- makePSOCKcluster(rep("localhost",2))

n =10 
myvec = seq(1,n,1)
mydivisor = 2


par_search = function(cls,data,divisor) {
  
    rowgrps <- splitIndices(length(data), length(cls))
      
    grpsearch  <- function(grp) {
      data = data/divisor
      return(sum(data[grp]==1))
    }  
    mout <- clusterApply(cls, rowgrps, grpsearch)
    Reduce(c, mout)
}



# why is it OK if do not export the variable 
clusterExport(cls,c('mydivisor'))

par_search(cls,myvec,mydivisor)


