import.peep.log <- function(log.fn){
  part.id <- substr(x = log.fn, start = 17, 19)
  run <- substr(x = log.fn, start = 41, 41)
  order <- substr(x = log.fn, start = 49, 49)
  
  peep <- read.csv(log.fn)
  
  peep$part.id <- part.id
  peep$run <- run
  peep$order <- order
  peep
}
  