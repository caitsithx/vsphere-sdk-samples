@echo off
echo Building vSphere web service SDK samples.....

if exist lib\wssamples.jar (
  del /q/f lib\wssamples.jar >nul 2>nul
)

echo Adding ssoclient.jar.....
xcopy/y/q/i/s ..\..\..\ssoclient\java\JAXWS\lib\ssoclient.jar lib || goto ERROR

echo Adding ssosamples.jar.....
if not exist ..\..\..\ssoclient\java\JAXWS\lib\ssosamples.jar (
	echo Missing ssosamples.jar... Trigerring the ssoclient build to generate one.
	pushd ..\..\..\ssoclient\java\JAXWS || goto ERROR
	call build.bat || goto ERROR
	popd
)
xcopy/y/q/i/s ..\..\..\ssoclient\java\JAXWS\lib\ssosamples.jar lib || goto ERROR

set LOCALCLASSPATH=%CD%\lib;
for %%i in ("lib\*.jar") do call lcp.bat %CD%\%%i
cd samples
@rem find all *.java files
dir *.java /b/s > java_src.txt

echo Compiling samples
javac -classpath "%LOCALCLASSPATH%" @java_src.txt || goto ERROR

echo Jarring samples
jar cf ..\lib\wssamples.jar com\vmware\alarms\*.class com\vmware\cim\*.class com\vmware\cim\helpers\*.class com\vmware\connection\*.class com\vmware\connection\helpers\*.class com\vmware\connection\helpers\builders\*.class com\vmware\events\*.class com\vmware\general\*.class com\vmware\guest\*.class com\vmware\host\*.class com\vmware\httpfileaccess\*.class com\vmware\performance\*.class com\vmware\performance\widgets\*.class com\vmware\scheduling\*.class com\vmware\scsilun\*.class com\vmware\security\credstore\*.class com\vmware\simpleagent\*.class com\vmware\storage\*.class com\vmware\vapp\*.class com\vmware\vm\*.class || goto ERROR

echo Generating javadocs for samples
javadoc -J-Xms512m -J-Xmx512m -classpath "%LOCALCLASSPATH%" -d ..\..\..\docs\java\JAXWS\samples\javadoc -public -windowtitle "VMware vSphere Web Services SDK JAXWS Java Samples Documentation" -doctitle "<html><body>VMware vSphere Web Services SDK JAXWS Java Samples Reference Documentation<a name=topofpage></a>" -overview ..\..\..\docresources\vsphere-ws-jaxws-samples-overview.html -nohelp -subpackages com.vmware -exclude com.vmware.vim25:com.vmware.common:com.vmware.samples:javax.wbem.client:javax.cim || goto ERROR

del /q/f java_*.txt >nul 2>nul
del /s/q/f *.class >nul 2>nul
cd ..

goto EOF

:ERROR
@echo FAILED
@exit /b 1

:EOF
