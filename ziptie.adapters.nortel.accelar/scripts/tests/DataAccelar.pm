package DataAccelar;

use strict;
use warnings;
use Exporter 'import';
our @EXPORT_OK = qw($responsesAccelar);

our $responsesAccelar = {};

$responsesAccelar->{config} = <<'END';
#
# box type             : Accelar-1100
# boot monitor version : v2.0.0
# software version     : 2.0.0
#

#
# HARDWARE CONFIGURATION
#

# slot 1        1x1000BaseLXWG      ARU2         GID4         GMAC4
# slot 2        2x1000BaseSXWG      ARU1         GID4         GMAC4
# slot 3        16x100BaseTXWG      ARU1         QUID3        PIC3
# ssf           1100                SQUID3       SWIP2        Xy2

#
# SYSTEM CONFIGURATION
#

config
cli
        password ro "franz" "kafka"
        password rwa "testlab" "hobbit"
back
sys
set
        contact "satish"
        location "Downtown"
        snmp community l2 austintestcommunity2
        snmp community l3 austintestcommunity
        snmp community rw testenv
        snmp community rwa austintestcommunity
back
syslog
back

#
# ACCESS-POLICY CONFIGURATION
#

access-policy
policy 1
back
back
back

#
# STG CONFIGURATION
#

stg 1
        add ports 1/1,2/1-2/2,3/1-3/15
back

#
# MLT CONFIGURATION
#


#
# TRAFFIC-FILTER CONFIGURATION
#

ip
traffic-filter
back
back

#
# WEB CONFIGURATION
#

web-server
back

#
# PORT CONFIGURATION
#

ethernet 1/1
        ip
        l3-igmp
        back
        dvmrp
        back
        dhcp-relay
        back
        ospf
        back
        rip
        back
        traffic-filter
        back
        back
        stg 1
        back
back
ethernet 2/1
        ip
        l3-igmp
        back
        dvmrp
        back
        dhcp-relay
        back
        ospf
        back
        rip
        back
        traffic-filter
        back
        back
        stg 1
        back
back
ethernet 2/2
        ip
        l3-igmp
        back
        dvmrp
        back
        dhcp-relay
        back
        ospf
        back
        rip
        back
        traffic-filter
        back
        back
        stg 1
        back
back
ethernet 3/1
        ip
        l3-igmp
        back
        dvmrp
        back
        dhcp-relay
        back
        ospf
        back
        rip
        back
        traffic-filter
        back
        back
        stg 1
        back
back
ethernet 3/2
        ip
        l3-igmp
        back
        dvmrp
        back
        dhcp-relay
        back
        ospf
        back
        rip
        back
        traffic-filter
        back
        back
        stg 1
        back
back
ethernet 3/3
        ip
        l3-igmp
        back
        dvmrp
        back
        dhcp-relay
        back
        ospf
        back
        rip
        back
        traffic-filter
        back
        back
        stg 1
        back
back
ethernet 3/4
        ip
        l3-igmp
        back
        dvmrp
        back
        dhcp-relay
        back
        ospf
        back
        rip
        back
        traffic-filter
        back
        back
        stg 1
        back
back
ethernet 3/5
        ip
        l3-igmp
        back
        dvmrp
        back
        dhcp-relay
        back
        ospf
        back
        rip
        back
        traffic-filter
        back
        back
        stg 1
        back
back
ethernet 3/6
        ip
        l3-igmp
        back
        dvmrp
        back
        dhcp-relay
        back
        ospf
        back
        rip
        back
        traffic-filter
        back
        back
        stg 1
        back
back
ethernet 3/7
        ip
        l3-igmp
        back
        dvmrp
        back
        dhcp-relay
        back
        ospf
        back
        rip
        back
        traffic-filter
        back
        back
        stg 1
        back
back
ethernet 3/8
        ip
        l3-igmp
        back
        dvmrp
        back
        dhcp-relay
        back
        ospf
        back
        rip
        back
        traffic-filter
        back
        back
        stg 1
        back
back
ethernet 3/9
        ip
        l3-igmp
        back
        dvmrp
        back
        dhcp-relay
        back
        ospf
        back
        rip
        back
        traffic-filter
        back
        back
        stg 1
        back
back
ethernet 3/10
        ip
        l3-igmp
        back
        dvmrp
        back
        dhcp-relay
        back
        ospf
        back
        rip
        back
        traffic-filter
        back
        back
        stg 1
        back
back
ethernet 3/11
        ip
        l3-igmp
        back
        dvmrp
        back
        dhcp-relay
        back
        ospf
        back
        rip
        back
        traffic-filter
        back
        back
        stg 1
        back
back
ethernet 3/12
        ip
        l3-igmp
        back
        dvmrp
        back
        dhcp-relay
        back
        ospf
        back
        rip
        back
        traffic-filter
        back
        back
        stg 1
        back
back
ethernet 3/13
        ip
        l3-igmp
        back
        dvmrp
        back
        dhcp-relay
        back
        ospf
        back
        rip
        back
        traffic-filter
        back
        back
        stg 1
        back
back
ethernet 3/14
        ip
        l3-igmp
        back
        dvmrp
        back
        dhcp-relay
        back
        ospf
        back
        rip
        back
        traffic-filter
        back
        back
        stg 1
        back
back
ethernet 3/15
        ip
        l3-igmp
        back
        dvmrp
        back
        dhcp-relay
        back
        ospf
        back
        rip
        back
        traffic-filter
        back
        back
        stg 1
        back
back
ethernet 3/16
        ip
        create 11.1.1.1/255.255.255.0
        l3-igmp
        back
        dvmrp
        back
        dhcp-relay
        back
        ospf
        back
        rip
        enable
        back
        traffic-filter
        back
        back
back

#
# VLAN CONFIGURATION
#

vlan 1
        ports add 1/1,2/1-2/2,3/1-3/15 member portmember
ip
        create 10.100.31.17/255.255.255.0
        l3-igmp
        back
        dvmrp
        back
        dhcp-relay
        back
        ospf
        metric 10
        back
        rip
        enable
        trigger enable
        back
back
ipx
back
back

#
# IPX CONFIGURATION
#

ipx
        rip
        back
        sap
        back
        set
        max-route 1500
        max-sap 1500
        max-static-route 128
        max-static-sap 64
        back
back

#
# IP & RIP CONFIGURATION
#

ip
        static-route create 0.0.0.0/0.0.0.0 next-hop 10.100.31.1 cost 1
rip
back

#
# DHCP CONFIGURATION
#

dhcp-relay
back

#
# TOS CONFIGURATION
#

diffserv-rule
back

#
# DVMRP CONFIGURATION
#

dvmrp
        interface 11.1.1.1
        back
        interface 10.100.31.17
        back
back

#
# IGMP CONFIGURATION
#

l3-igmp
        interface 11.1.1.1
        back
        interface 10.100.31.17
        back
back

#
# OSPF CONFIGURATION
#

ospf
        router-id 22.129.30.0
        interface 11.1.1.1
        back
        interface 10.100.31.17
        back
back

#
# IP POLICY CONFIGURATION
#

policy
        ospf
        back
        rip
        back
back

#
# UDP FWD CONFIGURATION
#

udpfwd
back
back
back

Accelar-1100#


END

$responsesAccelar->{system} = <<'END';

General Info :

        SysName      : Accelar-1100
        SysUpTime    : 248 day(s), 00:23:27
        SysContact   : satish
        SysLocation  : Downtown

Chassis Info :

        Chassis : 1100
        Serial# : 601SZ
        HwRev   : v3.0
        NumSlots: 3
        AruMode : AruOne
        EocMode : default

Power Supply Info :

        Ps#1 Status       : up
        Ps#1 Type         : 110V AC Power Supply
        Ps#1 Serial Number:
        Ps#1 Version      :
        Ps#1 Part Number  :

        Ps#2 Status       : empty

Fan Info :

        Fan#1: up
        Fan#2: up
        Fan#3: up

Card Info :

        Slot#            Type  Part#  Serial#   HwRev    Oper      Asic Version
                                                       Status
            1  1x1000BaseLXWG 875A06    DA08P    v1.0      up  GID4 GMAC 4  AR2
            2  2x1000BaseSXWG 593F00    B0110    v1.0      up  GID4 GMAC 4  AR1
            3  16x100BaseTXWG 615d00    601SZ    v3.0      up   SQ3   Xy 6  SW2
                                                              QUID3   PIC3  AR1

System Error Info :

        Send Trap        : false
        Error Code       : 33488905
        Error Severity   : 1

System Device Info :

        Autoboot               : true
        FactoryDefaults        : false
        SwitchPortIsolation    : false
        DebugMode              : false
        HighPriorityMode       : false
        LastBootSource         : flash:1
        Primary                : flash:1
        Secondary              : flash:1
        Tertiary               : net
        Configuration          : nvram
        FlashNumFiles          : 6
        FlashBytesUsed         : 3211264
        FlashBytesFree         : 983040
        PcmciaNumFiles         : 0
        PcmciaBytesUsed        : 0
        PcmciaBytesFree        : 0
        Action                 : 1
        Result                 : 1

Port Lock Info :

        Status       : off
        LockedPorts  :

Topology Status Info :

        Status       : on

Accelar-1100#


END

$responsesAccelar->{files} = <<'END';
Accelar-1100# directory
Device: flash
FN Name                             Flags    Length
-- ----                             -----    ------
1  acc2.0.0                           XZN   1805432
2  acc1.1.1                           XZN    994730
3  syslog                              LN    131072
4  config                              CN      5688
5  old.cfg                             CN      5788
6  config                              CN      6388
--                                           ------
6   files                      bytes used=  3211264 free=982864

Accelar-1100#


END

$responsesAccelar->{interfaces} = <<'END';
Accelar-1100# show ip interface

================================================================================
                                        Ip Interface
================================================================================
INTERFACE IP               NET              BCASTADDR  REASM
          ADDRESS          MASK             FORMAT     MAXSIZE
--------------------------------------------------------------------------------
Port3/16  11.1.1.1         255.255.255.0    ones       1500
Vlan1     10.100.31.17     255.255.255.0    ones       1500

Accelar-1100#


END

$responsesAccelar->{routes} = <<'END';

================================================================================
                                        Ip Route
================================================================================
            DST             MASK            NEXT COST VLAN   PORT  CACHE OWNER
--------------------------------------------------------------------------------
        0.0.0.0          0.0.0.0     10.100.31.1    1    1   3/1    TRUE STATIC
    10.100.31.0    255.255.255.0    10.100.31.17    1    1   -/-    TRUE  LOCAL
Total 2
------------------------ INACTIVE STATIC ROUTES ------------------------------
Total 0
Accelar-1100#


END

$responsesAccelar->{stp1} = <<'END';

================================================================================
                                        Stg Config
================================================================================
STG           BRIDGE  BRIDGE     FORWARD ENABLE STPTRAP
ID   PRIORITY MAX_AGE HELLO_TIME DELAY   STP    TRAP
--------------------------------------------------------------------------------
1    32768    2000    200        1500    true   true

STG  TAGGBPDU           TAGGBPDU PORT
ID   ADDRESS            VLAN_ID MEMBER
--------------------------------------------------------------------------------
1    00:00:00:00:00:00  0        1/1,2/1-2/2,3/1-3/15

Accelar-1100#


END

$responsesAccelar->{stp2} = <<'END';
show stg info status

================================================================================
                                        Stg Status
================================================================================
STG  BRIDGE            NUM   PROTOCOL      TOP     
ID   ADDRESS           PORTS SPECIFICATION CHANGES 
--------------------------------------------------------------------------------
1    00:e0:16:81:1e:01 18    ieee8021d     439     

STG  DESIGNATED        ROOT  ROOT  MAX  HELLO  HOLD  FORWARD 
ID   ROOT              COST  PORT  AGE  TIME   TIME  DELAY   
--------------------------------------------------------------------------------
1    00:17:94:45:ee:80 33    3/1   2000 200    1500  49      

Accelar-1100# 

END

$responsesAccelar->{vlans} = <<'END';
Accelar-1100# show vlan info basic

================================================================================
                                        Vlan Basic
================================================================================
VLAN                              STG
ID  NAME             TYPE         ID  PROTOCOLID SUBNETADDR      SUBNETMASK
--------------------------------------------------------------------------------
1   Default          byPort       1   none       N/A             N/A

Accelar-1100#


END

$responsesAccelar->{accounts} = <<'END';
Accelar-1100# show cli password
ACCESS    LOGIN            PASSWORD
rwa       testlab          hobbit
rw        rw               rw
l3        l3               l3
l2        l2               l2
ro        franz            kafka
Accelar-1100#

END

