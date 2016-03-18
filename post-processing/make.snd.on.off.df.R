make.snd.on.off.df <- function(df, part.id){
  # Creates new data frame with volume onsets and offsets for each 
  # sound condition; creates factors for sound conditions.
  # From this data frame, I can create BrainVoyager files.
  
  require(dplyr)
  
  snd.on <- df %>% filter(event_type == "sound_on")
  snd.off <- df %>% filter(event_type == "sound_off")
  vols.on <- snd.on$mri_vol
  # Extra sound_off at start of trial, trim it
  vols.off <- snd.off$mri_vol[2:dim(snd.off)[1]]
  secs.on <- snd.on$secs_from_start
  secs.off <- snd.off$secs_from_start[2:dim(snd.off)[1]]
  
  df.start <- df %>% 
    group_by(snd_playing) %>% 
    filter(snd_playing != "silence") %>%
    summarize(start.vol = min(mri_vol), start.secs = min(secs_from_start)) %>% 
    arrange(start.vol)
  
  df.snds <- df %>% 
    filter(event_type=="sound_on") %>% 
    group_by(snd_playing)
  snd_playing <- df.snds$snd_playing
  
  # Extract condition factor levels from sound file names
  snd.files <- as.character(snd_playing)
  fn <- unlist(lapply(snd.files, basename))
  
  spkr.id <- unlist(lapply(fn, function(fn){substr(fn,1,3)}))
  prosody <- unlist(lapply(fn, function(fn){substr(fn,5,7)}))
  script <- unlist(lapply(fn, function(fn){substr(fn,9,11)}))
  version <- unlist(lapply(fn, function(fn){substr(fn,13,13)}))
  
  # Make base dataframe
  snds.df <- data.frame(spkr.id = spkr.id,
                        prosody = prosody,
                        script = script,
                        version = version,
                        vol.on = vols.on,
                        vol.off = vols.off,
                        secs.on = secs.on,
                        secs.off = secs.off,
                        snd_playing = snd.files,
                        pid = rep(part.id, length(spkr.id)))
  
  # Add familiar/novel speaker factor
  spkr.fam <- with(snds.df, (part.id == spkr.id))
  snds.df$spkr.fam <- factor(spkr.fam, labels=c("nov", "fam"))
  
  return(snds.df)
}