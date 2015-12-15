@setlocal
@echo off

IF NOT EXIST docs\java\JAXWS\samples\javadoc (
   mkdir docs\java\JAXWS\samples\javadoc || goto ERROR
)

echo Adding vim25.jar.....
IF NOT EXIST ..\..\..\vsphere-ws\java\JAXWS\lib\vim25.jar (
	echo Missing vim25.jar... Trigerring the vsphere stub generator build to generate one.
	pushd ..\..\..\vsphere-ws\java\JAXWS || goto ERROR
	call build.bat -s || goto ERROR
	popd
)
xcopy/y/q/i/s ..\..\..\vsphere-ws\java\JAXWS\lib\vim25.jar lib || goto ERROR

echo compiling samples.....
mkdir samples\output || goto ERROR
dir /S /B samples\*.java > fileList.txt
javac -classpath lib\ssoclient.jar;lib\vim25.jar -d samples\output @fileList.txt || goto ERROR

echo Generating compiled samples jar.....
jar cf lib\ssosamples.jar -C samples\output/ . || goto ERROR

echo Cleaning up.....
del fileList.txt >nul 2>nul
del /s/q samples\output\* >nul 2>nul
rmdir/s/q samples\output
echo Generating javadocs.....
pushd samples || goto ERROR
javadoc -J-Xms512m -J-Xmx512m -d ..\docs\java\JAXWS\samples\javadoc -public -windowtitle "vCenter Single Sign-On Client Java Samples Documentation" -doctitle "<html><body>vCenter Single Sign-On Client Java Samples Reference Documentation<a name=topofpage></a>" -nohelp -subpackages com.vmware >nul 2>nul || goto ERROR
popd
echo Build complete.....
@echo on

goto EOF

:ERROR
@echo FAILED
@endlocal
@exit /b 1

:EOF
@endlocal