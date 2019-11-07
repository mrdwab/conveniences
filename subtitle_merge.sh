#!/bin/bash

read -p "Video Extension [mp4]: " vext
vext=${vext:-mp4}
read -p "Subtitle Extension [srt]: " sext
sext=${sext:-srt}

if [ $vext == "mkv" ]; then
    for f in *.$(echo "$vext"); do mkvmerge -o "${f%.*}_new.mkv" "$f" "${f%.*}.$sext"; rm "$f"; mv "${f%.*}_new.mkv" "$f"; done
else
    for f in *.$(echo "$vext"); do mkvmerge -o "${f%.*}.mkv" "$f" "${f%.*}.$sext"; done
fi
