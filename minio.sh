# Start server
# 

export MINIO_ACCESS_KEY=671A6QYAL6D7QF1G2EF8
export MINIO_SECRET_KEY=ZXQsO6ak1zSzknHPmv1H8fxb7hHNvg/csiaGnQYX

docker run -dp 9000:9000 --restart always --name minio -e "MINIO_ACCESS_KEY=$MINIO_ACCESS_KEY" -e "MINIO_SECRET_KEY=$MINIO_SECRET_KEY" minio/minio server /data

# Get minio client "mc"
wget https://dl.minio.io/client/mc/release/linux-amd64/mc
chmod +x mc
sudo cp mc /usr/local/bin/

# Test : mc -h

# Config client with local server
mc config host add local-minio  http://10.1.2.16:9000 $MINIO_ACCESS_KEY $MINIO_SECRET_KEY

# List minio servers
mc config host ls

# Create a bucket on local server
mc mb local-minio/dataset 

# List buckets on a server
mc ls local-minio

# Upload a file to your minio bucket
mc cp img.png local-minio/dataset

# List files on a bucket
mc ls local-minio/dataset

# Download a file from a bucket
mc cp citadel/dataset/img.png .
