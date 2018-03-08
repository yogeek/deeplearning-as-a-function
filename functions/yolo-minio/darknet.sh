#!/bin/sh

set -e

# Stdin in /tmp/input
cat - > /tmp/input

# input contains image name : e.g "file.png"
image_name=$(cat /tmp/input)

# Configure Minio client
mc config host add local-minio  http://$MINIO_SERVER:$MINIO_PORT $MINIO_ACCESS_KEY $MINIO_SECRET_KEY

# Get Minio file into local dir
mc cp local-minio/${MINIO_BUCKET_INPUT}/${image_name} /tmp/

# Launch detection 
/darknet/darknet detect cfg/yolo.cfg  /yolo.weights  /tmp/${image_name} 2>/dev/null | grep ': [0-9]'

# Result is "predictions.png" file in current directory 

# Change prediction file name to include initial image name : "imageName-predicted.imageExtention"
# Get the file name with extension
fullname=$(basename "$image_name")
# Extract name without extension
filename="${fullname%.*}"
# Build output file name by adding "-predicted"
outputfile=${filename}_prediction.png
# Copy the prediction result into the ouput file
cp predictions.png ${outputfile}

# Create MINIO_BUCKET_OUTPUT if missing
if ! mc ls local-minio/${MINIO_BUCKET_OUPUT}
then
    mc mb local-minio/${MINIO_BUCKET_OUPUT}
fi

# Send result file to Minio bucket
echo "Sending prediction file to minio output bucket : ${outputfile} ---> ${MINIO_BUCKET_OUPUT}"
mc cp ${outputfile} local-minio/${MINIO_BUCKET_OUPUT}
