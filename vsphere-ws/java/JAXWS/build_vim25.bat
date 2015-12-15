if NOT DEFINED WSDLNAME set WSDLNAME=vimService.wsdl
if NOT DEFINED WSDLPATH set WSDLPATH=..\..\wsdl\vim25

IF EXIST samples\com\vmware\vim25 (
  rmdir/s/q samples\com\vmware\vim25 >nul 2>nul
)
echo "Creating samples\com\vmware\vim25 directory"
mkdir samples\com\vmware\vim25 || goto ERROR

IF EXIST lib\vim25.jar (
  del /q/f lib\vim25.jar >nul 2>nul
)

echo Copying the wsdl files
xcopy /q/i/s "%WSDLPATH%\*" samples\com\vmware\vim25\ || goto ERROR

echo Generating vim25 stubs from wsdl
wsimport -wsdllocation "%WSDLNAME%" -p com.vmware.vim25 -s samples\ "%WSDLPATH%\%WSDLNAME%" -Xnocompile || goto ERROR

@rem fix VimService class to get the wsdl from the vim25.jar
echo Applying the FixJaxWsWsdlResource to VimService.java
java -classpath lib\ FixJaxWsWsdlResource "%CD%\samples\com\vmware\vim25\VimService.java" VimService|| goto ERROR

echo Compiling vim25 Stubs
javac samples\com\vmware\vim25\*.java || goto ERROR

echo Jarring vim25 Stubs
cd samples
jar cf "..\lib\vim25.jar" com\vmware\vim25\*.class com\vmware\vim25\*.wsdl com\vmware\vim25\*.xsd || goto ERROR
cd..

echo Cleaning generated code
del /q/f samples\com\vmware\vim25\*.wsdl >nul 2>nul
del /q/f samples\com\vmware\vim25\*.xsd >nul 2>nul
del /q/f samples\com\vmware\vim25\*.class >nul 2>nul

echo Done generating vim25 stubs from wsdl

goto EOF

:ERROR
@echo FAILED
@exit /b 1

:EOF