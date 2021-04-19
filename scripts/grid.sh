#!/bin/bash
set -x
echo "Running grid.sh"

this_fqdn=`hostname --fqdn`
this_host=${this_fqdn%%.*}

echo "$clusterName" > /tmp/clusterName
echo "lsfTop=${lsfTop}" >> /tmp/env_variables.sh
echo "jsTop=${jsTop}" >> /tmp/env_variables.sh

source /tmp/env_variables.sh

# only on grid control server
echo $this_host | grep -q "${gridNodeHostnamePrefix}1"
if [ $? -eq 0 ]; then
    echo "grid control server"
fi

