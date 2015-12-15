#!/bin/sh

## You need to set env variables : JAVA_HOME,
## or modify the value here

export SAMPLEDIR=./samples
export SAMPLEJARDIR=${PWD}/lib

if [ "x${JAVA_HOME}" = "x" ]
then
   echo "JAVA_HOME not defined. Must be defined to build java apps."
   exit
fi
export PATH="${JAVA_HOME}/bin:${PATH}"

if [ ! -d docs/java/JAXWS/samples/javadoc ]
then
    mkdir -p docs/java/JAXWS/samples/javadoc
fi

if [ ! -f ../../../vsphere-ws/java/JAXWS/lib/vim25.jar ]
then
    echo "Missing vim25.jar... Trigerring the vsphere stub generator build to generate one."
    pushd ../../../vsphere-ws/java/JAXWS/
    ./build.sh -j
    popd
fi
cp -f ../../../vsphere-ws/java/JAXWS/lib/vim25.jar ./lib/

echo "compiling samples..."

mkdir -p samples/output
cd samples

find . -depth -name '*.java' -print > files_src.txt
export SAMPLES_CLASSPATH=$(echo ${SAMPLEJARDIR}/*.* | tr ' ' ':')
if [ "x${CLASSPATH}" != "x" ]; then
    export SAMPLES_CLASSPATH=$CLASSPATH:$SAMPLES_CLASSPATH
fi

${JAVA_HOME}/bin/javac -J-Xms256M -J-Xmx256M -classpath ${SAMPLES_CLASSPATH} @files_src.txt
find . -depth -name '*.class' -print | grep -v "/vim25/" > files_classes.txt

${JAVA_HOME}/bin/jar cf ${SAMPLEJARDIR}/ssosamples.jar @files_classes.txt

rm files_classes.txt
rm files_src.txt

find . -depth -name '*.class' -type f -exec rm -f {} \;

cd ..

echo "Done."
