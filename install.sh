# Installation script

# A swarm mode cluster must be available (cf. README for help)

# Get faas
git clone https://github.com/openfaas/faas.git
# Patch docker-compose file to remove sample functions
cp docker-compose-without-sample.yml faas/docker-compose.yml
# Deploy FAAS !
cd faas
./deploy_stack.sh

# Install faas-cli
curl -sSL https://cli.openfaas.com | sudo sh

# Build functions
faas-cli build -f functions/stack.yml

# Push functions (needed if multiple hosts cluster)
faas-cli push -f functions/stack.yml

# Deploy functions
faas-cli deploy -f functions/stack.yml
