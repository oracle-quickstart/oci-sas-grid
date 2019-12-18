
echo "Running install.sh"


echo "Got the parameters:"
echo sasUserPassword \'$sasUserPassword\'
echo edition \'$edition\'



# Add Users and Groups
groupadd sas
adduser sas -g sas
echo -e "$sasUserPassword\n$sasUserPassword" | passwd sas
# to give sudo access without password. TODO: Need to add another step to enable it. 
usermod -aG wheel sas


thisFQDN=`hostname --fqdn`
thisHost=${thisFQDN%%.*}

echo $thisHost | grep -q "metadata-"
if [ $? -eq 0 ]; then
  echo "Metadata specific configurations"
  # permanent change
  echo -e "*               soft nproc 65536\n*               hard nproc 65536\n*               soft nofile 65536\n*               hard nofile 65536" >> /etc/security/limits.conf
  # for current session
  ulimit -n 65536
  ulimit -u 65536
  echo "ulimit -n 65536" >> /home/sas/.bash_profile
  echo "ulimit -u 65536" >> /home/sas/.bash_profile

  #echo DefaultTasksMax=10240 >> /etc/systemd/system.conf
  #systemctl daemon-reexec 
fi


echo $thisHost | grep -q "mid_tier-\|ss-compute-\|grid-"
if [ $? -eq 0 ]; then
  echo "Grid/Mid-tier specific configurations"
  # permanent change
  echo -e "*               soft nproc 10240\n*               hard nproc 10240\n*               soft nofile 20480\n*               hard nofile 20480" >> /etc/security/limits.conf
  # for current session
  ulimit -n 20480
  ulimit -u 10240
  echo "ulimit -n 20480" >> /home/sas/.bash_profile
  echo "ulimit -u 10240" >> /home/sas/.bash_profile 


  echo DefaultTasksMax=10240 >> /etc/systemd/system.conf
  systemctl daemon-reexec
fi


echo $thisHost | grep -q "mid_tier-"
if [ $? -eq 0 ]; then
  # Use the following commands to temporarily set the SAS recommended TCP/IP settings:
  echo 30 > /proc/sys/net/ipv4/tcp_fin_timeout  
  echo 3000 > /proc/sys/net/core/netdev_max_backlog 
  echo 3000 > /proc/sys/net/core/somaxconn 
  echo 15 > /proc/sys/net/ipv4/tcp_keepalive_intvl 
  echo 5 > /proc/sys/net/ipv4/tcp_keepalive_probes
  # Note: These settings will be lost upon rebooting your system.
  # Use the following commands to permanently set the SAS recommended TCP/IP settings:
  /sbin/sysctl -w net.ipv4.tcp_fin_timeout=30
  /sbin/sysctl -w net.core.netdev_max_backlog=3000
  /sbin/sysctl -w net.core.somaxconn=3000
  /sbin/sysctl -w net.ipv4.tcp_keepalive_intvl=15
  /sbin/sysctl -w net.ipv4.tcp_keepalive_probes=5
fi


echo $thisHost | grep -q "ss-compute-\|grid-"
if [ $? -eq 0 ]; then
  echo "umask 0022" >>  /home/sas/.bash_profile
  echo ". /mnt/sas/nfs/APPLSF/conf/profile.lsf" >> /home/sas/.bash_profile
fi


# only on grid control server, not on rest of the nodes of grid (ss-compute-2, ss-compute-3...etc)
echo $thisHost | grep -q "ss-compute-1\|grid-1"
if [ $? -eq 0 ]; then
  # Does the user need home dir, shell, password?
  #adduser  -r -s /bin/nologin sassrv -g sas
  adduser sassrv -g sas
  
  echo -e "$sasUserPassword\n$sasUserPassword" | passwd sassrv
 
  # sasdemo
  adduser sasdemo -g sas

  # User lsfadmin.  It is recommended to not create this user, instead use sas user

  # lsfuser
  adduser lsfuser -g sas

  # Create this as root user, since sas doesn't have permission to write to /usr/share
  mkdir -p /usr/share/pm
  chown sas:sas /usr/share/pm
  # Local directory to store pm_install binaries
  mkdir -p /local/pm_install
  chown sas:sas /local/pm_install

##  # Platform Web Services Process Manager
##  echo ". /usr/share/pm/conf/profile.js" >> /home/sas/.bash_profile
fi

 
#currentDefaultTasksMax=`systemctl show --property DefaultTasksMax  | gawk -F= '{ print $2 }'` ; echo $currentDefaultTasksMax

#if [ $currentDefaultTasksMax = "18446744073709551615" ]; then echo "no change"; 
#else 
#  echo "change needed"; 
#  # this change is not effective. Need another solution
#  echo DefaultTasksMax=10240 >> /etc/sysctl.conf
#fi ;

#fsFileMax=`cat /proc/sys/fs/file-max`
#if [ $fsFileMax -ge 65536 ]; then echo "no change"; 
#else 
#  echo "change needed";
#  echo fs.file-max=65536 >> /etc/sysctl.conf
#  sysctl -p
#fi ; 

#echo "*               soft    nproc            10240
#*               hard    nproc             10240
#*               soft    nofile           65536
#*               hard    nofile           65536" >> /etc/security/limits.conf

# The above change is effective on new login session. Hence run the below for current session
#ulimit -n 65536
#ulimit -u 10240 

# does not work - I think this was optional
#sudo -s bash -c "echo -e $sasUserPassword | sudo whoami"

# Does the user need home dir, shell, password?
#adduser  -r -s /bin/nologin sassrv -g sas


# on all nodes
vfabric="/etc/opt/vmware/vfabric/"
mkdir -p $vfabric
chown -R sas $vfabric
chgrp -R sas $vfabric




find_hostnames () {
# Make a list of nodes in the cluster
echo "Doing nslookup for $nodeType nodes"
ct=1
if [ $nodeCount -gt 0 ]; then
        while [ $ct -le $nodeCount ]; do
                nslk=`nslookup $nodeHostnamePrefix${ct}`
                ns_ck=`echo -e $?`
                if [ $ns_ck = 0 ]; then
                        hname=`nslookup $nodeHostnamePrefix${ct} | grep Name | gawk '{print $2}'`
                        echo "$hname" >> /tmp/${nodeType}nodehosts;
                        echo "$hname" >> /tmp/allnodehosts;
                        ct=$((ct+1));
                else
                        # sleep 10 seconds and check again - infinite loop
                        echo "Sleeping for 10 secs and will check again for nslookup $nodeHostnamePrefix${ct}"
                        sleep 10
                fi
        done;
        echo "Found `cat /tmp/${nodeType}nodehosts | wc -l` $nodeType nodes";
        echo `cat /tmp/${nodeType}nodehosts`;
else
        echo "no $nodeType nodes configured"
fi

}

nodeType="grid"
nodeHostnamePrefix=$gridNodeHostnamePrefix
nodeCount=$gridNodeCount
find_hostnames

nodeType="metadata"
nodeHostnamePrefix=$metadataNodeHostnamePrefix
nodeCount=$metadataNodeCount
find_hostnames

nodeType="midtier"
nodeHostnamePrefix=$midTierNodeHostnamePrefix
nodeCount=$midTierNodeCount
find_hostnames


sudo mkdir -p $nfsMountDirectory/SASCFG
sudo mkdir -p $nfsMountDirectory/SASHOME
sudo mkdir -p $nfsMountDirectory/APPLSF
sudo mkdir -p $nfsMountDirectory/SASDEPOT

sasDepotRootPath=${nfsMountDirectory}/SASDEPOT/${sasDepotRoot}
gridSASHome=${nfsMountDirectory}/SASHOME
gridSASConfig=${nfsMountDirectory}/SASCFG

gridSASWork=/sas/SASWORK
gridSASUtilloc=/sas/SASWORK/UTILLOC
metadataSASHome=/sas/SASHOME
midTierSASHome=/sas/SASHOME
metadataSASConfig=/sas/SASCFG
midTierSASConfig=/sas/SASCFG

# Temp workaround:
#planPath=${sasDepotRootPath}/plan_files/plan.xml
planPath=${sasDepotRootPath}/plan.xml

# Find the full path in depot on nfs file system
# moved to nfs.sh to determine the full name of SAS94*.txt
# installationData=${sasDepotRootPath}/sid_files/SAS94_*txt

platformLsf=${nfsMountDirectory}/APPLSF
platformLsfConf=${platformLsf}/conf


#gridControlConfigurationDirectory=${gridSASConfig}/gridctl
# or
#configurationDirectory=${gridSASConfig}/${thisHost}

fqdnHostname=${thisFQDN}
hostname=${thisHost}

metadataServerFqdnHostname=`head -n 1 /tmp/metadatanodehosts`

grdcctlsvrSharedDirPath=${nfsMountDirectory}/GRIDJOB

midTierServerFqdnHostname=`head -n 1 /tmp/midtiernodehosts`

gridControlServerFqdnHostname=`head -n 1 /tmp/gridnodehosts`

echo $thisHost | grep -q "ss-compute-\|grid-"
if [ $? -eq 0 ]; then
  configurationDirectory=${gridSASConfig}/${thisHost}
fi
echo $thisHost | grep -q "metadata-"
if [ $? -eq 0 ]; then
  configurationDirectory=${metadataSASConfig}
fi

echo $thisHost | grep -q "mid-tier-"
if [ $? -eq 0 ]; then
  configurationDirectory=${midTierSASConfig}
fi

echo "sshPublicKey=\"${sshPublicKey}\"" >> /tmp/env_variables.sh
echo "clusterName=$clusterName" >> /tmp/env_variables.sh
echo "sasDepotRootPath=${sasDepotRootPath}" >> /tmp/env_variables.sh
echo "nfsMountDirectory=$nfsMountDirectory" >> /tmp/env_variables.sh
echo "nfsMountDeviceName=${nfsMountDeviceName}" >> /tmp/env_variables.sh

echo "sasUserPassword=\"${sasUserPassword}\"" >> /tmp/env_variables.sh

echo "gridSASHome=$gridSASHome" >> /tmp/env_variables.sh
echo "gridSASConfig=$gridSASConfig" >> /tmp/env_variables.sh

echo "platformLsf=${platformLsf}" >> /tmp/env_variables.sh
echo "platformLsfConf=$platformLsfConf" >> /tmp/env_variables.sh

echo "gridSASWork=${gridSASWork}" >> /tmp/env_variables.sh
echo "gridSASUtilloc=$gridSASUtilloc" >> /tmp/env_variables.sh

echo "metadataSASHome=${metadataSASHome}" >> /tmp/env_variables.sh
echo "midTierSASHome=$midTierSASHome" >> /tmp/env_variables.sh
echo "metadataSASConfig=${metadataSASConfig}" >> /tmp/env_variables.sh
echo "midTierSASConfig=$midTierSASConfig" >> /tmp/env_variables.sh

echo "planPath=${planPath}" >> /tmp/env_variables.sh

# moved to nfs.sh to determine the full name of SAS94*.txt
#echo "installationData=$installationData" >> /tmp/env_variables.sh

echo "grdcctlsvrSharedDirPath=$grdcctlsvrSharedDirPath" >> /tmp/env_variables.sh
echo "configurationDirectory=$configurationDirectory" >> /tmp/env_variables.sh

echo "fqdnHostname=${fqdnHostname}" >> /tmp/env_variables.sh
echo "hostname=$hostname" >> /tmp/env_variables.sh
echo "metadataServerFqdnHostname=${metadataServerFqdnHostname}" >> /tmp/env_variables.sh
echo "midTierServerFqdnHostname=${midTierServerFqdnHostname}" >> /tmp/env_variables.sh
echo "gridControlServerFqdnHostname=$gridControlServerFqdnHostname" >> /tmp/env_variables.sh

# Update bash_profile
echo ". /tmp/env_variables.sh" >> /home/sas/.bash_profile
echo ". /tmp/env_variables.sh" >> /root/.bash_profile
