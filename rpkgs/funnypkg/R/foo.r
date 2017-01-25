#' The title of -foo-
#'
#' @param a Numeric scalar. A brief description.
#' @param b Numeric scalar. A brief description.
#' 
#' @details Computes the sum of \code{x} and \code{y}.
#' @return A list of class \code{funnypkg_foo}:
#' \item{a}{Numeric scalar.}
#' \item{b}{Numeric scalar.}
#' \item{ab}{Numeric scalar. the sum of \code{a} and \code{b}}
#' @examples
#' foo(1, 2)
#' 
#' @export
foo <- function(a, b) {
  ans <- a + b
  structure(list(a = a, b = b, ab = ans)
            , class = "funnypkg_foo")
}

#' @rdname foo
#' @export
#' @param x An object of class \code{funnypkg_foo}.
#' @param y Ignored.
#' @param ... Further arguments passed to
#' \code{\link[graphics:plot.window]{plot.window}}.
plot.funnypkg_foo <- function(x, y = NULL, ...) {
  graphics::plot.new()
  graphics::plot.window(xlim = range(unlist(c(0,x))), ylim = c(-.5,1))
  graphics::axis(1)
  with(x, graphics::segments(0, 1, ab, col = "blue", lwd=3))
  with(x, graphics::segments(0, 0, a, col = "green", lwd=3))
  with(x, graphics::segments(a, .5, a + b, col = "red", lwd=3))
  graphics::legend("bottom", col = c("blue", "green", "red"), 
                   legend = c("a+b", "a", "b"), bty = "n", 
                   ncol = 3, lty = 1, lwd=3)
  
  invisible(x)
}
