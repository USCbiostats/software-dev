main_function <- function(n_max, n_black, balls, n) {
  check_input(n_max, n_black, balls, n)
  x_prep <- prep_data(n_black, balls) 
  
  res <- numeric(n)
  for(i in seq_len(n)) {
    data <- simulate_data(x_prep, n_max)
    res[i] <- analyse_results(data)
  }
  res
}

check_input <- function(n_max, n_black, balls, n) {
  if(!is.numeric(n_max)) 
    stop("`n_max` must be numeric.")
  if(!is.numeric(n_black)) 
    stop("`n_black` must be numeric.")
  if(!is.numeric(balls)) 
    stop("`balls` must be a numeric.")
  if(!is.numeric(n)) 
    stop("`n` must be a numeric.")
  
  if(length(n_max) != 1) 
    stop("`n_max` must have length 1.")
  if(!is.numeric(n_black)) 
    stop("`n_black` must have length 1.")
  if(!is.numeric(n)) 
    stop("`n` must have length 1.")
}

prep_data <- function(n_black, balls) {
  c(rep(0, n_black), ball_create(balls))
}

ball_create <- function(balls) {
  ball_id <- seq_len(balls)
  res <- numeric()
  for(i in ball_id) {
    res <- c(res, rep(ball_id[i], balls[i]))
  }
  res
}

simulate_data <- function(urn, n_max) {
  for (j in length(urn):n_max) {
    draw <- sample(urn, 1)
    if(draw == 0) {
      urn <- c(urn, max(urn) + 1)
    } else {
      urn <- c(urn, draw)
    }  
  }
  urn
}

analyse_results <- function(x) {
  sum(x == 1)
}

main_function(n_max = 50, n_black = 1, balls = c(1, 1), n = 100)