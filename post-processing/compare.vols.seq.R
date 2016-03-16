compare.vols.seq <- function(vols, n.expected=269){
  cat(sprintf('%i volumes detected; %i expected', length(vols), n.expected), '\n')
  flush.console()
  if (length(vols) != n.expected){
    vols.seq <- 1:length(vols)
    cat(sprintf('First skipped volume: %i', min(vols.seq[(vols-vols.seq) != 0])), '\n')
    flush.console()
  } else {
    vols.seq <- 1:n.expected
    skipped <- ((vols-vols.seq) != 0)
    if (sum(skipped)){
      cat(sprintf('First skipped volume: %i', min(vols.seq[(vols-vols.seq) != 0])), '\n')
      flush.console()
    } else {
      cat(sprintf('No skipped volumes'), '\n')
      flush.console()
    }
  }
}