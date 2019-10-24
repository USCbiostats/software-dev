#!/bin/sh
#SBATCH --job-name=mclapply
#SBATCH --time=01:00:00
#SBATCH --cpus-per-task=4

source /usr/usc/R/default/setup.sh
Rscript --vanilla 02-mclapply.R

