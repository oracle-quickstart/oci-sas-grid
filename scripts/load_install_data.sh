#!/bin/bash
set -x

thisFQDN=`hostname --fqdn`
thisHost=${thisFQDN%%.*}


source /tmp/env_variables.sh

echo "sharedStorageGridNodesFsType=$sharedStorageGridNodesFsType"
echo "mountDeviceName=$mountDeviceName"
echo "mountDirectory=$mountDirectory"

if [ "$sharedStorageGridNodesFsType" == "gpfs" ]; then
  df -h | grep -q $mountDirectory
  if [ $? -eq 0 ]; then
    echo "shared file system already mounted"
  else
    echo "shared file system mount missing"
    exit 1;
  fi
elif [ "$sharedStorageGridNodesFsType" == "fss" ]; then
  sudo yum -y install nfs-utils > nfs-utils-install.log
  df -h | grep -q $mountDirectory
  if [ $? -eq 0 ]; then
    echo "shared file system already mounted"
  else
    sudo mkdir -p $mountDirectory
    sudo mount -t nfs $mountDeviceName $mountDirectory
    echo "$mountDeviceName    $mountDirectory    nfs  defaults,_netdev        0 0" >> /etc/fstab
  fi
elif [ "$sharedStorageGridNodesFsType" == "lustre" ]; then
  df -h | grep -q $mountDirectory
  if [ $? -eq 0 ]; then
    echo "shared file system already mounted"
  else
    sudo mkdir -p $mountDirectory
    sudo mount -t lustre $mountDeviceName $mountDirectory
    echo "$mountDeviceName  $mountDirectory  defaults,_netdev,x-systemd.automount,x-systemd.requires=lnet.service 0 0" >> /etc/fstab
  fi
else
  echo "invalid value - $sharedStorageGridNodesFsType"
  exit 1;
fi


#sudo chown -R sas:sas $mountDirectory


echo $thisHost | grep -q "${gridNodeHostnamePrefix}1"
if [ $? -eq 0 ]; then

  # These can be created only after the mount of shared file system
  sudo mkdir -p $gridSASConfig
  sudo mkdir -p $gridSASHome
  sudo mkdir -p $lsfHomePath
  sudo mkdir -p $mountDirectory/SASDEPOT


  echo "downloading depot to shared file system"
  cd $mountDirectory/SASDEPOT/
  
  sasDepotFilename=`basename $sasDepotDownloadUrl`
  if [ ! -f $sasDepotFilename ]; then
  
    curl -O $sasDepotDownloadUrl -s
    while [ $? -ne 0 ]; do
      sasDepotFilename=`basename $sasDepotDownloadUrl`
      rm -rf $sasDepotFilename
      curl -O $sasDepotDownloadUrl -s
    done

    curl -O $sasDepotDownloadUrlPlanFile
    curl -O $sasDepotDownloadUrlLSFLicenseFile
    curl -O $sasDepotDownloadUrlSAS94LicenseFile

    sasDepotFilename=`basename $sasDepotDownloadUrl`
    sasDepotPlanFilename=`basename $sasDepotDownloadUrlPlanFile`
    sasDepotLSFLicenseFilename=`basename $sasDepotDownloadUrlLSFLicenseFile`
    sasDepotSAS94LicenseFilename=`basename $sasDepotDownloadUrlSAS94LicenseFile`

    # SAS_Depot_9C7Q4X.tgz
    tarOptions="$mountDirectory/SASDEPOT/$sasDepotFilename -C $mountDirectory/SASDEPOT/ --exclude=${sasDepotRoot}/sid_files/LSF94_*.txt --exclude=${sasDepotRoot}/sid_files/SAS94_*.txt"
    tar xvzf $tarOptions
    while [ $? -ne 0 ]; do
      rm -rf ${sasDepotRoot}
      tar xvzf $tarOptions
    done

    cp $sasDepotPlanFilename $mountDirectory/SASDEPOT/${sasDepotRoot}/plan_files/
    chmod 644 -R $mountDirectory/SASDEPOT/${sasDepotRoot}/plan_files
    chown sas:sas -R  $mountDirectory/SASDEPOT/${sasDepotRoot}/plan_files
    # For some unknown reason even is the plan.xml file is present in the plan_files folder, the install process complains about not found.   Already looked into permissions. However found a workaround.  if I copy the plan.xml file one folder above, then it works.
    cp $sasDepotPlanFilename $mountDirectory/SASDEPOT/${sasDepotRoot}/
    chmod 644 $mountDirectory/SASDEPOT/${sasDepotRoot}/plan.xml
    chown sas:sas $mountDirectory/SASDEPOT/${sasDepotRoot}/plan.xml

    cp $sasDepotSAS94LicenseFilename $sasDepotRootPath/sid_files/
    cp $sasDepotLSFLicenseFilename $sasDepotRootPath/sid_files/

  fi
  cd -

fi

while [ ! -f $sasDepotRootPath/sid_files/SAS94*.txt ]
do
  sleep 60s
  echo "Waiting for SAS_Depot tar ball to be extracted on grid contol server..."
done

installationData=`ls $sasDepotRootPath/sid_files/SAS94*.txt`
echo $installationData
echo "installationData=$installationData" >> /tmp/env_variables.sh


sudo chown -R sas:sas $mountDirectory
touch /tmp/sas_depot_nfs_download.complete

