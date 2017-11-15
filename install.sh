#!/bin/sh

# Installation script
echo $SWARM_ETH

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
    docker swarm init --advertise-addr ${SWARM_ETH:-eth1}
    if [[ $? -ne 0 ]]
    then
      echo ""
      echo "---------------------------------------------------------------------------------------------------------------------"
      echo "Error to create Swarm cluster. Possible causes :"
      echo "   - Check docker version (must be 1.12+)"
      echo "   - Your network interface	(${SWARM_ETH:-eth0}) is not valid. Please export SWARM_ETH=<your_nerwork_interface> and relaunch this script."
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
alias faas-cli='docker run --rm -i --net=host -v $(pwd):/app -w /app -e LOCAL_USER_ID=`id -u $USER` yogeek/faas-cli faas-cli'

# Build functions
cd functions
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

# Deploy functions
faas-cli deploy -f stack.yml
sleep 5
# Deploy a function directly from an image
#faas-cli deploy --image yogeek/darknet --name darknet

echo ""
echo "Done !"

cd ${CUR_PWD}

# List functions
faas-cli list --gateway http://user:${secret}@localhost

# Test
echo ""
echo "-------> Test it :"
echo "Darknet, what is this image... ?"
echo "cat img/bald-eagle.jpg | faas-cli invoke darknet"
echo "---"
echo "Jin Yang, is it a hotdog... ?"
echo "curl --data-binary @img/hotdog.png http://localhost:8080/function/nothotdog"
echo ""
