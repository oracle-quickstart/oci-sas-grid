
echo "Running disks.sh"


# iscsiadm discovery/login
# loop over various ip's but needs to only attempt disks that actually
# do/will exist.
if [ $gridDiskCount -gt 0 ] ;
then
  echo "Number of disks gridDiskCount: $gridDiskCount"
  for n in `seq 2 $((gridDiskCount+1))`; do
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
  echo "Zero block volumes, not calling iscsiadm, gridDiskCount: $gridDiskCount"
fi

# logic added to ensure all /dev/sd* devices are available, sometime it takes a few seconds
iscsiDiskCount=`ls /dev/ | grep -ivw 'sda' | grep -ivw 'sda[1-3]' | grep -iw 'sd[b-z]' | wc -l `
while [ $iscsiDiskCount -lt $gridDiskCount ]; do
  sleep 5s;
  iscsiDiskCount=`ls /dev/ | grep -ivw 'sda' | grep -ivw 'sda[1-3]' | grep -iw 'sd[b-z]' | wc -l`
done;

# For mounting BV devices
if [ $gridDiskCount -gt 0 ] ;
then
  dcount=0
  index=-1
  bcount=`ls /dev/ | grep -ivw 'sda' | grep -ivw 'sda[1-3]' | grep -iw 'sd[b-z]' | wc -l `
  echo "bcount=$bcount"
# Added this logic, to ensure all required Bvolumes are available as /dev/sd* before proceding
while [ $bcount -lt $gridDiskCount ] ; do
  sleep 10s
  bcount=`ls /dev/ | grep -ivw 'sda' | grep -ivw 'sda[1-3]' | grep -iw 'sd[b-z]' | wc -l `
  echo "bcount=$bcount"
done;

  v=`ls /dev/ | grep -ivw 'sda' | grep -ivw 'sda[1-3]' | grep -iw 'sd[b-z]' `
  echo "v=$v"
  for disk in `ls /dev/ | grep -ivw 'sda' | grep -ivw 'sda[1-3]' | grep -iw 'sd[b-z]' `; do
    echo -e "\nProcessing /dev/$disk"
    device="/dev/$disk"

 
  echo "Creating filesystem and mounting on ..."
  mke2fs -F -t ext4 -b 4096 -E lazy_itable_init=1 -O sparse_super,dir_index,extent,has_journal,uninit_bg -m1 $device
  if [ $dcount -eq 0 ]; then
    # BVol based SASCFG and SASHOME are not required on grid nodes.
    mountDirs="/sas/SASCFG"
    mkdir -p $mountDirs
  fi
  
  if [ $dcount -eq 1 ]; then
    # BVol based SASCFG and SASHOME are not required on grid nodes.
    mountDirs="/sas/SASHOME"
    mkdir -p $mountDirs
  fi

  mount -t ext4 -o noatime $device $mountDirs
  UUID=$(lsblk -no UUID $device)
  echo "UUID=$UUID   $mountDirs    ext4   defaults,noatime,_netdev,nofail,discard,barrier=0 0 1" | sudo tee -a /etc/fstab

    dcount=$((dcount+1))
    index=$((index+1))
    mountDirs=""
    device=""
  done;
  echo "$dcount disk found"
else
  echo "No filesystem to create, skipping"
fi


mount_saswork () {

echo "Creating filesystem and mounting on ..."

mountDirs="${sasWorkPath}"
mkdir -p $mountDirs



if [ $diskCount -eq 1 ]; then
  echo "device=$device will be used for SASWORK"
else
  device_list="/dev/nvme[0-$((diskCount-1))]n1"
  device="/dev/md/SASWORK"
  mountDirs="${sasWorkPath}"
  raid_level="raid0"
  echo -e "RAID level of $raid_level for $diskCount disk ."
  echo "DEVICE $device_list" >  /etc/mdadm.conf
  echo "ARRAY ${device} devices=$device_list" >> /etc/mdadm.conf
  mdadm -C ${device} --level=$raid_level --raid-devices=$dcount $device_list

  #set readahead for RAID volumes - /dev/md/SASWORK
  blockdev --setra $READAHEAD $device
fi

# For RHEL/CentOS 6.x - EXT4 is recommended.
# mke2fs -F -t ext4 -b 4096 -E lazy_itable_init=1 -O sparse_super,dir_index,extent,has_journal,uninit_bg -m1 $device
# For RHEL/CentOS 7.x - XFS is recommended.
mkfs.xfs -b size=4096 $device
#mount -t ext4 -o noatime $device $mountDirs
mount -t xfs -o noatime $device $mountDirs
UUID=$(lsblk -no UUID $device)
echo "UUID=$UUID   $mountDirs    xfs   defaults,noatime,_netdev,nofail,discard,barrier=0 0 1" | sudo tee -a /etc/fstab
#echo "UUID=$UUID   $mountDirs    ext4   defaults,noatime,_netdev,nofail,discard,barrier=0 0 1" | sudo tee -a /etc/fstab

}

READAHEAD=16384
yum install mdadm -y -q

#setup noop for scheduler and set read ahead for all volumes.
for disk in `ls /dev/ | grep nvme | grep n1 | sort`; do echo "none" > /sys/block/$disk/queue/scheduler; done
for disk in `ls /dev/ | grep nvme | grep n1 | sort`; do blockdev --setra $READAHEAD /dev/$disk; done
#disable transparent_hugepage
echo never > /sys/kernel/mm/transparent_hugepage/enabled



  # For mounting nvme devices
  dcount=0
  index=-1
  diskCount=`ls /dev/ | grep nvme | grep n1 | sort | wc -l `
  for disk in ` ls /dev/ | grep nvme | grep n1 | sort `; do
    echo -e "\nProcessing /dev/$disk"
    device="/dev/$disk"
    if [ $diskCount -ge 2 ]; then
      echo "wait to loop through all disk"
    else
      mount_saswork
    fi


    dcount=$((dcount+1))
    index=$((index+1))
    mountDirs=""
    device=""
  done;
echo "$dcount nvme found"

if [ $diskCount -ge 2 ]; then
  mount_saswork
fi


# BVol based SASCFG and SASHOME are not required on grid nodes.
chown -R sas:sas  /sas/SASCFG /sas/SASHOME /sas/*

chown -R sas:sas  ${sasWorkPath}/../*

# Create UTILLOC as sub-directory under SASWORK as per SAS recommendation: http://support.sas.com/resources/papers/proceedings16/SAS6761-2016.pdf
mkdir -p ${sasWorkPath}/UTILLOC
