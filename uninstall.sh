#!/bin/sh


# UnInstallation script

# Remove faas stack
docker stack rm func

# Displaying remaining services
remaining_services=$(docker service ls -q)
if [[ "$remaining_services" != "" ]]
then
  echo "Remaining services :"
  docker service ls
  echo ""
  echo -n "Remove services ? [y/n]"
  read remove
  [[ "$remove" == "y" ]] && docker service rm $(docker service ls -q)
fi
