update.README <- function(boilerplate_txt) {
  cat(boilerplate_txt, "README.md")
  
  cat(sessionInfo(), "README.md")
}