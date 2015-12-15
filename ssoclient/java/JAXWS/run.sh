#!/bin/sh

## you need to set env variable : JAVAHOME, or modify the value here

export SAMPLE_PROPERTIES=" -Djava.util.logging.config.file=logging.properties"
if [ "x${JAVAHOME}" = "x" ]
then
   echo JAVAHOME not defined. Must be defined to run java apps.
   exit
fi

export PATH=${JAVAHOME}/bin:${PATH}
LOCALCLASSPATH=${PWD}/lib/ssosamples.jar:${PWD}/lib/ssoclient.jar:${PWD}/lib/vim25.jar

exec ${JAVAHOME}/bin/java ${SAMPLE_PROPERTIES} -classpath ${LOCALCLASSPATH} -Xmx1024M "$@"

echo Done.