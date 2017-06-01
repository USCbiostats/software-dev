#include <omp.h>
#include <RcppArmadillo.h>
using namespace Rcpp;

// [[Rcpp::depends(RcppArmadillo)]]
// [[Rcpp::plugins(openmp)]]

// [[Rcpp::export]]
double sim_pi(int m, int cores = 1) {
  
  // Setting the cores
  omp_set_num_threads(cores);
  int n = m / cores;
  
  double ans = 0.0, d;
  double val = 4.0/m;
  double piest;
  int i;
  
  // Pseudo RNG is not easy in OMP
  arma::mat points(m, 2);
  for (i = 0;i< (int) points.n_rows; i++)
    points.at(i, 0) = unif_rand()*2.0 - 1,
      points.at(i, 1) = unif_rand()*2.0 - 1;
  
#pragma omp parallel default(none) shared(ans, cores, points) \
  firstprivate(val, n, m) \
  private(piest, i, d)
{
    
  // Which core are we
  int core_num = omp_get_thread_num();
    
  piest = 0.0;
  for (i = n*core_num; i < (n + n*core_num); i++) {
    
    d = sqrt(pow(points.at(i, 0), 2.0) + pow(points.at(i, 1), 2.0));
    
    if (d <= 1.0)
      piest += val;
  }
  
  // This bit of code is executed one thread at a time.
  // Instead of -atomic-, we could have use -critical-, but that has
  // a higher overhead.
#pragma omp atomic
  ans += piest;
}
  
  return ans;
}

/* **R

library(rbenchmark)

nsim <- 1e8
benchmark(
  pi01 = sim_pi(nsim, 1),
  pi02 = sim_pi(nsim, 2),
  pi04 = sim_pi(nsim, 4),
  pi10 = sim_pi(nsim, 10),
  replications = 1
)[,1:4]

*/

