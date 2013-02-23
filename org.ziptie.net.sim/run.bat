@echo off

rem Uncomment this next line to enable debuging
rem set DEBUG=-Xdebug -Xrunjdwp:transport=dt_socket,address=8000,server=y,suspend=n

java %DEBUG% -XX:MaxPermSize=128m -Xms256m -Xmx1g -jar sim.jar %1 %2 %3 %4 %5
