#!/bin/sh

# Add local user
# Either use the LOCAL_USER_ID if passed in at runtime or
# fallback

USER_ID=${LOCAL_USER_ID:-9001}

echo "Starting with UID : $USER_ID"
echo "Adding to dockerhost group with GID : $DOCKER_GID"
addgroup -g $DOCKER_GID dockerhost
adduser -s /bin/sh -u $USER_ID -D user
addgroup user dockerhost
export HOME=/home/user

exec /sbin/su-exec user "$@"
