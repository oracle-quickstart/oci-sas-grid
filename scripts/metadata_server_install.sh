#!/bin/bash
set -x

# On all sas nodes
echo "$HOSTNAME"

if ! grep -q "@sas" /etc/security/limits.conf; then
    echo "@sas             hard    nofile         20480" >> /etc/security/limits.conf
    echo "@sas             soft    nofile         20480" >> /etc/security/limits.conf
    echo "@sas             hard    nproc          20480" >> /etc/security/limits.conf
    echo "@sas             soft    nproc          20480" >> /etc/security/limits.conf
fi

#if ! grep -q "SASFoundation" /etc/profile; then
#    echo ". $gridSASAppLsf/conf/profile.lsf" >> /etc/profile
#    echo 'export PATH=$PATH:$metadataSASHome/SASFoundation/9.4' >> /etc/profile
#fi

if ! grep -q "ulimit" /home/sas/.bash_profile; then
    echo "ulimit -n 20480" >> /home/sas/.bash_profile
    echo "ulimit -u 20480" >> /home/sas/.bash_profile
fi


source /tmp/env_variables.sh
for file in `ls /tmp/sdwresponsemeta.properties*` ;
do
  echo $file
  sed -i   "s| SAS_HOME=.*| SAS_HOME=${metadataSASHome}|g" $file
  sed -i   "s| CUSTOMIZED_PLAN_PATH=.*| CUSTOMIZED_PLAN_PATH=${planPath}|g" $file
  sed -i   "s| SAS_INSTALLATION_DATA=.*| SAS_INSTALLATION_DATA=${installationData}|g" $file
  sed -i   "s| CONFIGURATION_DIRECTORY=.*| CONFIGURATION_DIRECTORY=${configurationDirectory}|g" $file
  sed -i   "s| os.localhost.fqdn.host.name=.*| os.localhost.fqdn.host.name=${fqdnHostname}|g" $file
  sed -i   "s| os.localhost.host.name=.*| os.localhost.host.name=${hostname}|g" $file
  sed -i   "s| iomsrv.metadatasrv.host=.*| iomsrv.metadatasrv.host=${metadataServerFqdnHostname}|g" $file
  sed -i   "s| oma.person.installer.login.passwd=.*| oma.person.installer.login.passwd=${sasUserPassword}|g" $file
  sed -i   "s| oma.person.admin.login.passwd.internal.ms=.*| oma.person.admin.login.passwd.internal.ms=${sasUserPassword}|g" $file
  sed -i   "s| oma.person.trustusr.login.passwd.internal.ms=.*| oma.person.trustusr.login.passwd.internal.ms=${sasUserPassword}|g" $file
  sed -i   "s| hyperagntc.agent.setup.camIP=.*| hyperagntc.agent.setup.camIP=${hostname}|g" $file
  sed -i   "s| hyperagntc.admin.passwd=.*| hyperagntc.admin.passwd=${sasUserPassword}|g" $file
done

exit 0

su sas -l << EOF
cd $sasDepotRoot
./setup.sh -deploy -quiet -responsefile /tmp/sdwresponsemeta.properties.install
exit
EOF

su root -l << EOF
$gridSASHome/SASFoundation/9.4/utilities/bin/setuid.sh
exit
EOF

su sas -l << EOF
cd $sasDepotRoot
./setup.sh -deploy -quiet -responsefile /tmp/sdwresponsemeta.properties.config
exit
EOF

