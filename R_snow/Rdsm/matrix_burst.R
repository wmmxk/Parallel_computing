maxburst <- function(x,k,mas,rslts){
  require(Rdsm)
  require(zoo)
  #determinethisthread’schunkofx
  n <-  length(x)
  myidxs <-  getidxs(n-k+1)
  myfirst <-  myidxs[1]
  mylast <-  myidxs[length(myidxs)]
  mas[1,myfirst:mylast] <- 
  rollmean(x[myfirst:(mylast+k-1)],k)
  #makesureallthreadshavewrittentomas
  barr()
  #onethreadmustdowrapup,saythread1
  if(myinfo$id==1){
    rslts[1,1] <-   which.max(mas[,])
    rslts[1,2]  <-   mas[1,rslts[1,1]]
    
  }
  
}


test <-  function(cls){
  require(Rdsm)
  mgrinit(cls)
  mgrmakevar(cls,"mas",1,9)
  mgrmakevar(cls,"rslts",1,2)
  x <-  c(5,7,6,20,4,14,11,12,15,17)
  
  clusterExport(cls,"maxburst")
  clusterExport(cls,"x")
  clusterEvalQ(cls,maxburst(x,2,mas,rslts))
  print(rslts[,])#notprint(rslts)!
}

library(parallel)

c2 <- makeCluster(2)
test(c2)
