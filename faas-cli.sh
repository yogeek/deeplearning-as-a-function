#/bin/bash

# Search for docker group GID
if [[ $(command -v getent >/dev/null 2>&1) ]]
then
  DOCKER_GID=$(getent group docker | cut -d: -f3)
else
  # getent not installed => /etc/group and awk instead
  DOCKER_GID=$(cat /etc/group | grep docker: | awk -F\: '{print $3}')
fi

echo "PWD = $(pwd)"

docker run --rm -i \
	--net=host \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-v $(pwd):/app \
	-w /app \
	-e LOCAL_USER_ID=`id -u $USER` \
	-e DOCKER_GID=${DOCKER_GID} \
	yogeek/faas-cli faas-cli "$@"
