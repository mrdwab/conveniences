#!/usr/local/bin/r

suppressMessages(library(docopt))
suppressMessages(library(glue))
suppressMessages(library(rvest))
suppressMessages(library(data.table))
suppressMessages(library(stringi))
options(useFancyQuotes = FALSE)

doc <- "Usage: bandcamp.r [URL] [-h] [--typ TYP]
-t --typ TYP          type of URL (label, artist, album) [default: label]
-h --help             show this help text"

opt <- docopt(doc)

tc <- c(red = "\\\\e[31m", yellow = "\\\\e[33m", blue = "\\\\e[34m", none = "\\\\e[0m")
gluefun <- function(message, color = "red") {
  system(glue("echo -e \"{col}{mes}\\\\e[0m\"", col = tc[color], mes = message))
}

setwd("~/Downloads/_Audio_To_Convert/")
rootURL <- opt$URL
rootFile <- gsub("https://", "", rootURL)

if (file.exists(sprintf("%s.csv", rootFile))) {
  bookkeeping <- fread(file = sprintf("%s.csv", rootFile))
  albums <- bookkeeping$album
} else {
  page <- read_html(rootURL)
  albums <- page %>% html_nodes("li.square") %>% html_nodes("a") %>% html_attr("href")
  
  albums <- switch(opt$typ,
                   label = gsub("\\?label.*$", "", albums),
                   artist = sprintf("%s%s", opt$URL, albums), 
                   album = opt$URL)
  
  albums <- sort(albums)
  check <- startsWith(albums, "/")
  if (any(check)) albums[check] <- sprintf("%s%s", sub("/music/", "", opt$URL), albums[check])
  albums <- albums[!grepl("/track/", albums)]
  
  bookkeeping <- data.table(album = albums, status = FALSE)
  fwrite(bookkeeping, file = sprintf("%s.csv", rootFile))
}

lapply(albums[!bookkeeping$status], function(x) {
  ## Create folder for the music
  folder <- gsub("https://(*.*)\\.bandcamp*.*/(.*)$", "\\1_-_\\2", x)
  gluefun(message = sprintf("\n\nCreating folder %s\n", folder), color = "red")
  if (!dir.exists(folder)) dir.create(folder)
  setwd(folder)
  
  ## Scrape the track list
  gluefun(message = "Scraping track details", color = "yellow")
  page <- read_html(x)
  page %>% 
    html_nodes("table.track_list") %>% 
    html_nodes("tr") %>% 
    html_text() %>%
    trimws() %>%
    gsub("\n+\\s+", ";", x = .) %>%
    sub("^([^;]+;[^;]+).*", "\\1", x = .) %>%
    sub("\\.", "", x = .) %>%
    writeLines(con = sprintf("%s.ssv", folder))
  
  ## Scrape the artist and album title
  gluefun(message = "Scraping album and artist details", color = "yellow")
  page %>% 
    html_nodes("title") %>% 
    html_text(trim = TRUE) %>%
    writeLines(con = "artist_album.txt")
  
  ## Download the album
  
  gluefun(message = "Downloading the album", color = "yellow")
  files <- system(sprintf("youtube-dl %s --get-filename", x), intern = TRUE)
  
  if (length(files) > 0) {
    system(sprintf("youtube-dl %s", x), ignore.stderr = TRUE, ignore.stdout = TRUE)  
    
    gluefun(message = "Modifying ID3 tags", color = "yellow")
    files <- data.table(files)
    files[, track_title := sub("-[0-9]+\\.mp3", "", files)][
      , c("artist", "track_title") := transpose(stri_split_fixed(track_title, " - ", 2L))]
    
    album_artist <- strsplit(readLines("artist_album.txt"), " | ", fixed = TRUE)[[1]]
    album_artist <- gsub("\"", "", album_artist)
    
    metadata <- readLines(con = list.files(pattern = "*ssv"))
    if (length(metadata) == 1L) metadata <- paste0(metadata, "\n")
    metadata <- sub("^([^;]+;[^;]+).*", "\\1", x = metadata)
    metadata <- metadata[nzchar(metadata)]
    metadata <- fread(text = metadata)
    setnames(metadata, c("V1", "V2"), c("track_number", "track_title"))
    metadata[, album := album_artist[1]][, album_artist := album_artist[2]][]
    
    metadata <- cbind(files[order(files)], metadata[order(track_title)])
    metadata[, cmd := glue("mid3v2 -a ", dQuote(album_artist), 
                           " -A ", dQuote(album),
                           " -t ", dQuote(track_title), 
                           " -T ", track_number, 
                           " ", dQuote(files)), 1:nrow(metadata)]
    metadata[, system(cmd), 1:nrow(metadata)]
    gluefun(message = glue("Download of ", album_artist[1], 
                           " by ", album_artist[2], " complete\n\n"), 
            color = "blue")
  } else {
    gluefun(message = "Nothing to download!", color = "red")
  }

  bookkeeping[album %in% x, status := TRUE]
  setwd("~/Downloads/_Audio_To_Convert/")
  fwrite(bookkeeping, file = sprintf("%s.csv", rootFile))
})
