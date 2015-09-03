write.order.csv <- function(order, csv_dir='csv'){
  fn <- paste(csv_dir, paste(order, '.csv', sep=''), sep='/')
  write.csv(order, fn)
}