#!/bin/sh

# Secure Installation script

# A swarm mode cluster must be available (cf. README for help)

# Get faas
git clone https://github.com/openfaas/faas.git

# Default user
USER="user"
# Generate a hashed password for user
echo -n "Please enter a password to secure the cluster."
read secret
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

# Push functions (needed if multiple hosts cluster)
faas-cli push -f stack.yml

# Deploy functions
faas-cli deploy -f stack.yml --gateway http://user:${secret}@localhost

# List functions
faas-cli list --gateway http://user:a@localhost
