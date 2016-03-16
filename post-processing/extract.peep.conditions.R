extract.peep.conditions <- function(snd.fn){
  # Extract file name from path
  snd.fn <- basename(snd.fn)
  spkr.id <- substr(snd.fn,1,3)
  prosody <- substr(snd.fn,5,7)
  script <- substr(snd.fn,9,11)
  version <- substr(snd.fn,13,13)
  c(spkr.id, prosody, script, version)
}