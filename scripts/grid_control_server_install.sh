#!/bin/bash
set -x

echo "$HOSTNAME"

source /tmp/env_variables.sh

mkdir -p ${gridSASConfig}/${hostname}
mkdir -p ${nfsMountDirectory}/GRIDJOB
chown sas:sas ${gridSASConfig}/${hostname}
chown sas:sas ${nfsMountDirectory}/GRIDJOB

for file in `ls /tmp/sdwresponsegridcontrol.properties.*` ;
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
  sed -i   "s| oma.person.trustusr.login.passwd.internal.as=.*| oma.person.trustusr.login.passwd.internal.as=${sasUserPassword}|g" $file
  sed -i   "s| oma.person.gensrvusr.login.passwd=.*| oma.person.gensrvusr.login.passwd=${sasUserPassword}|g" $file
  sed -i   "s| iomsrv.webinfdsvrc.host=.*| iomsrv.webinfdsvrc.host=${hostname}|g" $file
  sed -i   "s| iomsrv.webinfdsvrc.passwd=.*| iomsrv.webinfdsvrc.passwd=${sasUserPassword}|g" $file
  sed -i   "s| server.grdcctlsvr.shared.dir.path=.*| server.grdcctlsvr.shared.dir.path=${grdcctlsvrSharedDirPath}|g" $file
  sed -i   "s| server.platformpm.host=.*| server.platformpm.host=${hostname}|g" $file
  sed -i   "s| hyperagntc.agent.setup.camIP=.*| hyperagntc.agent.setup.camIP=${midTierServerFqdnHostname}|g" $file
  sed -i   "s| hyperagntc.admin.passwd.as=.*| hyperagntc.admin.passwd.as=${sasUserPassword}|g" $file
done

su sas -l << EOF
cd $sasDepotRootPath
./setup.sh -deploy -quiet -responsefile /tmp/sdwresponsegridcontrol.properties.install
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
./setup.sh -deploy -quiet -responsefile /tmp/sdwresponsegridcontrol.properties.config
exit $?
EOF

if [ $? -ne 0 ]; then
  exit
fi
