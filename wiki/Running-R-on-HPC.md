# Introduction

A couple of things you need to know before you start working with HPC:

1.  While we have a huge storage space, your home directory (`~`) most certainly has 1GB of space, which makes it a bad idea to try to install R packages and store big files there. For that use your project folder.
    
    If you want to store big temporary files, you can always use `/staging/` (see [here](https://hpcc.usc.edu/support/infrastructure/temporary-disk-space/))

2.  Login is done via *head nodes*, which are **NOT FOR COMPUTING**, which means that whenever you want to start doing computation, you need to request nodes via Slurm.

3.  There are several partitions (groups of nodes) on HPC, and the Biostats division has a couple of these. Notably, the `conti` partition (which is associated to the `lc_dvc` account). This **DOESN'T MEAN THAT YOU CAN DO WHATEVER YOU WANT**, when submitting jobs be mindful about the other users.

4.  NOT ALL YOUR PROBLEMS NEED TO BE SOLVED WITH HPC. Some of them just need more efficient code or C++ on it.

# Login

## Windows

If you are using windows, you need to get the [Putty](https://www.putty.org) client.

## Mac OS/Linux/Unix

On the terminal, just type

```shell
$ ssh your-user-name@hpc-login2.usc.edu
```

And follow the instructions. Of course, you'll need to replace `[your-user-name]` with your corresponding user name. The following will happen:

1.  You'll be asked to type in your password.
2.  If correctly typed, it will ask you to select one of the options to [login using duo](https://itservices.usc.edu/duo/).

You can read more about loging in into HPC in the [HPCC website](https://hpcc.usc.edu/gettingstarted/#login).

# Setup

## Loading R

```shell
$ source /usr/usc/R/3.4.0/setup.sh
```

After sourcing the setup bash file, you can start using R by just typing `R` on the console:

```shell
$ R
```

**:warning: IMPORTANT: NEVER EVER RUN JOBS ON THE HEAD NODE, I.E. WITHOUT CALLING `sbatch`/`srun`/`salloc` FIRST :warning:**

## Installing R packages

Suppose that you have a folder that has significant space for storage, e.g. `/home/pmd-01/ttrojan`. You will want to install your R packages there instead of the home directory, and to make everything work, you'll need to create a symbolic link from your home directory to that:

```shelll
$ mkdir /home/pmd-01/ttrojan/R # Will create a folder named R
$ ln -s /home/pmd-01/ttrojan R # Will create a symbolic link to it
```

This way, anything 

1.  The first time that you try to install a package, R will tell you that it cannot write on the shared library (which is located at),
2.  so it will prompt a question on whether you want R to create a new library folder for you in your home directory `~/R`.
3.  Once you type `Y` + Enter, it will actually create a library at `/home/pmd-01/ttrojan/R` as it will be accessing the symbolic link.

This way, all your R packages will be installed there and not in your home folder (`~`)

# Running R

## Interactively

While not entirely recomended, you can run R interactively. To run R interactively you can do the following:

```shell
$ salloc # Will request a compute node
$ source /usr/usc/R/default/setup.sh # Will load the default version of R on HPC
$ R # Will start R
```

The allocation of computation resources on HPC can be further tailored to your needs. By default, `salloc` will allocate a single node for a max time of 30min. For more on this checkout the salloc manual page [here](https://slurm.schedmd.com/salloc.html).

## Batch JOBS

Prepare a bash file for Slurm, here we call it `my-simulations.sh`:

```shell
#!/bin/bash
#SBATCH --time=01:00:00
#SBATCH --job-name=my-simulations
#SBATCH --output=my-simulations-%A.out
source /usr/usc/R/default/setup.sh
Rscript --vanilla ~/my-simulations.R 
```

And then execute it using `sbatch`

```shell
$ sbatch my-simulations.sh
```

You can checkout any messages from R in the log file 

**:information_source: Protip: Try to name your R script, your R file and your log file the same except for the extension of the file. This will make easier keeping track of things in your filesystem**

**:information_source: Protip: In your R script `my-simulations.R` add calls to `message()` to tell yourself about the progress of your script**

## Mixed

You can always run interactively and also call `sbatch` at the same time. An example of this is done with the [`rslurm`](https://github.com/USCbiostats/rslurm) package, and the [`sluRm`](https://github.com/USCbiostats/sluRm) package.