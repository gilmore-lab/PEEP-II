print.peep.stats <- function(log.fn='mri-901-2016-03-09-1031-run-2-order-1.csv', n.vols.expected = 269){
  
  require(dplyr)
  source('check.counterbalance.R')
  source('import.peep.log.R')
  source('extract.peep.conditions.R')
  source('compare.vols.seq.R')

  peep <- import.peep.log(log.fn)
  
  log.fn <- basename(log.fn)
  part.id <- substr(x = log.fn, start = 5, 7)
  run <- substr(x = log.fn, start = 29, 29)
  order <- substr(x = log.fn, start = 37, 37)
  
  cat(sprintf('This is participant %s, run %s, order %s', part.id, run, order), '\n\n')
  flush.console()
  
  cat(sprintf('Run duration %i:%5.3f', max(peep$secs_from_start)%/%60, max(peep$secs_from_start)%%60), '\n\n')
  
  mri.vols <- peep %>%
    filter(event_type == "new_mri_vol")

  compare.vols.seq(unique(peep$mri_vol), n.vols.expected)
  
  sil.periods <- mri.vols %>%
    filter(snd_playing == "silence")
  cat(sprintf('There were %i volumes with silence', dim(sil.periods)[1]),'\n')
  flush.console()

  snd.periods <- mri.vols %>%
    filter(snd_playing != "silence")
  cat(sprintf('There were %i volumes with sound', dim(snd.periods)[1]),'\n')
  flush.console()
  
  snd.vols <- peep %>%
    filter(event_type == "sound_on")
  cat(sprintf('%i sounds were played', dim(snd.vols)[1]),'\n\n')
  flush.console()
  snd.files <- levels(snd.vols$snd_playing)
  
  # Take all but first, "silence"
  snd.files <- snd.files[2:length(snd.files)]
  
  cat('Checking counterbalance...', '\n\n')
  check.counterbalance(snd.files, part.id)
  cat('\n')
  
  ring.on <- peep %>%
    filter(event_type == "ring_on")
  cat(sprintf('%i visual targets were displayed', dim(ring.on)[1]),'\n')
  flush.console()
  
  keypress <- peep %>%
    filter(event_type == "keypress")
  cat(sprintf('%i keypresses were detected', dim(keypress)[1]),'\n')
  flush.console()
}