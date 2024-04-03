#!/bin/bash

echo "-------------------------------------------------------------------------"
echo "Get variables from metadata"
echo "-------------------------------------------------------------------------"
DB_USER=$(curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/db_user)
DB_PASS=$(curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/db_pass)
DB_HOST=$(curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/db_host)
DB_NAME=$(curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/db_name)
DB_PORT=$(curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/db_port)
PUBSUB_TOPIC=$(curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/pubsub_topic)


echo "-------------------------------------------------------------------------"
echo "Create .env in /tmp and move it to webapp"
echo "-------------------------------------------------------------------------"
cd /tmp/
touch .env
echo HOST=$DB_HOST >> .env
echo DB_NAME=$DB_NAME >> .env
echo DB_USERNAME=$DB_USER >> .env
echo DB_PASS=$DB_PASS >> .env
echo PUBSUB_TOPIC=$PUBSUB_TOPIC >> .env
echo PORT=$DB_PORT >> .env
echo DIALECT=mysql >> .env

sudo mv /tmp/.env /opt/csye6225/webapp/

echo "-------------------------------------------------------------------------"
echo "Start webapp service"
echo "-------------------------------------------------------------------------"
sudo systemctl daemon-reload
sudo systemctl enable webapp
sudo systemctl start webapp
sudo systemctl status webapp
