#!/bin/sh

# Installation script

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
    docker swarm init --advertise-addr eth0
  else
    echo "Ok. You can do this yourself with 'docker swarm init' command"
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
curl -sSL https://cli.openfaas.com | sudo sh

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
