```cpp
#include <Rcpp.h>

using namespace Rcpp;

// Here I'm defining the structure that holds the "amcmc" class object.
// It is basically a NumericVector (of no particular length), and
// a list with other R objects, which I'm not using... for now.
struct amcmc {
  NumericVector params;
  List others;
};

// Defining the -update- functions ---------------------------------------------

// This function uses pointers, hence should be faster
void pupdate(amcmc *args) {
  
  for (int i = 0; i< Rf_length(args->params); i++)
    args->params.at(i) = args->params.at(i)*i;
  
  return;
}

// This function, while receives its argument by reference, it creates
// the returning object, which is a NumericVector.
NumericVector update(amcmc & args) {
  
  NumericVector ans(args.params.size());
  
  for (int i = 0; i< Rf_length(args.params); i++)
    ans.at(i) = args.params.at(i)*i;
  
  return ans;
}

// Defining the -sim- functions ------------------------------------------------

// This function uses pointers overall, hence, updating is made in place using
// the -pupdate- function.

// [[Rcpp::export]]
NumericVector pmyrnorm(const List args, int nsim = 1e3) {
  
  // Created an empty structure
  amcmc args0;
  
  // A pointer to it
  amcmc * pargs0;
  pargs0 = &args0;
  
  // The structure is no empty now
  args0.params = args.at(0);
  
  // We just pass the pointer
  for (int i = 0; i < nsim ; i++)
    pupdate(pargs0);
  
  // But return a single element of the structure
  return args0.params;
}

// This function doesn't uses pointers, so, while the updating is done over
// the -amcmc- object (so we actually don't create a new variable each time),
// we are creating a new NumericVector in -update-, which is where the
// bottle neck may be located

// [[Rcpp::export]]
NumericVector myrnorm(const List args, int nsim = 1e3) {
  
  // Created an empty structure
  amcmc args0;
  
  // The structure is no empty now
  args0.params = args.at(0);
  
  // We update the value
  for (int i = 0; i < nsim ; i++)
    args0.params = update(args0);
  
  // But return a single element of the structure
  return args0.params;
}

/***R
myrnorm(list(1:10, NULL))
pmyrnorm(list(1:10, NULL))

microbenchmark::microbenchmark(
  myrnorm(list(1:10, NULL), nsim = 1e6),
  pmyrnorm(list(1:10, NULL), nsim = 1e6), times = 100
)

# > microbenchmark::microbenchmark(
#   +   myrnorm(list(1:10, NULL), nsim = 1e6),
#   +   pmyrnorm(list(1:10, NULL), nsim = 1e6), times = 10
#   + )
# Unit: milliseconds
#                                     expr      min        lq      mean    median        uq       max neval
#  myrnorm(list(1:10, NULL), nsim = 1e+06) 130.1483 131.84485 159.79306 157.25518 183.24565 199.22182    10
# pmyrnorm(list(1:10, NULL), nsim = 1e+06)  84.6813  84.97647  85.21205  85.24763  85.45566  85.66591    10
#
# So it seems that using pointers in this case is twice as faster. Here we are updating a parameter
# vector with 10 elements a million of times.
*/
```

Take a look at http://gallery.rcpp.org/articles/rcpp-serialization/