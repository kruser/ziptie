package DataCatOS5000;

use strict;
use warnings;
use Exporter 'import';
our @EXPORT_OK = qw($responsesCatOS5000);

our $responsesCatOS5000 = {};

$responsesCatOS5000->{version} = <<'END';
show version


WARNING: This product contains cryptographic features and is subject to United
States and local country laws governing import, export, transfer and use.
Delivery of Cisco cryptographic products does not imply third-party authority
to import, export, distribute or use encryption. Importers, exporters,
distributors and users are responsible for compliance with U.S. and local
country laws. By using this product you agree to comply with applicable
laws and regulations. If you are unable to comply with U.S. and local laws,
return this product immediately.

WS-C5000 Software, Version McpSW: 6.4(10) NmpSW: 6.4(10)
Copyright (c) 1995-2004 by Cisco Systems
NMP S/W compiled on Apr 16 2004, 16:46:19
MCP S/W compiled on Apr 16 2004, 15:16:24

System Bootstrap Version: 5.1(1)

Hardware Version: 1.2  Model: WS-C5000  Serial #: 021230524

Mod Port Model      Serial #  Versions
--- ---- ---------- --------- ----------------------------------------
1   2    WS-X5550   021230524 Hw : 1.2
                              Fw : 5.1(1)
                              Fw1: 5.2(1)
                              Sw : 6.4(10)
2   24   WS-X5224   009605133 Hw : 1.4
                              Fw : 3.1(1)
                              Sw : 6.4(10)
3   24   WS-X5010   005758185 Hw : 3.1
                              Fw : 1.1
                              Sw : 6.4(10)
4   1    WS-X5302   007459905 Hw : 4.5
                              Fw : 20.9
                              Fw1: 2.2(4)
                              Sw : 11.2(15a)P, P

       DRAM                    FLASH                   NVRAM
Module Total   Used    Free    Total   Used    Free    Total Used  Free
------ ------- ------- ------- ------- ------- ------- ----- ----- -----
1       32768K  19219K  13549K   8192K   4089K   4103K  512K  186K  326K

Uptime is 0 day, 10 hours, 20 minutes
LON-C5000> (enable)

END

$responsesCatOS5000->{module} = <<'END';
show module

Mod Slot Ports Module-Type               Model               Sub Status
--- ---- ----- ------------------------- ------------------- --- --------
1   1    2     1000BaseX Supervisor IIIG WS-X5550            no  faulty
2   2    24    10/100BaseTX Ethernet     WS-X5224            no  ok
3   3    24    10BaseT Ethernet          WS-X5010            no  ok
4   4    1     Route Switch              WS-X5302            no  ok

Mod Module-Name          Serial-Num
--- -------------------- --------------------
1                        00021230524
2                        00009605133
3                        00005758185
4                        00007459905

Mod MAC-Address(es)                        Hw     Fw         Sw
--- -------------------------------------- ------ ---------- -----------------
1   00-02-ba-62-b4-00 to 00-02-ba-62-b7-ff 1.2    5.1(1)     6.4(10)
2   00-10-7b-86-af-40 to 00-10-7b-86-af-57 1.4    3.1(1)     6.4(10)
3   00-e0-1e-7b-4a-a0 to 00-e0-1e-7b-4a-b7 3.1    1.1        6.4(10)
4   00-e0-1e-91-cd-ca to 00-e0-1e-91-cd-cb 4.5    20.9       11.2(15a)P, P
LON-C5000> (enable)

END

$responsesCatOS5000->{config} = <<'END';
show config all

.............
.................
.................
.................
...............



..

begin
!
# ***** ALL (DEFAULT and NON-DEFAULT) CONFIGURATION *****
!
!
#time: Fri Jul 27 2007, 12:46:30 
!
#version 6.4(10)
!
set option fddi-user-pri enabled
set feature fw-disable disable
set feature no-isl-entries disable
set password $2$fLsD$1XeXFWX8JfZKzOJ2rv8C90
set enablepass $2$rFnA$gyC9cbBFm6NleslBcJ//d1
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
set errordetection packet-buffer errdisable
!
#system
set system baud  9600
set system modem disable
set system name  LON-C5000
set system location ABC's London Office
set system contact  pitest1
set system countrycode 
set traffic monitor 100
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
set snmp community read-write     testenv
set snmp community read-write-all secret
set snmp rmon disable
set snmp rmonmemory 85
set snmp trap disable module
set snmp trap disable chassis
set snmp trap disable bridge
set snmp trap disable repeater
set snmp trap enable  vtp
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
set vtp domain test12
set vtp mode transparent
set vtp passwd Bla

END

$responsesCatOS5000->{interfaces} = <<'END';
show interface
sl0: flags=51<UP,POINTOPOINT,RUNNING>
        slip 0.0.0.0 dest 0.0.0.0
sc0: flags=63<UP,BROADCAST,RUNNING>
        vlan 1 inet 192.168.5.3 netmask 255.255.255.0 broadcast 192.168.5.255
LON-C5000> (enable) 

END

$responsesCatOS5000->{static_routes} = <<'END';
show ip route
Fragmentation   Redirect   Unreachable
-------------   --------   -----------
enabled         enabled    enabled 
 
The primary gateway: 192.168.5.1
Destination      Gateway          RouteMask    Flags   Use       Interface
---------------  ---------------  ----------   -----   --------  ---------
default          192.168.5.1      0x0          UG      18949       sc0
192.168.5.0      192.168.5.3      0xffffff00   U       0           sc0
default          default          0xff000000   UH      0           sl0
LON-C5000> (enable)

END

$responsesCatOS5000->{stp} = <<'END';
show spantree
VLAN 1
Spanning tree enabled
Spanning tree type          ieee
 
Designated Root             00-02-ba-62-b4-00
Designated Root Priority    32768
Designated Root Cost        0
Designated Root Port        1/0
Root Max Age   20 sec   Hello Time 2  sec   Forward Delay 15 sec
 
Bridge ID MAC ADDR          00-02-ba-62-b4-00
Bridge ID Priority          32768
Bridge Max Age 20 sec   Hello Time 2  sec   Forward Delay 15 sec
 
Port                     Vlan Port-State    Cost      Prio Portfast Channel_id
------------------------ ---- ------------- --------- ---- -------- ----------
 1/1                     1    not-connected         4   32 disabled 0         
 1/2                     1    not-connected         4   32 disabled 0         
 2/1                     1    not-connected       100   32 disabled 0         
 2/2                     1    forwarding           19   32 disabled 0         
 2/3                     1    not-connected       100   32 disabled 0         
 2/4                     1    not-connected       100   32 disabled 0         
 2/5                     1    not-connected       100   32 disabled 0         
 2/6                     1    not-connected       100   32 disabled 0         
 2/7                     1    not-connected       100   32 disabled 0         
 2/8                     1    not-connected       100   32 disabled 0         
 2/9                     1    not-connected       100   32 disabled 0         
 2/10                    1    not-connected       100   32 disabled 0         
 2/11                    1    not-connected       100   32 disabled 0         
 2/12                    1    not-connected       100   32 disabled 0         
 2/13                    1    not-connected       100   32 disabled 0         
 2/14                    1    not-connected       100   32 disabled 0         
 2/15                    1    not-connected       100   32 disabled 0         
 2/16                    1    not-connected       100   32 disabled 0         
 2/17                    1    not-connected       100   32 disabled 0         
 2/18                    1    not-connected       100   32 disabled 0         
 2/19                    1    not-connected       100   32 disabled 0         
 2/20                    1    not-connected       100   32 disabled 0         
 2/21                    1    not-connected       100   32 disabled 0         
 2/22                    1    not-connected       100   32 disabled 0         
 2/23                    1    not-connected       100   32 disabled 0         
 2/24                    1    not-connected       100   32 disabled 0         
 3/1                     1    not-connected       100   32 disabled 0         
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
 3/13                    1    not-connected       100   32 disabled 0         
 3/14                    1    not-connected       100   32 disabled 0         
 3/15                    1    not-connected       100   32 disabled 0         
 3/16                    1    not-connected       100   32 disabled 0         
 3/17                    1    not-connected       100   32 disabled 0         
 3/18                    1    not-connected       100   32 disabled 0         
 3/19                    1    not-connected       100   32 disabled 0         
 3/20                    1    not-connected       100   32 disabled 0         
 3/21                    1    not-connected       100   32 disabled 0         
 3/22                    1    not-connected       100   32 disabled 0         
 3/23                    1    not-connected       100   32 disabled 0         
 3/24                    1    not-connected       100   32 disabled 0         
 4/1                     1    forwarding            5   32 disabled 0         
LON-C5000> (enable)  

END

$responsesCatOS5000->{vlans} = <<'END';
show vlan
VLAN Name                             Status    IfIndex Mod/Ports, Vlans
---- -------------------------------- --------- ------- ------------------------
1    default                          active    5       1/1-2
                                                        2/1-24
                                                        3/1-24
40   VLAN0040                         active    61      
110  Bla&in                           active    62      
120  RSM-vlan                         active    64      
1002 fddi-default                     active    6       
1003 trcrf-default                    active    9       
1004 fddinet-default                  active    7       
1005 trbrf-default                    active    8       1003
 
 
VLAN Type  SAID       MTU   Parent RingNo BrdgNo Stp  BrdgMode Trans1 Trans2
---- ----- ---------- ----- ------ ------ ------ ---- -------- ------ ------
1    enet  100001     1500  -      -      -      -    -        0      0
40   enet  100040     1500  -      -      -      -    -        0      0
110  enet  100110     1500  -      -      -      -    -        0      0
120  enet  100120     1500  -      -      -      -    -        0      0
1002 fddi  101002     1500  -      -      -      -    -        0      0
1003 trcrf 101003     4472  1005   0xccc  -      ieee srb      0      0
1004 fdnet 101004     1500  -      -      -      -    -        0      0
1005 trbrf 101005     4472  -      -      0xf    ibm  -        0      0
 
 
VLAN DynCreated  RSPAN
---- ---------- --------
1    static     disabled
40   static     disabled
110  static     disabled
120  static     disabled
1002 static     disabled
1003 static     disabled
1004 static     disabled
1005 static     disabled
 
 
VLAN AREHops STEHops Backup CRF 1q VLAN
---- ------- ------- ---------- -------
1003 7       7       off        
LON-C5000> (enable)  

END

$responsesCatOS5000->{vtp_info} = <<'END';
show vtp domain
Domain Name                      Domain Index VTP Version Local Mode  Password
-------------------------------- ------------ ----------- ----------- ----------
test12                           1            2           Transparent configured
 
Vlan-count Max-vlan-storage Config Revision Notifications
---------- ---------------- --------------- -------------
8          1023             0               enabled
 
Last Updater    V2 Mode  Pruning  PruneEligible on Vlans
--------------- -------- -------- -------------------------
192.168.5.3     enabled  disabled 2-1000
LON-C5000> (enable)  

END
