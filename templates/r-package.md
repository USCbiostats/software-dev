# New Core C/D Assessment Project Template

This document provides a general framework for assessing the software and computing needs of a particular project.

The first step consists on answering the following questions:

- [ ] In a paragraph, describe what is the project about.
- [ ] List the project's specific goals (e.g. make the method available for public use, create a webservice, present this analysis)
- [ ] Think about what are your computing/software needs, and list them.

Once a general overview of the project has been defined, the next step consists on analyzing the following:

## R packages development

Fundamental questions/tasks

- [ ] Check for other R packages/software that does what the project tries to do.
- [ ] Describe the ultimate goal of your R package (e.g. solve an optim problem, implement a visualization problem, estimate parameters, etc.)
- [ ] Think about data (if any needed), in particular, input/output, have you checked any R packages that already have this?
- [ ] Create a repository for the package.

Once the project is on git, following checkmarks

- [ ] The package uses [roxygen2](https://cran.r-project.org/package=roxygen2) (you can turn your package Rd files to roxygen using [Rd2roxygen](https://cran.r-project.org/package=Rd2roxygen)).
- [ ] The package's functions are throughly documented. This includes: Description, parameters (`@param`), value (`@return`), details (if any), examples (`@details`), references (`@references`) and links to other functions (`@seealso`, and `@family`).
- [ ] The package has been fully tested using [testthat](https://cran.r-project.org/package=testthat) or other framework.
- [ ] The project is built using Continuous Integration services as [Travis-ci](https://travis-ci.org) and [Appveyor](https://ci.appveyor.com/) (use the [usethis](http://usethis.r-lib.org/) package to set it up, eg: `usethis::use_travis`).
- [ ] The package includes a vignette with an extended example and, if needed, references on the package.
- [ ] The package has a website (suggest using [pkgdown](https://pkgdown.r-lib.org))

## Sending package to CRAN

Prepare for release:

* [ ] `devtools::check_win_devel()`
* [ ] `rhub::check_for_cran()`
* [ ] `revdepcheck::revdep_check(num_workers = 4)`
* [ ] [Polish NEWS](http://style.tidyverse.org/news.html#before-release)
* [ ] If new failures, update `email.yml` then `revdepcheck::revdep_email_maintainers()`

Perform release:

* [ ] Bump version (in DESCRIPTION and NEWS)
* [ ] `devtools::check_win_devel()` (again!)
* [ ] `devtools::submit_cran()`
* [ ] `pkgdown::build_site()`
* [ ] Approve email

Wait for CRAN...

* [ ] Tag release
* [ ] Bump dev version

## Sending package to Bioconductor

Prepare for release:

* [ ] Pass `R CMD check` and `R CMD Biocheck`
* [ ] Go visit this guidance [site](https://github.com/Bioconductor/Contributions)
* [ ] Add SSH public key(s) to your GitHub account
* [ ] Add a webhook to your repository
* [ ] Submit by opening a new issue in the Bioconductor [Contributions](https://github.com/Bioconductor/Contributions/issues/new) repository.

Perform release:

* [ ] Bump version (in DESCRIPTION and NEWS) which triggers the submission
* [ ] Receive emails about successfully building your package without errors or warnings. 
* [ ] A technical review provided by a Bioconductor team member 
* [ ] Approve email
