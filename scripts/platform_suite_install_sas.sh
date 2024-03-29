#!/bin/bash
set -x
echo "Running platform_suite_install_sas.sh"

thisFQDN=`hostname --fqdn`
thisHost=${thisFQDN%%.*}


source /tmp/env_variables.sh

## mkdir -p /usr/share/pm
##  sudo chown sas:sas /usr/share/pm


# only on grid control server, not on rest of the nodes of grid (ss-compute-2, ss-compute-3...etc)
echo $thisHost | grep -q "${gridNodeHostnamePrefix}1"
if [ $? -eq 0 ]; then

os=`uname -a | gawk -F" " '{ print $1 }'`
find $sasDepotRootPath -name pm10*.tar | grep $os > /local/pm_install/pm10_location

for file_path in `cat /local/pm_install/pm10_location` ; do echo $file_path ; cp $file_path /local/pm_install/ ;  done ;
cd /local/pm_install/
tar xvf pm10*tar
cd pm10.2_sas_pinstall/
cp  $sasDepotRootPath/sid_files/LSF* ./
cp LSF*txt license.dat

cp install.config install.config.original
sed -i "s|# JS_TOP=|JS_TOP=${jsTop}|g"  install.config
sed -i "s|# JS_HOST=|JS_HOST=${thisFQDN}|g"  install.config
sed -i "s|# JS_ADMINS=|JS_ADMINS=sas|g"  install.config
sed -i "s|# LSF_INSTALL=true|LSF_INSTALL=true|g"  install.config
sed -i "s|# LSF_TOP=\"/usr/share/lsf\"|LSF_TOP=\"${lsfTop}\"|g"  install.config
sed -i "s|# LSF_CLUSTER_NAME=\"cluster1\"|LSF_CLUSTER_NAME=\"${clusterName}\"|g"  install.config
sed -i "s|# LSF_MASTER_LIST=\"hostm hosta hostc\"|LSF_MASTER_LIST=\"${thisFQDN}\"|g"  install.config

# make sure the pm subinstall is non-interactive (add -y -s options)
sed -i.bak 's+\./_jsinstall.*+\./_jsinstall -y -s -f _install.config+' jsinstall

fi

exit 0
