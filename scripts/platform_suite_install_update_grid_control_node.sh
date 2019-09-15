#!/bin/bash
set -x
echo "Running platform_suite_install_update_grid_control_node.sh"


this_fqdn=`hostname --fqdn`
this_host=${this_fqdn%%.*}

source /tmp/env_variables.sh

# Run these to make grid control node aware of newly added grid nodes

lsadmin reconfig
badmin reconfig
#sudo su -l -c "lsadmin reconfig"
#sudo su -l -c "badmin reconfig"


exit 0
