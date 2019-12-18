#!/bin/bash
set -x

source /tmp/env_variables.sh

mkdir -p ${gridSASConfig}/${hostname}
chown sas:sas ${gridSASConfig}/${hostname}

echo "$HOSTNAME"

if ! grep -q "@sas" /etc/security/limits.conf; then
    echo "@sas             hard    nofile         20480" >> /etc/security/limits.conf
    echo "@sas             soft    nofile         20480" >> /etc/security/limits.conf
    echo "@sas             hard    nproc          20480" >> /etc/security/limits.conf
    echo "@sas             soft    nproc          20480" >> /etc/security/limits.conf
fi
if ! grep -q "ulimit" /home/sas/.bash_profile; then
    echo "ulimit -n 20480" >> /home/sas/.bash_profile
    echo "ulimit -u 20480" >> /home/sas/.bash_profile
fi


for file in `ls /tmp/sdwresponsegridnoden.properties.* ` ;
do
echo $file
  sed -i   "s| SAS_HOME=.*| SAS_HOME=${gridSASHome}|g" $file
  sed -i   "s| CUSTOMIZED_PLAN_PATH=.*| CUSTOMIZED_PLAN_PATH=${planPath}|g" $file
  sed -i   "s| SAS_INSTALLATION_DATA=.*| SAS_INSTALLATION_DATA=${installationData}|g" $file
  sed -i   "s| REQUIRED_SOFTWARE_PLATFORMLSF=.*| REQUIRED_SOFTWARE_PLATFORMLSF=${platformLsfConf}|g" $file
  sed -i   "s| CONFIGURATION_DIRECTORY=.*| CONFIGURATION_DIRECTORY=${configurationDirectory}|g" $file
  sed -i   "s| os.localhost.fqdn.host.name=.*| os.localhost.fqdn.host.name=${fqdnHostname}|g" $file
  sed -i   "s| os.localhost.host.name=.*| os.localhost.host.name=${hostname}|g" $file
  sed -i   "s| iomsrv.metadatasrv.host=.*| iomsrv.metadatasrv.host=${metadataServerFqdnHostname}|g" $file
  sed -i   "s| oma.person.admin.login.passwd.internal.as=.*| oma.person.admin.login.passwd.internal.as=${sasUserPassword}|g" $file
  sed -i   "s| hyperagntc.agent.setup.camIP=.*| hyperagntc.agent.setup.camIP=${midTierServerFqdnHostname}|g" $file
  sed -i   "s| hyperagntc.admin.passwd.as=.*| hyperagntc.admin.passwd.as=${sasUserPassword}|g" $file
done


su sas -l << EOF
cd $sasDepotRootPath
./setup.sh -deploy -quiet -responsefile /tmp/sdwresponsegridnoden.properties.install
exit $?
EOF

if [ $? -ne 0 ]; then
  exit
fi

su root -l << EOF
${gridSASHome}/SASFoundation/9.4/utilities/bin/setuid.sh
exit $?
EOF

if [ $? -ne 0 ]; then
  exit
fi


su sas -l << EOF
cd $sasDepotRootPath
./setup.sh -deploy -quiet -responsefile /tmp/sdwresponsegridnoden.properties.config
exit $?
EOF

if [ $? -ne 0 ]; then
  exit
fi
