#!/bin/bash

read -p 'Extension: ' extvar
read -p "Per-channel (32): " abr
abr=${abr:-32}

for f in *."$extvar"; do ~/Apps/ffmpeg/ffmpeg -i "$f" -vn -c:a libopus -b:a "$((2 * $abr))"k -ac 2 -max_muxing_queue_size 99999 "${f%.*}.opus"; done

