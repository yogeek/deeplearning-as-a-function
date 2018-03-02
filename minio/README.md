https://minio.io/

Run Minio once and capture the secret/access keys and inject into the command above.

$ docker run -ti --rm minio/minio server /data
...
AccessKey: ZBPIIAOCJRY9QLUVEHQO
SecretKey: vMIoCaBu9sSg4ODrSkbD9CGXtq0TTpq6kq7psLuE
...

Hit Control+C and set up two environmental variables:

export MINIO_ACCESS_KEY="ZBPIIAOCJRY9QLUVEHQO"
export MINIO_SECRET_KEY="vMIoCaBu9sSg4ODrSkbD9CGXtq0TTpq6kq7psLuE"

We found running a single-container minio server was the easiest way as I had issues when running the distributed version. Once Minio is deployed, go and create a new bucket called 'dataset'. This is where the images will be stored.

$ docker run -dp 9000:9000 \
  --restart always --name minio \
  -e "MINIO_ACCESS_KEY=$MINIO_ACCESS_KEY" \
  -e "MINIO_SECRET_KEY=$MINIO_SECRET_KEY" \
  minio/minio server /data


You can optionally add a bind-mount too by adding the option: -v /mnt/data:/data -v /mnt/config:/root/.minio

