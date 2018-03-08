---
title: 'The "Happy Scientist" Semminar Series #5<br>A brief introduction to using R for high-performance computing'
author: '<par><table style="text-align:center;width:100%"><tr><td>George Vega Yon</td><td>Garrett Weaver</td></tr><tr><td>vegayon@usc.edu</td><td>gmweaver@usc.edu</tb></tr></table></par>'
output: 
  slidy_presentation:
    theme: journal
    highlight: haddock
    duration: 45
    incremental: true
    footer: Vega Yon & Weaver
    keep_md: true
date: '<br>Department of Preventive Medicine<br>March 23, 2017'
---



## Agenda

1.  High-Performance: An overview
    
2.  Parallel computing in R
    
3.  Examples:
    
    a.  parallel
    b.  iterators+foreach
    c.  RcppArmadillo + OpenMP



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
<img src="flynnsTaxonomy.gif" alt="Flynn's Classical Taxonomy ([Introduction to Parallel Computing, Blaise Barney, Lawrence Livermore National Laboratory](https://computing.llnl.gov/tutorials/parallel_comp/#Whatis))"  />
<p class="caption">Flynn's Classical Taxonomy ([Introduction to Parallel Computing, Blaise Barney, Lawrence Livermore National Laboratory](https://computing.llnl.gov/tutorials/parallel_comp/#Whatis))</p>
</div>

## GPU vs CPU

<div class="figure" style="text-align: center">
<img src="cpuvsgpu.jpg" alt="[NVIDIA Blog](http://www.nvidia.com/object/what-is-gpu-computing.html)"  />
<p class="caption">[NVIDIA Blog](http://www.nvidia.com/object/what-is-gpu-computing.html)</p>
</div>

**Why are we still using CPUs instead of GPUs?**

> GPUs have far more processor cores than CPUs, but because each GPU core runs
  significantly slower than a CPU core and do not have the features needed for
  modern operating systems, they are not appropriate for performing most of the
  processing in everyday computing. They are most suited to compute-intensive
  operations such as video processing and physics simulations.
  ([bwDraco at superuser](https://superuser.com/questions/308771/why-are-we-still-using-cpus-instead-of-gpus))

## When is it a good idea?

<div class="figure" style="text-align: center">
<img src="when_to_parallel.svg" alt="Ask yourself these questions before jumping into HPC!"  />
<p class="caption">Ask yourself these questions before jumping into HPC!</p>
</div>


## Parallel computing in R

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

Implicit parallelism, on the other hand, are out-of-the-box tools that allow the
programmer not to worry about parallelization, e.g. such as
[**gpuR**](https://cran.r-project.org/package=gpuR) for Matrix manipulation using
GPU.

## Parallel workflow

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

# Same sequence with same seed
set.seed(123) 
ans1 <- var(do.call(cbind, mclapply(1:2, function(x) runif(nsims))))

ans0 - ans1 # A matrix of zeros

# 4. STOP THE CLUSTER
stopCluster(cl)
```

## parallel example 2: Simulating $\pi$


*   We know that $\pi = \frac{A}{r^2}$. We approximate it by randomly adding
    points $x$ to a square of size 2 centered at the origin.

*   So, we approximate $\pi$ as $\Pr\{\|x\| \leq 1\}\times 2^2$

<img src="presentation_files/figure-slidy/unnamed-chunk-4-1.jpeg" width="300px" height="300px" />

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
# 1 parallel            1    0.47    1.000
# 2   serial            1    1.39    2.957
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


## The 'foreach' package

*   The 'foreach' package provides a looping construct to execute R code repeatedly in parallel

*   The general syntax of `foreach` looks very similar to a for loop
    
    ```r
    # With parallelization --> %dopar%
    output <- foreach(i = 'some object to iterate over', 'options') %dopar% {some r code}
    
    # Without parallelization --> %do%
    output <- foreach(i = 'some object to iterate over', 'options') %do% {some r code}
    ```

*   As a first example, we can use `foreach` just like a for loop without parallelization
    
    
    ```r
    library(foreach)
    result <- foreach(x = c(4, 9, 16)) %do% sqrt(x)
    result
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

* Note that `%do%` and `%dopar%` act like any other operators and can be equivalently called as `'%do%'(obj, expr)` and `'%dopar%'(obj, expr)`

## The 'foreach' package

*   Unlike a for loop, `foreach` returns an object (by default a list) that contains the results compiled across all iterations

    
    ```r
    result <- foreach(x = c(4, 9, 16)) %do% sqrt(x)
    class(result)
    ```
    
    ```
    # [1] "list"
    ```
    
*   We can change the object returned by specifying the function used to combine results across iterations with the '.combine' option
    
    
    ```r
    # Create a vector of the results
    foreach(x = c(4, 9, 16), .combine = 'c') %do% sqrt(x)
    ```
    
    ```
    # [1] 2 3 4
    ```
    
    ```r
    # Add the results
    foreach(x = c(4, 9, 16), .combine = '+') %do% x
    ```
    
    ```
    # [1] 29
    ```
    
    ```r
    # Custom combine that is tracking a running product
    customCombine <- function(i,j){
      if (length(i) < 2){
        c(i,j)
      } else {
        c(i, i[length(i)]*j)
      }
    }
    foreach(x = c(4, 9, 16), .combine = customCombine) %do% x
    ```
    
    ```
    # [1]   4   9 144
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

*   Below is a function that computes the log of each element in a sequence of numbers from 1 to x and returns the sum of the new sequence
    
    
    ```r
    sumLog <- function(x){
      sum <- 0
      for(i in seq.int(1, x)){
        sum <- sum + log(i)
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

*   You have been asked to find the fastest way to use this function on a large list of values

*   Let's say 5,000 integers randomly selected from the range {0, 1,..., 20,000}

## foreach example 1: Summing up numbers (cont.)





```r
# Sample 5000 integers from the range 1 - 20,000
myNumbers <- sample(seq(1,20000), 5000)
```

*   First Attempt: Use a for loop

    
    ```r
    seqTest1 <- function(numbers){
      out <- vector("numeric", length = length(numbers))
      for(i in seq.int(1, length(numbers))){
        out[i] <- sumLog(myNumbers[i])
      }
      out
    }
    test1 <- seqTest1(myNumbers)
    ```

*   Second Attempt: Use `sapply()`

    
    ```r
    test2 <- sapply(myNumbers, sumLog)
    ```

*   Third Attempt: Use `foreach()`

    
    ```r
    cl <- makeCluster(10, type = "SOCK")
    registerDoParallel(cl)
    test3 <- foreach(i = 1:length(myNumbers), .maxcombine = length(myNumbers),.combine = 'c') %dopar% sumLog(myNumbers[i])
    stopCluster(cl)
    ```


## foreach example 1: Summing up numbers (cont.)

*   Timing

    

    
    ```
    #      expr     mean   median
    # 1 forloop 4.084628 4.084628
    # 2  sapply 4.350735 4.350735
    # 3 foreach 2.185781 2.185781
    ```

*   Can we do better? In `sumLog()`, we use R loops to sum the sequence, what if we use the `log()` and `sum()` functions instead?
    
    
    ```r
    sumLog2 <- function(x){
      sum(log(seq.int(1,x)))
    }
    
    sapply_sumLog2 <- sapply(myNumbers, sumLog2)
    foreach_sumLog2 <- foreach(i = 1:length(myNumbers), .combine = 'c') %dopar% sumLog2(i)
    ```

    
    ```
    #              expr     mean   median
    # 1  sapply_sumLog2 1.587161 1.587161
    # 2 foreach_sumLog2 1.182589 1.182589
    ```

*   The improvement in performance of `foreach` over `sapply` is not that large, why? 
    
    *   Overhead due to data communication with the cores
    
    *   Use of `c` leads to a continual resizing of the results vector
    
    *   The operations being performed within threads are not computationally intensive

## An aside: foreach + iterators

*   The 'iterators' package provides tools for iterating over a number of different data types
    
    ```r
    # General function to create an iterator
    myIterator <- iter(object_to_iterate_over, by = "How to iterate over object")
    ```
    
*   `foreach` transforms the object you want to iterate over into an object of class "iter"

*   Example: A simple vector iterator

    
    ```r
    vector_iterator <- iter(1:4)
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
    
    ```r
    nextElem(vector_iterator)
    ```
    
    ```
    # [1] 3
    ```
    
    ```r
    nextElem(vector_iterator)
    ```
    
    ```
    # [1] 4
    ```

## An aside: foreach + iterators (cont.)

*   Example 2: An iterator that traverses over blocks of columns of a matrix

    
    ```r
    # Iterator function that traverses over blocks of columns of a matrix
    iblkcol <- function(mat, num_blocks) {  
      nc <- ncol(mat)
      i <- 1
      nextElem <- function() {
        if (num_blocks <= 0 || nc <= 0) stop('StopIteration')
        block_size <- ceiling(nc / num_blocks)
        col_idx <- seq(i, length = block_size)
        i <<- i + block_size
        nc <<- nc - block_size
        num_blocks <<- num_blocks - 1
        mat[, col_idx, drop=FALSE]
      }
    }
    myMatrix <- matrix(runif(300), nrow = 3, ncol = 100)
    splitMatrix <- iblkcol(myMatrix, 25)
    splitMatrix()
    ```
    
    ```
    #             [,1]      [,2]       [,3]       [,4]
    # [1,] 0.003147065 0.8202381 0.04666312 0.57934424
    # [2,] 0.782405319 0.6782123 0.92710481 0.01614295
    # [3,] 0.656852388 0.9828715 0.64867923 0.71503554
    ```
    
    ```r
    splitMatrix()
    ```
    
    ```
    #             [,1]      [,2]       [,3]      [,4]
    # [1,] 0.602049450 0.4287616 0.70046484 0.5623987
    # [2,] 0.816525605 0.7960140 0.20744594 0.5521983
    # [3,] 0.003589622 0.6741020 0.07346661 0.8416888
    ```

## An aside: Standardizing a Matrix

* Using foreach + iter

    ```r
    # Generate matrix with random values
    randomMatrix <- matrix(runif(5e7), ncol = 1e4)
    
    # Without foreach
    scale_noparallel <- scale(randomMatrix)
    
    # With foreach, different blocks of columns
    scale_size_1 <- foreach(x = iter(randomMatrix, by = 'col'), .combine = 'cbind') %dopar% scale(x)
    foreach_size_100 <- foreach(x = iter(randomMatrix, by = "col", chunksize = 100), .combine = 'cbind') %dopar% scale(x)
    ```
* Another option (bonus): Rcpp + Armadillo

    
    ```cpp
    #include <RcppArmadillo.h>
    // [[Rcpp::depends(RcppArmadillo)]]
    // [[Rcpp::export]]
    arma::mat standardize_data(const arma::mat & x) {
        arma::mat xnew(x.n_rows, x.n_cols);
        arma::vec w(x.n_rows);
        w.fill(1.0 / x.n_rows);
        for (unsigned int j = 0; j < x.n_cols; ++j) {
            double xm = arma::dot(w, x.unsafe_col(j));
            double xs = sqrt((arma::dot(x.unsafe_col(j) - xm, (x.unsafe_col(j) - xm) % w)) * x.n_rows / (x.n_rows - 1));
            xnew.col(j) = (x.unsafe_col(j) - xm) / xs;
        }
        return(xnew);
    }
    ```

*   Timing



    
    ```
    #               expr       mean     median
    # 1       noparallel  3.3448419  3.3448419
    # 2   foreach_size_1 10.2813561 10.2813561
    # 3 foreach_size_100  2.9852107  2.9852107
    # 4   rcpp_armadillo  0.3807034  0.3807034
    ```

## foreach example 1: More improvements to our previous problem


```r
# New function to compute sum(log(seq)) for a vector of x values
sumLog3 <- function(x){
  sapply(x, sumLog2)
}

# Create blocks of numbers 
chunks1000 <- split(myNumbers, cut(seq_along(myNumbers), 1000, labels = FALSE))
chunks100 <- split(myNumbers, cut(seq_along(myNumbers), 100, labels = FALSE))
chunks10 <- split(myNumbers, cut(seq_along(myNumbers), 10, labels = FALSE))

# foreach with iter object to iterate of blocks of objects
sumLog2_block <- foreach(i = iter(chunks1000), .combine = 'c') %dopar% sumLog3(i)
sumLog2_block <- foreach(i = iter(chunks100), .combine = 'c') %dopar% sumLog3(i)
sumLog2_block <- foreach(i = iter(chunks10), .combine = 'c') %dopar% sumLog3(i)
```

*   Timing
    
    
    ```
    #                  expr      mean    median
    # 1      sapply_sumlog2 1.5563548 1.5563548
    # 2 foreach_blocks_1000 0.6058905 0.6058905
    # 3  foreach_blocks_100 0.4407942 0.4407942
    # 4   foreach_blocks_10 0.4996990 0.4996990
    ```

## foreach example 2: Random Forests

* A number of statistical/learning methods involve computational steps that can be done in parallel

    
    
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

* Two changes in the call to `foreach`

    ```r
    rf <- randomForest(X, y, ntree = 500, nodesize = 3)

    rf_par <- foreach(ntree = rep(50, 10), .combine = combine, .packages = "randomForest") %dopar% {
        randomForest(X, y, ntree = ntree, nodesize = 3)
    }
    ```

    1. The 'randomForest' package has its own combine function that we can call with `.combine = combine`
    
    2. The `.packages` option is used to export the 'randomForest' package to all the cores


* In previous examples, we never explicitly export variables to the cores
    
    + By default, all objects in the current environment that are refenced in `foreach` are exported
    
    + '.export' and '.noexport' can be used to control which objects are exported

* Timing

    

    
    ```
    #          expr     mean   median
    # 1          rf 27.04903 27.04903
    # 2 rf_parallel 19.84977 19.84977
    ```


## RcppArmadillo and OpenMP

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
# 3  dist_par(x, cores = 4)            1    1.58    1.000
# 4 dist_par(x, cores = 10)            1    1.67    1.057
# 2  dist_par(x, cores = 1)            1    3.11    1.968
# 1                 dist(x)            1    7.59    4.804
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
# 1 pi01            1    4.78    1.081
# 2 pi04            1    4.42    1.000
# 3 pi10            1    4.43    1.002
```

No big speed gains... but at least you know how to use it now :)!

## Thanks!


```
# R version 3.4.3 (2017-11-30)
# Platform: x86_64-w64-mingw32/x64 (64-bit)
# Running under: Windows 10 x64 (build 16299)
# 
# Matrix products: default
# 
# locale:
# [1] LC_COLLATE=English_United States.1252 
# [2] LC_CTYPE=English_United States.1252   
# [3] LC_MONETARY=English_United States.1252
# [4] LC_NUMERIC=C                          
# [5] LC_TIME=English_United States.1252    
# 
# attached base packages:
# [1] parallel  stats     graphics  grDevices utils     datasets  methods  
# [8] base     
# 
# other attached packages:
# [1] randomForest_4.6-12 doParallel_1.0.11   iterators_1.0.9    
# [4] foreach_1.4.4      
# 
# loaded via a namespace (and not attached):
#  [1] Rcpp_0.12.15     codetools_0.2-15 snow_0.4-2       digest_0.6.15   
#  [5] rprojroot_1.3-2  backports_1.1.2  magrittr_1.5     evaluate_0.10.1 
#  [9] highr_0.6        stringi_1.1.6    rmarkdown_1.8    tools_3.4.3     
# [13] stringr_1.3.0    yaml_2.1.16      compiler_3.4.3   htmltools_0.3.6 
# [17] knitr_1.20
```

## References

*   [Package parallel](https://stat.ethz.ch/R-manual/R-devel/library/parallel/doc/parallel.pdf) 
*   [Using the iterators package](https://cran.r-project.org/web/packages/iterators/vignettes/iterators.pdf)
*   [Using the foreach package](https://cran.r-project.org/web/packages/foreach/vignettes/foreach.pdf)
*   [32 OpenMP traps for C++ developers](https://software.intel.com/en-us/articles/32-openmp-traps-for-c-developers)
*   [The OpenMP API specification for parallel programming](http://www.openmp.org/)
*   ['openmp' tag in Rcpp gallery](gallery.rcpp.org/tags/openmp/)
*   [OpenMP tutorials and articles](http://www.openmp.org/resources/tutorials-articles/)

For more, checkout the [CRAN Task View on HPC](https://cran.r-project.org/web/views/HighPerformanceComputing.html)


