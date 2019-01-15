# Exercise 1: Generating MVN samples in parallel

# In the random forest example, we generate the predictors from a multivariate random normal
# We are interested in determining whether also generating the MVN sample in parallel is useful

# Below is code that generates the mean and covariance structure for an MVN of dimension p
# with mean zero and an autoregressive correlation structure
library(MASS)
p <- 500
mean_x <- rep(0, p)
sigma_x <- 0.5^abs(outer(1:p, 1:p, "-"))

# To generate observations from a MVN distribution, we can use the mvrnorm function in the MASS package
# Below is an example that creates a sample of size 100000 
system.time(samp1 <- mvrnorm(n = 100000, mu = mean_x, Sigma = sigma_x))

# 1a) Use the 'parallel' package to generate another 100000 observatiouns in parallel

library(parallel)
cl <- makePSOCKcluster(4)
clusterSetRNGStream(cl, 123)
clusterExport(cl, c("mean_x", "sigma_x"))
system.time(samp2 <- parLapply(cl, rep(25000, 4), mvrnorm, mu = mean_x, Sigma = sigma_x))
stopCluster(cl)

# 1b) Use the 'foreach' package to generate another sample of 100000 observations

library(foreach)
library(doParallel)
cl <- makePSOCKcluster(4)
registerDoParallel(cl)
system.time(samp3 <- foreach(x = rep(25000, 4), .combine = rbind) %dopar% {
    MASS::mvrnorm(n = x, mu = mean_x, Sigma = sigma_x)
})
stopCluster(cl)

# 1c) Do you see any improvement? Try other variable (p) and sample (n) sizes, how does this change the results?
# Hint: To quickly get a rough performance assessment, wrap your code above in system.time()

# On my computer the timings for the above code were approximately:
# Sequential: 16 seconds
# parLapply: 8 seconds
# foreach: 8 seconds

# There does appear to be a modest improvement in speed as we increase the number of cores. 
# However, the improvement is only noticeable for larger sample sizes. Also, note that as
# p increases, the computational cost will significantly increase for the following lines
# in the mvrnorm function, which leads to decreased performance that parallelization will not
# be able to help improve in terms of speed.

# eS <- eigen(Sigma, symmetric = TRUE)
# X <- drop(mu) + eS$vectors %*% diag(sqrt(pmax(ev, 0)), p) %*% t(X)

# Conclusion: Parallelization helps, but may be useful at a much lower level than can be achieved
# by only calling the R function directly (i.e. OpenMP). In fact, an R function 
# rmvn() did just this + some other improvements in the mvnfast package!

# https://cran.r-project.org/web/packages/mvnfast/vignettes/mvnfast.html
    

