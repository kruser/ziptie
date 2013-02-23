package Data6506;

use strict;
use warnings;
use Exporter 'import';
our @EXPORT_OK = qw($responses);

our $responses = {};

$responses->{'show_power'} = <<'EO_SHOWPOWER';
show power
system power redundancy mode = redundant
system power total =     1153.32 Watts (27.46 Amps @ 42V)
system power used =       657.30 Watts (15.65 Amps @ 42V)
system power available =  496.02 Watts (11.81 Amps @ 42V)
                        Power-Capacity PS-Fan Output Oper
PS   Type               Watts   A @42V Status Status State
---- ------------------ ------- ------ ------ ------ -----
1    WS-CAC-1300W       1153.32 27.46  OK     OK     on
2    WS-CAC-1300W       1153.32 27.46  OK     OK     on
                        Pwr-Requested  Pwr-Allocated  Admin Oper
Slot Card-Type          Watts   A @42V Watts   A @42V State State
---- ------------------ ------- ------ ------- ------ ----- -----
1    WS-X6K-S2U-MSFC2    142.38  3.39   142.38  3.39  on    on
2    WS-X6408-GBIC       142.38  3.39   142.38  3.39  on    on
3    WS-X6348-RJ-45      100.38  2.39   100.38  2.39  on    on
4    WS-X6348-RJ-45      100.38  2.39   100.38  2.39  on    on
6    WS-SVC-FWM-1        171.78  4.09   171.78  4.09  on    on
AUS-6506#
EO_SHOWPOWER

$responses->{'show_inventory'} = <<'EO_SHOWINVENTORY';
show inventory
NAME: "WS-C6506", DESCR: "Cisco Systems Catalyst 6500 6-slot Chassis System"
PID: WS-C6506          , VID:    , SN: SAL08290JNU

NAME: "WS-C6K-VTT 1", DESCR: "VTT 1"
PID: WS-C6K-VTT        , VID:    , SN: SMT0826A845

NAME: "WS-C6K-VTT 2", DESCR: "VTT 2"
PID: WS-C6K-VTT        , VID:    , SN: SMT0826C533

NAME: "WS-C6K-VTT 3", DESCR: "VTT 3"
PID: WS-C6K-VTT        , VID:    , SN: SMT0826C515

NAME: "WS-C6000-CL", DESCR: "C6k Clock 1"
PID: WS-C6000-CL       , VID:    , SN: SMT0827D056

NAME: "WS-C6000-CL", DESCR: "C6k Clock 2"
PID: WS-C6000-CL       , VID:    , SN: SMT0827D046

NAME: "1", DESCR: "WS-X6K-S2U-MSFC2 2 ports Catalyst 6000 supervisor 2 Rev. 5.1"
PID: WS-X6K-S2U-MSFC2  , VID:    , SN: SAL08445F8B

NAME: "sub-module of 1", DESCR: "WS-F6K-MSFC2 Cat6k MSFC 2 daughterboard Rev. 2.8"
PID: WS-F6K-MSFC2      , VID:    , SN: SAL08455TJ8

NAME: "sub-module of 1", DESCR: "WS-F6K-PFC2 Policy Feature Card 2 Rev. 3.5"
PID: WS-F6K-PFC2       , VID:    , SN: SAL08455V6V

NAME: "2", DESCR: "WS-X6408-GBIC 8 port 1000mb ethernet Rev. 2.7"
PID: WS-X6408-GBIC     , VID:    , SN: SAD0409037P

NAME: "3", DESCR: "WS-X6348-RJ-45 48 port 10/100 mb RJ45 Rev. 1.1"
PID: WS-X6348-RJ-45    , VID:    , SN: SAD043306HV

NAME: "4", DESCR: "WS-X6348-RJ-45 48 port 10/100 mb RJ45 Rev. 1.1"
PID: WS-X6348-RJ-45    , VID:    , SN: SAL04300Z7B

NAME: "6", DESCR: "WS-SVC-FWM-1 6 ports Firewall Module Rev. 4.0"
PID: WS-SVC-FWM-1      , VID:    , SN: SAD0948024S

NAME: "PS 1 WS-CAC-1300W", DESCR: "110/220v AC power supply, 1360 watt 1"
PID: WS-CAC-1300W      , VID:    , SN: ACP03291041

NAME: "PS 2 WS-CAC-1300W", DESCR: "110/220v AC power supply, 1360 watt 2"
PID: WS-CAC-1300W      , VID:    , SN: ACP04060158


AUS-6506#
EO_SHOWINVENTORY

$responses->{'show_module'} = <<'EO_SHOWMOD';
show module
Mod Ports Card Type                              Model              Serial No.
--- ----- -------------------------------------- ------------------ -----------
  1    2  Catalyst 6000 supervisor 2 (Active)    WS-X6K-S2U-MSFC2   SAL08445F8B
  2    8  8 port 1000mb ethernet                 WS-X6408-GBIC      SAD0409037P
  3   48  48 port 10/100 mb RJ45                 WS-X6348-RJ-45     SAD043306HV
  4   48  48 port 10/100 mb RJ45                 WS-X6348-RJ-45     SAL04300Z7B
  6    6  Firewall Module                        WS-SVC-FWM-1       SAD0948024S

Mod MAC addresses                       Hw    Fw           Sw           Status
--- ---------------------------------- ------ ------------ ------------ -------
  1  0009.1247.fd58 to 0009.1247.fd59   5.1   7.1(1)       12.2(17d)SXB Ok
  2  00b0.c2f0.78b0 to 00b0.c2f0.78b7   2.7   5.4(2)       8.3(0.110)TE Ok
  3  0001.6411.de1c to 0001.6411.de4b   1.1   5.4(2)       8.3(0.110)TE Ok
  4  0030.19db.c594 to 0030.19db.c5c3   1.1   5.3(1)       8.3(0.110)TE Ok
  6  0015.6214.d9dc to 0015.6214.d9e3   4.0   7.2(1)       3.1(1)       Ok

Mod Sub-Module                  Model              Serial        Hw     Status 
--- --------------------------- ------------------ ------------ ------- -------
  1 Policy Feature Card 2       WS-F6K-PFC2        SAL08455V6V   3.5    Ok
  1 Cat6k MSFC 2 daughterboard  WS-F6K-MSFC2       SAL08455TJ8   2.8    Ok

Mod Online Diag Status 
--- -------------------
  1 Pass
  2 Pass
  3 Pass
  4 Minor Error
  6 Pass
AUS-6506#
EO_SHOWMOD

$responses->{'file_systems'}->{'bootflash'} = <<'EO_BOOTFLASH';
show bootflash
-#- ED ----type---- --crc--- -seek-- nlen -length- ---------date/time--------- name
1   .. image        997D2076  218B88   23  1673992 Jul 9 2005 18:34:03 +01:00 c6msfc2-boot-mz.121-7.E
2   .. image        F80FE611  956D04   23  7069948 Jul 9 2005 18:35:50 +01:00 c6msfc2-js-mz.121-3a.E4
3   .. image        F25115AF 1D34978   27 20306932 May 1 2006 21:15:34 +01:00 c6sup22-js-mz.121-26.E2.bin

1881736 bytes available (29051256 bytes used)
AUS-6506#
EO_BOOTFLASH

$responses->{'file_systems'}->{'sup-bootflash'} = <<'EO_SHOWSUPBOOTFLASH';
show sup-bootflash

No files on device

31981568 bytes available (0 bytes used)
AUS-6506#
EO_SHOWSUPBOOTFLASH

$responses->{'file_systems'}->{'slot0'} = <<'EO_SHOWSLOT0';
show slot0
-#- ED ----type---- --crc--- -seek-- nlen -length- ---------date/time--------- name
1   .. config       DE0E1E70   22EF8    1    11893 Apr 26 2006 20:50:32 +01:00 n
2   .. image        C2BDD16F 22A8D24   33 36199852 Jun 26 2006 19:17:23 +01:00 c6k222-pk9sv-mz.122-17d.SXB10.bin
3   .. image        5C41E688 2F54AFC   31 13286744 May 7 2007 20:10:40 +01:00 c2800nm-ipbase-mz.123-8.T11.bin

17216772 bytes available (49498876 bytes used)
AUS-6506#
EO_SHOWSLOT0

$responses->{'version'} = <<'EO_SHOWVER';
show version
Cisco Internetwork Operating System Software 
IOS (tm) c6sup2_rp Software (c6sup2_rp-PK9SV-M), Version 12.2(17d)SXB10, RELEASE SOFTWARE (fc1)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2005 by cisco Systems, Inc.
Compiled Thu 11-Aug-05 15:44 by kellythw
Image text-base: 0x40008FBC, data-base: 0x41FE0000

ROM: System Bootstrap, Version 12.2(17r)S1, RELEASE SOFTWARE (fc1)
BOOTLDR: c6sup2_rp Software (c6sup2_rp-PK9SV-M), Version 12.2(17d)SXB10, RELEASE SOFTWARE (fc1)

AUS-6506 uptime is 8 weeks, 4 days, 23 hours, 14 minutes
Time since AUS-6506 switched to active is 8 weeks, 4 days, 23 hours, 13 minutes
System returned to ROM by power-on (SP by reload)
System restarted at 17:10:34 S Fri Sep 14 2007
System image file is "slot0:c6k222-pk9sv-mz.122-17d.SXB10.bin"


This product contains cryptographic features and is subject to United
States and local country laws governing import, export, transfer and
use. Delivery of Cisco cryptographic products does not imply
third-party authority to import, export, distribute or use encryption.
Importers, exporters, distributors and users are responsible for
compliance with U.S. and local country laws. By using this product you
agree to comply with applicable laws and regulations. If you are unable
to comply with U.S. and local laws, return this product immediately.

A summary of U.S. laws governing Cisco cryptographic products may be found at:
http://www.cisco.com/wwl/export/crypto/tool/stqrg.html

If you require further assistance please contact us by sending email to
export@cisco.com.

cisco WS-C6506 (R7000) processor (revision 3.0) with 458752K/65536K bytes of memory.
Processor board ID SAL08290JNU
R7000 CPU at 300Mhz, Implementation 0x27, Rev 3.3, 256KB L2, 1024KB L3 Cache
Last reset from power-on
X.25 software, Version 3.0.0.
Bridging software.
5 Virtual Ethernet/IEEE 802.3  interface(s)
96 FastEthernet/IEEE 802.3 interface(s)
16 Gigabit Ethernet/IEEE 802.3 interface(s)
381K bytes of non-volatile configuration memory.

32768K bytes of Flash internal SIMM (Sector size 512K).
Configuration register is 0x2102

AUS-6506#
EO_SHOWVER

$responses->{'show_fs'} = <<'EO_SHOWFILESYS';
show file systems
File Systems:

     Size(b)     Free(b)      Type  Flags  Prefixes
           -           -      disk     rw   disk0:
*   66715648    17216772     flash     rw   slot0: flash: sup-slot0:
    31981568    31981568     flash     rw   sup-bootflash:
    37141798           0    opaque     ro   sup-microcode:
           0   126651176    opaque     wo   sup-image:
      129004      127848     nvram     rw   const_nvram:
      391160      370764     nvram     rw   nvram:
           -           -    opaque     rw   null:
           -           -    opaque     rw   system:
           -           -   network     rw   tftp:
    30932992     1881736     flash     rw   bootflash:
           -           -   network     rw   rcp:
           -           -   network     rw   ftp:

AUS-6506#
EO_SHOWFILESYS

$responses->{'running_config'} = <<'EO_RUNNING';
!
! Last configuration change at 19:51:30 S Tue Nov 13 2007 by testlab
! NVRAM config last updated at 19:48:47 S Tue Nov 13 2007 by testlab
!
version 12.2
service timestamps debug uptime
service timestamps log uptime
no service password-encryption
service counters max age 10
!
hostname AUS-6506
!
boot system flash bootflash:c6sup22-js-mz.121-26.E2.bin
boot system slot0:c6k222-pk9sv-mz.122-17d.SXB10.bin
boot bootldr bootflash:c6msfc2-boot-mz.121-7.E
aaa new-model
aaa authentication login default group tacacs+ local
aaa authentication enable default group tacacs+
aaa accounting exec default start-stop group tacacs+
aaa accounting commands 1 default start-stop group tacacs+
aaa accounting commands 7 default start-stop group tacacs+
aaa accounting commands 15 default start-stop group tacacs+
enable secret level 5 5 $1$i24e$02uo/P01ObCByHFvC2JNC1
enable secret level 8 5 $1$/McA$TIIwRV0qsxAKqImCXjSXU1
enable password 7 13071E151F091C
!
username testlab password 0 hobbit
username testbling privilege 15 password 7 06120A32584C05100B10
username rickchen access-class 80 privilege 15 password 7 031652080D
username superfly
username radware password 0 radware-pass
clock timezone S 1
firewall multiple-vlan-interfaces
firewall module 6 vlan-group 10
firewall vlan-group 10  25,26,50,51,200,300
vtp mode transparent
ip subnet-zero
!
!
ip tftp source-interface FastEthernet3/12
no ip ftp passive
ip ftp username anonymous
ip ftp password 7 1108151112005A5E57
ip domain-list inside.eclyptic.com
ip domain-list alterpoint.com
no ip domain-lookup
ip domain-name alterpoint.com
ip name-server 10.10.1.9
!
ip vrf blue
 rd 1:1
!
ip vrf green
 rd 1:2
!
ipv6 unicast-routing
ipv6 cef
mpls label protocol ldp
mpls ldp logging neighbor-changes
mpls traffic-eng tunnels
mls flow ip destination
mls flow ipx destination
mls verify ip length minimum 
mls verify ipx length minimum 
!
!
!
!
!
!
!
spanning-tree mode pvst
spanning-tree vlan 25 priority 8192
diagnostic cns publish cisco.cns.device.diag_results
diagnostic cns subscribe cisco.cns.device.diag_commands
!
redundancy
 mode rpr-plus
 main-cpu
  auto-sync running-config
  auto-sync standard
!
vlan internal allocation policy ascending
!
vlan 25
 name ceige1
!
vlan 26
 name ceige3
!
vlan 50
 name ceige2
!
vlan 51
 name ceige4
!
vlan 100
 name foo
!
vlan 101
 name v1
!
vlan 102
 name v2
!
vlan 200
 name FWSMOutside
!
vlan 300
 name FWSMInside
!
vlan 950
 name dork
!
class-map match-all emoney
  match access-group name emoney
!
!
policy-map llq
  class emoney
    priority percent 20
!
!
!
interface Loopback0
 description blah
 ip address 10.100.20.210 255.255.255.255
 ipv6 enable
 ipv6 ospf 100 area 0
!
interface Loopback30
 no ip address
!
interface Tunnel5
 ip unnumbered Loopback0
 no ip mroute-cache
 tunnel destination 12.12.12.12
 tunnel mode mpls traffic-eng
 tunnel mpls traffic-eng autoroute announce
 tunnel mpls traffic-eng priority 3 3
 tunnel mpls traffic-eng bandwidth  512
 tunnel mpls traffic-eng path-option 3 dynamic
!
interface Tunnel50
 ip vrf forwarding green
 ip address 10.250.3.3 255.255.255.0
 tunnel source Loopback0
 tunnel destination 10.5.5.5
!
interface Tunnel100
 description ISATAP tunnel
 no ip address
 no ip redirects
 ipv6 address 2002:36::/64 eui-64
 tunnel source Loopback0
 tunnel mode ipv6ip isatap
!
interface GigabitEthernet1/1
 no ip address
!
interface GigabitEthernet1/2
 no ip address
 shutdown
!
interface GigabitEthernet2/1
 no ip address
 shutdown
!
interface GigabitEthernet2/2
 no ip address
 shutdown
!
interface GigabitEthernet2/3
 no ip address
 shutdown
!
interface GigabitEthernet2/4
 no ip address
 shutdown
!
interface GigabitEthernet2/5
 no ip address
 shutdown
!
interface GigabitEthernet2/6
 no ip address
 shutdown
!
interface GigabitEthernet2/7
 no ip address
 shutdown
!
interface GigabitEthernet2/8
 no ip address
 shutdown
!
interface GigabitEthernet2/8.100
!
interface GigabitEthernet2/8.101
!
interface GigabitEthernet2/8.451
 encapsulation dot1Q 451
 ip address 10.231.1.11 255.255.0.0
!
interface GigabitEthernet2/8.452
 encapsulation dot1Q 452
 ip address 10.232.1.12 255.255.0.0
!
interface FastEthernet3/1
 no ip address
 ipv6 address 3FFE:FFFF:0:C002::/54
 ipv6 enable
 ipv6 ospf 100 area 0
!
interface FastEthernet3/2
 no ip address
 switchport
 switchport access vlan 200
 switchport trunk allowed vlan 1-4000
 switchport mode access
!
interface FastEthernet3/3
 no ip address
 speed 10
 duplex full
 switchport
 switchport trunk allowed vlan 1-4000
!
interface FastEthernet3/4
 no ip address
 shutdown
 switchport
 switchport trunk allowed vlan 1-4000
!
interface FastEthernet3/5
 no ip address
 speed 10
 duplex half
 switchport
 switchport trunk allowed vlan 1-4000
!
interface FastEthernet3/6
 no ip address
 shutdown
 switchport
 switchport trunk allowed vlan 1-4000
!
interface FastEthernet3/7
 no ip address
 shutdown
 switchport
 switchport trunk allowed vlan 1-4000
!
interface FastEthernet3/8
 no ip address
 shutdown
 switchport
 switchport trunk allowed vlan 1-4000
!
interface FastEthernet3/9
 no ip address
 shutdown
 switchport
 switchport trunk allowed vlan 1-4000
!
interface FastEthernet3/10
 no ip address
 switchport
 switchport trunk allowed vlan 1-4000
!
interface FastEthernet3/11
 no ip address
 speed 100
 duplex full
 switchport
 switchport trunk allowed vlan 1-4000
 ip rsvp bandwidth 1000 sub-pool 2
!
interface FastEthernet3/12
 bandwidth 10000
 ip address 10.100.20.10 255.255.255.252
 speed 10
 duplex full
 ipv6 address 6FFE:FFFF:0:C001::/54
 ipv6 enable
 ipv6 ospf 100 area 0
 mpls traffic-eng tunnels
 tag-switching ip
 service-policy output llq
 ip rsvp bandwidth 1024 1024
!
interface FastEthernet3/13
 description to lab core
 bandwidth 10000
 ip address 10.100.20.2 255.255.255.248
 speed 10
 duplex full
 ipv6 address 9FFE:FFFF:0:C002::/54
 ipv6 ospf 100 area 0
!
interface FastEthernet3/14
 description to 3825
 ip address 10.100.20.69 255.255.255.252
 speed 10
 duplex full
 ipv6 address 2FFE:FFFF:0:C001::/54
 ipv6 enable
 ipv6 ospf 100 area 0
!
interface FastEthernet3/15
 no ip address
 switchport
 switchport access vlan 100
 switchport trunk allowed vlan 1-4000
 switchport mode access
!
interface FastEthernet3/16
 no ip address
 shutdown
!
interface FastEthernet3/17
 no ip address
 shutdown
!
interface FastEthernet3/18
 no ip address
 shutdown
!
interface FastEthernet3/19
 no ip address
 shutdown
!
interface FastEthernet3/20
 no ip address
 shutdown
!
interface FastEthernet3/21
 no ip address
 shutdown
!
interface FastEthernet3/22
 no ip address
 shutdown
!
interface FastEthernet3/23
 no ip address
 shutdown
!
interface FastEthernet3/24
 no ip address
 duplex full
!
interface FastEthernet3/25
 description FWSMinside
 no ip address
 switchport
 switchport access vlan 300
 switchport trunk allowed vlan 1-4000
 switchport mode access
!
interface FastEthernet3/26
 no ip address
 shutdown
!
interface FastEthernet3/27
 no ip address
 shutdown
!
interface FastEthernet3/28
 no ip address
 shutdown
!
interface FastEthernet3/29
 no ip address
 ip access-group 80 in
 ip access-group 80 out
!
interface FastEthernet3/30
 no ip address
 shutdown
!
interface FastEthernet3/31
 no ip address
 shutdown
!
interface FastEthernet3/32
 no ip address
 shutdown
!
interface FastEthernet3/33
 no ip address
 shutdown
!
interface FastEthernet3/34
 no ip address
 shutdown
!
interface FastEthernet3/35
 no ip address
!
interface FastEthernet3/36
 no ip address
 shutdown
!
interface FastEthernet3/37
 no ip address
 switchport
 switchport access vlan 50
 switchport trunk allowed vlan 1-4000
 switchport mode access
!
interface FastEthernet3/38
 no ip address
 shutdown
!
interface FastEthernet3/39
 no ip address
 shutdown
!
interface FastEthernet3/40
 no ip address
 shutdown
!
interface FastEthernet3/41
 no ip address
 shutdown
!
interface FastEthernet3/42
 no ip address
 shutdown
!
interface FastEthernet3/43
 no ip address
 shutdown
!
interface FastEthernet3/44
 no ip address
 shutdown
!
interface FastEthernet3/45
 no ip address
 shutdown
!
interface FastEthernet3/46
 no ip address
 shutdown
!
interface FastEthernet3/47
 no ip address
 switchport
 switchport trunk allowed vlan 1-4000
 switchport mode access
!
interface FastEthernet3/48
 no ip address
 shutdown
!
interface FastEthernet4/1
 description *Do Not Remove HSRP Config* to SEA-7206
 ip address 172.16.0.2 255.255.255.240
 standby 1 ip 172.16.0.3
 standby 1 timers 5 15
 standby 1 preempt
!
interface FastEthernet4/2
 no ip address
!
interface FastEthernet4/3
 no ip address
 shutdown
!
interface FastEthernet4/4
 no ip address
 shutdown
!
interface FastEthernet4/5
 no ip address
 shutdown
!
interface FastEthernet4/6
 no ip address
 shutdown
!
interface FastEthernet4/7
 no ip address
 shutdown
!
interface FastEthernet4/8
 no ip address
 shutdown
!
interface FastEthernet4/9
 no ip address
 shutdown
!
interface FastEthernet4/10
 no ip address
 shutdown
!
interface FastEthernet4/11
 no ip address
 shutdown
!
interface FastEthernet4/12
 no ip address
 shutdown
!
interface FastEthernet4/13
 no ip address
!
interface FastEthernet4/14
 no ip address
 shutdown
!
interface FastEthernet4/15
 no ip address
 shutdown
!
interface FastEthernet4/16
 no ip address
 shutdown
!
interface FastEthernet4/17
 no ip address
 shutdown
!
interface FastEthernet4/18
 no ip address
 shutdown
!
interface FastEthernet4/19
 no ip address
 shutdown
!
interface FastEthernet4/20
 no ip address
 shutdown
!
interface FastEthernet4/21
 no ip address
 shutdown
!
interface FastEthernet4/22
 no ip address
 shutdown
!
interface FastEthernet4/23
 no ip address
 shutdown
!
interface FastEthernet4/24
 no ip address
 shutdown
!
interface FastEthernet4/25
 no ip address
!
interface FastEthernet4/26
 no ip address
 shutdown
!
interface FastEthernet4/27
 no ip address
 shutdown
!
interface FastEthernet4/28
 no ip address
 shutdown
!
interface FastEthernet4/29
 no ip address
 shutdown
!
interface FastEthernet4/30
 no ip address
 shutdown
!
interface FastEthernet4/31
 no ip address
 shutdown
!
interface FastEthernet4/32
 no ip address
 shutdown
!
interface FastEthernet4/33
 no ip address
 shutdown
!
interface FastEthernet4/34
 description TestQC
 no ip address
!
interface FastEthernet4/35
 no ip address
 shutdown
!
interface FastEthernet4/36
 no ip address
 shutdown
!
interface FastEthernet4/37
 no ip address
!
interface FastEthernet4/38
 no ip address
 shutdown
!
interface FastEthernet4/39
 no ip address
 shutdown
!
interface FastEthernet4/40
 no ip address
 shutdown
!
interface FastEthernet4/41
 no ip address
 shutdown
!
interface FastEthernet4/42
 no ip address
 shutdown
!
interface FastEthernet4/43
 no ip address
 shutdown
!
interface FastEthernet4/44
 no ip address
 shutdown
!
interface FastEthernet4/45
 no ip address
 shutdown
!
interface FastEthernet4/46
 no ip address
 shutdown
!
interface FastEthernet4/47
 no ip address
 shutdown
!
interface FastEthernet4/48
 no ip address
 shutdown
!
interface Vlan1
 no ip address
!
interface Vlan20
 no ip address
 no ip igmp snooping explicit-tracking
 shutdown
!
interface Vlan215
 ip address 12.12.12.12 255.0.0.0
 no ip igmp snooping explicit-tracking
!
interface Vlan220
 no ip address
 no ip igmp snooping explicit-tracking
!
interface Vlan401
 ip address 192.168.77.133 255.255.255.0
 no ip igmp snooping explicit-tracking
 shutdown
!
router ospf 100
 log-adjacency-changes
 redistribute connected subnets
 network 10.100.20.0 0.0.0.255 area 0
 mpls traffic-eng router-id Loopback0
 mpls traffic-eng area 0
!
router rip
 network 10.0.0.0
!
router bgp 200
 no synchronization
 bgp log-neighbor-changes
 neighbor 10.100.20.212 remote-as 200
 neighbor 10.100.20.212 update-source Loopback0
 neighbor 10.100.20.213 remote-as 200
 neighbor 10.100.20.213 update-source Loopback0
 neighbor 10.100.20.214 remote-as 200
 neighbor 10.100.20.214 update-source Loopback0
 neighbor 10.100.20.215 remote-as 200
 neighbor 10.100.20.215 update-source Loopback0
 neighbor 10.100.20.221 remote-as 200
 neighbor 10.100.20.221 update-source Loopback0
 neighbor 10.100.20.222 remote-as 200
 neighbor 10.100.20.222 update-source Loopback0
 no auto-summary
!
ip classless
ip default-network 0.0.0.0
ip route vrf blue 10.5.5.0 255.255.255.0 10.20.40.30
no ip http server
ip http secure-server
ip tacacs source-interface Loopback0
!
!
ip access-list standard emoney
 permit 10.10.1.218 log
ip access-list standard homey
 deny   10.100.16.0 0.0.0.255
 permit any
!
logging trap notifications
logging facility local0
logging 10.100.33.22
logging 10.100.32.88
logging 10.100.32.39
logging 10.100.32.43
logging 10.100.32.206
logging 10.100.31.72
access-list 10 permit 192.168.2.0 0.0.0.255 log
access-list 50 deny   0.0.0.0 255.255.0.0
access-list 50 permit any
access-list 80 permit 10.100.1.30
access-list 80 deny   any log
access-list 101 permit eigrp 10.1.6.0 0.0.0.255 10.1.6.0 0.0.0.255 log-input
access-list 101 permit eigrp 10.2.6.0 0.0.0.252 10.2.6.0 0.0.0.252 log-input
access-list 101 permit tcp host 10.5.2.25 any eq smtp
access-list 101 permit udp host 10.6.3.7 10.6.3.0 0.0.0.255 lt 1024
access-list 101 deny   ip any any log
access-list 101 permit tcp host 10.8.45.23 gt 1024 10.8.0.0 0.0.255.255
access-list 101 deny   ip any any
access-list 101 permit tcp host 10.14.56.243 range 1 443 10.24.56.0 0.0.0.254 log
access-list 105 permit ip any any log
access-list 106 permit tcp 10.100.20.16 0.0.0.3 172.16.0.0 0.0.0.15 eq telnet
access-list 106 deny   tcp any 172.16.0.0 0.0.0.15 eq telnet
access-list 106 permit tcp any any
queue-list 1 protocol ip 3
cdp timer 10
ipv6 router ospf 100
 log-adjacency-changes
!
!
snmp-server community public RO
snmp-server community mystring RO
snmp-server community training RO
snmp-server community len RO
snmp-server community public123 RO
snmp-server location Aus-Rack3a
snmp-server contact jsmith
snmp-server chassis-id SAL08290JNU 
snmp-server enable traps config
snmp-server enable traps sonet
snmp-server host 10.10.1.65 b00g3r3at3r 
snmp-server host 10.10.1.187 public 
snmp-server host 10.10.1.230 public 
snmp-server host 10.10.1.94 public 
snmp-server host 10.10.101.102 public 
snmp-server host 10.100.32.33 public 
snmp-server host 10.10.1.237 testenv 
snmp-server host 10.100.1.230 v3rb0ten! 
!
tftp-server slot0:c2800nm-ipbase-mz.123-8.T11.bin
tacacs-server host 10.100.32.137
tacacs-server directed-request
tacacs-server key cisco
!
dial-peer cor custom
!
!
!
banner motd ^C
TGIF Cold Bud in Fridge
^C
!
line con 0
 exec-timeout 0 0
 password 7 045304040D2858
line vty 0 4
 session-timeout 30 
 exec-timeout 60 0
 password 7 011B0906590212
 transport input telnet ssh
line vty 5 15
 session-timeout 30 
 exec-timeout 60 0
 transport input telnet ssh
!
end
EO_RUNNING

1;