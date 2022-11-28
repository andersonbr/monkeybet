#!/bin/bash

TMPFILE=$(mktemp)
mv $TMPFILE $TMPFILE.ts

BASEURL="https://gvc.live.inspiredvss.co.uk/live/intpoolsoccer/stream_5/"

curl -s $BASEURL$(curl -s $BASEURL/intpoolsoccer.m3u8 2>/dev/null|tail -n 1) -o $TMPFILE.ts; ffmpeg -i $TMPFILE.ts $TMPFILE.png 1>/dev/null 2>&1

rm -f $TMPFILE.ts

TXT=$(cat $TMPFILE.png | convert png:- -threshold 60% -crop 230x60+255+0 -negate pnm:-| gocr - 2>/dev/null)
EVENTID=$(cat $TMPFILE.png | convert png:- -threshold 95% -crop 100x34+597+15 -negate pnm:-|gocr -C "0123456789" - 2>/dev/null)

if [[ "$TXT" = "RESULT" || "$TXT" = "PLAYNOW!" ]]; then
  echo $TXT
  echo "$EVENTID"
  RESULTS=$(cat $TMPFILE.png | convert png:- -threshold 95% -crop 700x30+240+340 -negate pnm:- | gocr -C "-0123456789" - 2>/dev/null | sed -r -e 's/([0-9]+)_([0-9]+)/\1x\2/g' | sed -r -e 's/\s+/ /g')
  echo $RESULTS
fi

rm -f $TMPFILE.png

