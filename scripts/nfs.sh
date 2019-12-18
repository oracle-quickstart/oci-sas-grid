

echo "nfsMountDeviceName=$nfsMountDeviceName"
echo "nfsMountDirectory=$nfsMountDirectory"
sudo yum -y install nfs-utils > nfs-utils-install.log
sudo mkdir -p $nfsMountDirectory
sudo mount $nfsMountDeviceName $nfsMountDirectory
sudo mkdir -p $nfsMountDirectory/SASCFG
sudo mkdir -p $nfsMountDirectory/SASHOME
sudo mkdir -p $nfsMountDirectory/APPLSF
sudo mkdir -p $nfsMountDirectory/SASDEPOT
echo "$nfsMountDeviceName               $nfsMountDirectory           nfs  defaults,_netdev        0 0" >> /etc/fstab

sudo chown -R sas:sas /mnt/sas/nfs


# Assumes SASDepot tgz is stored on OCI Obj Storage in a compartment which is set as S3 API compartment in Tenancy details.  eg: compartment: root/internal/bd_team/common
echo $thisHost | grep -q "ss-compute-1\|grid-1"
if [ $? -eq 0 ]; then
  yum install https://dl.fedoraproject.org/pub/epel/7/x86_64/Packages/s/s3fs-fuse-1.85-1.el7.x86_64.rpm -y
  echo 83bd53544431dff354452d9685eb6e810b2c8964:BX0B924rOiaR/uP6/bNtJ6onHNSXZPL86uqi5zdxcyo= > ${HOME}/.passwd-s3fs
  echo "${objectStorageAccessKey}:${objectStorageSecretKey}" > ${HOME}/.passwd-s3fs
  chmod 600 ${HOME}/.passwd-s3fs
  mkdir -p /mnt/oci_object_storage
  chmod 777 -R /mnt/oci_object_storage
# s3fs sas_grid_nfs_data_dump /mnt/oci_object_storage -o endpoint=us-ashburn-1 -o passwd_file=${HOME}/.passwd-s3fs -o url=https://hpc.compat.objectstorage.us-ashburn-1.oraclecloud.com/ -onomultipart -o use_path_request_style
#cp -r /mnt/oci_object_storage/SASDEPOT/SAS_Depot.tgz $nfsMountDirectory/SASDEPOT/
#tar xvzf  $nfsMountDirectory/SASDEPOT/SAS_Depot.tgz -C $nfsMountDirectory/SASDEPOT/
#cp /mnt/oci_object_storage/SASDEPOT/SAS_Depot/sid_files/LSF94_9C59RF_70252045_LINUX_X86-64.txt $nfsMountDirectory/SASDEPOT/SAS_Depot/sid_files/
#cp /mnt/oci_object_storage/SASDEPOT/SAS_Depot/sid_files/SAS94_9C59RF_70252045_LINUX_X86-64.txt $nfsMountDirectory/SASDEPOT/SAS_Depot/sid_files/
#cp /mnt/oci_object_storage/SASDEPOT/SAS_Depot/plan_files/plan.xml $nfsMountDirectory/SASDEPOT/SAS_Depot/plan_files/
#echo "wget $sasDepotDownloadUrl"
  s3fs SAS_Depot_Zip /mnt/oci_object_storage -o endpoint=us-ashburn-1 -o passwd_file=${HOME}/.passwd-s3fs -o url=https://hpc.compat.objectstorage.us-ashburn-1.oraclecloud.com/ -onomultipart -o use_path_request_style
  cp -r /mnt/oci_object_storage/SAS_Depot_9C7Q4X.tgz $nfsMountDirectory/SASDEPOT/
  tar xvzf  $nfsMountDirectory/SASDEPOT/SAS_Depot_9C7Q4X.tgz -C $nfsMountDirectory/SASDEPOT/
#cp /mnt/oci_object_storage/SASDEPOT/SAS_Depot_9C7Q4X/sid_files/LSF94_*.txt $nfsMountDirectory/SASDEPOT/SAS_Depot/sid_files/
#cp /mnt/oci_object_storage/SASDEPOT/SAS_Depot_9C7Q4X/sid_files/SAS94_*.txt $nfsMountDirectory/SASDEPOT/SAS_Depot/sid_files/
  cp /mnt/oci_object_storage/plan.xml $nfsMountDirectory/SASDEPOT/SAS_Depot_9C7Q4X/plan_files/
  chmod 644 -R $nfsMountDirectory/SASDEPOT/SAS_Depot_9C7Q4X/plan_files
  chown sas:sas -R  $nfsMountDirectory/SASDEPOT/SAS_Depot_9C7Q4X/plan_files
  # For some unknown reason even is the plan.xml file is present in the plan_files folder, the install process complains about not found.   Already looked into permissions. However found a workaround.  if I copy the plan.xml file one folder above, then it works.
  cp /mnt/oci_object_storage/plan.xml $nfsMountDirectory/SASDEPOT/SAS_Depot_9C7Q4X/
  chmod 644 $nfsMountDirectory/SASDEPOT/SAS_Depot_9C7Q4X/plan.xml
  chown sas:sas $nfsMountDirectory/SASDEPOT/SAS_Depot_9C7Q4X/plan.xml

  echo "wget $sasDepotDownloadUrl"
fi

while [ ! -f $sasDepotRootPath/sid_files/SAS94*.txt ]
do
  sleep 60s
  echo "Waiting for SAS_Depot tar ball to be extracted on grid contol server..."
done

installationData=`ls $sasDepotRootPath/sid_files/SAS94*.txt`
echo $installationData
echo "installationData=$installationData" >> /tmp/env_variables.sh


sudo chown -R sas:sas /mnt/sas/nfs
touch /tmp/sas_depot_nfs_download.complete

