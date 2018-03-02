#!/bin/sh

# Get image from stdin and save it as /tmp/path.txt
cat - > /tmp/path.txt

# Read pathes in /tmp/path.txt
src=$(grep src /tmp/path.txt | cut -d"=" -f2)
dest=$(grep dest /tmp/path.txt | cut -d"=" -f2)
echo "$src -> $dest"
cp $src $dest
