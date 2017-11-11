#!/bin/sh

# Get image from stdin and save it as /tmp/image
cat - > /tmp/image

# Apply nothotdog classifier on /tmp/image
cd /not-hotdog
python label_image.py /tmp/image
