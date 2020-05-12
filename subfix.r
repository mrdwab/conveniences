#!/usr/local/bin/r

suppressMessages(library(docopt))
suppressMessages(library(glue))
options(useFancyQuotes = FALSE)

doc <- "Usage: subfix.r [FILE] [-h]
-h --help             show this help text"

opt <- docopt(doc)

# Step 1: Fix the SRT
srt <- as.character(opt$FILE)

file.copy(srt, glue(srt, ".bak"), overwrite = TRUE)
new.file <- glue(substr(srt, 1, nchar(srt)-4), "_fixed.srt")
cmd <- glue("~/Apps/ffmpeg/ffmpeg -fix_sub_duration -i {input} {output}", 
            input = srt, output = new.file)

system(cmd)

# Step 2: Fix the times

x <- readLines(new.file)

## Which lines need to be fixed
### Start time fix
inds <- grep("^[0-9]+$", x)+1
y <- x[inds]

### End time fix
z <- which(substr(y, 10, 12) == "999")
substring(y, 10, 12) <- sprintf("%03d", as.numeric(substr(y, 10, 12))+1)

if (length(z) > 0) {
  substr(y[z-1], 27, 29) <- "998"
  substr(y[z], 10, 12) <- "999"
}

x[inds] <- y

writeLines(x, new.file)
