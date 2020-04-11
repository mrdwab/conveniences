#!/bin/bash

read -p 'Extension: ' extvar
read -p "CRF SD (23): " crflowvar
crflowvar=${crflowvar:-23}
read -p "CRF 720 (28): " crfhighvar
crfhighvar=${crfhighvar:-28}
read -p "CRF 1080 (33): " cfrhdvar
cfrhdvar=${cfrhdvar:-33}
read -p "Sharpen (y/n) (n): " sharpvar
sharpvar=${sharpvar:-n}

for f in *."$extvar"; do \

height=$(~/Apps/ffmpeg/ffprobe -loglevel error -select_streams v:0 -show_entries stream=height -of default=nw=1:nk=1 "$f")

if [ "$height" -lt 500 ]; then
    if [ "$sharpvar" == "y" ]; then
        ~/Apps/ffmpeg/ffmpeg -i "$f" -an -vf unsharp -c:v libx265 -preset fast -x265-params crf="$crflowvar" "${f%.*}_micro.mkv"
    else
        ~/Apps/ffmpeg/ffmpeg -i "$f" -an -c:v libx265 -preset fast -x265-params crf="$crflowvar" "${f%.*}_micro.mkv"
    fi
elif [ "$height" -gt 999 ]; then
    ~/Apps/ffmpeg/ffmpeg -i "$f" -an -c:v libx265 -preset fast -x265-params crf="$crfhdvar" "${f%.*}_micro.mkv"
else
    ~/Apps/ffmpeg/ffmpeg -i "$f" -an -c:v libx265 -preset fast -x265-params crf="$crfhighvar" "${f%.*}_micro.mkv"
fi; done
