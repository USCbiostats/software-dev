rm(list = ls())

library(parallel)

source("workshops/writing_r_pkgs2017/numint.r")

# Example with univariate function ----------------------------------------

# Normal
ans <- num_int(dnorm, a = -1, b = 1, mean = 0, sd = 1,
               N = 1e6, ncores = 4)
ans
1 - pnorm(-1)*2
plot(ans)

# Beta
bmedian <- (2 - 1/3)/(2 + 20 - 2/3)
ans <- num_int(dbeta, a = 0, b = bmedian, shape1 = 2, shape2 = 20, N = 2e6,
               ncores=4)
ans
plot(ans)

# Example with multivariate normal ----------------------------------------

library(mvtnorm)

# Integrate between a = {-1, -10} and b = {1, 1}
ans <- num_int(
  dmvnorm, a = c(-1, -10), b = c(1, 1),
  mean = c(0,0), sigma = diag(2),
  N = 1e7, ncores = 4
)
ans
pmvnorm(lower = c(-1,-10), upper = c(1,1), mean = c(0,0), sigma = diag(2))


# Checkin speed ----------------------------------------

library(microbenchmark) # For speed benchmark

k     <- 100
N     <- 2e6
lower <- rep(-1, k)
upper <- rep(0,k)

microbenchmark(
  core1 = num_int(dmvnorm, a = lower, b = upper, mean = rep(0,100), sigma = diag(100),
                  N = N, ncores = 1),
  core4 = num_int(dmvnorm, a = lower, b = upper, mean = rep(0,100), sigma = diag(100),
                  N = N, ncores = 4),
  times = 1, unit="relative"
)

