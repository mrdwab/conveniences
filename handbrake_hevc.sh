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

rate = 0.0
abr = `echo $abr * 2 | bc`

for f in *."$extvar"; do \

height=$(~/Apps/ffmpeg/ffprobe -loglevel error -select_streams v:0 -show_entries stream=height -of default=nw=1:nk=1 "$f")

if [ "$height" -lt 500 ]; then
    rate = `echo $crflowvar + $rate | bc` 
    HandBrakeCLI -i "$f" -o "${f%.*}_micro.mkv" -e x265 -q "$rate" --all-audio -E "opus" -B "$abr" --mixdown "stereo"
elif [ "$height" -gt 999 ]; then
    rate = `echo $crfhdvar + $rate | bc`
    HandBrakeCLI -i "$f" -o "${f%.*}_micro.mkv" -e x265 -q "$rate" --all-audio -E "opus" -B "$abr" --mixdown "stereo"
else
    rate = `echo $crfhighvar + $rate | bc`
    HandBrakeCLI -i "$f" -o "${f%.*}_micro.mkv" -e x265 -q "$rate" --all-audio -E "opus" -B "$abr" --mixdown "stereo"
fi; done

