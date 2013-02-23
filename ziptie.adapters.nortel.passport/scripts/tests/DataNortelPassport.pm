package DataNortelPassport;

use strict;
use warnings;
use Exporter 'import';
our @EXPORT_OK = qw($responsesNortelPassport);

our $responsesNortelPassport = {};

$responsesNortelPassport->{cards} = <<'END';
show sys info card


Card Info :


  Slot 1 :

        FrontType       : 48x100BaseTX
        FrontDescr      : TX48
        FrontAdminStatus: up
        FrontOperStatus : up
        FrontSerialNum  : SSLFA305DA
        FrontHwVersion  : A
        FrontPartNumber : 202572A28
        FrontDateCode   : 10042000
        FrontDeviations : none

        BackType        : BFM6
        BackDescr       : BFM6
        BackSerialNum   : SSLFA204WO
        BackHwVersion   : A
        BackPartNumber  : 205282A20
        BackDateCode    : 09302000
        BackDeviations  : HP622


  Slot 5 :

        FrontType       : CPU
        FrontDescr      : CPU
        FrontAdminStatus: up
        FrontOperStatus : up
        FrontSerialNum  : SSCHC10350
        FrontHwVersion  : A
        FrontPartNumber : 202247A21
        FrontDateCode   : 01282001
        FrontDeviations :

        BackType        : SFM
        BackDescr       : SF
        BackSerialNum   : SSCHD8001K
        BackHwVersion   : A
        BackPartNumber  : 202252A31
        BackDateCode    : 01272001
        BackDeviations  :

Passport-8606:5#

END

$responsesNortelPassport->{config_plain} = <<'END';
show config

Preparing to Display Configuration...

#

# THU SEP 27 11:59:46 2007 UTC

# box type             : Passport-8006

# software version     : 3.5.0.0

# monitor version      : 3.5.0.0/058

#

#

# Asic Info : 

# SlotNum|Name  |CardType   |MdaType |Parts Description 

#

# Slot  1 8648TX   0x20210130 0x00000000   IOM: PLRO=3  BFM: OP=2 TMUX=2 RARU=2 CPLD=4

# Slot  2   --     0x00000001 0x00000000  

# Slot  3   --     0x00000001 0x00000000  

# Slot  4   --     0x00000001 0x00000000  

# Slot  5 8690SF   0x200e0100 0x00000000  CPU: CPLD=15 SFM: OP=2 TMUX=2 SWIP=2 FAD=1 CF=11

# Slot  6   --     0x00000001 0x00000000  

#

#!flags m-mode false

#!flags enhanced-operational-mode false

#!flags vlan-optimization-mode false

#!record-reservation filter 4096

#!record-reservation ipmc 500

#!record-reservation local 2000

#!record-reservation mac 2000

#!record-reservation static-route 200

#!record-reservation vrrp 500

#!end

#

config

load-module 3DES /pcmcia/P80C3500.IMG

mac-flap-time-limit 500

#

# CLI CONFIGURATION

#

cli more false 

#

# SYSTEM CONFIGURATION

#

sys set location "Costa" 

#

# LOG CONFIGURATION

#

#

# LINK-FLAP-DETECT CONFIGURATION

#

#

# IEEE VLAN AGING CONFIGURATION

#

#

# ACCESS-POLICY CONFIGURATION

#

#

# SSH CONFIGURATION

#

sys set ssh version both

sys set ssh enable true

#

# MCAST SOFTWARE FORWARDING CONFIGURATION

#

#

# SNMP V3 GROUP MEMBERSHIP CONFIGURATION

#

#

# SNMP V3 GROUP ACCESS CONFIGURATION

#

#

# SNMP V3 MIB VIEW CONFIGURATION

#

#

# SNMP V3 COMMUNITY TABLE CONFIGURATION

#

#

# SLOT CONFIGURATION

#

#

# WEB CONFIGURATION

#

web-server enable

#

# RMON CONFIGURATION

#

#

# QOS CONFIGURATION 

#

#

# TRAFFIC-FILTER CONFIGURATION

#

#

# DVMRP CONFIGURATION

#

#

# PIM CONFIGURATION

#

#

# IP PREFIX LIST CONFIGURATION

#

#

# SVLAN-CONFIGURATION

#

#

# PORT CONFIGURATION - PHASE I

#

#

# MLT CONFIGURATION

#

#

# STG CONFIGURATION

#

#

# VLAN CONFIGURATION

#

vlan 1 ip create 10.100.26.4/255.255.255.0 mac_offset 0

#

# PORT CONFIGURATION - PHASE II

#

#

# IPX CONFIGURATION

#

#

# IP & RIP CONFIGURATION

#

#

# IP AS LIST CONFIGURATION

#

#

# IP COMMUNITY LIST CONFIGURATION

#

#

# IP ROUTE POLICY CONFIGURATION

#

ip static-route create 0.0.0.0/0.0.0.0 next-hop 10.100.26.2 cost 1  

#

# CIRCUITLESS IP INTERFACE CONFIGURATION

#

#

# DHCP CONFIGURATION

#

#

# IGMP CONFIGURATION

#

#

# PIM RP CONFIGURATION

#

#

# PIM STATIC RP CONFIGURATION

#

#

# OSPF CONFIGURATION

#

#

# MROUTE CONFIGURATION

#

#

# MCAST RESOURCE USAGE CONFIGURATION

#

#

# PGM CONFIGURATION

#

#

# MCAST MLT DISTRIBUTION CONFIGURATION

#

#

# TIMED PRUNE CONFIGURATION

#

#

# BGP CONFIGURATION

#

#

# IP REDISTRIBUTION CONFIGURATION

#

#

# OSPF ACCEPT CONFIGURATION

#

#

# RIP POLICY CONFIGURATION

#

#

# DVMRP POLICY CONFIGURATION

#

#

# UDP FWD CONFIGURATION

#

#

# VRRP CONFIGURATION

#

#

# POS CONFIGURATION

#

#

# ATM CONFIGURATION

#

#

# DIAG CONFIGURATION

#

#

# RADIUS CONFIGURATION

#

#

# NTP CONFIGURATION

#

back

Passport-8606:5# 

END

$responsesNortelPassport->{directory} = <<'END';
directory

  size          date       time       name

--------       ------     ------    --------

     342    AUG-10-2006  13:32:26   /flash/boot.cfg               

    2985    SEP-01-2006  13:55:46   /flash/config.cfg             

  684867    DEC-14-2001  17:10:08   /flash/p80b3202.img           

      11    SEP-19-2007  13:03:42   /flash/engboot                

 3415293    AUG-04-2006  14:25:48   /flash/10.10.1.137            

 3415293    AUG-04-2006  14:28:26   /flash/10.10.1.218            

    2048    AUG-04-2006  15:40:48   /flash/.ssh              <DIR>

     317    AUG-04-2006  15:40:34   /flash/.ssh/ssh_host_rsa_key.pub      

     588    AUG-04-2006  15:40:48   /flash/.ssh/dsa_pub.key       

     342    SEP-20-2007  09:16:48   /flash/10.100.26.4.BootConfig      

total: 15793152 used: 7580672 free: 8212480 bytes

  size          date       time       name

--------       ------     ------    --------

    4330    AUG-04-2006  14:18:12   /pcmcia/syslog.txt            

     124    MAY-25-2005  13:39:54   /pcmcia/PCMBOOT.CFG           

 5780148    JUN-07-2006  17:38:52   /pcmcia/P80A3700.IMG          

  713134    JUL-07-2006  13:56:06   /pcmcia/P80B3500.IMG          

   49996    MAY-22-2003  15:13:38   /pcmcia/P80C3500.IMG          

 1048653    OCT-20-2006  15:09:10   /pcmcia/69C80005.000          

     253    JUL-07-2006  11:26:16   /pcmcia/BOOT.CFG              

    3029    APR-03-2007  15:02:22   /pcmcia/CONFIG.CFG            

 5124517    AUG-10-2006  13:32:26   /pcmcia/p80a3500.img          

    3933    SEP-25-2007  17:45:04   /pcmcia/PCMBOOT.CFG.txt       

total: 31834112 used: 12875776 free: 18958336 bytes

Passport-8606:5# 

END

$responsesNortelPassport->{interfaces} = <<'END';
 show ip interface

================================================================================

                                        Ip Interface

================================================================================

INTERFACE IP             NET            BCASTADDR  REASM    VLAN  BROUTER   

          ADDRESS        MASK           FORMAT     MAXSIZE  ID    PORT      

--------------------------------------------------------------------------------

Port5/1   192.168.1.1    255.255.255.0  ones       1500     0     false     

Vlan1     10.100.26.4    255.255.255.0  ones       1500     --    false     

Passport-8606:5# 

END

$responsesNortelPassport->{stg_config} = <<'END';
show stg info config

================================================================================

                                        Stg Config

================================================================================

STG           BRIDGE  BRIDGE     FORWARD ENABLE STPTRAP

ID   PRIORITY MAX_AGE HELLO_TIME DELAY   STP    TRAP   

--------------------------------------------------------------------------------

1    32768    2000    200        1500    true   true   

STG  TAGGBPDU           TAGGBPDU STG     PORT

ID   ADDRESS            VLAN_ID   TYPE MEMBER

--------------------------------------------------------------------------------

1    01:80:c2:00:00:00  0       normal 1/1-1/48

Total number of STGs :  1

Passport-8606:5# 

END

$responsesNortelPassport->{stg_status} = <<'END';
show stg info status

================================================================================

                                        Stg Status

================================================================================

STG  BRIDGE            NUM   PROTOCOL      TOP     

ID   ADDRESS           PORTS SPECIFICATION CHANGES 

--------------------------------------------------------------------------------

1    00:04:38:69:c8:01 48    ieee8021d     5       

STG  DESIGNATED              ROOT  ROOT  MAX  HELLO  HOLD  FORWARD 

ID   ROOT                    COST  PORT  AGE  TIME   TIME  DELAY   

--------------------------------------------------------------------------------

1    80:00:00:01:63:bb:c3:4a 52    1/1   2000 200    100   1500    

Total number of STGs :  1

Passport-8606:5# 

END

$responsesNortelPassport->{tech} = <<'END';
show tech

Sys Info:

---------------

General Info :

	SysDescr     : Passport-8606 (3.5.0.0)

	SysName      : Passport-8606

	SysUpTime    : 7 day(s), 22:52:41

	SysContact   : support@nortelnetworks.com

	SysLocation  : Costa

Chassis Info :

	Chassis     : 8006

	Serial#     : SSNM0642F9

	HwRev       : A

	NumSlots    : 6

	NumPorts    : 48

	GlobalFilter: enable

	VlanBySrcMac: disable

	Ecn-Compatib: enable

	BaseMacAddr : 00:04:38:69:c8:00

	MacAddrCapacity : 1024

	Temperature : 26 C

	MgmtMacAddr : 00:04:38:69:cb:f4

	System MTU  : 1950

	clock_sync_time : 60

Power Supply Info :

	Ps#1 Status       : empty

	Ps#2 Status       : up

	Ps#2 Type         : Unknown

	Ps#2 Description  : UNKNOWN

	Ps#2 Serial Number: 

	Ps#2 Version      : 

	Ps#2 Part Number  : 

	Ps#3 Status       : empty

Fan Info :

	Fan#1: up, air temp: 22 C

Card Info :

	Slot#         FrontType  FrontHw    Oper   Admin  BackType   BackHw

	                         Version  Status  Status            Version

	    1      48x100BaseTX        A      up      up      BFM6        A

	    5               CPU        A      up      up       SFM        A

System Error Info : 

	Send Authentication Trap  : false

	Error Code                : 0

	Error Severity            : 0

Port Lock Info :

	Status       : off

	LockedPorts  : 

Topology Status Info :

	Status       : on

Message Control Info : 

	Status       : disable

Management Virtual IP Info : 

	Status       : disable

Sys Software:

---------------

System Software Info :

Default Runtime Config File : /pcmcia/CONFIG.CFG

Default Boot Config File : /flash/boot.cfg

Config File : 

Last Runtime Config Save : 0

Last Runtime Config Save to Slave : 0

Last Boot Config Save : 0

Last Boot Config Save on Slave : 0

Boot Config Table

Slot# : 5

Version : Build 3.5.0.0 on Mon May 19 15:39:18 PDT 2003

LastBootConfigSource : /flash/boot.cfg

LastRuntimeImageSource : /pcmcia/p80a3500.img

LastRuntimeConfigSource : /pcmcia/CONFIG.CFG

PrimaryImageSource : /pcmcia/p80a3500.img

PrimaryConfigSource : /pcmcia/CONFIG.CFG

SecondaryImageSource : /flash/p80a3202.img

SecondaryConfigSource : /flash/config.cfg

TertiaryImageSource : 0.0.0.0:

TertiaryConfigSource : /flash/config.cfg

EnableAutoBoot : true

EnableFactoryDefaults : false

EnableDebugMode : false

EnableHwWatchDogTimer : true

EnableRebootOnError : true

EnableTelnetServer : true

EnableRloginServer : false

EnableFtpServer : false

EnableTftpServer : true

Sys Performance:

---------------

	              CpuUtil: 2%

	     SwitchFabricUtil: 0%

	OtherSwitchFabricUtil: 0%

	           BufferUtil: 0%

	            DramSize: 256 M

	            DramUsed: 16 % 

	            DramFree: 217805 K 

Vlan Info:

---------------

================================================================================

                                        Vlan Basic

================================================================================

VLAN                              STG

ID  NAME             TYPE         ID  PROTOCOLID SUBNETADDR      SUBNETMASK     

--------------------------------------------------------------------------------

1   Default          byPort       1   none       N/A             N/A            

================================================================================

                                        Vlan Port

================================================================================

VLAN PORT               ACTIVE             STATIC             NOT_ALLOW         

ID   MEMBER             MEMBER             MEMBER             MEMBER            

--------------------------------------------------------------------------------

1    1/1-1/48           1/1-1/48                                                

================================================================================

                                        Vlan ATM VPort

================================================================================

VLAN ID    PORT NUM      PVC LIST       

--------------------------------------------------------------------------------

================================================================================

                                        Vlan Advance

================================================================================

VLAN        IF    QOS AGING MAC                               USER            

ID  NAME    INDEX LVL TIME  ADDRESS            ACTION RESULT  DEFINEPID ENCAP 

--------------------------------------------------------------------------------

1   Default 2049  1   0     00:04:38:69:ca:00  none   none    0x0000      

VLAN       

ID  DSAP/SSAP

--------------------------------------------------------------------------------

1   

================================================================================

                                        Vlan Arp

================================================================================

VLAN ID  DOPROXY    DORESP    

--------------------------------------------------------------------------------

1        false      true      

================================================================================

                                        Vlan Fdb

================================================================================

VLAN            MAC                                   QOS    SMLT  

ID   STATUS     ADDRESS            INTERFACE  MONITOR LEVEL  REMOTE

--------------------------------------------------------------------------------

1    self       00:04:38:69:ca:00  -          false   1      false 

1    learned    00:04:96:20:ac:d4  Port-1/1   false   1      false 

1    learned    00:09:b7:f6:57:4b  Port-1/1   false   1      false 

1    learned    00:11:20:22:8e:80  Port-1/1   false   1      false 

1    learned    00:e0:2b:00:00:01  Port-1/1   false   1      false 

1    learned    00:e0:b6:00:5f:52  Port-1/1   false   1      false 

6 out of 6 entries in all fdb(s) displayed.

================================================================================

                                        Vlan Filter

================================================================================

VLAN           MAC                               DST-DISCARD     SRC-DISCARD     

ID   STATUS    ADDRESS            PORT   PCAP    SET             SET             

--------------------------------------------------------------------------------

================================================================================

                                        Vlan Static

================================================================================

VLAN                 MAC                               QOS   

ID   STATUS          ADDRESS            PORT   MONITOR LEVEL 

--------------------------------------------------------------------------------

================================================================================

                                        IDS Vlan Info

================================================================================

VLANID     MAC LEARNING DISABLED PORTS

--------------------------------------------------------------------------------

================================================================================

                                        Vlan Ip

================================================================================

VLAN IP               NET              BCASTADDR REASM    ADVERTISE  DIRECTED  

ID   ADDRESS          MASK             FORMAT    MAXSIZE  WHEN_DOWN  BROADCAST 

--------------------------------------------------------------------------------

1    10.100.26.4      255.255.255.0    ones      1500     disable    enable    

================================================================================

                                        Vlan Dhcp

================================================================================

VLAN IF            MAX    MIN            ALWAYS

ID   INDEX  ENABLE HOP    SEC    MODE    BCAST 

--------------------------------------------------------------------------------

1    2049   false  4      0      both    false 

================================================================================

                                        Vlan Ospf

================================================================================

VLAN        HELLO    RTRDEAD  DESIGRTR

ID  ENABLE INTERVAL INTERVAL PRIORITY METRIC AUTHTYPE AUTHKEY    AREAID         

--------------------------------------------------------------------------------

1   false  10       40       1        10     none                0.0.0.0

================================================================================

                                        Vlan Rip

================================================================================

VLAN        DEFAULT   DEFAULT TRIGGERED AUTOAGG                     

ID   ENABLE SUPPLY    LISTEN  UPDATE    ENABLE  SUPPLY LISTEN POISON

--------------------------------------------------------------------------------

1    false  false     false   false     false   true   true   false 

================================================================================

                                        Vlan Vrrp

================================================================================

VLAN VRRP                 VIRTUAL          

ID   ID   IPADDR          MAC ADDR         

--------------------------------------------------------------------------------

================================================================================

                                        Vlan Vrrp Extended

================================================================================

                                   MASTER          ADVERTISE CRITICAL       

VID  STATE      CONTROL  PRIORITY  IPADDR          INTERVAL  IPADDR         

--------------------------------------------------------------------------------

VID  HOLDDOWN_TIME  ACTION   CRITICAL IP  BACKUP   BACKUP  FAST ADV    FAST ADV   

                             ENABLE       MASTER   MASTER  INTERVAL    ENABLE     

                                                   STATE                          

--------------------------------------------------------------------------------

================================================================================

                                        Vlan Ip Igmp

================================================================================

VLAN QUERY QUERY ROBUST VERSION LAST  PROXY  SNOOP  SSM    FAST   FAST

ID   INTVL MAX                  MEMB  SNOOP  ENABLE SNOOP  LEAVE  LEAVE

           RESP                 QUERY ENABLE        ENABLE ENABLE PORTS

--------------------------------------------------------------------------------

1    125   100   2      2       10    false  false  false  false  

================================================================================

                                        Vlan Ip Dvmrp

================================================================================

VLAN  DVMRP            DEFAULT DEFAULT DEFAULT ADVERTISE

ID    ENABLE  METRIC   LISTEN  SUPPLY  METRIC  SELF     

--------------------------------------------------------------------------------

1     disable 1        enable  disable 1       enable   

================================================================================

                                        Vlan Ip Icmp Route Discovery

================================================================================

VLAN_ID  ADV_ADDRESS      ADV_FLAG LIFETIME   MAX_INT    MIN_INT    PREF_LEVEL  

--------------------------------------------------------------------------------

1        255.255.255.255  true     1800         600        450        0           

================================================================================

                                        Vlan Ipx

================================================================================

VLAN-ID VLAN-TYPE      IPXNET     ENCAPSULATION  ROUTING   

--------------------------------------------------------------------------------

================================================================================

                                        Manual Edit Mac

================================================================================

MAC ADDRESS        PORTS               

--------------------------------------------------------------------------------

================================================================================

                                        Autolearn Mac

================================================================================

MAC ADDRESS        PORT  

--------------------------------------------------------------------------------

================================================================================

                                        Vlan Ip Pim

================================================================================

VLAN-ID   PIM-ENABLE MODE    HELLOINT  JPINT   CBSRPREF      INTF TYPE

--------------------------------------------------------------------------------

1         disable    sparse  30        60      -1  (disabled) active 

================================================================================

                                        Vlan Ip Pgm

================================================================================

VLAN-ID ENABLE    STATE    NAK_RE_XMIT  MAX_NAK_RE   NAK_RDATA    NAK_ELIMINATE

                          INTERVAL      XMIT_COUNT    INTERVAL      INTERVAL    

--------------------------------------------------------------------------------

Vlan1    disabled  down     1000         2             10000        5000        

================================================================================

                                        Vlan Mcastmac

================================================================================

VLAN_ID    MAC_ADDRESS          PORT_LIST                      MLT_GROUPS

--------------------------------------------------------------------------------

Total Entries: 0

Port Info:

---------------

================================================================================

                                        Port Interface

================================================================================

PORT                       LINK  PORT           PHYSICAL          STATUS

NUM   INDEX DESCRIPTION    TRAP  LOCK     MTU   ADDRESS           ADMIN  OPERATE

--------------------------------------------------------------------------------

1/1   64    100BaseTX      true  false    1950  00:04:38:69:c8:00 up     up     

1/2   65    100BaseTX      true  false    1950  00:04:38:69:c8:01 up     down   

1/3   66    100BaseTX      true  false    1950  00:04:38:69:c8:02 up     down   

1/4   67    100BaseTX      true  false    1950  00:04:38:69:c8:03 up     down   

1/5   68    100BaseTX      true  false    1950  00:04:38:69:c8:04 up     down   

1/6   69    100BaseTX      true  false    1950  00:04:38:69:c8:05 up     down   

1/7   70    100BaseTX      true  false    1950  00:04:38:69:c8:06 up     down   

1/8   71    100BaseTX      true  false    1950  00:04:38:69:c8:07 up     down   

1/9   72    100BaseTX      true  false    1950  00:04:38:69:c8:08 up     down   

1/10  73    100BaseTX      true  false    1950  00:04:38:69:c8:09 up     down   

1/11  74    100BaseTX      true  false    1950  00:04:38:69:c8:0a up     down   

1/12  75    100BaseTX      true  false    1950  00:04:38:69:c8:0b up     down   

1/13  76    100BaseTX      true  false    1950  00:04:38:69:c8:0c up     down   

1/14  77    100BaseTX      true  false    1950  00:04:38:69:c8:0d up     down   

1/15  78    100BaseTX      true  false    1950  00:04:38:69:c8:0e up     down   

1/16  79    100BaseTX      true  false    1950  00:04:38:69:c8:0f up     down   

1/17  80    100BaseTX      true  false    1950  00:04:38:69:c8:10 up     down   

1/18  81    100BaseTX      true  false    1950  00:04:38:69:c8:11 up     down   

1/19  82    100BaseTX      true  false    1950  00:04:38:69:c8:12 up     down   

1/20  83    100BaseTX      true  false    1950  00:04:38:69:c8:13 up     down   

1/21  84    100BaseTX      true  false    1950  00:04:38:69:c8:14 up     down   

1/22  85    100BaseTX      true  false    1950  00:04:38:69:c8:15 up     down   

1/23  86    100BaseTX      true  false    1950  00:04:38:69:c8:16 up     down   

1/24  87    100BaseTX      true  false    1950  00:04:38:69:c8:17 up     down   

1/25  88    100BaseTX      true  false    1950  00:04:38:69:c8:28 up     down   

1/26  89    100BaseTX      true  false    1950  00:04:38:69:c8:29 up     down   

1/27  90    100BaseTX      true  false    1950  00:04:38:69:c8:2a up     down   

1/28  91    100BaseTX      true  false    1950  00:04:38:69:c8:2b up     down   

1/29  92    100BaseTX      true  false    1950  00:04:38:69:c8:2c up     down   

1/30  93    100BaseTX      true  false    1950  00:04:38:69:c8:2d up     down   

1/31  94    100BaseTX      true  false    1950  00:04:38:69:c8:2e up     down   

1/32  95    100BaseTX      true  false    1950  00:04:38:69:c8:2f up     down   

1/33  96    100BaseTX      true  false    1950  00:04:38:69:c8:30 up     down   

1/34  97    100BaseTX      true  false    1950  00:04:38:69:c8:31 up     down   

1/35  98    100BaseTX      true  false    1950  00:04:38:69:c8:32 up     down   

1/36  99    100BaseTX      true  false    1950  00:04:38:69:c8:33 up     down   

1/37  100   100BaseTX      true  false    1950  00:04:38:69:c8:34 up     down   

1/38  101   100BaseTX      true  false    1950  00:04:38:69:c8:35 up     down   

1/39  102   100BaseTX      true  false    1950  00:04:38:69:c8:36 up     down   

1/40  103   100BaseTX      true  false    1950  00:04:38:69:c8:37 up     down   

1/41  104   100BaseTX      true  false    1950  00:04:38:69:c8:38 up     down   

1/42  105   100BaseTX      true  false    1950  00:04:38:69:c8:39 up     down   

1/43  106   100BaseTX      true  false    1950  00:04:38:69:c8:3a up     down   

1/44  107   100BaseTX      true  false    1950  00:04:38:69:c8:3b up     down   

1/45  108   100BaseTX      true  false    1950  00:04:38:69:c8:3c up     down   

1/46  109   100BaseTX      true  false    1950  00:04:38:69:c8:3d up     down   

1/47  110   100BaseTX      true  false    1950  00:04:38:69:c8:3e up     down   

1/48  111   100BaseTX      true  false    1950  00:04:38:69:c8:3f up     down   

================================================================================

                                        Port Name

================================================================================

PORT                                     OPERATE  OPERATE  OPERATE        

NUM   NAME                 DESCRIPTION   STATUS   DUPLX    SPEED    VLAN  

--------------------------------------------------------------------------------

1/1                        100BaseTX     up       full     100      Access

1/2                        100BaseTX     down     full     0        Access

1/3                        100BaseTX     down     full     0        Access

1/4                        100BaseTX     down     full     0        Access

1/5                        100BaseTX     down     full     0        Access

1/6                        100BaseTX     down     full     0        Access

1/7                        100BaseTX     down     full     0        Access

1/8                        100BaseTX     down     full     0        Access

1/9                        100BaseTX     down     full     0        Access

1/10                       100BaseTX     down     full     0        Access

1/11                       100BaseTX     down     full     0        Access

1/12                       100BaseTX     down     full     0        Access

1/13                       100BaseTX     down     full     0        Access

1/14                       100BaseTX     down     full     0        Access

1/15                       100BaseTX     down     full     0        Access

1/16                       100BaseTX     down     full     0        Access

1/17                       100BaseTX     down     full     0        Access

1/18                       100BaseTX     down     full     0        Access

1/19                       100BaseTX     down     full     0        Access

1/20                       100BaseTX     down     full     0        Access

1/21                       100BaseTX     down     full     0        Access

1/22                       100BaseTX     down     full     0        Access

1/23                       100BaseTX     down     full     0        Access

1/24                       100BaseTX     down     full     0        Access

1/25                       100BaseTX     down     full     0        Access

1/26                       100BaseTX     down     full     0        Access

1/27                       100BaseTX     down     full     0        Access

1/28                       100BaseTX     down     full     0        Access

1/29                       100BaseTX     down     full     0        Access

1/30                       100BaseTX     down     full     0        Access

1/31                       100BaseTX     down     full     0        Access

1/32                       100BaseTX     down     full     0        Access

1/33                       100BaseTX     down     full     0        Access

1/34                       100BaseTX     down     full     0        Access

1/35                       100BaseTX     down     full     0        Access

1/36                       100BaseTX     down     full     0        Access

1/37                       100BaseTX     down     full     0        Access

1/38                       100BaseTX     down     full     0        Access

1/39                       100BaseTX     down     full     0        Access

1/40                       100BaseTX     down     full     0        Access

1/41                       100BaseTX     down     full     0        Access

1/42                       100BaseTX     down     full     0        Access

1/43                       100BaseTX     down     full     0        Access

1/44                       100BaseTX     down     full     0        Access

1/45                       100BaseTX     down     full     0        Access

1/46                       100BaseTX     down     full     0        Access

1/47                       100BaseTX     down     full     0        Access

1/48                       100BaseTX     down     full     0        Access

================================================================================

                                        Port Config

================================================================================

PORT                AUTO  SFFD  ADMIN       OPERATE     DIFF-SERV  QOS MLT VENDOR DUAL SMLT ADMIN   OPERATE

NUM   TYPE          NEG.        DUPLX SPD   DUPLX SPD   EN   TYPE  LVL ID  NAME   CONN ID   ROUTING ROUTING

--------------------------------------------------------------------------------

1/1   100BaseTX     true  false half  10    full  100  fals  core  1   0               0    Enable  Enable 

1/2   100BaseTX     true  false half  10          0    fals  core  1   0               0    Enable  Disable

1/3   100BaseTX     true  false half  10          0    fals  core  1   0               0    Enable  Disable

1/4   100BaseTX     true  false half  10          0    fals  core  1   0               0    Enable  Disable

1/5   100BaseTX     true  false half  10          0    fals  core  1   0               0    Enable  Disable

1/6   100BaseTX     true  false half  10          0    fals  core  1   0               0    Enable  Disable

1/7   100BaseTX     true  false half  10          0    fals  core  1   0               0    Enable  Disable

1/8   100BaseTX     true  false half  10          0    fals  core  1   0               0    Enable  Disable

1/9   100BaseTX     true  false half  10          0    fals  core  1   0               0    Enable  Disable

1/10  100BaseTX     true  false half  10          0    fals  core  1   0               0    Enable  Disable

1/11  100BaseTX     true  false half  10          0    fals  core  1   0               0    Enable  Disable

1/12  100BaseTX     true  false half  10          0    fals  core  1   0               0    Enable  Disable

1/13  100BaseTX     true  false half  10          0    fals  core  1   0               0    Enable  Disable

1/14  100BaseTX     true  false half  10          0    fals  core  1   0               0    Enable  Disable

1/15  100BaseTX     true  false half  10          0    fals  core  1   0               0    Enable  Disable

1/16  100BaseTX     true  false half  10          0    fals  core  1   0               0    Enable  Disable

1/17  100BaseTX     true  false half  10          0    fals  core  1   0               0    Enable  Disable

1/18  100BaseTX     true  false half  10          0    fals  core  1   0               0    Enable  Disable

1/19  100BaseTX     true  false half  10          0    fals  core  1   0               0    Enable  Disable

1/20  100BaseTX     true  false half  10          0    fals  core  1   0               0    Enable  Disable

1/21  100BaseTX     true  false half  10          0    fals  core  1   0               0    Enable  Disable

1/22  100BaseTX     true  false half  10          0    fals  core  1   0               0    Enable  Disable

1/23  100BaseTX     true  false half  10          0    fals  core  1   0               0    Enable  Disable

1/24  100BaseTX     true  false half  10          0    fals  core  1   0               0    Enable  Disable

1/25  100BaseTX     true  false half  10          0    fals  core  1   0               0    Enable  Disable

1/26  100BaseTX     true  false half  10          0    fals  core  1   0               0    Enable  Disable

1/27  100BaseTX     true  false half  10          0    fals  core  1   0               0    Enable  Disable

1/28  100BaseTX     true  false half  10          0    fals  core  1   0               0    Enable  Disable

1/29  100BaseTX     true  false half  10          0    fals  core  1   0               0    Enable  Disable

1/30  100BaseTX     true  false half  10          0    fals  core  1   0               0    Enable  Disable

1/31  100BaseTX     true  false half  10          0    fals  core  1   0               0    Enable  Disable

1/32  100BaseTX     true  false half  10          0    fals  core  1   0               0    Enable  Disable

1/33  100BaseTX     true  false half  10          0    fals  core  1   0               0    Enable  Disable

1/34  100BaseTX     true  false half  10          0    fals  core  1   0               0    Enable  Disable

1/35  100BaseTX     true  false half  10          0    fals  core  1   0               0    Enable  Disable

1/36  100BaseTX     true  false half  10          0    fals  core  1   0               0    Enable  Disable

1/37  100BaseTX     true  false half  10          0    fals  core  1   0               0    Enable  Disable

1/38  100BaseTX     true  false half  10          0    fals  core  1   0               0    Enable  Disable

1/39  100BaseTX     true  false half  10          0    fals  core  1   0               0    Enable  Disable

1/40  100BaseTX     true  false half  10          0    fals  core  1   0               0    Enable  Disable

1/41  100BaseTX     true  false half  10          0    fals  core  1   0               0    Enable  Disable

1/42  100BaseTX     true  false half  10          0    fals  core  1   0               0    Enable  Disable

1/43  100BaseTX     true  false half  10          0    fals  core  1   0               0    Enable  Disable

1/44  100BaseTX     true  false half  10          0    fals  core  1   0               0    Enable  Disable

1/45  100BaseTX     true  false half  10          0    fals  core  1   0               0    Enable  Disable

1/46  100BaseTX     true  false half  10          0    fals  core  1   0               0    Enable  Disable

1/47  100BaseTX     true  false half  10          0    fals  core  1   0               0    Enable  Disable

1/48  100BaseTX     true  false half  10          0    fals  core  1   0               0    Enable  Disable

================================================================================

                                        Port Arp

================================================================================

PORT_NUM DOPROXY    DORESP    

--------------------------------------------------------------------------------

1/1      false      true      

1/2      false      true      

1/3      false      true      

1/4      false      true      

1/5      false      true      

1/6      false      true      

1/7      false      true      

1/8      false      true      

1/9      false      true      

1/10     false      true      

1/11     false      true      

1/12     false      true      

1/13     false      true      

1/14     false      true      

1/15     false      true      

1/16     false      true      

1/17     false      true      

1/18     false      true      

1/19     false      true      

1/20     false      true      

1/21     false      true      

1/22     false      true      

1/23     false      true      

1/24     false      true      

1/25     false      true      

1/26     false      true      

1/27     false      true      

1/28     false      true      

1/29     false      true      

1/30     false      true      

1/31     false      true      

1/32     false      true      

1/33     false      true      

1/34     false      true      

1/35     false      true      

1/36     false      true      

1/37     false      true      

1/38     false      true      

1/39     false      true      

1/40     false      true      

1/41     false      true      

1/42     false      true      

1/43     false      true      

1/44     false      true      

1/45     false      true      

1/46     false      true      

1/47     false      true      

1/48     false      true      

================================================================================

                                        Port Dhcp

================================================================================

PORT_NUM ENABLE   MAX_HOP  MIN_SEC  MODE  ALWAYS_BROADCAST    

--------------------------------------------------------------------------------

1/1      false    4        0        both  false               

1/2      false    4        0        both  false               

1/3      false    4        0        both  false               

1/4      false    4        0        both  false               

1/5      false    4        0        both  false               

1/6      false    4        0        both  false               

1/7      false    4        0        both  false               

1/8      false    4        0        both  false               

1/9      false    4        0        both  false               

1/10     false    4        0        both  false               

1/11     false    4        0        both  false               

1/12     false    4        0        both  false               

1/13     false    4        0        both  false               

1/14     false    4        0        both  false               

1/15     false    4        0        both  false               

1/16     false    4        0        both  false               

1/17     false    4        0        both  false               

1/18     false    4        0        both  false               

1/19     false    4        0        both  false               

1/20     false    4        0        both  false               

1/21     false    4        0        both  false               

1/22     false    4        0        both  false               

1/23     false    4        0        both  false               

1/24     false    4        0        both  false               

1/25     false    4        0        both  false               

1/26     false    4        0        both  false               

1/27     false    4        0        both  false               

1/28     false    4        0        both  false               

1/29     false    4        0        both  false               

1/30     false    4        0        both  false               

1/31     false    4        0        both  false               

1/32     false    4        0        both  false               

1/33     false    4        0        both  false               

1/34     false    4        0        both  false               

1/35     false    4        0        both  false               

1/36     false    4        0        both  false               

1/37     false    4        0        both  false               

1/38     false    4        0        both  false               

1/39     false    4        0        both  false               

1/40     false    4        0        both  false               

1/41     false    4        0        both  false               

1/42     false    4        0        both  false               

1/43     false    4        0        both  false               

1/44     false    4        0        both  false               

1/45     false    4        0        both  false               

1/46     false    4        0        both  false               

1/47     false    4        0        both  false               

1/48     false    4        0        both  false               

================================================================================

                                        Port High-Secure

================================================================================

PORT NUM     HIGH_SECURE

--------------------------------------------------------------------------------

1/1         false

1/2         false

1/3         false

1/4         false

1/5         false

1/6         false

1/7         false

1/8         false

1/9         false

1/10        false

1/11        false

1/12        false

1/13        false

1/14        false

1/15        false

1/16        false

1/17        false

1/18        false

1/19        false

1/20        false

1/21        false

1/22        false

1/23        false

1/24        false

1/25        false

1/26        false

1/27        false

1/28        false

1/29        false

1/30        false

1/31        false

1/32        false

1/33        false

1/34        false

1/35        false

1/36        false

1/37        false

1/38        false

1/39        false

1/40        false

1/41        false

1/42        false

1/43        false

1/44        false

1/45        false

1/46        false

1/47        false

1/48        false

================================================================================

                                        Port Ip

================================================================================

PORT     IP_ADDRESS       NET_MASK         BROADCAST  REASM   ADVERTISE  DIRECT 

NUM                                                   MAXSIZE WHEN_DOWN  BCAST  

--------------------------------------------------------------------------------

================================================================================

                                        Port Ipx

================================================================================

PORT     IPX_ADDRESS ENCAP          

--------------------------------------------------------------------------------

================================================================================

                                        Port Ospf

================================================================================

PORT         HELLO   RTRDEAD OSPF                                      

NUM   ENABLE INTVAL  INTVAL  PRIORITY METRIC AUTHTYPE AUTHKEY    AREA_ID        

--------------------------------------------------------------------------------

1/1   false  10      40      1        0      none                0.0.0.0

1/2   false  10      40      1        0      none                0.0.0.0

1/3   false  10      40      1        0      none                0.0.0.0

1/4   false  10      40      1        0      none                0.0.0.0

1/5   false  10      40      1        0      none                0.0.0.0

1/6   false  10      40      1        0      none                0.0.0.0

1/7   false  10      40      1        0      none                0.0.0.0

1/8   false  10      40      1        0      none                0.0.0.0

1/9   false  10      40      1        0      none                0.0.0.0

1/10  false  10      40      1        0      none                0.0.0.0

1/11  false  10      40      1        0      none                0.0.0.0

1/12  false  10      40      1        0      none                0.0.0.0

1/13  false  10      40      1        0      none                0.0.0.0

1/14  false  10      40      1        0      none                0.0.0.0

1/15  false  10      40      1        0      none                0.0.0.0

1/16  false  10      40      1        0      none                0.0.0.0

1/17  false  10      40      1        0      none                0.0.0.0

1/18  false  10      40      1        0      none                0.0.0.0

1/19  false  10      40      1        0      none                0.0.0.0

1/20  false  10      40      1        0      none                0.0.0.0

1/21  false  10      40      1        0      none                0.0.0.0

1/22  false  10      40      1        0      none                0.0.0.0

1/23  false  10      40      1        0      none                0.0.0.0

1/24  false  10      40      1        0      none                0.0.0.0

1/25  false  10      40      1        0      none                0.0.0.0

1/26  false  10      40      1        0      none                0.0.0.0

1/27  false  10      40      1        0      none                0.0.0.0

1/28  false  10      40      1        0      none                0.0.0.0

1/29  false  10      40      1        0      none                0.0.0.0

1/30  false  10      40      1        0      none                0.0.0.0

1/31  false  10      40      1        0      none                0.0.0.0

1/32  false  10      40      1        0      none                0.0.0.0

1/33  false  10      40      1        0      none                0.0.0.0

1/34  false  10      40      1        0      none                0.0.0.0

1/35  false  10      40      1        0      none                0.0.0.0

1/36  false  10      40      1        0      none                0.0.0.0

1/37  false  10      40      1        0      none                0.0.0.0

1/38  false  10      40      1        0      none                0.0.0.0

1/39  false  10      40      1        0      none                0.0.0.0

1/40  false  10      40      1        0      none                0.0.0.0

1/41  false  10      40      1        0      none                0.0.0.0

1/42  false  10      40      1        0      none                0.0.0.0

1/43  false  10      40      1        0      none                0.0.0.0

1/44  false  10      40      1        0      none                0.0.0.0

1/45  false  10      40      1        0      none                0.0.0.0

1/46  false  10      40      1        0      none                0.0.0.0

1/47  false  10      40      1        0      none                0.0.0.0

1/48  false  10      40      1        0      none                0.0.0.0

================================================================================

                                        Port Rip

================================================================================

PORT         DEFAULT   DEFAULT TRIGGERED AUTOAGG                     

NUM   ENABLE SUPPLY    LISTEN  UPDATE    ENABLE  SUPPLY LISTEN POISON

--------------------------------------------------------------------------------

1/1   false  false     false   false     false   true   true   false 

1/2   false  false     false   false     false   true   true   false 

1/3   false  false     false   false     false   true   true   false 

1/4   false  false     false   false     false   true   true   false 

1/5   false  false     false   false     false   true   true   false 

1/6   false  false     false   false     false   true   true   false 

1/7   false  false     false   false     false   true   true   false 

1/8   false  false     false   false     false   true   true   false 

1/9   false  false     false   false     false   true   true   false 

1/10  false  false     false   false     false   true   true   false 

1/11  false  false     false   false     false   true   true   false 

1/12  false  false     false   false     false   true   true   false 

1/13  false  false     false   false     false   true   true   false 

1/14  false  false     false   false     false   true   true   false 

1/15  false  false     false   false     false   true   true   false 

1/16  false  false     false   false     false   true   true   false 

1/17  false  false     false   false     false   true   true   false 

1/18  false  false     false   false     false   true   true   false 

1/19  false  false     false   false     false   true   true   false 

1/20  false  false     false   false     false   true   true   false 

1/21  false  false     false   false     false   true   true   false 

1/22  false  false     false   false     false   true   true   false 

1/23  false  false     false   false     false   true   true   false 

1/24  false  false     false   false     false   true   true   false 

1/25  false  false     false   false     false   true   true   false 

1/26  false  false     false   false     false   true   true   false 

1/27  false  false     false   false     false   true   true   false 

1/28  false  false     false   false     false   true   true   false 

1/29  false  false     false   false     false   true   true   false 

1/30  false  false     false   false     false   true   true   false 

1/31  false  false     false   false     false   true   true   false 

1/32  false  false     false   false     false   true   true   false 

1/33  false  false     false   false     false   true   true   false 

1/34  false  false     false   false     false   true   true   false 

1/35  false  false     false   false     false   true   true   false 

1/36  false  false     false   false     false   true   true   false 

1/37  false  false     false   false     false   true   true   false 

1/38  false  false     false   false     false   true   true   false 

1/39  false  false     false   false     false   true   true   false 

1/40  false  false     false   false     false   true   true   false 

1/41  false  false     false   false     false   true   true   false 

1/42  false  false     false   false     false   true   true   false 

1/43  false  false     false   false     false   true   true   false 

1/44  false  false     false   false     false   true   true   false 

1/45  false  false     false   false     false   true   true   false 

1/46  false  false     false   false     false   true   true   false 

1/47  false  false     false   false     false   true   true   false 

1/48  false  false     false   false     false   true   true   false 

================================================================================

                                        Port Stg

================================================================================

                             ENABLE                    FORWARD    CHANGE

SID PORT_NUM PRIO STATE       STP   FASTSTART PATHCOST TRANSITION DETECTION

--------------------------------------------------------------------------------

1   1/1      128  forwarding true   false     10       1          true

1   1/2      128  disabled   true   false     100      0          true

1   1/3      128  disabled   true   false     100      0          true

1   1/4      128  disabled   true   false     100      0          true

1   1/5      128  disabled   true   false     100      0          true

1   1/6      128  disabled   true   false     100      0          true

1   1/7      128  disabled   true   false     100      0          true

1   1/8      128  disabled   true   false     100      0          true

1   1/9      128  disabled   true   false     100      0          true

1   1/10     128  disabled   true   false     100      0          true

1   1/11     128  disabled   true   false     100      0          true

1   1/12     128  disabled   true   false     100      0          true

1   1/13     128  disabled   true   false     100      0          true

1   1/14     128  disabled   true   false     100      0          true

1   1/15     128  disabled   true   false     100      0          true

1   1/16     128  disabled   true   false     100      0          true

1   1/17     128  disabled   true   false     100      0          true

1   1/18     128  disabled   true   false     100      0          true

1   1/19     128  disabled   true   false     100      0          true

1   1/20     128  disabled   true   false     100      0          true

1   1/21     128  disabled   true   false     100      0          true

1   1/22     128  disabled   true   false     100      0          true

1   1/23     128  disabled   true   false     100      0          true

1   1/24     128  disabled   true   false     100      0          true

1   1/25     128  disabled   true   false     100      0          true

1   1/26     128  disabled   true   false     100      0          true

1   1/27     128  disabled   true   false     100      0          true

1   1/28     128  disabled   true   false     100      0          true

1   1/29     128  disabled   true   false     100      0          true

1   1/30     128  disabled   true   false     100      0          true

1   1/31     128  disabled   true   false     100      0          true

1   1/32     128  disabled   true   false     100      0          true

1   1/33     128  disabled   true   false     100      0          true

1   1/34     128  disabled   true   false     100      0          true

1   1/35     128  disabled   true   false     100      0          true

1   1/36     128  disabled   true   false     100      0          true

1   1/37     128  disabled   true   false     100      0          true

1   1/38     128  disabled   true   false     100      0          true

1   1/39     128  disabled   true   false     100      0          true

1   1/40     128  disabled   true   false     100      0          true

1   1/41     128  disabled   true   false     100      0          true

1   1/42     128  disabled   true   false     100      0          true

1   1/43     128  disabled   true   false     100      0          true

1   1/44     128  disabled   true   false     100      0          true

1   1/45     128  disabled   true   false     100      0          true

1   1/46     128  disabled   true   false     100      0          true

1   1/47     128  disabled   true   false     100      0          true

1   1/48     128  disabled   true   false     100      0          true

================================================================================

                                        Port Stg Extended

================================================================================

           ----------------------DESIGNATED----------------

SID PORT_NUM   ROOT                    COST       BRIDGE                  PORT 

--------------------------------------------------------------------------------

1   1/1        80:00:00:01:63:bb:c3:4a 42         80:00:00:09:b7:f6:57:66 80:0b

1   1/2        80:00:00:01:63:bb:c3:4a 52         80:00:00:04:38:69:c8:01 80:41

1   1/3        80:00:00:01:63:bb:c3:4a 52         80:00:00:04:38:69:c8:01 80:42

1   1/4        80:00:00:01:63:bb:c3:4a 52         80:00:00:04:38:69:c8:01 80:43

1   1/5        80:00:00:01:63:bb:c3:4a 52         80:00:00:04:38:69:c8:01 80:44

1   1/6        80:00:00:01:63:bb:c3:4a 52         80:00:00:04:38:69:c8:01 80:45

1   1/7        80:00:00:01:63:bb:c3:4a 52         80:00:00:04:38:69:c8:01 80:46

1   1/8        80:00:00:01:63:bb:c3:4a 52         80:00:00:04:38:69:c8:01 80:47

1   1/9        80:00:00:01:63:bb:c3:4a 52         80:00:00:04:38:69:c8:01 80:48

1   1/10       80:00:00:01:63:bb:c3:4a 52         80:00:00:04:38:69:c8:01 80:49

1   1/11       80:00:00:01:63:bb:c3:4a 52         80:00:00:04:38:69:c8:01 80:4a

1   1/12       80:00:00:01:63:bb:c3:4a 52         80:00:00:04:38:69:c8:01 80:4b

1   1/13       80:00:00:01:63:bb:c3:4a 52         80:00:00:04:38:69:c8:01 80:4c

1   1/14       80:00:00:01:63:bb:c3:4a 52         80:00:00:04:38:69:c8:01 80:4d

1   1/15       80:00:00:01:63:bb:c3:4a 52         80:00:00:04:38:69:c8:01 80:4e

1   1/16       80:00:00:01:63:bb:c3:4a 52         80:00:00:04:38:69:c8:01 80:4f

1   1/17       80:00:00:01:63:bb:c3:4a 52         80:00:00:04:38:69:c8:01 80:50

1   1/18       80:00:00:01:63:bb:c3:4a 52         80:00:00:04:38:69:c8:01 80:51

1   1/19       80:00:00:01:63:bb:c3:4a 52         80:00:00:04:38:69:c8:01 80:52

1   1/20       80:00:00:01:63:bb:c3:4a 52         80:00:00:04:38:69:c8:01 80:53

1   1/21       80:00:00:01:63:bb:c3:4a 52         80:00:00:04:38:69:c8:01 80:54

1   1/22       80:00:00:01:63:bb:c3:4a 52         80:00:00:04:38:69:c8:01 80:55

1   1/23       80:00:00:01:63:bb:c3:4a 52         80:00:00:04:38:69:c8:01 80:56

1   1/24       80:00:00:01:63:bb:c3:4a 52         80:00:00:04:38:69:c8:01 80:57

1   1/25       80:00:00:01:63:bb:c3:4a 52         80:00:00:04:38:69:c8:01 80:58

1   1/26       80:00:00:01:63:bb:c3:4a 52         80:00:00:04:38:69:c8:01 80:59

1   1/27       80:00:00:01:63:bb:c3:4a 52         80:00:00:04:38:69:c8:01 80:5a

1   1/28       80:00:00:01:63:bb:c3:4a 52         80:00:00:04:38:69:c8:01 80:5b

1   1/29       80:00:00:01:63:bb:c3:4a 52         80:00:00:04:38:69:c8:01 80:5c

1   1/30       80:00:00:01:63:bb:c3:4a 52         80:00:00:04:38:69:c8:01 80:5d

1   1/31       80:00:00:01:63:bb:c3:4a 52         80:00:00:04:38:69:c8:01 80:5e

1   1/32       80:00:00:01:63:bb:c3:4a 52         80:00:00:04:38:69:c8:01 80:5f

1   1/33       80:00:00:01:63:bb:c3:4a 52         80:00:00:04:38:69:c8:01 80:60

1   1/34       80:00:00:01:63:bb:c3:4a 52         80:00:00:04:38:69:c8:01 80:61

1   1/35       80:00:00:01:63:bb:c3:4a 52         80:00:00:04:38:69:c8:01 80:62

1   1/36       80:00:00:01:63:bb:c3:4a 52         80:00:00:04:38:69:c8:01 80:63

1   1/37       80:00:00:01:63:bb:c3:4a 52         80:00:00:04:38:69:c8:01 80:64

1   1/38       80:00:00:01:63:bb:c3:4a 52         80:00:00:04:38:69:c8:01 80:65

1   1/39       80:00:00:01:63:bb:c3:4a 52         80:00:00:04:38:69:c8:01 80:66

1   1/40       80:00:00:01:63:bb:c3:4a 52         80:00:00:04:38:69:c8:01 80:67

1   1/41       80:00:00:01:63:bb:c3:4a 52         80:00:00:04:38:69:c8:01 80:68

1   1/42       80:00:00:01:63:bb:c3:4a 52         80:00:00:04:38:69:c8:01 80:69

1   1/43       80:00:00:01:63:bb:c3:4a 52         80:00:00:04:38:69:c8:01 80:6a

1   1/44       80:00:00:01:63:bb:c3:4a 52         80:00:00:04:38:69:c8:01 80:6b

1   1/45       80:00:00:01:63:bb:c3:4a 52         80:00:00:04:38:69:c8:01 80:6c

1   1/46       80:00:00:01:63:bb:c3:4a 52         80:00:00:04:38:69:c8:01 80:6d

1   1/47       80:00:00:01:63:bb:c3:4a 52         80:00:00:04:38:69:c8:01 80:6e

1   1/48       80:00:00:01:63:bb:c3:4a 52         80:00:00:04:38:69:c8:01 80:6f

================================================================================

                                        Port Vrrp

================================================================================

PORT_NUM VRRP_ID IP_ADDRESS      VIRTUAL_MAC_ADDR 

--------------------------------------------------------------------------------

================================================================================

                                        Port Vrrp Extended

================================================================================

PORT  STATE      CONTROL  PRIORITY  MASTER_IPADDR   ADVERTISE CRITICAL_IPADDR

--------------------------------------------------------------------------------

PORT  HOLDDOWN_TIME  ACTION   CRITICAL IP  BACKUP   BACKUP  FAST ADV    FAST ADV   

                              ENABLE       MASTER   MASTER  INTERVAL    ENABLE     

                              STATE                                     ENABLE     

--------------------------------------------------------------------------------

================================================================================

                                        Port Vlans

================================================================================

PORT          DISCARD DISCARD   DEFAULT VLAN   PORT  

NUM   TAGGING TAGFRAM UNTAGFRAM VLANID  IDS    TYPE  

--------------------------------------------------------------------------------

1/1   disable false   false     1       1 normal

1/2   disable false   false     1       1 normal

1/3   disable false   false     1       1 normal

1/4   disable false   false     1       1 normal

1/5   disable false   false     1       1 normal

1/6   disable false   false     1       1 normal

1/7   disable false   false     1       1 normal

1/8   disable false   false     1       1 normal

1/9   disable false   false     1       1 normal

1/10  disable false   false     1       1 normal

1/11  disable false   false     1       1 normal

1/12  disable false   false     1       1 normal

1/13  disable false   false     1       1 normal

1/14  disable false   false     1       1 normal

1/15  disable false   false     1       1 normal

1/16  disable false   false     1       1 normal

1/17  disable false   false     1       1 normal

1/18  disable false   false     1       1 normal

1/19  disable false   false     1       1 normal

1/20  disable false   false     1       1 normal

1/21  disable false   false     1       1 normal

1/22  disable false   false     1       1 normal

1/23  disable false   false     1       1 normal

1/24  disable false   false     1       1 normal

1/25  disable false   false     1       1 normal

1/26  disable false   false     1       1 normal

1/27  disable false   false     1       1 normal

1/28  disable false   false     1       1 normal

1/29  disable false   false     1       1 normal

1/30  disable false   false     1       1 normal

1/31  disable false   false     1       1 normal

1/32  disable false   false     1       1 normal

1/33  disable false   false     1       1 normal

1/34  disable false   false     1       1 normal

1/35  disable false   false     1       1 normal

1/36  disable false   false     1       1 normal

1/37  disable false   false     1       1 normal

1/38  disable false   false     1       1 normal

1/39  disable false   false     1       1 normal

1/40  disable false   false     1       1 normal

1/41  disable false   false     1       1 normal

1/42  disable false   false     1       1 normal

1/43  disable false   false     1       1 normal

1/44  disable false   false     1       1 normal

1/45  disable false   false     1       1 normal

1/46  disable false   false     1       1 normal

1/47  disable false   false     1       1 normal

1/48  disable false   false     1       1 normal

================================================================================

                                        Port Ip Dvmrp

================================================================================

PORT  DVMRP            DEFAULT DEFAULT DEFAULT ADVERTISE

NUM   ENABLE  METRIC   LISTEN  SUPPLY  METRIC  SELF     

--------------------------------------------------------------------------------

1/1   disable 1        enable  disable 1       enable   

1/2   disable 1        enable  disable 1       enable   

1/3   disable 1        enable  disable 1       enable   

1/4   disable 1        enable  disable 1       enable   

1/5   disable 1        enable  disable 1       enable   

1/6   disable 1        enable  disable 1       enable   

1/7   disable 1        enable  disable 1       enable   

1/8   disable 1        enable  disable 1       enable   

1/9   disable 1        enable  disable 1       enable   

1/10  disable 1        enable  disable 1       enable   

1/11  disable 1        enable  disable 1       enable   

1/12  disable 1        enable  disable 1       enable   

1/13  disable 1        enable  disable 1       enable   

1/14  disable 1        enable  disable 1       enable   

1/15  disable 1        enable  disable 1       enable   

1/16  disable 1        enable  disable 1       enable   

1/17  disable 1        enable  disable 1       enable   

1/18  disable 1        enable  disable 1       enable   

1/19  disable 1        enable  disable 1       enable   

1/20  disable 1        enable  disable 1       enable   

1/21  disable 1        enable  disable 1       enable   

1/22  disable 1        enable  disable 1       enable   

1/23  disable 1        enable  disable 1       enable   

1/24  disable 1        enable  disable 1       enable   

1/25  disable 1        enable  disable 1       enable   

1/26  disable 1        enable  disable 1       enable   

1/27  disable 1        enable  disable 1       enable   

1/28  disable 1        enable  disable 1       enable   

1/29  disable 1        enable  disable 1       enable   

1/30  disable 1        enable  disable 1       enable   

1/31  disable 1        enable  disable 1       enable   

1/32  disable 1        enable  disable 1       enable   

1/33  disable 1        enable  disable 1       enable   

1/34  disable 1        enable  disable 1       enable   

1/35  disable 1        enable  disable 1       enable   

1/36  disable 1        enable  disable 1       enable   

1/37  disable 1        enable  disable 1       enable   

1/38  disable 1        enable  disable 1       enable   

1/39  disable 1        enable  disable 1       enable   

1/40  disable 1        enable  disable 1       enable   

1/41  disable 1        enable  disable 1       enable   

1/42  disable 1        enable  disable 1       enable   

1/43  disable 1        enable  disable 1       enable   

1/44  disable 1        enable  disable 1       enable   

1/45  disable 1        enable  disable 1       enable   

1/46  disable 1        enable  disable 1       enable   

1/47  disable 1        enable  disable 1       enable   

1/48  disable 1        enable  disable 1       enable   

================================================================================

                                        Port Ip Igmp

================================================================================

PORT QUERY QUERY ROBUST VERSION LAST  PROXY  SNOOP  SSM    FAST  

NUM  INTVL MAX                  MEMB  SNOOP  ENABLE SNOOP  LEAVE 

           RESP                 QUERY ENABLE        ENABLE ENABLE

--------------------------------------------------------------------------------

1/1  125   100   2      2       10    false  false  false  false 

1/2  125   100   2      2       10    false  false  false  false 

1/3  125   100   2      2       10    false  false  false  false 

1/4  125   100   2      2       10    false  false  false  false 

1/5  125   100   2      2       10    false  false  false  false 

1/6  125   100   2      2       10    false  false  false  false 

1/7  125   100   2      2       10    false  false  false  false 

1/8  125   100   2      2       10    false  false  false  false 

1/9  125   100   2      2       10    false  false  false  false 

1/10 125   100   2      2       10    false  false  false  false 

1/11 125   100   2      2       10    false  false  false  false 

1/12 125   100   2      2       10    false  false  false  false 

1/13 125   100   2      2       10    false  false  false  false 

1/14 125   100   2      2       10    false  false  false  false 

1/15 125   100   2      2       10    false  false  false  false 

1/16 125   100   2      2       10    false  false  false  false 

1/17 125   100   2      2       10    false  false  false  false 

1/18 125   100   2      2       10    false  false  false  false 

1/19 125   100   2      2       10    false  false  false  false 

1/20 125   100   2      2       10    false  false  false  false 

1/21 125   100   2      2       10    false  false  false  false 

1/22 125   100   2      2       10    false  false  false  false 

1/23 125   100   2      2       10    false  false  false  false 

1/24 125   100   2      2       10    false  false  false  false 

1/25 125   100   2      2       10    false  false  false  false 

1/26 125   100   2      2       10    false  false  false  false 

1/27 125   100   2      2       10    false  false  false  false 

1/28 125   100   2      2       10    false  false  false  false 

1/29 125   100   2      2       10    false  false  false  false 

1/30 125   100   2      2       10    false  false  false  false 

1/31 125   100   2      2       10    false  false  false  false 

1/32 125   100   2      2       10    false  false  false  false 

1/33 125   100   2      2       10    false  false  false  false 

1/34 125   100   2      2       10    false  false  false  false 

1/35 125   100   2      2       10    false  false  false  false 

1/36 125   100   2      2       10    false  false  false  false 

1/37 125   100   2      2       10    false  false  false  false 

1/38 125   100   2      2       10    false  false  false  false 

1/39 125   100   2      2       10    false  false  false  false 

1/40 125   100   2      2       10    false  false  false  false 

1/41 125   100   2      2       10    false  false  false  false 

1/42 125   100   2      2       10    false  false  false  false 

1/43 125   100   2      2       10    false  false  false  false 

1/44 125   100   2      2       10    false  false  false  false 

1/45 125   100   2      2       10    false  false  false  false 

1/46 125   100   2      2       10    false  false  false  false 

1/47 125   100   2      2       10    false  false  false  false 

1/48 125   100   2      2       10    false  false  false  false 

================================================================================

                                        POS Config Info

================================================================================

PORT  ADMIN      BRIDGE     IP         IPX        MAGIC                 PPP

NUM   STATUS     ADMIN      ADMIN      ADMIN      NUMBER     LQSTATUS   STPMODE

--------------------------------------------------------------------------------

================================================================================

                                        Port Unknown-Mac-Discard

================================================================================

PORT  ACTI    AUTO    AUTOLN   LOCK    DOWN            SEND    MAXMAC CURMAC

NUM   VATION  LEARN   MODE     AUTOLN  PORT    LOG     TRAP    COUNT  COUNT 

--------------------------------------------------------------------------------

1/1   disable disable one-shot disable disable enable  disable 2048   0     

1/2   disable disable one-shot disable disable enable  disable 2048   0     

1/3   disable disable one-shot disable disable enable  disable 2048   0     

1/4   disable disable one-shot disable disable enable  disable 2048   0     

1/5   disable disable one-shot disable disable enable  disable 2048   0     

1/6   disable disable one-shot disable disable enable  disable 2048   0     

1/7   disable disable one-shot disable disable enable  disable 2048   0     

1/8   disable disable one-shot disable disable enable  disable 2048   0     

1/9   disable disable one-shot disable disable enable  disable 2048   0     

1/10  disable disable one-shot disable disable enable  disable 2048   0     

1/11  disable disable one-shot disable disable enable  disable 2048   0     

1/12  disable disable one-shot disable disable enable  disable 2048   0     

1/13  disable disable one-shot disable disable enable  disable 2048   0     

1/14  disable disable one-shot disable disable enable  disable 2048   0     

1/15  disable disable one-shot disable disable enable  disable 2048   0     

1/16  disable disable one-shot disable disable enable  disable 2048   0     

1/17  disable disable one-shot disable disable enable  disable 2048   0     

1/18  disable disable one-shot disable disable enable  disable 2048   0     

1/19  disable disable one-shot disable disable enable  disable 2048   0     

1/20  disable disable one-shot disable disable enable  disable 2048   0     

1/21  disable disable one-shot disable disable enable  disable 2048   0     

1/22  disable disable one-shot disable disable enable  disable 2048   0     

1/23  disable disable one-shot disable disable enable  disable 2048   0     

1/24  disable disable one-shot disable disable enable  disable 2048   0     

1/25  disable disable one-shot disable disable enable  disable 2048   0     

1/26  disable disable one-shot disable disable enable  disable 2048   0     

1/27  disable disable one-shot disable disable enable  disable 2048   0     

1/28  disable disable one-shot disable disable enable  disable 2048   0     

1/29  disable disable one-shot disable disable enable  disable 2048   0     

1/30  disable disable one-shot disable disable enable  disable 2048   0     

1/31  disable disable one-shot disable disable enable  disable 2048   0     

1/32  disable disable one-shot disable disable enable  disable 2048   0     

1/33  disable disable one-shot disable disable enable  disable 2048   0     

1/34  disable disable one-shot disable disable enable  disable 2048   0     

1/35  disable disable one-shot disable disable enable  disable 2048   0     

1/36  disable disable one-shot disable disable enable  disable 2048   0     

1/37  disable disable one-shot disable disable enable  disable 2048   0     

1/38  disable disable one-shot disable disable enable  disable 2048   0     

1/39  disable disable one-shot disable disable enable  disable 2048   0     

1/40  disable disable one-shot disable disable enable  disable 2048   0     

1/41  disable disable one-shot disable disable enable  disable 2048   0     

1/42  disable disable one-shot disable disable enable  disable 2048   0     

1/43  disable disable one-shot disable disable enable  disable 2048   0     

1/44  disable disable one-shot disable disable enable  disable 2048   0     

1/45  disable disable one-shot disable disable enable  disable 2048   0     

1/46  disable disable one-shot disable disable enable  disable 2048   0     

1/47  disable disable one-shot disable disable enable  disable 2048   0     

1/48  disable disable one-shot disable disable enable  disable 2048   0     

================================================================================

                                        Port Ip Pim

================================================================================

PORT-NUM  PIM-ENABLE MODE    HELLOINT  JPINT   CBSRPREF      INTF TYPE

--------------------------------------------------------------------------------

1/1       disable    sparse  30        60      -1  (disabled) active 

1/2       disable    sparse  30        60      -1  (disabled) active 

1/3       disable    sparse  30        60      -1  (disabled) active 

1/4       disable    sparse  30        60      -1  (disabled) active 

1/5       disable    sparse  30        60      -1  (disabled) active 

1/6       disable    sparse  30        60      -1  (disabled) active 

1/7       disable    sparse  30        60      -1  (disabled) active 

1/8       disable    sparse  30        60      -1  (disabled) active 

1/9       disable    sparse  30        60      -1  (disabled) active 

1/10      disable    sparse  30        60      -1  (disabled) active 

1/11      disable    sparse  30        60      -1  (disabled) active 

1/12      disable    sparse  30        60      -1  (disabled) active 

1/13      disable    sparse  30        60      -1  (disabled) active 

1/14      disable    sparse  30        60      -1  (disabled) active 

1/15      disable    sparse  30        60      -1  (disabled) active 

1/16      disable    sparse  30        60      -1  (disabled) active 

1/17      disable    sparse  30        60      -1  (disabled) active 

1/18      disable    sparse  30        60      -1  (disabled) active 

1/19      disable    sparse  30        60      -1  (disabled) active 

1/20      disable    sparse  30        60      -1  (disabled) active 

1/21      disable    sparse  30        60      -1  (disabled) active 

1/22      disable    sparse  30        60      -1  (disabled) active 

1/23      disable    sparse  30        60      -1  (disabled) active 

1/24      disable    sparse  30        60      -1  (disabled) active 

1/25      disable    sparse  30        60      -1  (disabled) active 

1/26      disable    sparse  30        60      -1  (disabled) active 

1/27      disable    sparse  30        60      -1  (disabled) active 

1/28      disable    sparse  30        60      -1  (disabled) active 

1/29      disable    sparse  30        60      -1  (disabled) active 

1/30      disable    sparse  30        60      -1  (disabled) active 

1/31      disable    sparse  30        60      -1  (disabled) active 

1/32      disable    sparse  30        60      -1  (disabled) active 

1/33      disable    sparse  30        60      -1  (disabled) active 

1/34      disable    sparse  30        60      -1  (disabled) active 

1/35      disable    sparse  30        60      -1  (disabled) active 

1/36      disable    sparse  30        60      -1  (disabled) active 

1/37      disable    sparse  30        60      -1  (disabled) active 

1/38      disable    sparse  30        60      -1  (disabled) active 

1/39      disable    sparse  30        60      -1  (disabled) active 

1/40      disable    sparse  30        60      -1  (disabled) active 

1/41      disable    sparse  30        60      -1  (disabled) active 

1/42      disable    sparse  30        60      -1  (disabled) active 

1/43      disable    sparse  30        60      -1  (disabled) active 

1/44      disable    sparse  30        60      -1  (disabled) active 

1/45      disable    sparse  30        60      -1  (disabled) active 

1/46      disable    sparse  30        60      -1  (disabled) active 

1/47      disable    sparse  30        60      -1  (disabled) active 

1/48      disable    sparse  30        60      -1  (disabled) active 

Route:

---------------

================================================================================

                                        Ip Route

================================================================================

            DST            MASK            NEXT COST VLAN  PORT PROT AGE TYPE PRF

--------------------------------------------------------------------------------

        0.0.0.0         0.0.0.0     10.100.26.2    1    1  -/-  STAT   0 IB     5

    10.100.26.0   255.255.255.0     10.100.26.4    1    1  -/-    LOC   0 DB    0

2 out of 2 Total Num of Dest Networks,2 Total Num of Route Entries displayed.

--------------------------------------------------------------------------------

TYPE Legend:

I=Indirect Route, D=Direct Route, A=Alternative Route, B=Best Route, E=Ecmp Route, U=Unresolved Route, N=Not in HW

Ip Arp:

---------------

================================================================================

                                        Ip Arp

================================================================================

  IP_ADDRESS       MAC_ADDRESS      VLAN  PORT    TYPE    TTL

--------------------------------------------------------------------------------

10.100.26.1     00:e0:b6:00:5f:52  1       1/1   DYNAMIC 111  

10.100.26.2     00:11:20:22:8e:80  1       1/1   DYNAMIC 2138 

10.100.26.4     00:04:38:69:ca:00  1        -    LOCAL   2160 

10.100.26.5     00:04:96:20:ac:d4  1       1/1   DYNAMIC 2138 

10.100.26.255   ff:ff:ff:ff:ff:ff  1        -    LOCAL   2160 

5 out of 5 ARP entries displayed

OSPF:

---------------

================================================================================

                                        Ospf Area

================================================================================

AREA_ID         STUB_AREA  NSSA          IMPORT_SUM ACTIVE_IFCNT   

--------------------------------------------------------------------------------

0.0.0.0         false      false         true       0              

STUB_COST SPF_RUNS  BDR_RTR_CNT ASBDR_RTR_CNT LSA_CNT   LSACK_SUM      

--------------------------------------------------------------------------------

0         0         0           0             0         0              

================================================================================

                                        Ospf Interface

================================================================================

INTERFACE       AREAID          ADM IFST MET PRIO DR/BDR          TYPE AUTHTYPE MTUIGN

--------------------------------------------------------------------------------

================================================================================

                                        Ospf Neighbors

================================================================================

INTERFACE       NBRROUTERID     NBRIPADDR       PRIO_STATE    RTXQLEN PERMANENCE

--------------------------------------------------------------------------------

Total ospf neighbors: 0

================================================================================

                                        Ospf Lsdb

================================================================================

================================================================================

                                        AsExternal Lsas

================================================================================

Trace:

---------------

Log:

---------------

CPU5 [09/19/07 13:03:42] SW INFO System boot

CPU5 [09/19/07 13:03:42] SW INFO Passport System Software Release 3.5.0.0

CPU5 [09/19/07 13:03:42] SW INFO all the configured hosts not reachable

CPU5 [09/19/07 13:03:42] HW INFO Card inserted: Slot=1 Type=8648TX

CPU5 [09/19/07 13:03:43] HW INFO Card inserted: Slot=5 Type=8690SF

CPU5 [09/19/07 13:03:43] HW INFO Initializing 8690SF in slot #5 ...

CPU5 [09/19/07 13:03:45] HW INFO Initializing 8648TX in slot #1 ...

CPU5 [09/19/07 13:03:45] SNMP INFO 2k card up(CardNum=5 AdminStatus=1 OperStatus=1)

CPU5 [09/19/07 13:03:47] SW INFO Loading configuration from /pcmcia/CONFIG.CFG

CPU5 [09/19/07 13:03:47] SNMP INFO 2k card up(CardNum=1 AdminStatus=1 OperStatus=1)

CPU5 [09/19/07 13:03:48] SW INFO The system is ready

CPU5 [09/19/07 13:03:48] SNMP INFO Booted with PRIMARY boot image source - /pcmcia/p80a3500.img

CPU5 [09/19/07 13:03:48] SW INFO PCMCIA card detected in Master CPU "Passport-8606" slot 5, Chassis S/N SSNM0642F9

CPU5 [09/19/07 13:03:49] SSH INFO Server listening on port 22.

CPU5 [09/19/07 13:03:49] SNMP INFO Link Down(1/1)

CPU5 [09/19/07 13:03:49] SNMP INFO Link Down 1/1.Port is an access port

CPU5 [09/19/07 13:03:49] SNMP INFO Link Down(1/2)

CPU5 [09/19/07 13:03:49] SNMP INFO Link Down 1/2.Port is an access port

CPU5 [09/19/07 13:03:49] SNMP INFO Link Down(1/3)

CPU5 [09/19/07 13:03:49] SNMP INFO Link Down 1/3.Port is an access port

CPU5 [09/19/07 13:03:49] SNMP INFO Link Down(1/4)

CPU5 [09/19/07 13:03:49] SNMP INFO Link Down 1/4.Port is an access port

CPU5 [09/19/07 13:03:49] SNMP INFO Link Down(1/5)

CPU5 [09/19/07 13:03:49] SNMP INFO Link Down 1/5.Port is an access port

CPU5 [09/19/07 13:03:49] SNMP INFO Link Down(1/6)

CPU5 [09/19/07 13:03:49] SNMP INFO Link Down 1/6.Port is an access port

CPU5 [09/19/07 13:03:49] SNMP INFO Link Down(1/7)

CPU5 [09/19/07 13:03:49] SNMP INFO Link Down 1/7.Port is an access port

CPU5 [09/19/07 13:03:49] SNMP INFO Link Down(1/8)

CPU5 [09/19/07 13:03:49] SNMP INFO Link Down 1/8.Port is an access port

CPU5 [09/19/07 13:03:49] SNMP INFO Link Down(1/9)

CPU5 [09/19/07 13:03:49] SNMP INFO Link Down 1/9.Port is an access port

CPU5 [09/19/07 13:03:49] SNMP INFO Link Down(1/10)

CPU5 [09/19/07 13:03:49] SNMP INFO Link Down 1/10.Port is an access port

CPU5 [09/19/07 13:03:49] SNMP INFO Link Down(1/11)

CPU5 [09/19/07 13:03:49] SNMP INFO Link Down 1/11.Port is an access port

CPU5 [09/19/07 13:03:49] SNMP INFO Link Down(1/12)

CPU5 [09/19/07 13:03:49] SNMP INFO Link Down 1/12.Port is an access port

CPU5 [09/19/07 13:03:49] SNMP INFO Link Down(1/13)

CPU5 [09/19/07 13:03:49] SNMP INFO Link Down 1/13.Port is an access port

CPU5 [09/19/07 13:03:49] SNMP INFO Link Down(1/14)

CPU5 [09/19/07 13:03:49] SNMP INFO Link Down 1/14.Port is an access port

CPU5 [09/19/07 13:03:49] SNMP INFO Link Down(1/15)

CPU5 [09/19/07 13:03:49] SNMP INFO Link Down 1/15.Port is an access port

CPU5 [09/19/07 13:03:49] SNMP INFO Link Down(1/16)

CPU5 [09/19/07 13:03:49] SNMP INFO Link Down 1/16.Port is an access port

CPU5 [09/19/07 13:03:49] SNMP INFO Link Down(1/17)

CPU5 [09/19/07 13:03:49] SNMP INFO Link Down 1/17.Port is an access port

CPU5 [09/19/07 13:03:49] SNMP INFO Link Down(1/18)

CPU5 [09/19/07 13:03:49] SNMP INFO Link Down 1/18.Port is an access port

CPU5 [09/19/07 13:03:49] SNMP INFO Link Down(1/19)

CPU5 [09/19/07 13:03:49] SNMP INFO Link Down 1/19.Port is an access port

CPU5 [09/19/07 13:03:49] SNMP INFO Link Down(1/20)

CPU5 [09/19/07 13:03:49] SNMP INFO Link Down 1/20.Port is an access port

CPU5 [09/19/07 13:03:49] SNMP INFO Link Down(1/21)

CPU5 [09/19/07 13:03:49] SNMP INFO Link Down 1/21.Port is an access port

CPU5 [09/19/07 13:03:49] SNMP INFO Link Down(1/22)

CPU5 [09/19/07 13:03:49] SNMP INFO Link Down 1/22.Port is an access port

CPU5 [09/19/07 13:03:49] SNMP INFO Link Down(1/23)

CPU5 [09/19/07 13:03:49] SNMP INFO Link Down 1/23.Port is an access port

CPU5 [09/19/07 13:03:49] SNMP INFO Link Down(1/24)

CPU5 [09/19/07 13:03:49] SNMP INFO Link Down 1/24.Port is an access port

CPU5 [09/19/07 13:03:49] SNMP INFO Link Down(1/25)

CPU5 [09/19/07 13:03:49] SNMP INFO Link Down 1/25.Port is an access port

CPU5 [09/19/07 13:03:49] SNMP INFO Link Down(1/26)

CPU5 [09/19/07 13:03:50] SNMP INFO Link Down 1/26.Port is an access port

CPU5 [09/19/07 13:03:50] SNMP INFO Link Down(1/27)

CPU5 [09/19/07 13:03:50] SNMP INFO Link Down 1/27.Port is an access port

CPU5 [09/19/07 13:03:50] SNMP INFO Link Down(1/28)

CPU5 [09/19/07 13:03:50] SNMP INFO Link Down 1/28.Port is an access port

CPU5 [09/19/07 13:03:50] SNMP INFO Link Down(1/29)

CPU5 [09/19/07 13:03:50] SNMP INFO Link Down 1/29.Port is an access port

CPU5 [09/19/07 13:03:50] SNMP INFO Link Down(1/30)

CPU5 [09/19/07 13:03:50] SNMP INFO Link Down 1/30.Port is an access port

CPU5 [09/19/07 13:03:50] SNMP INFO Link Down(1/31)

CPU5 [09/19/07 13:03:50] SNMP INFO Link Down 1/31.Port is an access port

CPU5 [09/19/07 13:03:50] SNMP INFO Link Down(1/32)

CPU5 [09/19/07 13:03:50] SNMP INFO Link Down 1/32.Port is an access port

CPU5 [09/19/07 13:03:50] SNMP INFO Link Down(1/33)

CPU5 [09/19/07 13:03:50] SNMP INFO Link Down 1/33.Port is an access port

CPU5 [09/19/07 13:03:50] SNMP INFO Link Down(1/34)

CPU5 [09/19/07 13:03:50] SNMP INFO Link Down 1/34.Port is an access port

CPU5 [09/19/07 13:03:50] SNMP INFO Link Down(1/35)

CPU5 [09/19/07 13:03:50] SNMP INFO Link Down 1/35.Port is an access port

CPU5 [09/19/07 13:03:50] SNMP INFO Link Down(1/36)

CPU5 [09/19/07 13:03:50] SNMP INFO Link Down 1/36.Port is an access port

CPU5 [09/19/07 13:03:50] SNMP INFO Link Down(1/37)

CPU5 [09/19/07 13:03:50] SNMP INFO Link Down 1/37.Port is an access port

CPU5 [09/19/07 13:03:50] SNMP INFO Link Down(1/38)

CPU5 [09/19/07 13:03:50] SNMP INFO Link Down 1/38.Port is an access port

CPU5 [09/19/07 13:03:50] SNMP INFO Link Down(1/39)

CPU5 [09/19/07 13:03:50] SNMP INFO Link Down 1/39.Port is an access port

CPU5 [09/19/07 13:03:50] SNMP INFO Link Down(1/40)

CPU5 [09/19/07 13:03:50] SNMP INFO Link Down 1/40.Port is an access port

CPU5 [09/19/07 13:03:50] SNMP INFO Link Down(1/41)

CPU5 [09/19/07 13:03:50] SNMP INFO Link Down 1/41.Port is an access port

CPU5 [09/19/07 13:03:50] SNMP INFO Link Down(1/42)

CPU5 [09/19/07 13:03:50] SNMP INFO Link Down 1/42.Port is an access port

CPU5 [09/19/07 13:03:50] SNMP INFO Link Down(1/43)

CPU5 [09/19/07 13:03:50] SNMP INFO Link Down 1/43.Port is an access port

CPU5 [09/19/07 13:03:50] SNMP INFO Link Down(1/44)

CPU5 [09/19/07 13:03:50] SNMP INFO Link Down 1/44.Port is an access port

CPU5 [09/19/07 13:03:50] SNMP INFO Link Down(1/45)

CPU5 [09/19/07 13:03:50] SNMP INFO Link Down 1/45.Port is an access port

CPU5 [09/19/07 13:03:50] SNMP INFO Link Down(1/46)

CPU5 [09/19/07 13:03:50] SNMP INFO Link Down 1/46.Port is an access port

CPU5 [09/19/07 13:03:50] SNMP INFO Link Down(1/47)

CPU5 [09/19/07 13:03:50] SNMP INFO Link Down 1/47.Port is an access port

CPU5 [09/19/07 13:03:50] SNMP INFO Link Down(1/48)

CPU5 [09/19/07 13:03:50] SNMP INFO Link Down 1/48.Port is an access port

CPU5 [09/19/07 13:03:50] SNMP INFO Fan Up(FanId=1, OperStatus=2)

CPU5 [09/19/07 13:03:50] SNMP INFO SSH server enabled

CPU5 [09/19/07 13:03:50] SNMP INFO Link Up(1/1)

CPU5 [09/19/07 13:03:52] NONE INFO Spanning Tree Topology Change. New Root bridge 00:04:38:69:c8:01 for StgId = 1

CPU5 [09/19/07 13:04:20] SNMP INFO Spanning Tree Topology Change(StgId=1, PortNum=1/1, MacAddr=00:04:38:69:c8:01)

CPU5 [09/19/07 13:04:28] SNMP INFO Sending Cold-Start Trap

CPU5 [09/19/07 13:38:16] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/19/07 13:38:16] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/19/07 13:38:16] SSH INFO Accepted password for ROOT from 10.100.32.55 port 3027 ssh2

CPU5 [09/19/07 13:38:16] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.55

CPU5 [09/19/07 13:38:16] SNMP INFO SSH new session login

CPU5 [09/19/07 13:38:17] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/19/07 13:38:17] SNMP INFO SSH session logout

CPU5 [09/19/07 13:40:25] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/19/07 13:40:25] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/19/07 13:40:26] SSH INFO Accepted password for ROOT from 10.100.32.55 port 3498 ssh2

CPU5 [09/19/07 13:40:26] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.55

CPU5 [09/19/07 13:40:26] SNMP INFO SSH new session login

CPU5 [09/19/07 13:42:34] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/19/07 13:42:34] SNMP INFO SSH session logout

CPU5 [09/19/07 14:38:27] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/19/07 14:38:27] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/19/07 14:38:28] SSH INFO Accepted password for ROOT from 10.100.32.55 port 4051 ssh2

CPU5 [09/19/07 14:38:28] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.55

CPU5 [09/19/07 14:38:28] SNMP INFO SSH new session login

CPU5 [09/19/07 14:38:34] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/19/07 14:38:34] SNMP INFO SSH session logout

CPU5 [09/19/07 14:40:46] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/19/07 14:40:46] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/19/07 14:40:48] SSH INFO Accepted password for ROOT from 10.100.32.55 port 4500 ssh2

CPU5 [09/19/07 14:40:48] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.55

CPU5 [09/19/07 14:40:48] SNMP INFO SSH new session login

CPU5 [09/19/07 14:42:09] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/19/07 15:16:50] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/19/07 15:16:50] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/19/07 15:16:52] SSH INFO Accepted password for ROOT from 10.100.32.18 port 60573 ssh2

CPU5 [09/19/07 15:16:53] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.18

CPU5 [09/19/07 15:16:53] SNMP INFO SSH new session login

CPU5 [09/19/07 15:18:05] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/19/07 15:24:09] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/19/07 15:24:09] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/19/07 15:24:10] SSH INFO Accepted password for ROOT from 10.10.1.89 port 4189 ssh2

CPU5 [09/19/07 15:24:10] SSH INFO SSH: User testlab login /pty/sshd1. from 10.10.1.89

CPU5 [09/19/07 15:24:10] SNMP INFO SSH new session login

CPU5 [09/19/07 15:29:45] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/19/07 15:29:45] SNMP INFO SSH session logout

CPU5 [09/19/07 15:33:06] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/19/07 15:33:06] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/19/07 15:33:07] SSH INFO Accepted password for ROOT from 10.100.32.14 port 4422 ssh2

CPU5 [09/19/07 15:33:07] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.14

CPU5 [09/19/07 15:33:07] SNMP INFO SSH new session login

CPU5 [09/19/07 15:37:15] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/19/07 15:37:15] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/19/07 15:37:15] SSH INFO Accepted password for ROOT from 10.100.32.55 port 1351 ssh2

CPU5 [09/19/07 15:37:15] SSH INFO SSH: User testlab login /pty/sshd2. from 10.100.32.55

CPU5 [09/19/07 15:37:15] SNMP INFO SSH new session login

CPU5 [09/19/07 15:37:16] SSH INFO SSH: User /pty/sshd2. logout

CPU5 [09/19/07 15:37:16] SNMP INFO SSH session logout

CPU5 [09/19/07 15:37:31] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/19/07 15:37:31] SNMP INFO SSH session logout

CPU5 [09/19/07 15:47:04] SW INFO user testlab connected from 10.100.32.14 via telnet

CPU5 [09/19/07 15:49:00] SW INFO Closed telnet connection from IP 10.100.32.14, user testlab

CPU5 [09/19/07 16:20:38] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/19/07 16:20:38] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/19/07 16:20:40] SSH INFO Accepted password for ROOT from 192.168.11.239 port 45549 ssh2

CPU5 [09/19/07 16:20:40] SSH INFO SSH: User testlab login /pty/sshd1. from 192.168.11.239

CPU5 [09/19/07 16:20:40] SNMP INFO SSH new session login

CPU5 [09/19/07 16:23:10] SSH ERROR Write failed: S_errno_EWOULDBLOCK

CPU5 [09/19/07 16:23:10] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/19/07 16:30:26] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/19/07 16:30:26] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/19/07 16:30:58] SSH INFO Accepted password for ROOT from 10.100.32.55 port 2034 ssh2

CPU5 [09/19/07 16:30:58] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.55

CPU5 [09/19/07 16:30:58] SNMP INFO SSH new session login

CPU5 [09/19/07 16:32:23] SW INFO user testlab connected from 10.100.32.14 via telnet

CPU5 [09/19/07 16:33:17] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/19/07 16:33:17] SNMP INFO SSH session logout

CPU5 [09/19/07 16:34:58] SW INFO Closed telnet connection from IP 10.100.32.14, user testlab

CPU5 [09/19/07 16:37:16] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/19/07 16:37:16] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/19/07 16:37:17] SSH INFO Accepted password for ROOT from 10.100.32.55 port 2376 ssh2

CPU5 [09/19/07 16:37:17] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.55

CPU5 [09/19/07 16:37:17] SNMP INFO SSH new session login

CPU5 [09/19/07 16:37:23] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/19/07 16:37:23] SNMP INFO SSH session logout

CPU5 [09/19/07 17:37:42] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/19/07 17:37:42] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/19/07 17:37:42] SSH INFO Accepted password for ROOT from 10.100.32.55 port 2897 ssh2

CPU5 [09/19/07 17:37:43] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.55

CPU5 [09/19/07 17:37:43] SNMP INFO SSH new session login

CPU5 [09/19/07 17:37:43] SSH INFO Disconnecting: Bad packet length 1319370934.

CPU5 [09/19/07 17:37:43] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/19/07 18:10:53] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/19/07 18:10:53] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/19/07 18:10:54] SSH INFO Failed password for ROOT from 10.100.32.88 port 4346 ssh2

CPU5 [09/19/07 18:33:41] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/19/07 18:33:41] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/19/07 18:33:45] SSH INFO Accepted password for ROOT from 10.100.32.55 port 3561 ssh2

CPU5 [09/19/07 18:33:45] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.55

CPU5 [09/19/07 18:33:45] SNMP INFO SSH new session login

CPU5 [09/19/07 18:37:57] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/19/07 18:37:57] SNMP INFO SSH session logout

CPU5 [09/19/07 18:38:14] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/19/07 18:38:14] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/19/07 18:38:15] SSH INFO Accepted password for ROOT from 10.100.32.55 port 3892 ssh2

CPU5 [09/19/07 18:38:15] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.55

CPU5 [09/19/07 18:38:15] SNMP INFO SSH new session login

CPU5 [09/19/07 18:38:21] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/19/07 18:38:21] SNMP INFO SSH session logout

CPU5 [09/19/07 18:54:59] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/19/07 18:54:59] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/19/07 18:55:00] SSH INFO Accepted password for ROOT from 10.10.1.184 port 3567 ssh2

CPU5 [09/19/07 18:55:00] SSH INFO SSH: User testlab login /pty/sshd1. from 10.10.1.184

CPU5 [09/19/07 18:55:00] SNMP INFO SSH new session login

CPU5 [09/19/07 18:56:27] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/19/07 18:56:27] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/19/07 18:56:29] SSH INFO Accepted password for ROOT from 10.100.32.55 port 4437 ssh2

CPU5 [09/19/07 18:56:29] SSH INFO SSH: User testlab login /pty/sshd2. from 10.100.32.55

CPU5 [09/19/07 18:56:29] SNMP INFO SSH new session login

CPU5 [09/19/07 18:57:42] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/19/07 19:01:02] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/19/07 19:01:02] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/19/07 19:01:03] SSH INFO Accepted password for ROOT from 10.100.7.210 port 1577 ssh2

CPU5 [09/19/07 19:01:03] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.7.210

CPU5 [09/19/07 19:01:03] SNMP INFO SSH new session login

CPU5 [09/19/07 19:01:11] SSH INFO SSH: User /pty/sshd2. logout

CPU5 [09/19/07 19:01:11] SNMP INFO SSH session logout

CPU5 [09/19/07 19:03:10] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/19/07 19:03:10] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/19/07 19:03:12] SSH INFO Accepted password for ROOT from 10.100.32.41 port 2232 ssh2

CPU5 [09/19/07 19:03:13] SSH INFO SSH: User testlab login /pty/sshd2. from 10.100.32.41

CPU5 [09/19/07 19:03:13] SNMP INFO SSH new session login

CPU5 [09/19/07 19:04:58] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/19/07 19:08:07] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/19/07 19:08:07] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/19/07 19:08:13] SSH INFO Accepted password for ROOT from 10.100.7.200 port 3191 ssh2

CPU5 [09/19/07 19:08:13] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.7.200

CPU5 [09/19/07 19:08:13] SNMP INFO SSH new session login

CPU5 [09/19/07 19:10:07] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/19/07 19:10:07] SNMP INFO SSH session logout

CPU5 [09/19/07 19:11:22] SSH INFO SSH: User /pty/sshd2. logout

CPU5 [09/19/07 19:11:22] SNMP INFO SSH session logout

CPU5 [09/19/07 19:37:41] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/19/07 19:37:41] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/19/07 19:37:42] SSH INFO Accepted password for ROOT from 10.100.32.55 port 4879 ssh2

CPU5 [09/19/07 19:37:42] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.55

CPU5 [09/19/07 19:37:42] SNMP INFO SSH new session login

CPU5 [09/19/07 19:37:48] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/19/07 19:37:48] SNMP INFO SSH session logout

CPU5 [09/19/07 19:53:21] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/19/07 19:53:21] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/19/07 19:53:23] SSH INFO Accepted password for ROOT from 10.100.32.55 port 1506 ssh2

CPU5 [09/19/07 19:53:23] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.55

CPU5 [09/19/07 19:53:23] SNMP INFO SSH new session login

CPU5 [09/19/07 19:56:12] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/19/07 19:56:12] SNMP INFO SSH session logout

CPU5 [09/19/07 20:37:29] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/19/07 20:37:29] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/19/07 20:37:30] SSH INFO Accepted password for ROOT from 10.100.32.55 port 1911 ssh2

CPU5 [09/19/07 20:37:30] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.55

CPU5 [09/19/07 20:37:30] SNMP INFO SSH new session login

CPU5 [09/19/07 20:37:36] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/19/07 20:37:36] SNMP INFO SSH session logout

CPU5 [09/19/07 20:39:35] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/19/07 20:39:35] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/19/07 20:39:37] SSH INFO Accepted password for ROOT from 10.100.32.55 port 2334 ssh2

CPU5 [09/19/07 20:39:37] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.55

CPU5 [09/19/07 20:39:37] SNMP INFO SSH new session login

CPU5 [09/19/07 20:41:56] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/19/07 21:37:44] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/19/07 21:37:44] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/19/07 21:37:44] SSH INFO Accepted password for ROOT from 10.100.32.55 port 2909 ssh2

CPU5 [09/19/07 21:37:45] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.55

CPU5 [09/19/07 21:37:45] SNMP INFO SSH new session login

CPU5 [09/19/07 21:37:50] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/19/07 21:39:52] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/19/07 21:39:52] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/19/07 21:39:53] SSH INFO Accepted password for ROOT from 10.100.32.55 port 3354 ssh2

CPU5 [09/19/07 21:39:53] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.55

CPU5 [09/19/07 21:39:53] SNMP INFO SSH new session login

CPU5 [09/19/07 21:43:29] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/19/07 21:43:29] SNMP INFO SSH session logout

CPU5 [09/19/07 22:37:36] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/19/07 22:37:36] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/19/07 22:37:36] SSH INFO Accepted password for ROOT from 10.100.32.55 port 3904 ssh2

CPU5 [09/19/07 22:37:36] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.55

CPU5 [09/19/07 22:37:36] SNMP INFO SSH new session login

CPU5 [09/19/07 22:37:42] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/19/07 22:39:50] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/19/07 22:39:50] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/19/07 22:39:51] SSH INFO Accepted password for ROOT from 10.100.32.55 port 4320 ssh2

CPU5 [09/19/07 22:39:51] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.55

CPU5 [09/19/07 22:39:51] SNMP INFO SSH new session login

CPU5 [09/19/07 22:43:13] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/19/07 22:43:13] SNMP INFO SSH session logout

CPU5 [09/19/07 23:37:28] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/19/07 23:37:28] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/19/07 23:37:28] SSH INFO Accepted password for ROOT from 10.100.32.55 port 4942 ssh2

CPU5 [09/19/07 23:37:29] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.55

CPU5 [09/19/07 23:37:29] SNMP INFO SSH new session login

CPU5 [09/19/07 23:37:34] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/19/07 23:37:34] SNMP INFO SSH session logout

CPU5 [09/20/07 00:05:33] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 00:05:33] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 00:05:34] SSH INFO Accepted password for ROOT from 10.10.1.112 port 36619 ssh2

CPU5 [09/20/07 00:05:34] SSH INFO SSH: User testlab login /pty/sshd1. from 10.10.1.112

CPU5 [09/20/07 00:05:34] SNMP INFO SSH new session login

CPU5 [09/20/07 00:07:40] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/20/07 00:07:40] SNMP INFO SSH session logout

CPU5 [09/20/07 00:38:12] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 00:38:12] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 00:38:13] SSH INFO Accepted password for ROOT from 10.100.32.55 port 1579 ssh2

CPU5 [09/20/07 00:38:13] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.55

CPU5 [09/20/07 00:38:13] SNMP INFO SSH new session login

CPU5 [09/20/07 00:38:19] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/20/07 00:38:19] SNMP INFO SSH session logout

CPU5 [09/20/07 00:40:13] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 00:40:13] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 00:40:13] SSH INFO Accepted password for ROOT from 10.100.32.55 port 1903 ssh2

CPU5 [09/20/07 00:40:14] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.55

CPU5 [09/20/07 00:40:14] SNMP INFO SSH new session login

CPU5 [09/20/07 00:41:15] SSH ERROR Write failed: S_errno_EWOULDBLOCK

CPU5 [09/20/07 00:41:15] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/20/07 00:46:38] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 00:46:38] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 00:46:38] SSH INFO Accepted password for ROOT from 10.10.1.89 port 2479 ssh2

CPU5 [09/20/07 00:46:38] SSH INFO SSH: User testlab login /pty/sshd1. from 10.10.1.89

CPU5 [09/20/07 00:46:38] SNMP INFO SSH new session login

CPU5 [09/20/07 00:49:17] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/20/07 00:49:17] SNMP INFO SSH session logout

CPU5 [09/20/07 01:38:26] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 01:38:26] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 01:38:27] SSH INFO Accepted password for ROOT from 10.100.32.55 port 2647 ssh2

CPU5 [09/20/07 01:38:27] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.55

CPU5 [09/20/07 01:38:27] SNMP INFO SSH new session login

CPU5 [09/20/07 01:38:33] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/20/07 01:40:17] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 01:40:17] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 01:40:19] SSH INFO Accepted password for ROOT from 10.100.32.55 port 2903 ssh2

CPU5 [09/20/07 01:40:19] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.55

CPU5 [09/20/07 01:40:19] SNMP INFO SSH new session login

CPU5 [09/20/07 01:43:02] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/20/07 01:43:02] SNMP INFO SSH session logout

CPU5 [09/20/07 02:36:28] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 02:36:28] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 02:36:29] SSH INFO Accepted password for ROOT from 10.100.32.55 port 3734 ssh2

CPU5 [09/20/07 02:36:29] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.55

CPU5 [09/20/07 02:36:29] SNMP INFO SSH new session login

CPU5 [09/20/07 02:36:35] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/20/07 02:36:35] SNMP INFO SSH session logout

CPU5 [09/20/07 03:36:37] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 03:36:37] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 03:36:37] SSH INFO Accepted password for ROOT from 10.100.32.55 port 4257 ssh2

CPU5 [09/20/07 03:36:38] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.55

CPU5 [09/20/07 03:36:38] SNMP INFO SSH new session login

CPU5 [09/20/07 03:36:39] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/20/07 03:37:26] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 03:37:26] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 03:37:26] SSH INFO Accepted password for ROOT from 10.10.1.133 port 1738 ssh2

CPU5 [09/20/07 03:37:26] SSH INFO SSH: User testlab login /pty/sshd1. from 10.10.1.133

CPU5 [09/20/07 03:37:26] SNMP INFO SSH new session login

CPU5 [09/20/07 03:39:02] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 03:39:02] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 03:39:03] SSH INFO Accepted password for ROOT from 10.100.32.55 port 4732 ssh2

CPU5 [09/20/07 03:39:03] SSH INFO SSH: User testlab login /pty/sshd2. from 10.100.32.55

CPU5 [09/20/07 03:39:03] SNMP INFO SSH new session login

CPU5 [09/20/07 03:40:52] SSH INFO SSH: User /pty/sshd2. logout

CPU5 [09/20/07 03:40:52] SNMP INFO SSH session logout

CPU5 [09/20/07 03:57:31] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/20/07 03:57:31] SNMP INFO SSH session logout

CPU5 [09/20/07 04:36:17] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 04:36:17] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 04:36:20] SSH INFO Accepted password for ROOT from 10.100.32.55 port 1332 ssh2

CPU5 [09/20/07 04:36:20] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.55

CPU5 [09/20/07 04:36:20] SNMP INFO SSH new session login

CPU5 [09/20/07 04:36:21] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/20/07 04:36:21] SNMP INFO SSH session logout

CPU5 [09/20/07 04:38:10] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 04:38:10] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 04:38:12] SSH INFO Accepted password for ROOT from 10.100.32.55 port 1731 ssh2

CPU5 [09/20/07 04:38:12] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.55

CPU5 [09/20/07 04:38:12] SNMP INFO SSH new session login

CPU5 [09/20/07 04:41:03] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/20/07 04:41:03] SNMP INFO SSH session logout

CPU5 [09/20/07 05:36:03] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 05:36:03] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 05:36:03] SSH INFO Accepted password for ROOT from 10.100.32.55 port 2310 ssh2

CPU5 [09/20/07 05:36:03] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.55

CPU5 [09/20/07 05:36:03] SNMP INFO SSH new session login

CPU5 [09/20/07 05:36:09] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/20/07 05:36:09] SNMP INFO SSH session logout

CPU5 [09/20/07 05:38:30] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 05:38:30] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 05:38:30] SSH INFO Accepted password for ROOT from 10.100.32.55 port 2738 ssh2

CPU5 [09/20/07 05:38:31] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.55

CPU5 [09/20/07 05:38:31] SNMP INFO SSH new session login

CPU5 [09/20/07 05:41:42] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/20/07 05:41:42] SNMP INFO SSH session logout

CPU5 [09/20/07 06:37:44] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 06:37:44] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 06:37:45] SSH INFO Accepted password for ROOT from 10.100.32.55 port 3297 ssh2

CPU5 [09/20/07 06:37:45] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.55

CPU5 [09/20/07 06:37:45] SNMP INFO SSH new session login

CPU5 [09/20/07 06:37:51] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/20/07 06:37:51] SNMP INFO SSH session logout

CPU5 [09/20/07 06:40:17] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 06:40:17] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 06:40:19] SSH INFO Accepted password for ROOT from 10.100.32.55 port 3739 ssh2

CPU5 [09/20/07 06:40:19] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.55

CPU5 [09/20/07 06:40:19] SNMP INFO SSH new session login

CPU5 [09/20/07 06:43:37] SSH ERROR Write failed: S_errno_EWOULDBLOCK

CPU5 [09/20/07 06:43:37] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/20/07 07:37:33] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 07:37:33] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 07:37:34] SSH INFO Accepted password for ROOT from 10.100.32.55 port 4282 ssh2

CPU5 [09/20/07 07:37:34] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.55

CPU5 [09/20/07 07:37:34] SNMP INFO SSH new session login

CPU5 [09/20/07 07:37:40] SSH ERROR padding error: need 12 block 8 mod 4

CPU5 [09/20/07 07:37:40] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/20/07 07:40:06] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 07:40:06] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 07:40:07] SSH INFO Accepted password for ROOT from 10.100.32.55 port 4734 ssh2

CPU5 [09/20/07 07:40:07] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.55

CPU5 [09/20/07 07:40:07] SNMP INFO SSH new session login

CPU5 [09/20/07 07:43:06] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/20/07 07:43:06] SNMP INFO SSH session logout

CPU5 [09/20/07 08:37:28] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 08:37:28] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 08:37:29] SSH INFO Accepted password for ROOT from 10.100.32.55 port 1342 ssh2

CPU5 [09/20/07 08:37:29] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.55

CPU5 [09/20/07 08:37:29] SNMP INFO SSH new session login

CPU5 [09/20/07 08:37:35] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/20/07 08:37:35] SNMP INFO SSH session logout

CPU5 [09/20/07 08:40:02] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 08:40:02] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 08:40:02] SSH INFO Accepted password for ROOT from 10.100.32.55 port 1787 ssh2

CPU5 [09/20/07 08:40:02] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.55

CPU5 [09/20/07 08:40:02] SNMP INFO SSH new session login

CPU5 [09/20/07 08:43:20] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/20/07 08:43:20] SNMP INFO SSH session logout

CPU5 [09/20/07 09:04:35] SW INFO user testlab connected from 10.10.1.102 via telnet

CPU5 [09/20/07 09:15:16] SW INFO Closed telnet connection from IP 10.10.1.102, user testlab

CPU5 [09/20/07 09:15:19] SW INFO user testlab connected from 10.10.1.102 via telnet

CPU5 [09/20/07 09:21:49] SW INFO Closed telnet connection from IP 10.10.1.102, user testlab

CPU5 [09/20/07 09:38:10] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 09:38:10] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 09:38:11] SSH INFO Accepted password for ROOT from 10.100.32.55 port 2368 ssh2

CPU5 [09/20/07 09:38:11] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.55

CPU5 [09/20/07 09:38:11] SNMP INFO SSH new session login

CPU5 [09/20/07 09:38:17] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/20/07 09:40:23] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 09:40:23] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 09:40:24] SSH INFO Accepted password for ROOT from 10.100.32.55 port 2811 ssh2

CPU5 [09/20/07 09:40:24] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.55

CPU5 [09/20/07 09:40:24] SNMP INFO SSH new session login

CPU5 [09/20/07 09:45:43] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/20/07 09:45:43] SNMP INFO SSH session logout

CPU5 [09/20/07 09:45:58] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 09:45:58] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 09:45:59] SSH INFO Accepted password for ROOT from 10.100.32.55 port 3336 ssh2

CPU5 [09/20/07 09:45:59] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.55

CPU5 [09/20/07 09:45:59] SNMP INFO SSH new session login

CPU5 [09/20/07 09:48:44] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/20/07 09:48:44] SNMP INFO SSH session logout

CPU5 [09/20/07 10:36:53] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 10:36:53] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 10:36:54] SSH INFO Accepted password for ROOT from 10.100.32.55 port 3829 ssh2

CPU5 [09/20/07 10:36:54] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.55

CPU5 [09/20/07 10:36:54] SNMP INFO SSH new session login

CPU5 [09/20/07 10:37:00] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/20/07 10:37:00] SNMP INFO SSH session logout

CPU5 [09/20/07 10:42:32] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 10:42:32] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 10:42:33] SSH INFO Failed password for ROOT from 192.168.11.238 port 4781 ssh2

CPU5 [09/20/07 10:43:31] SSH INFO Connection closed by 192.168.11.238

CPU5 [09/20/07 11:39:22] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 11:39:22] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 11:39:22] SSH INFO Accepted password for ROOT from 10.100.32.55 port 4379 ssh2

CPU5 [09/20/07 11:39:23] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.55

CPU5 [09/20/07 11:39:23] SNMP INFO SSH new session login

CPU5 [09/20/07 11:39:24] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/20/07 11:39:24] SNMP INFO SSH session logout

CPU5 [09/20/07 11:42:25] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/20/07 11:48:45] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 11:48:45] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 11:48:46] SSH INFO Accepted password for ROOT from 10.100.32.55 port 4878 ssh2

CPU5 [09/20/07 11:48:46] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.55

CPU5 [09/20/07 11:48:46] SNMP INFO SSH new session login

CPU5 [09/20/07 11:52:20] SSH ERROR Write failed: S_errno_EWOULDBLOCK

CPU5 [09/20/07 11:52:20] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/20/07 12:03:53] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 12:03:53] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 12:03:54] SSH INFO Accepted password for ROOT from 192.168.11.238 port 2160 ssh2

CPU5 [09/20/07 12:03:54] SSH INFO SSH: User testlab login /pty/sshd1. from 192.168.11.238

CPU5 [09/20/07 12:03:54] SNMP INFO SSH new session login

CPU5 [09/20/07 12:06:17] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/20/07 12:06:17] SNMP INFO SSH session logout

CPU5 [09/20/07 12:08:44] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 12:08:44] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 12:08:45] SSH INFO Accepted password for ROOT from 10.100.32.55 port 1524 ssh2

CPU5 [09/20/07 12:08:45] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.55

CPU5 [09/20/07 12:08:45] SNMP INFO SSH new session login

CPU5 [09/20/07 12:11:32] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/20/07 12:11:32] SNMP INFO SSH session logout

CPU5 [09/20/07 12:32:36] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 12:32:36] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 12:32:37] SSH INFO Accepted password for ROOT from 192.168.11.238 port 3045 ssh2

CPU5 [09/20/07 12:32:38] SSH INFO SSH: User testlab login /pty/sshd1. from 192.168.11.238

CPU5 [09/20/07 12:32:38] SNMP INFO SSH new session login

CPU5 [09/20/07 12:35:12] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/20/07 12:35:12] SNMP INFO SSH session logout

CPU5 [09/20/07 12:38:47] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 12:38:47] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 12:38:48] SSH INFO Accepted password for ROOT from 10.100.32.55 port 1881 ssh2

CPU5 [09/20/07 12:38:48] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.55

CPU5 [09/20/07 12:38:48] SNMP INFO SSH new session login

CPU5 [09/20/07 12:38:54] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/20/07 12:41:05] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/20/07 12:52:45] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 12:52:45] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 12:52:50] SSH INFO Accepted password for ROOT from 10.100.32.83 port 59158 ssh2

CPU5 [09/20/07 12:52:50] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.83

CPU5 [09/20/07 12:52:50] SNMP INFO SSH new session login

CPU5 [09/20/07 12:59:36] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/20/07 12:59:36] SNMP INFO SSH session logout

CPU5 [09/20/07 13:04:28] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/20/07 13:09:31] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 13:09:31] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 13:09:35] SSH INFO Accepted password for ROOT from 10.100.32.55 port 2526 ssh2

CPU5 [09/20/07 13:09:35] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.55

CPU5 [09/20/07 13:09:35] SNMP INFO SSH new session login

CPU5 [09/20/07 13:11:50] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/20/07 13:11:50] SNMP INFO SSH session logout

CPU5 [09/20/07 13:22:17] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/20/07 13:34:16] SSH INFO Failed password for ROOT from 10.10.1.32 port 2391

CPU5 [09/20/07 13:34:16] SSH INFO Connection closed by 10.10.1.32

[09/20/07 13:34:16] The previous message repeated 2 time(s).          

CPU5 [09/20/07 13:36:04] SSH INFO Failed password for ROOT from 10.10.1.32 port 2449

CPU5 [09/20/07 13:36:04] SSH INFO Connection closed by 10.10.1.32

[09/20/07 13:36:04] The previous message repeated 2 time(s).          

CPU5 [09/20/07 13:37:55] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 13:37:55] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 13:37:58] SSH INFO Accepted password for ROOT from 192.168.11.239 port 58358 ssh2

CPU5 [09/20/07 13:37:58] SSH INFO SSH: User testlab login /pty/sshd1. from 192.168.11.239

CPU5 [09/20/07 13:37:58] SNMP INFO SSH new session login

CPU5 [09/20/07 13:38:17] SSH INFO Failed password for ROOT from 10.10.1.32 port 2493

CPU5 [09/20/07 13:38:17] SSH INFO Connection closed by 10.10.1.32

[09/20/07 13:38:17] The previous message repeated 2 time(s).          

CPU5 [09/20/07 13:38:18] SSH INFO Failed password for ROOT from 10.10.1.32 port 2496

CPU5 [09/20/07 13:38:18] SSH INFO Connection closed by 10.10.1.32

[09/20/07 13:38:18] The previous message repeated 2 time(s).          

CPU5 [09/20/07 13:38:47] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 13:38:47] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 13:38:48] SSH INFO Accepted password for ROOT from 10.100.32.55 port 2886 ssh2

CPU5 [09/20/07 13:38:48] SSH INFO SSH: User testlab login /pty/sshd2. from 10.100.32.55

CPU5 [09/20/07 13:38:48] SNMP INFO SSH new session login

CPU5 [09/20/07 13:38:54] SSH INFO SSH: User /pty/sshd2. logout

CPU5 [09/20/07 13:38:54] SNMP INFO SSH session logout

CPU5 [09/20/07 13:41:28] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/20/07 13:41:28] SNMP INFO SSH session logout

CPU5 [09/20/07 14:05:04] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 14:05:04] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 14:05:11] SSH INFO Accepted password for ROOT from 10.100.32.83 port 60475 ssh2

CPU5 [09/20/07 14:05:12] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.83

CPU5 [09/20/07 14:05:12] SNMP INFO SSH new session login

CPU5 [09/20/07 14:07:26] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/20/07 14:08:12] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/20/07 14:12:49] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 14:12:49] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 14:12:51] SSH INFO Accepted password for ROOT from 10.100.32.55 port 3503 ssh2

CPU5 [09/20/07 14:12:51] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.55

CPU5 [09/20/07 14:12:51] SNMP INFO SSH new session login

CPU5 [09/20/07 14:16:16] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/20/07 14:16:16] SNMP INFO SSH session logout

CPU5 [09/20/07 14:23:12] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/20/07 14:38:26] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 14:38:26] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 14:38:27] SSH INFO Accepted password for ROOT from 10.100.32.55 port 3895 ssh2

CPU5 [09/20/07 14:38:27] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.55

CPU5 [09/20/07 14:38:27] SNMP INFO SSH new session login

CPU5 [09/20/07 14:38:33] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/20/07 14:38:33] SNMP INFO SSH session logout

CPU5 [09/20/07 15:16:11] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 15:16:11] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 15:16:13] SSH INFO Accepted password for ROOT from 10.100.32.44 port 59236 ssh2

CPU5 [09/20/07 15:16:13] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.44

CPU5 [09/20/07 15:16:13] SNMP INFO SSH new session login

CPU5 [09/20/07 15:18:34] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/20/07 15:18:34] SNMP INFO SSH session logout

CPU5 [09/20/07 15:39:32] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 15:39:32] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 15:39:33] SSH INFO Accepted password for ROOT from 10.100.32.55 port 4463 ssh2

CPU5 [09/20/07 15:39:33] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.55

CPU5 [09/20/07 15:39:33] SNMP INFO SSH new session login

CPU5 [09/20/07 15:39:33] SW WARNING  Code=0x1ff0009Blocked unauthorized cli access

CPU5 [09/20/07 15:39:39] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/20/07 15:39:39] SNMP INFO SSH session logout

CPU5 [09/20/07 15:39:41] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/20/07 15:41:25] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 15:41:25] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 15:41:28] SSH INFO Accepted password for ROOT from 192.168.11.238 port 1538 ssh2

CPU5 [09/20/07 15:41:29] SSH INFO SSH: User testlab login /pty/sshd1. from 192.168.11.238

CPU5 [09/20/07 15:41:29] SNMP INFO SSH new session login

CPU5 [09/20/07 15:44:07] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/20/07 15:44:07] SNMP INFO SSH session logout

CPU5 [09/20/07 15:44:14] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/20/07 15:44:15] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/20/07 15:49:49] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 15:49:49] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 15:49:52] SSH INFO Accepted password for ROOT from 10.100.32.55 port 1026 ssh2

CPU5 [09/20/07 15:49:53] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.55

CPU5 [09/20/07 15:49:53] SNMP INFO SSH new session login

CPU5 [09/20/07 15:54:52] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/20/07 15:54:52] SNMP INFO SSH session logout

CPU5 [09/20/07 15:56:49] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/20/07 16:01:50] SW INFO user testlab connected from 192.168.11.129 via telnet

[09/20/07 16:02:29] The previous message repeated 1 time(s).          

CPU5 [09/20/07 16:02:30] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/20/07 16:12:01] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/20/07 16:13:35] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/20/07 16:15:28] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/20/07 16:16:11] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

[09/20/07 16:25:04] The previous message repeated 1 time(s).          

CPU5 [09/20/07 16:40:27] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 16:40:27] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 16:40:28] SSH INFO Accepted password for ROOT from 10.100.32.55 port 1483 ssh2

CPU5 [09/20/07 16:40:28] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.55

CPU5 [09/20/07 16:40:28] SNMP INFO SSH new session login

CPU5 [09/20/07 16:40:34] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/20/07 16:50:18] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 16:50:18] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 16:50:18] SSH INFO Accepted password for ROOT from 10.100.32.55 port 2004 ssh2

CPU5 [09/20/07 16:50:18] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.55

CPU5 [09/20/07 16:50:18] SNMP INFO SSH new session login

CPU5 [09/20/07 16:53:25] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/20/07 17:38:59] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 17:38:59] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 17:38:59] SSH INFO Accepted password for ROOT from 10.100.32.55 port 2456 ssh2

CPU5 [09/20/07 17:39:00] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.55

CPU5 [09/20/07 17:39:00] SNMP INFO SSH new session login

CPU5 [09/20/07 17:39:05] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/20/07 17:39:05] SNMP INFO SSH session logout

CPU5 [09/20/07 17:51:27] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 17:51:27] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 17:51:28] SSH INFO Accepted password for ROOT from 10.100.32.55 port 3027 ssh2

CPU5 [09/20/07 17:51:28] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.55

CPU5 [09/20/07 17:51:28] SNMP INFO SSH new session login

CPU5 [09/20/07 17:54:34] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/20/07 17:54:34] SNMP INFO SSH session logout

CPU5 [09/20/07 18:03:12] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/20/07 18:04:05] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/20/07 18:07:58] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/20/07 18:08:50] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/20/07 18:10:16] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/20/07 18:11:00] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/20/07 18:13:07] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/20/07 18:13:44] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/20/07 18:16:25] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/20/07 18:17:07] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/20/07 18:40:15] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 18:40:15] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 18:40:15] SSH INFO Accepted password for ROOT from 10.100.32.55 port 3473 ssh2

CPU5 [09/20/07 18:40:16] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.55

CPU5 [09/20/07 18:40:16] SNMP INFO SSH new session login

CPU5 [09/20/07 18:40:22] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/20/07 18:40:22] SNMP INFO SSH session logout

CPU5 [09/20/07 18:51:41] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 18:51:41] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 18:51:43] SSH INFO Accepted password for ROOT from 10.100.32.55 port 4011 ssh2

CPU5 [09/20/07 18:51:43] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.55

CPU5 [09/20/07 18:51:43] SNMP INFO SSH new session login

CPU5 [09/20/07 18:54:35] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 18:54:35] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 18:54:35] SSH INFO Accepted password for ROOT from 10.10.1.184 port 3314 ssh2

CPU5 [09/20/07 18:54:36] SSH INFO SSH: User testlab login /pty/sshd2. from 10.10.1.184

CPU5 [09/20/07 18:54:36] SNMP INFO SSH new session login

CPU5 [09/20/07 18:57:17] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/20/07 18:57:44] SSH INFO SSH: User /pty/sshd2. logout

CPU5 [09/20/07 18:58:17] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 18:58:17] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 18:58:18] SSH INFO Accepted password for ROOT from 10.100.32.55 port 4555 ssh2

CPU5 [09/20/07 18:58:18] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.55

CPU5 [09/20/07 18:58:18] SNMP INFO SSH new session login

CPU5 [09/20/07 19:01:31] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 19:01:31] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 19:01:32] SSH INFO Accepted password for ROOT from 10.100.7.210 port 1861 ssh2

CPU5 [09/20/07 19:01:32] SSH INFO SSH: User testlab login /pty/sshd2. from 10.100.7.210

CPU5 [09/20/07 19:01:32] SNMP INFO SSH new session login

CPU5 [09/20/07 19:01:57] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 19:01:57] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 19:01:59] SSH INFO Accepted password for ROOT from 10.100.7.200 port 4927 ssh2

CPU5 [09/20/07 19:01:59] SSH INFO SSH: User testlab login /pty/sshd3. from 10.100.7.200

CPU5 [09/20/07 19:01:59] SNMP INFO SSH new session login

CPU5 [09/20/07 19:03:01] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 19:03:01] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 19:03:03] SSH INFO Accepted password for ROOT from 10.100.32.41 port 3841 ssh2

CPU5 [09/20/07 19:03:03] SSH INFO SSH: User testlab login /pty/sshd4. from 10.100.32.41

CPU5 [09/20/07 19:03:03] SNMP INFO SSH new session login

CPU5 [09/20/07 19:03:09] SSH INFO SSH: User /pty/sshd3. logout

CPU5 [09/20/07 19:03:13] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/20/07 19:04:30] SSH INFO SSH: User /pty/sshd2. logout

CPU5 [09/20/07 19:06:11] SSH INFO SSH: User /pty/sshd4. logout

CPU5 [09/20/07 19:39:20] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 19:39:20] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 19:39:20] SSH INFO Accepted password for ROOT from 10.100.32.55 port 4953 ssh2

CPU5 [09/20/07 19:39:21] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.55

CPU5 [09/20/07 19:39:21] SNMP INFO SSH new session login

CPU5 [09/20/07 19:39:26] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/20/07 19:39:26] SNMP INFO SSH session logout

CPU5 [09/20/07 20:36:52] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 20:36:52] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 20:36:53] SSH INFO Accepted password for ROOT from 10.100.32.55 port 1541 ssh2

CPU5 [09/20/07 20:36:53] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.55

CPU5 [09/20/07 20:36:53] SNMP INFO SSH new session login

CPU5 [09/20/07 20:36:54] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/20/07 20:36:54] SNMP INFO SSH session logout

CPU5 [09/20/07 20:41:05] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 20:41:05] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 20:41:06] SSH INFO Accepted password for ROOT from 10.100.32.55 port 1955 ssh2

CPU5 [09/20/07 20:41:06] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.55

CPU5 [09/20/07 20:41:06] SNMP INFO SSH new session login

CPU5 [09/20/07 20:44:04] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/20/07 20:44:04] SNMP INFO SSH session logout

CPU5 [09/20/07 21:36:48] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 21:36:48] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 21:36:48] SSH INFO Accepted password for ROOT from 10.100.32.55 port 2527 ssh2

CPU5 [09/20/07 21:36:49] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.55

CPU5 [09/20/07 21:36:49] SNMP INFO SSH new session login

CPU5 [09/20/07 21:36:54] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/20/07 21:36:54] SNMP INFO SSH session logout

CPU5 [09/20/07 21:41:21] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 21:41:21] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 21:41:22] SSH INFO Accepted password for ROOT from 10.100.32.55 port 2977 ssh2

CPU5 [09/20/07 21:41:23] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.55

CPU5 [09/20/07 21:41:23] SNMP INFO SSH new session login

CPU5 [09/20/07 21:45:07] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/20/07 21:45:07] SNMP INFO SSH session logout

CPU5 [09/20/07 22:36:30] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 22:36:30] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 22:36:31] SSH INFO Accepted password for ROOT from 10.100.32.55 port 3535 ssh2

CPU5 [09/20/07 22:36:31] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.55

CPU5 [09/20/07 22:36:31] SNMP INFO SSH new session login

CPU5 [09/20/07 22:36:37] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/20/07 22:36:37] SNMP INFO SSH session logout

CPU5 [09/20/07 22:41:35] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 22:41:35] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 22:41:36] SSH INFO Accepted password for ROOT from 10.100.32.55 port 4019 ssh2

CPU5 [09/20/07 22:41:36] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.55

CPU5 [09/20/07 22:41:36] SNMP INFO SSH new session login

CPU5 [09/20/07 22:44:43] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/20/07 22:44:43] SNMP INFO SSH session logout

CPU5 [09/20/07 23:36:26] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 23:36:26] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 23:36:27] SSH INFO Accepted password for ROOT from 10.100.32.55 port 4544 ssh2

CPU5 [09/20/07 23:36:27] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.55

CPU5 [09/20/07 23:36:27] SNMP INFO SSH new session login

CPU5 [09/20/07 23:36:33] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/20/07 23:36:33] SNMP INFO SSH session logout

CPU5 [09/20/07 23:41:44] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 23:41:44] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/20/07 23:41:45] SSH INFO Accepted password for ROOT from 10.100.32.55 port 1111 ssh2

CPU5 [09/20/07 23:41:45] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.55

CPU5 [09/20/07 23:41:45] SNMP INFO SSH new session login

CPU5 [09/20/07 23:46:18] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/20/07 23:46:18] SNMP INFO SSH session logout

CPU5 [09/21/07 00:06:09] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/21/07 00:06:09] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/21/07 00:06:11] SSH INFO Accepted password for ROOT from 10.10.1.112 port 43470 ssh2

CPU5 [09/21/07 00:06:11] SSH INFO SSH: User testlab login /pty/sshd1. from 10.10.1.112

CPU5 [09/21/07 00:06:11] SNMP INFO SSH new session login

CPU5 [09/21/07 00:08:25] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/21/07 00:08:25] SNMP INFO SSH session logout

CPU5 [09/21/07 00:36:00] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/21/07 00:36:00] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/21/07 00:36:01] SSH INFO Accepted password for ROOT from 10.100.32.55 port 1615 ssh2

CPU5 [09/21/07 00:36:01] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.55

CPU5 [09/21/07 00:36:01] SNMP INFO SSH new session login

CPU5 [09/21/07 00:36:07] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/21/07 00:36:07] SNMP INFO SSH session logout

CPU5 [09/21/07 00:42:19] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/21/07 00:42:19] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/21/07 00:42:20] SSH INFO Accepted password for ROOT from 10.100.32.55 port 2079 ssh2

CPU5 [09/21/07 00:42:21] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.55

CPU5 [09/21/07 00:42:21] SNMP INFO SSH new session login

CPU5 [09/21/07 00:47:27] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/21/07 00:47:27] SNMP INFO SSH session logout

CPU5 [09/21/07 00:51:29] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/21/07 00:51:29] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/21/07 00:51:30] SSH INFO Accepted password for ROOT from 10.10.1.89 port 3390 ssh2

CPU5 [09/21/07 00:51:30] SSH INFO SSH: User testlab login /pty/sshd1. from 10.10.1.89

CPU5 [09/21/07 00:51:30] SNMP INFO SSH new session login

CPU5 [09/21/07 00:56:26] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/21/07 00:56:26] SNMP INFO SSH session logout

CPU5 [09/21/07 01:30:37] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/21/07 01:30:37] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/21/07 01:30:37] SSH INFO Accepted password for ROOT from 10.10.1.133 port 3131 ssh2

CPU5 [09/21/07 01:30:37] SSH INFO SSH: User testlab login /pty/sshd1. from 10.10.1.133

CPU5 [09/21/07 01:30:37] SNMP INFO SSH new session login

CPU5 [09/21/07 01:35:53] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/21/07 01:35:53] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/21/07 01:35:54] SSH INFO Accepted password for ROOT from 10.100.32.55 port 2589 ssh2

CPU5 [09/21/07 01:35:54] SSH INFO SSH: User testlab login /pty/sshd2. from 10.100.32.55

CPU5 [09/21/07 01:35:54] SNMP INFO SSH new session login

CPU5 [09/21/07 01:36:00] SSH INFO SSH: User /pty/sshd2. logout

CPU5 [09/21/07 01:36:00] SNMP INFO SSH session logout

CPU5 [09/21/07 01:42:08] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/21/07 01:42:08] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/21/07 01:42:09] SSH INFO Accepted password for ROOT from 10.100.32.55 port 3069 ssh2

CPU5 [09/21/07 01:42:09] SSH INFO SSH: User testlab login /pty/sshd2. from 10.100.32.55

CPU5 [09/21/07 01:42:09] SNMP INFO SSH new session login

CPU5 [09/21/07 01:44:30] SSH INFO SSH: User /pty/sshd2. logout

CPU5 [09/21/07 01:44:30] SNMP INFO SSH session logout

CPU5 [09/21/07 01:48:06] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/21/07 01:48:06] SNMP INFO SSH session logout

CPU5 [09/21/07 10:47:51] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/21/07 10:48:38] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/21/07 10:51:51] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/21/07 10:52:34] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/21/07 11:36:59] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/21/07 11:55:16] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/21/07 12:24:08] SW INFO user testlab connected from 10.10.1.108 via telnet

[09/21/07 12:24:31] The previous message repeated 1 time(s).          

CPU5 [09/21/07 12:24:31] SW INFO Closed telnet connection from IP 10.10.1.108, user testlab

CPU5 [09/21/07 12:38:07] SW INFO user testlab connected from 10.10.1.108 via telnet

CPU5 [09/21/07 12:38:38] SW INFO Closed telnet connection from IP 10.10.1.108, user testlab

[09/21/07 12:39:11] The previous message repeated 1 time(s).          

CPU5 [09/21/07 12:43:43] SW INFO user testlab connected from 10.10.1.108 via telnet

CPU5 [09/21/07 12:44:16] SW INFO Closed telnet connection from IP 10.10.1.108, user testlab

CPU5 [09/21/07 12:48:40] SW INFO user testlab connected from 10.10.1.108 via telnet

[09/21/07 12:50:09] The previous message repeated 1 time(s).          

CPU5 [09/21/07 12:50:42] SW INFO Closed telnet connection from IP 10.10.1.108, user testlab

CPU5 [09/21/07 12:57:33] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/21/07 12:57:33] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/21/07 12:57:35] SSH INFO Failed password for ROOT from 10.10.1.34 port 44998 ssh2

CPU5 [09/21/07 12:57:41] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/21/07 12:57:41] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/21/07 12:57:41] SSH INFO Accepted password for ROOT from 10.10.1.34 port 45007 ssh2

CPU5 [09/21/07 12:57:42] SSH INFO SSH: User testlab login /pty/sshd2. from 10.10.1.34

CPU5 [09/21/07 12:57:42] SNMP INFO SSH new session login

CPU5 [09/21/07 12:58:33] SSH INFO Connection closed by 10.10.1.34

CPU5 [09/21/07 12:59:34] SSH INFO SSH: User /pty/sshd2. logout

CPU5 [09/21/07 12:59:34] SNMP INFO SSH session logout

CPU5 [09/21/07 13:02:57] SW INFO user testlab connected from 10.10.1.108 via telnet

CPU5 [09/21/07 13:03:53] SW INFO Closed telnet connection from IP 10.10.1.108, user testlab

CPU5 [09/21/07 13:07:05] SW INFO user testlab connected from 10.10.1.108 via telnet

CPU5 [09/21/07 13:07:59] SW INFO Closed telnet connection from IP 10.10.1.108, user testlab

[09/21/07 13:08:12] The previous message repeated 1 time(s).          

CPU5 [09/21/07 13:26:11] SW INFO user testlab connected from 10.10.1.108 via telnet

CPU5 [09/21/07 13:26:43] SW INFO Closed telnet connection from IP 10.10.1.108, user testlab

CPU5 [09/21/07 13:27:39] SW INFO user testlab connected from 10.10.1.108 via telnet

CPU5 [09/21/07 13:28:10] SW INFO Closed telnet connection from IP 10.10.1.108, user testlab

CPU5 [09/21/07 13:29:01] SW INFO user testlab connected from 10.10.1.108 via telnet

CPU5 [09/21/07 13:30:38] SW INFO Closed telnet connection from IP 10.10.1.108, user testlab

CPU5 [09/21/07 13:49:53] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/21/07 13:49:53] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/21/07 13:49:53] SSH INFO Accepted password for ROOT from 10.100.32.83 port 36997 ssh2

CPU5 [09/21/07 13:49:53] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.83

CPU5 [09/21/07 13:49:53] SNMP INFO SSH new session login

CPU5 [09/21/07 13:51:39] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/21/07 13:51:39] SNMP INFO SSH session logout

CPU5 [09/21/07 14:23:20] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/21/07 14:23:20] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/21/07 14:23:20] SSH INFO Accepted password for ROOT from 10.100.32.83 port 37921 ssh2

CPU5 [09/21/07 14:23:21] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.83

CPU5 [09/21/07 14:23:21] SNMP INFO SSH new session login

CPU5 [09/21/07 14:25:08] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/21/07 14:25:08] SNMP INFO SSH session logout

CPU5 [09/21/07 14:45:03] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/21/07 15:29:23] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/21/07 16:32:49] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/21/07 16:32:49] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/21/07 16:32:50] SSH INFO Accepted password for ROOT from 192.168.11.76 port 2035 ssh2

CPU5 [09/21/07 16:32:50] SSH INFO SSH: User testlab login /pty/sshd1. from 192.168.11.76

CPU5 [09/21/07 16:32:50] SNMP INFO SSH new session login

CPU5 [09/21/07 16:34:58] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/21/07 16:34:58] SNMP INFO SSH session logout

CPU5 [09/21/07 16:59:33] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/21/07 17:00:13] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/21/07 17:01:43] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/21/07 17:02:31] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/21/07 17:03:29] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/21/07 17:04:12] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/21/07 17:07:02] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/21/07 17:07:54] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/21/07 17:15:43] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/21/07 17:16:29] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/21/07 17:17:16] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/21/07 17:18:05] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/21/07 17:21:52] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/21/07 17:22:36] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/21/07 17:30:57] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/21/07 17:31:45] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/21/07 17:32:48] SW INFO user testlab connected from 192.168.11.129 via telnet

[09/21/07 17:33:03] The previous message repeated 1 time(s).          

CPU5 [09/21/07 17:34:14] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/21/07 17:36:07] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/21/07 17:36:50] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/21/07 17:37:50] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/21/07 17:38:33] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/21/07 17:38:56] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/21/07 17:39:40] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/21/07 17:40:01] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/21/07 17:40:47] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/21/07 17:41:37] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/21/07 17:41:39] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/21/07 17:43:04] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/21/07 17:43:05] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/21/07 17:44:06] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/21/07 17:44:08] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/21/07 17:45:07] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/21/07 17:45:52] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

[09/21/07 17:48:05] The previous message repeated 1 time(s).          

CPU5 [09/21/07 17:54:50] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/21/07 17:56:39] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/21/07 18:26:26] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/21/07 18:26:26] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/21/07 18:26:27] SSH INFO Failed password for ROOT from 10.100.32.88 port 3110 ssh2

CPU5 [09/21/07 18:53:44] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/21/07 18:53:44] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/21/07 18:53:45] SSH INFO Accepted password for ROOT from 10.10.1.184 port 3137 ssh2

CPU5 [09/21/07 18:53:45] SSH INFO SSH: User testlab login /pty/sshd1. from 10.10.1.184

CPU5 [09/21/07 18:53:45] SNMP INFO SSH new session login

CPU5 [09/21/07 18:56:00] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/21/07 18:56:00] SNMP INFO SSH session logout

CPU5 [09/21/07 19:00:59] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/21/07 19:00:59] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/21/07 19:00:59] SSH INFO Accepted password for ROOT from 10.100.7.210 port 2178 ssh2

CPU5 [09/21/07 19:00:59] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.7.210

CPU5 [09/21/07 19:00:59] SNMP INFO SSH new session login

CPU5 [09/21/07 19:03:13] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/21/07 19:03:13] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/21/07 19:03:15] SSH INFO Accepted password for ROOT from 10.100.32.41 port 1654 ssh2

CPU5 [09/21/07 19:03:15] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/21/07 19:03:15] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/21/07 19:03:15] SSH INFO SSH: User testlab login /pty/sshd2. from 10.100.32.41

CPU5 [09/21/07 19:03:15] SNMP INFO SSH new session login

CPU5 [09/21/07 19:03:19] SSH INFO Accepted password for ROOT from 10.100.7.200 port 2908 ssh2

CPU5 [09/21/07 19:03:19] SSH INFO SSH: User testlab login /pty/sshd3. from 10.100.7.200

CPU5 [09/21/07 19:03:19] SNMP INFO SSH new session login

CPU5 [09/21/07 19:04:37] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/21/07 19:05:42] SSH INFO SSH: User /pty/sshd2. logout

CPU5 [09/21/07 19:10:20] SSH INFO SSH: User /pty/sshd3. logout

CPU5 [09/22/07 00:05:45] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/22/07 00:05:45] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/22/07 00:05:47] SSH INFO Accepted password for ROOT from 10.10.1.112 port 50722 ssh2

CPU5 [09/22/07 00:05:47] SSH INFO SSH: User testlab login /pty/sshd1. from 10.10.1.112

CPU5 [09/22/07 00:05:47] SNMP INFO SSH new session login

CPU5 [09/22/07 00:08:10] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/22/07 00:08:10] SNMP INFO SSH session logout

CPU5 [09/22/07 00:46:54] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/22/07 00:46:54] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/22/07 00:46:55] SSH INFO Accepted password for ROOT from 10.10.1.89 port 4016 ssh2

CPU5 [09/22/07 00:46:55] SSH INFO SSH: User testlab login /pty/sshd1. from 10.10.1.89

CPU5 [09/22/07 00:46:55] SNMP INFO SSH new session login

CPU5 [09/22/07 00:52:08] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/22/07 05:20:25] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/22/07 05:20:25] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/22/07 05:20:25] SSH INFO Accepted password for ROOT from 10.10.1.133 port 4561 ssh2

CPU5 [09/22/07 05:20:25] SSH INFO SSH: User testlab login /pty/sshd1. from 10.10.1.133

CPU5 [09/22/07 05:20:25] SNMP INFO SSH new session login

CPU5 [09/22/07 05:37:53] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/22/07 05:37:53] SNMP INFO SSH session logout

CPU5 [09/22/07 17:25:26] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/22/07 17:40:26] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/22/07 18:06:09] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/22/07 18:15:36] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/22/07 18:15:36] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/22/07 18:15:49] SSH INFO Failed password for ROOT from 10.100.32.88 port 3970 ssh2

CPU5 [09/22/07 18:21:28] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/22/07 18:32:21] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/22/07 18:48:53] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/22/07 18:54:28] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/22/07 18:54:28] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/22/07 18:54:29] SSH INFO Accepted password for ROOT from 10.10.1.184 port 3202 ssh2

CPU5 [09/22/07 18:54:29] SSH INFO SSH: User testlab login /pty/sshd1. from 10.10.1.184

CPU5 [09/22/07 18:54:29] SNMP INFO SSH new session login

CPU5 [09/22/07 18:56:42] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/22/07 18:56:42] SNMP INFO SSH session logout

CPU5 [09/22/07 19:01:27] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/22/07 19:01:27] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/22/07 19:01:28] SSH INFO Accepted password for ROOT from 10.100.7.210 port 2466 ssh2

CPU5 [09/22/07 19:01:29] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.7.210

CPU5 [09/22/07 19:01:29] SNMP INFO SSH new session login

CPU5 [09/22/07 19:02:26] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/22/07 19:02:26] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/22/07 19:02:27] SSH INFO Accepted password for ROOT from 10.100.7.200 port 1103 ssh2

CPU5 [09/22/07 19:02:27] SSH INFO SSH: User testlab login /pty/sshd2. from 10.100.7.200

CPU5 [09/22/07 19:02:27] SNMP INFO SSH new session login

CPU5 [09/22/07 19:03:12] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/22/07 19:03:12] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/22/07 19:03:13] SSH INFO Accepted password for ROOT from 10.100.32.41 port 3318 ssh2

CPU5 [09/22/07 19:03:13] SSH INFO SSH: User testlab login /pty/sshd3. from 10.100.32.41

CPU5 [09/22/07 19:03:13] SNMP INFO SSH new session login

CPU5 [09/22/07 19:04:43] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/22/07 19:05:08] SSH INFO SSH: User /pty/sshd2. logout

CPU5 [09/22/07 19:05:59] SSH INFO SSH: User /pty/sshd3. logout

CPU5 [09/22/07 19:08:39] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/22/07 19:24:17] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/22/07 20:36:53] SW WARNING  Code=0x1ff0009Blocked unauthorized cli access

CPU5 [09/22/07 20:37:00] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/22/07 20:44:37] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/23/07 00:06:39] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/23/07 00:06:39] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/23/07 00:06:40] SSH INFO Accepted password for ROOT from 10.10.1.112 port 57163 ssh2

CPU5 [09/23/07 00:06:40] SSH INFO SSH: User testlab login /pty/sshd1. from 10.10.1.112

CPU5 [09/23/07 00:06:40] SNMP INFO SSH new session login

CPU5 [09/23/07 00:09:17] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/23/07 00:09:17] SNMP INFO SSH session logout

CPU5 [09/23/07 00:46:30] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/23/07 00:46:30] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/23/07 00:46:30] SSH INFO Accepted password for ROOT from 10.10.1.89 port 4553 ssh2

CPU5 [09/23/07 00:46:30] SSH INFO SSH: User testlab login /pty/sshd1. from 10.10.1.89

CPU5 [09/23/07 00:46:30] SNMP INFO SSH new session login

CPU5 [09/23/07 00:50:20] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/23/07 00:50:20] SNMP INFO SSH session logout

CPU5 [09/23/07 18:54:05] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/23/07 18:54:05] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/23/07 18:54:06] SSH INFO Accepted password for ROOT from 10.10.1.184 port 3288 ssh2

CPU5 [09/23/07 18:54:06] SSH INFO SSH: User testlab login /pty/sshd1. from 10.10.1.184

CPU5 [09/23/07 18:54:06] SNMP INFO SSH new session login

CPU5 [09/23/07 18:56:26] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/23/07 18:56:26] SNMP INFO SSH session logout

CPU5 [09/23/07 19:00:48] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/23/07 19:00:48] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/23/07 19:00:50] SSH INFO Accepted password for ROOT from 10.100.7.210 port 2749 ssh2

CPU5 [09/23/07 19:00:50] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.7.210

CPU5 [09/23/07 19:00:50] SNMP INFO SSH new session login

CPU5 [09/23/07 19:02:58] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/23/07 19:02:58] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/23/07 19:02:59] SSH INFO Accepted password for ROOT from 10.100.7.200 port 3098 ssh2

CPU5 [09/23/07 19:02:59] SSH INFO SSH: User testlab login /pty/sshd2. from 10.100.7.200

CPU5 [09/23/07 19:02:59] SNMP INFO SSH new session login

CPU5 [09/23/07 19:03:01] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/23/07 19:03:01] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/23/07 19:03:02] SSH INFO Accepted password for ROOT from 10.100.32.41 port 1043 ssh2

CPU5 [09/23/07 19:03:03] SSH INFO SSH: User testlab login /pty/sshd3. from 10.100.32.41

CPU5 [09/23/07 19:03:03] SNMP INFO SSH new session login

CPU5 [09/23/07 19:03:24] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/23/07 19:03:24] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/23/07 19:03:36] SSH INFO Accepted password for ROOT from 10.10.20.22 port 2550 ssh2

CPU5 [09/23/07 19:03:38] SSH INFO SSH: User testlab login /pty/sshd4. from 10.10.20.22

CPU5 [09/23/07 19:03:38] SNMP INFO SSH new session login

CPU5 [09/23/07 19:04:01] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/23/07 19:04:07] SSH INFO SSH: User /pty/sshd2. logout

CPU5 [09/23/07 19:06:06] SSH INFO SSH: User /pty/sshd4. logout

CPU5 [09/23/07 19:06:42] SSH INFO SSH: User /pty/sshd3. logout

CPU5 [09/24/07 00:07:43] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/24/07 00:07:43] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/24/07 00:07:43] SSH INFO Accepted password for ROOT from 10.10.1.112 port 1287 ssh2

CPU5 [09/24/07 00:07:43] SSH INFO SSH: User testlab login /pty/sshd1. from 10.10.1.112

CPU5 [09/24/07 00:07:43] SNMP INFO SSH new session login

CPU5 [09/24/07 00:10:26] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/24/07 00:10:26] SNMP INFO SSH session logout

CPU5 [09/24/07 00:48:19] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/24/07 00:48:19] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/24/07 00:48:20] SSH INFO Accepted password for ROOT from 10.10.1.89 port 1318 ssh2

CPU5 [09/24/07 00:48:20] SSH INFO SSH: User testlab login /pty/sshd1. from 10.10.1.89

CPU5 [09/24/07 00:48:20] SNMP INFO SSH new session login

CPU5 [09/24/07 00:51:47] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/24/07 00:51:47] SNMP INFO SSH session logout

CPU5 [09/24/07 11:40:49] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/24/07 11:40:49] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/24/07 11:40:50] SSH INFO Accepted password for ROOT from 10.100.32.83 port 47573 ssh2

CPU5 [09/24/07 11:40:50] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.83

CPU5 [09/24/07 11:40:50] SNMP INFO SSH new session login

CPU5 [09/24/07 11:46:18] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/24/07 11:46:18] SNMP INFO SSH session logout

CPU5 [09/24/07 12:37:01] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/24/07 12:37:01] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/24/07 12:37:02] SSH INFO Accepted password for ROOT from 192.168.11.76 port 1937 ssh2

CPU5 [09/24/07 12:37:03] SSH INFO SSH: User testlab login /pty/sshd1. from 192.168.11.76

CPU5 [09/24/07 12:37:03] SNMP INFO SSH new session login

CPU5 [09/24/07 12:39:30] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/24/07 12:39:30] SNMP INFO SSH session logout

CPU5 [09/24/07 13:49:24] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/24/07 13:49:24] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/24/07 13:49:29] SSH INFO Accepted password for ROOT from 10.10.20.20 port 4801 ssh2

CPU5 [09/24/07 13:49:32] SSH INFO SSH: User testlab login /pty/sshd1. from 10.10.20.20

CPU5 [09/24/07 13:49:32] SNMP INFO SSH new session login

CPU5 [09/24/07 13:59:15] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/24/07 13:59:15] SNMP INFO SSH session logout

CPU5 [09/24/07 14:03:38] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/24/07 14:03:38] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/24/07 14:03:38] SSH INFO Accepted password for ROOT from 10.100.32.83 port 49015 ssh2

CPU5 [09/24/07 14:03:38] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.83

CPU5 [09/24/07 14:03:38] SNMP INFO SSH new session login

CPU5 [09/24/07 14:07:00] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/24/07 15:03:51] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/24/07 15:03:51] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/24/07 15:03:51] SSH INFO Accepted password for ROOT from 10.100.32.83 port 50156 ssh2

CPU5 [09/24/07 15:03:51] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.83

CPU5 [09/24/07 15:03:51] SNMP INFO SSH new session login

CPU5 [09/24/07 15:07:08] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/24/07 16:03:53] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/24/07 16:03:53] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/24/07 16:03:54] SSH INFO Accepted password for ROOT from 10.100.32.83 port 50775 ssh2

CPU5 [09/24/07 16:03:54] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.83

CPU5 [09/24/07 16:03:54] SNMP INFO SSH new session login

CPU5 [09/24/07 16:07:49] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/24/07 16:07:49] SNMP INFO SSH session logout

CPU5 [09/24/07 16:24:28] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/24/07 16:24:28] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/24/07 16:24:28] SSH INFO Accepted password for ROOT from 10.100.32.85 port 2726 ssh2

CPU5 [09/24/07 16:24:29] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.85

CPU5 [09/24/07 16:24:29] SNMP INFO SSH new session login

CPU5 [09/24/07 16:29:24] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/24/07 16:29:24] SNMP INFO SSH session logout

CPU5 [09/24/07 17:04:21] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/24/07 17:05:16] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/24/07 17:05:16] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/24/07 17:05:17] SSH INFO Accepted password for ROOT from 10.100.32.83 port 51332 ssh2

CPU5 [09/24/07 17:05:17] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.83

CPU5 [09/24/07 17:05:17] SNMP INFO SSH new session login

CPU5 [09/24/07 17:05:18] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/24/07 17:09:12] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/24/07 17:09:12] SNMP INFO SSH session logout

CPU5 [09/24/07 17:09:29] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/24/07 17:10:31] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/24/07 17:23:16] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/24/07 17:23:16] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/24/07 17:23:16] SSH INFO Accepted password for ROOT from 10.100.32.85 port 3808 ssh2

CPU5 [09/24/07 17:23:16] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.85

CPU5 [09/24/07 17:23:16] SNMP INFO SSH new session login

CPU5 [09/24/07 17:26:35] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/24/07 18:03:22] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/24/07 18:03:22] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/24/07 18:03:23] SSH INFO Accepted password for ROOT from 10.100.32.83 port 51922 ssh2

CPU5 [09/24/07 18:03:23] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.83

CPU5 [09/24/07 18:03:23] SNMP INFO SSH new session login

CPU5 [09/24/07 18:05:53] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/24/07 18:05:53] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/24/07 18:05:54] SSH INFO Accepted password for ROOT from 192.168.11.75 port 51755 ssh2

CPU5 [09/24/07 18:05:54] SSH INFO SSH: User testlab login /pty/sshd2. from 192.168.11.75

CPU5 [09/24/07 18:05:54] SNMP INFO SSH new session login

CPU5 [09/24/07 18:07:38] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/24/07 18:09:30] SSH ERROR Write failed: S_errno_EWOULDBLOCK

CPU5 [09/24/07 18:09:30] SSH INFO SSH: User /pty/sshd2. logout

CPU5 [09/24/07 18:16:04] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/24/07 18:16:04] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/24/07 18:16:17] SSH INFO Failed password for ROOT from 10.100.32.88 port 3081 ssh2

CPU5 [09/24/07 18:21:45] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/24/07 18:21:45] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/24/07 18:21:48] SSH INFO Accepted password for ROOT from 10.100.32.85 port 4866 ssh2

CPU5 [09/24/07 18:21:48] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.85

CPU5 [09/24/07 18:21:48] SNMP INFO SSH new session login

CPU5 [09/24/07 18:24:06] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/24/07 18:53:59] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/24/07 18:53:59] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/24/07 18:54:00] SSH INFO Accepted password for ROOT from 10.10.1.184 port 3861 ssh2

CPU5 [09/24/07 18:54:00] SSH INFO SSH: User testlab login /pty/sshd1. from 10.10.1.184

CPU5 [09/24/07 18:54:00] SNMP INFO SSH new session login

CPU5 [09/24/07 18:58:53] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/24/07 18:58:53] SNMP INFO SSH session logout

CPU5 [09/24/07 19:01:25] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/24/07 19:01:25] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/24/07 19:01:26] SSH INFO Accepted password for ROOT from 10.100.7.210 port 3054 ssh2

CPU5 [09/24/07 19:01:26] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.7.210

CPU5 [09/24/07 19:01:26] SNMP INFO SSH new session login

CPU5 [09/24/07 19:02:38] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/24/07 19:02:38] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/24/07 19:02:42] SSH INFO Accepted password for ROOT from 10.100.7.200 port 1109 ssh2

CPU5 [09/24/07 19:02:42] SSH INFO SSH: User testlab login /pty/sshd2. from 10.100.7.200

CPU5 [09/24/07 19:02:42] SNMP INFO SSH new session login

CPU5 [09/24/07 19:03:19] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/24/07 19:03:19] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/24/07 19:03:25] SSH INFO Accepted password for ROOT from 10.100.32.41 port 2801 ssh2

CPU5 [09/24/07 19:03:26] SSH INFO SSH: User testlab login /pty/sshd3. from 10.100.32.41

CPU5 [09/24/07 19:03:26] SNMP INFO SSH new session login

CPU5 [09/24/07 19:03:31] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/24/07 19:03:31] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/24/07 19:03:32] SSH INFO Accepted password for ROOT from 10.100.32.83 port 52505 ssh2

CPU5 [09/24/07 19:03:33] SSH INFO SSH: User testlab login /pty/sshd4. from 10.100.32.83

CPU5 [09/24/07 19:03:33] SNMP INFO SSH new session login

CPU5 [09/24/07 19:04:33] SSH INFO SSH: User /pty/sshd3. logout

CPU5 [09/24/07 19:04:33] SNMP INFO SSH session logout

CPU5 [09/24/07 19:04:40] SSH INFO SSH: User /pty/sshd4. logout

CPU5 [09/24/07 19:05:22] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/24/07 19:05:37] SSH INFO SSH: User /pty/sshd2. logout

CPU5 [09/24/07 19:12:01] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/24/07 19:12:01] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/24/07 19:12:02] SSH INFO Accepted password for ROOT from 10.10.20.21 port 3018 ssh2

CPU5 [09/24/07 19:12:02] SSH INFO SSH: User testlab login /pty/sshd1. from 10.10.20.21

CPU5 [09/24/07 19:12:02] SNMP INFO SSH new session login

CPU5 [09/24/07 19:20:05] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/24/07 19:20:05] SNMP INFO SSH session logout

CPU5 [09/24/07 19:22:46] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/24/07 19:22:46] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/24/07 19:22:49] SSH INFO Accepted password for ROOT from 10.100.32.85 port 1924 ssh2

CPU5 [09/24/07 19:22:49] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.85

CPU5 [09/24/07 19:22:49] SNMP INFO SSH new session login

CPU5 [09/24/07 19:28:14] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/24/07 19:28:14] SNMP INFO SSH session logout

CPU5 [09/24/07 20:03:16] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/24/07 20:03:16] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/24/07 20:03:17] SSH INFO Accepted password for ROOT from 10.100.32.83 port 53082 ssh2

CPU5 [09/24/07 20:03:17] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.83

CPU5 [09/24/07 20:03:17] SNMP INFO SSH new session login

CPU5 [09/24/07 20:07:17] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/24/07 20:07:17] SNMP INFO SSH session logout

CPU5 [09/24/07 20:24:46] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/24/07 20:24:46] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/24/07 20:24:47] SSH INFO Accepted password for ROOT from 10.100.32.85 port 2995 ssh2

CPU5 [09/24/07 20:24:47] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.85

CPU5 [09/24/07 20:24:47] SNMP INFO SSH new session login

CPU5 [09/24/07 20:25:58] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/24/07 21:02:59] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/24/07 21:02:59] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/24/07 21:02:59] SSH INFO Accepted password for ROOT from 10.100.32.83 port 53644 ssh2

CPU5 [09/24/07 21:02:59] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.83

CPU5 [09/24/07 21:02:59] SNMP INFO SSH new session login

CPU5 [09/24/07 21:06:13] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/24/07 21:06:13] SNMP INFO SSH session logout

CPU5 [09/24/07 21:25:35] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/24/07 21:25:35] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/24/07 21:25:36] SSH INFO Accepted password for ROOT from 10.100.32.85 port 4032 ssh2

CPU5 [09/24/07 21:25:36] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.85

CPU5 [09/24/07 21:25:36] SNMP INFO SSH new session login

CPU5 [09/24/07 21:30:46] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/24/07 21:30:46] SNMP INFO SSH session logout

CPU5 [09/24/07 22:02:47] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/24/07 22:02:47] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/24/07 22:02:48] SSH INFO Accepted password for ROOT from 10.100.32.83 port 54237 ssh2

CPU5 [09/24/07 22:02:48] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.83

CPU5 [09/24/07 22:02:48] SNMP INFO SSH new session login

CPU5 [09/24/07 22:06:54] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/24/07 22:06:54] SNMP INFO SSH session logout

CPU5 [09/24/07 22:25:11] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/24/07 22:25:11] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/24/07 22:25:12] SSH INFO Accepted password for ROOT from 10.100.32.85 port 1171 ssh2

CPU5 [09/24/07 22:25:12] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.85

CPU5 [09/24/07 22:25:12] SNMP INFO SSH new session login

CPU5 [09/24/07 22:26:14] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/24/07 23:03:19] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/24/07 23:03:19] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/24/07 23:03:19] SSH INFO Accepted password for ROOT from 10.100.32.83 port 54825 ssh2

CPU5 [09/24/07 23:03:19] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.83

CPU5 [09/24/07 23:03:19] SNMP INFO SSH new session login

CPU5 [09/24/07 23:07:14] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/24/07 23:07:14] SNMP INFO SSH session logout

CPU5 [09/24/07 23:26:58] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/24/07 23:26:58] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/24/07 23:26:59] SSH INFO Accepted password for ROOT from 10.100.32.85 port 2227 ssh2

CPU5 [09/24/07 23:26:59] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.85

CPU5 [09/24/07 23:26:59] SNMP INFO SSH new session login

CPU5 [09/24/07 23:31:45] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/24/07 23:31:45] SNMP INFO SSH session logout

CPU5 [09/25/07 00:03:08] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 00:03:08] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 00:03:09] SSH INFO Accepted password for ROOT from 10.100.32.83 port 55395 ssh2

CPU5 [09/25/07 00:03:09] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.83

CPU5 [09/25/07 00:03:09] SNMP INFO SSH new session login

CPU5 [09/25/07 00:06:40] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/25/07 00:07:09] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 00:07:09] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 00:07:09] SSH INFO Accepted password for ROOT from 10.10.1.112 port 8172 ssh2

CPU5 [09/25/07 00:07:09] SSH INFO SSH: User testlab login /pty/sshd1. from 10.10.1.112

CPU5 [09/25/07 00:07:09] SNMP INFO SSH new session login

CPU5 [09/25/07 00:09:49] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/25/07 00:09:49] SNMP INFO SSH session logout

CPU5 [09/25/07 00:24:30] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 00:24:30] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 00:24:31] SSH INFO Accepted password for ROOT from 10.100.32.85 port 3262 ssh2

CPU5 [09/25/07 00:24:31] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.85

CPU5 [09/25/07 00:24:31] SNMP INFO SSH new session login

CPU5 [09/25/07 00:29:27] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/25/07 00:29:27] SNMP INFO SSH session logout

CPU5 [09/25/07 00:46:25] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 00:46:25] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 00:46:26] SSH INFO Accepted password for ROOT from 10.10.1.89 port 1948 ssh2

CPU5 [09/25/07 00:46:26] SSH INFO SSH: User testlab login /pty/sshd1. from 10.10.1.89

CPU5 [09/25/07 00:46:26] SNMP INFO SSH new session login

CPU5 [09/25/07 00:49:47] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/25/07 00:49:47] SNMP INFO SSH session logout

CPU5 [09/25/07 01:03:13] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 01:03:13] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 01:03:14] SSH INFO Accepted password for ROOT from 10.100.32.83 port 55975 ssh2

CPU5 [09/25/07 01:03:14] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.83

CPU5 [09/25/07 01:03:14] SNMP INFO SSH new session login

CPU5 [09/25/07 01:10:24] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/25/07 01:10:24] SNMP INFO SSH session logout

CPU5 [09/25/07 02:03:14] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 02:03:14] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 02:03:14] SSH INFO Accepted password for ROOT from 10.100.32.83 port 56542 ssh2

CPU5 [09/25/07 02:03:15] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.83

CPU5 [09/25/07 02:03:15] SNMP INFO SSH new session login

CPU5 [09/25/07 02:06:48] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/25/07 02:06:48] SNMP INFO SSH session logout

CPU5 [09/25/07 02:25:10] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 02:25:10] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 02:25:14] SSH INFO Accepted password for ROOT from 10.100.32.85 port 1212 ssh2

CPU5 [09/25/07 02:25:14] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.85

CPU5 [09/25/07 02:25:14] SNMP INFO SSH new session login

CPU5 [09/25/07 02:29:07] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/25/07 02:29:07] SNMP INFO SSH session logout

CPU5 [09/25/07 03:03:19] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 03:03:19] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 03:03:19] SSH INFO Accepted password for ROOT from 10.100.32.83 port 57094 ssh2

CPU5 [09/25/07 03:03:20] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.83

CPU5 [09/25/07 03:03:20] SNMP INFO SSH new session login

CPU5 [09/25/07 03:07:35] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/25/07 03:07:35] SNMP INFO SSH session logout

CPU5 [09/25/07 03:23:21] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 03:23:21] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 03:23:22] SSH INFO Accepted password for ROOT from 10.100.32.85 port 2235 ssh2

CPU5 [09/25/07 03:23:22] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.85

CPU5 [09/25/07 03:23:22] SNMP INFO SSH new session login

CPU5 [09/25/07 03:27:09] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/25/07 04:02:18] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 04:02:18] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 04:02:19] SSH INFO Accepted password for ROOT from 10.100.32.83 port 57710 ssh2

CPU5 [09/25/07 04:02:19] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.83

CPU5 [09/25/07 04:02:19] SNMP INFO SSH new session login

CPU5 [09/25/07 04:05:33] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/25/07 05:01:59] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 05:01:59] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 05:02:00] SSH INFO Accepted password for ROOT from 10.100.32.83 port 58299 ssh2

CPU5 [09/25/07 05:02:00] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.83

CPU5 [09/25/07 05:02:00] SNMP INFO SSH new session login

CPU5 [09/25/07 05:05:47] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/25/07 05:05:47] SNMP INFO SSH session logout

CPU5 [09/25/07 06:02:08] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 06:02:08] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 06:02:08] SSH INFO Accepted password for ROOT from 10.100.32.83 port 58877 ssh2

CPU5 [09/25/07 06:02:09] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.83

CPU5 [09/25/07 06:02:09] SNMP INFO SSH new session login

CPU5 [09/25/07 06:05:18] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/25/07 06:05:18] SNMP INFO SSH session logout

CPU5 [09/25/07 07:02:20] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 07:02:20] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 07:02:20] SSH INFO Accepted password for ROOT from 10.100.32.83 port 59456 ssh2

CPU5 [09/25/07 07:02:21] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.83

CPU5 [09/25/07 07:02:21] SNMP INFO SSH new session login

CPU5 [09/25/07 07:05:34] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/25/07 08:02:26] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 08:02:26] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 08:02:27] SSH INFO Accepted password for ROOT from 10.100.32.83 port 60034 ssh2

CPU5 [09/25/07 08:02:27] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.83

CPU5 [09/25/07 08:02:27] SNMP INFO SSH new session login

CPU5 [09/25/07 08:06:34] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/25/07 08:06:34] SNMP INFO SSH session logout

CPU5 [09/25/07 09:02:27] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 09:02:27] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 09:02:28] SSH INFO Accepted password for ROOT from 10.100.32.83 port 60605 ssh2

CPU5 [09/25/07 09:02:28] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.83

CPU5 [09/25/07 09:02:28] SNMP INFO SSH new session login

CPU5 [09/25/07 09:08:06] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/25/07 09:08:06] SNMP INFO SSH session logout

CPU5 [09/25/07 10:02:06] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 10:02:06] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 10:02:06] SSH INFO Accepted password for ROOT from 10.100.32.83 port 32956 ssh2

CPU5 [09/25/07 10:02:07] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.83

CPU5 [09/25/07 10:02:07] SNMP INFO SSH new session login

CPU5 [09/25/07 10:05:23] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/25/07 10:05:23] SNMP INFO SSH session logout

CPU5 [09/25/07 10:35:47] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 10:35:47] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 10:35:48] SSH INFO Accepted password for ROOT from 10.100.32.85 port 1332 ssh2

CPU5 [09/25/07 10:35:48] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.85

CPU5 [09/25/07 10:35:48] SNMP INFO SSH new session login

CPU5 [09/25/07 10:42:10] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/25/07 10:42:10] SNMP INFO SSH session logout

CPU5 [09/25/07 11:01:48] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 11:01:48] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 11:01:48] SSH INFO Accepted password for ROOT from 10.100.32.83 port 33533 ssh2

CPU5 [09/25/07 11:01:48] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.83

CPU5 [09/25/07 11:01:48] SNMP INFO SSH new session login

CPU5 [09/25/07 11:09:01] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/25/07 11:09:01] SNMP INFO SSH session logout

CPU5 [09/25/07 11:17:51] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 11:17:51] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 11:17:51] SSH INFO Accepted password for ROOT from 10.100.32.85 port 2774 ssh2

CPU5 [09/25/07 11:17:52] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.85

CPU5 [09/25/07 11:17:52] SNMP INFO SSH new session login

CPU5 [09/25/07 11:24:35] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/25/07 11:24:35] SNMP INFO SSH session logout

CPU5 [09/25/07 11:47:17] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 11:47:17] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 11:47:18] SSH INFO Failed password for ROOT from 192.168.11.79 port 49033 ssh2

CPU5 [09/25/07 12:01:41] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 12:01:41] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 12:01:42] SSH INFO Accepted password for ROOT from 10.100.32.83 port 34120 ssh2

CPU5 [09/25/07 12:01:42] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.83

CPU5 [09/25/07 12:01:42] SNMP INFO SSH new session login

CPU5 [09/25/07 12:04:06] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 12:04:06] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 12:04:07] SSH INFO Accepted password for ROOT from 10.100.32.18 port 49897 ssh2

CPU5 [09/25/07 12:04:07] SSH INFO SSH: User testlab login /pty/sshd2. from 10.100.32.18

CPU5 [09/25/07 12:04:07] SNMP INFO SSH new session login

CPU5 [09/25/07 12:05:43] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/25/07 12:05:43] SNMP INFO SSH session logout

CPU5 [09/25/07 12:07:46] SSH INFO SSH: User /pty/sshd2. logout

CPU5 [09/25/07 12:17:42] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 12:17:42] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 12:17:42] SSH INFO Accepted password for ROOT from 10.100.32.85 port 3850 ssh2

CPU5 [09/25/07 12:17:43] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.85

CPU5 [09/25/07 12:17:43] SNMP INFO SSH new session login

CPU5 [09/25/07 12:24:06] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/25/07 12:24:06] SNMP INFO SSH session logout

CPU5 [09/25/07 13:01:42] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 13:01:42] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 13:01:43] SSH INFO Accepted password for ROOT from 10.100.32.83 port 34682 ssh2

CPU5 [09/25/07 13:01:43] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.83

CPU5 [09/25/07 13:01:43] SNMP INFO SSH new session login

CPU5 [09/25/07 13:04:52] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/25/07 13:04:52] SNMP INFO SSH session logout

CPU5 [09/25/07 13:18:43] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 13:18:43] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 13:18:44] SSH INFO Accepted password for ROOT from 10.100.32.85 port 4922 ssh2

CPU5 [09/25/07 13:18:44] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.85

CPU5 [09/25/07 13:18:44] SNMP INFO SSH new session login

CPU5 [09/25/07 13:23:17] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/25/07 14:01:50] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 14:01:50] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 14:01:50] SSH INFO Accepted password for ROOT from 10.100.32.83 port 35258 ssh2

CPU5 [09/25/07 14:01:50] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.83

CPU5 [09/25/07 14:01:50] SNMP INFO SSH new session login

CPU5 [09/25/07 14:05:51] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/25/07 14:05:51] SNMP INFO SSH session logout

CPU5 [09/25/07 14:11:31] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/25/07 14:12:54] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/25/07 14:18:14] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 14:18:14] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 14:18:15] SSH INFO Accepted password for ROOT from 10.100.32.85 port 2041 ssh2

CPU5 [09/25/07 14:18:15] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.85

CPU5 [09/25/07 14:18:15] SNMP INFO SSH new session login

CPU5 [09/25/07 14:24:22] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/25/07 14:24:22] SNMP INFO SSH session logout

CPU5 [09/25/07 14:29:21] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/25/07 14:30:15] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/25/07 14:36:10] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/25/07 14:36:59] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/25/07 14:37:58] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/25/07 14:38:47] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/25/07 15:03:07] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 15:03:07] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 15:03:08] SSH INFO Accepted password for ROOT from 10.100.32.83 port 35843 ssh2

CPU5 [09/25/07 15:03:08] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.83

CPU5 [09/25/07 15:03:08] SNMP INFO SSH new session login

CPU5 [09/25/07 15:06:55] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/25/07 15:06:55] SNMP INFO SSH session logout

CPU5 [09/25/07 15:15:13] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/25/07 15:16:03] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/25/07 15:17:12] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 15:17:12] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 15:17:13] SSH INFO Accepted password for ROOT from 10.100.32.85 port 3134 ssh2

CPU5 [09/25/07 15:17:13] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.85

CPU5 [09/25/07 15:17:13] SNMP INFO SSH new session login

CPU5 [09/25/07 15:17:17] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/25/07 15:18:52] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/25/07 15:20:19] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/25/07 15:21:47] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/25/07 15:22:47] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/25/07 15:22:59] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/25/07 15:24:27] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/25/07 15:25:08] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/25/07 15:25:54] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/25/07 15:26:33] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/25/07 15:27:34] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/25/07 15:32:07] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/25/07 15:32:56] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/25/07 15:34:18] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/25/07 15:35:05] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/25/07 15:41:11] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/25/07 15:42:05] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/25/07 15:50:45] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 15:50:45] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 15:50:48] SSH INFO Failed password for ROOT from 192.168.11.78 port 1090 ssh2

CPU5 [09/25/07 15:53:39] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/25/07 15:54:48] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/25/07 16:03:15] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 16:03:15] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 16:03:16] SSH INFO Accepted password for ROOT from 10.100.32.83 port 36417 ssh2

CPU5 [09/25/07 16:03:16] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.83

CPU5 [09/25/07 16:03:16] SNMP INFO SSH new session login

CPU5 [09/25/07 16:07:25] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/25/07 16:07:25] SNMP INFO SSH session logout

CPU5 [09/25/07 16:19:16] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 16:19:16] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 16:19:17] SSH INFO Accepted password for ROOT from 10.100.32.85 port 4253 ssh2

CPU5 [09/25/07 16:19:17] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.85

CPU5 [09/25/07 16:19:17] SNMP INFO SSH new session login

CPU5 [09/25/07 16:19:19] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/25/07 16:21:30] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/25/07 16:22:20] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/25/07 16:23:14] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/25/07 16:24:49] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/25/07 16:35:58] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/25/07 16:37:26] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/25/07 16:38:52] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/25/07 16:39:43] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/25/07 16:41:21] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/25/07 16:42:09] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/25/07 16:44:06] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/25/07 16:45:41] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/25/07 17:06:09] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 17:06:09] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 17:06:09] SSH INFO Accepted password for ROOT from 10.100.32.83 port 37007 ssh2

CPU5 [09/25/07 17:06:10] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.83

CPU5 [09/25/07 17:06:10] SNMP INFO SSH new session login

CPU5 [09/25/07 17:08:55] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/25/07 17:18:19] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 17:18:19] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 17:18:20] SSH INFO Accepted password for ROOT from 10.100.32.85 port 1354 ssh2

CPU5 [09/25/07 17:18:20] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.85

CPU5 [09/25/07 17:18:20] SNMP INFO SSH new session login

CPU5 [09/25/07 17:22:13] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/25/07 17:35:38] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/25/07 17:52:58] SW INFO user testlab connected from 10.10.1.129 via telnet

CPU5 [09/25/07 18:03:39] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 18:03:39] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 18:03:40] SSH INFO Accepted password for ROOT from 10.100.32.83 port 37543 ssh2

CPU5 [09/25/07 18:03:41] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.83

CPU5 [09/25/07 18:03:41] SNMP INFO SSH new session login

CPU5 [09/25/07 18:06:44] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 18:06:44] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 18:06:46] SSH INFO Failed password for ROOT from 10.100.32.88 port 3490 ssh2

CPU5 [09/25/07 18:07:09] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/25/07 18:08:13] SW INFO Closed telnet connection from IP 10.10.1.129, user testlab

CPU5 [09/25/07 18:15:07] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/25/07 18:18:16] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/25/07 18:18:34] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 18:18:34] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 18:18:34] SSH INFO Accepted password for ROOT from 10.100.32.85 port 2465 ssh2

CPU5 [09/25/07 18:18:35] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.85

CPU5 [09/25/07 18:18:35] SNMP INFO SSH new session login

CPU5 [09/25/07 18:23:46] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/25/07 18:36:19] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/25/07 18:37:12] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/25/07 18:37:25] SW INFO user l3 connected from 192.168.11.129 via telnet

CPU5 [09/25/07 18:37:33] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/25/07 18:38:07] SW INFO Closed telnet connection from IP 192.168.11.129, user l3

CPU5 [09/25/07 18:38:13] SW INFO user l1 connected from 192.168.11.129 via telnet

CPU5 [09/25/07 18:38:46] SW INFO Closed telnet connection from IP 192.168.11.129, user l1

CPU5 [09/25/07 18:38:53] SW INFO user testlab connected from 192.168.11.129 via telnet

[09/25/07 18:41:40] The previous message repeated 1 time(s).          

CPU5 [09/25/07 18:42:49] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

[09/25/07 18:43:41] The previous message repeated 1 time(s).          

CPU5 [09/25/07 18:54:59] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 18:54:59] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 18:54:59] SSH INFO Accepted password for ROOT from 10.10.1.184 port 3873 ssh2

CPU5 [09/25/07 18:54:59] SSH INFO SSH: User testlab login /pty/sshd1. from 10.10.1.184

CPU5 [09/25/07 18:54:59] SNMP INFO SSH new session login

CPU5 [09/25/07 18:58:41] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/25/07 18:58:41] SNMP INFO SSH session logout

CPU5 [09/25/07 19:00:58] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 19:00:58] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 19:00:59] SSH INFO Accepted password for ROOT from 10.100.7.210 port 4496 ssh2

CPU5 [09/25/07 19:00:59] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.7.210

CPU5 [09/25/07 19:00:59] SNMP INFO SSH new session login

CPU5 [09/25/07 19:02:48] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 19:02:48] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 19:02:49] SSH INFO Accepted password for ROOT from 10.10.101.118 port 2550 ssh2

CPU5 [09/25/07 19:02:50] SSH INFO SSH: User testlab login /pty/sshd2. from 10.10.101.118

CPU5 [09/25/07 19:02:50] SNMP INFO SSH new session login

CPU5 [09/25/07 19:02:55] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 19:02:55] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 19:02:55] SSH INFO Accepted password for ROOT from 10.100.7.200 port 3107 ssh2

CPU5 [09/25/07 19:02:55] SSH INFO SSH: User testlab login /pty/sshd3. from 10.100.7.200

CPU5 [09/25/07 19:02:55] SNMP INFO SSH new session login

CPU5 [09/25/07 19:03:16] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 19:03:16] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 19:03:20] SSH INFO Accepted password for ROOT from 10.100.32.41 port 4567 ssh2

CPU5 [09/25/07 19:03:20] SSH INFO SSH: User testlab login /pty/sshd4. from 10.100.32.41

CPU5 [09/25/07 19:03:20] SNMP INFO SSH new session login

CPU5 [09/25/07 19:03:48] SSH ERROR sshd: failed to add connections

CPU5 [09/25/07 19:04:01] SSH INFO SSH: User /pty/sshd3. logout

CPU5 [09/25/07 19:04:01] SNMP INFO SSH session logout

CPU5 [09/25/07 19:04:18] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/25/07 19:05:03] SSH INFO SSH: User /pty/sshd2. logout

CPU5 [09/25/07 19:05:29] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 19:05:29] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 19:05:31] SSH INFO Accepted password for ROOT from 10.100.32.83 port 38134 ssh2

CPU5 [09/25/07 19:05:31] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.83

CPU5 [09/25/07 19:05:31] SNMP INFO SSH new session login

CPU5 [09/25/07 19:06:46] SSH INFO SSH: User /pty/sshd4. logout

CPU5 [09/25/07 19:08:12] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/25/07 19:17:55] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 19:17:55] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 19:17:56] SSH INFO Accepted password for ROOT from 10.100.32.85 port 3528 ssh2

CPU5 [09/25/07 19:17:56] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.85

CPU5 [09/25/07 19:17:56] SNMP INFO SSH new session login

CPU5 [09/25/07 19:21:40] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/25/07 20:03:35] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 20:03:35] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 20:03:36] SSH INFO Accepted password for ROOT from 10.100.32.83 port 38687 ssh2

CPU5 [09/25/07 20:03:36] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.83

CPU5 [09/25/07 20:03:36] SNMP INFO SSH new session login

CPU5 [09/25/07 20:05:24] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 20:05:24] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 20:05:26] SSH INFO Failed password for ROOT from 192.168.11.78 port 2536 ssh2

CPU5 [09/25/07 20:07:02] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/25/07 20:17:16] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 20:17:16] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 20:17:20] SSH INFO Accepted password for ROOT from 10.100.32.85 port 4637 ssh2

CPU5 [09/25/07 20:17:20] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.85

CPU5 [09/25/07 20:17:20] SNMP INFO SSH new session login

CPU5 [09/25/07 20:18:06] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 20:18:06] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 20:18:08] SSH INFO Failed password for ROOT from 192.168.11.79 port 51157 ssh2

CPU5 [09/25/07 20:21:07] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/25/07 21:03:45] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 21:03:45] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 21:03:46] SSH INFO Accepted password for ROOT from 10.100.32.83 port 39272 ssh2

CPU5 [09/25/07 21:03:46] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.83

CPU5 [09/25/07 21:03:46] SNMP INFO SSH new session login

CPU5 [09/25/07 21:08:18] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/25/07 21:08:18] SNMP INFO SSH session logout

CPU5 [09/25/07 21:18:19] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 21:18:19] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 21:18:20] SSH INFO Accepted password for ROOT from 10.100.32.85 port 1780 ssh2

CPU5 [09/25/07 21:18:20] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.85

CPU5 [09/25/07 21:18:20] SNMP INFO SSH new session login

CPU5 [09/25/07 21:24:31] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/25/07 21:24:31] SNMP INFO SSH session logout

CPU5 [09/25/07 22:04:02] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 22:04:02] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 22:04:02] SSH INFO Accepted password for ROOT from 10.100.32.83 port 39848 ssh2

CPU5 [09/25/07 22:04:03] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.83

CPU5 [09/25/07 22:04:03] SNMP INFO SSH new session login

CPU5 [09/25/07 22:09:42] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/25/07 22:09:42] SNMP INFO SSH session logout

CPU5 [09/25/07 22:17:28] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 22:17:28] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 22:17:28] SSH INFO Accepted password for ROOT from 10.100.32.85 port 2867 ssh2

CPU5 [09/25/07 22:17:28] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.85

CPU5 [09/25/07 22:17:28] SNMP INFO SSH new session login

CPU5 [09/25/07 22:24:18] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/25/07 22:24:18] SNMP INFO SSH session logout

CPU5 [09/25/07 23:03:56] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 23:03:56] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 23:03:56] SSH INFO Accepted password for ROOT from 10.100.32.83 port 40390 ssh2

CPU5 [09/25/07 23:03:57] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.83

CPU5 [09/25/07 23:03:57] SNMP INFO SSH new session login

CPU5 [09/25/07 23:13:48] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/25/07 23:13:48] SNMP INFO SSH session logout

CPU5 [09/25/07 23:17:22] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 23:17:22] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/25/07 23:17:22] SSH INFO Accepted password for ROOT from 10.100.32.85 port 3943 ssh2

CPU5 [09/25/07 23:17:23] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.85

CPU5 [09/25/07 23:17:23] SNMP INFO SSH new session login

CPU5 [09/25/07 23:24:33] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/25/07 23:24:33] SNMP INFO SSH session logout

CPU5 [09/26/07 00:06:35] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 00:06:35] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 00:06:38] SSH INFO Accepted password for ROOT from 10.10.1.112 port 17158 ssh2

CPU5 [09/26/07 00:06:38] SSH INFO SSH: User testlab login /pty/sshd1. from 10.10.1.112

CPU5 [09/26/07 00:06:38] SNMP INFO SSH new session login

CPU5 [09/26/07 00:07:14] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 00:07:14] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 00:07:16] SSH INFO Accepted password for ROOT from 10.100.32.83 port 40997 ssh2

CPU5 [09/26/07 00:07:16] SSH INFO SSH: User testlab login /pty/sshd2. from 10.100.32.83

CPU5 [09/26/07 00:07:16] SNMP INFO SSH new session login

CPU5 [09/26/07 00:09:52] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/26/07 00:13:13] SSH INFO SSH: User /pty/sshd2. logout

CPU5 [09/26/07 00:13:13] SNMP INFO SSH session logout

CPU5 [09/26/07 00:16:33] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 00:16:33] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 00:16:35] SSH INFO Accepted password for ROOT from 10.100.32.85 port 1073 ssh2

CPU5 [09/26/07 00:16:35] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.85

CPU5 [09/26/07 00:16:35] SNMP INFO SSH new session login

CPU5 [09/26/07 00:21:33] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/26/07 00:21:33] SNMP INFO SSH session logout

CPU5 [09/26/07 00:50:16] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 00:50:16] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 00:50:16] SSH INFO Accepted password for ROOT from 10.10.1.89 port 2448 ssh2

CPU5 [09/26/07 00:50:16] SSH INFO SSH: User testlab login /pty/sshd1. from 10.10.1.89

CPU5 [09/26/07 00:50:16] SNMP INFO SSH new session login

CPU5 [09/26/07 00:52:57] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/26/07 01:12:14] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 01:12:14] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 01:12:15] SSH INFO Accepted password for ROOT from 10.100.32.83 port 41566 ssh2

CPU5 [09/26/07 01:12:15] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.83

CPU5 [09/26/07 01:12:15] SNMP INFO SSH new session login

CPU5 [09/26/07 01:15:30] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/26/07 01:17:30] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 01:17:30] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 01:17:31] SSH INFO Accepted password for ROOT from 10.100.32.85 port 2142 ssh2

CPU5 [09/26/07 01:17:31] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.85

CPU5 [09/26/07 01:17:31] SNMP INFO SSH new session login

CPU5 [09/26/07 01:23:59] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/26/07 02:08:54] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 02:08:54] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 02:08:54] SSH INFO Accepted password for ROOT from 10.100.32.83 port 42145 ssh2

CPU5 [09/26/07 02:08:54] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.83

CPU5 [09/26/07 02:08:54] SNMP INFO SSH new session login

CPU5 [09/26/07 02:12:25] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/26/07 02:12:25] SNMP INFO SSH session logout

CPU5 [09/26/07 02:17:07] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 02:17:07] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 02:17:08] SSH INFO Accepted password for ROOT from 10.100.32.85 port 3217 ssh2

CPU5 [09/26/07 02:17:08] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.85

CPU5 [09/26/07 02:17:08] SNMP INFO SSH new session login

CPU5 [09/26/07 02:24:13] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/26/07 02:24:13] SNMP INFO SSH session logout

CPU5 [09/26/07 03:08:58] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 03:08:58] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 03:08:58] SSH INFO Accepted password for ROOT from 10.100.32.83 port 42725 ssh2

CPU5 [09/26/07 03:08:59] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.83

CPU5 [09/26/07 03:08:59] SNMP INFO SSH new session login

CPU5 [09/26/07 03:12:24] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/26/07 03:17:32] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 03:17:32] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 03:17:34] SSH INFO Accepted password for ROOT from 10.100.32.85 port 4333 ssh2

CPU5 [09/26/07 03:17:35] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.85

CPU5 [09/26/07 03:17:35] SNMP INFO SSH new session login

CPU5 [09/26/07 03:21:49] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/26/07 03:21:49] SNMP INFO SSH session logout

CPU5 [09/26/07 04:09:50] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 04:09:50] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 04:09:51] SSH INFO Accepted password for ROOT from 10.100.32.83 port 43294 ssh2

CPU5 [09/26/07 04:09:51] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.83

CPU5 [09/26/07 04:09:51] SNMP INFO SSH new session login

CPU5 [09/26/07 04:15:42] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/26/07 04:17:39] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 04:17:39] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 04:17:40] SSH INFO Accepted password for ROOT from 10.100.32.85 port 1467 ssh2

CPU5 [09/26/07 04:17:40] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.85

CPU5 [09/26/07 04:17:40] SNMP INFO SSH new session login

CPU5 [09/26/07 04:19:51] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/26/07 04:20:41] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 04:20:41] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 04:20:42] SSH INFO Accepted password for ROOT from 10.10.1.133 port 1722 ssh2

CPU5 [09/26/07 04:20:42] SSH INFO SSH: User testlab login /pty/sshd1. from 10.10.1.133

CPU5 [09/26/07 04:20:42] SNMP INFO SSH new session login

CPU5 [09/26/07 04:40:10] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/26/07 04:40:10] SNMP INFO SSH session logout

CPU5 [09/26/07 05:09:23] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 05:09:23] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 05:09:24] SSH INFO Accepted password for ROOT from 10.100.32.83 port 43869 ssh2

CPU5 [09/26/07 05:09:24] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.83

CPU5 [09/26/07 05:09:24] SNMP INFO SSH new session login

CPU5 [09/26/07 05:17:07] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 05:17:07] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 05:17:09] SSH INFO Accepted password for ROOT from 10.100.32.85 port 2540 ssh2

CPU5 [09/26/07 05:17:09] SSH INFO SSH: User testlab login /pty/sshd2. from 10.100.32.85

CPU5 [09/26/07 05:17:09] SNMP INFO SSH new session login

CPU5 [09/26/07 05:17:57] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/26/07 05:21:49] SSH INFO SSH: User /pty/sshd2. logout

CPU5 [09/26/07 05:21:49] SNMP INFO SSH session logout

CPU5 [09/26/07 06:09:25] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 06:09:25] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 06:09:26] SSH INFO Accepted password for ROOT from 10.100.32.83 port 44424 ssh2

CPU5 [09/26/07 06:09:26] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.83

CPU5 [09/26/07 06:09:26] SNMP INFO SSH new session login

CPU5 [09/26/07 06:12:59] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/26/07 06:17:19] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 06:17:19] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 06:17:20] SSH INFO Accepted password for ROOT from 10.100.32.85 port 3626 ssh2

CPU5 [09/26/07 06:17:20] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.85

CPU5 [09/26/07 06:17:20] SNMP INFO SSH new session login

CPU5 [09/26/07 06:21:38] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/26/07 06:21:38] SNMP INFO SSH session logout

CPU5 [09/26/07 07:09:43] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 07:09:43] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 07:09:44] SSH INFO Accepted password for ROOT from 10.100.32.83 port 44968 ssh2

CPU5 [09/26/07 07:09:44] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.83

CPU5 [09/26/07 07:09:44] SNMP INFO SSH new session login

CPU5 [09/26/07 07:13:01] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/26/07 07:13:01] SNMP INFO SSH session logout

CPU5 [09/26/07 07:18:30] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 07:18:30] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 07:18:30] SSH INFO Accepted password for ROOT from 10.100.32.85 port 4736 ssh2

CPU5 [09/26/07 07:18:30] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.85

CPU5 [09/26/07 07:18:30] SNMP INFO SSH new session login

CPU5 [09/26/07 07:22:22] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/26/07 08:09:38] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 08:09:38] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 08:09:38] SSH INFO Accepted password for ROOT from 10.100.32.83 port 45523 ssh2

CPU5 [09/26/07 08:09:39] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.83

CPU5 [09/26/07 08:09:39] SNMP INFO SSH new session login

CPU5 [09/26/07 08:13:07] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/26/07 08:17:34] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 08:17:34] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 08:17:34] SSH INFO Accepted password for ROOT from 10.100.32.85 port 1856 ssh2

CPU5 [09/26/07 08:17:34] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.85

CPU5 [09/26/07 08:17:34] SNMP INFO SSH new session login

CPU5 [09/26/07 08:24:01] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/26/07 09:09:32] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 09:09:32] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 09:09:33] SSH INFO Accepted password for ROOT from 10.100.32.83 port 46384 ssh2

CPU5 [09/26/07 09:09:33] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.83

CPU5 [09/26/07 09:09:33] SNMP INFO SSH new session login

CPU5 [09/26/07 09:16:58] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 09:16:58] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 09:16:58] SSH INFO Accepted password for ROOT from 10.100.32.85 port 2917 ssh2

CPU5 [09/26/07 09:16:58] SSH INFO SSH: User testlab login /pty/sshd2. from 10.100.32.85

CPU5 [09/26/07 09:16:58] SNMP INFO SSH new session login

CPU5 [09/26/07 09:23:52] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/26/07 09:24:28] SSH INFO SSH: User /pty/sshd2. logout

CPU5 [09/26/07 09:24:28] SNMP INFO SSH session logout

CPU5 [09/26/07 10:13:12] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 10:13:12] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 10:13:12] SSH INFO Accepted password for ROOT from 10.100.32.83 port 47369 ssh2

CPU5 [09/26/07 10:13:12] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.83

CPU5 [09/26/07 10:13:12] SNMP INFO SSH new session login

CPU5 [09/26/07 10:16:27] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/26/07 10:16:47] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 10:16:47] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 10:16:48] SSH INFO Accepted password for ROOT from 10.100.32.85 port 3859 ssh2

CPU5 [09/26/07 10:16:48] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.85

CPU5 [09/26/07 10:16:48] SNMP INFO SSH new session login

CPU5 [09/26/07 10:21:39] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/26/07 10:21:39] SNMP INFO SSH session logout

CPU5 [09/26/07 11:13:47] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 11:13:47] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 11:13:48] SSH INFO Accepted password for ROOT from 10.100.32.83 port 48334 ssh2

CPU5 [09/26/07 11:13:48] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.83

CPU5 [09/26/07 11:13:48] SNMP INFO SSH new session login

CPU5 [09/26/07 11:16:57] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 11:16:57] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 11:16:59] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/26/07 11:17:01] SSH INFO Accepted password for ROOT from 10.100.32.85 port 4816 ssh2

CPU5 [09/26/07 11:17:01] SSH INFO SSH: User testlab login /pty/sshd2. from 10.100.32.85

CPU5 [09/26/07 11:17:01] SNMP INFO SSH new session login

CPU5 [09/26/07 11:20:27] SSH INFO SSH: User /pty/sshd2. logout

CPU5 [09/26/07 11:38:59] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 11:38:59] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 11:38:59] SSH INFO Accepted password for ROOT from 10.10.1.89 port 4328 ssh2

CPU5 [09/26/07 11:38:59] SSH INFO SSH: User testlab login /pty/sshd1. from 10.10.1.89

CPU5 [09/26/07 11:38:59] SNMP INFO SSH new session login

CPU5 [09/26/07 11:42:31] SW INFO user testlab connected from 10.10.1.129 via telnet

CPU5 [09/26/07 11:42:32] SW INFO Closed telnet connection from IP 10.10.1.129, user testlab

CPU5 [09/26/07 11:42:59] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/26/07 11:42:59] SNMP INFO SSH session logout

CPU5 [09/26/07 12:12:58] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 12:12:58] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 12:12:58] SSH INFO Accepted password for ROOT from 10.100.32.83 port 48957 ssh2

CPU5 [09/26/07 12:12:59] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.83

CPU5 [09/26/07 12:12:59] SNMP INFO SSH new session login

CPU5 [09/26/07 12:14:49] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 12:14:49] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 12:14:50] SSH INFO Failed password for ROOT from 192.168.11.79 port 54197 ssh2

CPU5 [09/26/07 12:15:09] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/26/07 12:17:30] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 12:17:30] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 12:17:31] SSH INFO Accepted password for ROOT from 10.100.32.85 port 1855 ssh2

CPU5 [09/26/07 12:17:31] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.85

CPU5 [09/26/07 12:17:31] SNMP INFO SSH new session login

CPU5 [09/26/07 12:21:19] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/26/07 12:37:18] SW WARNING  Code=0x1ff0009Blocked unauthorized cli access

CPU5 [09/26/07 12:37:22] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/26/07 12:52:39] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/26/07 13:12:47] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 13:12:47] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 13:12:47] SSH INFO Accepted password for ROOT from 10.100.32.83 port 49605 ssh2

CPU5 [09/26/07 13:12:48] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.83

CPU5 [09/26/07 13:12:48] SNMP INFO SSH new session login

CPU5 [09/26/07 13:16:52] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 13:16:52] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 13:16:52] SSH INFO Accepted password for ROOT from 10.100.32.85 port 2826 ssh2

CPU5 [09/26/07 13:16:53] SSH INFO SSH: User testlab login /pty/sshd2. from 10.100.32.85

CPU5 [09/26/07 13:16:53] SNMP INFO SSH new session login

CPU5 [09/26/07 13:20:08] SSH INFO SSH: User /pty/sshd2. logout

CPU5 [09/26/07 13:20:59] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/26/07 13:20:59] SNMP INFO SSH session logout

CPU5 [09/26/07 13:23:47] SW WARNING  Code=0x1ff0009Blocked unauthorized cli access

CPU5 [09/26/07 13:23:52] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/26/07 13:33:45] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/26/07 13:33:49] SW INFO user testlab connected from 192.168.11.129 via telnet

[09/26/07 13:35:50] The previous message repeated 1 time(s).          

CPU5 [09/26/07 13:37:03] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/26/07 13:49:05] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/26/07 13:49:45] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

[09/26/07 13:50:35] The previous message repeated 1 time(s).          

CPU5 [09/26/07 13:58:33] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/26/07 13:59:56] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/26/07 14:03:31] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/26/07 14:07:32] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/26/07 14:13:15] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 14:13:15] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 14:13:16] SSH INFO Accepted password for ROOT from 10.100.32.83 port 50241 ssh2

CPU5 [09/26/07 14:13:16] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.83

CPU5 [09/26/07 14:13:16] SNMP INFO SSH new session login

CPU5 [09/26/07 14:17:06] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 14:17:06] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 14:17:08] SSH INFO Accepted password for ROOT from 10.100.32.85 port 3777 ssh2

CPU5 [09/26/07 14:17:08] SSH INFO SSH: User testlab login /pty/sshd2. from 10.100.32.85

CPU5 [09/26/07 14:17:08] SNMP INFO SSH new session login

CPU5 [09/26/07 14:18:17] SSH INFO SSH: User /pty/sshd2. logout

CPU5 [09/26/07 14:26:21] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/26/07 14:26:21] SNMP INFO SSH session logout

CPU5 [09/26/07 14:29:12] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/26/07 14:30:29] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/26/07 14:30:50] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/26/07 14:32:09] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/26/07 14:45:58] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/26/07 14:49:03] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/26/07 14:54:38] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/26/07 14:57:56] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/26/07 14:58:51] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/26/07 15:00:02] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/26/07 15:04:09] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/26/07 15:08:21] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/26/07 15:15:10] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/26/07 15:15:32] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 15:15:32] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 15:15:33] SSH INFO Accepted password for ROOT from 10.100.32.83 port 50756 ssh2

CPU5 [09/26/07 15:15:33] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.83

CPU5 [09/26/07 15:15:33] SNMP INFO SSH new session login

CPU5 [09/26/07 15:16:47] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 15:16:47] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 15:16:48] SSH INFO Accepted password for ROOT from 10.100.32.85 port 4821 ssh2

CPU5 [09/26/07 15:16:48] SSH INFO SSH: User testlab login /pty/sshd2. from 10.100.32.85

CPU5 [09/26/07 15:16:48] SNMP INFO SSH new session login

CPU5 [09/26/07 15:17:34] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/26/07 15:19:29] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/26/07 15:20:50] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/26/07 15:21:50] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/26/07 15:22:54] SSH INFO SSH: User /pty/sshd2. logout

CPU5 [09/26/07 15:26:01] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/26/07 15:50:05] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/26/07 16:03:44] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/26/07 16:15:11] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 16:15:11] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 16:15:12] SSH INFO Accepted password for ROOT from 10.100.32.83 port 51386 ssh2

CPU5 [09/26/07 16:15:12] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.83

CPU5 [09/26/07 16:15:12] SNMP INFO SSH new session login

CPU5 [09/26/07 16:18:10] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 16:18:10] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 16:18:11] SSH INFO Accepted password for ROOT from 10.100.32.85 port 1950 ssh2

CPU5 [09/26/07 16:18:11] SSH INFO SSH: User testlab login /pty/sshd2. from 10.100.32.85

CPU5 [09/26/07 16:18:11] SNMP INFO SSH new session login

CPU5 [09/26/07 16:19:20] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/26/07 16:21:03] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/26/07 16:21:03] SNMP INFO SSH session logout

CPU5 [09/26/07 16:23:38] SSH INFO SSH: User /pty/sshd2. logout

CPU5 [09/26/07 16:29:26] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/26/07 16:31:03] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/26/07 16:31:52] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/26/07 16:34:13] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/26/07 16:37:24] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/26/07 16:38:31] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/26/07 16:39:36] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/26/07 16:40:38] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/26/07 17:15:30] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 17:15:30] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 17:15:31] SSH INFO Accepted password for ROOT from 10.100.32.83 port 51958 ssh2

CPU5 [09/26/07 17:15:31] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.83

CPU5 [09/26/07 17:15:31] SNMP INFO SSH new session login

CPU5 [09/26/07 17:17:10] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 17:17:10] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 17:17:12] SSH INFO Accepted password for ROOT from 10.100.32.85 port 3001 ssh2

CPU5 [09/26/07 17:17:13] SSH INFO SSH: User testlab login /pty/sshd2. from 10.100.32.85

CPU5 [09/26/07 17:17:13] SNMP INFO SSH new session login

CPU5 [09/26/07 17:18:46] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/26/07 17:20:56] SSH INFO SSH: User /pty/sshd2. logout

CPU5 [09/26/07 18:05:55] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/26/07 18:06:43] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 18:06:43] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 18:06:43] SSH INFO Failed password for ROOT from 10.100.32.88 port 3847 ssh2

CPU5 [09/26/07 18:09:16] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/26/07 18:09:58] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/26/07 18:10:31] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/26/07 18:11:02] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/26/07 18:12:15] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/26/07 18:12:50] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/26/07 18:15:38] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 18:15:38] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 18:15:38] SSH INFO Accepted password for ROOT from 10.100.32.83 port 52552 ssh2

CPU5 [09/26/07 18:15:38] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.83

CPU5 [09/26/07 18:15:38] SNMP INFO SSH new session login

CPU5 [09/26/07 18:16:03] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/26/07 18:16:16] SW INFO user testlab connected from 192.168.11.129 via telnet

CPU5 [09/26/07 18:17:04] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 18:17:04] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 18:17:05] SSH INFO Accepted password for ROOT from 10.100.32.85 port 4040 ssh2

CPU5 [09/26/07 18:17:05] SSH INFO SSH: User testlab login /pty/sshd2. from 10.100.32.85

CPU5 [09/26/07 18:17:05] SNMP INFO SSH new session login

CPU5 [09/26/07 18:19:13] SW INFO Closed telnet connection from IP 192.168.11.129, user testlab

CPU5 [09/26/07 18:19:42] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/26/07 18:23:27] SSH INFO SSH: User /pty/sshd2. logout

CPU5 [09/26/07 18:54:06] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 18:54:06] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 18:54:07] SSH INFO Accepted password for ROOT from 10.10.1.184 port 3891 ssh2

CPU5 [09/26/07 18:54:07] SSH INFO SSH: User testlab login /pty/sshd1. from 10.10.1.184

CPU5 [09/26/07 18:54:07] SNMP INFO SSH new session login

CPU5 [09/26/07 18:59:14] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/26/07 18:59:14] SNMP INFO SSH session logout

CPU5 [09/26/07 19:01:13] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 19:01:13] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 19:01:13] SSH INFO Accepted password for ROOT from 10.100.7.210 port 2388 ssh2

CPU5 [09/26/07 19:01:13] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.7.210

CPU5 [09/26/07 19:01:13] SNMP INFO SSH new session login

CPU5 [09/26/07 19:02:17] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 19:02:17] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 19:02:20] SSH INFO Accepted password for ROOT from 10.100.7.200 port 1097 ssh2

CPU5 [09/26/07 19:02:20] SSH INFO SSH: User testlab login /pty/sshd2. from 10.100.7.200

CPU5 [09/26/07 19:02:20] SNMP INFO SSH new session login

CPU5 [09/26/07 19:05:18] SSH INFO SSH: User /pty/sshd2. logout

CPU5 [09/26/07 19:05:55] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/26/07 19:17:00] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 19:17:00] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 19:17:01] SSH INFO Accepted password for ROOT from 10.100.32.83 port 53118 ssh2

CPU5 [09/26/07 19:17:01] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.83

CPU5 [09/26/07 19:17:01] SNMP INFO SSH new session login

CPU5 [09/26/07 19:18:56] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 19:18:56] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 19:18:57] SSH INFO Accepted password for ROOT from 10.100.32.85 port 1210 ssh2

CPU5 [09/26/07 19:18:57] SSH INFO SSH: User testlab login /pty/sshd2. from 10.100.32.85

CPU5 [09/26/07 19:18:57] SNMP INFO SSH new session login

CPU5 [09/26/07 19:21:55] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/26/07 19:25:38] SSH INFO SSH: User /pty/sshd2. logout

CPU5 [09/26/07 19:25:38] SNMP INFO SSH session logout

CPU5 [09/26/07 20:11:44] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 20:11:44] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 20:11:46] SSH INFO Failed password for ROOT from 192.168.11.78 port 1734 ssh2

CPU5 [09/26/07 20:16:10] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 20:16:10] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 20:16:10] SSH INFO Accepted password for ROOT from 10.100.32.83 port 53683 ssh2

CPU5 [09/26/07 20:16:11] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.83

CPU5 [09/26/07 20:16:11] SNMP INFO SSH new session login

CPU5 [09/26/07 20:17:05] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 20:17:05] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 20:17:06] SSH INFO Accepted password for ROOT from 10.100.32.85 port 2224 ssh2

CPU5 [09/26/07 20:17:06] SSH INFO SSH: User testlab login /pty/sshd2. from 10.100.32.85

CPU5 [09/26/07 20:17:06] SNMP INFO SSH new session login

CPU5 [09/26/07 20:17:47] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 20:17:47] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 20:17:49] SSH INFO Failed password for ROOT from 192.168.11.79 port 56034 ssh2

CPU5 [09/26/07 20:19:24] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/26/07 20:20:25] SSH INFO SSH: User /pty/sshd2. logout

CPU5 [09/26/07 21:16:46] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 21:16:46] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 21:16:46] SSH INFO Accepted password for ROOT from 10.100.32.83 port 54254 ssh2

CPU5 [09/26/07 21:16:47] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.83

CPU5 [09/26/07 21:16:47] SNMP INFO SSH new session login

CPU5 [09/26/07 21:18:58] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 21:18:58] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 21:18:59] SSH INFO Accepted password for ROOT from 10.100.32.85 port 3301 ssh2

CPU5 [09/26/07 21:18:59] SSH INFO SSH: User testlab login /pty/sshd2. from 10.100.32.85

CPU5 [09/26/07 21:18:59] SNMP INFO SSH new session login

CPU5 [09/26/07 21:21:58] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/26/07 21:23:14] SSH INFO SSH: User /pty/sshd2. logout

CPU5 [09/26/07 22:16:02] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 22:16:02] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 22:16:02] SSH INFO Accepted password for ROOT from 10.100.32.83 port 54837 ssh2

CPU5 [09/26/07 22:16:02] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.83

CPU5 [09/26/07 22:16:02] SNMP INFO SSH new session login

CPU5 [09/26/07 22:17:14] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 22:17:14] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 22:17:15] SSH INFO Accepted password for ROOT from 10.100.32.85 port 4210 ssh2

CPU5 [09/26/07 22:17:15] SSH INFO SSH: User testlab login /pty/sshd2. from 10.100.32.85

CPU5 [09/26/07 22:17:15] SNMP INFO SSH new session login

CPU5 [09/26/07 22:19:19] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/26/07 22:19:53] SSH INFO SSH: User /pty/sshd2. logout

CPU5 [09/26/07 23:16:23] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 23:16:23] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 23:16:23] SSH INFO Accepted password for ROOT from 10.100.32.85 port 1533 ssh2

CPU5 [09/26/07 23:16:23] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.85

CPU5 [09/26/07 23:16:23] SNMP INFO SSH new session login

CPU5 [09/26/07 23:16:45] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 23:16:45] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/26/07 23:16:45] SSH INFO Accepted password for ROOT from 10.100.32.83 port 55416 ssh2

CPU5 [09/26/07 23:16:45] SSH INFO SSH: User testlab login /pty/sshd2. from 10.100.32.83

CPU5 [09/26/07 23:16:45] SNMP INFO SSH new session login

CPU5 [09/26/07 23:18:38] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/26/07 23:22:55] SSH INFO SSH: User /pty/sshd2. logout

CPU5 [09/27/07 00:07:06] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/27/07 00:07:06] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/27/07 00:07:06] SSH INFO Accepted password for ROOT from 10.10.1.112 port 22597 ssh2

CPU5 [09/27/07 00:07:07] SSH INFO SSH: User testlab login /pty/sshd1. from 10.10.1.112

CPU5 [09/27/07 00:07:07] SNMP INFO SSH new session login

CPU5 [09/27/07 00:11:09] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/27/07 00:11:09] SNMP INFO SSH session logout

CPU5 [09/27/07 00:17:48] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/27/07 00:17:48] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/27/07 00:17:48] SSH INFO Accepted password for ROOT from 10.100.32.85 port 2615 ssh2

CPU5 [09/27/07 00:17:52] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.85

CPU5 [09/27/07 00:17:52] SNMP INFO SSH new session login

CPU5 [09/27/07 00:22:05] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/27/07 00:22:05] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/27/07 00:22:06] SSH INFO Accepted password for ROOT from 10.100.32.83 port 56245 ssh2

CPU5 [09/27/07 00:22:06] SSH INFO SSH: User testlab login /pty/sshd2. from 10.100.32.83

CPU5 [09/27/07 00:22:06] SNMP INFO SSH new session login

CPU5 [09/27/07 00:23:55] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/27/07 00:29:48] SSH INFO SSH: User /pty/sshd2. logout

CPU5 [09/27/07 00:29:48] SNMP INFO SSH session logout

CPU5 [09/27/07 00:48:59] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/27/07 00:48:59] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/27/07 00:49:07] SSH INFO Accepted password for ROOT from 10.10.1.89 port 2920 ssh2

CPU5 [09/27/07 00:49:07] SSH INFO SSH: User testlab login /pty/sshd1. from 10.10.1.89

CPU5 [09/27/07 00:49:07] SNMP INFO SSH new session login

CPU5 [09/27/07 00:53:56] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/27/07 01:17:14] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/27/07 01:17:14] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/27/07 01:17:14] SSH INFO Accepted password for ROOT from 10.100.32.85 port 3697 ssh2

CPU5 [09/27/07 01:17:15] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.85

CPU5 [09/27/07 01:17:15] SNMP INFO SSH new session login

CPU5 [09/27/07 01:20:57] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/27/07 01:20:57] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/27/07 01:20:57] SSH INFO Accepted password for ROOT from 10.100.32.83 port 56836 ssh2

CPU5 [09/27/07 01:20:58] SSH INFO SSH: User testlab login /pty/sshd2. from 10.100.32.83

CPU5 [09/27/07 01:20:58] SNMP INFO SSH new session login

CPU5 [09/27/07 01:23:57] SSH INFO SSH: User /pty/sshd2. logout

CPU5 [09/27/07 01:26:23] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/27/07 01:26:23] SNMP INFO SSH session logout

CPU5 [09/27/07 02:17:20] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/27/07 02:17:20] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/27/07 02:17:21] SSH INFO Accepted password for ROOT from 10.100.32.85 port 4639 ssh2

CPU5 [09/27/07 02:17:21] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.85

CPU5 [09/27/07 02:17:21] SNMP INFO SSH new session login

CPU5 [09/27/07 02:21:29] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/27/07 02:21:29] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/27/07 02:21:30] SSH INFO Accepted password for ROOT from 10.100.32.83 port 57408 ssh2

CPU5 [09/27/07 02:21:31] SSH INFO SSH: User testlab login /pty/sshd2. from 10.100.32.83

CPU5 [09/27/07 02:21:31] SNMP INFO SSH new session login

CPU5 [09/27/07 02:23:23] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/27/07 02:23:25] SSH INFO SSH: User /pty/sshd2. logout

CPU5 [09/27/07 03:18:21] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/27/07 03:18:21] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/27/07 03:18:22] SSH INFO Accepted password for ROOT from 10.100.32.85 port 1803 ssh2

CPU5 [09/27/07 03:18:22] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.85

CPU5 [09/27/07 03:18:22] SNMP INFO SSH new session login

CPU5 [09/27/07 03:20:52] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/27/07 03:20:52] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/27/07 03:20:53] SSH INFO Accepted password for ROOT from 10.100.32.83 port 57960 ssh2

CPU5 [09/27/07 03:20:53] SSH INFO SSH: User testlab login /pty/sshd2. from 10.100.32.83

CPU5 [09/27/07 03:20:53] SNMP INFO SSH new session login

CPU5 [09/27/07 03:22:30] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/27/07 03:27:16] SSH INFO SSH: User /pty/sshd2. logout

CPU5 [09/27/07 03:27:16] SNMP INFO SSH session logout

CPU5 [09/27/07 04:17:49] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/27/07 04:17:49] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/27/07 04:17:50] SSH INFO Accepted password for ROOT from 10.100.32.85 port 3023 ssh2

CPU5 [09/27/07 04:17:51] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.85

CPU5 [09/27/07 04:17:51] SNMP INFO SSH new session login

CPU5 [09/27/07 04:20:50] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/27/07 04:20:50] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/27/07 04:20:51] SSH INFO Accepted password for ROOT from 10.100.32.83 port 58526 ssh2

CPU5 [09/27/07 04:20:51] SSH INFO SSH: User testlab login /pty/sshd2. from 10.100.32.83

CPU5 [09/27/07 04:20:51] SNMP INFO SSH new session login

CPU5 [09/27/07 04:24:05] SSH INFO SSH: User /pty/sshd2. logout

CPU5 [09/27/07 04:24:47] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/27/07 04:24:47] SNMP INFO SSH session logout

CPU5 [09/27/07 05:17:16] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/27/07 05:17:16] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/27/07 05:17:16] SSH INFO Accepted password for ROOT from 10.100.32.85 port 3956 ssh2

CPU5 [09/27/07 05:17:17] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.85

CPU5 [09/27/07 05:17:17] SNMP INFO SSH new session login

CPU5 [09/27/07 05:20:46] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/27/07 05:20:46] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/27/07 05:20:46] SSH INFO Accepted password for ROOT from 10.100.32.83 port 59068 ssh2

CPU5 [09/27/07 05:20:46] SSH INFO SSH: User testlab login /pty/sshd2. from 10.100.32.83

CPU5 [09/27/07 05:20:46] SNMP INFO SSH new session login

CPU5 [09/27/07 05:23:14] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/27/07 05:23:59] SSH INFO SSH: User /pty/sshd2. logout

CPU5 [09/27/07 06:19:30] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/27/07 06:19:30] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/27/07 06:19:31] SSH INFO Accepted password for ROOT from 10.100.32.85 port 1224 ssh2

CPU5 [09/27/07 06:19:31] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.85

CPU5 [09/27/07 06:19:31] SNMP INFO SSH new session login

CPU5 [09/27/07 06:20:49] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/27/07 06:20:49] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/27/07 06:20:50] SSH INFO Accepted password for ROOT from 10.100.32.83 port 59579 ssh2

CPU5 [09/27/07 06:20:50] SSH INFO SSH: User testlab login /pty/sshd2. from 10.100.32.83

CPU5 [09/27/07 06:20:50] SNMP INFO SSH new session login

CPU5 [09/27/07 06:23:05] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/27/07 06:24:12] SSH INFO SSH: User /pty/sshd2. logout

CPU5 [09/27/07 07:17:37] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/27/07 07:17:37] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/27/07 07:17:38] SSH INFO Accepted password for ROOT from 10.100.32.85 port 2131 ssh2

CPU5 [09/27/07 07:17:38] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.85

CPU5 [09/27/07 07:17:38] SNMP INFO SSH new session login

CPU5 [09/27/07 07:21:07] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/27/07 07:21:07] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/27/07 07:21:07] SSH INFO Accepted password for ROOT from 10.100.32.83 port 60137 ssh2

CPU5 [09/27/07 07:21:08] SSH INFO SSH: User testlab login /pty/sshd2. from 10.100.32.83

CPU5 [09/27/07 07:21:08] SNMP INFO SSH new session login

CPU5 [09/27/07 07:23:40] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/27/07 07:24:26] SSH INFO SSH: User /pty/sshd2. logout

CPU5 [09/27/07 08:23:22] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/27/07 08:23:22] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/27/07 08:23:23] SSH INFO Accepted password for ROOT from 10.100.32.85 port 3345 ssh2

CPU5 [09/27/07 08:23:23] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.85

CPU5 [09/27/07 08:23:23] SNMP INFO SSH new session login

CPU5 [09/27/07 08:24:46] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/27/07 08:24:46] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/27/07 08:24:47] SSH INFO Accepted password for ROOT from 10.100.32.83 port 60818 ssh2

CPU5 [09/27/07 08:24:47] SSH INFO SSH: User testlab login /pty/sshd2. from 10.100.32.83

CPU5 [09/27/07 08:24:47] SNMP INFO SSH new session login

CPU5 [09/27/07 08:28:32] SSH INFO SSH: User /pty/sshd2. logout

CPU5 [09/27/07 08:30:24] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/27/07 08:30:24] SNMP INFO SSH session logout

CPU5 [09/27/07 09:18:30] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/27/07 09:18:30] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/27/07 09:18:31] SSH INFO Accepted password for ROOT from 10.100.32.85 port 4289 ssh2

CPU5 [09/27/07 09:18:31] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.85

CPU5 [09/27/07 09:18:31] SNMP INFO SSH new session login

CPU5 [09/27/07 09:24:04] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/27/07 09:24:04] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/27/07 09:24:04] SSH INFO Accepted password for ROOT from 10.100.32.83 port 33140 ssh2

CPU5 [09/27/07 09:24:05] SSH INFO SSH: User testlab login /pty/sshd2. from 10.100.32.83

CPU5 [09/27/07 09:24:05] SNMP INFO SSH new session login

CPU5 [09/27/07 09:25:18] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/27/07 09:25:18] SNMP INFO SSH session logout

CPU5 [09/27/07 09:28:26] SSH INFO SSH: User /pty/sshd2. logout

CPU5 [09/27/07 09:28:26] SNMP INFO SSH session logout

CPU5 [09/27/07 10:20:52] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/27/07 10:20:52] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/27/07 10:20:53] SSH INFO Accepted password for ROOT from 10.100.32.85 port 1587 ssh2

CPU5 [09/27/07 10:20:53] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.85

CPU5 [09/27/07 10:20:53] SNMP INFO SSH new session login

CPU5 [09/27/07 10:23:48] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/27/07 10:23:48] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/27/07 10:23:49] SSH INFO Accepted password for ROOT from 10.100.32.83 port 33728 ssh2

CPU5 [09/27/07 10:23:49] SSH INFO SSH: User testlab login /pty/sshd2. from 10.100.32.83

CPU5 [09/27/07 10:23:49] SNMP INFO SSH new session login

CPU5 [09/27/07 10:24:48] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/27/07 10:27:20] SSH INFO SSH: User /pty/sshd2. logout

CPU5 [09/27/07 11:19:16] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/27/07 11:19:16] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/27/07 11:19:18] SSH INFO Accepted password for ROOT from 10.100.32.85 port 2646 ssh2

CPU5 [09/27/07 11:19:19] SSH INFO SSH: User testlab login /pty/sshd1. from 10.100.32.85

CPU5 [09/27/07 11:19:19] SNMP INFO SSH new session login

CPU5 [09/27/07 11:24:23] SSH INFO kex:chosen algorithms for client->server: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/27/07 11:24:23] SSH INFO kex:chosen algorithms for server->client: encryption:3des-cbc mac:hmac-md5 compression:none

CPU5 [09/27/07 11:24:24] SSH INFO Accepted password for ROOT from 10.100.32.83 port 34282 ssh2

CPU5 [09/27/07 11:24:24] SSH INFO SSH: User testlab login /pty/sshd2. from 10.100.32.83

CPU5 [09/27/07 11:24:24] SNMP INFO SSH new session login

CPU5 [09/27/07 11:25:36] SSH INFO SSH: User /pty/sshd1. logout

CPU5 [09/27/07 11:25:36] SNMP INFO SSH session logout

CPU5 [09/27/07 11:27:33] SSH INFO SSH: User /pty/sshd2. logout

CPU5 [09/27/07 11:59:45] SW INFO user testlab connected from 192.168.11.129 via telnet

Passport-8606:5# 

END

$responsesNortelPassport->{users} = <<'END';
show cli password

	aging     90

	ACCESS    LOGIN

	rwa       testlab         

	rw        rw              

	l3        l3              

	l2        l2              

	l1        l1              

	ro        ro              

	l4admin   l4admin         

	slbadmin  slbadmin        

	oper      oper            

	l4oper    l4oper          

	slboper   slboper         

	ssladmin  ssladmin        

Passport-8606:5# 

END

