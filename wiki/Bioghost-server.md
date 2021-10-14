# Introduction

This document describes the current configuration of the bioghost.usc.edu server. Be advised that this document is permanently 'work-in-progress'.

# Setup

The following instructions have been written for a server running [**CentOS Linux release 7.3.1611 (Core)**](https://wiki.centos.org/Manuals/ReleaseNotes/CentOS7) that
has been registered to have a static IP/www address (see [here](https://itservices.usc.edu/registration/)).

## Security

<!--

### SSH Access

1.  In the file `/etc/ssh/sshd_config` set the options Port and `PermitRootLogin`
    to "2436" and "no" respectively as follows
    
    ```shell
    Port 22
    ...
    PermitRootLogin no
    ```

2.  Once you have changed that, restart the ssh service as follows
    
    ```shell
    sudo service ssh restart
    ```
    
    You will be kicked out of the server (since originally you connected to it)
    using the port 22. Now connect again using port 2436 instead.


-->

## Software

### valgrind

**What is it?**

> Valgrind is an instrumentation framework for building dynamic analysis tools. There are Valgrind tools that can automatically detect many memory management and threading bugs, and profile your programs in detail. (valgrind.org)

We use it mostly to check memory leaks in R packages when running `R CMD check --use-valgrind`

**How to install it**

```shell
$ sudo yum install valgrind
```

### wget

**What is it?**

> GNU Wget is a free software package for retrieving files using HTTP, HTTPS and FTP, the most widely-used Internet protocols. It is a non-interactive commandline tool, so it may easily be called from scripts, cron jobs, terminals without X-Windows support, etc. ([GNU Operating System](https://www.gnu.org/software/wget/))

**How to install it**

```shell
$ sudo yum install wget
```

### Perl

**What is it?**

> Perl is a family of high-level, general-purpose, interpreted, dynamic programming languages. The languages in this family include Perl 5 and Perl 6. ([wiki](https://en.wikipedia.org/wiki/Perl))

**How to install it**

For now, we use perl to install texlive

```shell
$ sudo yum install perl perl-Digest-MD5
```

### TexLive 2016

**What is it?**

> TeX Live is a free software distribution for the TeX typesetting system that
includes major TeX-related programs, macro packages, and fonts.
([wiki](https://en.wikipedia.org/wiki/TeX_Live))

**How to install it**

1.  Download and execute the installer as follows:

    ```shell
    $ wget http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
    $ tar xzf install-tl-unx.tar.gz
    $ cd ./install-tl-20170209/
    $ sudo perl install-tl
    ```

2.  Setup process, make sure you activate the option "create symlinks to standard
    directories". This will make available `pdflatex` and friends system wide.
    
### Pandoc

**What is it?**

> Pandoc is a free and open-source software document converter,
widely used as a writing tool (especially by scholars) and as a basis
for publishing workflows. It was originally created by John MacFarlane,
a philosophy professor at the University of California, Berkeley.
([wiki](https://en.wikipedia.org/wiki/Pandoc))

**How to install it**

Not right now, we just use the RStudio default

<!--
Can be downloaded directly from the development website https://github.com/jgm/pandoc/releases/. The current version is Pandoc 1.17.2
    
1.  Download and install Pandoc 1.17.2 as follows

    ```shell
    wget https://github.com/jgm/pandoc/releases/download/1.17.2/pandoc-1.17.2-1-amd64.deb
    sudo dpkg -i pandoc-1.17.2-1-amd64.deb
    ```
-->

### mlocate

**What is it?**

**How to install it**

```shell
$ sudo yum install mlocate
```

### qpdf

**What is it?**

> QPDF is a command-line program that does structural, content-preserving transformations on PDF files.
[project's website](http://qpdf.sourceforge.net/)

**How to install it**

```shell
$ sudo yum install qpdf
```

### R

**What is it?**

> R is a programming language and software environment for statistical computing
and graphics supported by the R Foundation for Statistical Computing.
([wiki](https://en.wikipedia.org/wiki/R_(programming_language)))

**How to install it**

1.  Add the following repository

    ```shell
    $ # Info from https://cran.rstudio.com/bin/linux/redhat/README
    $ sudo rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
    ```

2.  Install R

    ```shell
    $ sudo yum install R
    ```

For personalizing system-wide R-sessions, type `?Rprofile` in the R terminal.
The following R packages are installed (besides the default ones):
    
*   For reporting: knitr, rmarkdown, texreg, shiny
*   For SNA: statnet, sna, igraph, RSiena, netdiffuseR
*   Others: dplyr, ggplot2, Rcpp, RcppArmadillo, AER, microbenchmark, ape,
    devtools, readxl, roxygen2, testtha, tm, stringr, xml2

For more information, visit the "Ubuntu Packages for R" section in the R-project
website: https://cran.r-project.org/bin/linux/ubuntu/README.html

### RStudio-server

**What is it?**

> RStudio is a free and open-source integrated development environment (IDE)
for R, a programming language for statistical computing and graphics.
([wiki](https://en.wikipedia.org/wiki/RStudio)))

**How to install it**

1.  Installation is as easy as typing the following commands

    ```shell
    
    wget sudo yum install --nogpgcheck rstudio-server-rhel-1.0.136-x86_64.rpm
    ```
    
2.  For security, we change the access Port by editing the following file
    `/etc/rstudio/rserver.conf`. Just add/replace the following line
    
    ```shell
    www-port=3624
    ```
    
    This will allow RStudio server to accept connections only from port 3624.
    Therefore, to login to RStudio server, you must type the following address
    in your web-browser URL bar http://bioghost.usc.edu:3624, but first, we
    need to open port 3624

3.  To open a port in CentOS 7, we do the following

    ```shell
    $ sudo firewall-cmd --zone=public --add-port=3624/tcp --permanent
    $ sudo firewall-cmd --reload
    ```

4.  Finally, in order to make sure the login is smooth, we need to copy
    the pam login profile of the system to rstudio's

    ```shell
    $ sudo cp /etc/pam.d/login /etc/pam.d/rstudio
    $ sudo rstudio-server restart
    ```

    This solution was posted [here](https://support.rstudio.com/hc/en-us/community/posts/200656406-Getting-RServer-to-work), in the RStudio blog.

For more information, visit the RStudio server website https://www.rstudio.com/products/rstudio/download-server/

**Troubleshooting**

What to do when RStudio server says 

```shell
rserver[23961]: ERROR system error 98 (Address already in use); OCCURRED AT: rstudio::core::Error rstudio::core::http::initTcpIpAcceptor(rstudio::core::http::SocketAcce...
```

```shell
$ sudo rstudio-server stop
$ ps -aux | grep rserver
$ sudo kill -9 [pid] # Or you can kill them all with sudo killall -9 rserver
$ sudo rstudio-server start
```

### The `devtools` R package

**What is it?**

> The aim of devtools is to make package development easier by providing R functions that
simplify common tasks. ([GitHub website of the project](https://github.com/hadley/devtools))

**How to install it**

1.  For the `curl` package, run libcurl-devel `sudo yum install libcurl-devel`

2.  For the `openssl` and `git2r` packages, run `sudo yum install openssl-devel`
    
    Once the dependencies are install, each user can install it's own copy of `devtools
    by typing
    
    ```R
    > install.packages("devtools")
    ```

### The `roxygen2` package

**What is it?**



**How to install it**

1.  It requires the `xml2` R-package, which requires the `libxml2-devel` library
    `sudo yum install libxml2-devel`

2.  Once the dependencies are install, each user can install it's own copy of `devtools
    by typing
    
    ```R
    > install.packages("roxygen2")
    ```

### The `rgl` package

**What is it?**

**How to install it**

Currently, while the package's installation process is successful, creating rgl
devices is not possible at the time due to issues with X11 (needs to be resolved).
For now, here are the instructions to install rgl.

1.  To install rgl, we need some extra libraries:
    
    ```shell
    $ sudo yum install xauth
    ```

2.  Once the dependencies are install, each user can install it's own copy of `devtools
    by typing
    
    ```R
    > install.packages("rgl")
    ```

3.  http://linuxtoolkit.blogspot.com/2015/10/libgl-error-unable-to-load-driver.html
    
    ```shell
    $ sudo yum install mesa-libGL-devel mesa-libGLU-devel libpng-devel
    ```

More information go to the package's [README](https://cran.r-project.org/web/packages/rgl/README) file

### net-tools

**What is it?**

I use it to check the ports usage: `netstat -anp | grep 3624` will list the connections that are using port 3624. 

**How to install it**

```shell
$ sudo yum install net-tools
```

### The DMRcate R package (Bioconductor)

This needs BiocManager (which can be install via install.packages) and, for some indirect dependency, the libjpeg library, which was installed using `sudo yum install libjpeg-*`. Once the dependencies are done (there could be a few more), you can install the package using `BiocManager::install("DMRcate")`.

### The `rjags` R package

**What is it?**

> Interface to the JAGS MCMC library. (rjags at [CRAN](https://CRAN.R-project.org/package=rjags))

**How to install it (if you have sudo)**

1.  Install the jags and jags-dev packages in the OS:
    
    ```shell
    $ sudo rpm -Uhv http://download.opensuse.org/repositories/home:/cornell_vrdc/CentOS_7/x86_64/jags4-4.1.0-65.2.x86_64.rpm
    $ sudo rpm -Uhv http://download.opensuse.org/repositories/home:/cornell_vrdc/CentOS_7/x86_64/jags4-devel-4.1.0-65.2.x86_64.rpm
    $ sudo rpm -Uhv http://download.opensuse.org/repositories/home:/cornell_vrdc/CentOS_7/x86_64/jags4-debuginfo-4.1.0-65.2.x86_64.rpm
    ```

2.  Then, install the R package using `install.packages("rjags")`.

**How to install it (if you don't have sudo)**

1. Get JAGS http://mcmc-jags.sourceforge.net/, in particular from https://sourceforge.net/projects/mcmc-jags/files/JAGS/4.x/Source/

2. tar xf JAGS*.tar.gz

3. Need to get LAPACK https://github.com/Reference-LAPACK/lapack/archive/v3.9.0.tar.gz

### Apache HTTP Server

**What is it?**

> is free and open-source cross-platform web server software, released under the terms of Apache License 2.0. Apache is developed and maintained by an open community of developers under the auspices of the Apache Software Foundation (Apache at [Wiki](https://en.wikipedia.org/wiki/Apache_HTTP_Server))

**How to install it**

1.  Install httpd
    
    ```
    $ sudo yum -y install httpd
    ```

2.  Start and enable the service

    ```shell
    $ sudo systemctl start httpd
    $ sudo systemctl enable httpd.service
    ```

3.  Setting up the firewall (adding port 80, http)
    
    ```shell
    $ sudo firewall-cmd --permanent --add-port=80
    ```

The webserver should show a default website when following http://bioghost.usc.edu. The default can be modified in `/var/www/html/`

### RStudio connect

**What is it?**

> RStudio Connect is a new publishing platform for the work your teams create in R. Share Shiny applications, R Markdown reports, Plumber APIs, dashboards, plots, and more in one convenient place. Use push-button publishing from the RStudio IDE, scheduled execution of reports, and flexible security policies to bring the power of data science to your entire enterprise. (RStudio connect [website](https://www.rstudio.com/products/connect/))

**How to install it**

RStudio grants full licenses for educational purposes. In our case, Prof. Marjoram got us a 1 year license to try it out (usually is for 45 days-only). To install and active RStudio connect you need to contact RStudio directly. Once it has been set up, one important bit is to configure the login capabilities:

1. Change the file `/etc/rstudio-connect/rstudio-connect.gcfg` and set the following option: `Password = pam`
   
   ```
   [Authentication]
   Provider = pam             
   ```
   
   This will cause RStudio connect to use the same login system that we use in Bioghost.

2. Edit the file `/etc/pam.d/rstudio-connect` to be as the following:
   
   ```
   #%PAM-1.0
   auth [user_unknown=ignore success=ok ignore=ignore default=bad] pam_securetty.so
   auth       substack     system-auth
   auth       include      postlogin
   account    required     pam_nologin.so
   account    include      system-auth
   password   include      system-auth
   # pam_selinux.so close should be the first session rule
   session    required     pam_selinux.so close
   session    required     pam_loginuid.so
   session    optional     pam_console.so
   # pam_selinux.so open should only be followed by sessions to be executed in the user context
   session    required     pam_selinux.so open
   session    required     pam_namespace.so
   session    optional     pam_keyinit.so force revoke
   session    include      system-auth
   session    include      postlogin
   -session   optional     pam_ck_connector.so
   ```
   
   These very same rules are the ones we use for RStudio Server.

3. Stop and start the service as follows:
   
   ```
   sudo service rstudio-connect stop
   sudo service rstudio-connect start
   ```
   
   And you should be good to go.

Currently RStudio connect is set with the default configuration for http access. So to access the dashboard you need to go to http://bioghost.usc.edu:3939. This address is also the one you need to use in order to setup RStudio connect in your RStudio server machine.

**Adding RStudio connect to RStudio**

You can use this directly with RStudio. The only requirement is to have a prevmed account (which all of you have), and be under the USC network (VPN if you are outside USC). To publish either a shiny app or any other markdown document (html output of course), you need to do the following:

To add the new publishing tool:

1. Go to Tools > Global Options
2. Go to "Publish"
3. Click on "Connect", and select "RStudio Connect"
4. The public URL is http://bioghost.usc.edu:3939 If everything works fine, you should be asked to login to RStudio connect in bioghost (I did had a problem relating to an old version of RCurl, which is needed for this!). Enter your prevmed account credentials.
5. Click on "Connect" and you are good to go!

To publish new content, open any Rmarkdown/Shiny app and:

1. Go to File > Publish
2. Follow the instructions

Here you can find an example app that I just published: http://bioghost.usc.edu:3939/rstudio-connect-example/ You need to login to be able to look at it!

 
### shiny-server

**What is it?**

> Shiny is an R package that makes it easy to build interactive web apps straight from R. You can host standalone apps on a webpage or embed them in R Markdown documents or build dashboards. You can also extend your Shiny apps with CSS themes, htmlwidgets, and JavaScript actions. (shiny [website](http://shiny.rstudio.com/))

**How to install it**

0.  Make sure you have `shiny` and `rmarkdown` available system-wide, from R:
    
    ```r
    > install.packages(c("shiny", "rmarkdown"))
    ```

1.  To install
    
    ```shell
    $ wget https://download3.rstudio.org/centos5.9/x86_64/shiny-server-1.5.5.872-rh5-x86_64.rpm
    $ sudo yum install --nogpgcheck shiny-server-1.5.5.872-rh5-x86_64.rpm
    ```
    
2.  You need to open the default port (which can be modified `/etc/shiny-server/shiny-server.conf`) as follows:
    ```shell
    $ sudo firewall-cmd --zone=public --add-port=3838/tcp --permanent
    $ sudo firewall-cmd --reload
    ```

3.  To start/stop (more details [here](http://docs.rstudio.com/shiny-server/#upstart-ubuntu-12.04-through-14.10-redhat-6))
    ```shell
    $ sudo /sbin/service shiny-server start1
    ```

To add apps, you need to add them to the folder `/srv/shiny-server`, and you can access them using http://bioghost.usc.edu:3838 (the default website).


### docker

**What is it?**

**How to install it?**

Follow the instructions here https://docs.docker.com/engine/installation/linux/docker-ce/centos/#set-up-the-repository

To allow group usage, follow these instructions: https://askubuntu.com/questions/477551/how-can-i-use-docker-without-sudo

### autoconf

**What is it?**

> Autoconf is an extensible package of M4 macros that produce shell scripts to automatically configure software source code packages. These scripts can adapt the packages to many kinds of UNIX-like systems without manual user intervention. Autoconf creates a configuration script for a package from a template file that lists the operating system features that the package can use, in the form of M4 macro calls. ----autoconf [website](https://www.gnu.org/software/autoconf/autoconf.html)

**How to install it**

```shell
$ sudo yum install autoconf
```

### MySQL server

**What is it?**

**How to install it**

We followed the instructions in this website: https://www.tecmint.com/install-latest-mysql-on-rhel-centos-and-fedora/.
This is a needed dependency for some research projects. In particular, this was installed
to be used with [SIFTER in the aphylo](https://github.com/USCbiostats/sifter-aphylo) module.

```shell
sudo yum localinstall mysql80-community-release-el7-1.noarch.rpm
sudo yum repolist enabled | grep "mysql.*-community.*"
sudo yum install mysql-community-server
sudo service mysqld start
```

After that step, we need to beef up the security, so we use `grep 'temporary password' /var/log/mysqld.log`
to find out what is the temporary password generated. Once we get it, you can then use command
`mysql_secure_installation` and follow the steps.

To change the default location for storage, we had to follow a mix of steps from
[this tutorial](https://www.digitalocean.com/community/tutorials/how-to-change-a-mysql-data-directory-to-a-new-location-on-centos-7),
to set up the config of the MySQL service, and
[this other tutorial](https://blogs.oracle.com/jsmyth/selinux-and-mysql) to deal with
SELinux which will probably cause I/O errors. In sum, the steps were:

1. Stop the mysqld service,
2. Edit the `/etc/my.cnf` file, by replacing the lines

```
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
```

with

```
datadir=/home/mysql
socket=/home/mysql/mysql.sock
```

And add the lines at the end

```
[client]
port=3306
socket=/home/mysql/mysql.sock
```

3. Once that's done, we can move the `datafile` to its new home with rsync, and backup
the data:

```
sudo rsync -av /var/lib/mysql /home/
sudo mv /var/lib/mysql /var/lib/mysql.bak
```

4. Once that's done, we need to make sure SELinux will allow the `mysql` user to do I/O:

```
sudo semanage fcontext -a -t mysqld_db_t "/home/mysql(/.*)?"
sudo restorecon -Rv /home/mysql
```

5. Finally, if you followed all the steps correctly, you can start the mysqld service

```
sudo systemclt start mysqld.service
```

Credits go to Dustin Ebert!

### Stata 15.1

**What is it?**


**How to install it**

We got one of the LICENSES that George Martinez has, from there:

```shell
$ sudo -s
$ cd /tmp/
$ mkdir statafiles
$ cd statafiles
$ tar -zxf /home/you/Downloads/Stata15Linux64.tar.gz
$ cd /usr/local
$ mkdir stata15
$ cd stata15
$ /tmp/statafiles/install
```
And follow the instructions afterwards. To make it system wide available:

```shell
$ cd ..
$ sudo chmod -R 755 stata15
```

### Windows shared folder

**What is it?**

Install `mount.cifs`

```
$ sudo yum install -y cifs-utils
```

To mount a drive

```
$ sudo mount.cifs //[SUBDOMAIN].usc.edu/[FOLDER?] /path/to/mount -o username=[USERNAME] uid=[GET IT WITH id] dir_mode=0770 file_mode=0770
```

In the case of `username`, our experience tells us that we don't need to use the subdomain.


### bash completion

**What is it**

**How to install it**

Following [these](https://www.cyberciti.biz/faq/fedora-redhat-scientific-linuxenable-bash-completion/) instructions:

```shell
$ sudo yum install bash-completion
```

### GNU Multiple Precision Arithmetic Library (GMP)

**What is it**

> GNU Multiple Precision Arithmetic Library is a free library for arbitrary-precision arithmetic, operating on signed integers, rational numbers, and floating point numbers. ([wiki](https://en.wikipedia.org/wiki/GNU_Multiple_Precision_Arithmetic_Library))

It is required by the R package [gmp](https://cran.r-project.org/package=gmp).

**How to install it**

```shell
$ sudo yum install gmp-devel
```

### Adding a CentOS server 7 to a domain

Before this configuration works, we need to have the DNS config file pointing to our USC's prevmed machine (a windows machine). To do so we have to have the folling settings in the `/etc/resolv.conf` file:

```
search usc.edu
nameserver 10.148.80.211
```

Changing this does not need a restart or anything (see [here](https://www.dnsknowledge.com/q-a/howto-edit-etcresolv-conf-file-in-centos/)).

1.  Run on CentOS server as root

2.  `yum install realmd sssd ntpdate ntp adcli` (installs the need packages)

3.  `systemctl enable ntpd.service` (enables ntp service - required to keep times synced)

4.  `ntpdate prevmed.usc.edu` (or name of domain to join - syncs time to domin server)

5.  `systemctl start ntpd.service` (starts the ntp service)

6.  `realm join -U odin prevmed.usc.edu` (or administrator account and domain if not prevmed.usc.edu)
    
    (should be prompted for password for domain admin account)
    
    No message means it worked.

Can run the follow command to verify the installation. `realm list`.

### SYRUPY (SYstem Resource Usage Profile ...um, Yeah)

**What is it**

> Syrupy is a Python script that regularly takes snapshots of the memory and CPU load of one or more running processes, so as to dynamically build up a profile of their usage of system resources. ([repo](https://github.com/jeetsukumaran/Syrupy))

**How to install it**

1.  Download the repository using git: `git clone https://github.com/jeetsukumaran/Syrupy`

2.  Run the installation file `sudo python setup.py install`

To execute it you just need to type, for example,

```shell
$ syrupy.py Rscript -e "matrix(NA, 1000, 1000)"
```

And it will get the memory snapshots of the command out to a log file that you can later analyze.

### Developer Toolset 7

**What it is**

> Developer Toolset is designed for developers working on CentOS or Red Hat Enterprise Linux platform. It provides current versions of the GNU Compiler Collection, GNU Debugger, and other development, debugging, and performance monitoring tools. -- [Website description](https://www.softwarecollections.org/en/scls/rhscl/devtoolset-7/)

We installed this principally so people can have access to a newer version of
the gcc compiler without having to install the new version system-wide.

**How to install it**

```bash
sudo yum install centos-release-scl
sudo yum install devtoolset-7-gcc*
scl enable devtoolset-7 bash
which gcc
gcc --version
```

For more on this see the original post in stackoverflow [here](https://stackoverflow.com/questions/36327805/how-to-install-gcc-5-3-with-yum-on-centos-7-2)

# Commands cheat sheet

## R CMD

You can send batch jobs to R via command line in two ways:

1.  Using the `R CMD BATCH`. Its syntax is

    ```sh
    $ R CMD BATCH -- myjob.R myjob.Rout &
    ```
    
    Where `myjob.Rout` is a plain text file which dumps the output from `myjob.R`.

2.  Using `Rscript`. Its syntax is

    ```sh
    $ Rscript myjob.R > myjob.Rout &
    ```

    Follows the same logic as the previous method, with the difference that not everything is printed
    
## User management

```sh
# Add user
adduser [username]

# Add group
addgroup [groupname]

# Add user to a group
sudo usermod -G[groupname] -a [username]
```

In the case of Prevmed accounts

1.  Add the user using `sudo realm permit <username@PREVMED.USC.EDU>`
2.  Ask the user to login using ssh
3.  Once that is complete, he should be able to access RStudio server.

If the process does not work, it is usually due to a change in the DNS
server address. To solve this, follow these instructions (directly extracted
from [this website](https://www.thegeekdiary.com/centos-rhel-dns-servers-in-etcresolv-conf-change-after-a-rebootnetwork-service-restart-how-to-make-them-permanent/)):

You would face this issue after a reboot or a network service restart. This usually happens as the scripts /etc/sysconfig/network-scripts/ifup-post and /etc/sysconfig/network-scripts/ifdown-post checks for the parameters “RESOLV_MODS=no” or “PEERDNS=no” in the network interface configuration file such as /etc/sysconfig/network-scripts/ifcfg-*. If these either of these parameters are not present, it will replace the contents of /etc/resolv.conf with /etc/resolv.conf.save. By default, PEERDNS and RESOLV_MODS are null.

1. The /etc/resolv.conf file will be overwritten if any network
   interfaces use DHCP for activation. To prevent this, ensure such
   interfaces have PEERDNS=no set in their ifcfg file, for example

   ```
   # cat /etc/sysconfig/network-scripts/ifcfg-eth0
   TYPE=Ethernet
   DEVICE=eth0
   BOOTPROTO=dhcp
   PEERDNS=no
   ```

2. The ifcfg-file directives DNS1 and DNS2 can also lead to modification
   of resolv.conf. To prevent this, either remove said directives or use
   chattr(1) to make resolv.conf immutable to changes, i.e.:
   
   ```
   # chattr +i /etc/resolv.conf
   ```


## File management

```sh
# Change owner ship
chown [user][:groupname]
```

sudo chown -R www-data:www-data /srv/www
sudo chmod -R g+w /srv/www

## Parallel 

Setup

1.  Use `ssh-keygen` to create private and public keys in the client,
    
    ```sh
    $ ssh-keygen -t rsa
    ```
    
2.  Use `ssh-copy-id` to send a copy of the public key to the server

    ```sh
    $ ssh-copy-id -p 2436 vegayon@vega2.usc.edu
    ```

    Will prompt you asking for password. After that you won't be needing it since
    from this machine you'll be able to connect simply using `ssh -p 2436 vegayon@vega2.usc.edu`

3.  In ufw add the following rules needed for R to create a con with localhost:

    ```sh
    Anywhere                   ALLOW       127.0.0.1
    2436                       ALLOW       128.125.0.0/16
    2436                       ALLOW       68.181.0.0/16
    ```
    
4.  From R run

    ```r
    > cl <- makePSOCKcluster(rep('vega2.usc.edu',4), user='vegayon', rshcmd='ssh -p2436')
    ```
    
    and voila!
    
5.  Further, we can make this shorter. Changing the file `/etc/ssh/ssh_config`,
    we can add the line `Port 2436` to make the default outgoing connection to
    2436. And then we can write:
    
    ```r
    > cl <- makePSOCKcluster(rep('vegayon@vega2.usc.edu',4))
    ```
    
    In the case that you use your desktop or other computer as a server, it is wise
    to pass the argument `master` to the function `makePSOCKcluster`. This because
    usually, while you may have your computer connected to the network working as a
    server, R uses the name of your computer as default for the `master`, hence,
    instead of passing the argument `MASTER=vegayon.usc.edu` (for example), it passes
    `MASTER=george-computer` (which is the name of my computer). A more concrete
    example:
    
    
    ```r
    > cl <- makePSOCKcluster(rep('george@vegayon.usc.edu',4), master="vegayon.usc.edu")
    ```
    
    That works, while the following may not
    
    
    ```r
    > cl <- makePSOCKcluster(rep('george@vegayon.usc.edu',4))
    ```

# Website

The index webpage is located as /var/www/html/index.html

# SSL Certificate

1.  Request a certificate to itservices.usc.edu by providing them with the corresponding request: `openssl req -nodes -newkey rsa:2048 -keyout bioghost.key -out bioghost.csr`

2.  Once approved, download your certificate and the intermediate certificate, e.g. bioghost_usc_edu_cert.cer and `bioghost_usc_edu_iterm.cer` and, together with the key generated in step 1, copy them to the following paths:
    
    ```
    cp bioghost_usc_edu_cert.cer /etc/pki/tls/certs
    cp bioghost.key /etc/pki/tls/private
    cp bioghost_usc_edu_interm.csr /etc/pki/tls/private
    ```
    
3.  Update the apache conf file located at `/etc/httpd/conf.d/ssl.conf` with the following information:
    
    
    | Directives | Path to Enter |
    |------------|---------------|
    SSLCertificateFile | Certificate file path |
    SSLCertificateKeyFile | Key file path |
    SSLCertificateChainFile | Intermediate bundle path |
    
4.  Update the virtual hosts at `/etc/httpd/conf/httpd.conf` by setting:

    ```
    <VirtualHost *:80>
            ServerName bioghost.usc.edu
            # ServerAlias 
            Redirect "/" "https://bioghost.usc.edu"
            # DocumentRoot "/var/www/html/workshop" 
    </VirtualHost>
    
    ```
    
    And the file `/etc/httpd/conf/ssl.conf` by setting
    
    ```
    DocumentRoot "/var/www/html/workshop"
    ServerName bioghost.usc.edu:443
    ```

5.  Add the https protocol to firewall-cmd `sudo firewall-cmd --add-service=https --permanent`
    
6.  Restart the apache server by typing `sudo apachectl restart`.


More info at:

*  https://www.ssl2buy.com/wiki/install-ssl-certificate-on-apache-centos
*  https://www.centos.org/docs/5/html/Deployment_Guide-en-US/s1-apache-startstop.html
*  https://wiki.centos.org/HowTos/Https

# Transferring Files among Users

A shared folder is created to allow users to transfer files on the bioghost, i.e., without downloading these files to one's local computer and uploading later. The folder is only for transferring purpose so please do not leave any files unattended or use the `/home/shared` folder as storage. 

1. Go to the Terminal under your account on the bioghost (next to the Console in Rstudio). 

2. Copy the file to the shared folder. 

    ```sh
    $ cp /your_folder_name/filename.R /home/shared
    ```

3. Ask the other user to move that file to his/her own directory. 

    ```sh
    $ mv /home/shared/filename.R /destination_folder/
    ```

# System-wide configuration

In order to be able to automatically link to some installed libraries, we have added
the following file to the list of `LD_LIBRARY_PATH`

```
$ cat /etc/ld.so.conf.d/user.local.lib.conf
/usr/local/lib/
```

Right now there are a couple of libraries that can be linked, in particular,
`libhts` and singularity. To update the path, we just need to run `ldconfig`
as sudo.

Source: [StackOverflow](https://stackoverflow.com/a/13428971/2097171)

# Cheat Sheet

| Example | Problem | Details |
|---------|-------------|------|
`cat /etc/centos-release` | Checkout the version of the OS |
`sudo yum clean all` | Cleans cached repos | Neat when trying to install something fails |
`sudo firewall-cmd --zone=public --add-port=3624/tcp --permanent` | Open port 3624 in zone "public" |
`firewall-cmd --get-active-zones` | List active zones in the firewall (more [here](https://www.linode.com/docs/security/firewalls/introduction-to-firewalld-on-centos/))
`sudo cat /var/log/messages` | Show system log


