#!/bin/sh

# Uncomment this next line to enable debuging
# DEBUG="-Xdebug -Xrunjdwp:transport=dt_socket,address=8000,server=y,suspend=n"

java $DEBUG -XX:MaxPermSize=128m -Xms256m -Xmx1g -jar sim.jar
