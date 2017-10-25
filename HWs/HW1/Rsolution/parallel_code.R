library(parallel)
source("bin_search.R")
data =  read.table("../data/twitter_combined.txt", sep = " ")
data = data[order(data[,1]),]

reflexive_num = sum(data[,1]==data[,2])

col1= unlist(data[,1])

data = data.matrix(data)


cls <- makePSOCKcluster(rep("localhost",6))


par_search = function(cls,data) {
			rowgrps <- splitIndices(nrow(data), length(cls))
			N = nrow(data)
			col1= unlist(data[,1])


			bin_search <- function( arr, l, r, x){		
						if (r>=l) {
								mid = l+(r-l)%/%2
								if(arr[mid] == x) return(mid)
								
								if (arr[mid] > x)  
										return(bin_search(arr, l, mid-1, x))
								
								return(bin_search(arr, mid+1,r,x))
						}
						return(-1)
			}



# the work function search a groups rows for reciprocal eges in all the rows
			# when searching, the second node is seared by binary_search first and 
			# then a local bidrectional search is conducted.
			grpsearch  <- function(grp) {
							score = 0 
							for (i in grp)
							{
									row = unlist(data[i,])
									index = bin_search(col1,1,N,row[2])
									
									if (index!=-1) {
											found = FALSE
											i = index
											while (col1[i] == row[2] && i > 0) {
													if (data[i,2] == row[1]) {
															score = score +1
															found = TRUE
															break
													}
													i = i-1
											}
											
											if (!found) {
													i=index+1
													while (col1[i] == row[2] && i <=N) {
															if (data[i,2] == row[1]) {
																	score = score +1
																	break
															}
															i = i+1
													}
											}
									}
							}
							return(score)
			}  
# apply the work functions on the split rows
			mout <- clusterApply(cls, rowgrps, grpsearch)
			Reduce(c, mout)

}

ptm<-proc.time() 
scores = par_search(cls,data)
print(proc.time() - ptm)

res = (sum(scores)-reflexive_num)/2
