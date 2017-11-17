#!/bin/sh

echo "Importing Grafana awesomeness..."
# Import Grafana datasource
curl -u admin:admin http://localhost:3000/api/datasources -X POST  -H 'Content-Type: application/json' --data-binary @datasource.json
# Import Grafana dashboard
curl -u admin:admin http://localhost:3000/api/dashboards/db -X POST  -H 'Content-Type: application/json' --data-binary @./dashboard.json
echo "Done !"
