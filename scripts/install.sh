
echo "Running install.sh"


echo "Got the parameters:"
echo sasUserPassword \'$sasUserPassword\'
echo edition \'$edition\'


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

  echo -e "*               soft nproc 65536\n*               hard nproc 65536\n*               soft nofile 65536\n*               hard nofile 65536" >> /etc/security/limits.conf

  ulimit -n 65536
  ulimit -u 65536
  echo "ulimit -n 65536" >> /home/sas/.bash_profile
  echo "ulimit -u 65536" >> /home/sas/.bash_profile

  #echo DefaultTasksMax=10240 >> /etc/systemd/system.conf
  #systemctl daemon-reexec 
fi


echo $thisHost | grep -q "${midTierNodeHostnamePrefix}\|${gridNodeHostnamePrefix}"
if [ $? -eq 0 ]; then
  echo "Grid/Mid-tier specific configurations"
  echo -e "*               soft nproc 10240\n*               hard nproc 10240\n*               soft nofile 20480\n*               hard nofile 20480" >> /etc/security/limits.conf
  ulimit -n 20480
  ulimit -u 10240
  echo "ulimit -n 20480" >> /home/sas/.bash_profile
  echo "ulimit -u 10240" >> /home/sas/.bash_profile 


  echo DefaultTasksMax=10240 >> /etc/systemd/system.conf
  systemctl daemon-reexec
fi


echo $thisHost | grep -q "mid_tier-"
if [ $? -eq 0 ]; then
  # temporarily set  SAS recommended TCP/IP settings:
  echo 30 > /proc/sys/net/ipv4/tcp_fin_timeout  
  echo 3000 > /proc/sys/net/core/netdev_max_backlog 
  echo 3000 > /proc/sys/net/core/somaxconn 
  echo 15 > /proc/sys/net/ipv4/tcp_keepalive_intvl 
  echo 5 > /proc/sys/net/ipv4/tcp_keepalive_probes
  # set permanently
  /sbin/sysctl -w net.ipv4.tcp_fin_timeout=30
  /sbin/sysctl -w net.core.netdev_max_backlog=3000
  /sbin/sysctl -w net.core.somaxconn=3000
  /sbin/sysctl -w net.ipv4.tcp_keepalive_intvl=15
  /sbin/sysctl -w net.ipv4.tcp_keepalive_probes=5
fi


echo $thisHost | grep -q "${gridNodeHostnamePrefix}"
if [ $? -eq 0 ]; then
  echo "umask 0022" >>  /home/sas/.bash_profile
  #/mnt/sas/nfs/APPLSF/conf/profile.lsf
  echo ". ${lsfHomePath}/conf/profile.lsf" >> /home/sas/.bash_profile
fi


# only on grid control server
echo $thisHost | grep -q "${gridNodeHostnamePrefix}1"
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


sasDepotRootPath=${nfsMountDirectory}/SASDEPOT/${sasDepotRoot}

gridSASHome=${gridSASHomePath}
gridSASConfig=${gridSASConfigPath}
gridSASWork=$sasWorkPath
gridSASUtilloc=$sasWorkPath/UTILLOC
metadataSASHome=$metadataSASHomePath
midTierSASHome=$midTierSASHomePath
metadataSASConfig=$metadataSASConfigPath
midTierSASConfig=$midTierSASConfigPath

#sudo mkdir -p $gridSASConfig
#sudo mkdir -p $gridSASHome
#sudo mkdir -p $lsfHomePath
#sudo mkdir -p $nfsMountDirectory/SASDEPOT


# Temp workaround:
#planPath=${sasDepotRootPath}/plan_files/plan.xml
planPath=${sasDepotRootPath}/plan.xml

platformLsf=${lsfHomePath}
platformLsfConf=${platformLsf}/conf

#gridControlConfigurationDirectory=${gridSASConfig}/gridctl
# or
#configurationDirectory=${gridSASConfig}/${thisHost}

fqdnHostname=${thisFQDN}
hostname=${thisHost}

metadataServerFqdnHostname=`head -n 1 /tmp/metadatanodehosts`

grdcctlsvrSharedDirPath=${gridJobPath}

midTierServerFqdnHostname=`head -n 1 /tmp/midtiernodehosts`

gridControlServerFqdnHostname=`head -n 1 /tmp/gridnodehosts`

echo $thisHost | grep -q "${gridNodeHostnamePrefix}"
if [ $? -eq 0 ]; then
  configurationDirectory=${gridSASConfig}/${thisHost}
fi
echo $thisHost | grep -q "${metadataNodeHostnamePrefix}"
if [ $? -eq 0 ]; then
  configurationDirectory=${metadataSASConfig}
fi

echo $thisHost | grep -q "${midTierNodeHostnamePrefix}"
if [ $? -eq 0 ]; then
  configurationDirectory=${midTierSASConfig}
fi

echo "sshPublicKey=\"${sshPublicKey}\"" >> /tmp/env_variables.sh
echo "clusterName=$clusterName" >> /tmp/env_variables.sh

echo "sasDepotRootPath=${sasDepotRootPath}" >> /tmp/env_variables.sh
echo "sasDepotDownloadUrl=${sasDepotDownloadUrl}" >> /tmp/env_variables.sh
echo "sasDepotDownloadUrlPlanFile=${sasDepotDownloadUrlPlanFile}" >> /tmp/env_variables.sh
echo "sasDepotDownloadUrlLSFLicenseFile=${sasDepotDownloadUrlLSFLicenseFile}" >> /tmp/env_variables.sh
echo "sasDepotDownloadUrlSAS94LicenseFile=${sasDepotDownloadUrlSAS94LicenseFile}" >> /tmp/env_variables.sh

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
