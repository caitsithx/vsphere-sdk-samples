@echo off
REM you need to set env variable : JAVAHOME, or modify the value here
set SAMPLE_PROPERTIES= -Djava.util.logging.config.file=logging.properties
if NOT DEFINED JAVAHOME (
   echo JAVAHOME not defined. Must be defined to run java apps.
   goto END
)

setlocal

:SETENV
set LOCALCLASSPATH=lib\ssosamples.jar;lib\ssoclient.jar;lib\vim25.jar

:NEXT
if [%1]==[] goto ARGEND
   set ARG=%ARG% %1
   shift
   goto NEXT
:ARGEND

:DORUN
"%JAVAHOME%"\bin\java %SAMPLE_PROPERTIES% -cp "%LOCALCLASSPATH%" -Xmx1024M %ARG%

:END
endlocal
echo Done.