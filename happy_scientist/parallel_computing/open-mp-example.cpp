#include <RcppArmadillo.h>
#include <omp.h>
using namespace Rcpp;

// [[Rcpp::depends(RcppArmadillo)]]
// [[Rcpp::plugins(openmp)]]

// [[Rcpp::export]]
arma::mat centerRcpp(const arma::mat & A) {
  
  arma::mat ans(A);
  
  for (int k = 0; k < (int) A.n_cols; k++) {
    ans.col(k) -= arma::mean(ans.col(k));
    ans.col(k) /= arma::stddev(ans.col(k)); 
  }
    
  
  return ans;
  
}

// [[Rcpp::export]]
arma::mat centerRcpp_omp(const arma::mat & A, int cores = 1) {
  
  arma::mat ans(A);
  
  // Setting the cores
  omp_set_num_threads(cores);
  
#pragma omp parallel for shared(ans) default(none) schedule(static)
  for (int k = 0; k < (int) ans.n_cols; k++) {
    ans.col(k) -= arma::mean(ans.col(k));
    ans.col(k) /= arma::stddev(ans.col(k)); 
  }
  
  return ans;
  
}

/***R

# The standarizing function in R -----------------------------------------------

centerR <- function(A) {
  means <- colMeans(A)
  sds   <- apply(A, 2, sd)
  (A - matrix(means, ncol = ncol(A), nrow = nrow(A), byrow = TRUE))/
    matrix(sds, ncol = ncol(A), nrow = nrow(A), byrow = TRUE)
}

# Making sure we get the same result eveytime ----------------------------------
A <- matrix(rnorm(100*100), ncol = 100)

ans_R    <- centerR(A)
ans_Rcpp <- centerRcpp(A)
ans_Rcpp_omp <- centerRcpp_omp(A, 10)

all.equal(ans_R, ans_Rcpp) # TRUE
all.equal(ans_R, ans_Rcpp_omp) # TRUE

# Benchmark between R and Rcpp -------------------------------------------------

A <- matrix(rnorm(1e4*100), ncol = 1e4)

microbenchmark::microbenchmark(
  R = centerR(A),
  Rcpp  = centerRcpp(A),
  times = 10,
  unit  = "relative"
)

# Benchmark between Rcpp and Rcpp + OpenMP -------------------------------------
A <- matrix(rnorm(1e6*100), ncol = 1e6)
microbenchmark::microbenchmark(
  OMP2  = centerRcpp_omp(A, cores = 2),
  OMP4  = centerRcpp_omp(A, cores = 4),
  OMP8  = centerRcpp_omp(A, cores = 8),
  OMP12  = centerRcpp_omp(A, cores = 12),
  times = 10,
  unit  = "relative"
)

*/
