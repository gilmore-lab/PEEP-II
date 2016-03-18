import.peep.log <- function(log.fn){
  part.id <- substr(x = log.fn, start = 5, 7)
  run <- substr(x = log.fn, start = 29, 29)
  order <- substr(x = log.fn, start = 37, 37)
  
  peep <- read.csv(log.fn)
  
  peep$part.id <- part.id
  peep$run <- run
  peep$order <- order
  peep
}
  