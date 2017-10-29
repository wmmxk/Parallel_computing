# source: http://people.math.aau.dk/~sorenh/teaching/2012-ASC/day4/interfaceC-notes.pdf
n = 2e5
A <- matrix(1:n, nc=25)
B <- matrix(1:n, nr=25)
source("mat_mul_R.R")
dyn.load("lib/mat_mul_c.so")

system.time(mat_mul_s(A,B))

system.time(mat_mul_p(A,B))

system.time(A %*% B)
