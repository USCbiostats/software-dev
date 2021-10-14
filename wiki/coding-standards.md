# Coding Standards

## General Overview

1. The [80 characters rule](https://www.emacswiki.org/emacs/EightyColumnRule#:~:text=WhitespaceMode-,About%20the%20Eighty%20Column%20Rule,including%20the%20Linux%20kernel%20standard.).
2. When possible, structure your code as sections/files, with files holding similar functions
   and sections to give internal structure to your file.
3. Use white space for indenting, 4 characters.
4. Explain yourself: Add comments.

## Control-flow statements

1.  Single line `if`

    ```r
    # If it's only a single like
    if (...)
        ...then...
    ```

2.  Multiple lines `ifelse`

    ```r
    # Several blocks
    if (...) {
        ...then...
    } else {
        ...
    }
    ```

## Variable/Objects names

1. Never use dots to name objects, e.g. `my.object`. Both R and C++ use the dot symbol to access (or call) methods. Instead use either underscore or capital letters, e.g. `my_object` or `myObject`.
2. Whenever possible, use informative names, e.g. `loglike` instead of `var1`

# <a name="software-thinking"></a> Software Thinking

# <a name="development-workflow"></a> Development Workflow

## General Overview

Unfolding the "Software Thinking", once you have set up the project (whereas an R package, C/C++ library, etc.), the development workflow is an iterative process. For each `fun` in `functions` do the following:

1.  Write down the function.
2.  Document the function: Input/output, examples, and references.
3.  Write down the tests.
4.  Build (compile) the package.
5.  Run the tests and make sure `fun` didn't break anything.
6.  Update the `news.md` and `ChangeLog` files (that sounds like a good idea).

# <a name="misc"></a>Misc

## R-packages

For R package development

*   [`devtools`](https://github.com/hadley/devtools#devtools): An R package for package developers.
*   [`roxygen`](https://github.com/klutometis/roxygen#roxygen2): For documenting functions.
*   [`testthat`](https://github.com/hadley/testthat#testthat): For making testing fun.
*   [`codecov`](https://github.com/jimhester/covr#covr): To track the code coverage.

For reproducible research

*   [`ProjectTemplate`](http://projecttemplate.net/) A complete workflow for reproducible research.
*   [`represtools`](https://CRAN.R-project.org/package=represtools) An alternative to ProjectTemplate.
*   [`CodeDepends`](https://CRAN.R-project.org/package=CodeDepends) Analyzes your code to see dependencies.
*   [`reproducible`](https://github.com/PredictiveEcology/reproducible) An alternative to ProjectTemplate.

## More references

* [R packages](https://r-pkgs.org/)
* [Advanced R](https://adv-r.hadley.nz/)
* [R Graphics Cookbook](https://r-graphics.org/)
* [The Art of R Programming](https://www.amazon.com/Art-Programming-Statistical-Software-Design/dp/1593273843)
