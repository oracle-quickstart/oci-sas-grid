#!/bin/bash
set -x
echo "Running platform_suite_install.sh"

# Chapter 2 - Installing Process Manager and LSF
# Step1
# Primary LSF Administrator - We are using sas user as Primary LSF Administrator instead of configuring a seperate user.





# only on grid control server, not on rest of the nodes of grid (ss-compute-2, ss-compute-3...etc)
echo $this_host | grep -q "ss-compute-1"
if [ $? -eq 0 ]; then


  #os=`uname -a | gawk -F" " '{ print $1 }'`
  #find $sas_depot_root -name pm10*.tar | grep $os > /local/pm_install/pm10_location

  #for file_path in `cat /local/pm_install/pm10_location` ; do echo $file_path ; cp $file_path /local/pm_install/ ;  done ; 
  #cd /local/pm_install/
  #tar xvf pm10*tar 
  #cd pm10.2_sas_pinstall/
  #cp  $sas_depot_root/sid_files/LSF* ./
  #cp LSF* license.dat

  sed -i "s|# JS_TOP=|JS_TOP=/usr/share/pm|g"  install.config
  sed -i "s|# JS_HOST=|JS_HOST=${this_fqdn}|g"  install.config
  sed -i "s|# JS_ADMINS=|JS_ADMINS=sas|g"  install.config
  sed -i "s|# LSF_INSTALL=true|LSF_INSTALL=true|g"  install.config
  sed -i "s|# LSF_TOP=\"/usr/share/lsf\"|LSF_TOP=\"/mnt/sas/nfs/APPLSF\"|g"  install.config
  sed -i "s|# LSF_CLUSTER_NAME=\"cluster1\"|LSF_CLUSTER_NAME=\"${cluster_name}\"|g"  install.config
  sed -i "s|# LSF_MASTER_LIST=\"hostm hosta hostc\"|LSF_MASTER_LIST=\"${this_fqdn}\"|g"  install.config

  # Platform Web Services Process Manager
  #echo ". /mnt/sas/nfs/APPLSF/conf/profile.lsf" >> /home/sas/.bash_profile 
  #echo ". /usr/share/pm/conf/profile.js" >> /home/sas/.bash_profile 
fi

 




