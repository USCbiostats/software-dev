#!/bin/sh
#SBATCH --job-name=sapply
#SBATCH --time=01:00:00

source /usr/usc/R/default/setup.sh
Rscript --vanilla 01-sapply.R

