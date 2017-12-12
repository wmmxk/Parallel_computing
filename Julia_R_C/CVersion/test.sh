#!/bin/bash
n=$1
k=3
project_dir=$PWD
time $project_dir/rollmean_s ${n}  ${k}
time $project_dir/rollmean_p ${n}  ${k}

