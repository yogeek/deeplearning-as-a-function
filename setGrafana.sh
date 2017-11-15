#!/bin/sh

[[ -z $1 ]] && echo "Please provide IP argument" && exit 1
echo "IP = $1"

# Import Grafana datasource
#curl -u admin:admin http://172.28.128.4:3000/api/datasources -X POST  -H 'Content-Type: application/json' --data-binary @datasource.json
curl -u admin:admin http://$1:3000/api/datasources -X POST  -H 'Content-Type: application/json' --data-binary @datasource.json
# Import Grafana dashboard
#curl -u admin:admin http://172.28.128.4:3000/api/dashboards/db -X POST  -H 'Content-Type: application/json' --data-binary @./dashboard.json
curl -u admin:admin http://$1:3000/api/dashboards/db -X POST  -H 'Content-Type: application/json' --data-binary @./dashboard.json
