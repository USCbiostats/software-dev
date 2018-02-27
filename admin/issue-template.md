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
- [ ] The package has been uploaded to CRAN or BioC.


## Shiny Apps Development

- [ ] TBD

## Infrastructure for Reproducible Research

- [ ] Create a git repository for the paper.
- [ ] Organize your files in a neat way
- [ ] Put all the files required to reproduce the results, or at least placeholders (hopefully `readme.md` files for each folder). You can find an example of a readme file [here]()
- [ ] List all the software requirements including names and versions in the readme.md file.
- [ ] Set up the project using Docker.


## HPC assessment and consultation

- [ ] Is my code neat (vectorized)?
- [ ] Think about what parts are parelelizable or not.
- [ ] Look for out-of-the-box tools on CRAN and BioC.

