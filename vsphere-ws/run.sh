#!/bin/sh

## you need to set env variables : JAVA_HOME, or modify the 2 values here

export SAMPLE_PROPERTIES=" -Dsamples.trustAll=true -Djava.util.logging.config.file=java/JAXWS/logging.properties -DvimService.url=https://10.112.113.154:/sdk/vim -Dconnection.username= -Dconnection.password="
export SAMPLEDIR=/Users/admin/dev/vsphere-sdk/SDK/vsphere-ws


exec ~/Tools/jdk-1.7.0_76/Contents/Home/bin/java ${SAMPLE_PROPERTIES} -cp $(echo ${SAMPLEDIR}/target/lib/*.jar | tr ' ' ':'):${SAMPLEDIR}/target/vsphere-ws-6.0.jar -Xmx1024M com.vmware.common.Main "$@"
