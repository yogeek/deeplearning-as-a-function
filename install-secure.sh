#!/bin/sh

# Secure Installation script

# A swarm mode cluster must be available (cf. README for help)

CUR_PWD=$(pwd)

# Get faas
git clone https://github.com/openfaas/faas.git

# Default user
USER="user"
# Generate a hashed password for user
echo -n "Please enter a password to secure the cluster :"
read -s secret
# htpasswd read from stdin with "-i" and write hashed passwd to the "-c" file
# Format : "user:<HASHED_PASSWD>"
echo $secret | htpasswd -i -c /tmp/password.txt $USER

# Replace user and password into docker-compose file
HASHED_PASSWD=$(cat /tmp/password.txt)
ESCAPE_PASSWORD=$(echo $HASHED_PASSWD | sed 's/\$/$$/g')
sed -i 's#@@@USER_PASSWORD@@@#'"$ESCAPE_PASSWORD"'#' docker-compose-with-traefik.yml
# Patch docker-compose file to add traefik in front of the gateway
cp docker-compose-with-traefik.yml faas/docker-compose.yml
# Deploy FAAS !
cd faas
./deploy_stack.sh
cd ${CUR_PWD}

# Install faas-cli
curl -sSL https://cli.openfaas.com | sudo sh

cd functions
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

# Deploy functions
faas-cli deploy -f stack.yml --gateway http://user:${secret}@localhost
sleep 5
echo ""
echo "Done !"

cd ${CUR_PWD}

# List functions
faas-cli list --gateway http://user:${secret}@localhost

# Test
echo ""
echo "-------> Test it :"
echo "Darknet, what is this image... ?"
echo "cat img/bald-eagle.jpg | faas-cli invoke darknet --gateway http://user:<PASSWORD>@localhost"
echo "---"
echo "Jin Yang, is it a hotdog... ?"
echo "curl -u user:password -X POST --data-binary @img/hotdog.png http://localhost/function/nothotdog"
echo ""
