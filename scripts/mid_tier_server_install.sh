#!/bin/bash
set -x

source /tmp/env_variables.sh

# On all sas nodes
echo "$HOSTNAME"

if ! grep -q "@sas" /etc/security/limits.conf; then
    echo "@sas             hard    nofile         20480" >> /etc/security/limits.conf
    echo "@sas             soft    nofile         20480" >> /etc/security/limits.conf
    echo "@sas             hard    nproc          10240" >> /etc/security/limits.conf
    echo "@sas             soft    nproc          10240" >> /etc/security/limits.conf
fi

if ! grep -q "ulimit" /home/sas/.bash_profile; then
    echo "ulimit -n 20480" >> /home/sas/.bash_profile
    echo "ulimit -u 10240" >> /home/sas/.bash_profile
fi


for file in `ls  /tmp/sdwresponsemidtier0.properties` ;
do
  echo $file
  sed -i  "s| SAS_HOME=.*| SAS_HOME=${midTierSASHome}|g" $file
  sed -i  "s| CUSTOMIZED_PLAN_PATH=.*| CUSTOMIZED_PLAN_PATH=${planPath}|g" $file
  sed -i  "s| SAS_INSTALLATION_DATA=.*| SAS_INSTALLATION_DATA=${installationData}|g" $file
  sed -i  "s| REQUIRED_SOFTWARE_PLATFORMLSF=.*| REQUIRED_SOFTWARE_PLATFORMLSF=${platformLsfConf}|g" $file
  sed -i  "s| CONFIGURATION_DIRECTORY=.*| CONFIGURATION_DIRECTORY=${configurationDirectory}|g" $file
  sed -i  "s| os.localhost.fqdn.host.name=.*| os.localhost.fqdn.host.name=${fqdnHostname}|g" $file
  sed -i  "s| os.localhost.host.name=.*| os.localhost.host.name=${hostname}|g" $file
  sed -i  "s| iomsrv.metadatasrv.host=.*| iomsrv.metadatasrv.host=${metadataServerFqdnHostname}|g" $file
  sed -i  "s| oma.person.admin.login.passwd.internal.as=.*| oma.person.admin.login.passwd.internal.as=${sasUserPassword}|g" $file
  sed -i  "s| oma.person.trustusr.login.passwd.internal.as=.*| oma.person.trustusr.login.passwd.internal.as=${sasUserPassword}|g" $file
  sed -i  "s| oma.person.webanon.login.passwd.internal=.*| oma.person.webanon.login.passwd.internal=${sasUserPassword}|g" $file
  sed -i  "s| webapp.theme.host=.*| webapp.theme.host=${hostname}|g" $file
  sed -i  "s| iomsrv.httpserver.repository.dir=.*| iomsrv.httpserver.repository.dir=${midTierSASConfig}/Lev1/AppData/SASContentServer/Repository|g" $file
  sed -i  "s| webappsrv.dbms.admin.passwd=.*| webappsrv.dbms.admin.passwd=${sasUserPassword}|g" $file
  sed -i  "s| webappsrv.dbms.passwd=.*| webappsrv.dbms.passwd=${sasUserPassword}|g" $file
  sed -i  "s| admappmid.dbms.passwd=.*| admappmid.dbms.passwd=${sasUserPassword}|g" $file
  sed -i  "s| vfabrchyperc.server.admin.passwd.as=.*| vfabrchyperc.server.admin.passwd.as=${sasUserPassword}|g" $file
  sed -i  "s| vfabrchyperc.server.database.password=.*| vfabrchyperc.server.database.password=${sasUserPassword}|g" $file
  sed -i  "s| vfabrchyperc.server.encryption.key=.*| vfabrchyperc.server.encryption.key=${sasUserPassword}|g" $file
  sed -i  "s| evmkitevp.db.passwd=.*| evmkitevp.db.passwd=${sasUserPassword}|g" $file
  sed -i  "s| platformpws.platformlsf.conf.dir=.*| platformpws.platformlsf.conf.dir=${platformLsfConf}|g" $file
  sed -i  "s| platformpws.dbms.passwd=.*| platformpws.dbms.passwd=${sasUserPassword}|g" $file
done

su sas -l << EOF
cd $sasDepotRootPath
./setup.sh -deploy -quiet -responsefile /tmp/sdwresponsemidtier0.properties
exit $?
EOF

if [ $? -ne 0 ]; then
  exit
fi

echo "Review Manual Configuration Instructions"
echo "Manual steps are required to complete your configuration.  You can view these steps in /sas/SASCFG/Lev1/Documents/Instructions.html."

