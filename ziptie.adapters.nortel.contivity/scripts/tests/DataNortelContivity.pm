package DataNortelContivity;

use strict;
use warnings;
use Exporter 'import';
our @EXPORT_OK = qw($responsesContivity);

our $responsesContivity = {};

$responsesContivity->{flash} = <<'END';
show flash contents

Flash Header - copyright: Nortel Networks, Copyright 1999-2005

               tag:       NOC

               version:   1

               length:    959

               count:     19

Flash Data - 

model number: CES0600D

MAC address: 00-09-97-75-78-24

serial number: 10597

feature keys:

     Maximum Ethernet ports: 3

     Maximum T-1 ports: 1

     Maximum T-3 ports: 1

     Allow PPTP tunnels: True

     Allow L2F tunnels: True

     Allow L2TP tunnels: True

     Allow IPsec tunnels: True

     Allow QoS internal: True

     Allow QoS admission: True

     Allow RSVP: True

     Allow RADIUS authentication: True

     Allow LDAP authentication: True

     Allow NT Domain authentication: True

     Allow RSA encryption: True

     Allow SSL: True

     Allow X.509 certificates: True

     Allow RADIUS accounting: True

     CPU clock rate 300 MHz

     CPU cache size 128 KB

     Number of CPUs supported: 1

     Allow IPX: True

     Allow NAT: True

     Firewall: Disabled

     Allow External LDAP authentication: True

     Maximum Hifn Accelerators: 0 (this value is not used !)

     FIPS Mode: False

     Allow Safe Mode Boot: False

     SERVER_FARM Mode: False

     Serial Driver Controlled Crash: Disabled

Flash Revision: 1

key length: 128

Boot Device: /ide0/

maximum concurrent sessions: flash: 50 runtime: 50

primary backup host: :

host username: 

system IP netmask: 255.255.255.0

system IP address: 10.100.27.4

system default gateway: 10.100.27.1

checksum: 54204

CES#

END

$responsesContivity->{snmp_identity} = <<'END';
show snmp identity

  SysDescr	CES V06_00.310

  SysObjectID	01.03.06.01.04.01.2505.600

  SysName  	Contivity

  SysContact	gfarris

  SysLocation	Planet Earth

CES#

END

$responsesContivity->{version} = <<'END';
show version


System Up Time

Up Time:                 21:31:49


System Configuration

Software Version:        V06_00.310

Software Build Date:     Nov 18 2005, 18:22:05

System Serial Number:    10597

MAC Address:             00-09-97-75-78-24

BIOS Version:            PO3


Hardware Configuration

Processor 1:   Celeron 300 Mhz, L1D Cache:16K, L1I Cache:16K, L2 Cache:128K

Memory:        63 MB Free, 128 MB Total

Hard Disk 0:   1832 MB Free, 2146 MB Total

Diskette:      Virtual

CES#

END

$responsesContivity->{hosts} = <<'END';
show hosts


Management IP Address: 10.100.27.4

        DNS Host Name: NYC-Contivity

      DNS Domain Name: alterpoint.com

   DNS Server Address

              primary: 0.0.0.0

            secondary: 0.0.0.0

             tertiary: 0.0.0.0

               fourth: 0.0.0.0

CES#

END

$responsesContivity->{interfaces} = <<'END';
show status statistics interfaces interfaces
Date 11/30/2007  Time 20:43:15
lo (unit number 0, index 1):
     Flags: (0x00008069) UP LOOPBACK MULTICAST ARP RUNNING
     ifp: 0x1e7ae00, trusted: 1, devLoc: 0x0, devType: 6, devSubType: 0
                   dlCtxtPtr: 0x0, circuitMapping: 0x0
     Internet address: 127.0.0.1
     Netmask 0xff000000 Subnetmask 0xffffff80
     IPX is disabled
     Metric is 0
     Maximum Transfer Unit size is 1788
     5604 packets received; 5604 packets sent
     0 multicast packets received
     0 multicast packets sent
     0 input errors; 0 output errors
     0 collisions; 0 dropped
fei (unit number 0, index 2):
     Flags: (0x00008063) UP BROADCAST MULTICAST ARP RUNNING
     ifp: 0x1c28c18, trusted: 1, devLoc: 0x100, devType: 2, devSubType: 25
                   dlCtxtPtr: 0x6c808e8, circuitMapping: 0x7e2ad90
     Internet address: 10.100.27.5
     Broadcast address: 10.100.27.255
     Netmask 0xff000000 Subnetmask 0xffffff00
     IPX is disabled
     TCP MSS is disabled
     Ethernet address is 00:09:97:75:78:24
     Metric is 0
     Maximum Transfer Unit size is 1500
     27732 packets received; 13761 packets sent
     11 multicast packets received
     0 multicast packets sent
     0 input errors; 0 output errors
     0 collisions; 0 dropped
fei (unit number 1, index 3):
     Flags: (0x00008022) DOWN BROADCAST MULTICAST ARP
     ifp: 0x1c2917c, trusted: 0, devLoc: 0x101, devType: 2, devSubType: 25
                   dlCtxtPtr: 0x6c80c30, circuitMapping: 0x0
     IPX is disabled
     TCP MSS is disabled
     Ethernet address is 00:09:97:75:78:25
     Metric is 0
     Maximum Transfer Unit size is 1500
     0 packets received; 0 packets sent
     0 multicast packets received
     0 multicast packets sent
     0 input errors; 0 output errors
     0 collisions; 0 dropped
clip (unit number 0, index 4):
     Flags: (0x00000021) UP ARP
     ifp: 0x6bb439c, trusted: 1, devLoc: 0x0, devType: 8, devSubType: 0
                   dlCtxtPtr: 0x0, circuitMapping: 0x56450a0
     Internet address: 10.100.27.4
     Netmask 0xffffffff Subnetmask 0x0
     IPX is disabled
     TCP MSS is disabled
     Ethernet address is 00:00:00:00:40:8e
     Metric is 0
     Maximum Transfer Unit size is 1500
     0 packets received; 0 packets sent
     0 multicast packets received
     0 multicast packets sent
     0 input errors; 0 output errors
     0 collisions; 0 dropped
CES#

END

$responsesContivity->{routes} = <<'END';
show ip route
Protocol IP Address      Mask            Cost Next Hop        Interface
------------------------------------------------------------------------
STATIC   0.0.0.0         0.0.0.0         [10] 10.100.27.1     10.100.27.5
DIRECT_N 10.100.27.0     255.255.255.0   [0]  10.100.27.5     10.100.27.5
MGMT     10.100.27.4     255.255.255.255 [0]  127.0.0.1       127.0.0.1
DIRECT_H 10.100.27.5     255.255.255.255 [0]  127.0.0.1       127.0.0.1
Total route(s) 4
CES#

END

$responsesContivity->{'running-config'} = <<'END';
show running-config

! !!! no license AR

! !!! no license FW

! !!! no license DW

! !!! no license BG

! !!! no license PR

adminname testlab epassword "VtLZh7/Nups="

serial-banner ""

no serial-banner enable

idle-timeout 00:15:00

no idle-timeout enable

default language English

no aaa authentication administrator ldap-server

no aaa authentication administrator radius

ip address 10.100.27.4

ip domain-name alterpoint.com

hostname NYC-Contivity

dns-proxy enable

no split-dns enable

no clip enable

audible alarm

clock set 14:34:31 Nov 30 2007

clock timezone GMT

no ntp

no ntp broadcast server

no ntp multicast server

no qos bandwidth-management enable

no qos admission-control enable

qos bandwidth-rates  14400

qos bandwidth-rates  28800

qos bandwidth-rates  56000

qos bandwidth-rates  128000

qos bandwidth-rates  256000

qos bandwidth-rates  512000

qos bandwidth-rates  1000000

qos bandwidth-rates  5000000

interface Fastethernet 0/1

no qos egress-dscp-map

no qos Ingress-dscp-map

no qos shaping-state enable

qos shaping  0

qos over-subscription-ratio  10

qos non-tunnel-traffic-ratio  0

no qos mf-class enable

no qos traffic-conditioning enable

qos ingress-traffic-conditioning EF 0

qos ingress-traffic-conditioning AF4 0

qos ingress-traffic-conditioning AF3 0

qos ingress-traffic-conditioning AF2 0

qos ingress-traffic-conditioning AF1 0

qos egress-traffic-conditioning ef-shaping-rate 0

qos egress-queuing-mode legacy

exit

interface Fastethernet 1/1

no qos egress-dscp-map

no qos Ingress-dscp-map

no qos shaping-state enable

qos shaping  0

qos over-subscription-ratio  10

qos non-tunnel-traffic-ratio  0

no qos mf-class enable

no qos traffic-conditioning enable

qos ingress-traffic-conditioning EF 0

qos ingress-traffic-conditioning AF4 0

qos ingress-traffic-conditioning AF3 0

qos ingress-traffic-conditioning AF2 0

qos ingress-traffic-conditioning AF1 0

qos egress-traffic-conditioning ef-shaping-rate 0

qos egress-queuing-mode legacy

exit

filter tunnel rule "deny all/in"

port "any" 0

port "dns" 53

port "dynamic port begin" 1023

port "Entrust CA" 829

port "finger" 79

port "ftp" 21

port "ftp-data" 20

port "gopher" 70

port "http" 80

port "laplink" 1547

port "ldap" 389

port "nbdatagram" 138

port "nbname" 137

port "nbsession" 139

port "nntp" 119

port "ntp" 123

port "pcANYWHERE/data" 5631

port "pcANYWHERE/stat" 5631

port "pop2" 109

port "pop3" 110

port "portmap" 111

port "smtp" 25

port "snmp" 161

port "snmp-trap" 162

port "telnet" 23

port "wais" 210

port "whois" 43

protocol "icmp" 1

protocol "ip" 255

protocol "tcp" 6

protocol "udp" 17

address "any" ip 0.0.0.0 mask 255.255.255.255

address "FtpServer" ip 0.0.0.0 mask 0.0.0.0

address "HttpServer" ip 0.0.0.0 mask 0.0.0.0

action deny

direction inbound

connection none

use protocol "ip"

use address "any"

use src-port eq "any"

use dest-port eq "any"

exit

filter tunnel rule "deny all/out"

action deny

direction outbound

connection none

use protocol "ip"

use address "any"

use src-port eq "any"

use dest-port eq "any"

exit

filter tunnel rule "permit all/in"

action permit

direction inbound

connection none

use protocol "ip"

use address "any"

use src-port eq "any"

use dest-port eq "any"

exit

filter tunnel rule "permit all/out"

action permit

direction outbound

connection none

use protocol "ip"

use address "any"

use src-port eq "any"

use dest-port eq "any"

exit

filter tunnel rule "permit dns(tcp)/in"

action permit

direction inbound

connection none

use protocol "tcp"

use address "any"

use src-port gt "dynamic port begin"

use dest-port eq "dns"

exit

filter tunnel rule "permit dns(tcp)/out"

action permit

direction outbound

connection established

use protocol "tcp"

use address "any"

use src-port eq "dns"

use dest-port gt "dynamic port begin"

exit

filter tunnel rule "permit dns(udp)/in"

action permit

direction inbound

connection none

use protocol "udp"

use address "any"

use src-port gt "dynamic port begin"

use dest-port eq "dns"

exit

filter tunnel rule "permit dns(udp)/out"

action permit

direction outbound

connection none

use protocol "udp"

use address "any"

use src-port eq "dns"

use dest-port gt "dynamic port begin"

exit

filter tunnel rule "permit Entrust CA/in"

action permit

direction inbound

connection none

use protocol "tcp"

use address "any"

use src-port gt "dynamic port begin"

use dest-port eq "Entrust CA"

exit

filter tunnel rule "permit Entrust CA/out"

action permit

direction outbound

connection established

use protocol "tcp"

use address "any"

use src-port eq "Entrust CA"

use dest-port gt "dynamic port begin"

exit

filter tunnel rule "permit finger/in"

action permit

direction inbound

connection none

use protocol "tcp"

use address "any"

use src-port gt "dynamic port begin"

use dest-port eq "finger"

exit

filter tunnel rule "permit finger/out"

action permit

direction outbound

connection established

use protocol "tcp"

use address "any"

use src-port eq "finger"

use dest-port gt "dynamic port begin"

exit

filter tunnel rule "permit ftp-data/in single server"

action permit

direction inbound

connection established

use protocol "tcp"

use address "FtpServer"

use src-port gt "dynamic port begin"

use dest-port eq "ftp-data"

exit

filter tunnel rule "permit ftp-data/in"

action permit

direction inbound

connection established

use protocol "tcp"

use address "any"

use src-port gt "dynamic port begin"

use dest-port eq "ftp-data"

exit

filter tunnel rule "permit ftp-data/out single server"

action permit

direction outbound

connection none

use protocol "tcp"

use address "FtpServer"

use src-port eq "ftp-data"

use dest-port gt "dynamic port begin"

exit

filter tunnel rule "permit ftp-data/out"

action permit

direction outbound

connection none

use protocol "tcp"

use address "any"

use src-port eq "ftp-data"

use dest-port gt "dynamic port begin"

exit

filter tunnel rule "permit ftp/in single server"

action permit

direction inbound

connection none

use protocol "tcp"

use address "FtpServer"

use src-port gt "dynamic port begin"

use dest-port eq "ftp"

exit

filter tunnel rule "permit ftp/in"

action permit

direction inbound

connection none

use protocol "tcp"

use address "any"

use src-port gt "dynamic port begin"

use dest-port eq "ftp"

exit

filter tunnel rule "permit ftp/out single server"

action permit

direction outbound

connection established

use protocol "tcp"

use address "FtpServer"

use src-port eq "ftp"

use dest-port gt "dynamic port begin"

exit

filter tunnel rule "permit ftp/out"

action permit

direction outbound

connection established

use protocol "tcp"

use address "any"

use src-port eq "ftp"

use dest-port gt "dynamic port begin"

exit

filter tunnel rule "permit gopher/in"

action permit

direction inbound

connection none

use protocol "tcp"

use address "any"

use src-port gt "dynamic port begin"

use dest-port eq "gopher"

exit

filter tunnel rule "permit gopher/out"

action permit

direction outbound

connection established

use protocol "tcp"

use address "any"

use src-port eq "gopher"

use dest-port gt "dynamic port begin"

exit

filter tunnel rule "permit http/in single server"

action permit

direction inbound

connection none

use protocol "tcp"

use address "HttpServer"

use src-port gt "dynamic port begin"

use dest-port eq "http"

exit

filter tunnel rule "permit http/in"

action permit

direction inbound

connection none

use protocol "tcp"

use address "any"

use src-port gt "dynamic port begin"

use dest-port eq "http"

exit

filter tunnel rule "permit http/out single server"

action permit

direction outbound

connection established

use protocol "tcp"

use address "HttpServer"

use src-port eq "http"

use dest-port gt "dynamic port begin"

exit

filter tunnel rule "permit http/out"

action permit

direction outbound

connection established

use protocol "tcp"

use address "any"

use src-port eq "http"

use dest-port gt "dynamic port begin"

exit

filter tunnel rule "permit icmp/in"

action permit

direction inbound

connection established

use protocol "icmp"

use address "any"

exit

filter tunnel rule "permit icmp/out"

action permit

direction outbound

connection established

use protocol "icmp"

use address "any"

exit

filter tunnel rule "permit laplink(tcp)/in"

action permit

direction inbound

connection none

use protocol "tcp"

use address "any"

use src-port gt "dynamic port begin"

use dest-port eq "laplink"

exit

filter tunnel rule "permit laplink(tcp)/out"

action permit

direction outbound

connection established

use protocol "tcp"

use address "any"

use src-port eq "laplink"

use dest-port gt "dynamic port begin"

exit

filter tunnel rule "permit laplink(udp)/in"

action permit

direction inbound

connection none

use protocol "udp"

use address "any"

use src-port gt "dynamic port begin"

use dest-port eq "laplink"

exit

filter tunnel rule "permit laplink(udp)/out"

action permit

direction outbound

connection none

use protocol "udp"

use address "any"

use src-port eq "laplink"

use dest-port gt "dynamic port begin"

exit

filter tunnel rule "permit ldap/in"

action permit

direction inbound

connection none

use protocol "tcp"

use address "any"

use src-port gt "dynamic port begin"

use dest-port eq "ldap"

exit

filter tunnel rule "permit ldap/out"

action permit

direction outbound

connection established

use protocol "tcp"

use address "any"

use src-port eq "ldap"

use dest-port gt "dynamic port begin"

exit

filter tunnel rule "permit netbios name service/in"

action permit

direction inbound

connection none

use protocol "udp"

use address "any"

use src-port eq "nbname"

use dest-port eq "nbname"

exit

filter tunnel rule "permit netbios name service/out"

action permit

direction outbound

connection none

use protocol "udp"

use address "any"

use src-port eq "nbname"

use dest-port eq "nbname"

exit

filter tunnel rule "permit netbios session/in"

action permit

direction inbound

connection none

use protocol "tcp"

use address "any"

use src-port gt "dynamic port begin"

use dest-port eq "nbsession"

exit

filter tunnel rule "permit netbios session/out"

action permit

direction outbound

connection established

use protocol "tcp"

use address "any"

use src-port eq "nbsession"

use dest-port gt "dynamic port begin"

exit

filter tunnel rule "permit netbios/in"

action permit

direction inbound

connection none

use protocol "udp"

use address "any"

use src-port eq "nbdatagram"

use dest-port eq "nbdatagram"

exit

filter tunnel rule "permit netbios/out"

action permit

direction outbound

connection none

use protocol "udp"

use address "any"

use src-port eq "nbdatagram"

use dest-port eq "nbdatagram"

exit

filter tunnel rule "permit nntp/in"

action permit

direction inbound

connection none

use protocol "tcp"

use address "any"

use src-port gt "dynamic port begin"

use dest-port eq "nntp"

exit

filter tunnel rule "permit nntp/out"

action permit

direction outbound

connection established

use protocol "tcp"

use address "any"

use src-port eq "nntp"

use dest-port gt "dynamic port begin"

exit

filter tunnel rule "permit ntp/in"

action permit

direction inbound

connection none

use protocol "udp"

use address "any"

use src-port gt "dynamic port begin"

use dest-port eq "ntp"

exit

filter tunnel rule "permit ntp/out"

action permit

direction outbound

connection none

use protocol "udp"

use address "any"

use src-port eq "ntp"

use dest-port gt "dynamic port begin"

exit

filter tunnel rule "permit pcANYWHERE/data(tcp)/in"

action permit

direction inbound

connection none

use protocol "tcp"

use address "any"

use src-port gt "dynamic port begin"

use dest-port eq "pcANYWHERE/data"

exit

filter tunnel rule "permit pcANYWHERE/data(tcp)/out"

action permit

direction outbound

connection established

use protocol "tcp"

use address "any"

use src-port eq "pcANYWHERE/data"

use dest-port gt "dynamic port begin"

exit

filter tunnel rule "permit pcANYWHERE/data(udp)/in"

action permit

direction inbound

connection none

use protocol "udp"

use address "any"

use src-port gt "dynamic port begin"

use dest-port eq "pcANYWHERE/data"

exit

filter tunnel rule "permit pcANYWHERE/data(udp)/out"

action permit

direction outbound

connection none

use protocol "udp"

use address "any"

use src-port eq "pcANYWHERE/data"

use dest-port gt "dynamic port begin"

exit

filter tunnel rule "permit pcANYWHERE/stat(tcp)/in"

action permit

direction inbound

connection none

use protocol "tcp"

use address "any"

use src-port gt "dynamic port begin"

use dest-port eq "pcANYWHERE/stat"

exit

filter tunnel rule "permit pcANYWHERE/stat(tcp)/out"

action permit

direction outbound

connection established

use protocol "tcp"

use address "any"

use src-port eq "pcANYWHERE/stat"

use dest-port gt "dynamic port begin"

exit

filter tunnel rule "permit pcANYWHERE/stat(udp)/in"

action permit

direction inbound

connection none

use protocol "udp"

use address "any"

use src-port gt "dynamic port begin"

use dest-port eq "pcANYWHERE/stat"

exit

filter tunnel rule "permit pcANYWHERE/stat(udp)/out"

action permit

direction outbound

connection none

use protocol "udp"

use address "any"

use src-port eq "pcANYWHERE/stat"

use dest-port gt "dynamic port begin"

exit

filter tunnel rule "permit pop3/in"

action permit

direction inbound

connection none

use protocol "tcp"

use address "any"

use src-port gt "dynamic port begin"

use dest-port eq "pop3"

exit

filter tunnel rule "permit pop3/out"

action permit

direction outbound

connection established

use protocol "tcp"

use address "any"

use src-port eq "pop3"

use dest-port gt "dynamic port begin"

exit

filter tunnel rule "permit smtp/in"

action permit

direction inbound

connection none

use protocol "tcp"

use address "any"

use src-port gt "dynamic port begin"

use dest-port eq "smtp"

exit

filter tunnel rule "permit smtp/out"

action permit

direction outbound

connection established

use protocol "tcp"

use address "any"

use src-port eq "smtp"

use dest-port gt "dynamic port begin"

exit

filter tunnel rule "permit snmp(tcp)/in"

action permit

direction inbound

connection none

use protocol "tcp"

use address "any"

use src-port gt "dynamic port begin"

use dest-port eq "snmp"

exit

filter tunnel rule "permit snmp(tcp)/out"

action permit

direction outbound

connection established

use protocol "tcp"

use address "any"

use src-port eq "snmp"

use dest-port gt "dynamic port begin"

exit

filter tunnel rule "permit snmp(udp)/in"

action permit

direction inbound

connection none

use protocol "udp"

use address "any"

use src-port gt "dynamic port begin"

use dest-port eq "snmp"

exit

filter tunnel rule "permit snmp(udp)/out"

action permit

direction outbound

connection none

use protocol "udp"

use address "any"

use src-port eq "snmp"

use dest-port gt "dynamic port begin"

exit

filter tunnel rule "permit snmp-trap(tcp)/in"

action permit

direction inbound

connection none

use protocol "tcp"

use address "any"

use src-port gt "dynamic port begin"

use dest-port eq "snmp-trap"

exit

filter tunnel rule "permit snmp-trap(tcp)/out"

action permit

direction outbound

connection established

use protocol "tcp"

use address "any"

use src-port eq "snmp-trap"

use dest-port gt "dynamic port begin"

exit

filter tunnel rule "permit snmp-trap(udp)/in"

action permit

direction inbound

connection none

use protocol "udp"

use address "any"

use src-port gt "dynamic port begin"

use dest-port eq "snmp-trap"

exit

filter tunnel rule "permit snmp-trap(udp)/out"

action permit

direction outbound

connection none

use protocol "udp"

use address "any"

use src-port eq "snmp-trap"

use dest-port gt "dynamic port begin"

exit

filter tunnel rule "permit telnet/in"

action permit

direction inbound

connection none

use protocol "tcp"

use address "any"

use src-port gt "dynamic port begin"

use dest-port eq "telnet"

exit

filter tunnel rule "permit telnet/out"

action permit

direction outbound

connection established

use protocol "tcp"

use address "any"

use src-port eq "telnet"

use dest-port gt "dynamic port begin"

exit

filter tunnel rule "permit wais/in"

action permit

direction inbound

connection none

use protocol "tcp"

use address "any"

use src-port gt "dynamic port begin"

use dest-port eq "wais"

exit

filter tunnel rule "permit wais/out"

action permit

direction outbound

connection established

use protocol "tcp"

use address "any"

use src-port eq "wais"

use dest-port gt "dynamic port begin"

exit

filter tunnel rule "permit whois/in"

action permit

direction inbound

connection none

use protocol "tcp"

use address "any"

use src-port gt "dynamic port begin"

use dest-port eq "whois"

exit

filter tunnel rule "permit whois/out"

action permit

direction outbound

connection established

use protocol "tcp"

use address "any"

use src-port eq "whois"

use dest-port gt "dynamic port begin"

exit

filter tunnel "deny all"

no client cmp

no client tunnelguard

no client ntp

no client ldap

no client dns

no client radius

no client ftp

no server telnet

no server snmp

no server radius

no server dns

no server https

no server ssh

no server http

no server ping

no server identification

no server ftp

add-rule "deny all/in"

add-rule "deny all/out"

exit

filter tunnel "Entrust PKI"

no client cmp

no client tunnelguard

no client ntp

no client ldap

no client dns

no client radius

no client ftp

no server telnet

no server snmp

no server radius

no server dns

no server https

no server ssh

no server http

no server ping

no server identification

no server ftp

add-rule "permit ldap/in"

add-rule "permit ldap/out"

add-rule "permit Entrust CA/in"

add-rule "permit Entrust CA/out"

exit

filter tunnel "permit all"

no client cmp

client tunnelguard

no client ntp

no client ldap

no client dns

no client radius

no client ftp

no server telnet

server snmp

no server radius

no server dns

server https

server ssh

server http

server ping

no server identification

no server ftp

add-rule "permit all/in"

add-rule "permit all/out"

exit

filter tunnel "permit only dns/ftp single server"

no client cmp

no client tunnelguard

no client ntp

no client ldap

no client dns

no client radius

no client ftp

no server telnet

no server snmp

no server radius

no server dns

no server https

no server ssh

no server http

no server ping

no server identification

no server ftp

add-rule "permit ftp/in single server"

add-rule "permit ftp/out single server"

add-rule "permit ftp-data/in single server"

add-rule "permit ftp-data/out single server"

add-rule "permit dns(tcp)/in"

add-rule "permit dns(tcp)/out"

add-rule "permit dns(udp)/in"

add-rule "permit dns(udp)/out"

exit

filter tunnel "permit only dns/ftp"

no client cmp

no client tunnelguard

no client ntp

no client ldap

no client dns

no client radius

no client ftp

no server telnet

no server snmp

no server radius

no server dns

no server https

no server ssh

no server http

no server ping

no server identification

no server ftp

add-rule "permit ftp/in"

add-rule "permit ftp/out"

add-rule "permit ftp-data/in"

add-rule "permit ftp-data/out"

add-rule "permit dns(tcp)/in"

add-rule "permit dns(tcp)/out"

add-rule "permit dns(udp)/in"

add-rule "permit dns(udp)/out"

exit

filter tunnel "permit only dns/http single server"

no client cmp

no client tunnelguard

no client ntp

no client ldap

no client dns

no client radius

no client ftp

no server telnet

no server snmp

no server radius

no server dns

no server https

no server ssh

no server http

no server ping

no server identification

no server ftp

add-rule "permit http/in single server"

add-rule "permit http/out single server"

add-rule "permit dns(tcp)/in"

add-rule "permit dns(tcp)/out"

add-rule "permit dns(udp)/in"

add-rule "permit dns(udp)/out"

exit

filter tunnel "permit only dns/http"

no client cmp

no client tunnelguard

no client ntp

no client ldap

no client dns

no client radius

no client ftp

no server telnet

no server snmp

no server radius

no server dns

no server https

no server ssh

no server http

no server ping

no server identification

no server ftp

add-rule "permit http/in"

add-rule "permit http/out"

add-rule "permit dns(tcp)/in"

add-rule "permit dns(tcp)/out"

add-rule "permit dns(udp)/in"

add-rule "permit dns(udp)/out"

exit

filter tunnel "permit only dns/netbios"

no client cmp

no client tunnelguard

no client ntp

no client ldap

no client dns

no client radius

no client ftp

no server telnet

no server snmp

no server radius

no server dns

no server https

no server ssh

no server http

no server ping

no server identification

no server ftp

add-rule "permit netbios/in"

add-rule "permit netbios/out"

add-rule "permit netbios name service/in"

add-rule "permit netbios name service/out"

add-rule "permit netbios session/in"

add-rule "permit netbios session/out"

add-rule "permit dns(tcp)/in"

add-rule "permit dns(tcp)/out"

add-rule "permit dns(udp)/in"

add-rule "permit dns(udp)/out"

exit

filter tunnel "permit only dns/nntp"

no client cmp

no client tunnelguard

no client ntp

no client ldap

no client dns

no client radius

no client ftp

no server telnet

no server snmp

no server radius

no server dns

no server https

no server ssh

no server http

no server ping

no server identification

no server ftp

add-rule "permit nntp/in"

add-rule "permit nntp/out"

add-rule "permit dns(tcp)/in"

add-rule "permit dns(tcp)/out"

add-rule "permit dns(udp)/in"

add-rule "permit dns(udp)/out"

exit

filter tunnel "permit only dns/smtp/pop3"

no client cmp

no client tunnelguard

no client ntp

no client ldap

no client dns

no client radius

no client ftp

no server telnet

no server snmp

no server radius

no server dns

no server https

no server ssh

no server http

no server ping

no server identification

no server ftp

add-rule "permit smtp/in"

add-rule "permit smtp/out"

add-rule "permit pop3/in"

add-rule "permit pop3/out"

add-rule "permit dns(tcp)/in"

add-rule "permit dns(tcp)/out"

add-rule "permit dns(udp)/in"

add-rule "permit dns(udp)/out"

exit

filter tunnel "permit only dns/telnet"

no client cmp

no client tunnelguard

no client ntp

no client ldap

no client dns

no client radius

no client ftp

no server telnet

no server snmp

no server radius

no server dns

no server https

no server ssh

no server http

no server ping

no server identification

no server ftp

add-rule "permit telnet/in"

add-rule "permit telnet/out"

add-rule "permit dns(tcp)/in"

add-rule "permit dns(tcp)/out"

add-rule "permit dns(udp)/in"

add-rule "permit dns(udp)/out"

exit

filter interface rule "deny all/in"

port "any" 0

port "DNS" 53

port "Dynamic Port Begin" 1023

port "Entrust CA" 829

port "Finger" 79

port "FTP Control" 21

port "FTP Data" 20

port "Gopher" 70

port "HTTP" 80

port "LapLink" 1547

port "LDAP" 389

port "nbdatagram" 138

port "nbname" 137

port "nbsession" 139

port "NNTP" 119

port "NTP" 123

port "pcANYWHERE/Data" 5631

port "pcANYWHERE/stat" 5631

port "POP2" 109

port "POP3" 110

port "Portmap" 111

port "smtp" 25

port "snmp" 161

port "snmp-trap" 162

port "Telnet" 23

port "wais" 210

port "whois" 43

protocol "Icmp" 1

protocol "Ip" 255

protocol "Tcp" 6

protocol "Udp" 17

address "any" ip 0.0.0.0 mask 255.255.255.255

action deny

direction inbound

connection none

use protocol "Ip"

use address "any"

use src-port eq "any"

use dest-port eq "any"

exit

filter interface rule "deny all/out"

action deny

direction outbound

connection none

use protocol "Ip"

use address "any"

use src-port eq "any"

use dest-port eq "any"

exit

filter interface rule "permit all/in"

action permit

direction inbound

connection none

use protocol "Ip"

use address "any"

use src-port eq "any"

use dest-port eq "any"

exit

filter interface rule "permit all/out"

action permit

direction outbound

connection none

use protocol "Ip"

use address "any"

use src-port eq "any"

use dest-port eq "any"

exit

filter interface rule "permit DnsTcpReplyIn"

action permit

direction inbound

connection established

use protocol "Tcp"

use address "any"

use src-port eq "DNS"

use dest-port gt "Dynamic Port Begin"

exit

filter interface rule "permit DnsTcpReplyOut"

action permit

direction outbound

connection established

use protocol "Tcp"

use address "any"

use src-port eq "DNS"

use dest-port gt "Dynamic Port Begin"

exit

filter interface rule "permit DnsTcpReqIn"

action permit

direction inbound

connection none

use protocol "Tcp"

use address "any"

use src-port gt "Dynamic Port Begin"

use dest-port eq "DNS"

exit

filter interface rule "permit DnsTcpReqOut"

action permit

direction outbound

connection none

use protocol "Tcp"

use address "any"

use src-port gt "Dynamic Port Begin"

use dest-port eq "DNS"

exit

filter interface rule "permit DnsUdpReplyIn"

action permit

direction inbound

connection none

use protocol "Udp"

use address "any"

use src-port eq "DNS"

use dest-port gt "Dynamic Port Begin"

exit

filter interface rule "permit DnsUdpReplyOut"

action permit

direction outbound

connection none

use protocol "Udp"

use address "any"

use src-port eq "DNS"

use dest-port gt "Dynamic Port Begin"

exit

filter interface rule "permit DnsUdpReqIn"

action permit

direction inbound

connection none

use protocol "Udp"

use address "any"

use src-port gt "Dynamic Port Begin"

use dest-port eq "DNS"

exit

filter interface rule "permit DnsUdpReqOut"

action permit

direction outbound

connection none

use protocol "Udp"

use address "any"

use src-port gt "Dynamic Port Begin"

use dest-port eq "DNS"

exit

filter interface rule "permit EntrustCaReplyIn"

action permit

direction inbound

connection established

use protocol "Tcp"

use address "any"

use src-port eq "Entrust CA"

use dest-port gt "Dynamic Port Begin"

exit

filter interface rule "permit EntrustCaReplyOut"

action permit

direction outbound

connection established

use protocol "Tcp"

use address "any"

use src-port eq "Entrust CA"

use dest-port gt "Dynamic Port Begin"

exit

filter interface rule "permit EntrustCaReqIn"

action permit

direction inbound

connection none

use protocol "Tcp"

use address "any"

use src-port gt "Dynamic Port Begin"

use dest-port eq "Entrust CA"

exit

filter interface rule "permit EntrustCaReqOut"

action permit

direction outbound

connection none

use protocol "Tcp"

use address "any"

use src-port gt "Dynamic Port Begin"

use dest-port eq "Entrust CA"

exit

filter interface rule "permit FingerReplyIn"

action permit

direction inbound

connection established

use protocol "Tcp"

use address "any"

use src-port eq "Finger"

use dest-port gt "Dynamic Port Begin"

exit

filter interface rule "permit FingerReplyOut"

action permit

direction outbound

connection established

use protocol "Tcp"

use address "any"

use src-port eq "Finger"

use dest-port gt "Dynamic Port Begin"

exit

filter interface rule "permit FingerReqIn"

action permit

direction inbound

connection none

use protocol "Tcp"

use address "any"

use src-port gt "Dynamic Port Begin"

use dest-port eq "Finger"

exit

filter interface rule "permit FingerReqOut"

action permit

direction outbound

connection none

use protocol "Tcp"

use address "any"

use src-port gt "Dynamic Port Begin"

use dest-port eq "Finger"

exit

filter interface rule "permit FtpDataReplyIn"

action permit

direction inbound

connection established

use protocol "Tcp"

use address "any"

use src-port gt "Dynamic Port Begin"

use dest-port eq "FTP Data"

exit

filter interface rule "permit FtpDataReplyOut"

action permit

direction outbound

connection established

use protocol "Tcp"

use address "any"

use src-port gt "Dynamic Port Begin"

use dest-port eq "FTP Data"

exit

filter interface rule "permit FtpDataReqIn"

action permit

direction inbound

connection none

use protocol "Tcp"

use address "any"

use src-port eq "FTP Data"

use dest-port gt "Dynamic Port Begin"

exit

filter interface rule "permit FtpDataReqOut"

action permit

direction outbound

connection none

use protocol "Tcp"

use address "any"

use src-port eq "FTP Data"

use dest-port gt "Dynamic Port Begin"

exit

filter interface rule "permit FtpReplyIn"

action permit

direction inbound

connection established

use protocol "Tcp"

use address "any"

use src-port eq "FTP Control"

use dest-port gt "Dynamic Port Begin"

exit

filter interface rule "permit FtpReplyOut"

action permit

direction outbound

connection established

use protocol "Tcp"

use address "any"

use src-port eq "FTP Control"

use dest-port gt "Dynamic Port Begin"

exit

filter interface rule "permit FtpReqIn"

action permit

direction inbound

connection none

use protocol "Tcp"

use address "any"

use src-port gt "Dynamic Port Begin"

use dest-port eq "FTP Control"

exit

filter interface rule "permit FtpReqOut"

action permit

direction outbound

connection none

use protocol "Tcp"

use address "any"

use src-port gt "Dynamic Port Begin"

use dest-port eq "FTP Control"

exit

filter interface rule "permit HttpReplyIn"

action permit

direction inbound

connection established

use protocol "Tcp"

use address "any"

use src-port eq "HTTP"

use dest-port gt "Dynamic Port Begin"

exit

filter interface rule "permit HttpReplyOut"

action permit

direction outbound

connection established

use protocol "Tcp"

use address "any"

use src-port eq "HTTP"

use dest-port gt "Dynamic Port Begin"

exit

filter interface rule "permit HttpReqIn"

action permit

direction inbound

connection none

use protocol "Tcp"

use address "any"

use src-port gt "Dynamic Port Begin"

use dest-port eq "HTTP"

exit

filter interface rule "permit HttpReqOut"

action permit

direction outbound

connection none

use protocol "Tcp"

use address "any"

use src-port gt "Dynamic Port Begin"

use dest-port eq "HTTP"

exit

filter interface rule "permit icmp in"

action permit

direction inbound

connection none

use protocol "Icmp"

use address "any"

use src-port eq "any"

use dest-port eq "any"

exit

filter interface rule "permit icmp out"

action permit

direction outbound

connection none

use protocol "Icmp"

use address "any"

use src-port eq "any"

use dest-port eq "any"

exit

filter interface rule "permit LdapReplyIn"

action permit

direction inbound

connection established

use protocol "Tcp"

use address "any"

use src-port eq "LDAP"

use dest-port gt "Dynamic Port Begin"

exit

filter interface rule "permit LdapReplyOut"

action permit

direction outbound

connection established

use protocol "Tcp"

use address "any"

use src-port eq "LDAP"

use dest-port gt "Dynamic Port Begin"

exit

filter interface rule "permit LdapReqIn"

action permit

direction inbound

connection none

use protocol "Tcp"

use address "any"

use src-port gt "Dynamic Port Begin"

use dest-port eq "LDAP"

exit

filter interface rule "permit LdapReqOut"

action permit

direction outbound

connection none

use protocol "Tcp"

use address "any"

use src-port gt "Dynamic Port Begin"

use dest-port eq "LDAP"

exit

filter interface rule "permit NntpReplyIn"

action permit

direction inbound

connection established

use protocol "Tcp"

use address "any"

use src-port eq "NNTP"

use dest-port gt "Dynamic Port Begin"

exit

filter interface rule "permit NntpReplyOut"

action permit

direction outbound

connection established

use protocol "Tcp"

use address "any"

use src-port eq "NNTP"

use dest-port gt "Dynamic Port Begin"

exit

filter interface rule "permit NntpReqIn"

action permit

direction inbound

connection none

use protocol "Tcp"

use address "any"

use src-port gt "Dynamic Port Begin"

use dest-port eq "NNTP"

exit

filter interface rule "permit NntpReqOut"

action permit

direction outbound

connection none

use protocol "Tcp"

use address "any"

use src-port gt "Dynamic Port Begin"

use dest-port eq "NNTP"

exit

filter interface rule "permit NTPin static port"

action permit

direction inbound

connection none

use protocol "Udp"

use address "any"

use src-port eq "NTP"

use dest-port eq "NTP"

exit

filter interface rule "permit NTPout static port"

action permit

direction outbound

connection none

use protocol "Udp"

use address "any"

use src-port eq "NTP"

use dest-port eq "NTP"

exit

filter interface rule "permit NtpReplyIn"

action permit

direction inbound

connection established

use protocol "Udp"

use address "any"

use src-port eq "NTP"

use dest-port gt "Dynamic Port Begin"

exit

filter interface rule "permit NtpReplyOut"

action permit

direction outbound

connection established

use protocol "Udp"

use address "any"

use src-port eq "NTP"

use dest-port gt "Dynamic Port Begin"

exit

filter interface rule "permit NtpReqIn"

action permit

direction inbound

connection none

use protocol "Udp"

use address "any"

use src-port gt "Dynamic Port Begin"

use dest-port eq "NTP"

exit

filter interface rule "permit NtpReqOut"

action permit

direction outbound

connection none

use protocol "Udp"

use address "any"

use src-port gt "Dynamic Port Begin"

use dest-port eq "NTP"

exit

filter interface rule "permit TelnetReplyIn"

action permit

direction inbound

connection established

use protocol "Tcp"

use address "any"

use src-port eq "Telnet"

use dest-port gt "Dynamic Port Begin"

exit

filter interface rule "permit TelnetReplyOut"

action permit

direction outbound

connection established

use protocol "Tcp"

use address "any"

use src-port eq "Telnet"

use dest-port gt "Dynamic Port Begin"

exit

filter interface rule "permit TelnetReqIn"

action permit

direction inbound

connection none

use protocol "Tcp"

use address "any"

use src-port gt "Dynamic Port Begin"

use dest-port eq "Telnet"

exit

filter interface rule "permit TelnetReqOn"

action permit

direction outbound

connection none

use protocol "Tcp"

use address "any"

use src-port gt "Dynamic Port Begin"

use dest-port eq "Telnet"

exit

filter interface "deny all"

add-rule "deny all/in"

add-rule "deny all/out"

exit

filter interface "permit all"

add-rule "permit all/in"

add-rule "permit all/out"

exit

filter interface "permit DNS"

add-rule "permit DnsTcpReqIn"

add-rule "permit DnsTcpReqOut"

add-rule "permit DnsTcpReplyIn"

add-rule "permit DnsTcpReplyOut"

add-rule "permit DnsUdpReqIn"

add-rule "permit DnsUdpReqOut"

add-rule "permit DnsUdpReplyIn"

add-rule "permit DnsUdpReplyOut"

exit

filter interface "permit DNS TCP"

add-rule "permit DnsTcpReqIn"

add-rule "permit DnsTcpReqOut"

add-rule "permit DnsTcpReplyIn"

add-rule "permit DnsTcpReplyOut"

exit

filter interface "permit DNS UDP"

add-rule "permit DnsUdpReqIn"

add-rule "permit DnsUdpReqOut"

add-rule "permit DnsUdpReplyIn"

add-rule "permit DnsUdpReplyOut"

exit

filter interface "permit entrust CA"

add-rule "permit EntrustCaReqIn"

add-rule "permit EntrustCaReqOut"

add-rule "permit EntrustCaReplyIn"

add-rule "permit EntrustCaReplyOut"

exit

filter interface "permit finger"

add-rule "permit FingerReqIn"

add-rule "permit FingerReqOut"

add-rule "permit FingerReplyIn"

add-rule "permit FingerReplyOut"

exit

filter interface "permit FTP"

add-rule "permit FtpReqIn"

add-rule "permit FtpReqOut"

add-rule "permit FtpReplyIn"

add-rule "permit FtpReplyOut"

add-rule "permit FtpDataReqIn"

add-rule "permit FtpDataReqOut"

add-rule "permit FtpDataReplyIn"

add-rule "permit FtpDataReplyOut"

exit

filter interface "permit HTTP"

add-rule "permit HttpReqIn"

add-rule "permit HttpReqOut"

add-rule "permit HttpReplyIn"

add-rule "permit HttpReplyOut"

exit

filter interface "permit LDAP"

add-rule "permit LdapReqIn"

add-rule "permit LdapReqOut"

add-rule "permit LdapReplyIn"

add-rule "permit LdapReplyOut"

exit

filter interface "permit NNTP"

add-rule "permit NntpReqIn"

add-rule "permit NntpReqOut"

add-rule "permit NntpReplyIn"

add-rule "permit NntpReplyOut"

exit

filter interface "permit NTP"

add-rule "permit NTPin static port"

add-rule "permit NTPout static port"

add-rule "permit NtpReplyIn"

add-rule "permit NtpReplyOut"

add-rule "permit NtpReqIn"

add-rule "permit NtpReqOut"

add-rule "permit NtpReplyIn"

add-rule "permit NtpReplyOut"

exit

filter interface "permit ping"

add-rule "permit icmp in"

add-rule "permit icmp out"

exit

filter interface "permit Telnet"

add-rule "permit TelnetReqIn"

add-rule "permit TelnetReqOn"

add-rule "permit TelnetReplyIn"

add-rule "permit TelnetReplyOut"

exit

interface FastEthernet 0/1

ip address 10.100.27.5 255.255.255.0

no ip directed-broadcast

filter "deny all"

speed auto

no dot1q enable

dot1q interface vlan-id 1

dot1q interface untag ingress

dot1q interface untag egress

no qos ingress-dscp-map

no qos egress-dscp-map

no mac-pause

no mtu

service dhcp enable

no tcp-mss enable

no tcp-mss

arp timeout 1200

exit

interface FastEthernet 1/1

no shutdown

filter "permit all"

public

speed auto

no dot1q enable

dot1q interface vlan-id 1

dot1q interface untag ingress

dot1q interface untag egress

no qos ingress-dscp-map

no qos egress-dscp-map

no mac-pause

no mtu

no service dhcp enable

no tcp-mss enable

no tcp-mss

arp timeout 1200

exit

interface dial 7/1

auto-answer 1

baud-rate 9600

mode serial-menu

dial-prefix-string +++ATDT

filter "deny all"

no phone

modem-initialization-string +++ATZ

modem-termination-string +++ATH

no mtu

no tcp-mss enable

no tcp-mss

menu-access-level UNRESTRICTED

exit

router static

ip default-network 10.100.27.1 private 10 enable

! !!! RIP is currently disabled

! !!! In order to properly provision

! !!! RIP it will be temporarily enabled

! !!! When RIP provisioning is complete

! !!! RIP will be set back to disabled

 router rip

timers basic 30

network 10.100.27.5 255.255.255.0

exit

no router rip

route-policy

! !!! RIP is currently disabled

! !!! In order to properly provision redistribution,

! !!! RIP will be temporarily enabled

! !!! When Redistribution provisioning is complete

! !!! RIP will be set back to disabled

 router rip

redistribute static

no redistribute ospf

no redistribute utunnel

no redistribute direct

no redistribute hosts

no redistribute bgp

no redistribute clip

no redistribute mgmt

redistribute nat

exit

no router rip

no router car

no multicast-relay enable

multicast-relay congestion-threshold 3000

no ip forward-protocol dhcp-relay

interface FastEthernet 0/1

ip rip 

ip rip send version 2 

ip rip receive version 2 

no ip rip authentication mode 

ip rip cost 1 

ip rip poison-reverse 

no ip rip import-default 

no ip rip export-default-metric 

ip rip export-static-metric 1  

no ip rip export-ospf-metric 

no ip rip export-bgp-metric 

ip rip export-bo-static-metric 1  

exit

router nat

summarization

threshold 200

exit

! !!! Running configuration for Demand

no demand enable

logging 10.100.32.88 facility-tagged kern filter-entity all filter-subentity al

l level all port 514

logging 10.100.32.88 enable

logging 10.100.32.43 facility-tagged local0 filter-entity all filter-subentity 

all level notice port 514

logging 10.100.32.43 enable

tunnel protocol ipsec private

tunnel protocol ipsec public

tunnel protocol pptp private

tunnel protocol pptp public

tunnel protocol l2tp-l2f private

tunnel protocol l2tp-l2f public

no fwua private

no fwua public

ip http server

http port 80

https private

no https public

https private port 443

ssh private

ssh public

no identification enable

snmp-server management

snmp-server port 161

ftp-server enable

ftp-server port 21

ftp-server passive mode disabled

telnet enable

telnet port 23

crl retrieval private

no crl retrieval public

cmp private

no cmp public

radius-accounting private enable

no radius-accounting public enable

icmp private

icmp public

no bgp public

no ip radius source-interface private

no ip radius source-interface public

no aaa authentication ipsec ldap-server

aaa authentication ipsec radius 

ipsec authentication local username-password

ipsec authentication local rsa-sig

ipsec authentication radius axent-defender

ipsec authentication radius dynamic-securid

ipsec authentication radius username-password

ipsec encryption des56-md5

no ipsec encryption md5

ipsec encryption hmac-sha1

ipsec encryption hmac-md5

no ipsec encryption 3des-sha1

no ipsec encryption des56-sha1

ipsec encryption 3des-md5

no ipsec encryption aes128-sha1

no ipsec encryption des40-sha1

ipsec encryption des40-md5

no ipsec encryption sha1

no ipsec encryption aes256-sha1

ipsec encryption ike des56-group1

ipsec encryption ike 3des-group2

ipsec encryption ike 3des-group7

ipsec encryption ike 128aes-group5

ipsec encryption ike 128aes-group8

no ipsec encryption ike 128aes-group2

no ipsec encryption ike 256aes-group8

no ipsec encryption ike 256aes-group5

no ipsec load-balance

no ipsec nat-traversal

ipsec nat-traversal client-ike-source-port-switching enable

no ipsec fail-over host1

no ipsec fail-over host2

no ipsec fail-over host3

no firewall user-authentication ldap-server

no firewall user-authentication radius

firewall user-authentication port 8000

firewall user-authentication max-sessions 1000

no firewall user-authentication banner

no aaa authentication pptp ldap-server

aaa authentication pptp radius 

pptp authentication pap

pptp authentication chap

pptp authentication ms-chap version 1

pptp authentication ms-chap version 2

pptp authentication ms-chap encryption rc4-128

pptp authentication ms-chap encryption rc4-40

pptp authentication ms-chap encryption none

no pptp lcp-echo enable

no aaa authentication l2tp ldap-server

aaa authentication l2tp radius 

l2tp authentication pap

l2tp authentication chap

l2tp authentication ms-chap version 1

l2tp authentication ms-chap version 2

l2tp authentication ms-chap encryption rc4-128

l2tp authentication ms-chap encryption rc4-40

l2tp authentication ms-chap encryption none

no l2tp lcp-echo enable

no aaa authentication l2f ldap-server

aaa authentication l2f radius 

l2f authentication pap

l2f authentication chap

no l2f lcp-echo enable

no radius service

! !!! The above command temporarily disables radius service

! !!! to allow radius service to be correctly configured

radius-client port 1645

radius-client default-client disabled

radius-client default-client epassword "VlaL3YvcCT4="

no aaa authentication radius ldap-server

no aaa authentication radius radius

no ssl https-port 

ssl cipher 1

ssl cipher 2

ssl cipher 3

ssl cipher 4

ssl cipher 5

ssl cipher 6

ssl cipher 7

ssl cipher 8

ssl cipher 9

ssl cipher 10

ssl cipher 11

ssl option des-cbc-padding enable

no ssl server-cert 

no ssl-vpn enable

ssl-vpn csfw-implied-rule enable

ssl-vpn one-time-password enable

tunnel-guard server-port 8282

ip address-pool local

ip dhcp proxy-server any

ip dhcp proxy-server cache-size 1

ip dhcp proxy-server blackout-interval 300

ip dhcp proxy-server address-release

ip dhcp proxy-server blackout-interval override

ip local pool blackout-interval 0

ip local pool unavailable failover

group connectivity "/Base"

access-hours "Anytime"

no access-network

ip address-src default

no ip address-pool

priority call-admission highest

no contact

priority forwarding low

idle-timeout 00:15:00

no ipx

filters "permit all"

no rsvp

rsvp token-bucket depth 3000

rsvp token-bucket rate 28

no password alphabetic

no password management

password max-age 30

password min-length 16

ppp-links max-number "2"

login max-attempts 0

logins 1

static-ipaddress

excess rate 5000000

! !!! Temporary set of excess rate to maximum value

committed rate 56000

excess rate 128000

excess action MARK

no tunnel-guard enable

use tunnel-guard filter "deny all"

tunnel-guard recheck-interval 15

tunnel-guard agent-query-timeout 2

tunnel-guard fail-action teardown-tunnel

tunnel-guard agent-min-version major 0

tunnel-guard agent-min-version feature 0

tunnel-guard agent-min-version minor 0

tunnel-guard agent-min-version patch 0

no tunnel-guard banner

forced-logoff 00:00:00

exit

group ipsec "/Base"

no banner

no display-banner

rekey timeout 08:00:00

rekey data-count 0

no password-storage

pfs

no mobility enable

antireplay enable

compress

encryption des56-md5

encryption hmac-sha1

encryption hmac-md5

no encryption 3des-md5

no encryption des40-md5

encryption ike des56-group1

no encryption ike 3des-group2

no encryption ike 3des-group7

no encryption ike 128aes-group5

no encryption ike 128aes-group8

nortel-client action none

nortel-client version none

no nortel-client message

nortel-client filter "permit all"

client allowed ALL

no client policy

no client screen-saver password

client screen-saver activation-time 5

client undefined-networks

client failover-tuning

client failover-tuning interval 00:01:00

client failover-tuning retransmissions 3

client dynamic-dns enable

max-roamingtime 120

no persistence enable

persistent-time 60

no client auto-connect

client auto-connect networks any

no ip domain-name

ip address 0.0.0.0

ip address 0.0.0.0 secondary

wins address 0.0.0.0

wins address 0.0.0.0 secondary

authentication local rsa-sig

authentication local username-password

no authentication local rsa-sig server-ca

no authentication external groupid

no authentication external axent-defender

no authentication external username-password

no authentication external dynamic-securid

ipsec-transport

no split tunneling

no split tunnel-network

no split inverse-tunnel-network

ipsec-idle-timeout-reset enable

exit

group l2f "/Base"

no authentication pap

authentication chap

no client-address

compress

ip address 0.0.0.0

ip address 0.0.0.0 secondary

wins address 0.0.0.0

wins address 0.0.0.0 secondary

exit

group l2tp "/Base"

no authentication pap

authentication chap

authentication ms-chap version 1

authentication ms-chap version 2

authentication ms-chap encryption none

authentication ms-chap encryption rc4-40

authentication ms-chap encryption rc4-128

no client-address

ipsec-data-protection none

ipsec-credentials "/Base"

compress

ip address 0.0.0.0

ip address 0.0.0.0 secondary

wins address 0.0.0.0

wins address 0.0.0.0 secondary

exit

group pptp "/Base"

no authentication pap

authentication chap

authentication ms-chap version 1

authentication ms-chap version 2

authentication ms-chap encryption none

authentication ms-chap encryption rc4-40

authentication ms-chap encryption rc4-128

no client-address

compress

ip address 0.0.0.0

ip address 0.0.0.0 secondary

wins address 0.0.0.0

wins address 0.0.0.0 secondary

exit

group fwua "/Base"

no proxy-ip

no banner

no display-banner

exit

radius-server domain-delimiter @

radius-server prefix-delimiter \

radius-server default-group "/Base"

no radius-server error-code-pass-thru enable

no radius-server suffix-remove

no radius-server prefix-remove

aaa authorization network radius

no radius-server authentication challenge

no radius-server authentication response

no radius-server authentication ms-chap version 1

radius-server authentication ms-chap version 1 rfc-2548

no radius-server authentication ms-chap version 2

radius-server authentication chap

radius-server authentication pap

radius-server retransmit 3

radius-server timeout 3

radius-server primary disabled

radius-server alternate1 disabled

radius-server alternate2 disabled

aaa accounting network radius

accounting radius-server disabled

aaa accounting session update  00:30:00

no aaa accounting update

aaa accounting update 00:30:00

clear accounting 60

ldap-server source internal

ldap-server internal domain-delimiter @

no ldap-server internal remove-suffix

aaa authentication ldap-server

proxy ldap-server domain-delimiter  @

no proxy ldap-server remove-suffix

no proxy ldap-server host master

no proxy ldap-server host slave1

no proxy ldap-server host slave2

no proxy ldap-server digital-certificate

proxy ldap-server mode basic

proxy ldap-server subject-dn " " subject-alt-name " " ca " "

no proxy ldap-server uid

no proxy ldap-server password

no proxy ldap-server ldap-filter

proxy ldap-server server-type 0

no proxy ldap-server pwd-timestamp-attr

proxy ldap-server pwd-life-time 0

no proxy ldap-server contivity-group

no proxy ldap-server filter

no proxy ldap-server ip-address 

no proxy ldap-server net-mask 

proxy ldap-server timeout 4

access-hours "Anytime"  monday 00:00:00 23:59:59 tuesday 00:00:00 23:59:59 wedn

esday 00:00:00 23:59:59 thursday 00:00:00 23:59:59 friday 00:00:00 23:59:59 sat

urday 00:00:00 23:59:59 sunday 00:00:00 23:59:59

access-hours "Weekdays"  monday 00:00:00 23:59:59 tuesday 00:00:00 23:59:59 wed

nesday 00:00:00 23:59:59 thursday 00:00:00 23:59:59 friday 00:00:00 23:59:59

access-hours "Weekends"  saturday 00:00:00 23:59:59 sunday 00:00:00 23:59:59

policy object

exit

bo-group connectivity "/Base"

access-hours "Anytime"

priority call-admission highest

priority forwarding low

idle-timeout 00:15:00

forced-logoff 00:00:00

no nailed-up

no rsvp

rsvp token-bucket depth 3000

rsvp token-bucket rate 28

excess rate 5000000

! !!! Temporary set of excess rate to maximum value

committed rate 56000

excess rate 128000

excess action MARK

exit

bo-group ipsec "/Base"

rekey timeout 08:00:00

rekey data-count 0

pfs

antireplay enable

compress

no initial-contact enable

encryption des56-md5

encryption hmac-sha1

encryption hmac-md5

no encryption 3des-md5

no encryption des40-md5

encryption ike des56-group1

vendor-id

isakmp-retransmission interval 16

isakmp-retransmission max-attempts 4

keepalive interval 00:01:00

no keepalive ondemand-conn

df-bit CLEAR

exit

bo-group ospf "/Base"

priority 1

dead-interval 40

hello-interval 10

retransmit-interval 5

transmit-delay 1

authentication none

exit

bo-group rip "/Base"

send version 2

receive version 2

authentication none

no import default-route

no export default-routes-metric

no export static-routes-metric

no export bo-static-routes-metric

no export ospf-routes-metric

no export bgp-routes-metric

poison-reverse

exit

route-policy

! !!! RIP is currently disabled

! !!! In order to properly provision redistribution,

! !!! RIP will be temporarily enabled

! !!! When Redistribution provisioning is complete

! !!! RIP will be set back to disabled

 router rip

redistribute static

no redistribute ospf

no redistribute utunnel

no redistribute direct

no redistribute hosts

no redistribute bgp

no redistribute clip

no redistribute mgmt

redistribute nat

exit

no router rip

snmp-server name "Contivity"

snmp-server contact "gfarris"

snmp-server location "Planet Earth"

snmp-server get-host  0.0.0.0 "public" enabled

no snmp-server mib iptunnel

no snmp-server mib rip2

no snmp-server mib ospf

no snmp-server mib bgp

no snmp-server mib vrrp

no snmp-server mib ipx

no snmp-server mib ripsap

no snmp-server mib dsu/csu

snmp-server enable traps hardware lan-1/1 interval 00:03:00

no snmp-server enable traps hardware lan-1/1

snmp-server enable traps hardware lan-system interval 00:03:00

no snmp-server enable traps hardware lan-system

snmp-server enable traps hardware memory interval 00:03:00

no snmp-server enable traps hardware memory

snmp-server enable traps hardware disk0 interval 00:03:00

no snmp-server enable traps hardware disk0

snmp-server enable traps hardware temp-critical interval 00:03:00

no snmp-server enable traps hardware temp-critical

snmp-server enable traps hardware voltage-12minus interval 00:03:00

no snmp-server enable traps hardware voltage-12minus

snmp-server enable traps hardware voltage-12plus interval 00:03:00

no snmp-server enable traps hardware voltage-12plus

snmp-server enable traps hardware voltage-2.5b interval 00:03:00

no snmp-server enable traps hardware voltage-2.5b

snmp-server enable traps hardware voltage-2.5a interval 00:03:00

no snmp-server enable traps hardware voltage-2.5a

snmp-server enable traps hardware voltage-3.3plus interval 00:03:00

no snmp-server enable traps hardware voltage-3.3plus

snmp-server enable traps hardware voltage-5plus interval 00:03:00

no snmp-server enable traps hardware voltage-5plus

snmp-server enable traps hardware heart-beat interval 00:03:00

no snmp-server enable traps hardware heart-beat

snmp-server enable traps server cmp interval 00:03:00

no snmp-server enable traps server cmp

snmp-server enable traps server certificates interval 00:03:00

no snmp-server enable traps server certificates

snmp-server enable traps server backup interval 00:03:00

no snmp-server enable traps server backup

snmp-server enable traps server load-balance interval 00:03:00

no snmp-server enable traps server load-balance

snmp-server enable traps server ldap-internal interval 00:03:00

no snmp-server enable traps server ldap-internal

snmp-server enable traps server radius-auth interval 00:03:00

no snmp-server enable traps server radius-auth

snmp-server enable traps server radius-acct interval 00:03:00

no snmp-server enable traps server radius-acct

snmp-server enable traps server ldap-external interval 00:03:00

no snmp-server enable traps server ldap-external

snmp-server enable traps server dhcp interval 00:03:00

no snmp-server enable traps server dhcp

snmp-server enable traps server snmp interval 00:03:00

no snmp-server enable traps server snmp

snmp-server enable traps server ldap-auth-external interval 00:03:00

no snmp-server enable traps server ldap-auth-external

snmp-server enable traps server ipaddr-pool interval 00:03:00

no snmp-server enable traps server ipaddr-pool

snmp-server enable traps server dns interval 00:03:00

no snmp-server enable traps server dns

snmp-server enable traps service fips interval 00:03:00

no snmp-server enable traps service fips

snmp-server enable traps service anti-spoofing interval 00:03:00

no snmp-server enable traps service anti-spoofing

snmp-server enable traps service nat interval 00:03:00

no snmp-server enable traps service nat

snmp-server enable traps service firewall interval 00:03:00

no snmp-server enable traps service firewall

snmp-server enable traps service temp-license interval 00:03:00

no snmp-server enable traps service temp-license

snmp-server enable traps service buffer interval 00:03:00

no snmp-server enable traps service buffer

no snmp-server enable traps ietf authentication

no snmp-server enable traps ietf physical

no snmp-server enable traps ietf bo-tunnel-nailed-up

no snmp-server enable traps ietf bo-tunnel-ondemand

no snmp-server enable traps ietf vrrp

no snmp-server enable traps ietf bgp

no snmp-server enable traps ietf ospf

no snmp-server enable traps ietf dsu/csu

no snmp-server enable traps attack failed-login

no snmp-server enable traps attack firewall

no snmp-server enable traps attack intrusion

no exception backup 1

no exception backup 2

no exception backup 3

no firewall 

policy nat interface disable

! !!! Reboot CES for NAT interface state change to take effect.

no firewall anti-spoof

no firewall strict-tcp-rules

firewall tunnel-filter

firewall tunnel-management-filter

firewall connection-number 2000

firewall logging log-level None

no firewall logging all

no firewall logging debug

no firewall logging firewall

no firewall logging nat

no firewall logging polmgr

no firewall logging traffic

firewall alg snmp enable

no firewall alg sip enable

no firewall cone-nat enable

no firewall hairpin enable

no firewall scan-detection

firewall scan-detection interval 10

firewall scan-detection threshold-network 20

firewall scan-detection threshold-port 50

system forwarding proxy-arp branch-office-tunnels enable

no system forwarding proxy-arp physical-interfaces enable

system forwarding proxy-arp nat enable

no system forwarding gratuitous-arp enable

no system forwarding tunnel-to-tunnel-traffic EU-to-EU enable

no system forwarding tunnel-to-tunnel-traffic EU-to-BO enable

no system forwarding tunnel-to-tunnel-traffic BO-to-BO enable

no system forwarding nexthop-forward enable

data-collection-interval 2

log-file-lifetime 60

event-log size 2000

no compress-files enable

system-log-to-file enable

safe-mode duration 5

no scheduler manageability enable

no prompt

! !!! Running configuration for Eventlog

no auto-save-logging enable

logging auto-save-logging max-files  5

! !!! 

! !!! No event-log capture filter entity, sub-entity configured.

! !!! Caution:Capture all is defaulted with no prior configuration.

! !!! Addition of one or more entity/subentity will turn off all others.

! !!! 

! !!! No event-log capture filter severity configured.

! !!! Caution:Capture all except debug is defaulted with no prior configuration

.

! !!! Addition of one or more severity will turn off all others.

! !!! 

! !!! No event-log display filter entity, sub-entity configured.

! !!! Caution:Display all is defaulted with no prior configuration.

! !!! Addition of one or more entity/subentity will turn off all others.

! !!! 

! !!! No event-log display filter severity configured.

! !!! Caution:Display all except debug is defaulted with no prior configuration

.

! !!! Addition of one or more severity will turn off all others.

! !!! Running configuration for AOT

aot peer-ip-address 0.0.0.0

aot local-ip-address 0.0.0.0

aot port-number 1000

aot num-of-ticks 3

aot originator FALSE

no aot enable

no aot private enable

no aot public enable

serial-port parity none

serial-port data 8-bit

serial-port stop 1-bit

ip dhcp server pool

name "default"

lease default 0 12 0 0

lease maximum 1 0 0 0

exit

ip dhcp server pool network 10.0.0.0 mask 255.0.0.0

name "blarg"

description blargthis

lease default 0 12 0 0

lease maximum 1 0 0 0

exit

service dhcp enable

CES#

END

