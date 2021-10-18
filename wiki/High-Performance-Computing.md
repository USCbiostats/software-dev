I figured that having a page dedicated to HPC might be a good thing. Here are some stuff that I find interesting/useful that should be take in consideration when writing HPC code. Most of this is related to R (though)

*   OpenMP: Mostly useful for `for` loops. Support for iterator is sort of reduced, but, if the code blocks
    have a significant number of computation happening, then it might be useful. Otherwise you may actually step
    into your tail! Here is an example using `Rcpp` (which you can run in R)
      
    ```c++
    // These two lines allow using OpenMP (included as a plugin in Rcpp)
    #include <omp.h>
    // [[Rcpp::plugins(openmp)]]
    // [[Rcpp::depends(RcppArmadillo)]]
    #include <RcppArmadillo.h>
    using namespace Rcpp;
    
    // [[Rcpp::export]]
    arma::vec useful_to_par(int n, int cores = 1) {
      arma::vec ans(n);
      ans.fill(2);
    
      // Telling how many cores do we need to use
      omp_set_num_threads(cores);
    
    #pragma omp parallel for shared(ans)
      for (int i = 0; i<n; i++) {
        ans(i) += (ans(i))/2.0;
        ans(i) = pow(pow(exp(ans(i)), 2.0), .5)*1.25;
      }
    
    
      return ans;
    }
    
    // [[Rcpp::export]]
    arma::vec not_useful_to_par(int n, int cores = 1) {
      arma::vec ans(n);
      ans.fill(2);
    
      omp_set_num_threads(cores);
    #pragma omp parallel for shared(ans)
      for (int i = 0; i<n; i++) {
        ans(i) += (ans(i))/2.0;
        //ans(i) = exp(ans(i));
      }
    
    
      return ans;
    }
    
    /***R
    library(microbenchmark)
    microbenchmark(
      core1 = not_useful_to_par(2e5, 1),
      core2 = not_useful_to_par(2e5, 2),
      core4 = not_useful_to_par(2e5, 4),
      times = 500, unit = "relative"
    )
    # Unit: relative
    #  expr       min       lq      mean   median       uq        max neval
    # core1 0.9265140 1.064638 1.0081291 1.047105 1.021032 0.85553745   500
    # core2 1.0000000 1.000000 1.0000000 1.000000 1.000000 1.00000000   500
    # core4 0.9444418 1.158769 0.9170785 1.114313 1.235165 0.07896276   500
    
    
    microbenchmark(
      core1 = useful_to_par(2e5, 1),
      core2 = useful_to_par(2e5, 2),
      core4 = useful_to_par(2e5, 4),
      times = 500, unit = "relative"
    )
    # Unit: relative
    #  expr      min       lq     mean   median       uq      max neval
    # core1 3.287934 2.504221 2.361865 2.376846 2.226688 7.363329   500
    # core2 1.683536 1.765088 1.471315 1.519295 1.298309 1.190534   500
    # core4 1.000000 1.000000 1.000000 1.000000 1.000000 1.000000   500
    */
    
    ```
    
    As you can see, parallelizing the function `useful_to_par` gave us speed gains (2.3 times faster
    than the non parallel version of it). At the same time, parallelizing the function `not_useful_to_par`
    wasn't useful at all.
    More resources at the project's website www.openmp.org and examples with Rcpp
   [here](http://gallery.rcpp.org/articles/dmvnorm_arma/)

*  Intel's TBB: There's an R package to handle this: RcppParallel. 
https://software.intel.com/en-us/intel-threading-building-blocks-openmp-or-native-threads