#!/bin/bash

echo 'Extracting...'
for f in *.mp4; do MP4Box "$f" -srt 3 -out "${f%.*}.srt"; done

echo 'Renaming...'
rename 's/_3_text//' *.srt

echo 'Merging to mkv...'
for f in *.mp4; do mkvmerge -o "${f%.*}.mkv" "$f" "${f%.*}.srt"; done
