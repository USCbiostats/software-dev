Since RStudio.com has precompiled versions of RStudio, we can actually take advantage of it. The only thing you need to have is a copy of RStudio for CentOS/RHL 7+ and, if using PC or Mac, Xming/X11 to run it.

## **Running RStudio on HPC is not recommended for running big/large jobs**, but for running R interactively and do code editing. 

# Mac Version
1. Make sure X11 is installed on your Macbook. Download [here](https://www.xquartz.org/). 

2. Download RStudio zipped file on your HPC. Download [here](https://www.rstudio.com/products/rstudio/download/). 

   <img src="http://drive.google.com/uc?export=view&id=1cy22jAY5DOIgC_7Twu0OYnflJj8QTfaY" alt="RStudio">

3. Login your HPC account with X11 enabled via the terminal (the `-X` flag). 

   `$ ssh -X yourname@hpc-login3.usc.edu`

4. Transfer the zipped RStudio file under your HPC directory and unzip it. 

   `$ tar xvf rstudio-1.1.456-x86_64-fedora.tar.gz`

5. Request a single node to start your work. This example code only applies if you are under the conti partition. 

   `$ salloc --partition=conti --account=lc_dvc --time=01:00:00` 

6. Source R by 

   `$ source /usr/usc/R/3.5.0/setup.sh` 

   or use the default R version 

   `$ source /usr/usc/R/default/setup.sh`

7. The last step is to open RStudio (remember to change `yourname` to your name). 

   `$ /home/pmd-01/yourname/rstudio-1.1.456/bin/./rstudio >/dev/null 2>&1 &`

8. You are good to go. Enjoy! Use `exit` at the terminal to exit the node that you requested earlier. 



# Windows Version
1. Make sure Xming is installed on your local computer. Download [here](https://sourceforge.net/projects/xming/). 

2. Download RStudio zipped file on your HPC. Download [here](https://www.rstudio.com/products/rstudio/download/). 

   <img src="http://drive.google.com/uc?export=view&id=1cy22jAY5DOIgC_7Twu0OYnflJj8QTfaY" alt="RStudio">

3. Update the settings in PuTTY as shown in the image below and enable X11.

   <img src="https://wikis.nyu.edu/download/attachments/84611827/image2017-2-17%2015%3A34%3A2.png?version=1&modificationDate=1487363642091&api=v2Y" alt="PuTTY" width=500>

4. Login your HPC account via PuTTY and keep Xming open. 

   `$ ssh yourname@hpc-login3.usc.edu`

5. Transfer the zipped RStudio file under your HPC directory and unzip it. 

   `$ tar xvf rstudio-1.1.456-x86_64-fedora.tar.gz`

6. Request a single node to start your work. This example code only applies if you are under the conti partition. 

   `$ salloc --partition=conti --account=lc_dvc --time=01:00:00` 

7. Source R by 

   `$ source /usr/usc/R/3.5.0/setup.sh` 

   or use the default R version 

   `$ source /usr/usc/R/default/setup.sh`

8. The last step is to open RStudio (remember to change `yourname` to your name). 

   `$ /home/pmd-01/yourname/rstudio-1.1.456/bin/./rstudio >/dev/null 2>&1 &`

9. You are good to go. Enjoy! Use `exit` at the terminal to exit the node that you requested earlier.  

   <img src="http://drive.google.com/uc?export=view&id=1d1SA_bbpsRL_R0ZiApznhPpI6dh1aWL-" alt="RStudio2" width=300>


