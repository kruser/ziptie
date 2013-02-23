@echo off

set JAVA_OPTIONS=%JAVA_OPTIONS% -DPERL_SERVER=scripts
set JAVA_OPTIONS=%JAVA_OPTIONS% -Xmx512m

rem JAVA_OPTIONS="%JAVA_OPTIONS% -DdebugPerlServer=3" 

java %JAVA_OPTIONS% -jar lib/adapterTool.jar %*
