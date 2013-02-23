@echo off
@setlocal

set JAVA_OPTIONS=%JAVA_OPTIONS% -server
set JAVA_OPTIONS=%JAVA_OPTIONS% -Xmx512m
set JAVA_OPTIONS=%JAVA_OPTIONS% -XX:MaxPermSize=128m
set JAVA_OPTIONS=%JAVA_OPTIONS% -Djava.io.tmpdir=tmp
set JAVA_OPTIONS=%JAVA_OPTIONS% -Dderby.system.home=derby
rem set JAVA_OPTIONS=%JAVA_OPTIONS% -Xdebug -Xrunjdwp:transport=dt_socket,address=8787,server=y,suspend=y

rem Set up JProfiler options
if [%1] == [-profile] (
	set PATH=%PATH%;C:\Program Files\jprofiler5\bin\windows
	set JAVA_OPTIONS=%JAVA_OPTIONS% -XX:-UseSharedSpaces -agentlib:jprofilerti=port=8849  "-Xbootclasspath/a:C:\Program Files\jprofiler5\bin\agent.jar"
)

set OSGI_OPTIONS=%OSGI_OPTIONS% -Dosgi.configuration.area=osgi-config
set OSGI_OPTIONS=%OSGI_OPTIONS% -Dosgi.noShutdown=true
set OSGI_OPTIONS=%OSGI_OPTIONS% -Dosgi.install.area=./

echo Starting with Java options: %JAVA_OPTIONS%
echo Starting with OSGi options: %OSGI_OPTIONS%
echo Starting with arguments: %1 %2 %3 %4

java %JAVA_OPTIONS% %OSGI_OPTIONS% -jar core/org.eclipse.osgi_3.3.1.R33x_v20070828.jar -clean -consoleLog %1 %2 %3 %4
