#!/bin/bash

DB_USER=$(curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/db_user)
DB_PASS=$(curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/db_pass)
DB_HOST=$(curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/db_host)
DB_NAME=$(curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/db_name)

sed -i "s/DB_USER_PLACEHOLDER/$DB_USER/" ../webapp/.env
sed -i "s/DB_PASS_PLACEHOLDER/$DB_PASS/" ../webapp/.env
sed -i "s/DB_HOST_PLACEHOLDER/$DB_HOST/" ../webapp/.env
sed -i "s/DB_NAME_PLACEHOLDER/$DB_NAME/" ../webapp/.env

systemctl start webapp
