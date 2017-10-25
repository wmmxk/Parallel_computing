# This codes is experiment on the clusterExport function. It seems the first argument don't have
# to be exported


library(parallel)

#  a function to count the number of ones in a vector is defined in the count_one.R file
source("./count_one.R")

# create some data
n =10 
myvec = seq(1,n,1)
mydivisor = 2


# make a cluster
cls <- makePSOCKcluster(rep("localhost",2))



# split the input data (a vector) to n parts (n is the nubmer of clusters) and count ones in each part.
# each part is indexed by an index vector
par_search = function(cls,data,divisor) {
  
    rowgrps <- splitIndices(length(data), length(cls))
      
    grpsearch  <- function(grp) {
      data = data/divisor
      return(count_one(data[grp]))
    }  
    mout <- clusterApply(cls, rowgrps, grpsearch)
    Reduce(c, mout)
}



# make the user-defined function and the variables visible.
clusterExport(cls,c('mydivisor','count_one'))

par_search(cls,myvec,mydivisor)


