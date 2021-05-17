#!/bin/bash
set -x

source /tmp/env_variables.sh

thisFQDN=`hostname --fqdn`
thisHost=${thisFQDN%%.*}

echo $thisHost | grep -q "${gridNodeHostnamePrefix}"
if [ $? -eq 0 ]; then
  echo "grid nodes..."

  consolidate_file="/tmp/consolidated_configure_grid_node.sh"
cat > $consolidate_file << EOF
#!/bin/bash
set -x
sudo /usr/libexec/oci-growfs -y | egrep 'NOCHANGE:|CHANGED:'

source /tmp/env_variables.sh

EOF


  cat /tmp/firewall.sh >> $consolidate_file
  cat /tmp/install.sh >> $consolidate_file
  cat /tmp/grid_disks.sh >> $consolidate_file
  cat /tmp/x11_setup.sh >> $consolidate_file
  #cat /tmp/load_install_data.sh >> $consolidate_file
  #echo "touch /tmp/sas_depot_nfs_download.complete" >> $consolidate_file
  cat /tmp/grid.sh >> $consolidate_file
  echo "touch /tmp/cloud_init.complete" >> $consolidate_file

  sudo chmod +x $consolidate_file

fi


echo $thisHost | grep -q "${metadataNodeHostnamePrefix}"
if [ $? -eq 0 ]; then
  echo "metadata nodes..."

  consolidate_file="/tmp/consolidated_configure_metadata_node.sh"
cat > $consolidate_file << EOF
#!/bin/bash
set -x
sudo /usr/libexec/oci-growfs -y | egrep 'NOCHANGE:|CHANGED:'

source /tmp/env_variables.sh

EOF

  cat /tmp/firewall.sh >> $consolidate_file
  cat /tmp/install.sh >> $consolidate_file
  cat /tmp/metadata_disks.sh >> $consolidate_file
  cat /tmp/x11_setup.sh >> $consolidate_file
  #cat /tmp/load_install_data.sh >> $consolidate_file
  echo "touch /tmp/cloud_init.complete" >> $consolidate_file

  sudo chmod +x $consolidate_file

fi



echo $thisHost | grep -q "${midTierNodeHostnamePrefix}"
if [ $? -eq 0 ]; then
  echo "mid_tier nodes..."

  consolidate_file="/tmp/consolidated_configure_mid_tier_node.sh"
cat > $consolidate_file << EOF
#!/bin/bash
set -x
sudo /usr/libexec/oci-growfs -y | egrep 'NOCHANGE:|CHANGED:'

source /tmp/env_variables.sh

EOF

  cat /tmp/firewall.sh >> $consolidate_file
  cat /tmp/install.sh >> $consolidate_file
  cat /tmp/mid_tier_disks.sh >> $consolidate_file
  cat /tmp/x11_setup.sh >> $consolidate_file
  #cat /tmp/load_install_data.sh >> $consolidate_file
  echo "touch /tmp/cloud_init.complete" >> $consolidate_file

  sudo chmod +x $consolidate_file

fi

