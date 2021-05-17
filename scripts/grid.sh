#!/bin/bash
set -x
echo "Running grid.sh"

thisFQDN=`hostname --fqdn`
thisHost=${thisFQDN%%.*}


echo "$clusterName" > /tmp/clusterName
echo "lsfTop=${lsfTop}" >> /tmp/env_variables.sh
echo "jsTop=${jsTop}" >> /tmp/env_variables.sh

source /tmp/env_variables.sh

# only on grid control server
echo $thisHost | grep -q "${gridNodeHostnamePrefix}1"
if [ $? -eq 0 ]; then
    echo "grid control server"
fi

