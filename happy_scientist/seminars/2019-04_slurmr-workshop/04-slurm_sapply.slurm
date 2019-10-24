#!/bin/sh
#SBATCH --job-name=slurm_sapply
#SBATCH --time=01:00:00

source /usr/usc/R/default/setup.sh
Rscript --vanilla 04-slurm_sapply.R

