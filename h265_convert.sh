#!/bin/bash

read -p 'Extension: ' extvar
read -p "Per-channel (32): " abr
abr=${abr:-32}
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
        ~/Apps/ffmpeg/ffmpeg -i "$f" -map 0 -c copy -vf unsharp -c:v libx265 -preset fast -x265-params crf="$crflowvar" -c:a libopus -b:a "$((2 * $abr))"k -ac 2 -max_muxing_queue_size 99999 "${f%.*}_micro.mkv"
    else
        ~/Apps/ffmpeg/ffmpeg -i "$f" -map 0 -c copy -c:v libx265 -preset fast -x265-params crf="$crflowvar" -c:a libopus -b:a "$((2 * $abr))"k -ac 2 -max_muxing_queue_size 99999 "${f%.*}_micro.mkv"
    fi
elif [ "$height" -gt 999 ]; then
    ~/Apps/ffmpeg/ffmpeg -i "$f" -map 0 -c copy -c:v libx265 -preset fast -x265-params crf="$crfhdvar" -c:a libopus -b:a "$((2 * $abr))"k -ac 2 -max_muxing_queue_size 99999 "${f%.*}_micro.mkv"
else
    ~/Apps/ffmpeg/ffmpeg -i "$f" -map 0 -c copy -c:v libx265 -preset fast -x265-params crf="$crfhighvar" -c:a libopus -b:a "$((2 * $abr))"k -ac 2 -max_muxing_queue_size 99999 "${f%.*}_micro.mkv"
fi; done

