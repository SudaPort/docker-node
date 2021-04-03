#!/bin/bash

echo "==================================== Getting Azure CLI ==========================================================="
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
echo "==================================== Getting Stellar ============================================================="
for N in 1 2; do
  docker run --name db$N -p 544$N:5432 --env-file local.env -d stellar/stellar-core-state
  docker run --name node$N --net host -v /home/gurosh/stellar:/opt/stellar --volumes-from db$N --env-file local.env -d stellar/stellar-core /start node$N fresh forcescp
done

for N in 3; do
  docker run --name db$N -p 544$N:5432 --env-file local.env -d stellar/stellar-core-state
  docker run --name node$N --net host -v /home/gurosh/stellar:/opt/stellar --volumes-from db$N --env-file local.env -d stellar/stellar-core /start node$N fresh
done
