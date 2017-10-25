source("bin_search.R")


data =  read.table("../data/twitter_combined.txt", sep = " ")
data = data[order(data[,1]),]

col1= unlist(data[,1])

data = data.matrix(data)


score = 0 
N = max(dim(data))
ptm<-proc.time() 

for (i in 1:N) {
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

score = score/2 -7 
# 7 is the number of reflexive nodes

cat("score: ", score)
print(proc.time() - ptm)