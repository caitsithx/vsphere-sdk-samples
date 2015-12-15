#!/bin/sh

## you need to set env variables : JAVA_HOME, or modify the 2 values here

export SAMPLE_PROPERTIES=" -Dsamples.trustAll=true -Djava.util.logging.config.file=logging.properties"
export SAMPLEDIR=.

if [ "x${JAVA_HOME}" = "x" ]
then
   if [ "x${JAVAHOME}" = "x" ]
   then
      echo JAVA_HOME not defined. Must be defined to run java apps.
      exit
   fi
   export JAVA_HOME="${JAVAHOME}"
fi

export PATH=${JAVA_HOME}/bin:${PATH}

LOCALCLASSPATH=${PWD}/lib/vim25.jar

exec ${JAVA_HOME}/bin/java ${SAMPLE_PROPERTIES} -cp $(echo lib/*.jar | tr ' ' ':') -Xmx1024M com.vmware.common.Main "$@"
