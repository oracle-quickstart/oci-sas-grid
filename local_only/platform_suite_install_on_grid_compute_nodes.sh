
NOT USED IN AUTOMATION

sudo su -l

[root@ss-compute-2 ~]# history 
LSF_TOP="/mnt/sas/nfs/APPLSF"
cd $LSF_TOP/10.1/install 
./hostsetup --top="$LSF_TOP" --boot="y" --profile="y" --start="y"
ps -ef | grep $LSF_TOP 

# run the 2 commands as root on grid control server
lsadmin reconfig
badmin reconfig
