#!/bin/sh

set -e

# Stdin in /tmp/input
cat - > /tmp/input

# input contains image name : e.g "file.png"
image_name=$(cat /tmp/input)

# Configure Minio client
mc config host add local-minio  http://$MINIO_SERVER:$MINIO_PORT $MINIO_ACCESS_KEY $MINIO_SECRET_KEY

# Connection test = mc ls $MINIO_SERVER

# Get Minio file into local dir
mc cp local-minio/$MINIO_BUCKET/${image_name} /tmp/

/darknet/darknet detect cfg/yolo.cfg  /yolo.weights  /tmp/${image_name} 2>/dev/null | grep ': [0-9]'

# Send result file to Minio bucket
mc cp predictions.png local-minio/$MINIO_BUCKET
