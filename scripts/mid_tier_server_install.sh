#!/bin/bash
set -x

source /tmp/env_variables.sh
sed -i .bak "s| SAS_HOME=.*| SAS_HOME=${midTierSASHome}|g" sdwresponsemidtier0.properties
sed -i .bak "s| CUSTOMIZED_PLAN_PATH=.*| CUSTOMIZED_PLAN_PATH=${planPath}|g" sdwresponsemidtier0.properties
sed -i .bak "s| SAS_INSTALLATION_DATA=.*| SAS_INSTALLATION_DATA=${installationData}|g" sdwresponsemidtier0.properties
sed -i .bak "s| REQUIRED_SOFTWARE_PLATFORMLSF=.*| REQUIRED_SOFTWARE_PLATFORMLSF=${platformLsf}|g" sdwresponsemidtier0.properties
sed -i .bak "s| CONFIGURATION_DIRECTORY=.*| CONFIGURATION_DIRECTORY=${configurationDirectory}|g" sdwresponsemidtier0.properties
sed -i .bak "s| os.localhost.fqdn.host.name=.*| os.localhost.fqdn.host.name=${fqdnHostname}|g" sdwresponsemidtier0.properties
sed -i .bak "s| os.localhost.host.name=.*| os.localhost.host.name=${hostname}|g" sdwresponsemidtier0.properties
sed -i .bak "s| iomsrv.metadatasrv.host=.*| iomsrv.metadatasrv.host=${metadataServerFqdnHostname}|g" sdwresponsemidtier0.properties
sed -i .bak "s| oma.person.admin.login.passwd.internal.as=.*| oma.person.admin.login.passwd.internal.as=${sasUserPassword}|g" sdwresponsemidtier0.properties
sed -i .bak "s| oma.person.trustusr.login.passwd.internal.as=.*| oma.person.trustusr.login.passwd.internal.as=${sasUserPassword}|g" sdwresponsemidtier0.properties
sed -i .bak "s| oma.person.webanon.login.passwd.internal=.*| oma.person.webanon.login.passwd.internal=${sasUserPassword}|g" sdwresponsemidtier0.properties
sed -i .bak "s| webapp.theme.host=.*| webapp.theme.host=${hostname}|g" sdwresponsemidtier0.properties
sed -i .bak "s| iomsrv.httpserver.repository.dir=.*| iomsrv.httpserver.repository.dir=${midTierSASConfig}/Lev1/AppData/SASContentServer/Repository|g" sdwresponsemidtier0.properties
sed -i .bak "s| webappsrv.dbms.admin.passwd=.*| webappsrv.dbms.admin.passwd=${sasUserPassword}|g" sdwresponsemidtier0.properties
sed -i .bak "s| webappsrv.dbms.passwd=.*| webappsrv.dbms.passwd=${sasUserPassword}|g" sdwresponsemidtier0.properties
sed -i .bak "s| admappmid.dbms.passwd=.*| admappmid.dbms.passwd=${sasUserPassword}|g" sdwresponsemidtier0.properties
sed -i .bak "s| vfabrchyperc.server.admin.passwd.as=.*| vfabrchyperc.server.admin.passwd.as=${sasUserPassword}|g" sdwresponsemidtier0.properties
sed -i .bak "s| vfabrchyperc.server.database.password=.*| vfabrchyperc.server.database.password=${sasUserPassword}|g" sdwresponsemidtier0.properties
sed -i .bak "s| vfabrchyperc.server.encryption.key=.*| vfabrchyperc.server.encryption.key=${sasUserPassword}|g" sdwresponsemidtier0.properties
sed -i .bak "s| evmkitevp.db.passwd=.*| evmkitevp.db.passwd=${sasUserPassword}|g" sdwresponsemidtier0.properties
sed -i .bak "s| platformpws.platformlsf.conf.dir=.*| platformpws.platformlsf.conf.dir=${gridSASAppLsf}|g" sdwresponsemidtier0.properties
sed -i .bak "s| platformpws.dbms.passwd=.*| platformpws.dbms.passwd=${sasUserPassword}|g" sdwresponsemidtier0.properties
