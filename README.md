# Deep Learning as a funtion

Easy deployment of Deep Learning predictions as functions thanks to OpenFaas awesome projet :-)

List of current functions :
* darknet

More to come...

## Initialize Swarm Mode (from [OpenFaas deployment documentation](https://github.com/openfaas/faas/blob/master/guide/deployment_swarm.md))

You can create a single-host Docker Swarm on your laptop with a single command. You don't need any additional software to Docker 17.05 or greater. You can also run these commands on a Linux VM or cloud host.

This is how you initialize your master node:

```
# docker swarm init
```

If you have more than one IP address you may need to pass a string like `--advertise-addr eth0` to this command.

Take a note of the join token

* Join any workers you need

Log into your worker node and type in the output from `docker swarm init` on the master. If you've lost this info then type in `docker swarm join-token worker` and then enter that on the worker.

It's also important to pass the `--advertise-addr` string to any hosts which have a public IP address.

> Note: check whether you need to enable firewall rules for the [Docker Swarm ports listed here](https://docs.docker.com/engine/swarm/swarm-tutorial/).

## Deploy all the things

* Connect to a swarm manager
* Clone this repository
* Execute the install script :
```
./install.sh
```

Your functions are available !

## Test

Classify an image with darknet :
* Get an image
```
 wget https://upload.wikimedia.org/wikipedia/commons/thumb/1/19/%C3%81guila_calva.jpg/1200px-%C3%81guila_calva.jpg -O eagle.jpg
```
* Call the function from any node
```
curl localhost:8080/function/darknet --data-binary @eagle.jpg
```

## Improvements

To use in production mode, follow the [guide](https://blog.alexellis.io/lock-down-openfaas/) to lock-down OpenFaas with a reverse proxy like Traefik for example.
