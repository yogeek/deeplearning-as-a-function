#!/bin/sh

# Installation script
if [[ ! -z $SWARM_ETH ]]
then
  swarm_opts="--advertise-addr ${SWARM_ETH}"
fi

# A swarm mode cluster must be available (cf. README for help)
swarmInactive=$(docker info | grep -i swarm | grep inactive)
# If swarm mode is inactive, we nicely propose to init a minimal swarm
if [[ "$swarmInactive" != "" ]]
then
  echo "A swarm mode cluster must be available (cf. README for help)"
  echo -n "Do you want to init a minimal one-node swarm ? [y/n]"
  read createSwarm
  if [[ "$createSwarm" == "y" ]]
  then
    echo "Swarm options : ${swarm_opts:-}"
    docker swarm init ${swarm_opts:-}
    if [[ $? -ne 0 ]]
    then
      echo ""
      echo "---------------------------------------------------------------------------------------------------------------------"
      echo "Error to create Swarm cluster. Possible causes :"
      echo "   - Check docker version (must be 1.12+)"
      echo "   - Your default network interface is not valid. Please export SWARM_ETH=<your_nerwork_interface> and relaunch this script."
      echo "     (interface list can be displayed by 'ifconfig' command)"
      echo "     => example : export SWARM_ETH=ens160"
      echo "---------------------------------------------------------------------------------------------------------------------"
      echo ""
      exit 1
    fi
  else
    echo "Ok. You can do this yourself with 'docker swarm init' command"
    exit 1
  fi
fi

CUR_PWD=$(pwd)

# Get faas
git clone https://github.com/openfaas/faas.git
# Patch docker-compose file to remove sample functions
mv faas/docker-compose.yml faas/docker-compose.yml.with-sample
cp docker-compose-without-sample.yml faas/docker-compose.yml
# Deploy FAAS !
cd faas
./deploy_stack.sh
cd ${CUR_PWD}

# Install faas-cli
#curl -sSL https://cli.openfaas.com | sudo sh

# Use faasci docker image
echo "Getting faas-cli image..."
docker pull yogeek/faas-cli

# Search for docker group GID
if [[ $(command -v getent >/dev/null 2>&1) ]]
then
  DOCKER_GID=$(getent group docker | cut -d: -f3)
else
  # getent not installed => /etc/group and awk instead
  DOCKER_GID=$(cat /etc/group | grep docker: | awk -F\: '{print $3}')
fi

# Replace faas-cli command to run into custom docker image
alias faas-cli='docker run --rm -it \
	--net=host \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-v $(pwd):/app \
	-w /app \
	-e LOCAL_USER_ID=`id -u $USER` \
	-e DOCKER_GID=${DOCKER_GID} \
	yogeek/faas-cli faas-cli'

cd functions
if [[ "$1" == "build" ]]
then
  # Build functions
  faas-cli build -f stack.yml
  rm -rf template/

  # Push functions (needed if multiple hosts cluster)
  echo "If you deploy to a multi-hosts cluster, you have to push the image to a registry."
  echo -n "Do you want to push the image to your docker account [y/n]?"
  read isLogin
  if [[ "$isLogin" == "y" ]]
  then
    echo -n "Enter your login: "
    read login
    echo -n "Enter your password: "
    read -s password
    docker login -u $login -p $password
    echo "Pushing image..."
    faas-cli push -f stack.yml
  fi
fi

# Deploy functions
FAAS_IP=$(ifconfig ${SWARM_ETH:-localhost} | grep "inet " | awk '{print $2}')
#faas-cli deploy --gateway http://${FAAS_IP}:8080 -f stack.yml
faas-cli deploy -f stack.yml
sleep 10
# Deploy a function directly from an image
#faas-cli deploy --image yogeek/darknet --name darknet

# Import Grafan dashboard
# curl -X POST https://${FAAS_IP}/api/v2/grafana/dashboards/ -d @faas-dashboard.json

echo ""
echo "----------------------------------------------"
echo "FaaS available : "
echo "	GATEWAY : http://${FAAS_IP}:8080"
echo "	DASHBOARD : http://${FAAS_IP}:3000"
echo ""
echo "Import "faas-dashboard.json" in grafana and enjoy monitoring !
echo ""
echo "----------------------------------------------"

echo ""
echo "Done !"

cd ${CUR_PWD}

# List functions
faas-cli list

# Test
echo ""
echo "-------> Test it :"
echo "Darknet, what is this image... ?"
echo "cat img/bald-eagle.jpg | faas-cli invoke darknet --gateway http://${FAAS_IP}:8080"
echo "---"
echo "Jin Yang, is it a hotdog... ?"
echo "curl --data-binary @img/hotdog.png http://${FAAS_IP}:8080/function/nothotdog"
echo ""
