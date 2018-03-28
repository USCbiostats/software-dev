#include <omp.h>
#include <RcppArmadillo.h>
using namespace Rcpp;

// [[Rcpp::depends(RcppArmadillo)]]
// [[Rcpp::plugins(openmp)]]

// C++11 provides several RNGs algorithms that can be set up to be thread safe.
// [[Rcpp::plugins(cpp11)]]

// [[Rcpp::export]]
double sim_pi(int m, int cores = 1, int seed = 100) {
  
  // Setting the cores
  omp_set_num_threads(cores);
  int n = m / cores;
  
  double ans = 0.0, d;
  double val = 4.0/m;
  double piest;
  int i;
  
#pragma omp parallel default(none) shared(ans, cores) \
  firstprivate(val, n, m, seed) \
  private(piest, i, d)
{
    
  // Which core are we
  int core_num = omp_get_thread_num();
    
  // Setting up the RNG
  // - The first line creates an engine that uses the 64-bit Mersenne Twister by
  //   Matsumoto and Nishimura, 2000. One seed per core.
  // - The second line creates a function based on the real uniform between -1
  //   and 1. This receives as argument the engine
  std::mt19937_64 engine((core_num + seed)*10);
  std::uniform_real_distribution<double> my_runif(-1.0, 1.0);
  
  double p0, p1;
    
  piest = 0.0;
  for (i = n*core_num; i < (n + n*core_num); i++) {
    
    // Random number generation (see how we pass the engine)
    p0 = my_runif(engine);
    p1 = my_runif(engine);
    
    d = sqrt(pow(p0, 2.0) + pow(p1, 2.0));
    
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

/** *R

library(rbenchmark)

nsim <- 1e5
benchmark(
  pi01 = sim_pi(nsim, 1),
  pi02 = sim_pi(nsim, 2),
  pi04 = sim_pi(nsim, 4),
  pi08 = sim_pi(nsim, 8),
  pi16 = sim_pi(nsim, 16),
  pi32 = sim_pi(nsim, 20),
  replications = 1000
)[,1:4]

*/

