1.  source /usr/usc/R/3.4.0/setup.sh

2.  source /usr/usc/openmpi/1.8.8/setup.sh

3.  wget https://cran.r-project.org/src/contrib/Rmpi_0.6-6.tar.gz

4.  
    
    ```shell    
    R CMD INSTALL -l ~/R/x86_64-redhat-linux-gnu-library/3.4/ \
      --configure-args="--with-mpi=/usr/usc/openmpi/1.8.8/slurm --with-Rmpi-type=OPENMPI" \
      Rmpi_0.6-6.tar.gz --no-test-load
    ```

