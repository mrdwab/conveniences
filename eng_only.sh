#!/bin/bash

for f in *.mkv ; do
  mkvmerge -o "${f%.*}_new.mkv" -s und,eng "$f"; rm "$f"; mv "${f%.*}_new.mkv" "$f"
done
