context("Basic set of tests")
test_that("foo(a, b) = a+b", {
  # Preparing the test
  a <- 1
  b <- -2
  
  # Calling the function
  ans0 <- a+b
  ans1 <- addnums(a, b)
  
  # Are these equal?
  expect_equal(ans0, ans1$ab)
})

test_that("Plot returns -funnypkg_addnums-", {
  expect_s3_class(plot(addnums(1,2)), "funnypkg_addnums")
})