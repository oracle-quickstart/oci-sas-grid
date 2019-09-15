#!/bin/bash
set -x
echo "Running platform_suite_install_1.sh"

# I don't need this anymore, since I have the logic in grid.tf and wait_for_cloud_init_to_complete.tf
#while [ ! -f /tmp/grid_cloud-init.complete ]
#do
#  sleep 20s;
#  echo "Waiting for node: `hostname --fqdn` cloud-init to complete ..."
#done;

su sas -l -c "/tmp/platform_suite_install_sas.sh"
