#!/bin/sh

set -e

# Get image from stdin and save it as /tmp/image
cat - > /tmp/image

# Apply darknet classifier on /tmp/image
cd /darknet
./darknet classifier predict cfg/imagenet22k.dataset cfg/extraction.cfg /extraction.weights /tmp/image 2>/dev/null
