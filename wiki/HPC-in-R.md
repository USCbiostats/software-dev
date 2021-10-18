Based on **The "Happy Scientist" Seminar Series: "A brief introduction to using R for high-performance computing"** (George Vega Yon and Garrett Weaver). Found [here](https://github.com/USCbiostats/software-dev/tree/master/happy_scientist/seminars/2017-05_high-performance)



## Agenda

1.  High-Performance: An overview 
    
2.  [Parallel computing in R](HPC-in-R#parallel-computing-in-r)
    
3.  Examples:
    
    a.  [parallel](HPC-in-R#parallel)
    
    b.  [iterators+foreach](HPC-in-R#foreach)
    
    c.  [RcppArmadillo + OpenMP](HPC-in-R#rcpparmadillo-and-openmp)



## High-Performance Computing: An overview

Loosely, from R's perspective, we can think of HPC in terms of two, maybe three things:

1.  Big data: How to work with data that doesn't fit your computer

2.  Parallel computing: How to take advantage of multiple core systems

3.  Compiled code: Write your own low-level code (if R doesn't has it yet...)


## Big Data

*   Buy a bigger computer/RAM memory (not the best solution!)
    
*   Use out-of-memory storage, i.e., don't load all your data in the RAM. e.g.
    The [bigmemory](https://CRAN.R-project.org/package=bigmemory),
    [data.table](https://CRAN.R-project.org/package=data.table),
    [HadoopStreaming](https://CRAN.R-project.org/package=HadoopStreaming) R packages

*   Store it more efficiently, e.g.: Sparse Matrices (take a look at the `dgCMatrix` objects
    from the [Matrix](https://CRAN.R-project.org/package=Matrix) R package)

## Parallel computing

<div class="figure" style="text-align: center">
<img src="https://github.com/USCBiostats/software-dev/blob/master/happy_scientist/parallel_computing/flynnsTaxonomy.gif" alt="Flynn's Classical Taxonomy ([Introduction to Parallel Computing, Blaise Barney, Lawrence Livermore National Laboratory](https://computing.llnl.gov/tutorials/parallel_comp/#Whatis))"  />
<p class="caption">Flynn's Classical Taxonomy ([Introduction to Parallel Computing, Blaise Barney, Lawrence Livermore National Laboratory](https://computing.llnl.gov/tutorials/parallel_comp/#Whatis))</p>
</div>

## GPU vs CPU

<div class="figure" style="text-align: center">
<img src="https://github.com/USCBiostats/software-dev/blob/master/happy_scientist/parallel_computing/cpuvsgpu.jpg" alt="[NVIDIA Blog](http://www.nvidia.com/object/what-is-gpu-computing.html)"  />
<p class="caption">[NVIDIA Blog](http://www.nvidia.com/object/what-is-gpu-computing.html)</p>
</div>

**Why are we still using CPUs instead of GPUs?**

> GPUs have far more processor cores than CPUs, but because each GPU core runs
  significantly slower than a CPU core and does not have the features needed for
  modern operating systems, they are not appropriate for performing most of the
  processing in everyday computing. They are most suited to compute-intensive
  operations such as video processing and physics simulations.
  ([bwDraco at superuser](https://superuser.com/questions/308771/why-are-we-still-using-cpus-instead-of-gpus))

## When is it a good idea?

<div class="figure" style="text-align: center">
<img src="https://github.com/USCBiostats/software-dev/blob/master/happy_scientist/parallel_computing/when_to_parallel.svg" alt="Ask yourself these questions before jumping into HPC!"  />
<p class="caption">Ask yourself these questions before jumping into HPC!</p>
</div>


## <a name="parallel-computing-in-r"></a>Parallel computing in R

While there are several alternatives (just take a look at the
[High-Performance Computing Task View](https://cran.r-project.org/web/views/HighPerformanceComputing.html)),
we'll focus on the following R-packages/tools for explicit parallelism:



1.  R packages
    
    *   **parallel**: R package that provides '[s]upport for parallel computation,
        including random-number generation'.
    
    *   **foreach**: '[A] new looping construct for executing R code repeatedly
        [...] that supports parallel execution.'
    
    *   **iterators**: 'tools for iterating over various R data structures'
    
2.  RcppArmadillo + OpenMP
    
    *   **RcppArmadillo**: 'Armadillo is a C++ linear algebra library, aiming
        towards a good balance between speed and ease of use.' '[RcppArmadillo]
        brings the power of Armadillo to R.'
        
    *  **OpenMP**: 'Open Multi-Processing is an application programming interface
        (API) that supports multi-platform shared memory multiprocessing
        programming in C, C++, and Fortran, on most platforms, processor
        architectures and operating systems, including Solaris, AIX, HP-UX,
        Linux, macOS, and Windows.' ([Wiki](https://en.wikipedia.org/wiki/OpenMP))

Implicit parallelism, on the other hand, is the use of out-of-the-box tools that allow the
programmer not to worry about parallelization, e.g., 
[**gpuR**](https://cran.r-project.org/package=gpuR) for Matrix manipulation using
GPU.

## <a name="parallel"></a>Parallel workflow

1.  Create a cluster:
    
    a.  PSOCK Cluster: `makePSOCKCluster`: Creates brand new R Sessions (so
        nothing is inherited from the master), even in other computers!
        
    b.  Fork Cluster: `makeForkCluster`: Using OS
        [Forking](https://en.wikipedia.org/wiki/Fork_(system_call)),
        copies the current R session locally (so everything is inherited from
        the master up to that point). Not available on Windows.
    
    c.  Other: `makeCluster` passed to **snow**
    
2.  Copy/prepare each R session:

    a.  Copy objects with `clusterExport`

    b.  Pass expressions with `clusterEvalQ`

    c.  Set a seed
    

3.  Do your call:

    a.  `mclapply`, `mcmapply` if you are using **Fork**

    b.  `parApply`, `parLapply`, etc. if you are using **PSOCK**

    
4.  Stop the cluster with `clusterStop`
    
## parallel example 1: Parallel RNG


```r
# 1. CREATING A CLUSTER
library(parallel)
cl <- makePSOCKcluster(2)    

# 2. PREPARING THE CLUSTER
clusterSetRNGStream(cl, 123) # Equivalent to `set.seed(123)`

# 3. DO YOUR CALL
ans <- parSapply(cl, 1:2, function(x) runif(1e3))
(ans0 <- var(ans))
```

```
#               [,1]          [,2]
# [1,]  0.0861888293 -0.0001633431
# [2,] -0.0001633431  0.0853841838
```

```r
# I want to get the same!
clusterSetRNGStream(cl, 123)
ans1 <- var(parSapply(cl, 1:2, function(x) runif(1e3)))

ans0 - ans1 # A matrix of zeros
```

```
#      [,1] [,2]
# [1,]    0    0
# [2,]    0    0
```

```r
# 4. STOP THE CLUSTER
stopCluster(cl)
```

## parallel example 1: Parallel RNG (cont.)

In the case of `makeForkCluster`


```r
# 1. CREATING A CLUSTER
library(parallel)

# The fork cluster will copy the -nsims- object
nsims <- 1e3
cl    <- makeForkCluster(2)    

# 2. PREPARING THE CLUSTER
RNGkind("L'Ecuyer-CMRG")
set.seed(123) 

# 3. DO YOUR CALL
ans <- do.call(cbind, mclapply(1:2, function(x) {
  runif(nsims) # Look! we use the nsims object!
               # This would have fail in makePSOCKCluster
               # if we didn't copy -nsims- first.
  }))
(ans0 <- var(ans))
```

```
#            [,1]       [,2]
# [1,] 0.08538418 0.00239079
# [2,] 0.00239079 0.08114219
```

```r
# Same sequence with same seed
set.seed(123) 
ans1 <- var(do.call(cbind, mclapply(1:2, function(x) runif(nsims))))

ans0 - ans1 # A matrix of zeros
```

```
#      [,1] [,2]
# [1,]    0    0
# [2,]    0    0
```

```r
# 4. STOP THE CLUSTER
stopCluster(cl)
```

## parallel example 2: Simulating $\pi$


*   We know that $\pi = \frac{A}{r^2}$. We approximate it by randomly adding
    points $x$ to a square of size 2 centered at the origin.

*   So, we approximate $\pi$ as $\Pr\{\|x\| \leq 1\}\times 2^2$

The R code to do this


```r
pisim <- function(i, nsim) {  # Notice we don't use the -i-
  # Random points
  ans  <- matrix(runif(nsim*2), ncol=2)
  
  # Distance to the origin
  ans  <- sqrt(rowSums(ans^2))
  
  # Estimated pi
  (sum(ans <= 1)*4)/nsim
}
```

## parallel example 2: Simulating $\pi$ (cont.)


```r
# Setup
cl <- makePSOCKcluster(10)
clusterSetRNGStream(cl, 123)

# Number of simulations we want each time to run
nsim <- 1e5

# We need to make -nsim- and -pisim- available to the
# cluster
clusterExport(cl, c("nsim", "pisim"))

# Benchmarking: parSapply and sapply will run this simulation
# a hundred times each, so at the end we have 1e5*100 points
# to approximate pi
rbenchmark::benchmark(
  parallel = parSapply(cl, 1:100, pisim, nsim=nsim),
  serial   = sapply(1:100, pisim, nsim=nsim), replications = 1
)[,1:4]
```

```
#       test replications elapsed relative
# 1 parallel            1   0.302    1.000
# 2   serial            1   1.556    5.152
```


```r
ans_par <- parSapply(cl, 1:100, pisim, nsim=nsim)
ans_ser <- sapply(1:100, pisim, nsim=nsim)
stopCluster(cl)
```


```
#      par      ser        R 
# 3.141561 3.141247 3.141593
```


## <a name="foreach"></a>The 'foreach' package

* The 'foreach' package provides a looping construct to execute R code repeatedly in parallel

* The general syntax of `foreach` looks very similar to a for loop


```r
# With parallelization --> %dopar%
output <- foreach(i = 'some object to iterate over', 'options') %dopar% {some r code}

# Without parallelization --> %do%
output <- foreach(i = 'some object to iterate over', 'options') %do% {some r code}
```

* As a first example, we can use `foreach` just like a for loop without parallelization


```r
library(foreach)
result <- foreach(x = c(4,9,16)) %do% sqrt(x)
```


```
# [[1]]
# [1] 2
# 
# [[2]]
# [1] 3
# 
# [[3]]
# [1] 4
```

## The 'foreach' package

* A closer look at the previous example

```r
result <- foreach(x = c(4,9,16)) %do% sqrt(x)
class(result)
```

```
# [1] "list"
```
  + Unlike a for loop, foreach returns an object (by default a list) that contains the results compiled across all iterations
  
  + We can change the object returned by specifying the function used to combine results across iterations with the '.combine' option

```r
result <- foreach(x = c(4,9,16), .combine = 'c') %do% sqrt(x)
result2 <- foreach(x = c(4,9,16), .combine = '+') %do% x

customCombine <- function(i,j){
  if(length(i) < 1){
    c(i,j)
  } else {
    c(i, i[length(i)]*j)
  }
}
result3 <- foreach(x = c(4,9,16), .combine = customCombine) %do% x
```


```
# [1] 2 3 4
```

```
# [1] 29
```

```
# [1]   4  36 576
```

## Parallel Execution with 'foreach'

* The steps to setup the cluster and use `foreach` in parallel are similar to the 'parallel' package  

  1. Create the cluster
  

```r
myCluster <- makeCluster(# of Cores to Use, type = "SOCK or FORK")
```

  2. Register the cluster with the 'foreach' package
  
  

```r
registerDoParallel(myCluster)
registerDoSNOW(myCluster)
```

  3. To use the cluster with `foreach`, we only have to change %do% to %dopar%


```r
output <- foreach(i = 'some object to iterate over', 'options') %dopar% {some r code}
```

  4. Stop cluster when you have finished


```r
stopCluster(myCluster)
```

## foreach example 1: Summing up numbers

* Below is a function that computes the log of each element in a sequence of numbers from 1 to x and returns the sum of the new sequence


```r
sumLog <- function(x){
  sum <- 0
  temp <- log(seq(1,x))
  for(i in temp){
    sum <- sum + i
  }
  sum
}
sumLog(3)
```

```
# [1] 1.791759
```

```r
log(1) + log(2) + log(3)
```

```
# [1] 1.791759
```

* You have been asked to find the fastest way to use this function on a large list of values, let's say for all integers from 1 to 15,000

## foreach example 1: Summing up numbers (cont.)


```r
# A vector of integers to use with sumLog function
myNumbers <- seq(1,15000)

# First Attempt: Use a for loop to loop through all the numbers
seqTest1 <- function(numbers){
  out <- vector("numeric", length = length(numbers))
  for(i in 1:length(numbers)){
    out[i] <- sumLog(myNumbers[i])
  }
  out
}
test1 <- seqTest1(myNumbers)

# Second Attempt: Use sapply function
test2 <- sapply(myNumbers, sumLog)

# Third Attempt: Use foreach function
cl <- makeCluster(10, type = "SOCK")
library(doParallel)
```

```
# Loading required package: iterators
```

```r
registerDoParallel(cl)

test3 <- foreach(i = 1:length(myNumbers), .combine = 'c') %dopar% sumLog(myNumbers[i])

stopCluster(cl)
```

## foreach example 1: Summing up numbers (cont.)

* Timing


```
# Loading required package: iterators
```


```
#      expr     mean   median
# 1 forloop 28.27404 28.27404
# 2  sapply 28.54954 28.54954
# 3 foreach  8.43848  8.43848
```

* Can we do better?

    + In `sumLog()`, we use R to sum the sequence, what if we use the `sum()` function instead?


```r
sumLog2 <- function(x){
  sum(log(seq(1,x)))
}
sapply_sumLog2 <- sapply(myNumbers, sumLog2)
foreach_sumLog2 <- foreach(i = 1:length(myNumbers), .combine = 'c') %dopar% sumLog2(i)
```


```
#              expr     mean   median
# 1  sapply_sumLog2 3.203019 3.196875
# 2 foreach_sumLog2 4.791163 4.718027
```

* `foreach` is now slower, why? 

    + The overhead due to data communication with the cores

## An aside: foreach + iterators

* The 'iterators' package provides tools for iterating over a number of different data types


```r
# General function to create an iterator
myIterator <- iter(object_to_iterate_over, by = "How to iterate over object")
```

* `foreach` transforms the object you want to iterate over into an object of class "iter"

* Example 1: A simple vector iterator


```r
vector_iterator <- iter(1:5)
nextElem(vector_iterator)
```

```
# [1] 1
```

```r
nextElem(vector_iterator)
```

```
# [1] 2
```

## An aside: foreach + iterators (cont.)

* Example 2: An iterator that traverses over blocks of columns of a matrix
  
    + The advantage? Never send the whole matrix to any one core and reduce the amount of data communication


```r
# A function to split our iterator (matrix) into blocks (column-wise)
iblkcol <- function(a, chunks) {  
  n <- ncol(a)
  i <- 1

  nextElem <- function() {
    if (chunks <= 0 || n <= 0) stop('StopIteration')
    m <- ceiling(n / chunks)
    r <- seq(i, length=m)
    i <<- i + m
    n <<- n - m
    chunks <<- chunks - 1
    a[,r, drop=FALSE]
  }
}

myMatrix <- matrix(runif(300), nrow = 3)
splitMatrix <- iblkcol(myMatrix, 25)
splitMatrix()
```

```
#           [,1]      [,2]      [,3]      [,4]
# [1,] 0.5642110 0.8680218 0.5209036 0.9408382
# [2,] 0.1586587 0.3346269 0.2838197 0.1985143
# [3,] 0.6396941 0.2618662 0.4432034 0.5593025
```

## An aside: foreach + iterators (cont.)


```r
# Example: Standardize the columns of a random large matrix with foreach + iterators
randomMatrix <- matrix(runif(100000), ncol = 10000)

# Without foreach
scale_noparallel <- scale(randomMatrix)

# With foreach, by column
scale_bycolumn <- foreach(x = iter(randomMatrix, by = 'col'), .combine = 'cbind') %dopar% scale(x)

# With foreach, blocks of columns
foreach_blocks_1000 <- foreach(x = iblkcol(randomMatrix, 1000), .combine = 'cbind') %dopar% scale(x)
foreach_blocks_100 <- foreach(x = iblkcol(randomMatrix, 100), .combine = 'cbind') %dopar% scale(x)
foreach_blocks_10 <- foreach(x = iblkcol(randomMatrix, 10), .combine = 'cbind') %dopar% scale(x)
foreach_blocks_1 <- foreach(x = iblkcol(randomMatrix, 1), .combine = 'cbind') %dopar% scale(x)
```

* Timing


```
#                   expr       mean     median
# 1                scale 0.05335319 0.05335319
# 2 foreach_singlecolumn 3.14870216 3.14870216
# 3  foreach_blocks_1000 0.42620077 0.42620077
# 4   foreach_blocks_100 0.86075290 0.86075290
# 5    foreach_blocks_10 0.14986960 0.14986960
# 6     foreach_blocks_1 0.10987660 0.10987660
```

## foreach example 1: More improvements


```r
# New function to compute sum(log(seq)) for a vector of x values
sumLog3 <- function(x){
  sapply(x, sumLog2)
}

# Reorder the numbers so that big and small numbers are mixed together --> Balance load across cores
myNumbers_interweave <- c(rbind(myNumbers[1:7500], sort(myNumbers[7501:15000], decreasing = T)))

# Create blocks of numbers --> Reduce data communication
chunks1000 <- split(myNumbers_interweave, cut(seq_along(myNumbers_interweave), 1000, labels = FALSE))
chunks100 <- split(myNumbers_interweave, cut(seq_along(myNumbers_interweave), 100, labels = FALSE))
chunks10 <- split(myNumbers_interweave, cut(seq_along(myNumbers_interweave), 10, labels = FALSE))
chunks5 <- split(myNumbers_interweave, cut(seq_along(myNumbers_interweave), 5, labels = FALSE))

# foreach with iter object to iterate of blocks of objects
sumLog2_block <- foreach(i = iter(chunks1000), .combine = 'c') %dopar% sumLog3(i)
sumLog2_block <- foreach(i = iter(chunks100), .combine = 'c') %dopar% sumLog3(i)
sumLog2_block <- foreach(i = iter(chunks10), .combine = 'c') %dopar% sumLog3(i)
sumLog2_block <- foreach(i = iter(chunks5), .combine = 'c') %dopar% sumLog3(i)
```

* Timing


```
#                  expr      mean    median
# 1      sapply_sumlog2 3.2640003 3.2544051
# 2 foreach_blocks_1000 0.8613782 0.8714444
# 3  foreach_blocks_100 0.5958943 0.5915252
# 4   foreach_blocks_10 0.6814783 0.6811157
# 5    foreach_blocks_5 1.0260959 1.0351314
```

## foreach example 2: Random Forests

* A number of statistical/learning methods involve computational steps that can be done in parallel

    + Random Forests, Gradient Boosting, Bootstrapping, Clustering, k-fold Cross-Validation
    

```r
# Random Forest Example

# Number of observations and predictor variables
n <- 3000
p <- 500

# Predictor data simulated as MVN(0,sigma) with AR(1) correlation
means_x <- rep(0,p)
var_x <- 1
rho <- 0.8
sigma_x <- matrix(NA, nrow = p, ncol = p)
for(i in 1:p){
    for(j in 1:p){
        sigma_x[i,j] <- var_x*rho^abs(i-j)
    }
}
X <- MASS::mvrnorm(n = n, mu = means_x, Sigma = sigma_x)

# Outcome is binary (two classes)
y <- gl(2, 1500)
```

## foreach example 2: Random Forests (cont.)


```r
rf <- randomForest(X, y, ntree = 5000, nodesize = 3)

rf_par <- foreach(ntree = rep(500, 10), .combine = combine, .packages = "randomForest") %dopar% {
  randomForest(X, y, ntree = ntree, nodesize = 3)
}
```

* Two changes in the call to `foreach`

    1. The 'randomForest' package has its own combine function that we can call with `.combine = combine`
    
    2. The `.packages` option is used to export the 'randomForest' package to all the cores
    
* In previous examples, we never explicitly export variables to the cores
    
    + By default, all objects in the current environment that are refenced in `foreach` are exported
    
    + '.export' and '.noexport' can be used to control which objects are exported

* Timing


```
# randomForest 4.6-12
```

```
# Type rfNews() to see new features/changes/bug fixes.
```

```
#          expr      mean    median
# 1          rf 466.03393 466.03393
# 2 rf_parallel  66.94749  66.94749
```



## <a name="rcpparmadillo-and-openmp"></a>RcppArmadillo and OpenMP

*   Friendlier than [**RcppParallel**](http://rcppcore.github.io/RcppParallel/)...
    at least for 'I-use-Rcpp-but-don't-actually-know-much-about-C++' users (like myself!).

*   Must run only 'Thread-safe' calls, so calling R within parallel blocks can cause
    problems (almost all the time).
    
*   Use `arma` objects, e.g. `arma::mat`, `arma::vec`, etc. Or, if you are used to them
    `std::vector` objects as these are thread safe.

*   Pseudo Random Number Generation is not very straight forward.

*   Need to think about how processors work, cache memory, etc. Otherwise you could
    get into trouble... if your code is slower when run in parallel, then you probably
    are facing [false sharing](https://software.intel.com/en-us/articles/avoiding-and-identifying-false-sharing-among-threads)
    
*   If R crashes... try running R with a debugger (see
    [Section 4.3 in Writing R extensions](https://cran.r-project.org/doc/manuals/r-release/R-exts.html#Checking-memory-access)):
    
    ```shell
    ~$ R --debugger=valgrind
    ```



## RcppArmadillo and OpenMP workflow

1.  Add the following to your C++ source code to use OpenMP, and tell Rcpp that
    you need to include that in the compiler:
    
    ```cpp
    #include <omp.h>
    // [[Rcpp::plugins(openmp)]]
    ```

2.  Tell the compiler that you'll be running a block in parallel with openmp
    
    ```cpp
    #pragma omp [directives] [options]
    {
      ...your neat parallel code...
    }
    ```
    
    You'll need to specify how OMP should handle the data:
    
    *   `shared`: Default, all threads access the same copy.
    *   `private`: Each thread has its own copy (although not initialized).
    *   `firstprivate` Each thread has its own copy initialized.
    *   `lastprivate` Each thread has its own copy. The last value is the one stored in the main program.
    
    Setting `default(none)` is a good practice.
    
3.  Compile!

## RcppArmadillo + OpenMP example 1: Distance matrix

```cpp
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
```

## RcppArmadillo + OpenMP example 1: Distance matrix (cont.)


```r
# Compiling the function
Rcpp::sourceCpp("dist.cpp")

# Simulating data
set.seed(1231)
K <- 5000
n <- 500
x <- matrix(rnorm(n*K), ncol=K)

# Are we getting the same?
table(as.matrix(dist(x)) - dist_par(x, 10)) # Only zeros
```

```
# 
#      0 
# 250000
```

```r
# Benchmarking!
rbenchmark::benchmark(
  dist(x),                 # stats::dist
  dist_par(x, cores = 1),  # 1 core
  dist_par(x, cores = 4),  # 4 cores
  dist_par(x, cores = 10), # 10 cores
  replications = 1, order="elapsed"
)[,1:4]
```

```
#                      test replications elapsed relative
# 4 dist_par(x, cores = 10)            1   0.508    1.000
# 3  dist_par(x, cores = 4)            1   1.225    2.411
# 2  dist_par(x, cores = 1)            1   2.344    4.614
# 1                 dist(x)            1   5.465   10.758
```


## RcppArmadillo + OpenMP example 2: Simulating $\pi$

```cpp
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
```

## RcppArmadillo + OpenMP example 2: Simulating $\pi$ (cont.)


```r
# Compiling c++
Rcpp::sourceCpp("simpi.cpp")

# Running in 1 or 10 cores should be the same
set.seed(1); sim_pi(1e5, 1)
```

```
# [1] 3.14532
```

```r
set.seed(1); sim_pi(1e5, 10)
```

```
# [1] 3.14532
```

```r
# Benchmarking
nsim <- 1e8
rbenchmark::benchmark(
  pi01 = sim_pi(nsim, 1),
  pi04 = sim_pi(nsim, 4),
  pi10 = sim_pi(nsim, 10),
  replications = 1
)[,1:4]
```

```
#   test replications elapsed relative
# 1 pi01            1   4.517    1.108
# 2 pi04            1   4.227    1.037
# 3 pi10            1   4.077    1.000
```

No big speed gains... but at least you know how to use it now :)!

## Thanks!


```
# R version 3.3.2 (2016-10-31)
# Platform: x86_64-redhat-linux-gnu (64-bit)
# Running under: CentOS Linux 7 (Core)
# 
# locale:
#  [1] LC_CTYPE=en_US.UTF-8       LC_NUMERIC=C              
#  [3] LC_TIME=en_US.UTF-8        LC_COLLATE=en_US.UTF-8    
#  [5] LC_MONETARY=en_US.UTF-8    LC_MESSAGES=en_US.UTF-8   
#  [7] LC_PAPER=en_US.UTF-8       LC_NAME=C                 
#  [9] LC_ADDRESS=C               LC_TELEPHONE=C            
# [11] LC_MEASUREMENT=en_US.UTF-8 LC_IDENTIFICATION=C       
# 
# attached base packages:
# [1] parallel  stats     graphics  grDevices utils     datasets  methods  
# [8] base     
# 
# other attached packages:
# [1] randomForest_4.6-12 doParallel_1.0.10   iterators_1.0.8    
# [4] foreach_1.4.3      
# 
# loaded via a namespace (and not attached):
#  [1] Rcpp_0.12.9               rbenchmark_1.0.0         
#  [3] codetools_0.2-15          snow_0.4-2               
#  [5] digest_0.6.12             rprojroot_1.2            
#  [7] backports_1.0.5           magrittr_1.5             
#  [9] evaluate_0.10             highr_0.6                
# [11] stringi_1.1.2             RcppArmadillo_0.7.700.0.0
# [13] rmarkdown_1.3             tools_3.3.2              
# [15] stringr_1.1.0             compiler_3.3.2           
# [17] yaml_2.1.14               htmltools_0.3.5          
# [19] knitr_1.15.1
```

## References

*   [Package parallel](https://stat.ethz.ch/R-manual/R-devel/library/parallel/doc/parallel.pdf) 
*   [Using the iterators package](https://cran.r-project.org/web/packages/iterators/vignettes/iterators.pdf)
*   [Using the foreach package](https://cran.r-project.org/web/packages/foreach/vignettes/foreach.pdf)
*   [32 OpenMP traps for C++ developers](https://software.intel.com/en-us/articles/32-openmp-traps-for-c-developers)
*   [The OpenMP API specification for parallel programming](http://www.openmp.org/)
*   ['openmp' tag in Rcpp gallery](http://gallery.rcpp.org/tags/openmp/)
*   [OpenMP tutorials and articles](http://www.openmp.org/resources/tutorials-articles/)

For more, checkout the [CRAN Task View on HPC](https://cran.r-project.org/web/views/HighPerformanceComputing.html)

