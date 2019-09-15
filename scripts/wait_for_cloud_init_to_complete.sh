#!/bin/bash
set -x

while [ ! -f /tmp/cloud_init.complete ]
do
  sleep 60s
  echo "Waiting for  cloud-init to complete for : `hostname --fqdn`  ..."
done

