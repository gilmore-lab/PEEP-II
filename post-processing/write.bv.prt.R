write.bv.prt <- function(df, out.dir="prt/", log.fn){
  # Writes BrainVoyager file from PEEP II log file
  
  # Output file name
  log.fn <- basename(log.fn)
  log.fn <- paste(substr(log.fn, 1, nchar(log.fn)-4), ".prt", sep="")
  out.fn <- paste(out.dir, log.fn, sep="")
  
  # Extract order, run, make Experiment:
  run <- substr(x = log.fn, start = 29, 29)
  order <- substr(x = log.fn, start = 37, 37)
  expt.name <- paste("PEEP2_Order", order, "Run", run, sep="")
    
  # Write header
  sink(out.fn)
  
  writeLines("\nFileVersion:        2\n")
  writeLines("ResolutionOfTime:   Volumes\n")
  writeLines(paste("Experiment:         ", expt.name, "\n", sep=""))
  writeLines("BackgroundColor:    0 0 0")
  writeLines("TextColor:          255 255 255")
  writeLines("TimeCourseColor:    255 255 255")
  writeLines("TimeCourseThick:    2")
  writeLines("ReferenceFuncColor: 0 0 80")
  writeLines("ReferenceFuncThick: 2\n")
  writeLines("NrOfConditions:     8")			
  
  # For each condition, write...
  # <ConditionLabel>
  # <N repetitions>
  #   <start_vol> <end_vol>
  #   <start_vol> <end_vol>
  #   ...         ...
  
  # Save output file
  sink()
  cat(sprintf('Saved %s', out.fn), '\n')
  flush.console()
}
