#source: http://www.biostat.jhsph.edu/~rpeng/docs/interface.pdf
# compile the c code, R CMD SHLIB hello.c 
# source the hello.R when running main.R. In the hello.R a R function is created
source("hello.R")

dyn.load("hello.so")
hello2(5)
