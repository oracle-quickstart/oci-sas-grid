#!/bin/bash 
set -x 
echo "Running platform_suite_install_add_grid_nodes.sh"

this_fqdn=`hostname --fqdn`
this_host=${this_fqdn%%.*}


source /tmp/env_variables.sh


# Add rest of the grid nodes to this file
cat $lsfTop/conf/lsf.cluster.$clusterName
sed -i "s|End     Host|$this_fqdn   !   !   1   (SASApp)\nEnd     Host|g" $lsfTop/conf/lsf.cluster.$clusterName


#ss-compute-1.private1.ibmssvcnv3.oraclevcn.com   !   !   1   (mg SASApp)
#ss-compute-2.private1.ibmssvcnv3.oraclevcn.com   !   !   1   (SASApp)
#ss-compute-3.private1.ibmssvcnv3.oraclevcn.com   !   !   1   (SASApp)
#End     Host

# command to set up the proper initialization files for future reboots
cd $lsfTop/10.1/install
./hostsetup --top="$lsfTop" --boot="y" --profile="y" --start="y"
ps -ef | grep $lsfTop

# next step - Run the following two commands as root on the grid control node to make the new node known
# lsadmin reconfig  , badmin reconfig
 




