## The problem

* We are unlikely of "signing" into a coding standard agreement in the form of
  telling us how to write for-loops.

* Different coding styles, different learning-to-code languages, doesn't make
  it easier.

* Also, important to notice, not all of us use github/alike tools, and right
  now there is no (that) big of an incentive to do the opposite.

* On the other side, there are indeed some practices that can be applied widely
  regardless of the programming language:

    - Commenting your code
    - The 80 column rule
    - Commenting your code (again)
    - Does the project has a README file (including funding information?)

  In the case of R packages, this is simpler:

    - Just follow whatever CRAN wants
    - Are we listing the grant as part of the authors (fndr)
    - Are we doing devtools/usethis?

  If the repo is about a research paper, we can add a few things:

    - Are there any README files around? We need to document/describe
      what each script does, and if there's data, where did we got it 
      from, e.g.: https://github.com/USCCANA/fctc

## What can we do about it

* We could, in principle, suggest users to apply these rules to their coding
  practices... but it is unlikely that everybody will abide.

* Instead, we could try to get into their code, look at these issues, and
  make proposals about this: "look how nicier your code looks like!"

* Assuming people will be OK with someone else looking at your code, still
  there are too many projects/code to look at, so, unless we have one of
  us doing this all day every day, this won't work. A solution: A BOT.

* We can have a boot looking at github/folders in bioghost/folders in hpc
  checking these issues.

* Oh, big first question: How much of our code is on github/alike?

* Looking at code that has git, we can actually ask this bot to make forks/new
  branches of the repos, look at the very basic checks, make changes in the code,
  and submit pull requests in our behalf.

## Final obs

* Important thing to notice: Keep goals realistic (i.e. we are not a software
  development company, we are a science-making venture), so it is easier to
  reach the goals, and people doesn't get frustated with this!
