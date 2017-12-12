#!/bin/bash
n=1000
k=3
project_dir=$PWD

time julia $project_dir/Julia/serial_rollmean.jl ${n}  ${k}
time julia -p 2 $project_dir/Julia/parallel_rollmean.jl ${n}  ${k}

