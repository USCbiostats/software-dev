all:
	sbatch --partition=scavenge 01-sapply.slurm & \
	sbatch --partition=scavenge 02-mclapply.slurm & \
	sbatch --partition=scavenge 03-parsapply-slurmr.slurm & \
	sbatch --partition=scavenge 04-slurm_sapply.slurm & \
	Rscript -e 'slurmR::sourceSlurm("05-sapply.R", plan = "submit", partition = "scavange")' &
