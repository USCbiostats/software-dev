#!/bin/sh
#SBATCH --job-name=parsapply
#SBATCH --time=01:00:00

source /usr/usc/R/default/setup.sh
Rscript --vanilla 03-parsapply-slurmr.R

