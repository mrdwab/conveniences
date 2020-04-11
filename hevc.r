#!/usr/local/bin/r

suppressMessages(library(docopt))
suppressMessages(library(glue))

doc <- "Usage: hevc.r [EXT] [-h] [--abr ABR] [--crf CRF] [--backend BACKEND] [--skip-check SKIP]
-a --abr ABR          per-channel audio bitrate [default: 32]
-c --crf CRF          video crf for SD, 720, and 1080+ videos [default: 23/28/33]
-b --backend BACKEND  backend to be used (ffmpeg/handbrake) [default: ffmpeg]
-s --skip-check SKIP  should dimension check be skipped [default: no]
-h --help             show this help text"

opt <- docopt(doc)

files <- list.files(pattern = sprintf("*.%s", opt$EXT), include.dirs = FALSE)

if (opt$`skip-check` == "no") {
  stub <- "~/Apps/ffmpeg/ffprobe -loglevel error -select_streams v:0 -show_entries stream=height -of default=nw=1:nk=1"
  video_size <- function(input) {
    if (input < 500) {
      "SD"
    } else if (input > 999) {
      "HD"
    } else {
      "Standard"
    }
  }
} 

VCRF <- setNames(as.numeric(strsplit(opt$crf, "/", TRUE)[[1]]), c("SD", "Standard", "HD"))

for (i in seq_along(files)) {
  type <- if (opt$`skip-check` != "no") "Standard" else video_size(as.numeric(system(sprintf("%s '%s'", stub, files[i]), intern = TRUE)))
  
  if (opt$backend == "ffmpeg") {
    cmd <- glue('~/Apps/ffmpeg/ffmpeg -i "', files[i],
                '" -map 0 -c copy -c:v libx265 -x265-params crf=', unname(VCRF[type]),
                ' -c:a libopus -b:a ', as.numeric(opt$abr)*2,
                'k -ac 2 -max_muxing_queue_size 99999 "', gsub(paste0(".", opt$EXT), paste0("_micro.", "mkv"), files[i]), '"')
  } else {
    cmd <- glue('HandBrakeCLI -i "', files[i],
                '" -o "', gsub(paste0(".", opt$EXT), paste0("_micro.", "mkv"), files[i]),
                '" -e x265 -q ', sprintf("%d.0", unname(VCRF[type])),
                ' --all-audio -E "opus" -B ', as.numeric(opt$abr)*2,
                ' --mixdown "stereo"')
  }
  print(cmd)
  cat("\n\n")
  system(cmd)
}
