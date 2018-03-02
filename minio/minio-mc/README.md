# Minio client
# https://github.com/minio/mc

# Minio Client (mc) provides a modern alternative to UNIX commands like ls, cat, cp, mirror, diff, find etc. It supports filesystems and Amazon S3 compatible cloud storage service (AWS Signature v2 and v4).

ls       List files and folders.
mb       Make a bucket or a folder.
cat      Display file and object contents.
pipe     Redirect STDIN to an object or file or STDOUT.
share    Generate URL for sharing.
cp       Copy files and objects.
mirror   Mirror buckets and folders.
find     Finds files which match the given set of parameters.
diff     List objects with size difference or missing between two folders or buckets.
rm       Remove files and objects.
events   Manage object notifications.
watch    Watch for file and object events.
policy   Manage anonymous access to objects.
session  Manage saved sessions for cp command.
config   Manage mc configuration file.
update   Check for a new software update.
version  Print version info.

# Run image
docker run minio/mc ls play

