#!/bin/sh

current_dir=$PWD
cd ~/Apps

remote=$(wget -qO- https://johnvansickle.com/ffmpeg/git-readme.txt | grep 'build: ' | sed -r 's/\s+build: ffmpeg-git-//' | sed -r 's/-amd64-static.tar.xz//')
echo "  Remote version date: $remote"
current=$(grep 'build:' ~/Apps/ffmpeg/readme.txt | sed -r 's/\s+build: ffmpeg-git-//' | sed -r 's/-amd64-static.tar.xz//')
echo "   Local version date: $current"

if [ $current -lt $remote ]; then
  echo 'Local version is out of date. Updating.'
  wget https://johnvansickle.com/ffmpeg/builds/ffmpeg-git-amd64-static.tar.xz
  dtrx --one=here ffmpeg-git-amd64-static.tar.xz 
  rm -r ffmpeg
  rm ffmpeg-git-amd64-static.tar.xz
  find . -depth -type d -name 'ffmpeg*' -execdir mv {} ffmpeg \;
else
  echo 'No need to update'
fi

cd $current_dir

