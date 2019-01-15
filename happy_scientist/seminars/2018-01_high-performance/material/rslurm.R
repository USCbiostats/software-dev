library(rslurm)

# How many nodes are we going to be using
nnodes <- 2L

# The slurm_apply function is what makes all the work
sjob <- slurm_apply(
  # We first define the job as a function
  f = function(n) {
    
    # Compiling Rcpp
    Rcpp::sourceCpp("~/simpi.cpp")
    
    # Returning pi
    sim_pi(1e9, cores = 8, seed = n*100)
    
  },
  # The parameters that `f` receives must be passed as a data.frame
  params        = data.frame(n = 1:nnodes), jobname = "sim-pi",
  
  # How many cpus we want to use (this when calling mcapply)
  cpus_per_node = 1,
  
  # Here we are asking for nodes with 8 CPUS
  slurm_options = list(`cpus-per-task` = 8),
  nodes         = nnodes,
  submit        = TRUE
)

# We save the image so that later we can use the `sjob` object to retrieve the
# results
save.image("~/sim-pi.rda")