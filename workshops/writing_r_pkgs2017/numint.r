rm(list = ls())

num_int <- function(fn, ..., a, b, N = 100, ncores = 1, cl = NULL) {
  
  # Checking length
  k <- length(a)
  if (length(b) != k)
    stop("-a- and -b- must have the same length.")
  
  # Checking parallel
  if (!length(cl)) {
    cl <- makeCluster(ncores)
    on.exit(stopCluster(cl))
  }
  
  # Sampling
  samp <- mcMap(function(lb, ub) runif(N, lb, ub), lb = a, ub = b)
  samp <- do.call(cbind, samp)
  
  V <- prod(b - a)
  
  # Computing density
  f <- function(x) f(x, ...)
  V/N*sum(parApply(cl, samp, 1, fn))
}

# Example with univariate function
ans <- num_int(dnorm, a = -1, b = 1, mean = 0, sd = 1,
               N = 100000, ncores = 10)
ans
1 - pnorm(-1)*2

# Example with multivariate normal
library(mvtnorm)

# Integrate between a = {-1, -10} and b = {1, 1}
ans <- num_int(
  dmvnorm, a = c(-1, -10), b = c(1, 1),
  mean = c(0,0), sigma = diag(2),
  N = 1e6, ncores = 10
  )
ans
pmvnorm(lower = c(-1,-10), upper = c(1,1), mean = c(0,0), sigma = diag(2))


# Checkin speed
library(microbenchmark)
k     <- 5
N     <- 5e5
lower <- rep(-1, k)
upper <- rep(0,k)

microbenchmark(
  core1 = num_int(dmvnorm, a = lower, b = upper, mean = upper, sigma = diag(k),
          N = N, ncores = 1),
  core2 = num_int(dmvnorm, a = lower, b = upper, mean = upper, sigma = diag(k),
                  N = N, ncores = 2),
  core4 = num_int(dmvnorm, a = lower, b = upper, mean = upper, sigma = diag(k),
                  N = N, ncores = 4), times = 1, unit="relative"
)
