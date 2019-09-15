#!/bin/bash
set -x
echo "Running grid.sh"

this_fqdn=`hostname --fqdn`
this_host=${this_fqdn%%.*}

# Make a list of nodes in the cluster
# Files in /tmp folder created by install.sh script
# /tmp/gridnodehosts
# /tmp/metadatanodehosts
# /tmp/midtiernodehosts
# /tmp/allnodehosts

echo "$clusterName" > /tmp/clusterName

echo "lsfTop=${lsfTop}" >> /tmp/env_variables.sh
echo "jsTop=${jsTop}" >> /tmp/env_variables.sh

source /tmp/env_variables.sh


# only on grid control server, not on rest of the nodes of grid (ss-compute-2, ss-compute-3...etc)
echo $this_host | grep -q "ss-compute-1\|grid-1"
if [ $? -eq 0 ]; then
    echo "grid control server"
fi

