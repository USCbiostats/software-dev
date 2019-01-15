# Exercise 1: Generating MVN samples in parallel

# In the random forest example, we generate the predictors from a multivariate random normal
# We are interested in determining whether generating the MVN sample in parallel is also useful

# Below is code that generates the mean and covariance structure for an MVN of dimension p
# with mean zero and an autoregressive correlation structure
library(MASS)
p <- 500
mean_x <- rep(0, p)
sigma_x <- 0.5^abs(outer(1:p, 1:p, "-"))

# To generate observations from a MVN distribution, we can use the mvrnorm function in the MASS package
# Below is an example that creates a sample of size 100000 
system.time(samp1 <- mvrnorm(n = 100000, mu = mean_x, Sigma = sigma_x))

# 1a) Use functions in the 'parallel' package to generate another 100000 observatiouns in parallel

# 1b) Use functions in the 'foreach' package to generate another sample of 100000 observations in parallel

# 1c) Do you see any improvement? Try other variable (p) and sample (n) sizes, how does this change the results?
# Hint: To quickly get a rough performance assessment, wrap your code above in system.time()
