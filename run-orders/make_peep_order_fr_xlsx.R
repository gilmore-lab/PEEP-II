make_peep_order_fr_xlsx <- function(fn, sheetIndex, order, run) {
  require(xlsx)
  m <- read.xlsx(fn, sheetIndex=sheetIndex, header = FALSE)
  df <- data.frame(t(m)[2:dim(m)[2],], row.names = NULL)
  names(df) <- c("Speaker", "Emotion", "Script")
  df$Order <- order
  df$Run <- run
  df$Stim_index <- 1:dim(df)[1]
  df
}