write.order.csv <- function(df, this_order, this_run, csv_dir='csv') {
  require(dplyr)
  fn <- paste(csv_dir, paste('o', this_order, 'r', this_run, '.csv', sep=''), sep='/')
  this_order <- df %>% filter(Order = this_order, Run = this_run)
  write.csv(this_order, fn, row.names=FALSE)
}