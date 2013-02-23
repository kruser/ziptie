package DataNetVanta;

use strict;
use warnings;
use Exporter 'import';
our @EXPORT_OK = qw($responsesNetVanta);

our $responsesNetVanta = {};

$responsesNetVanta->{version} = <<'VERSION';
OS version 05.03.00
  Checksum: 24022BD8, built on Wed Dec 17 14:47:59 2003
  Upgrade key: 2e6baf8a9cab6720e468452bc1239441
Boot ROM version 05.02.00
  Checksum: A400, built on: Tue Nov 11 15:35:06 2003
Copyright (c) 1999-2003, ADTRAN, Inc.
Platform: NetVanta 3200, part number 1202860L1
Serial number D49E4210

NetVanta uptime is 11 weeks, 5 days, 19 hours, 57 minutes, 28 seconds

System returned to ROM by Warm Start
Current system image file is "9200860-2A0503.biz"
Primary boot system image file is "9200860-2A0503.biz"
Backup boot system image file is "9200860-2A0402.biz"
NetVanta#

VERSION


$responsesNetVanta->{config} = <<'CONFIG';
Using 1255 bytes

!
!
hostname "NetVanta"
enable password bigtex
!
ip subnet-zero
ip classless
ip domain-name alterpoint.com
ip routing
!
event-history on
no logging forwarding
logging forwarding priority-level info
no logging email
logging email priority-level info
!
username "testlab" password "hobbit"
username "kermit" password "thefrog"
!
!
ip firewall check syn-flood
!
radius-server key cisco
!
radius-server host 10.100.32.137
!
aaa authentication login default group radius local
!
aaa authentication enable default group radius enable
!
aaa group server radius radius+
  server 10.100.32.137
!
!
interface eth 0/1
  ip address  10.100.23.10  255.255.255.0
  no shutdown
!
!
interface t1 1/1
  shutdown
!
!
router ospf
  network 10.100.23.0 0.0.0.255 area 23
  area 23 default-cost 100
!
!
ip route 0.0.0.0 0.0.0.0 10.100.23.1
ip route 0.0.0.0 0.0.0.0 10.100.24.1
!
no ip n-form agent
ip snmp agent
no ip ftp agent
!
!
!
snmp-server location "Austin"
snmp-server enable traps
snmp-server community public RO
snmp-server community testenv RW
snmp-server community Asit RO
snmp-server community Clayton RO
line con 0
  login
!
line telnet 0 4
  login local-userlist
  password "hobbit"
!
end


CONFIG

$responsesNetVanta->{interfaces} = <<'INTS';
eth 0/1 is UP, line protocol is UP
  Hardware address is 00:A0:C8:0D:2D:58
  eth 0/1 Ip address is 10.100.23.10, netmask is 255.255.255.0
  MTU is 1500 bytes, BW is 100000 Kbit
  100Mb/s, negotiated full-duplex, configured full-duplex
  ARP type: ARPA; ARP timeout is 20 minutes
    784939 packets input, 59175838 bytes
    574620 unicasts, 210319 broadcasts, 0 multicasts input
    0 unknown protocol, 0 symbol errors, 0 discards
    0 input errors, 0 runts, 0 giants
    0 no buffer, 0 overruns, 0 internal receive errors
    0 alignment errors, 0 crc errors
    1409789 packets output, 103547003 bytes
    1409789 unicasts, 0 broadcasts, 0 multicasts output
    0 output errors, 0 deferred, 0 discards
    0 single, 0 multiple, 0 late collisions
    0 excessive collisions, 0 underruns
    0 internal transmit errors, 0 carrier sense errors
    0 resets, 0 throttles

t1 1/1 is administratively down
  T1 coding is B8ZS, framing is ESF
  Clock source is line, FDL type is ANSI
  Line build-out is 0dB
  No remote loopbacks, No network loopbacks
  Acceptance of remote loopback requests enabled

  DS0 Status: 123456789012345678901234
              ------------------------
  Status Legend: '-' = DS0 is unallocated
                 'N' = DS0 is dedicated (nailed)

  Line Status: -- No Alarms --

  Current Performance Statistics:
    0 Errored Seconds, 0 Bursty Errored Seconds
    0 Severely Errored Seconds, 0 Severely Errored Frame Seconds
    0 Unavailable Seconds, 0 Path Code Violations
    0 Line Code Violations, 0 Controlled Slip Seconds
    0 Line Errored Seconds, 0 Degraded Minutes
    0 packets input, 0 bytes, 0 no buffer
    0 runts, 0 giants, 0 throttles
    0 input errors, 0 CRC, 0 frame
    0 abort, 0 discards, 0 overruns
    0 packets output, 0 bytes, 0 underruns
    0 input clock glitches, 0 output clock glitches
    0 carrier lost, 0 cts lost
NetVanta#    

INTS

$responsesNetVanta->{startup_config} = <<'STUP';
NetVanta#show startup-config
Using 1255 bytes

!
!
hostname "NetVanta"
enable password bigtex
!
ip subnet-zero
ip classless
ip domain-name alterpoint.com
ip routing
!
event-history on
no logging forwarding
logging forwarding priority-level info
no logging email
logging email priority-level info
!
username "testlab" password "hobbit"
username "kermit" password "thefrog"
!
!
ip firewall check syn-flood
!
radius-server key cisco
!
radius-server host 10.100.32.137
!
aaa authentication login default group radius local
!
aaa authentication enable default group radius enable
!
aaa group server radius radius+
  server 10.100.32.137
!
!
interface eth 0/1
  ip address  10.100.23.10  255.255.255.0
  no shutdown
!
!
interface t1 1/1
  shutdown
!
!
router ospf
  network 10.100.23.0 0.0.0.255 area 23
  area 23 default-cost 100
!
!
ip route 0.0.0.0 0.0.0.0 10.100.23.1
ip route 0.0.0.0 0.0.0.0 10.100.24.1
!
no ip n-form agent
ip snmp agent
no ip ftp agent
!
!
!
snmp-server location "Austin"
snmp-server enable traps
snmp-server community public RO
snmp-server community testenv RW
snmp-server community Asit RO
snmp-server community Clayton RO
line con 0
  login
!
line telnet 0 4
  login local-userlist
  password "hobbit"
!
end


STUP

$responsesNetVanta->{running_config} = <<'RUN';
Building configuration...
!
!
hostname "NetVanta"
enable password bigtex
!
ip subnet-zero
ip classless
ip domain-name alterpoint.com
ip routing
!
event-history on
no logging forwarding
logging forwarding priority-level info
no logging email
logging email priority-level info
!
username "testlab" password "hobbit"
username "kermit" password "thefrog"
!
!
ip firewall check syn-flood
!
radius-server key cisco
!
radius-server host 10.100.32.137
!
aaa authentication login default group radius local
!
aaa authentication enable default group radius enable
!
aaa group server radius radius+
  server 10.100.32.137
!
!
interface eth 0/1
  ip address  10.100.23.10  255.255.255.0
  no shutdown
!
!
interface t1 1/1
  shutdown
!
!
router ospf
  network 10.100.23.0 0.0.0.255 area 23
  area 23 default-cost 100
!
!
ip route 0.0.0.0 0.0.0.0 10.100.23.1
ip route 0.0.0.0 0.0.0.0 10.100.24.1
!
no ip n-form agent
ip snmp agent
no ip ftp agent
!
!
!
snmp-server location "Austin"
snmp-server enable traps
snmp-server community public RO
snmp-server community testenv RW
snmp-server community Asit RO
snmp-server community Clayton RO
line con 0
  login
!
line telnet 0 4
  login local-userlist
  password "hobbit"
!
end


RUN

$responsesNetVanta->{files} = <<'FILES';
Files:
1948204 9200860-2A0503.biz
1741550 9200860-2A0402.biz
   1216 startup-config.bak
   1254 startup-config
3698520 bytes used, 3003560 available, 6702080 total
NetVanta#

FILES

$responsesNetVanta->{static_routes} = <<'ROUTES';
S    0.0.0.0/0 [1/0] via 10.100.23.1, eth 0/1
NetVanta#

ROUTES
