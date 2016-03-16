check.counterbalance <- function(snd.files, part.id){
  fn <- lapply(snd.files, basename)
  spkr.id <- unlist(lapply(fn, function(fn){substr(fn,1,3)}))
  prosody <- unlist(lapply(fn, function(fn){substr(fn,5,7)}))
  script <- unlist(lapply(fn, function(fn){substr(fn,9,11)}))
  version <- unlist(lapply(fn, function(fn){substr(fn,13,13)}))
  
  snds.df <- data.frame( spkr.id = spkr.id,
                         prosody = prosody,
                         script = script,
                         version = version)
  
  snds.df$snd_playing <- snd.files
  snds.df$part.id <- part.id
  spkr.fam <- with(snds.df, (part.id == spkr.id))
  snds.df$spkr.fam <- factor(spkr.fam, labels=c("nov", "fam"))
  print(xtabs(formula = ~ prosody + script + spkr.fam))
  nov.id <- unique(snds.df$spkr.id[snds.df$spkr.id == part.id]) 
  return(nov.id)
}
