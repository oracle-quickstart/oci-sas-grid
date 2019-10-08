
echo "Running disks.sh"

# iscsiadm discovery/login
# loop over various ip's but needs to only attempt disks that actually
# do/will exist.
if [ $midTierDiskCount -gt 0 ] ;
then
  echo "Number of disks midTierDiskCount: $midTierDiskCount"
  for n in `seq 2 $((midTierDiskCount+1))`; do
    echo "Disk $((n-2)), attempting iscsi discovery/login of 169.254.2.$n ..."
    success=1
    while [[ $success -eq 1 ]]; do
      iqn=$(iscsiadm -m discovery -t sendtargets -p 169.254.2.$n:3260 | awk '{print $2}')
      if  [[ $iqn != iqn.* ]] ;
      then
        echo "Error: unexpected iqn value: $iqn"
        sleep 10s
        continue
      else
        echo "Success for iqn: $iqn"
        success=0
      fi
    done
    iscsiadm -m node -o update -T $iqn -n node.startup -v automatic
    iscsiadm -m node -T $iqn -p 169.254.2.$n:3260 -l
  done
else
  echo "Zero block volumes, not calling iscsiadm, midTierDiskCount: $midTierDiskCount"
fi

# logic added to ensure all /dev/sd* devices are available, sometime it takes a few seconds
iscsiDiskCount=`ls /dev/ | grep -ivw 'sda' | grep -ivw 'sda[1-3]' | grep -iw 'sd[b-z]' | wc -l `
while [ $iscsiDiskCount -lt $midTierDiskCount ]; do
  sleep 5s;
  iscsiDiskCount=`ls /dev/ | grep -ivw 'sda' | grep -ivw 'sda[1-3]' | grep -iw 'sd[b-z]' | wc -l`
done;


if [ $midTierDiskCount -gt 0 ] ;
then
  dcount=0
  index=-1
  for disk in `ls /dev/ | grep -ivw 'sda' | grep -ivw 'sda[1-3]' | grep -iw 'sd[b-z]' `; do
    echo -e "\nProcessing /dev/$disk"
    device="/dev/$disk"

 
  echo "Creating filesystem and mounting on ..."
  mke2fs -F -t ext4 -b 4096 -E lazy_itable_init=1 -O sparse_super,dir_index,extent,has_journal,uninit_bg -m1 $device
  if [ $dcount -eq 0 ]; then
    mountDirs="/sas/SASCFG"
    mkdir -p $mountDirs
  fi
  
  if [ $dcount -eq 1 ]; then
    mountDirs="/sas/SASHOME"
    mkdir -p $mountDirs
  fi

  if [ $dcount -ge 2 ]; then
    echo "We only need 2 Block volumes, more than 2 are attached"
  else
    mount -t ext4 -o noatime $device $mountDirs
    UUID=$(lsblk -no UUID $device)
    echo "UUID=$UUID   $mountDirs    ext4   defaults,noatime,_netdev,nofail,discard,barrier=0 0 1" | sudo tee -a /etc/fstab
  fi
    dcount=$((dcount+1))
    index=$((index+1))
    mountDirs=""
    device=""
  done;
  echo "$dcount disk found"
else
  echo "No filesystem to create, skipping"
fi


# change ownership to sas user
chown -R sas:sas  /sas/SASCFG
chown -R sas:sas  /sas/SASHOME
chown -R sas:sas  /sas/*



  # For mounting nvme devices
  dcount=0
  index=-1
  for disk in ` ls /dev/ | grep nvme | grep n1 | sort `; do
    echo -e "\nProcessing /dev/$disk"
    device="/dev/$disk"


    echo "Creating filesystem and mounting on ..."
    mke2fs -F -t ext4 -b 4096 -E lazy_itable_init=1 -O sparse_super,dir_index,extent,has_journal,uninit_bg -m1 $device
    mountDirs="/sas/$disk"
    mkdir -p $mountDirs

    mount -t ext4 -o noatime $device $mountDirs
    UUID=$(lsblk -no UUID $device)
    echo "UUID=$UUID   $mountDirs    ext4   defaults,noatime,_netdev,nofail,discard,barrier=0 0 1" | sudo tee -a /etc/fstab

    dcount=$((dcount+1))
    index=$((index+1))
    mountDirs=""
    device=""
  done;
  echo "$dcount nvme found"

# change ownership to sas user
chown -R sas:sas  /sas/SASCFG
chown -R sas:sas  /sas/SASHOME
chown -R sas:sas  /sas/*

