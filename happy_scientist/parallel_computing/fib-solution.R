library(Rcpp)

#' Fibonacci numbers https://en.wikipedia.org/wiki/Fibonacci_number
#' {\displaystyle F_{n}=F_{n-1}+F_{n-2},}
#' 

fibR <- function(n, f1 = 1, f2 = 0) {
  
  if (n > 0)
    return(fibR(n - 1, f1 + f2, f1))
  else
    return(f1)
  
}

ans <- NULL
for (i in 1:20)
  ans <- c(ans, fibR(i))

# Visualizing it
barplot(ans, names.arg = ans, las=2)

fibRcpp <- Rcpp::cppFunction("
double fibRcpp(int n, double f1 = 1, double f2 = 0) {
  if (n > 0)
    return fibRcpp(n - 1, f1 + f2, f1);
  else
    return f1;
}
")

#' How fast?
microbenchmark::microbenchmark(
  fibRcpp(500),
  fibR(500),
  times = 1e3, unit = "relative"
)
