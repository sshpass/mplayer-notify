#!/usr/bin/env bash

# music.sh - mplayer script with 'Now Playing' notifications and album art.
# Written by Marc Carlson March 28, 2022.
# This script requires the installation of notify-send (libnotify-bin or libnotify), mplayer, ffmpeg and mp3info.
# Please indicate path to playlist below. 
# Album art icon is displayed only if there is embedded album art in the MP3.
# When killing mplayer, be sure to kill tail also, as it is running in the background. pkill mplayer && pkill tail
# mplayer can be controlled via the fifo file. Examples below. Search web for more examples.
# echo 'pausing_keep_force pt_step 1' > /tmp/fifo - skip track
# echo 'pause' > /tmp/fifo - pause and unpause music.
# Free software. Blah, blah, blah. Do whatever you want with it. 


path_to_playlist=~/music/playlist


type -P ffmpeg 1>/dev/null
          [ "$?" -ne 0 ] && echo "Please install ffmpeg before using this script." && exit

type -P mp3info 1>/dev/null
          [ "$?" -ne 0 ] && echo "Please install mp3info before using this script." && exit

if [ ! -e /tmp/fifo ]; then
          mkfifo /tmp/fifo
fi

function play {
          ( mplayer -slave -input file=/tmp/fifo -shuffle -playlist $path_to_playlist > /tmp/log 2>&1 & )
}

function notify {
          ( tail -n 25 -f /tmp/log | grep --line-buffered "Playing" | while read line 
      do
	  song=$(cat /tmp/log | grep Playing | sed 's/Playing//g' | sed 's/ //1'| cut -d . -f 1,2 | tail -n 1) 
	  ( ffmpeg -y -i "$song" /tmp/album.jpg > /dev/null 2>&1 & ) 
	  sleep 0.5
	  notify-send -i /tmp/album.jpg "Now Playing" "$(mp3info -p '%a - %t' "$song")" 
      done > /dev/null 2>&1 & )
}

play
notify
