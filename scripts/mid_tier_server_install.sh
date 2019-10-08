#!/bin/bash
set -x

source /tmp/env_variables.sh
for file in `ls /tmp/sdwresponsemidtier*.properties*` ;
do
  echo $file
  sed -i  "s| SAS_HOME=.*| SAS_HOME=${midTierSASHome}|g" $file
  sed -i  "s| CUSTOMIZED_PLAN_PATH=.*| CUSTOMIZED_PLAN_PATH=${planPath}|g" $file
  sed -i  "s| SAS_INSTALLATION_DATA=.*| SAS_INSTALLATION_DATA=${installationData}|g" $file
  sed -i  "s| REQUIRED_SOFTWARE_PLATFORMLSF=.*| REQUIRED_SOFTWARE_PLATFORMLSF=${platformLsf}|g" $file
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
  sed -i  "s| platformpws.platformlsf.conf.dir=.*| platformpws.platformlsf.conf.dir=${gridSASAppLsf}|g" $file
  sed -i  "s| platformpws.dbms.passwd=.*| platformpws.dbms.passwd=${sasUserPassword}|g" $file
done

# source /tmp/env_variables.sh
# clusterName=
# sasDepotRoot=/SASDEPOT/SAS_Depot_9C7Q4X
# nfsMountDirectory=
# nfsMountDeviceName=
# gridSASHome=/SASHOME
# sasUserPassword='*=?<qCr3QeMIv'
# gridSASConfig=/SASCFG
# gridSASAppLsf=/APPLSF
# gridSASAppLsfConfig=/APPLSF/config
# gridSASWork=/sas/SASWORK
# gridSASUtilloc=/sas/SASWORK/UTILLOC
# metadataSASHome=/sas/SASHOME
# midTierSASHome=/sas/SASHOME
# metadataSASConfig=/sas/SASCFG
# midTierSASConfig=/sas/SASCFG
# planPath=/SASDEPOT/SAS_Depot_9C7Q4X/plan_files/plan.xml
# installationData='/SASDEPOT/SAS_Depot_9C7Q4X/sid_files/SAS94_*txt'
# platformLsf=/APPLSF/conf
# gridControlConfigDirectory=
# configurationDirectory=/SASCFG/mid-tier-1
# fqdnHostname=mid-tier-1.privateb0.sas.oraclevcn.com
# hostname=mid-tier-1
# metadataServerFqdnHostname=metadata-1.privateb0.sas.oraclevcn.com
# grdcctlsvrSharedDirPath=/GRIDJOB
# midTierServerFqdnHostname=mid-tier-1.privateb0.sas.oraclevcn.com
# gridControlServerFqdnHostname=grid-1.privateb0.sas.oraclevcn.com
# sasDepotRoot=/SASDEPOT/SAS_Depot_9C7Q4X
