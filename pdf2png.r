#!/usr/local/bin/r

suppressMessages(library(docopt))
suppressMessages(library(glue))

doc <- "Usage: pdf2png.r [EXT] [-h]
-h --help             show this help text"

opt <- docopt(doc)

files <- list.files(pattern = sprintf("%s", opt$EXT), include.dirs = FALSE)

for (i in seq_along(files)) {
  cmd <- glue('pdftoppm "', files[i], '" "', gsub(".pdf", "", files[i]), '" -png')
  print(cmd)
  system(cmd)
}
