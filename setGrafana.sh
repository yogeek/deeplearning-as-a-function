#!/bin/bash

GRAFANA_IP=${1}

while ! curl http://${GRAFANA_IP}:3000
do
    echo "Waiting Grafana to be ready..."
    sleep 2
done
echo "Grafana ready !"

echo "Importing Grafana awesomeness..."
# Import Grafana datasource
curl -u admin:admin http://${GRAFANA_IP}:3000/api/datasources -X POST  -H 'Content-Type: application/json' --data-binary @datasource.json
# Import Grafana dashboard
curl -u admin:admin http://${GRAFANA_IP}:3000/api/dashboards/db -X POST  -H 'Content-Type: application/json' --data-binary @./dashboard.json
echo "Done !"
