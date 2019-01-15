# Exercise 2: Fibonacci with Rcpp
# 
# The `fibR` function implements the Fibonacci number using recursions, which is
# defined as follows:
# 
#   F_{n}=F_{n-1}+F_{n-2}
#
# Our goal is to implement the same algorithm using Rcpp, for which 
# 
# Fibonacci numbers https://en.wikipedia.org/wiki/Fibonacci_number
# 
# Author: GEORGE G VEGA YON
# Date  : 2018-03-29


# Fib in R
fibR <- function(n, f1 = 1, f2 = 0) {
  
  if (n > 0)
    return(fibR(n - 1, f1 + f2, f1))
  else
    return(f1)
  
}

# Testing it works
ans <- NULL
for (i in 1:20)
  ans <- c(ans, fibR(i))

# Visualizing it
barplot(ans, names.arg = ans, las=2)

# 2a) Implement the algorithm using Rcpp
fibRcpp <- Rcpp::cppFunction("
double fibRcpp(int n, double f1 = 1, double f2 = 0) {
  if (n > 0)
    return fibRcpp(n - 1, f1 + f2, f1);
  else
    return f1;
}
")

# 2b) Using the microbenchmark package, tests how fast it is now using n=500 for
# 1,000 replicates.
microbenchmark::microbenchmark(
  fibRcpp(500),
  fibR(500),
  times = 1e3, unit = "relative"
)
