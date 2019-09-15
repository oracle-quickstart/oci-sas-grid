#!/bin/bash
set -x

echo "$HOSTNAME"

#sudo -u root bash << EOF
#cd /sas
#mkdir SASHome config metadata
#chmod 755 SASHome config metadata
#chown sasinst:sas SASHome config metadata
#rm -Rf SASHome/* config/* metadata/*
#pkill -U sasinst
#exit
#EOF


source /tmp/env_variables.sh

for file in `ls /tmp/sdwresponsegridcontrol.properties.*  ` ;
do
echo $file
sed -i   "s| SAS_HOME=.*| SAS_HOME=${gridSASHome}|g" $file
sed -i   "s| CUSTOMIZED_PLAN_PATH=.*| CUSTOMIZED_PLAN_PATH=${planPath}|g" $file
sed -i   "s| SAS_INSTALLATION_DATA=.*| SAS_INSTALLATION_DATA=${installationData}|g" $file
sed -i   "s| REQUIRED_SOFTWARE_PLATFORMLSF=.*| REQUIRED_SOFTWARE_PLATFORMLSF=${platformLsf}|g" $file
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
sed -i   "s| hyperagntc.agent.setup.camIP=.*| hyperagntc.agent.setup.camIP=${metadataServerFqdnHostname}|g" $file
sed -i   "s| hyperagntc.admin.passwd.as=.*| hyperagntc.admin.passwd.as=${sasUserPassword}|g" $file
done


su sas -l << EOF
cd $sasDepotRoot
./setup.sh -deploy -quiet -responsefile /tmp/sdwresponsegridcontrol.properties.install
exit
EOF

su root -l << EOF
$gridSASHome/SASFoundation/9.4/utilities/bin/setuid.sh
exit
EOF

# . /sas/lsf/conf/profile.lsf
# . /mnt/sas/nfs/APPLSF/conf/profile.lsf
su sas -l << EOF
cd $sasDepotRoot
. $gridSASAppLsf/conf/profile.lsf
./setup.sh -deploy -quiet -responsefile /tmp/sdwresponsegridcontrol.properties.config
# ./setup.sh -deploy -quiet -responsefile /sas/quickstart/playbooks/templates/studio_config.txt
exit
EOF

su root -l << EOF
echo "-WORK $gridSASWork" >> $gridSASHome/SASFoundation/9.4/nls/en/sasv9.cfg
. $gridSASAppLsf/conf/profile.lsf
$gridSASHome/SASFoundation/9.4/utilities/bin/setuid.sh
. $gridSASHome/studioconfig/sasstudio.sh start
exit
EOF
