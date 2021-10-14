
# Introduction

Setting up an R package that supports OpenMP can be a bit awkward. While systems like Ubuntu with g++ have straight forward support for `-fopenmp` flags, the same may not be true un MacOS's `clang`, since the latter is not shipped with it.

In order to solve this, it is necesary to have different `src/Makevars` file depending on whether the compiler supports OpenMP or not. This can be solved using a `configure` file, more over, `autoconf`.

[Autoconf](https://www.gnu.org/software/autoconf/autoconf.html) is "an extensible package of M4 macros that produce shell scripts to automatically configure software source code packages". Among the (cool) things that we can use it for is creating tailored `src/Makevars` files (and furthermore, any other files... even R/*.r source code can be modified with this, just take a look at [Writing R Extensions](https://cran.r-project.org/doc/manuals/r-devel/R-exts.html#Configure-and-cleanup)). The workflow of `R CMD`+autoconf follows:

1.  The `configure` file is executed and performs the requested checks (like having OpenMP) and modifies/creates the configuration files that will be used to compile the package, like `src/Makevars`, `src/makefile`, etc. Furthermore, it can use "templates" to create such files, which have the suffix `.in`, for example, `src/Makevars.in`.

2.  `R CMD` will compile the package using all the inputs (`src/Makevars`, `src/makefile`) that were created, and

3.  In the case of `R CMD build`, `R CMD` will call `cleanup` (they require you to do so) to remove the `config.*` files and `src/Makevars` so these are not shipped with the package file.

The next section describes the files that you need to include in your project to set it up using `RcppArmadillo` with OpenMP support depending on whether it is available with the compiler. This example is from the R package [netdiffuseR](https://github.com/USCCANA/netdiffuseR).

# Configuration Files

In order to use `autoconf` to optionally include OpenMP with your R package, you need to have the following files in your system:

1.  Need a `configure.ac` file. This is what `autoconf` uses as input.
    
    ```ac
    #                                               -*- Autoconf -*-
    # netdiffuseR configure.ac
    # (with some code borrowed from RcppArmadillo configure.ac
    # and ARTP2 configure.ac)
    # 
    # Process this file with autoconf to produce a configure script.
    
    AC_PREREQ([2.69])
    ```
    
    This line can be replaced by whatever the name of your package is (here is netdiffuseR)
    
    ```
    AC_INIT(netdiffuseR, m4_esyscmd_s([awk '/^Version:/ {print $2}' DESCRIPTION]))
    ```
    
    These couple of lines set up the path to R
    
    ```
    ## Set R_HOME, respecting an environment variable if one is set 
    : ${R_HOME=$(R RHOME)}
    if test -z "${R_HOME}"; then
        AC_MSG_ERROR([Could not determine R_HOME.])   
    fi
    ## Use R to set CXX and CXXFLAGS
    CXX=$(${R_HOME}/bin/R CMD config CXX)
    CXXFLAGS=$("${R_HOME}/bin/R" CMD config CXXFLAGS)
    
    ## We are using C++
    AC_LANG(C++)
    AC_REQUIRE_CPP
    ```
    
    This are the lines that actually do the job on setting OpenMP. I copied this from the ARTP2 R Package.
    
    ```

    dnl this the meat of R's m4/openmp.m4
      OPENMP_[]_AC_LANG_PREFIX[]FLAGS=
      AC_ARG_ENABLE([openmp],
        [AS_HELP_STRING([--disable-openmp], [do not use OpenMP])])
      if test "$enable_openmp" != no; then
        AC_CACHE_CHECK([for $[]_AC_CC[] option to support OpenMP],
          [ac_cv_prog_[]_AC_LANG_ABBREV[]_openmp],
          [AC_LINK_IFELSE([_AC_LANG_OPENMP],
       	 [ac_cv_prog_[]_AC_LANG_ABBREV[]_openmp='none needed'],
    	 [ac_cv_prog_[]_AC_LANG_ABBREV[]_openmp='unsupported'
    	  for ac_option in -fopenmp -xopenmp -qopenmp \
                               -openmp -mp -omp -qsmp=omp -homp \
    			   -fopenmp=libomp \
                               -Popenmp --openmp; do
    	    ac_save_[]_AC_LANG_PREFIX[]FLAGS=$[]_AC_LANG_PREFIX[]FLAGS
    	    _AC_LANG_PREFIX[]FLAGS="$[]_AC_LANG_PREFIX[]FLAGS $ac_option"
    	    AC_LINK_IFELSE([_AC_LANG_OPENMP],
    	      [ac_cv_prog_[]_AC_LANG_ABBREV[]_openmp=$ac_option])
    	    _AC_LANG_PREFIX[]FLAGS=$ac_save_[]_AC_LANG_PREFIX[]FLAGS
    	    if test "$ac_cv_prog_[]_AC_LANG_ABBREV[]_openmp" != unsupported; then
    	      break
    	    fi
    	  done])])
        case $ac_cv_prog_[]_AC_LANG_ABBREV[]_openmp in #(
          "none needed" | unsupported)
    	;; #(
          *)
    	OPENMP_[]_AC_LANG_PREFIX[]FLAGS=$ac_cv_prog_[]_AC_LANG_ABBREV[]_openmp ;;
        esac
      fi
    
    AC_SUBST(OPENMP_CXXFLAGS)
    AC_CONFIG_FILES([src/Makevars])
    AC_OUTPUT
    
    ```
    
2.  A `src/Makevars.in` file which will be modified by configure. The most important part here is the `@OPENMP_CXXFLAGS@` tag, which will be replaced accordingly:
    
    ```
    PKG_LIBS = $(LAPACK_LIBS) $(BLAS_LIBS) $(FLIBS) @OPENMP_CXXFLAGS@
    # 1.2.4 Using C++11 code
    CXX_STD = CXX11
    
    # Besides of the -fopenmp flag, here I'm telling armadillo to use
    # 64BIT_WORD which removes the matrix size limit constraint.
    PKG_CXXFLAGS=@OPENMP_CXXFLAGS@ -DARMA_64BIT_WORD
    ```

3.  A `cleanup` file (with execution permissions) that `R CMD build` will call after building the package. Again, this is a requirement.
    
    ```
    #!/bin/sh
    rm -f config.* src/Makevars
    ```

Once you have all these files in order, you have to run `autoconf` so that the `configure` file is created, i.e.

```shell
$ autoconf
```

If you happen to use travis.yml, you need to specify a more modern distribution so that RcppArmadillo can built with a more modern compiler. In order to do so, put the `dist: trusty` option in the yml file. Here is an example travis file from netdiffuseR:

```yml
dist: trusty
language: r
sudo: required

r:
  - release
  - devel # Not working
  - oldrel

os:
  - linux
  - osx

osx_image: xcode7.3

env:
 global:
   - CRAN: http://cran.rstudio.com

r_packages:
  - ape
  - covr
  - testthat
  - knitr
  - rmarkdown
  - RSiena
  - igraph
  - survival

after_success:
  - if [ $TRAVIS_OS_NAME == "linux" ]; then Rscript -e 'covr::codecov()'; fi

after_failure:
  - ./run.sh dump_logs

notifications:
  email:
    on_success: change
    on_failure: change
```


Finally, you'll need to add/keep the following files to your repository: `configure`, `configure.ac`, `src/Makevars.in`, `src/Makevars.win`, and `cleanup`. Otherwise you'll find yourself scratching your head and asking why is travis failing... belive me.

# See also

*  The RcppArmadillo [configure.ac](https://github.com/RcppCore/RcppArmadillo/blob/dcc8d474446aacabbb13813ee7da4636eeeee450/configure.ac) file

*  The netdiffuseR [configure.ac](https://github.com/USCCANA/netdiffuseR/blob/98020e28dce5fd8cbabd497eb7fbf99be3ec0e2e/configure.ac) file.

* The aphylo [configure.ac]() file.