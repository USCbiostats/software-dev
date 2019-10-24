# Model parameters
nsims <- 1e3
n     <- 1e4

# Function to simulate pi
simpi <- function(i) {
  
  p <- matrix(runif(n*2, -1, 1), ncol = 2)
  mean(sqrt(rowSums(p^2)) <= 1) * 4
  
}

# Approximation
set.seed(12322)
ans <- sapply(1:nsims, simpi)

saveRDS(ans, "01-sapply.rds")

