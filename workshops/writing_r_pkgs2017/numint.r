# Clean working space (aooaoaoa)
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
  f       <- function(x) fn(x, ...)
  fsample <- parApply(cl, samp, 1, f)
  ans     <- V*sum(fsample)/N
  
  # Preparing arguments
  env <- new.env()
  environment(f) <- env
  args <- list(...)
  environment(args) <- env
  
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
      b = b,
      f = f,
      args = args
      ),
    class = "numint"
  )
}

# Plotting method
plot.numint <- function(x, y = NULL, main = "Monte Carlo Integration", col=blues9[4],...) {
  
  n <- 100
  
  # Computing values
  xran <- c(x$a[1], x$b[1])
  vals <- NULL
  if (length(x$a > 1)) {
    vals <- Map(function(a,b) rep((a + b)/2, n), a = x$a[-1], x$b[-1])
    vals <- do.call(cbind, vals)
  } 
  
  # Computing coordinates
  vals <- cbind(seq(xran[1], xran[2], length.out = n), vals)
  y <- apply(vals, 1, x$f)
  
  
  # Adding missing points
  coordinates <- cbind(vals[,1], y)
  coordinates <- rbind(coordinates, c(xran[2], 0), c(xran[1], 0))
  
  # Plotting
  plot.new()
  plot.window(xlim = xran, ylim = range(y))
  polygon(coordinates, col = col, ...)
  
  # Adding axis
  axis(1);axis(2)
  
  # A nice title
  title(main = main)
  
  # And a neat legend
  legend("topright",
         legend = substitute(
           Volume~~a %+-% b,
           list(
             a = sprintf("%.4f", x$val),
             b = sprintf("%.4f", x$sd))
           ),
         bty = "n"
         )
  
  # Returning the coordinates used for the plot
  invisible(cbind(x = vals, y = y))
}

# printing method 
print.numint <- function(x, ...) {
  with(x, cat(sprintf("MONTE CARLO INTEGRATION\nN: %i\nVolume: %.4f\n", N, vol)))
  with(x, cat(sprintf("%.4f in [%.4f, %.4f]", val, val - sd, val + sd)))
  
  invisible(x)
}

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
