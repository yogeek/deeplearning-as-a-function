# Installation script

CUR_PWD=$(pwd)

# A swarm mode cluster must be available (cf. README for help)

# Get faas
git clone https://github.com/openfaas/faas.git
# Patch docker-compose file to remove sample functions
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
if [[ $isLogin ]]
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
