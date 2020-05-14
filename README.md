# conveniences

Command line scripts I use a lot...

## FFmpeg related

* [`audio_only.sh`](/audio_only.sh): Extracts the audio from a 
video file and converts it to a stereo opus file.
* [`audio_replace.sh`](/audio_replace.sh): Converts the audio 
file in a video to a stereo opus file.
* [`eng_only.sh`](/eng_only.sh): Removes any non-English or 
"unknown" subtitles from an mkv file.
* [`h265_convert.sh`](/h265_convert.sh): The main script I use 
to batch convert videos.
* [`no_copy.sh`](/no_copy.sh): Like `h265_convert.sh` but only 
copies audio and video streams and ignores anything else.
* [`update_ffmpeg.sh`](/update_ffmpeg.sh): Checks to see if a
new static build version of FFmpeg is available online at 
https://johnvansickle.com/ffmpeg/ and replaces the local
version if an update is found.
* [`video_only.sh`](/video_only.sh): Like `audio_only.sh` but
converts only the video stream to h265.

## Other video related

* [`handbrake_hevc.sh`](/handbrake_hevc.sh): For when FFmpeg 
fails me and I decide to fall back on the HandBrake encoder 
instead.
* [`hevc.r`](/hevc.r): Pretty much rolls together 
`h265_convert.sh` and `handbrake_hevc.sh` into one script.
* [`subfix.r`](/subfix.r): Fixes the timestamps of srt or sbv 
files downloaded from YouTube so they don't overlap when you 
reupload them to YouTube. Go figure...
* [`subtitle_merge.sh`](/subtitle_merge.sh): Merges video and
srt files with common names into an mkv.
* [`timed_text_extract.sh`](/timed_text_extract.sh): Extracts
timed text from mp4 files to an srt.

## PDF related

* [`pdf2png.r`](/pdf2png.r): Converts the pages of a pdf into 
separate pngs.
* [`scanfix.r`](/scanfix.r): Converts a series of tif files 
into a pdf, optionally also creating a multi-page layout pdf 
for printing. See how this works with `pdf2png.r` 
[here](https://graphicdesign.stackexchange.com/a/137056/4044).

## Other stuff

* [`bandcamp.r`](/bandcamp.r): Scraper for bandcamp. Can
scrape by label, artist, or album.
* [`toggle_keyboard.sh`](/toggle_keyboard.sh): Turns the
inbuilt laptop keyboard on or off. Useful when you have an 
external keyboard plugged in and don't want cats walking 
on your laptop to take over typing.
