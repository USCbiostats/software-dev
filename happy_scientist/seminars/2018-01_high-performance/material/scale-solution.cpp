/***
 * Exercise 3: Rewriting the scale function using Rcpp and OpenMP
 * Write down a C++ function using RcppArmadillo and OpenMP that centers and
 * scales each column of a matrix as the `scale` function in R does.
 * 
 * The R function provides an alternative implementation of the `scale` function.
 * This is included just to show that sometimes we don't need that much fancy
 * code to speed up things.
 * 
 * The C++ function `scaleRcpp` provides a starting point. This very same function
 * with the name `scaleRcpp_omp` is the one that you need to modify in order to
 * use OpenMP.
 * 
 * Besides of modifying the function, recall including the header, and telling
 * Rcpp to link it to openmp.
 * 
 * Author: GEORGE G VEGA YON
 * Date  : 2018-03-29
 * 
 */

#include <RcppArmadillo.h>

// 3a) INLCUDE THE OPENMP LIBRARY ----------------------------------------------
#include <omp.h>
using namespace Rcpp;

// [[Rcpp::depends(RcppArmadillo)]]
// 3b) LOAD THE OPENMP PLUGIN --------------------------------------------------
// [[Rcpp::plugins(openmp)]]

// [[Rcpp::export]]
arma::mat scaleRcpp(const arma::mat & A) {
  
  arma::mat ans(A);
  
  int n = (int) A.n_rows, K = (int) A.n_cols;
  
  for (int k = 0; k < K; k++) {
    ans.col(k) -= arma::mean(ans.col(k));
    ans.col(k) /= pow(arma::accu(pow(ans.col(k), 2.0))/(n - 1), 0.5); 
  }
    
  
  return ans;
  
}

// [[Rcpp::export]]
arma::mat scaleRcpp_omp(const arma::mat & A, int cores = 1) {
  
  arma::mat ans(A);
  int n = (int) A.n_rows, K = (int) A.n_cols;
  
  // Setting the cores
// 3c) SET UP THE NUMBER OF CORES ----------------------------------------------
  omp_set_num_threads(cores);

// 3d) HERE GOES PRAGMA --------------------------------------------------------
#pragma omp parallel for shared(ans) default(none) schedule(static) \
  firstprivate(n, K)
  for (int k = 0; k < K; k++) {
    ans.col(k) -= arma::mean(ans.col(k));
    ans.col(k) /= pow(arma::accu(pow(ans.col(k), 2.0))/(n - 1), 0.5); 
  }
  
  return ans;
  
}

/***R

# The standarizing function in R -----------------------------------------------

scale2 <- function(A) {
  means <- colMeans(A)
  means <- matrix(means, ncol = ncol(A), nrow = nrow(A), byrow = TRUE)
  diff  <- A - means
  sdv   <- matrix(sqrt(colSums(diff^2)/(nrow(A) - 1)), ncol = ncol(A), nrow = nrow(A), byrow=TRUE)
  diff/sdv
    
}

# Making sure we get the same result eveytime ----------------------------------
A <- matrix(rnorm(100*100), ncol = 100)

ans_R    <- scale2(A)
ans_Rcpp <- scaleRcpp(A)
ans_Rcpp_omp <- scaleRcpp_omp(A, 10)

all.equal(ans_R, ans_Rcpp) # TRUE
all.equal(ans_R, ans_Rcpp_omp) # TRUE

# Benchmark between R and Rcpp -------------------------------------------------

A <- matrix(rnorm(1e4*100), ncol = 1e4)

microbenchmark::microbenchmark(
  R      = scale(A, TRUE, TRUE),
  R2     = scale2(A),
  Rcpp   = scaleRcpp(A),
  times  = 10,
  unit   = "relative"
)

# Benchmark between Rcpp and Rcpp + OpenMP -------------------------------------
A <- matrix(rnorm(1e6*100), ncol = 1e6)
microbenchmark::microbenchmark(
  OMP2  = scaleRcpp_omp(A, cores = 2),
  OMP4  = scaleRcpp_omp(A, cores = 4),
  OMP8  = scaleRcpp_omp(A, cores = 8),
  OMP12  = scaleRcpp_omp(A, cores = 12),
  times = 10,
  unit  = "relative"
)

*/
