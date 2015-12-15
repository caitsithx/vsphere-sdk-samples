#!/bin/sh

## You need to set env variables : JAVA_HOME,
## or modify the value here

export SAMPLEDIR=./samples
export SAMPLEJARDIR=${PWD}/lib

if [ "x${JAVA_HOME}" = "x" ]
then
   echo JAVA_HOME not defined. Must be defined to build java apps.
   exit
fi

if [ "x${1}" != "x-w" ]
then
   export WSDLFILE25=../../../wsdl/vim25/vimService.wsdl
   export WSDLLOCATION25=vimService.wsdl
fi

export PATH="${JAVA_HOME}/bin:${PATH}"

./clean.sh ${1}

cd samples

if [ "x${1}" != "x-w" ]
then
   echo Generating vim25 stubs from wsdl

   if [ -d "com/vmware/vim25" ]
   then
      rm -rf com/vmware/vim25
   fi
   mkdir -p com/vmware/vim25
   cp -f ../../../wsdl/vim25/*.* com/vmware/vim25/

   ${JAVA_HOME}/bin/java -Xmx512m \
       -classpath ${JAVA_HOME}/lib/tools.jar com.sun.tools.internal.ws.WsImport \
       -wsdllocation ${WSDLLOCATION25} -p com.vmware.vim25 -s . ${WSDLFILE25}

   #echo fix VimService
   ## fix VimService class to get the wsdl from the vim25.jar
   ${JAVA_HOME}/bin/java -Xmx128m -classpath ${CLASSPATH}:${SAMPLEJARDIR} FixJaxWsWsdlResource ./com/vmware/vim25/VimService.java VimService

   find ./com/vmware/vim25 -depth -name '*.java' -print > vim25_src.txt
   echo Done generating vim25 stubs. Compiling vim25 stubs.
   ${JAVA_HOME}/bin/javac -J-Xms1024M -J-Xmx1024M -classpath ${CLASSPATH}:${SAMPLEJARDIR} @vim25_src.txt

   find ./com/vmware/vim25 -depth -name '*.class' -print > vim25_class.txt
   ${JAVA_HOME}/bin/jar cf ${SAMPLEJARDIR}/vim25.jar @vim25_class.txt com/vmware/vim25/*.wsdl com/vmware/vim25/*.xsd

   rm -f com/vmware/vim25/*.wsdl com/vmware/vim25/*.xsd
   rm -f vim25_src.txt vim25_class.txt

   echo Done compiling vim25 stubs.
fi

## allow for only compiling stub code, without regenerating java stub files
if [ "x${2}" = "x-c" ]
then
   echo Compiling vim25 stubs

   find ./com/vmware/vim25 -depth -name '*.java' -print > vim25_src.txt
   echo Done generating vim25 stubs. Compiling vim25 stubs.
   ${JAVA_HOME}/bin/javac -J-Xms1024M -J-Xmx1024M -classpath ${CLASSPATH}:${SAMPLEJARDIR} @vim25_src.txt

   find ./com/vmware/vim25 -depth -name '*.class' -print > vim25_class.txt
   ${JAVA_HOME}/bin/jar cf ${SAMPLEJARDIR}/vim25.jar @vim25_class.txt com/vmware/vim25/*.wsdl com/vmware/vim25/*.xsd

   rm -f com/vmware/vim25/*.wsdl com/vmware/vim25/*.xsd
   rm -f vim25_src.txt vim25_class.txt

   echo Done compiling vim25 stubs
fi


if [ ! -f "../../../../ssoclient/java/JAXWS/lib/ssosamples.jar" ]; then
    ../../../../ssoclient/java/JAXWS/build.sh
fi

if [ ! -f lib/ssoclient.jar ]; then
    echo copying ssoclient.jar
    cp ../../../../ssoclient/java/JAXWS/lib/ssoclient.jar ${SAMPLEJARDIR}
fi

if [ ! -f lib/ssosamples.jar ]; then
    echo copying ssosamples.jar
    cp ../../../../ssoclient/java/JAXWS/lib/ssosamples.jar ${SAMPLEJARDIR} 
fi

echo Compiling samples

find ./com/vmware -depth -name '*.java' -print > files_src.txt
${JAVA_HOME}/bin/javac -J-Xms256M -J-Xmx256M -classpath ${CLASSPATH}:$(echo ${SAMPLEJARDIR}/*.* | tr ' ' ':')  @files_src.txt
find ./com/vmware -depth -name '*.class' -print | grep -v "/examples/" | grep -v "/vim25/" > files_classes.txt
${JAVA_HOME}/bin/jar cf ${SAMPLEJARDIR}/wssamples.jar @files_classes.txt

#echo fix javadoc Generation
echo Generating javadocs for samples
${JAVA_HOME}/bin/javadoc -J-Xms512m -J-Xmx512m -classpath ${CLASSPATH}:$(echo ${SAMPLEJARDIR}/*.* | tr ' ' ':') -d ../../../docs/java/JAXWS/samples/javadoc -public -windowtitle "VMware vSphere Web Services SDK JAXWS Java Samples Documentation" -doctitle "<html><body>VMware vSphere Web Services SDK JAXWS Java Samples Reference Documentation<a name=topofpage></a>" -overview ../../../docresources/vsphere-ws-jaxws-samples-overview.html -nohelp -subpackages com.vmware -exclude com.vmware.vim25:com.vmware.common:com.vmware.samples:javax.wbem.client:javax.cim

rm files_classes.txt
rm files_src.txt
find ./com/vmware -depth -name '*.class' -type f -exec rm -f {} \;
rm -rf ./com/vmware/vim25

cd ..

echo Done.
