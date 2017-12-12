#!/bin/bash
n=$1
k=3

time Rscript rollmean_s.R ${n}  ${k}
time Rscript rollmean_p.R ${n}  ${k}
