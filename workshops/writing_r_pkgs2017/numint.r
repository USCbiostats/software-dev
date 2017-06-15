rm(list = ls())

# Packages that we will be using
library(parallel)
library(mvtnorm)
library(microbenchmark) # For speed benchmark

# This function performes numerical integration using monte carlo integration
# fn is a function
# ... are further arguments to be passed to fn
# a is the lower bound
# b is the upper bound
# N is the sample size
# ncores is the number of processors to call
# cl is an object of class cluster
num_int <- function(fn, ..., a, b, N = 100, ncores = 1, cl = NULL) {
  
  # Getting the call
  call <- match.call()
  
  # Checking length
  if (length(b) != length(a))
    stop("-a- and -b- must have the same length.")
  
  # Checking values
  if (!all(a < b))
    stop("There are some values a > b (all must a < b)")
  
  # Checking parallel
  if (!length(cl)) {
    cl <- makeCluster(ncores)
    on.exit(stopCluster(cl))
  }
  
  # Sampling
  samp <- Map(function(lb, ub) runif(N, lb, ub), lb = a, ub = b)
  samp <- do.call(cbind, samp)
  
  # Computing the volume
  V <- prod(b - a)
  
  # Computing density
  f       <- function(x) f(x, ...)
  fsample <- parApply(cl, samp, 1, fn)
  ans     <- V*sum(fsample)/N
  
  # Returning an object of class numint
  structure(
    list(
      val = ans,
      vol = V,
      fsample = fsample,
      call = call,
      sd = sd(fsample*V),
      N=N,
      a = a,
      b = b
      ),
    class = "numint"
  )
}

# Plotting method
plot.numint <- function(x, y = NULL, main = "Monte Carlo Integration", ...) {
  with(x,boxplot(fsample*vol, main=main, ...))
}

# printing method 
print.numint <- function(x, ...) {
  with(x, cat(sprintf("MONTE CARLO INTEGRATION\nN: %i\nVolume: %.4f\n", N, vol)))
  with(x, cat(sprintf("%.4f in [%.4f, %.4f]", val, val - sd, val + sd)))
}

# Example with univariate function ----------------------------------------
ans <- num_int(dnorm, a = -1, b = 1, mean = 0, sd = 1,
               N = 1e6, ncores = 4)
ans
1 - pnorm(-1)*2

# Example with multivariate normal ----------------------------------------

# Integrate between a = {-1, -10} and b = {1, 1}
ans <- num_int(
  dmvnorm, a = c(-1, -10), b = c(1, 1),
  mean = c(0,0), sigma = diag(2),
  N = 1e6, ncores = 4
  )
ans
pmvnorm(lower = c(-1,-10), upper = c(1,1), mean = c(0,0), sigma = diag(2))


# Checkin speed ----------------------------------------

k     <- 5
N     <- 5e5
lower <- rep(-1, k)
upper <- rep(0,k)
  
microbenchmark(
  core1 = num_int(dmvnorm, a = lower, b = upper, mean = upper, sigma = diag(k),
          N = N, ncores = 1),
  core2 = num_int(dmvnorm, a = lower, b = upper, mean = upper, sigma = diag(k),
                  N = N, ncores = 2),
  times = 1, unit="relative"
)
