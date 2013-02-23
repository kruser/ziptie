#!/bin/sh
#
#  usage:  server [-console]
#

JAVA_OPTIONS="$JAVA_OPTIONS -server"
JAVA_OPTIONS="$JAVA_OPTIONS -Xmx512m"
JAVA_OPTIONS="$JAVA_OPTIONS -XX:MaxPermSize=128m"
JAVA_OPTIONS="$JAVA_OPTIONS -Djava.io.tmpdir=tmp"
JAVA_OPTIONS="$JAVA_OPTIONS -Dderby.system.home=derby"
JAVA_OPTIONS="$JAVA_OPTIONS -Djava.awt.headless=true"
JAVA_OPTIONS="$JAVA_OPTIONS -Djava.library.path=/usr/lib:/usr/lib/jni:/usr/local/lib:/usr/local/lib/jni"
if [ "$1" = "-debug" ]
then
    JAVA_OPTIONS="$JAVA_OPTIONS -Xdebug -Xrunjdwp:transport=dt_socket,address=8787,server=y,suspend=n"
elif [ "$1" = "-debugw" ]
then
    JAVA_OPTIONS="$JAVA_OPTIONS -Xdebug -Xrunjdwp:transport=dt_socket,address=8787,server=y,suspend=y"
fi

if [ "$1" = "-profile" ]
then
    export DYLD_LIBRARY_PATH=/Applications/jprofiler5/bin/macos
    JAVA_OPTIONS="$JAVA_OPTIONS -XX:-UseSharedSpaces -Xrunjprofiler:port=8849  -Xbootclasspath/a:/Applications/jprofiler5/bin/agent.jar"
fi

OSGI_OPTIONS="$OSGI_OPTIONS -Dosgi.configuration.area=osgi-config"
OSGI_OPTIONS="$OSGI_OPTIONS -Dosgi.noShutdown=true"
OSGI_OPTIONS="$OSGI_OPTIONS -Dosgi.install.area=./"

# org.eclipse.equinox.http.jetty.ssl.password
# org.eclipse.equinox.http.jetty.ssl.needclientauth=false
# org.eclipse.equinox.http.jetty.ssl.wantclientauth=false
# org.eclipse.equinox.http.jetty.ssl.protocol
# org.eclipse.equinox.http.jetty.ssl.algorithm
# org.eclipse.equinox.http.jetty.ssl.keystoretype
# org.eclipse.equinox.http.jetty.context.path

echo Starting with Java options: $JAVA_OPTIONS
echo Starting with OSGi options: $OSGI_OPTIONS
echo Starting with arguments: $1 $2 $3 $4

java $JAVA_OPTIONS $OSGI_OPTIONS -jar core/org.eclipse.osgi_3.3.1.R33x_v20070828.jar -clean -consoleLog $1 $2 $3 $4
