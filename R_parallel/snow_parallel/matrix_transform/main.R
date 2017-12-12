transgraph.par <- function(cls,mat) {
  # to retain original row numbers after splitting matrix
  rownames(mat) <- as.character(1:nrow(mat))
  # distribute matrix chunks to workers
  rowgrps <- splitIndices(nrow(mat),length(cls))
  # <<- assigns to global
  clusterApply(cls,rowgrps,
               function(onegrp) mymat <<- mat[onegrp,])
  # do the work
  clusterExport(cls,'transgraph.ser')
  tmp <- clusterEvalQ(cls,transgraph.ser(mymat))
  Reduce(rbind,tmp)
}

transgraph.ser <- function(adj) {
  outmat <- NULL
  for (i in 1:nrow(adj))  {
    where1s <- which(adj[i,] == 1)
    origrownum <- as.numeric(rownames(adj)[i])
    newrows <- cbind(origrownum,where1s)
    outmat <- rbind(outmat,newrows)
  }
  outmat
}

test <- function() {
  require(parallel)
  a <- rbind(c(1,0,1,1), c(1,0,0,1), c(0,0,0,1), c(0,1,1,0)) 
  cls <- makeCluster(2) 
  transgraph.par(cls,a) 
}

test()