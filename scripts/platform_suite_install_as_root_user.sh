#!/bin/bash
set -x
echo "Running platform_suite_install_root.sh"

thisFQDN=`hostname --fqdn`
thisHost=${thisFQDN%%.*}


source /tmp/env_variables.sh


# only on grid control server, not on rest of the nodes of grid (ss-compute-2, ss-compute-3...etc)
echo $thisHost | grep -q "${gridNodeHostnamePrefix}1"
if [ $? -eq 0 ]; then
  cd /local/pm_install/pm10.2_sas_pinstall
  echo 1 | ./jsinstall -f ./install.config &> install.log
  cd $lsfTop/10.1/install/
  ./hostsetup --top="$lsfTop" --boot="y" --profile="y" --start="y"
  ps -ef | grep $lsfTop
  # As per install step,  the root user needs to source this and start jadmin
  echo ". /usr/share/pm/conf/profile.js" >>  /root/.bash_profile
  # The below sourcing for sas user, might not be required for sas user.
  ## echo ". /usr/share/pm/conf/profile.js" >>   /home/sas/.bash_profile
  . /usr/share/pm/conf/profile.js
  which jadmin
  cd /usr/share/pm
  $jsTop/10.2/bin/jadmin start
  cd 10.2/install/
  $jsTop/10.2/install/bootsetup
  ps -ef | grep jfd

  # Platform Web Services Process Manager
  echo ". ${lsfTop}/conf/profile.lsf" >> /home/sas/.bash_profile
  # source for current session
  . ${lsfTop}/conf/profile.lsf
fi

####
##LSF_TOP="/mnt/sas/nfs/APPLSF"
##JS_TOP="/usr/share/pm"
##cd /local/pm_install/pm10.2_sas_pinstall
##./jsinstall -f install.config
##cd /mnt/sas/nfs/APPLSF/10.1/install/
##./hostsetup --top="$LSF_TOP" --boot="y" --profile="y" --start="y"
##ps -ef | grep $LSF_TOP
##echo ". /usr/share/pm/conf/profile.js" >>  /root/.bash_profile
##echo ". /usr/share/pm/conf/profile.js" >>   /home/sas/.bash_profile
##. /usr/share/pm/conf/profile.js
##which jadmin
##cd /usr/share/pm
##/usr/share/pm/10.2/bin/jadmin start
##cd 10.2/install/
##/usr/share/pm/10.2/install/bootsetup
##ps -ef | grep jfd



# $lsfTop/conf/lsf.shared  contains below line.  It was not added manually, so should be added by one of the sas commands.
# SASApp Boolean () () ()



