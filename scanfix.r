#!/usr/local/bin/r

suppressMessages(library(docopt))
suppressMessages(library(glue))
options(useFancyQuotes = FALSE)

doc <- "Usage: scanfix.r [EXT] [-h] [--pgs PGS]
-p --pgs PGS          pages per sheet in output [default: 1]
-h --help             show this help text"

opt <- docopt(doc)

files <- list.files(pattern = sprintf("%s", opt$EXT), include.dirs = FALSE)
individual_files <- split(files, sub(glue("-[0-9]+.*\\.", opt$EXT, "$"), "", files))

for (i in seq_along(individual_files)) {
  NAM <- names(individual_files)[i]
  cmd1 <- glue('tiffcp ', paste(sQuote(individual_files[[i]]), collapse = " "), ' ', sQuote(sprintf("%s_combined.tiff", NAM)))
  print(cmd1)
  system(cmd1)
  cmd2 <- glue('tiff2pdf ', sQuote(sprintf("%s_combined.tiff", NAM)), ' > ', sQuote(sprintf("%s.pdf", NAM)))
  print(cmd2)
  system(cmd2)
  if (opt$pgs > 1) {
    cmd3 <- glue('pdfnup --nup ', opt$pgs, 'x1 --landscape --paper letter --frame false ', sQuote(sprintf("%s.pdf", NAM)))
    print(cmd3)
    system(cmd3)
  }
}
