Workshop: Hands-on on Writing R packages
================
Date and Location: June 19 and 20 on SSB 116
This version: 2017-06-19 01:21:41

-   [Goal](#goal)
-   [Who is this for](#who-is-this-for)
-   [When and where](#when-and-where)
-   [Program](#program)
    -   [Day 1](#day-1)
    -   [Day 2](#day-2)
-   [Requirements](#requirements)
    -   [R Package Project](#r-package-project)
    -   [System requirements](#system-requirements)
    -   [Optional Requirements](#optional-requirements)

Goal
====

This day and a half workshop has the goal of writing fully functional R packages. All the attendees will be required to build an R package of their own, and will be assisted throughout the development process.

At the end of the event, all the packages will be put together in a website to be featured at a USC website.

Who is this for
===============

In this first round, the event will be open only to Members of the Department of Preventive Medicine. While having an ongoing R package project is not a requirement, the workshop will be driven by the participants' projects.

When and where
==============

The workshop is designed to last one day and a half. The first day dedicated to write the R package, and the reminder to Package Vignettes and time to finish the development process if needed. The workshop will take place in **SSB 116** on **June 19 from 9:30 to 16:00**, and **June 20 from 9:30 to 12:00**.

Program
=======

The workshop will be carried out using **short presentations** introducing a topic, and presenting **two or, if time permits, more examples** using attendees' projects, during which all the projects will be assisted (one-by-one). Lunch will be provided for both days.

Day 1
-----

-   **(60 minutes 09:30 to 10:30)** **Verifying requirements**

    For those who weren't able to install all the requirements prior to the workshop, we will dedicate an hour to assist them in the process.

|                        |
|:----------------------:|
| **Break (15 minutes)** |

-   **(30 minutes 10:30 to 11:00)** **Introduction and General Overview**

    Presentation of the program and description of the work-flow of the workshop.

-   **(60 minutes 11:00 to 12:00)** **Lightning talks: Presentation of the Projects**

    Each attendee should present its project in the following terms: Description of the package and its tentative name, and development status (what has been done so far).

|                        |
|:----------------------:|
| **Break (15 minutes)** |

-   **(30 minutes 12:00 to 12:30)** **Setting Up the Rstudio+git project**

    We will create the necesary structure of the package using RStudio, and create a new project in github. Including setting up the accounts in travis-ci, Appveyor, and Codecov.

-   **(60 minutes 12:30 to 13:30)** **Documenting an R package with roxygen2: functions**

    Describe the function, its parameters, provide examples, add it to the namespace, and more references.

|                        |
|:----------------------:|
| **Break (15 minutes)** |

-   **(30 minutes 13:30 to 14:00)** **Documenting an R package with roxygen2: Dependencies, data and the package itself**

    Besides of the `@importFrom` and friends roxygen-tag, we will dedicate time to checkout how are we including external code in our R packages.

-   **(60 minutes 14:00 to 15:00)** **Writing tests with testthat**

    Adding tests that will be included in the `tests/` folder and will be ran throughout the development process.

|                        |
|:----------------------:|
| **Break (15 minutes)** |

-   **(60 minutes 15:00 to 16:00)** **Ready to publish: R CMD check**

    Run R CMD check, fix issues, commit changes and push new commit to github.

Day 2
-----

-   **(60 minutes 09:30 to 10:30)** **Beyond examples: Writing Vignettes**

    Package vignettes are usually made to provide extended examples, tutorials and theoretical references for the package.

-   **(90 minutes 10:30 to 12:00)** **Wrap-up**

    To solve any issue

Requirements
============

R Package Project
-----------------

Each participant should bring the following:

-   A short presentation (less than 5 minutes) describing the project that will be working on.

-   A set of R functions (can be a single function) to bind into an R package. The functions' parameters must have a description.

-   At least 1 example dataset (will be used for both testing and examples)

Otherwise, participants can use the files `numint.r` and `examples.r` which are intended to be wrapped as an R package for Montecarlo Integration.

System requirements
-------------------

-   Latest version of R (3.4.0) <https://cloud.r-project.org/>

-   Latest version of RStudio (1.0.143) <https://www.rstudio.com>

-   Latest version of Git-SCM (2.13.0) <https://git-scm.com/>

-   We will work with the following R packages:

    -   devtools,
    -   roxygen2,
    -   rmarkdown,
    -   testthat, and
    -   covr

    To install the missing packages, you can use the following lines

    ``` r
    toinstall <- c("devtools", "roxygen2", "rmarkdown", "testthat", "covr") 
    toinstall <- toinstall[!(toinstall %in% rownames(installed.packages()))]
    install.packages(toinstall)
    ```

Optional Requirements
---------------------

Also, we will be using the following online services:

-   A github account <http://github.com>,

-   A travis-ci account <http://travis-ci.org>,

-   An AppVeyor account <https://www.appveyor.com/>, and

-   A codecov account <https://codecov.io/>
