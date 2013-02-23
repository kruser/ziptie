package DataCatOS5500;

use strict;
use warnings;
use Exporter 'import';
our @EXPORT_OK = qw($responsesCatOS5500);

our $responsesCatOS5500 = {};

$responsesCatOS5500->{version} = <<'END';
show version



WARNING: This product contains cryptographic features and is subject to United
States and local country laws governing import, export, transfer and use.
Delivery of Cisco cryptographic products does not imply third-party authority
to import, export, distribute or use encryption. Importers, exporters,
distributors and users are responsible for compliance with U.S. and local
country laws. By using this product you agree to comply with applicable
laws and regulations. If you are unable to comply with U.S. and local laws,
return this product immediately.


WS-C5500 Software, Version McpSW: 6.4(2) NmpSW: 6.4(2)
Copyright (c) 1995-2003 by Cisco Systems
NMP S/W compiled on Mar  7 2003, 15:52:51
MCP S/W compiled on Mar 07 2003, 15:52:20

System Bootstrap Version: 3.1.2

Hardware Version: 1.3  Model: WS-C5500  Serial #: 069012487

Mod Port Model      Serial #  Versions
--- ---- ---------- --------- ----------------------------------------
1   2    WS-X5530   009996959 Hw : 1.9
                              Fw : 3.1.2
                              Fw1: 4.2(1)
                              Sw : 6.4(2)
         WS-F5521   010434283 Hw : 1.0
         WS-U5531   009981138 Hw : 1.1
2   1    WS-X5302   013486768 Hw : 7.5
                              Fw : 20.22
                              Fw1: 3.1(1)
                              Sw : 12.2(10d)
3   12   WS-X5213A  006056009 Hw : 2.0
                              Fw : 1.4
                              Sw : 6.4(2)
4   48   WS-X5020   005217990 Hw : 2.0
                              Fw : 2.1(1)
                              Sw : 6.4(2)
5   48   WS-X5020   005219199 Hw : 2.0
                              Fw : 2.1(1)
                              Sw : 6.4(2)

       DRAM                    FLASH                   NVRAM
Module Total   Used    Free    Total   Used    Free    Total Used  Free
------ ------- ------- ------- ------- ------- ------- ----- ----- -----
1       65536K  23659K  41877K   8192K   4184K   4008K  512K  186K  326K

Uptime is 62 days, 11 hours, 54 minutes
DAL-C5500> (enable)

END

$responsesCatOS5500->{module} = <<'END';
show module

Mod Slot Ports Module-Type               Model               Sub Status
--- ---- ----- ------------------------- ------------------- --- --------
1   1    2     10/100BaseTX Supervisor   WS-X5530            yes faulty
2   2    1     Route Switch              WS-X5302            no  ok
3   3    12    10/100BaseTX Ethernet     WS-X5213A           no  ok
4   4    48    4 Segment 10BaseT Etherne WS-X5020            no  ok
5   5    48    4 Segment 10BaseT Etherne WS-X5020            no  ok

Mod Module-Name          Serial-Num
--- -------------------- --------------------
1                        00009996959
2                        00013486768
3                        00006056009
4                        00005217990
5                        00005219199

Mod MAC-Address(es)                        Hw     Fw         Sw
--- -------------------------------------- ------ ---------- -----------------
1   00-10-11-e8-23-00 to 00-10-11-e8-26-ff 1.9    3.1.2      6.4(2)
2   00-e0-1e-92-94-1a to 00-e0-1e-92-94-1b 7.5    20.22      12.2(10d)
3   00-e0-1e-51-f3-ec to 00-e0-1e-51-f3-f7 2.0    1.4        6.4(2)
4   00-60-70-ea-bd-38 to 00-60-70-ea-bd-3b 2.0    2.1(1)     6.4(2)
5   00-60-70-ea-cc-cc to 00-60-70-ea-cc-cf 2.0    2.1(1)     6.4(2)

Mod Sub-Type Sub-Model Sub-Serial Sub-Hw
--- -------- --------- ---------- ------
1   NFFC     WS-F5521  0010434283 1.0
1   uplink   WS-U5531  0009981138 1.1
DAL-C5500> (enable)

END

$responsesCatOS5500->{config} = <<'END';
show config all

...........
..................
...............
.................
.................
.................








..

begin
!
# ***** ALL (DEFAULT and NON-DEFAULT) CONFIGURATION *****
!
!
#time: Sat Jul 28 2007, 15:36:04 
!
#version 6.4(2)
!
set option fddi-user-pri disabled
set feature fw-disable disable
set feature no-isl-entries disable
set rsmautostate multirsm disable
set password $2$Za1a$aAGkOfRNKXGKNF29C7ToF/
set enablepass $2$Cq.J$HexO1pPflmmQWsFcx9CZ60
set prompt Console>
set length 24 default
set logout 20
set config mode binary
set banner motd ^C^C
!
#test
set test diaglevel complete
set test packetbuffer sun 03:30
set test packetbuffer enable
!
#errordetection
set errordetection inband disable
set errordetection memory disable
set errordetection portcounter disable
!
#system
set system baud  9600
set system modem disable
set system name  DAL-C5500
set system location PQR's Dallas Office
set system contact  
set system countrycode 
set traffic monitor 100
set system core-dump disable
set system core-file  slot0:crashinfo
set feature log-command enable
set feature loop-detect enable
set feature supmon enable
!
#frame distribution method
set port channel all distribution mac both
!
#mac address reduction
set spantree macreduction disable
!
#default portcost mode
set spantree defaultcostmode short
!
#snmp
set snmp community read-only      public
set snmp community read-write     private
set snmp community read-write-all secret
set snmp rmon disable
set snmp rmonmemory 85
set snmp trap disable module
set snmp trap disable chassis
set snmp trap disable bridge
set snmp trap disable repeater
set snmp trap disable vtp
set snmp trap disable auth
set snmp trap disable ippermit
set snmp trap disable vmps
set snmp trap disable entity
set snmp trap disable config
set snmp trap disable stpx
set snmp trap disable syslog
set snmp trap disable system
set snmp extendedrmon vlanmode disable
set snmp extendedrmon vlanagent disable
set snmp extendedrmon enable
set snmp trap 10.100.100.2 XXX port 162 owner CLI index 3
set snmp trap 10.100.100.3 XXX port 162 owner CLI index 2
!
#tacacs+
set tacacs attempts 3
set tacacs directedrequest disable
set tacacs timeout 5
!
#radius
set radius deadtime 0
set radius timeout 5
set radius retransmit 2
!
#kerberos
!
#authentication
set authentication login tacacs disable console 
set authentication login tacacs disable telnet 
set authentication login tacacs disable http 
set authentication enable tacacs disable console 
set authentication enable tacacs disable telnet 
set authentication enable tacacs disable http 
set authentication login radius disable console 
set authentication login radius disable telnet 
set authentication login radius disable http 
set authentication enable radius disable console 
set authentication enable radius disable telnet 
set authentication enable radius disable http 
set authentication login local enable console 
set authentication login local enable telnet 
set authentication login local enable http 
set authentication enable local enable console 
set authentication enable local enable telnet 
set authentication enable local enable http 
set authentication login kerberos disable console 
set authentication login kerberos disable telnet 
set authentication login kerberos disable http 
set authentication enable kerberos disable console 
set authentication enable kerberos disable telnet 
set authentication enable kerberos disable http 
set authentication login attempt 3 console
set authentication login attempt 3 telnet
set authentication login lockout 0 console
set authentication login lockout 0 telnet
set authentication enable attempt 3 console
set authentication enable attempt 3 telnet
set authentication enable lockout 0 console
set authentication enable lockout 0 telnet
!
#bridge
set bridge apart enable
set bridge fddicheck disable
set bridge ipx snaptoether   8023raw
set bridge ipx 8022toether   8023
set bridge ipx 8023rawtofddi snap
!
#vtp
set vtp mode server
set vtp v2 disable
set vtp pruning disable
set vtp pruneeligible 2-1000
clear vtp pruneeligible 1001-1005
set dot1q-all-tagged disable
!
#ip
set feature mdg enable
set feature psync-recovery no-powerdown
set interface sc0 1 10.100.24.3/255.255.255.0 10.100.24.255

set interface sc0 up
set interface sl0 0.0.0.0 0.0.0.0
set interface sl0 up
set arp agingtime 1200
set ip redirect   enable
set ip unreachable   enable
set ip fragmentation enable
set ip route 0.0.0.0/0.0.0.0         10.100.24.1    
set ip alias default         0.0.0.0
!
#command alias
!
#vmps
set vmps server retry 3
set vmps server reconfirminterval 60
set vmps downloadmethod tftp 
set vmps downloadserver 0.0.0.0 vmps-config-database.1 
set vmps state disable

!
#rcp
set rcp username 
!
#dns
set ip dns disable
!
#spantree
#uplinkfast groups
set spantree uplinkfast disable
#backbonefast
set spantree backbonefast disable
#portfast
set spantree portfast bpdu-guard disable
set spantree portfast bpdu-filter disable
#bpdu-skewing
set spantree bpdu-skewing disable
set spantree enable  all
#vlan                         <VlanId>
set spantree fwddelay 15     1003
set spantree hello    2      1003
set spantree maxage   20     1003
set spantree priority 32768  1003
set spantree portstate 1003 block 0
set spantree portcost 1003 62
set spantree portpri  1003 4
set spantree portfast 1003 disable
set spantree fwddelay 15     1005
set spantree hello    2      1005
set spantree maxage   20     1005
set spantree priority 32768  1005
set spantree multicast-address 1005 ieee
#vlan(defaults)
set spantree fwddelay 15     1
set spantree hello    2      1
set spantree maxage   20     1
set spantree priority 32768  1
!
#cgmp
set cgmp disable
set cgmp leave disable
!
#syslog
set logging console enable
set logging telnet enable
set logging server disable
set logging level cdp 4 default
set logging level mcast 4 default
set logging level dtp 4 default
set logging level dvlan 4 default
set logging level earl 4 default
set logging level fddi 4 default
set logging level ip 4 default
set logging level pruning 4 default
set logging level snmp 4 default
set logging level spantree 4 default
set logging level sys 4 default
set logging level tac 4 default
set logging level tcp 4 default
set logging level telnet 4 default
set logging level tftp 4 default
set logging level vtp 4 default
set logging level vmps 4 default
set logging level kernel 4 default
set logging level filesys 4 default
set logging level drip 4 default
set logging level pagp 4 default
set logging level mgmt 4 default
set logging level mls 4 default
set logging level protfilt 4 default
set logging level security 4 default
set logging level radius 4 default
set logging level udld 4 default
set logging level gvrp 4 default
set logging level qos 4 default
set logging server facility LOCAL7
set logging server severity 4
set logging timestamp enable
set logging buffer 500
set logging history 1
!
#ntp
set ntp broadcastclient disable
set ntp broadcastdelay 3000
set ntp client disable
set ntp authentication disable
clear timezone
set summertime disable 
set summertime recurring
!
#set boot command
set boot config-register 0x2102
set boot system flash slot1:cat5000-sup3k9.6-4-2.bin
set boot system flash bootflash:cat5000-sup3.4-5-11.bin
!
#permit list
set ip permit disable telnet
set ip permit disable ssh
set ip permit disable snmp
!
#permanent arp entries
!
#drip
set tokenring reduction enable
set tokenring distrib-crf disable
!
#igmp
set igmp disable
set igmp fastleave disable
!
#rgmp
set rgmp disable
!
#protocolfilter
set protocolfilter disable
!
#mls
set mls enable ip
set mls disable ipx
set mls flow destination
set mls nde disable
set mls agingtime long-duration 1920
set mls agingtime 256
set mls agingtime ipx 256
set mls agingtime fast 0 0
!
#standby ports
set standbyports disable
!
#vlan mapping
!
#gmrp
set gmrp disable
!
#garp
set garp timer all 200 600 10000
!
#cdp
set cdp interval 60
set cdp holdtime 180
set cdp enable
set cdp version v2
set cdp format device-id other
!
#dot1x
set dot1x system-auth-control enable
set dot1x quiet-period 60
set dot1x tx-period 30
set dot1x supp-timeout 30
set dot1x server-timeout 30
set dot1x max-req 2
set dot1x re-authperiod 3600
!
#qos
set qos disable
set qos map 1q4t 1 1 cos 0
set qos map 1q4t 1 1 cos 1
set qos map 1q4t 1 2 cos 2
set qos map 1q4t 1 2 cos 3
set qos map 1q4t 1 3 cos 4
set qos map 1q4t 1 3 cos 5
set qos map 1q4t 1 4 cos 6
set qos map 1q4t 1 4 cos 7
set qos wred-threshold 1q4t tx queue 1 10 20 40 100 
!
#udld
set udld disable
set udld interval 15
!
#port channel
set port channel 1/1-2 1
!
#accounting
set accounting exec disable
set accounting connect disable
set accounting system disable
set accounting commands disable
set accounting suppress null-username disable
set accounting update new-info 
!
#errdisable timeout
set errdisable-timeout disable other
set errdisable-timeout disable udld
set errdisable-timeout disable duplex-mismatch
set errdisable-timeout disable bpdu-guard
set errdisable-timeout disable channel-misconfig
set errdisable-timeout interval 300
!
#http configuration
set ip http server disable
set ip http port 80
!
#crypto key
set crypto key rsa 1024
!
# default port status is enable
!
!
#module 1 : 2-port 10/100BaseTX Supervisor
set module name    1    
set vlan 1    1/1-2
set port enable     1/1-2
set port level      1/1-2  normal
set port speed      1/1-2  auto
set port trap       1/1-2  disable
set port name       1/1-2
set port dot1x 1/1-2 port-control force-authorized
set port dot1x 1/1-2 multiple-host disable
set port dot1x 1/1-2 re-authentication disable
set port security 1/1-2 disable age 0 maximum 1 shutdown 0 violation shutdown
set port broadcast  1/1-2  100.00%
set port membership 1/1-2  static
set port protocol 1/1-2 ip on
set port protocol 1/1-2 ipx auto
set port protocol 1/1-2 group auto
set cdp enable   1/1-2
set udld disable 1/1-2 
set udld aggressive-mode disable 1/1-2 
set trunk 1/1  auto isl 1-1005
set trunk 1/2  auto isl 1-1005
set spantree portfast    1/1-2 disable
set spantree portcost    1/1-2  100
set spantree portpri     1/1-2  32
set spantree portvlanpri 1/1  0
set spantree portvlanpri 1/2  0
set spantree portvlancost 1/1  cost 99
set spantree portvlancost 1/2  cost 99
set spantree guard none 1/1-2
set port gmrp   1/1-2  enable
set gmrp registration normal   1/1-2
set gmrp fwdall disable    1/1-2
set port channel 1/1-2 mode auto silent
set port jumbo  1/1-2  disable
!
#module 2 : 1-port Route Switch
set module name    2    
set port level      2/1  normal
set port name       2/1
set cdp enable   2/1
set trunk 2/1  on isl 1-1005
set spantree portcost    2/1  5
set spantree portpri     2/1  32
set spantree portvlanpri 2/1  0
set spantree portvlancost 2/1  cost 4
set spantree guard none 2/1
set port gmrp   2/1  enable
set gmrp registration normal   2/1
set gmrp fwdall disable    2/1
!
#module 3 : 12-port 10/100BaseTX Ethernet
set module name    3    
set module enable  3
set vlan 1    3/1-12
set port enable     3/1-12
set port level      3/1-12  normal
set port speed      3/1-12  auto
set port trap       3/1-12  disable
set port name       3/1-12
set port dot1x 3/1-12 port-control force-authorized
set port dot1x 3/1-12 multiple-host disable
set port dot1x 3/1-12 re-authentication disable
set port security 3/1-12 disable age 0 maximum 1 shutdown 0 violation shutdown
set port broadcast  3/1-12  0
set port membership 3/1-12  static
set port protocol 3/1-12 ip on
set port protocol 3/1-12 ipx auto
set port protocol 3/1-12 group auto
set cdp enable   3/1-12
set udld disable 3/1-12 
set udld aggressive-mode disable 3/1-12 
set trunk 3/1  auto isl 1-1005
set trunk 3/2  auto isl 1-1005
set trunk 3/3  auto isl 1-1005
set trunk 3/4  auto isl 1-1005
set trunk 3/5  auto isl 1-1005
set trunk 3/6  auto isl 1-1005
set trunk 3/7  auto isl 1-1005
set trunk 3/8  auto isl 1-1005
set trunk 3/9  auto isl 1-1005
set trunk 3/10 auto isl 1-1005
set trunk 3/11 auto isl 1-1005
set trunk 3/12 auto isl 1-1005
set spantree portfast    3/1-12 disable
set spantree portcost    3/1-12  100
set spantree portpri     3/1-12  32
set spantree portvlanpri 3/1  0
set spantree portvlanpri 3/2  0
set spantree portvlanpri 3/3  0
set spantree portvlanpri 3/4  0
set spantree portvlanpri 3/5  0
set spantree portvlanpri 3/6  0
set spantree portvlanpri 3/7  0
set spantree portvlanpri 3/8  0
set spantree portvlanpri 3/9  0
set spantree portvlanpri 3/10 0
set spantree portvlanpri 3/11 0
set spantree portvlanpri 3/12 0
set spantree portvlancost 3/1  cost 99
set spantree portvlancost 3/2  cost 99
set spantree portvlancost 3/3  cost 99
set spantree portvlancost 3/4  cost 99
set spantree portvlancost 3/5  cost 99
set spantree portvlancost 3/6  cost 99
set spantree portvlancost 3/7  cost 99
set spantree portvlancost 3/8  cost 99
set spantree portvlancost 3/9  cost 99
set spantree portvlancost 3/10 cost 99
set spantree portvlancost 3/11 cost 99
set spantree portvlancost 3/12 cost 99
set spantree guard none 3/1-12
set port gmrp   3/1-12  enable
set gmrp registration normal   3/1-12
set gmrp fwdall disable    3/1-12
set port jumbo  3/1-12  disable
!
#module 4 : 48-port 4 Segment 10BaseT Ethernet
set module name    4    
set module enable  4
set vlan 1    4/1,4/13,4/25,4/37
set port enable     4/1-48
set port level      4/1,4/13,4/25,4/37  normal
set port trap       4/1-48  disable
set port name       4/1-48
set port security 4/1-48 disable age 0 maximum 1 shutdown 0 violation shutdown
set port broadcast  4/1,4/13,4/25,4/37  0
set port membership 4/1,4/13,4/25,4/37  static
set port protocol 4/1,4/13,4/25,4/37 ip on
set port protocol 4/1,4/13,4/25,4/37 ipx auto
set port protocol 4/1,4/13,4/25,4/37 group auto
set cdp enable   4/1,4/13,4/25,4/37
set udld disable 4/1,4/13,4/25,4/37 
set udld aggressive-mode disable 4/1,4/13,4/25,4/37 
set spantree portfast    4/1,4/13,4/25,4/37 disable
set spantree portcost    4/1,4/13,4/25,4/37  100
set spantree portpri     4/1,4/13,4/25,4/37  32
set spantree guard none 4/1-48
set port gmrp   4/1,4/13,4/25,4/37  enable
set gmrp registration normal   4/1,4/13,4/25,4/37
set gmrp fwdall disable    4/1,4/13,4/25,4/37
set port jumbo  4/1-48  disable
!
#module 5 : 48-port 4 Segment 10BaseT Ethernet
set module name    5    
set module enable  5
set vlan 1    5/1,5/13,5/25,5/37
set port enable     5/1-48
set port level      5/1,5/13,5/25,5/37  normal
set port trap       5/1-48  disable
set port name       5/1-48
set port security 5/1-48 disable age 0 maximum 1 shutdown 0 violation shutdown
set port broadcast  5/1,5/13,5/25,5/37  0
set port membership 5/1,5/13,5/25,5/37  static
set port protocol 5/1,5/13,5/25,5/37 ip on
set port protocol 5/1,5/13,5/25,5/37 ipx auto
set port protocol 5/1,5/13,5/25,5/37 group auto
set cdp enable   5/1,5/13,5/25,5/37
set udld disable 5/1,5/13,5/25,5/37 
set udld aggressive-mode disable 5/1,5/13,5/25,5/37 
set spantree portfast    5/1,5/13,5/25,5/37 disable
set spantree portcost    5/1,5/13,5/25,5/37  100
set spantree portpri     5/1,5/13,5/25,5/37  32
set spantree guard none 5/1-48
set port gmrp   5/1,5/13,5/25,5/37  enable
set gmrp registration normal   5/1,5/13,5/25,5/37
set gmrp fwdall disable    5/1,5/13,5/25,5/37
set port jumbo  5/1-48  disable
!
#module 6 empty
!
#module 7 empty
!
#module 8 empty
!
#module 9 empty
!
#module 10 empty
!
#module 11 empty
!
#module 12 empty
!
#module 13 empty
!
#switch port analyzer
!
#cam
set cam agingtime 1,1003,1005 300
!
#qos mac-cos
!
#qos router-mac
!
#gvrp
set gvrp dynamic-vlan-creation disable
set gvrp disable
!
#authorization
set authorization exec disable console
set authorization exec disable telnet
set authorization enable disable console
set authorization enable disable telnet
set authorization commands disable console
set authorization commands disable telnet
end
DAL-C5500> (enable) 

END

$responsesCatOS5500->{filesys} = <<'END';
show flash filesys



-------- F I L E   S Y S T E M   S T A T U S --------
  Device Number = 2
DEVICE INFO BLOCK: c5500 bootflash
  Magic Number          =  6887635  File System Vers =    10000 (1.0)
  Length                =   800000  Sector Size      =    40000
  Programming Algorithm =        5  Erased State     = ffffffff
  File System Offset    =    40000  Length =   740000
  MONLIB Offset         =      100  Length =    10028
  Bad Sector Map Offset =    3fffc  Length =        4
  Squeeze Log Offset    =   780000  Length =    40000
  Squeeze Buffer Offset =   7c0000  Length =    40000
  Num Spare Sectors     = 0
    Spares: 
STATUS INFO:
  Writable
  NO File Open for Write
  Complete Stats
  No Unrecovered Errors
  No Squeeze in progress
USAGE INFO:
  Bytes Used     = 355c4c  Bytes Available = 3ea3b4
  Bad Sectors    =   0     Spared Sectors  = 0
  OK Files       =   6     Bytes = 3558b0
  Deleted Files  =   1     Bytes =     1c
  Files w/Errors =   0     Bytes =      0

DAL-C5500> (enable)

END

$responsesCatOS5500->{files} = <<'END';
show flash

-#- ED --type-- --crc--- -seek-- nlen -length- -----date/time------ name
  1 .. ffffffff 248ce3d1   42858   10    10200 Dec 17 2004 22:02:20 jcb.config
  2 .. ffffffff 4a9c6634   44cec    6     9233 Mar 16 2005 17:33:26 config
  3 .. ffffffff cb92a20a  394cc4   23  3473239 Jul 25 2005 15:21:14 cat5000-sup3.4-5-11.bin
  4 .. ffffffff 489dbc78  395a94   18     3405 Jan 19 2007 11:49:50 10.100.24.3.config
  5 .. ffffffff        1  395b14   12        0 Feb 02 2007 14:34:54 apconfig.cfg
  6 .D ffffffff 61aee4a3  395bb0   20       28 Jul 10 2007 14:44:13 spec.txt.10.100.24.3
  7 .. ffffffff 61aee4a3  395c4c   20       28 Jul 10 2007 17:03:57 spec.txt.10.100.24.3

4105140 bytes available (3497036 bytes used)
DAL-C5500> (enable)

END

$responsesCatOS5500->{interfaces} = <<'END';
show interface

sl0: flags=51<UP,POINTOPOINT,RUNNING>
        slip 0.0.0.0 dest 0.0.0.0
sc0: flags=63<UP,BROADCAST,RUNNING>
        vlan 1 inet 10.100.24.3 netmask 255.255.255.0 broadcast 10.100.24.255
DAL-C5500> (enable) 

END

$responsesCatOS5500->{static_routes} = <<'END';
show ip route

Fragmentation   Redirect   Unreachable
-------------   --------   -----------
enabled         enabled    enabled 

The primary gateway: 10.100.24.1
Destination      Gateway          RouteMask    Flags   Use       Interface
---------------  ---------------  ----------   -----   --------  ---------
default          10.100.24.1      0x0          UG      1613261     sc0
10.100.24.0      10.100.24.3      0xffffff00   U       55          sc0
default          default          0xff000000   UH      0           sl0
DAL-C5500> (enable)

END

$responsesCatOS5500->{stp} = <<'END';
show spantree

VLAN 1
Spanning tree enabled
Spanning tree type          ieee

Designated Root             00-17-94-45-ee-80
Designated Root Priority    24800
Designated Root Cost        123
Designated Root Port        3/1
Root Max Age   20 sec   Hello Time 2  sec   Forward Delay 15 sec

Bridge ID MAC ADDR          00-10-11-e8-23-00
Bridge ID Priority          32768
Bridge Max Age 20 sec   Hello Time 2  sec   Forward Delay 15 sec

Port                     Vlan Port-State    Cost      Prio Portfast Channel_id
------------------------ ---- ------------- --------- ---- -------- ----------
 1/1                     1    blocking            100   32 disabled 0         
 1/2                     1    not-connected       100   32 disabled 0         
 2/1                     1    forwarding            5   32 disabled 0         
 3/1                     1    forwarding          100   32 disabled 0         
 3/2                     1    not-connected       100   32 disabled 0         
 3/3                     1    not-connected       100   32 disabled 0         
 3/4                     1    not-connected       100   32 disabled 0         
 3/5                     1    not-connected       100   32 disabled 0         
 3/6                     1    not-connected       100   32 disabled 0         
 3/7                     1    not-connected       100   32 disabled 0         
 3/8                     1    not-connected       100   32 disabled 0         
 3/9                     1    not-connected       100   32 disabled 0         
 3/10                    1    not-connected       100   32 disabled 0         
 3/11                    1    not-connected       100   32 disabled 0         
 3/12                    1    not-connected       100   32 disabled 0         
 4/1-12                  1    not-connected       100   32 disabled 0         
 4/13-24                 1    not-connected       100   32 disabled 0         
 4/25-36                 1    not-connected       100   32 disabled 0         
 4/37-48                 1    not-connected       100   32 disabled 0         
 5/1-12                  1    not-connected       100   32 disabled 0         
 5/13-24                 1    not-connected       100   32 disabled 0         
 5/25-36                 1    not-connected       100   32 disabled 0         
 5/37-48                 1    not-connected       100   32 disabled 0         
DAL-C5500> (enable)

END

$responsesCatOS5500->{vlans} = <<'END';
show vlan

VLAN Name                             Status    IfIndex Mod/Ports, Vlans
---- -------------------------------- --------- ------- ------------------------
1    default                          active    5       1/1-2
                                                        3/1-12
                                                        4/1-48
                                                        5/1-48
1002 fddi-default                     active    6       
1003 token-ring-default               active    9       
1004 fddinet-default                  active    7       
1005 trnet-default                    active    8       


VLAN Type  SAID       MTU   Parent RingNo BrdgNo Stp  BrdgMode Trans1 Trans2
---- ----- ---------- ----- ------ ------ ------ ---- -------- ------ ------
1    enet  100001     1500  -      -      -      -    -        0      0
1002 fddi  101002     1500  -      -      -      -    -        0      0
1003 trcrf 101003     1500  -      -      -      -    -        0      0
1004 fdnet 101004     1500  -      -      -      -    -        0      0
1005 trbrf 101005     1500  -      -      -      ibm  -        0      0


VLAN DynCreated  RSPAN
---- ---------- --------
1    static     disabled
1002 static     disabled
1003 static     disabled
1004 static     disabled
1005 static     disabled


VLAN AREHops STEHops Backup CRF 1q VLAN
---- ------- ------- ---------- -------
1003 7       7       off        
DAL-C5500> (enable)  

END

$responsesCatOS5500->{vtp_info} = <<'END';
show vtp domain

Domain Name                      Domain Index VTP Version Local Mode  Password
-------------------------------- ------------ ----------- ----------- ----------
                                 1            2           server      -

Vlan-count Max-vlan-storage Config Revision Notifications
---------- ---------------- --------------- -------------
5          1023             0               disabled

Last Updater    V2 Mode  Pruning  PruneEligible on Vlans
--------------- -------- -------- -------------------------
0.0.0.0         disabled disabled 2-1000
DAL-C5500> (enable)  

END
