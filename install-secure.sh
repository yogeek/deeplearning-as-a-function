#!/bin/sh

# Secure Installation script

# A swarm mode cluster must be available (cf. README for help)

# Get faas
git clone https://github.com/openfaas/faas.git

# Default user
USER="user"
# Generate a hashed password for user
echo "Please enter a password to secure the cluster."
htpasswd -c /tmp/password.txt $USER

# Replace user and password into docker-compose file
HASHED_PASSWD=$(cat /tmp/password.txt)
ESCAPE_PASSWORD=$(echo $HASHED_PASSWD | sed 's/\$/$$/g')
sed -i 's#@@@USER_PASSWORD@@@#'"$ESCAPE_PASSWORD"'#' docker-compose-with-traefik.yml
# Patch docker-compose file to add traefik in front of the gateway
cp docker-compose-with-traefik.yml faas/docker-compose.yml
# Deploy FAAS !
cd faas
./deploy_stack.sh

# Install faas-cli
curl -sSL https://cli.openfaas.com | sudo sh

# Alias faas-cli to use secure authentication
alias faas-cli='faas-cli --gateway http://user:password@localhost'

# Build functions
faas-cli build -f functions/stack.yml

# Push functions (needed if multiple hosts cluster)
faas-cli push -f functions/stack.yml

# Deploy functions
faas-cli deploy -f functions/stack.yml
