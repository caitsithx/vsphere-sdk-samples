@echo off
@REM you need to set env variables : JAVA_HOME, or modify the 2 values here
set SAMPLE_PROPERTIES= -Dsamples.trustAll=true -Djava.util.logging.config.file=logging.properties
set SAMPLEDIR=.

if NOT DEFINED JAVA_HOME (
   if NOT DEFINED JAVAHOME (
       @echo JAVA_HOME not defined. Must be defined to build java apps.
       goto END
   )
   else (
       set JAVA_HOME=%JAVAHOME%
   )
)

setlocal

:SETENV

set PATH=%JAVA_HOME%\bin;%PATH%
set LOCALCLASSPATH=%CD%\lib;%WBEMHOME%;

for %%i in ("lib\*.jar") do call lcp.bat %CD%\%%i

set LOCALCLASSPATH=%LOCALCLASSPATH%;%CLASSPATH%

:next

if [%1]==[] goto argend
   set ARG=%ARG% %1
   shift
   goto next
:argend

:DORUN

"%JAVA_HOME%"\bin\java %SAMPLE_PROPERTIES% -cp "%LOCALCLASSPATH%" -Xmx1024M com.vmware.common.Main %ARG%

endlocal

:END
echo Done.
