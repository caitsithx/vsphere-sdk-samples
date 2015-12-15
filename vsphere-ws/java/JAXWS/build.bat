@setlocal
@echo off
if NOT DEFINED JAVA_HOME (
   if NOT DEFINED JAVAHOME (
       echo JAVA_HOME not defined. Must be defined to build java apps.
       goto ERROR
   ) else (
       set JAVA_HOME=%JAVAHOME%
   )
)

set PATH="%JAVA_HOME%"\bin;%PATH%

if "x%1" == "x/?" (
echo build.bat command line options
echo no parameters - full compilation
echo -s generate and compile only the client stubs
echo -w compile the client application without re-generating the client stubs
)

if "x%1" == "x" (
echo Building vim25 stubs and samples...
call build_vim25.bat || goto ERROR
call build_samples.bat || goto ERROR
)

if "x%1" == "x-s" (
echo Only building vim25 Stubs...
call build_vim25.bat || goto ERROR
)

if "x%1" == "x-w" (
echo Only building samples...
call build_samples.bat || goto ERROR
)

@echo on
goto EOF

:ERROR
@echo FAILED
@endlocal
@exit /b 1

:EOF
@endlocal