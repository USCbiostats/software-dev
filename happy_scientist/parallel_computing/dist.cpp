#include <omp.h>
#include <RcppArmadillo.h>

// [[Rcpp::depends(RcppArmadillo)]]
// [[Rcpp::plugins(openmp)]]

using namespace Rcpp;

// [[Rcpp::export]]
arma::mat dist_par(arma::mat X, int cores = 1) {
  // Some constants
  int N = (int) X.n_rows;
  int K = (int) X.n_cols;
  
  // Output
  arma::mat D(N,N);
  D.zeros(); // Filling with zeros
  
  // Setting the cores
  omp_set_num_threads(cores);
  
#pragma omp parallel for shared(D, N, K, X) default(none)
  for (int i=0; i<N; i++)
    for (int j=0; j<i; j++) {
      for (int k=0; k<K; k++) 
        D.at(i,j) += pow(X.at(i,k) - X.at(j,k), 2.0);
      
      // Computing square root
      D.at(i,j) = sqrt(D.at(i,j));
      D.at(j,i) = D.at(i,j);
    }
      
  
  // My nice distance matrix
  return D;
}

/* **R
set.seed(1231)
K <- 500
n <- 500
x <- matrix(rnorm(n*K), ncol=K)

library(microbenchmark)
benchmark(
  dist(x),
  dist_par(x, 1),
  dist_par(x, 4),
  dist_par(x, 10),
  replications = 1, order="elapsed"
)
*/