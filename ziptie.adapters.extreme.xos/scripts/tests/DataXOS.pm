package DataXOS;

use strict;
use warnings;
use Exporter 'import';
our @EXPORT_OK = qw($responsesXOS);

our $responsesXOS = {};

$responsesXOS->{switch} = <<'END';
show switch


SysName:          SummitX450-24t
SysLocation:      
SysContact:       support@extremenetworks.com, +1 888 257 3000
System MAC:       00:04:96:20:AC:D4
Recovery Mode:    All
System Watchdog:  Enabled

Current Time:     Sat Jan 19 07:11:45 2008
Timezone:         [Auto DST Disabled] GMT Offset: 0 minutes, name is UTC.
Boot Time:        Tue Jan 15 00:28:38 2008
Next Reboot:      None scheduled


Current State:    OPERATIONAL             
Image Selected:   primary                 
Image Booted:     primary                 
Primary ver:      11.2.3.3                
Secondary ver:    11.2.2.4                

Config Selected:  primary.cfg                                          
Config Booted:    primary.cfg                                          

primary.cfg       Created by ExtremeWare XOS version 11.2.3.3
                  87734 bytes saved on Tue Jan 15 00:52:35 2008
SummitX450-24t.3 # 

END

$responsesXOS->{version} = <<'END';
show version

Switch    : 800143-00-04 0532G-00169 Rev 4.0 BootROM: 1.0.0.9    IMG:           
XGM-2xn-1 :

Image   : ExtremeWare XOS version 11.2.3.3 v1123b3 by release-manager
          on Tue Aug 23 16:49:46 PDT 2005
BootROM : 1.0.0.9
SummitX450-24t.4 # 

END

$responsesXOS->{configuration} = <<'END';
show configuration

#
# Module devmgr configuration.
#
configure snmp sysName "SummitX450-24t"
configure snmp sysContact "support@extremenetworks.com, +1 888 257 3000"
configure slot 1 module SummitX450-24t

#
# Module vlan configuration.
#
create virtual-router "VR-Default"
configure vr VR-Default add ports 1-26
create vlan "Default"
configure vlan Default tag 1
configure vlan Default add ports 2-26 untagged  
configure vlan Default ipaddress 10.100.26.5 255.255.255.0

#
# Module fdb configuration.
#
configure fdb agingtime 300
configure iparp vr VR-Control max_entries 4096
configure iparp vr VR-Control max_pending_entries 256
configure iparp vr VR-Control max_proxy_entries 256
configure iparp vr VR-Control timeout 20
enable iparp vr VR-Control checking
enable iparp vr VR-Control refresh
configure iparp vr VR-Default max_entries 4096
configure iparp vr VR-Default max_pending_entries 256
configure iparp vr VR-Default max_proxy_entries 256
configure iparp vr VR-Default timeout 20
enable iparp vr VR-Default checking
enable iparp vr VR-Default refresh
configure iparp vr VR-Mgmt max_entries 4096
configure iparp vr VR-Mgmt max_pending_entries 256
configure iparp vr VR-Mgmt max_proxy_entries 256
configure iparp vr VR-Mgmt timeout 20
enable iparp vr VR-Mgmt checking
enable iparp vr VR-Mgmt refresh

#
# Module rtmgr configuration.
#
disable iproute sharing 
configure iproute priority blackhole 50 
configure iproute priority static 1100 
configure iproute priority icmp 1200 
configure iproute priority ebgp 1700 
configure iproute priority ibgp 1900 
configure iproute priority ospf-intra 2200 
configure iproute priority ospf-inter 2300 
configure iproute priority rip 2400 
configure iproute priority ospf-as-external 3100 
configure iproute priority ospf-extern1 3200 
configure iproute priority ospf-extern2 3300 
configure iproute priority bootp 5000 
configure iproute ipv6 priority blackhole 50 
configure iproute ipv6 priority static 1100 
configure iproute ipv6 priority icmp 1200 
configure iproute ipv6 priority ospfv3-intra 2200 
configure iproute ipv6 priority ospfv3-inter 2300 
configure iproute ipv6 priority RIPng 2400 
configure iproute ipv6 priority ospfv3-as-external 3100 
configure iproute ipv6 priority ospfv3-extern1 3200 
configure iproute ipv6 priority ospfv3-extern2 3300 
configure irdp broadcast 
configure irdp 450 600 1800 0 
disable irdp "Default"
disable icmp address-mask vlan "Default"
enable icmp parameter-problem vlan "Default"
enable icmp port-unreachables vlan "Default"
enable icmp unreachables vlan "Default"
enable icmp redirects vlan "Default"
enable icmp time-exceeded vlan "Default"
disable icmp timestamp vlan "Default"
enable ip-option loose-source-route 
enable ip-option strict-source-route 
enable ip-option record-timestamp 
enable ip-option router-alert 
enable ip-option record-route 
configure iproute add default 10.100.26.2 1 vr VR-Default 
configure iproute add default 192.168.5.1 1 vr VR-Default 
disable ipforwarding broadcast vlan "Default"
disable icmp useredirects

#
# Module mcmgr configuration.
#
configure igmp snooping cache 32 64 
configure igmp snooping timer 260 260 vr VR-Default
configure igmp snooping leave-timeout 1000 vr VR-Default
configure MLD snooping timer 260 260 vr VR-Default
configure MLD snooping leave-timeout 1000 vr VR-Default
disable igmp snooping forward-mcrouter-only vr VR-Default
disable MLD snooping forward-mcrouter-only vr VR-Default
configure igmp 125 10 1 2 vr VR-Default
configure MLD 125 10 1 2 vr VR-Default 
enable igmp snooping with-proxy vr VR-Default
enable MLD snooping with-proxy vr VR-Default
configure igmp snooping flood-list none vr VR-Default
configure MLD snooping flood-list none vr VR-Default

#
# Module aaa configuration.
#
disable radius mgmt-access
configure radius mgmt-access timeout 3
disable radius-accounting mgmt-access
configure radius-accounting mgmt-access timeout 3
disable radius netlogin
configure radius netlogin timeout 3
disable radius-accounting netlogin
configure radius-accounting netlogin timeout 3
disable tacacs
configure tacacs timeout 3
disable tacacs-accounting
configure tacacs-accounting timeout 3
disable tacacs-authorization
create account admin admin encrypted kHIZXS$n7uUIQpbpirSqLFcCIxhV/ 
create account user user encrypted o4H3WS$LGpsiUiHdZRDl15sDE7vf. 
create account admin testlab encrypted uZSl9I$vR7ekrMugwuY8doNHjUWG1 

#
# Module acl configuration.
#
enable access-list refresh blackhole 

#
# Module cfgmgr configuration.
#
disable cli-config-logging
configure cli max-sessions 8
configure cli max-failed-logins 3
configure idletimeout 20
enable idletimeout

#
# Module dosprotect configuration.
#
disable dos-protect
configure dos-protect interval 1
configure dos-protect trusted-ports ports 
configure dos-protect type l3-protect alert-threshold 4000
configure dos-protect type l3-protect notify-threshold 3500

#
# Module eaps configuration.
#
configure eaps fast-convergence off
disable eaps

#
# Module edp configuration.
#
configure edp advertisement-interval 60 holddown-interval 180
enable edp ports 1
enable edp ports 2
enable edp ports 3
enable edp ports 4
enable edp ports 5
enable edp ports 6
enable edp ports 7
enable edp ports 8
enable edp ports 9
enable edp ports 10
enable edp ports 11
enable edp ports 12
enable edp ports 13
enable edp ports 14
enable edp ports 15
enable edp ports 16
enable edp ports 17
enable edp ports 18
enable edp ports 19
enable edp ports 20
enable edp ports 21
enable edp ports 22
enable edp ports 23
enable edp ports 24
enable edp ports 25
enable edp ports 26

#
# Module elrp configuration.
#
disable elrp-client

#
# Module ems configuration.
#
disable log debug-mode
create log filter DefaultFilter
configure log filter DefaultFilter add event All 
enable log target memory-buffer
configure log target memory-buffer filter DefaultFilter severity Debug-Data
configure log target memory-buffer match Any
configure log target memory-buffer format timestamp hundredths date mm-dd-yyyy event-name condition process-slot severity 
configure log target memory-buffer number-of-messages 1000
enable log target nvram
configure log target nvram filter DefaultFilter severity Warning
configure log target nvram match Any
configure log target nvram format timestamp hundredths date mm-dd-yyyy event-name condition process-slot severity 
disable log target console
configure log target console filter DefaultFilter severity Info
configure log target console match Any
configure log target console format timestamp hundredths date mm-dd-yyyy event-name condition process-slot severity 

#
# Module epm configuration.
#
configure sys-recovery-level All
enable watchdog
configure firmware install-on-demand
enable cpu-monitoring interval 20 threshold 60

#
# Module esrp configuration.
#
configure esrp mode extended

#
# Module etmon configuration.
#
configure sflow sample-rate 8192
configure sflow max-cpu-sample-limit 2000
configure sflow poll-interval 20
disable sflow
disable rmon

#
# Module lldp configuration.
#
configure lldp transmit-interval 30
configure lldp transmit-hold 4
configure lldp reinitialize-delay 2
configure lldp transmit-delay 2
configure lldp snmp-notification-delay 5

#
# Module netLogin configuration.
#
configure netlogin dot1x timers server-timeout 30 quiet-period 60 reauth-period 3600 supp-resp-timeout 30
configure netlogin dot1x eapol-transmit-version v1
enable netlogin logout-privilege
enable netlogin session-refresh 3
configure netlogin base-url "network-access.com"
configure netlogin redirect-page "http://www.extremenetworks.com"
configure netlogin banner ""

#
# Module netTools configuration.
#
configure sntp-client update-interval 64 
disable sntp-client

#
# Module ospf configuration.
#
configure ospf routerid automatic
configure ospf spf-hold-time 3
configure ospf metric-table 10M 10 100M 5 1G 4 10G 2
configure ospf lsa-batch-interval 30
configure ospf import-policy none
configure ospf ase-limit 0 
disable ospf originate-default
disable ospf use-ip-router-alert
disable ospf
disable ospf export direct
disable ospf export static
disable ospf export rip
disable ospf export e-bgp
disable ospf export i-bgp
configure ospf area 0.0.0.0 external-filter none
configure ospf area 0.0.0.0 interarea-filter none
configure ospf area 0.0.0.0 normal
configure ospf vlan Default area 0.0.0.0
configure ospf vlan Default cost automatic
configure ospf vlan Default priority 0
configure ospf vlan Default authentication none
configure ospf vlan Default timer 5 1 10 40 

#
# Module pim configuration.
#
disable pim
configure pim crp timer 60
configure pim register-suppress-interval 60 register-probe-interval 5
configure pim register-checksum-to include-data

#
# Module poe configuration.
#
disable inline-power
configure inline-power usage-threshold 70
configure inline-power disconnect-precedence deny-port

#
# Module rip configuration.
#
configure rip garbagetime 120
configure rip import-policy none
configure rip routetimeout 180
configure rip updatetime 30
disable rip originate-default
enable rip use-ip-router-alert
disable rip aggregation
enable rip poisonreverse
enable rip splithorizon
enable rip triggerupdates
disable rip
disable rip export direct 
disable rip export static 
disable rip export ospf-intra 
disable rip export ospf-inter 
disable rip export ospf-extern1 
disable rip export ospf-extern2 
disable rip export e-bgp 
disable rip export i-bgp 

#
# Module ripng configuration.
#
disable ripng 
configure ripng garbagetime 120
configure ripng updatetime 30
configure ripng routetimeout 180 

#
# Module snmpMaster configuration.
#
configure snmpv3 engine-id 03:00:04:96:20:ac:d4
configure snmpv3 add user admin authentication md5 hex f4:f5:09:ec:4a:d6:69:23:0c:40:9d:cc:2b:e2:ec:64 privacy hex f4:f5:09:ec:4a:d6:69:23:0c:40:9d:cc:2b:e2:ec:64 
configure snmpv3 add user initial 
configure snmpv3 add user initialmd5 authentication md5 hex e5:de:25:c4:79:5f:c4:97:92:df:ef:18:f0:f5:16:8d 
configure snmpv3 add user initialsha authentication sha hex 67:fb:c3:b0:42:00:52:10:96:3b:b1:e1:22:c0:09:83:58:93:ea:13 
configure snmpv3 add user initialmd5Priv authentication md5 hex 95:f3:ea:88:93:ea:0c:8c:a4:73:b0:fe:31:23:fd:d5 privacy hex 95:f3:ea:88:93:ea:0c:8c:a4:73:b0:fe:31:23:fd:d5 
configure snmpv3 add user initialshaPriv authentication sha hex 0f:45:75:72:2d:e2:29:54:84:96:a5:ea:cf:62:7b:35:24:7b:6e:40 privacy hex 0f:45:75:72:2d:e2:29:54:84:96:a5:ea:cf:62:7b:35:24:7b:6e:40 
configure snmpv3 add group v1v2c_ro user v1v2c_ro sec-model snmpv1 
configure snmpv3 add group v1v2c_rw user v1v2c_rw sec-model snmpv1 
configure snmpv3 add group v1v2c_ro user v1v2c_ro sec-model snmpv2c 
configure snmpv3 add group v1v2c_rw user v1v2c_rw sec-model snmpv2c 
configure snmpv3 add group admin user admin sec-model usm 
configure snmpv3 add group initial user initial sec-model usm 
configure snmpv3 add group initial user initialmd5 sec-model usm 
configure snmpv3 add group initial user initialsha sec-model usm 
configure snmpv3 add group initial user initialmd5Priv sec-model usm 
configure snmpv3 add group initial user initialshaPriv sec-model usm 
configure snmpv3 add access admin sec-model usm sec-level authpriv read-view defaultAdminView write-view defaultAdminView notify-view defaultNotifyView 
configure snmpv3 add access initial sec-model usm sec-level noauth read-view defaultUserView notify-view defaultNotifyView 
configure snmpv3 add access initial sec-model usm sec-level authnopriv read-view defaultUserView write-view defaultUserView notify-view defaultNotifyView 
configure snmpv3 add access v1v2c_ro sec-model snmpv1 sec-level noauth read-view defaultUserView notify-view defaultNotifyView 
configure snmpv3 add access v1v2c_ro sec-model snmpv2c sec-level noauth read-view defaultUserView notify-view defaultNotifyView 
configure snmpv3 add access v1v2c_rw sec-model snmpv1 sec-level noauth read-view defaultUserView write-view defaultUserView notify-view defaultNotifyView 
configure snmpv3 add access v1v2c_rw sec-model snmpv2c sec-level noauth read-view defaultUserView write-view defaultUserView notify-view defaultNotifyView 
configure snmpv3 add access v1v2cNotifyGroup sec-model snmpv1 sec-level noauth notify-view defaultNotifyView 
configure snmpv3 add access v1v2cNotifyGroup sec-model snmpv2c sec-level noauth notify-view defaultNotifyView 
configure snmpv3 add mib-view defaultUserView subtree 1 type included 
configure snmpv3 add mib-view defaultUserView subtree 1.3.6.1.6.3.16 type excluded 
configure snmpv3 add mib-view defaultUserView subtree 1.3.6.1.6.3.18 type excluded 
configure snmpv3 add mib-view defaultUserView subtree 1.3.6.1.6.3.15.1.2.2.1.4 type excluded 
configure snmpv3 add mib-view defaultUserView subtree 1.3.6.1.6.3.15.1.2.2.1.6 type excluded 
configure snmpv3 add mib-view defaultUserView subtree 1.3.6.1.6.3.15.1.2.2.1.9 type excluded 
configure snmpv3 add mib-view defaultAdminView subtree 1 type included 
configure snmpv3 add mib-view defaultNotifyView subtree 1 type included 
configure snmpv3 add community private name private user v1v2c_rw 
configure snmpv3 add community pu name pu user v1v2c_ro 
configure snmpv3 add community public name public user v1v2c_ro 
configure snmpv3 add community testenv name testenv user v1v2c_rw 
configure snmpv3 add notify defaultNotify tag defaultNotify 
enable snmp access
enable snmp traps

#
# Module stp configuration.
#
create stpd s0
configure stpd s0 tag 0
configure stpd s0 mode dot1d
configure stpd s0 forwarddelay 15
configure stpd s0 hellotime 2
configure stpd s0 maxage 20
configure stpd s0 priority 32768
disable stpd s0 rapid-root-failover
configure stpd s0 default-encapsulation dot1d
enable stpd s0 auto-bind vlan Default
disable stpd s0

#
# Module telnetd configuration.
#
configure telnet vr all

#
# Module tftpd configuration.
#

#
# Module thttpd configuration.
#
hidden configure thttp vr all

#
# Module vrrp configuration.
#

SummitX450-24t.5 # 

END

$responsesXOS->{memory} = <<'END';
show memory


System Memory Information
-------------------------
 Total DRAM (KB): 262144
 System     (KB): 25852
 User       (KB): 97696
 Free       (KB): 138596

Memory Utilization Statistics
-----------------------------

 Process Name     Memory (KB)
-----------------------------
 aaa              13500           
 acl              11420           
 bgp              0               
 cfgmgr           8320            
 cli              41252           
 devmgr           8452            
 dirser           7076            
 dosprotect       8256            
 eaps             18788           
 edp              9768            
 elrp             10032           
 ems              10724           
 epm              15304           
 esrp             16728           
 etmon            18920           
 exacl            30              
 exdos            9               
 exfib            3               
 exosmc           30              
 exosnvram        4               
 exosq            35              
 exsflow          10              
 exsnoop          23              
 exvlan           291             
 fdb              12912           
 hal              64924           
 lldp             8820            
 mcmgr            17856           
 msgsrv           6952            
 netLogin         8936            
 netTools         11568           
 nettx            71              
 nodemgr          9632            
 ospf             18124           
 ospfv3           0               
 pim              15996           
 poe              8936            
 polMgr           7576            
 rip              17736           
 ripng            15168           
 rtmgr            16020           
 snmpMaster       21600           
 snmpSubagent     26448           
 stp              10764           
 telnetd          8476            
 tftpd            7576            
 thttpd           9408            
 vlan             9656            
 vrrp             11184           
 xmld             9148            
SummitX450-24t.6 # 

END

$responsesXOS->{power} = <<'END';
show power


PowerSupply 1 information:
 State:          Powered On
 PartInfo:       Internal Power Supply  


PowerSupply 2 information:
 State:          Empty
SummitX450-24t.7 # 

END

$responsesXOS->{platform} = <<'END';
show platform version

Slot  1 Version Information:

Linux version:			2.4.18_EXOS_cougar_IPv6_1.0.0.

EXOS link date:			Tue Aug 23 16:51:55 PDT 2005

EXOS built by:			release-manager

EXOS branch:			v1123b3

EXOS version:			11.2.3.3

Card type:			S450-24T rev 0**  (0)

MAC-0:				GE-MAC rev 1.3 (LED rev 2.0) 

MAC-1:				GE-MAC rev 1.3 (LED rev 2.0) 

SFC-2:				SFC rev UNKNOWN(2)

CPU Core:			SiByte SB1 V0.3  FPU V0.3
CPU Speed:			600 MHz

CPU Bus Speed:			100 MHz

CPU Memory Size:		256 MB

Alternate Bootrom Version:	unknown**  (1.0.0.24)

Default Bootrom Version:	unknown**  (1.0.0.24)

Active Bootrom:			unknown

Dillinger Version:		1279**  (6)



  
SummitX450-24t.8 # 

END

$responsesXOS->{interfaces} = <<'END';
show ports configuration

Port Configuration
Port     Virtual    Port  Link  Auto   Speed      Duplex   Flow  Load   Media
         router     State State Neg  Cfg Actual Cfg Actual Cntrl Master Primary
================================================================================
1        VR-Default   E     R    ON  AUTO       AUTO                    MGBIC  UTP
2        VR-Default   E     R    ON  AUTO       AUTO                    MGBIC  UTP
3        VR-Default   E     A    ON  AUTO   100 AUTO FULL    NONE         UTPMGBIC
4        VR-Default   E     R    ON  AUTO       AUTO                    MGBIC  UTP
5        VR-Default   E     R    ON  AUTO       AUTO                      UTP
6        VR-Default   E     R    ON  AUTO       AUTO                      UTP
7        VR-Default   E     R    ON  AUTO       AUTO                      UTP
8        VR-Default   E     R    ON  AUTO       AUTO                      UTP
9        VR-Default   E     R    ON  AUTO       AUTO                      UTP
10       VR-Default   E     R    ON  AUTO       AUTO                      UTP
11       VR-Default   E     R    ON  AUTO       AUTO                      UTP
12       VR-Default   E     R    ON  AUTO       AUTO                      UTP
13       VR-Default   E     R    ON  AUTO       AUTO                      UTP
14       VR-Default   E     R    ON  AUTO       AUTO                      UTP
15       VR-Default   E     R    ON  AUTO       AUTO                      UTP
16       VR-Default   E     R    ON  AUTO       AUTO                      UTP
17       VR-Default   E     R    ON  AUTO       AUTO                      UTP
18       VR-Default   E     R    ON  AUTO       AUTO                      UTP
19       VR-Default   E     R    ON  AUTO       AUTO                      UTP
20       VR-Default   E     R    ON  AUTO       AUTO                      UTP
21       VR-Default   E     R    ON  AUTO       AUTO                      UTP
22       VR-Default   E     R    ON  AUTO       AUTO                      UTP
23       VR-Default   E     R    ON  AUTO       AUTO                      UTP
24       VR-Default   E     R    ON  AUTO       AUTO                      UTP
25       VR-Default   E     R    ON  AUTO       AUTO                     NONE
26       VR-Default   E     R    ON  AUTO       AUTO                     NONE
================================================================================
                 Link Status: A-Active, R-Ready, NP-Port not present 
                 Port State:  D-Disabled, E-Enabled 
                 Media:  !- Unsupported XENPAK
SummitX450-24t.9 # 

END

$responsesXOS->{'vlan_Default'} = <<'END';
show Default

VLAN Interface with name Default created by user
	Tagging:	802.1Q Tag 1 
	Priority:	802.1P Priority 0
	Virtual router:	VR-Default
	Primary IP    : 10.100.26.5/24
	IPv6: 	NONE
	STPD: 		s0(Disabled,Auto-bind) 
	Protocol: 	Match all unfiltered protocols
	Loopback: 	Disable
	NetLogin: 	Disabled
	Rate Shape: 	Disable
	QosProfile: 	None configured
	Ports:	 25. 	  (Number of active ports=1)
           Untag:       2,     *3,      4,      5,      6,      7,      8,
                        9,     10,     11,     12,     13,     14,     15,
                       16,     17,     18,     19,     20,     21,     22,
                       23,     24,     25,     26
	Flags:    (*) Active, (!) Disabled, (g) Load Sharing port
                  (b) Port blocked on the vlan, (a) Authenticated NetLogin port
                  (u) Unauthenticated NetLogin port
SummitX450-24t.11 # 

END

$responsesXOS->{'vlan_Mgmt'} = <<'END';
show Mgmt

VLAN Interface with name Mgmt created by user
	Tagging:	802.1Q Tag 4095 
	Priority:	802.1P Priority 0
	Virtual router:	VR-Mgmt
	IPv6: 	NONE
	STPD: 		None
	Protocol: 	Match all unfiltered protocols
	Loopback: 	Disable
	NetLogin: 	Disabled
	Rate Shape: 	Disable
	QosProfile: 	None configured
	Ports:	 1. 	  (Number of active ports=0)
	 Untag: Mgmt-port on Mgmt is down

SummitX450-24t.12 # 

END

$responsesXOS->{'stp_s0'} = <<'END';
show s0

Stpd: s0		Stp: DISABLED		Number of Ports: 25
Rapid Root Failover: Disabled
Operational Mode: 802.1D			Default Binding Mode: 802.1D
802.1Q Tag: (none)
Ports: 2,3,4,5,6,7,8,9,10,11,
       12,13,14,15,16,17,18,19,20,21,
       22,23,24,25,26
Participating Vlans: Default
Auto-bind Vlans: Default
Bridge Priority: 32768
BridgeID:		80:00:00:04:96:20:ac:d4
Designated root:	00:00:00:00:00:00:00:00
RootPathCost: 0 	Root Port: ----
MaxAge: 0s		HelloTime: 0s		ForwardDelay: 0s
CfgBrMaxAge: 20s 	CfgBrHelloTime: 2s	CfgBrForwardDelay: 15s
Topology Change Time: 35s			Hold time: 1s
Topology Change Detected: FALSE			Topology Change: FALSE
Number of Topology Changes: 0
Time Since Last Topology Change: 0s
SummitX450-24t.14 # 

END

$responsesXOS->{route} = <<'END';
show iproute

Ori Destination        Gateway         Mtr  Flags       VLAN       Duration
#s  Default Route      10.100.26.2     1    UG---S-um-- Default    4d:6h:42m:28s
s   Default Route      192.168.5.1     1    -G---S-um-- -          4d:6h:42m:28s
#d  10.100.26.0/24     10.100.26.5     1    U------um-- Default    4d:6h:42m:29s

Origin(Ori): (b) BlackHole, (be) EBGP, (bg) BGP, (bi) IBGP, (bo) BOOTP 
            (ct) CBT, (d) Direct, (df) DownIF, (dv) DVMRP, (e1) ISISL1Ext 
            (e2) ISISL2Ext, (h) Hardcoded, (i) ICMP, (i1) ISISL1 (i2) ISISL2 
            (mb) MBGP, (mbe) MBGPExt, (mbi) MBGPInter, (ma) MPLSIntra
            (mr) MPLSInter, (mo) MOSPF (o) OSPF, (o1) OSPFExt1, (o2) OSPFExt2 
            (oa) OSPFIntra, (oe) OSPFAsExt, (or) OSPFInter, (pd) PIM-DM, (ps) PIM-SM 
            (r) RIP, (ra) RtAdvrt, (s) Static, (sv) SLB_VIP, (un) UnKnown 
            (*) Preferred unicast route (@) Preferred multicast route 
            (#) Preferred unicast and multicast route 

Flags: (B) BlackHole, (D) Dynamic, (G) Gateway, (H) Host Route
       (L) Direct LDP LSP, (l) Indirect LDP LSP, (m) Multicast
       (P) LPM-routing, (R) Modified, (S) Static, (T) Direct RSVP-TE LSP
       (t) Indirect RSVP-TE LSP, (u) Unicast, (U) Up 

Mask distribution:
     2 default routes                1 routes at length 24


Route Origin distribution:
     1 routes from Direct               2 routes from Static    


Total number of routes = 3

SummitX450-24t.15 # 

END

$responsesXOS->{config} = <<'END';
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="exos_config_display.xsl"?>
<xos-configuration version="11.2.3.3" date="Tue Jan 15 00:52:35 2008" creator="admin" checksum="0" platform="ASPEN">
<xos-module-aaa version="3.0.0.2">
<radius_service><server_set>1</server_set><type>0</type><timeOut>3</timeOut><enable>0</enable></radius_service>
<radius_service><server_set>1</server_set><type>1</type><timeOut>3</timeOut><enable>0</enable></radius_service>
<radius_service><server_set>2</server_set><type>0</type><timeOut>3</timeOut><enable>0</enable></radius_service>
<radius_service><server_set>2</server_set><type>1</type><timeOut>3</timeOut><enable>0</enable></radius_service>
<tacacs><server_no>0</server_no><type>0</type><tcp_port>49</tcp_port><encrypted_secret/><hostname/><vr><![CDATA[VR-Mgmt]]></vr><host_ipaddr>0.0.0.0</host_ipaddr><client_ipaddr>0.0.0.0</client_ipaddr><secret/></tacacs>
<tacacs><server_no>1</server_no><type>0</type><tcp_port>49</tcp_port><encrypted_secret/><hostname/><vr><![CDATA[VR-Mgmt]]></vr><host_ipaddr>0.0.0.0</host_ipaddr><client_ipaddr>0.0.0.0</client_ipaddr><secret/></tacacs>
<tacacs><server_no>0</server_no><type>1</type><tcp_port>49</tcp_port><encrypted_secret/><hostname/><vr><![CDATA[VR-Mgmt]]></vr><host_ipaddr>0.0.0.0</host_ipaddr><client_ipaddr>0.0.0.0</client_ipaddr><secret/></tacacs>
<tacacs><server_no>1</server_no><type>1</type><tcp_port>49</tcp_port><encrypted_secret/><hostname/><vr><![CDATA[VR-Mgmt]]></vr><host_ipaddr>0.0.0.0</host_ipaddr><client_ipaddr>0.0.0.0</client_ipaddr><secret/></tacacs>
<tacacs_service><type>0</type><timeOut>3</timeOut><enable>0</enable></tacacs_service>
<tacacs_service><type>1</type><timeOut>3</timeOut><enable>0</enable></tacacs_service>
<tacacs_service><type>2</type><timeOut>3</timeOut><enable>0</enable></tacacs_service>
<account><password><![CDATA[kHIZXS$n7uUIQpbpirSqLFcCIxhV/]]></password><name><![CDATA[admin]]></name><readwrite>1</readwrite></account>
<account><password><![CDATA[o4H3WS$LGpsiUiHdZRDl15sDE7vf.]]></password><name><![CDATA[user]]></name><readwrite>0</readwrite></account>
<account><password><![CDATA[uZSl9I$vR7ekrMugwuY8doNHjUWG1]]></password><name><![CDATA[testlab]]></name><readwrite>1</readwrite></account>
<acctPasswordSecurityGlobalCfg><acct_lockout_feature_enabled>0</acct_lockout_feature_enabled><passwd_min_len>0</passwd_min_len><acct_locked_out>0</acct_locked_out><passwd_char_validation_enabled>0</passwd_char_validation_enabled><passwd_hist_limit>0</passwd_hist_limit><passwd_max_age>0</passwd_max_age></acctPasswordSecurityGlobalCfg>
<acctPasswordSecurity><acct_lockout_feature_enabled>0</acct_lockout_feature_enabled><passwd_min_len>0</passwd_min_len><acct_locked_out>0</acct_locked_out><passwd_char_validation_enabled>0</passwd_char_validation_enabled><passwd_hist_limit>0</passwd_hist_limit><passwd_max_age>0</passwd_max_age><passwd_change_date>1151985893</passwd_change_date><name><![CDATA[admin]]></name></acctPasswordSecurity>
<acctPasswordSecurity><acct_lockout_feature_enabled>0</acct_lockout_feature_enabled><passwd_min_len>0</passwd_min_len><acct_locked_out>0</acct_locked_out><passwd_char_validation_enabled>0</passwd_char_validation_enabled><passwd_hist_limit>0</passwd_hist_limit><passwd_max_age>0</passwd_max_age><passwd_change_date>1151985797</passwd_change_date><name><![CDATA[user]]></name></acctPasswordSecurity>
<acctPasswordSecurity><acct_lockout_feature_enabled>0</acct_lockout_feature_enabled><passwd_min_len>0</passwd_min_len><acct_locked_out>0</acct_locked_out><passwd_char_validation_enabled>0</passwd_char_validation_enabled><passwd_hist_limit>0</passwd_hist_limit><passwd_max_age>0</passwd_max_age><passwd_change_date>1171604209</passwd_change_date><name><![CDATA[testlab]]></name></acctPasswordSecurity>
<acctPasswordHistory><histIndex>0</histIndex><passwd><![CDATA[Y6aZXS$.tP75QQJej7eVhjb.7DZL1]]></passwd><name><![CDATA[admin]]></name></acctPasswordHistory>
<acctPasswordHistory><histIndex>0</histIndex><passwd><![CDATA[vCK3WS$GgSlNgK6wPSbTk784fsS.0]]></passwd><name><![CDATA[user]]></name></acctPasswordHistory>
<acctPasswordHistory><histIndex>0</histIndex><passwd><![CDATA[nE8l9I$7P7ou0o7A0EiTufS1K85X1]]></passwd><name><![CDATA[testlab]]></name></acctPasswordHistory>
</xos-module-aaa>
<xos-module-acl version="3.0.0.2">
<aclRefreshConfig><blackhole>1</blackhole></aclRefreshConfig>
<cflwCfg><enable>0</enable></cflwCfg>
</xos-module-acl>
<xos-module-cfgmgr version="3.0.0.21">
<cliSession><maxSessions>8</maxSessions><maxLogins>3</maxLogins><loginBanner><![CDATA[]]></loginBanner><cmdLogging>0</cmdLogging></cliSession>
<idleTimeout><minutes>20</minutes><enabled>1</enabled></idleTimeout>
<systemDebug><coredumps>0</coredumps></systemDebug>
</xos-module-cfgmgr>
<xos-module-devmgr version="3.0.0.2">
<dm_system><power_off_on_failure>1</power_off_on_failure><disable_temp_check>0</disable_temp_check><sysContact><![CDATA[support@extremenetworks.com, +1 888 257 3000]]></sysContact><sysName><![CDATA[SummitX450-24t]]></sysName><slot_lock_required>0</slot_lock_required></dm_system>
<time_info></time_info>
<power_info><power_down_percent>100</power_down_percent><power_up_policy>2</power_up_policy><power_down_order>1000</power_down_order><power_up_percent>100</power_up_percent><power_down_policy>2</power_down_policy><disable_power_check>0</disable_power_check></power_info>
<card_info><slot>1</slot><poe_budget>65536</poe_budget><poe_disabled>0</poe_disabled><card_disabled>0</card_disabled><configured_type><![CDATA[SummitX450-24t]]></configured_type></card_info>
</xos-module-devmgr>
<xos-module-dosprotect version="3.0.0.1">
<dosprotect><l3protect_notify>3500</l3protect_notify><acl_timeout>5</acl_timeout><l3protect_alert>4000</l3protect_alert><trusted_ports></trusted_ports><enable>0</enable><interval>1</interval><debug>0</debug></dosprotect>
</xos-module-dosprotect>
<xos-module-eaps version="3.0.0.8">
<eapsGlobalCfg><fast_convergence>0</fast_convergence><enable>0</enable></eapsGlobalCfg>
</xos-module-eaps>
<xos-module-edp version="3.0.0.2">
<edpGlobalCfg><timeout>180</timeout><timer>60</timer></edpGlobalCfg>
<edpPortCfg><port>1</port><enable>1</enable></edpPortCfg>
<edpPortCfg><port>2</port><enable>1</enable></edpPortCfg>
<edpPortCfg><port>3</port><enable>1</enable></edpPortCfg>
<edpPortCfg><port>4</port><enable>1</enable></edpPortCfg>
<edpPortCfg><port>5</port><enable>1</enable></edpPortCfg>
<edpPortCfg><port>6</port><enable>1</enable></edpPortCfg>
<edpPortCfg><port>7</port><enable>1</enable></edpPortCfg>
<edpPortCfg><port>8</port><enable>1</enable></edpPortCfg>
<edpPortCfg><port>9</port><enable>1</enable></edpPortCfg>
<edpPortCfg><port>10</port><enable>1</enable></edpPortCfg>
<edpPortCfg><port>11</port><enable>1</enable></edpPortCfg>
<edpPortCfg><port>12</port><enable>1</enable></edpPortCfg>
<edpPortCfg><port>13</port><enable>1</enable></edpPortCfg>
<edpPortCfg><port>14</port><enable>1</enable></edpPortCfg>
<edpPortCfg><port>15</port><enable>1</enable></edpPortCfg>
<edpPortCfg><port>16</port><enable>1</enable></edpPortCfg>
<edpPortCfg><port>17</port><enable>1</enable></edpPortCfg>
<edpPortCfg><port>18</port><enable>1</enable></edpPortCfg>
<edpPortCfg><port>19</port><enable>1</enable></edpPortCfg>
<edpPortCfg><port>20</port><enable>1</enable></edpPortCfg>
<edpPortCfg><port>21</port><enable>1</enable></edpPortCfg>
<edpPortCfg><port>22</port><enable>1</enable></edpPortCfg>
<edpPortCfg><port>23</port><enable>1</enable></edpPortCfg>
<edpPortCfg><port>24</port><enable>1</enable></edpPortCfg>
<edpPortCfg><port>25</port><enable>1</enable></edpPortCfg>
<edpPortCfg><port>26</port><enable>1</enable></edpPortCfg>
</xos-module-edp>
<xos-module-elrp version="3.0.0.1">
<elrpGlobalCfg><elrpClients>0</elrpClients><txpkts>0</txpkts><rxpkts>0</rxpkts><enable>0</enable></elrpGlobalCfg>
</xos-module-elrp>
<xos-module-ems version="3.0.0.2">
<emsGlobalConfig><enableDebug>0</enableDebug></emsGlobalConfig>
<emsFilterConfig><name><![CDATA[DefaultFilter]]></name><type><![CDATA[filter]]></type></emsFilterConfig>
<emsFilterItem><row>0</row><name><![CDATA[DefaultFilter]]></name><event><![CDATA[All]]></event><severity><![CDATA[--------]]></severity></emsFilterItem>
<emsTargetConfig><type><![CDATA[memory-buffer]]></type><displayFormat>66010</displayFormat><regex><![CDATA[Any]]></regex><targetSize>1000</targetSize><only>0</only><severity><![CDATA[Debug-Data]]></severity><filter><![CDATA[DefaultFilter]]></filter><enable>1</enable></emsTargetConfig>
<emsTargetConfig><type><![CDATA[nvram]]></type><displayFormat>66010</displayFormat><regex><![CDATA[Any]]></regex><only>0</only><severity><![CDATA[Warning]]></severity><filter><![CDATA[DefaultFilter]]></filter><enable>1</enable></emsTargetConfig>
<emsTargetConfig><type><![CDATA[console]]></type><displayFormat>66010</displayFormat><regex><![CDATA[Any]]></regex><only>0</only><severity><![CDATA[Info]]></severity><filter><![CDATA[DefaultFilter]]></filter><enable>0</enable></emsTargetConfig>
</xos-module-ems>
<xos-module-epm version="3.0.0.3">
<epmsysrec><no_reboot>0</no_reboot></epmsysrec>
<epmwatchdog><on>1</on></epmwatchdog>
<epmFirmwareInstallationMode><mode>0</mode></epmFirmwareInstallationMode>
<epmenablecpu><total>0</total><threshold>60</threshold><interval>20</interval></epmenablecpu>
<epmdisablecpu><on>0</on></epmdisablecpu>
</xos-module-epm>
<xos-module-esrp version="3.0.0.4">
<esrpCreateGlobalCfg><enableEsrp>1</enableEsrp><enableAutoDomains>0</enableAutoDomains><enablePortTlv>0</enablePortTlv><version>2</version></esrpCreateGlobalCfg>
</xos-module-esrp>
<xos-module-etmon version="1.0.0.1">
<sflowGlobal><sflowEnable>0</sflowEnable><gPollInterval>20</gPollInterval><globalMaxSampleRate>2000</globalMaxSampleRate><defaultSampleRate>8192</defaultSampleRate><collectorPort2>0</collectorPort2><collectorPort3>0</collectorPort3><collectorIpa2>0.0.0.0</collectorIpa2><collectorPort>0</collectorPort><collectorIpa3>0.0.0.0</collectorIpa3><collectorPort4>0</collectorPort4><collectorIpa4>0.0.0.0</collectorIpa4><collectorVr><![CDATA[VR-Mgmt]]></collectorVr><collectorVr2><![CDATA[VR-Mgmt]]></collectorVr2><collectorVr3><![CDATA[VR-Mgmt]]></collectorVr3><collectorVr4><![CDATA[VR-Mgmt]]></collectorVr4><collectorIpa>0.0.0.0</collectorIpa><sflowCfgAgentAddress>0.0.0.0</sflowCfgAgentAddress></sflowGlobal>
<rmonCfg><enabled>2</enabled></rmonCfg>
<historyControl><historyControlIndex>1</historyControlIndex><historyControlDataSource>1.3.6.1.2.1.2.2.1.1.1001</historyControlDataSource><historyControlStatus>1</historyControlStatus><historyControlOwner>6d:6f:6e:69:74:6f:72</historyControlOwner><historyControlBucketsRequested>50</historyControlBucketsRequested><historyControlInterval>30</historyControlInterval></historyControl>
<historyControl><historyControlIndex>2</historyControlIndex><historyControlDataSource>1.3.6.1.2.1.2.2.1.1.1001</historyControlDataSource><historyControlStatus>1</historyControlStatus><historyControlOwner>6d:6f:6e:69:74:6f:72</historyControlOwner><historyControlBucketsRequested>50</historyControlBucketsRequested><historyControlInterval>1800</historyControlInterval></historyControl>
<historyControl><historyControlIndex>3</historyControlIndex><historyControlDataSource>1.3.6.1.2.1.2.2.1.1.1002</historyControlDataSource><historyControlStatus>1</historyControlStatus><historyControlOwner>6d:6f:6e:69:74:6f:72</historyControlOwner><historyControlBucketsRequested>50</historyControlBucketsRequested><historyControlInterval>30</historyControlInterval></historyControl>
<historyControl><historyControlIndex>4</historyControlIndex><historyControlDataSource>1.3.6.1.2.1.2.2.1.1.1002</historyControlDataSource><historyControlStatus>1</historyControlStatus><historyControlOwner>6d:6f:6e:69:74:6f:72</historyControlOwner><historyControlBucketsRequested>50</historyControlBucketsRequested><historyControlInterval>1800</historyControlInterval></historyControl>
<historyControl><historyControlIndex>5</historyControlIndex><historyControlDataSource>1.3.6.1.2.1.2.2.1.1.1003</historyControlDataSource><historyControlStatus>1</historyControlStatus><historyControlOwner>6d:6f:6e:69:74:6f:72</historyControlOwner><historyControlBucketsRequested>50</historyControlBucketsRequested><historyControlInterval>30</historyControlInterval></historyControl>
<historyControl><historyControlIndex>6</historyControlIndex><historyControlDataSource>1.3.6.1.2.1.2.2.1.1.1003</historyControlDataSource><historyControlStatus>1</historyControlStatus><historyControlOwner>6d:6f:6e:69:74:6f:72</historyControlOwner><historyControlBucketsRequested>50</historyControlBucketsRequested><historyControlInterval>1800</historyControlInterval></historyControl>
<historyControl><historyControlIndex>7</historyControlIndex><historyControlDataSource>1.3.6.1.2.1.2.2.1.1.1004</historyControlDataSource><historyControlStatus>1</historyControlStatus><historyControlOwner>6d:6f:6e:69:74:6f:72</historyControlOwner><historyControlBucketsRequested>50</historyControlBucketsRequested><historyControlInterval>30</historyControlInterval></historyControl>
<historyControl><historyControlIndex>8</historyControlIndex><historyControlDataSource>1.3.6.1.2.1.2.2.1.1.1004</historyControlDataSource><historyControlStatus>1</historyControlStatus><historyControlOwner>6d:6f:6e:69:74:6f:72</historyControlOwner><historyControlBucketsRequested>50</historyControlBucketsRequested><historyControlInterval>1800</historyControlInterval></historyControl>
<historyControl><historyControlIndex>9</historyControlIndex><historyControlDataSource>1.3.6.1.2.1.2.2.1.1.1005</historyControlDataSource><historyControlStatus>1</historyControlStatus><historyControlOwner>6d:6f:6e:69:74:6f:72</historyControlOwner><historyControlBucketsRequested>50</historyControlBucketsRequested><historyControlInterval>30</historyControlInterval></historyControl>
<historyControl><historyControlIndex>10</historyControlIndex><historyControlDataSource>1.3.6.1.2.1.2.2.1.1.1005</historyControlDataSource><historyControlStatus>1</historyControlStatus><historyControlOwner>6d:6f:6e:69:74:6f:72</historyControlOwner><historyControlBucketsRequested>50</historyControlBucketsRequested><historyControlInterval>1800</historyControlInterval></historyControl>
<historyControl><historyControlIndex>11</historyControlIndex><historyControlDataSource>1.3.6.1.2.1.2.2.1.1.1006</historyControlDataSource><historyControlStatus>1</historyControlStatus><historyControlOwner>6d:6f:6e:69:74:6f:72</historyControlOwner><historyControlBucketsRequested>50</historyControlBucketsRequested><historyControlInterval>30</historyControlInterval></historyControl>
<historyControl><historyControlIndex>12</historyControlIndex><historyControlDataSource>1.3.6.1.2.1.2.2.1.1.1006</historyControlDataSource><historyControlStatus>1</historyControlStatus><historyControlOwner>6d:6f:6e:69:74:6f:72</historyControlOwner><historyControlBucketsRequested>50</historyControlBucketsRequested><historyControlInterval>1800</historyControlInterval></historyControl>
<historyControl><historyControlIndex>13</historyControlIndex><historyControlDataSource>1.3.6.1.2.1.2.2.1.1.1007</historyControlDataSource><historyControlStatus>1</historyControlStatus><historyControlOwner>6d:6f:6e:69:74:6f:72</historyControlOwner><historyControlBucketsRequested>50</historyControlBucketsRequested><historyControlInterval>30</historyControlInterval></historyControl>
<historyControl><historyControlIndex>14</historyControlIndex><historyControlDataSource>1.3.6.1.2.1.2.2.1.1.1007</historyControlDataSource><historyControlStatus>1</historyControlStatus><historyControlOwner>6d:6f:6e:69:74:6f:72</historyControlOwner><historyControlBucketsRequested>50</historyControlBucketsRequested><historyControlInterval>1800</historyControlInterval></historyControl>
<historyControl><historyControlIndex>15</historyControlIndex><historyControlDataSource>1.3.6.1.2.1.2.2.1.1.1008</historyControlDataSource><historyControlStatus>1</historyControlStatus><historyControlOwner>6d:6f:6e:69:74:6f:72</historyControlOwner><historyControlBucketsRequested>50</historyControlBucketsRequested><historyControlInterval>30</historyControlInterval></historyControl>
<historyControl><historyControlIndex>16</historyControlIndex><historyControlDataSource>1.3.6.1.2.1.2.2.1.1.1008</historyControlDataSource><historyControlStatus>1</historyControlStatus><historyControlOwner>6d:6f:6e:69:74:6f:72</historyControlOwner><historyControlBucketsRequested>50</historyControlBucketsRequested><historyControlInterval>1800</historyControlInterval></historyControl>
<historyControl><historyControlIndex>17</historyControlIndex><historyControlDataSource>1.3.6.1.2.1.2.2.1.1.1009</historyControlDataSource><historyControlStatus>1</historyControlStatus><historyControlOwner>6d:6f:6e:69:74:6f:72</historyControlOwner><historyControlBucketsRequested>50</historyControlBucketsRequested><historyControlInterval>30</historyControlInterval></historyControl>
<historyControl><historyControlIndex>18</historyControlIndex><historyControlDataSource>1.3.6.1.2.1.2.2.1.1.1009</historyControlDataSource><historyControlStatus>1</historyControlStatus><historyControlOwner>6d:6f:6e:69:74:6f:72</historyControlOwner><historyControlBucketsRequested>50</historyControlBucketsRequested><historyControlInterval>1800</historyControlInterval></historyControl>
<historyControl><historyControlIndex>19</historyControlIndex><historyControlDataSource>1.3.6.1.2.1.2.2.1.1.1010</historyControlDataSource><historyControlStatus>1</historyControlStatus><historyControlOwner>6d:6f:6e:69:74:6f:72</historyControlOwner><historyControlBucketsRequested>50</historyControlBucketsRequested><historyControlInterval>30</historyControlInterval></historyControl>
<historyControl><historyControlIndex>20</historyControlIndex><historyControlDataSource>1.3.6.1.2.1.2.2.1.1.1010</historyControlDataSource><historyControlStatus>1</historyControlStatus><historyControlOwner>6d:6f:6e:69:74:6f:72</historyControlOwner><historyControlBucketsRequested>50</historyControlBucketsRequested><historyControlInterval>1800</historyControlInterval></historyControl>
<historyControl><historyControlIndex>21</historyControlIndex><historyControlDataSource>1.3.6.1.2.1.2.2.1.1.1011</historyControlDataSource><historyControlStatus>1</historyControlStatus><historyControlOwner>6d:6f:6e:69:74:6f:72</historyControlOwner><historyControlBucketsRequested>50</historyControlBucketsRequested><historyControlInterval>30</historyControlInterval></historyControl>
<historyControl><historyControlIndex>22</historyControlIndex><historyControlDataSource>1.3.6.1.2.1.2.2.1.1.1011</historyControlDataSource><historyControlStatus>1</historyControlStatus><historyControlOwner>6d:6f:6e:69:74:6f:72</historyControlOwner><historyControlBucketsRequested>50</historyControlBucketsRequested><historyControlInterval>1800</historyControlInterval></historyControl>
<historyControl><historyControlIndex>23</historyControlIndex><historyControlDataSource>1.3.6.1.2.1.2.2.1.1.1012</historyControlDataSource><historyControlStatus>1</historyControlStatus><historyControlOwner>6d:6f:6e:69:74:6f:72</historyControlOwner><historyControlBucketsRequested>50</historyControlBucketsRequested><historyControlInterval>30</historyControlInterval></historyControl>
<historyControl><historyControlIndex>24</historyControlIndex><historyControlDataSource>1.3.6.1.2.1.2.2.1.1.1012</historyControlDataSource><historyControlStatus>1</historyControlStatus><historyControlOwner>6d:6f:6e:69:74:6f:72</historyControlOwner><historyControlBucketsRequested>50</historyControlBucketsRequested><historyControlInterval>1800</historyControlInterval></historyControl>
<historyControl><historyControlIndex>25</historyControlIndex><historyControlDataSource>1.3.6.1.2.1.2.2.1.1.1013</historyControlDataSource><historyControlStatus>1</historyControlStatus><historyControlOwner>6d:6f:6e:69:74:6f:72</historyControlOwner><historyControlBucketsRequested>50</historyControlBucketsRequested><historyControlInterval>30</historyControlInterval></historyControl>
<historyControl><historyControlIndex>26</historyControlIndex><historyControlDataSource>1.3.6.1.2.1.2.2.1.1.1013</historyControlDataSource><historyControlStatus>1</historyControlStatus><historyControlOwner>6d:6f:6e:69:74:6f:72</historyControlOwner><historyControlBucketsRequested>50</historyControlBucketsRequested><historyControlInterval>1800</historyControlInterval></historyControl>
<historyControl><historyControlIndex>27</historyControlIndex><historyControlDataSource>1.3.6.1.2.1.2.2.1.1.1014</historyControlDataSource><historyControlStatus>1</historyControlStatus><historyControlOwner>6d:6f:6e:69:74:6f:72</historyControlOwner><historyControlBucketsRequested>50</historyControlBucketsRequested><historyControlInterval>30</historyControlInterval></historyControl>
<historyControl><historyControlIndex>28</historyControlIndex><historyControlDataSource>1.3.6.1.2.1.2.2.1.1.1014</historyControlDataSource><historyControlStatus>1</historyControlStatus><historyControlOwner>6d:6f:6e:69:74:6f:72</historyControlOwner><historyControlBucketsRequested>50</historyControlBucketsRequested><historyControlInterval>1800</historyControlInterval></historyControl>
<historyControl><historyControlIndex>29</historyControlIndex><historyControlDataSource>1.3.6.1.2.1.2.2.1.1.1015</historyControlDataSource><historyControlStatus>1</historyControlStatus><historyControlOwner>6d:6f:6e:69:74:6f:72</historyControlOwner><historyControlBucketsRequested>50</historyControlBucketsRequested><historyControlInterval>30</historyControlInterval></historyControl>
<historyControl><historyControlIndex>30</historyControlIndex><historyControlDataSource>1.3.6.1.2.1.2.2.1.1.1015</historyControlDataSource><historyControlStatus>1</historyControlStatus><historyControlOwner>6d:6f:6e:69:74:6f:72</historyControlOwner><historyControlBucketsRequested>50</historyControlBucketsRequested><historyControlInterval>1800</historyControlInterval></historyControl>
<historyControl><historyControlIndex>31</historyControlIndex><historyControlDataSource>1.3.6.1.2.1.2.2.1.1.1016</historyControlDataSource><historyControlStatus>1</historyControlStatus><historyControlOwner>6d:6f:6e:69:74:6f:72</historyControlOwner><historyControlBucketsRequested>50</historyControlBucketsRequested><historyControlInterval>30</historyControlInterval></historyControl>
<historyControl><historyControlIndex>32</historyControlIndex><historyControlDataSource>1.3.6.1.2.1.2.2.1.1.1016</historyControlDataSource><historyControlStatus>1</historyControlStatus><historyControlOwner>6d:6f:6e:69:74:6f:72</historyControlOwner><historyControlBucketsRequested>50</historyControlBucketsRequested><historyControlInterval>1800</historyControlInterval></historyControl>
<historyControl><historyControlIndex>33</historyControlIndex><historyControlDataSource>1.3.6.1.2.1.2.2.1.1.1017</historyControlDataSource><historyControlStatus>1</historyControlStatus><historyControlOwner>6d:6f:6e:69:74:6f:72</historyControlOwner><historyControlBucketsRequested>50</historyControlBucketsRequested><historyControlInterval>30</historyControlInterval></historyControl>
<historyControl><historyControlIndex>34</historyControlIndex><historyControlDataSource>1.3.6.1.2.1.2.2.1.1.1017</historyControlDataSource><historyControlStatus>1</historyControlStatus><historyControlOwner>6d:6f:6e:69:74:6f:72</historyControlOwner><historyControlBucketsRequested>50</historyControlBucketsRequested><historyControlInterval>1800</historyControlInterval></historyControl>
<historyControl><historyControlIndex>35</historyControlIndex><historyControlDataSource>1.3.6.1.2.1.2.2.1.1.1018</historyControlDataSource><historyControlStatus>1</historyControlStatus><historyControlOwner>6d:6f:6e:69:74:6f:72</historyControlOwner><historyControlBucketsRequested>50</historyControlBucketsRequested><historyControlInterval>30</historyControlInterval></historyControl>
<historyControl><historyControlIndex>36</historyControlIndex><historyControlDataSource>1.3.6.1.2.1.2.2.1.1.1018</historyControlDataSource><historyControlStatus>1</historyControlStatus><historyControlOwner>6d:6f:6e:69:74:6f:72</historyControlOwner><historyControlBucketsRequested>50</historyControlBucketsRequested><historyControlInterval>1800</historyControlInterval></historyControl>
<historyControl><historyControlIndex>37</historyControlIndex><historyControlDataSource>1.3.6.1.2.1.2.2.1.1.1019</historyControlDataSource><historyControlStatus>1</historyControlStatus><historyControlOwner>6d:6f:6e:69:74:6f:72</historyControlOwner><historyControlBucketsRequested>50</historyControlBucketsRequested><historyControlInterval>30</historyControlInterval></historyControl>
<historyControl><historyControlIndex>38</historyControlIndex><historyControlDataSource>1.3.6.1.2.1.2.2.1.1.1019</historyControlDataSource><historyControlStatus>1</historyControlStatus><historyControlOwner>6d:6f:6e:69:74:6f:72</historyControlOwner><historyControlBucketsRequested>50</historyControlBucketsRequested><historyControlInterval>1800</historyControlInterval></historyControl>
<historyControl><historyControlIndex>39</historyControlIndex><historyControlDataSource>1.3.6.1.2.1.2.2.1.1.1020</historyControlDataSource><historyControlStatus>1</historyControlStatus><historyControlOwner>6d:6f:6e:69:74:6f:72</historyControlOwner><historyControlBucketsRequested>50</historyControlBucketsRequested><historyControlInterval>30</historyControlInterval></historyControl>
<historyControl><historyControlIndex>40</historyControlIndex><historyControlDataSource>1.3.6.1.2.1.2.2.1.1.1020</historyControlDataSource><historyControlStatus>1</historyControlStatus><historyControlOwner>6d:6f:6e:69:74:6f:72</historyControlOwner><historyControlBucketsRequested>50</historyControlBucketsRequested><historyControlInterval>1800</historyControlInterval></historyControl>
<historyControl><historyControlIndex>41</historyControlIndex><historyControlDataSource>1.3.6.1.2.1.2.2.1.1.1021</historyControlDataSource><historyControlStatus>1</historyControlStatus><historyControlOwner>6d:6f:6e:69:74:6f:72</historyControlOwner><historyControlBucketsRequested>50</historyControlBucketsRequested><historyControlInterval>30</historyControlInterval></historyControl>
<historyControl><historyControlIndex>42</historyControlIndex><historyControlDataSource>1.3.6.1.2.1.2.2.1.1.1021</historyControlDataSource><historyControlStatus>1</historyControlStatus><historyControlOwner>6d:6f:6e:69:74:6f:72</historyControlOwner><historyControlBucketsRequested>50</historyControlBucketsRequested><historyControlInterval>1800</historyControlInterval></historyControl>
<historyControl><historyControlIndex>43</historyControlIndex><historyControlDataSource>1.3.6.1.2.1.2.2.1.1.1022</historyControlDataSource><historyControlStatus>1</historyControlStatus><historyControlOwner>6d:6f:6e:69:74:6f:72</historyControlOwner><historyControlBucketsRequested>50</historyControlBucketsRequested><historyControlInterval>30</historyControlInterval></historyControl>
<historyControl><historyControlIndex>44</historyControlIndex><historyControlDataSource>1.3.6.1.2.1.2.2.1.1.1022</historyControlDataSource><historyControlStatus>1</historyControlStatus><historyControlOwner>6d:6f:6e:69:74:6f:72</historyControlOwner><historyControlBucketsRequested>50</historyControlBucketsRequested><historyControlInterval>1800</historyControlInterval></historyControl>
<historyControl><historyControlIndex>45</historyControlIndex><historyControlDataSource>1.3.6.1.2.1.2.2.1.1.1023</historyControlDataSource><historyControlStatus>1</historyControlStatus><historyControlOwner>6d:6f:6e:69:74:6f:72</historyControlOwner><historyControlBucketsRequested>50</historyControlBucketsRequested><historyControlInterval>30</historyControlInterval></historyControl>
<historyControl><historyControlIndex>46</historyControlIndex><historyControlDataSource>1.3.6.1.2.1.2.2.1.1.1023</historyControlDataSource><historyControlStatus>1</historyControlStatus><historyControlOwner>6d:6f:6e:69:74:6f:72</historyControlOwner><historyControlBucketsRequested>50</historyControlBucketsRequested><historyControlInterval>1800</historyControlInterval></historyControl>
<historyControl><historyControlIndex>47</historyControlIndex><historyControlDataSource>1.3.6.1.2.1.2.2.1.1.1024</historyControlDataSource><historyControlStatus>1</historyControlStatus><historyControlOwner>6d:6f:6e:69:74:6f:72</historyControlOwner><historyControlBucketsRequested>50</historyControlBucketsRequested><historyControlInterval>30</historyControlInterval></historyControl>
<historyControl><historyControlIndex>48</historyControlIndex><historyControlDataSource>1.3.6.1.2.1.2.2.1.1.1024</historyControlDataSource><historyControlStatus>1</historyControlStatus><historyControlOwner>6d:6f:6e:69:74:6f:72</historyControlOwner><historyControlBucketsRequested>50</historyControlBucketsRequested><historyControlInterval>1800</historyControlInterval></historyControl>
<historyControl><historyControlIndex>49</historyControlIndex><historyControlDataSource>1.3.6.1.2.1.2.2.1.1.1025</historyControlDataSource><historyControlStatus>1</historyControlStatus><historyControlOwner>6d:6f:6e:69:74:6f:72</historyControlOwner><historyControlBucketsRequested>50</historyControlBucketsRequested><historyControlInterval>30</historyControlInterval></historyControl>
<historyControl><historyControlIndex>50</historyControlIndex><historyControlDataSource>1.3.6.1.2.1.2.2.1.1.1025</historyControlDataSource><historyControlStatus>1</historyControlStatus><historyControlOwner>6d:6f:6e:69:74:6f:72</historyControlOwner><historyControlBucketsRequested>50</historyControlBucketsRequested><historyControlInterval>1800</historyControlInterval></historyControl>
<historyControl><historyControlIndex>51</historyControlIndex><historyControlDataSource>1.3.6.1.2.1.2.2.1.1.1026</historyControlDataSource><historyControlStatus>1</historyControlStatus><historyControlOwner>6d:6f:6e:69:74:6f:72</historyControlOwner><historyControlBucketsRequested>50</historyControlBucketsRequested><historyControlInterval>30</historyControlInterval></historyControl>
<historyControl><historyControlIndex>52</historyControlIndex><historyControlDataSource>1.3.6.1.2.1.2.2.1.1.1026</historyControlDataSource><historyControlStatus>1</historyControlStatus><historyControlOwner>6d:6f:6e:69:74:6f:72</historyControlOwner><historyControlBucketsRequested>50</historyControlBucketsRequested><historyControlInterval>1800</historyControlInterval></historyControl>
<historyControl><historyControlIndex>53</historyControlIndex><historyControlDataSource>1.3.6.1.2.1.2.2.1.1.1027</historyControlDataSource><historyControlStatus>1</historyControlStatus><historyControlOwner>6d:6f:6e:69:74:6f:72</historyControlOwner><historyControlBucketsRequested>50</historyControlBucketsRequested><historyControlInterval>30</historyControlInterval></historyControl>
<historyControl><historyControlIndex>54</historyControlIndex><historyControlDataSource>1.3.6.1.2.1.2.2.1.1.1027</historyControlDataSource><historyControlStatus>1</historyControlStatus><historyControlOwner>6d:6f:6e:69:74:6f:72</historyControlOwner><historyControlBucketsRequested>50</historyControlBucketsRequested><historyControlInterval>1800</historyControlInterval></historyControl>
</xos-module-etmon>
<xos-module-fdb version="4.0.0.2">
<fdb_op><sub_action>1</sub_action><age>300</age></fdb_op>
<arp_config><checking>1</checking><max_proxy_entries>256</max_proxy_entries><vr_name><![CDATA[VR-Control]]></vr_name><refresh>1</refresh><max_entries>4096</max_entries><timeout>20</timeout><max_pending_entries>256</max_pending_entries></arp_config>
<arp_config><checking>1</checking><max_proxy_entries>256</max_proxy_entries><vr_name><![CDATA[VR-Default]]></vr_name><refresh>1</refresh><max_entries>4096</max_entries><timeout>20</timeout><max_pending_entries>256</max_pending_entries></arp_config>
<arp_config><checking>1</checking><max_proxy_entries>256</max_proxy_entries><vr_name><![CDATA[VR-Mgmt]]></vr_name><refresh>1</refresh><max_entries>4096</max_entries><timeout>20</timeout><max_pending_entries>256</max_pending_entries></arp_config>
</xos-module-fdb>
<xos-module-lldp version="1.2.0.0">
<lldpGlobalConfiguration><lldpNotificationInterval>5</lldpNotificationInterval><lldpMessageTxHoldMultiplier>4</lldpMessageTxHoldMultiplier><lldpMessageTxInterval>30</lldpMessageTxInterval><lldpTxDelay>2</lldpTxDelay><lldpReinitDelay>2</lldpReinitDelay></lldpGlobalConfiguration>
</xos-module-lldp>
<xos-module-mcmgr version="4.0.0.2">
<mcCacheMgtConfig><maxUnresCacheWithMultiPkts>64</maxUnresCacheWithMultiPkts><maxQueuedPktsPerCache>32</maxQueuedPktsPerCache></mcCacheMgtConfig>
<igmpSnoopTimer><vrName><![CDATA[VR-Default]]></vrName><leave_timeout>1000</leave_timeout><host_timeout>260</host_timeout><router_timeout>260</router_timeout></igmpSnoopTimer>
<igmp6SnoopTimer><vrName><![CDATA[VR-Default]]></vrName><leave_timeout>1000</leave_timeout><host_timeout>260</host_timeout><router_timeout>260</router_timeout></igmp6SnoopTimer>
<igmpSnoopFwMcRouter><vrName><![CDATA[VR-Default]]></vrName><mldEnable>0</mldEnable><enable>0</enable></igmpSnoopFwMcRouter>
<igmpTimer><vrName><![CDATA[VR-Default]]></vrName><last_member_query_interval>1</last_member_query_interval><query_response_interval>10</query_response_interval><query_interval>125</query_interval><robustness>2</robustness></igmpTimer>
<igmp6Timer><vrName><![CDATA[VR-Default]]></vrName><last_member_query_interval>1</last_member_query_interval><query_response_interval>10</query_response_interval><query_interval>125</query_interval><robustness>2</robustness></igmp6Timer>
<igmpSnoopProxy><vrName><![CDATA[VR-Default]]></vrName><mldEnable>1</mldEnable><enable>1</enable></igmpSnoopProxy>
<igmpSnoopFloodList><vrName><![CDATA[VR-Default]]></vrName><v6>0</v6><profileName><![CDATA[none]]></profileName></igmpSnoopFloodList>
<igmpSnoopFloodList><vrName><![CDATA[VR-Default]]></vrName><v6>1</v6><profileName><![CDATA[none]]></profileName></igmpSnoopFloodList>
</xos-module-mcmgr>
<xos-module-netLogin version="1.0.0.0">
<netloginDot1xConfigTimers><suppRespTimeout>30</suppRespTimeout><reAuthPeriod>3600</reAuthPeriod><quietPeriod>60</quietPeriod><eapolTxVersion>1</eapolTxVersion><serverTimeout>30</serverTimeout></netloginDot1xConfigTimers>
<netLoginWebCfg><banner/><redirect_page><![CDATA[http://www.extremenetworks.com]]></redirect_page><session_refresh>3</session_refresh><base_url><![CDATA[network-access.com]]></base_url><logout_popup>1</logout_popup></netLoginWebCfg>
</xos-module-netLogin>
<xos-module-netTools version="3.0.0.2">
<dns_search_pref><search_pref>4</search_pref></dns_search_pref>
<sntp><server_no>0</server_no><vr/><server_addr/></sntp>
<sntp><server_no>1</server_no><vr/><server_addr/></sntp>
<sntp_service><poll_intvl>64</poll_intvl><enable>0</enable></sntp_service>
</xos-module-netTools>
<xos-module-ospf version="3.0.0.2">
<ospfGlobal><ipOptionRA>0</ipOptionRA><metTabCost10M>10</metTabCost10M><opaqueExtEnable>1</opaqueExtEnable><ospfVersionNumber>2</ospfVersionNumber><ospfMulticastExtensions>0</ospfMulticastExtensions><def_cost>0</def_cost><leakFilter/><spfHoldTime>3</spfHoldTime><metTabCost100M>5</metTabCost100M><importPlcy/><def_tag>0</def_tag><ospfExtLsdbLimit>0</ospfExtLsdbLimit><defRouteEnable>0</defRouteEnable><metTabCost1G>4</metTabCost1G><ospfTOSSupport>2</ospfTOSSupport><originateRouterId>0</originateRouterId><ospfOperStatus>1</ospfOperStatus><lsaBatchInterval>30</lsaBatchInterval><ospfExitOverflowInterval>0</ospfExitOverflowInterval><ospfAdminStat>2</ospfAdminStat><always>0</always><ospfRouterIdAuto>1</ospfRouterIdAuto><def_type>0</def_type><ospfDemandExtensions>2</ospfDemandExtensions><metTabCost10G>2</metTabCost10G><ospfRouteLeak><cost>0</cost><shutdown_priority>2048</shutdown_priority><operation_status>0</operation_status><rtmap_s/><hasRtMap>0</hasRtMap><proto><![CDATA[direct]]></proto><tag>0</tag><type>0</type><enable>0</enable></ospfRouteLeak><ospfRouteLeak><cost>0</cost><shutdown_priority>2048</shutdown_priority><operation_status>0</operation_status><rtmap_s/><hasRtMap>0</hasRtMap><proto><![CDATA[static]]></proto><tag>0</tag><type>0</type><enable>0</enable></ospfRouteLeak><ospfRouteLeak><cost>0</cost><shutdown_priority>2048</shutdown_priority><operation_status>0</operation_status><rtmap_s/><hasRtMap>0</hasRtMap><proto><![CDATA[rip]]></proto><tag>0</tag><type>0</type><enable>0</enable></ospfRouteLeak><ospfRouteLeak><cost>0</cost><shutdown_priority>2048</shutdown_priority><operation_status>0</operation_status><rtmap_s/><hasRtMap>0</hasRtMap><proto><![CDATA[e-bgp]]></proto><tag>0</tag><type>0</type><enable>0</enable></ospfRouteLeak><ospfRouteLeak><cost>0</cost><shutdown_priority>2048</shutdown_priority><operation_status>0</operation_status><rtmap_s/><hasRtMap>0</hasRtMap><proto><![CDATA[i-bgp]]></proto><tag>0</tag><type>0</type><enable>0</enable></ospfRouteLeak></ospfGlobal>
<ospfArea><ospfAreaId>0.0.0.0</ospfAreaId><ospfStubTOS>0</ospfStubTOS><ospfSpfRuns>0</ospfSpfRuns><ospfStubMetric>0</ospfStubMetric><ospfInterAreaFilter/><ospfExternalRouteFilter/><ospfAreaStatus>1</ospfAreaStatus><ospfAreaLsaCksumSum>0</ospfAreaLsaCksumSum><ospfAreaType>0</ospfAreaType><ospfStubAreaId>0.0.0.0</ospfStubAreaId><ospfImportAsExtern>1</ospfImportAsExtern><ospfStubStatus>0</ospfStubStatus><ospfStubMetricType>0</ospfStubMetricType><ospfAreaBdrRtrCount>0</ospfAreaBdrRtrCount><ospfEnabled>0</ospfEnabled><ospfTranslate>0</ospfTranslate><ospfAsBdrRtrCount>0</ospfAsBdrRtrCount><ospfRouterId>0.0.0.0</ospfRouterId><ospfAuthType>0</ospfAuthType><ospfAreaSummary>2</ospfAreaSummary><ospfAreaLsaCount>0</ospfAreaLsaCount></ospfArea>
<ospfInterface><ospfIfName><![CDATA[Default]]></ospfIfName><ospfIfIpAddress>10.100.26.5</ospfIfIpAddress><ospfIfTransitDelay>1</ospfIfTransitDelay><ospfIfRtrDeadInterval>40</ospfIfRtrDeadInterval><ospfIfShutDownPriority>1024</ospfIfShutDownPriority><ospfIfAuthKey></ospfIfAuthKey><ospfIfPassive>2</ospfIfPassive><ospfIfLinkType>0</ospfIfLinkType><ospfIfAuthEncrypted>1</ospfIfAuthEncrypted><ospfIfRetransInterval>5</ospfIfRetransInterval><ospfIfMulticastForwarding>1</ospfIfMulticastForwarding><ospfIfNeighborIP>0.0.0.0</ospfIfNeighborIP><ospfIfWaitIntervalAuto>0</ospfIfWaitIntervalAuto><ospfIfRtrPriority>0</ospfIfRtrPriority><ospfIfType>1</ospfIfType><ospfIfMetricValue>5</ospfIfMetricValue><ospfIfAuthType>0</ospfIfAuthType><ospfIfStatus>1</ospfIfStatus><ospfIfPollInterval>120</ospfIfPollInterval><ospfIfMetricType>1</ospfIfMetricType><ospfAddressLessIf>0</ospfAddressLessIf><ospfIfAdminStat>2</ospfIfAdminStat><ospfIfWaitInterval>0</ospfIfWaitInterval><ospfIfNeighborNum>0</ospfIfNeighborNum><ospfIfHelloInterval>10</ospfIfHelloInterval><ospfIfDemand>2</ospfIfDemand><ospfIfAreaId>0.0.0.0</ospfIfAreaId><ospfIfMetricStatus>1</ospfIfMetricStatus></ospfInterface>
<ospfTrapControlObj><ospfPacketType>1</ospfPacketType><ospfPacketSrc>0.0.0.0</ospfPacketSrc><ospfConfigErrorType>1</ospfConfigErrorType><ospfSetTrap>00:00:00:00</ospfSetTrap></ospfTrapControlObj>
</xos-module-ospf>
<xos-module-pim version="3.0.0.2">
<pimGlobal><rpThreshold>0</rpThreshold><regSuppressTimer>60</regSuppressTimer><cbsrPrio>0</cbsrPrio><regActiveInterval>0</regActiveInterval><cbsrVlanName/><regChkSum>0</regChkSum><crpAdvInterval>60</crpAdvInterval><probeTimer>5</probeTimer><pimJoinPruneInterval>60</pimJoinPruneInterval><pimEnable>0</pimEnable><sptThreshold>0</sptThreshold></pimGlobal>
</xos-module-pim>
<xos-module-poe version="3.0.0.2">
<pseSystem><systemSurplusPower>0</systemSurplusPower><systemAdminEnable>0</systemAdminEnable><systemSurplusPowerRedun>0</systemSurplusPowerRedun><systemDisconnectPrecedence>0</systemDisconnectPrecedence><systemUsageThreshold>70</systemUsageThreshold></pseSystem>
</xos-module-poe>
<xos-module-rip version="3.0.0.2">
<rip2Conf><rip2VrId/><rip2TriggeredUpdtStatus>1</rip2TriggeredUpdtStatus><rip2AggregationStatus>0</rip2AggregationStatus><rip2OperStatusCause>0</rip2OperStatusCause><rip2OperStatus>0</rip2OperStatus><rip2GarbageTimeInterval>120</rip2GarbageTimeInterval><rip2RouteTimeoutInterval>180</rip2RouteTimeoutInterval><rip2AdminStatus>0</rip2AdminStatus><rip2OriginateDefaultTag>0</rip2OriginateDefaultTag><rip2OriginateDefaultMetric>0</rip2OriginateDefaultMetric><rip2OriginateDefaultType>0</rip2OriginateDefaultType><rip2UpdateTimeInterval>30</rip2UpdateTimeInterval><rip2SysImportPolicyState>0</rip2SysImportPolicyState><rip2SysImportPolicyName/><rip2IPRouterAlertStatus>1</rip2IPRouterAlertStatus><rip2PoisonReverseStatus>1</rip2PoisonReverseStatus><rip2SplitHorizonStatus>1</rip2SplitHorizonStatus></rip2Conf>
<rip2ExportConf><rip2ExportProtoName><![CDATA[Direct]]></rip2ExportProtoName><rip2ExportShutDownPriority>2048</rip2ExportShutDownPriority><rip2ExportOperStatus>0</rip2ExportOperStatus><rip2ExportTag>0</rip2ExportTag><rip2ExportAdminStatus>0</rip2ExportAdminStatus><rip2ExportOperStatusCause>0</rip2ExportOperStatusCause><rip2ExportMetric>0</rip2ExportMetric></rip2ExportConf>
<rip2ExportConf><rip2ExportProtoName><![CDATA[Static]]></rip2ExportProtoName><rip2ExportShutDownPriority>2048</rip2ExportShutDownPriority><rip2ExportOperStatus>0</rip2ExportOperStatus><rip2ExportTag>0</rip2ExportTag><rip2ExportAdminStatus>0</rip2ExportAdminStatus><rip2ExportOperStatusCause>0</rip2ExportOperStatusCause><rip2ExportMetric>0</rip2ExportMetric></rip2ExportConf>
<rip2ExportConf><rip2ExportProtoName><![CDATA[OSPFIntra]]></rip2ExportProtoName><rip2ExportShutDownPriority>2048</rip2ExportShutDownPriority><rip2ExportOperStatus>0</rip2ExportOperStatus><rip2ExportTag>0</rip2ExportTag><rip2ExportAdminStatus>0</rip2ExportAdminStatus><rip2ExportOperStatusCause>0</rip2ExportOperStatusCause><rip2ExportMetric>0</rip2ExportMetric></rip2ExportConf>
<rip2ExportConf><rip2ExportProtoName><![CDATA[OSPFInter]]></rip2ExportProtoName><rip2ExportShutDownPriority>2048</rip2ExportShutDownPriority><rip2ExportOperStatus>0</rip2ExportOperStatus><rip2ExportTag>0</rip2ExportTag><rip2ExportAdminStatus>0</rip2ExportAdminStatus><rip2ExportOperStatusCause>0</rip2ExportOperStatusCause><rip2ExportMetric>0</rip2ExportMetric></rip2ExportConf>
<rip2ExportConf><rip2ExportProtoName><![CDATA[OSPFExt1]]></rip2ExportProtoName><rip2ExportShutDownPriority>2048</rip2ExportShutDownPriority><rip2ExportOperStatus>0</rip2ExportOperStatus><rip2ExportTag>0</rip2ExportTag><rip2ExportAdminStatus>0</rip2ExportAdminStatus><rip2ExportOperStatusCause>0</rip2ExportOperStatusCause><rip2ExportMetric>0</rip2ExportMetric></rip2ExportConf>
<rip2ExportConf><rip2ExportProtoName><![CDATA[OSPFExt2]]></rip2ExportProtoName><rip2ExportShutDownPriority>2048</rip2ExportShutDownPriority><rip2ExportOperStatus>0</rip2ExportOperStatus><rip2ExportTag>0</rip2ExportTag><rip2ExportAdminStatus>0</rip2ExportAdminStatus><rip2ExportOperStatusCause>0</rip2ExportOperStatusCause><rip2ExportMetric>0</rip2ExportMetric></rip2ExportConf>
<rip2ExportConf><rip2ExportProtoName><![CDATA[E-BGP]]></rip2ExportProtoName><rip2ExportShutDownPriority>2048</rip2ExportShutDownPriority><rip2ExportOperStatus>0</rip2ExportOperStatus><rip2ExportTag>0</rip2ExportTag><rip2ExportAdminStatus>0</rip2ExportAdminStatus><rip2ExportOperStatusCause>0</rip2ExportOperStatusCause><rip2ExportMetric>0</rip2ExportMetric></rip2ExportConf>
<rip2ExportConf><rip2ExportProtoName><![CDATA[I-BGP]]></rip2ExportProtoName><rip2ExportShutDownPriority>2048</rip2ExportShutDownPriority><rip2ExportOperStatus>0</rip2ExportOperStatus><rip2ExportTag>0</rip2ExportTag><rip2ExportAdminStatus>0</rip2ExportAdminStatus><rip2ExportOperStatusCause>0</rip2ExportOperStatusCause><rip2ExportMetric>0</rip2ExportMetric></rip2ExportConf>
</xos-module-rip>
<xos-module-ripng version="3.0.0.1">
<ripngGlobal><ripngOperStatusCause>0</ripngOperStatusCause><ripngOperStatus>0</ripngOperStatus><ripngOriginateDefaultTag>0</ripngOriginateDefaultTag><ripngUpdateTimeInterval>30</ripngUpdateTimeInterval><ripngRouteTimeoutInterval>180</ripngRouteTimeoutInterval><ripngAggregationStatus>0</ripngAggregationStatus><ripngSysImportPolicyName/><ripngHoldDownTimeInterval>0</ripngHoldDownTimeInterval><ripngOriginateDefaultType>0</ripngOriginateDefaultType><ripngSysImportPolicyState>0</ripngSysImportPolicyState><ripngAdminStatus>0</ripngAdminStatus><ripngGarbageTimeInterval>120</ripngGarbageTimeInterval><ripngOriginateDefaultMetric>0</ripngOriginateDefaultMetric><ripngTotalAggregPfix>0</ripngTotalAggregPfix></ripngGlobal>
<ripngExportConf><ripngExportProtoName><![CDATA[Direct]]></ripngExportProtoName><ripngExportMetric>0</ripngExportMetric><ripngExportPolicyName><![CDATA[none]]></ripngExportPolicyName><ripngExportShutDownPriority>0</ripngExportShutDownPriority><ripngExportTag>0</ripngExportTag><ripngExportOperStatus>0</ripngExportOperStatus><ripngExportOperStatusCause>0</ripngExportOperStatusCause><ripngExportAdminStatus>0</ripngExportAdminStatus></ripngExportConf>
<ripngExportConf><ripngExportProtoName><![CDATA[Static]]></ripngExportProtoName><ripngExportMetric>0</ripngExportMetric><ripngExportPolicyName><![CDATA[none]]></ripngExportPolicyName><ripngExportShutDownPriority>0</ripngExportShutDownPriority><ripngExportTag>0</ripngExportTag><ripngExportOperStatus>0</ripngExportOperStatus><ripngExportOperStatusCause>0</ripngExportOperStatusCause><ripngExportAdminStatus>0</ripngExportAdminStatus></ripngExportConf>
<ripngExportConf><ripngExportProtoName><![CDATA[Ospfv3-intra]]></ripngExportProtoName><ripngExportMetric>0</ripngExportMetric><ripngExportPolicyName><![CDATA[none]]></ripngExportPolicyName><ripngExportShutDownPriority>0</ripngExportShutDownPriority><ripngExportTag>0</ripngExportTag><ripngExportOperStatus>0</ripngExportOperStatus><ripngExportOperStatusCause>0</ripngExportOperStatusCause><ripngExportAdminStatus>0</ripngExportAdminStatus></ripngExportConf>
<ripngExportConf><ripngExportProtoName><![CDATA[Ospfv3-inter]]></ripngExportProtoName><ripngExportMetric>0</ripngExportMetric><ripngExportPolicyName><![CDATA[none]]></ripngExportPolicyName><ripngExportShutDownPriority>0</ripngExportShutDownPriority><ripngExportTag>0</ripngExportTag><ripngExportOperStatus>0</ripngExportOperStatus><ripngExportOperStatusCause>0</ripngExportOperStatusCause><ripngExportAdminStatus>0</ripngExportAdminStatus></ripngExportConf>
<ripngExportConf><ripngExportProtoName><![CDATA[Ospfv3-extern1]]></ripngExportProtoName><ripngExportMetric>0</ripngExportMetric><ripngExportPolicyName><![CDATA[none]]></ripngExportPolicyName><ripngExportShutDownPriority>0</ripngExportShutDownPriority><ripngExportTag>0</ripngExportTag><ripngExportOperStatus>0</ripngExportOperStatus><ripngExportOperStatusCause>0</ripngExportOperStatusCause><ripngExportAdminStatus>0</ripngExportAdminStatus></ripngExportConf>
<ripngExportConf><ripngExportProtoName><![CDATA[Ospfv3-extern2]]></ripngExportProtoName><ripngExportMetric>0</ripngExportMetric><ripngExportPolicyName><![CDATA[none]]></ripngExportPolicyName><ripngExportShutDownPriority>0</ripngExportShutDownPriority><ripngExportTag>0</ripngExportTag><ripngExportOperStatus>0</ripngExportOperStatus><ripngExportOperStatusCause>0</ripngExportOperStatusCause><ripngExportAdminStatus>0</ripngExportAdminStatus></ripngExportConf>
</xos-module-ripng>
<xos-module-rtmgr version="4.0.0.2">
<ipRouteSharing><enabled>0</enabled></ipRouteSharing>
<ipRoutePri><protocol><![CDATA[Direct]]></protocol><pri>10</pri></ipRoutePri>
<ipRoutePri><protocol><![CDATA[Blackhole]]></protocol><pri>50</pri></ipRoutePri>
<ipRoutePri><protocol><![CDATA[Static]]></protocol><pri>1100</pri></ipRoutePri>
<ipRoutePri><protocol><![CDATA[ICMP]]></protocol><pri>1200</pri></ipRoutePri>
<ipRoutePri><protocol><![CDATA[EBGP]]></protocol><pri>1700</pri></ipRoutePri>
<ipRoutePri><protocol><![CDATA[IBGP]]></protocol><pri>1900</pri></ipRoutePri>
<ipRoutePri><protocol><![CDATA[OSPFIntra]]></protocol><pri>2200</pri></ipRoutePri>
<ipRoutePri><protocol><![CDATA[OSPFInter]]></protocol><pri>2300</pri></ipRoutePri>
<ipRoutePri><protocol><![CDATA[RIP]]></protocol><pri>2400</pri></ipRoutePri>
<ipRoutePri><protocol><![CDATA[OSPFAsExt]]></protocol><pri>3100</pri></ipRoutePri>
<ipRoutePri><protocol><![CDATA[OSPFExt1]]></protocol><pri>3200</pri></ipRoutePri>
<ipRoutePri><protocol><![CDATA[OSPFExt2]]></protocol><pri>3300</pri></ipRoutePri>
<ipRoutePri><protocol><![CDATA[Bootp]]></protocol><pri>5000</pri></ipRoutePri>
<ip6RoutePri><protocol><![CDATA[Direct]]></protocol><pri>10</pri></ip6RoutePri>
<ip6RoutePri><protocol><![CDATA[Blackhole]]></protocol><pri>50</pri></ip6RoutePri>
<ip6RoutePri><protocol><![CDATA[Static]]></protocol><pri>1100</pri></ip6RoutePri>
<ip6RoutePri><protocol><![CDATA[ICMP]]></protocol><pri>1200</pri></ip6RoutePri>
<ip6RoutePri><protocol><![CDATA[OSPFv3Intra]]></protocol><pri>2200</pri></ip6RoutePri>
<ip6RoutePri><protocol><![CDATA[OSPFv3Inter]]></protocol><pri>2300</pri></ip6RoutePri>
<ip6RoutePri><protocol><![CDATA[RIPng]]></protocol><pri>2400</pri></ip6RoutePri>
<ip6RoutePri><protocol><![CDATA[OSPFv3AsExt]]></protocol><pri>3100</pri></ip6RoutePri>
<ip6RoutePri><protocol><![CDATA[OSPFv3Ext1]]></protocol><pri>3200</pri></ip6RoutePri>
<ip6RoutePri><protocol><![CDATA[OSPFv3Ext2]]></protocol><pri>3300</pri></ip6RoutePri>
<irdpConfig><lifetime>1800</lifetime><maxinterval>600</maxinterval><mcast>0</mcast><preference>0</preference><mininterval>450</mininterval></irdpConfig>
<irdp><vlan><![CDATA[Default]]></vlan><enabled>0</enabled></irdp>
<icmp><vlan><![CDATA[Default]]></vlan><icmpTimeExceeded>1</icmpTimeExceeded><icmpRedirects>1</icmpRedirects><icmpUnreachables>1</icmpUnreachables><icmpParamProblem>1</icmpParamProblem><icmpTimeStamp>0</icmpTimeStamp><icmpPortUnreachables>1</icmpPortUnreachables><icmpAddressMask>0</icmpAddressMask></icmp>
<ipOption><routerAlert>1</routerAlert><looseSourceRoute>1</looseSourceRoute><recordRoute>1</recordRoute><recordTimestamp>1</recordTimestamp><strictSourceRoute>1</strictSourceRoute></ipOption>
<ipRouteEntry><ipRouteMetric1>1</ipRouteMetric1><vrName><![CDATA[VR-Default]]></vrName><ipRouteProto>3</ipRouteProto><ipRouteNextHop>10.100.26.2</ipRouteNextHop><ipRouteMask>0.0.0.0</ipRouteMask><ipRouteDest>0.0.0.0</ipRouteDest><unicastonly>0</unicastonly><multicastonly>0</multicastonly></ipRouteEntry>
<ipRouteEntry><ipRouteMetric1>1</ipRouteMetric1><vrName><![CDATA[VR-Default]]></vrName><ipRouteProto>3</ipRouteProto><ipRouteNextHop>192.168.5.1</ipRouteNextHop><ipRouteMask>0.0.0.0</ipRouteMask><ipRouteDest>0.0.0.0</ipRouteDest><unicastonly>0</unicastonly><multicastonly>0</multicastonly></ipRouteEntry>
<ipBrForward><vlan><![CDATA[Default]]></vlan><ignoreEnabled>0</ignoreEnabled><enabled>0</enabled><fastEnabled>0</fastEnabled></ipBrForward>
<icmpUseRedirects><enabled>0</enabled></icmpUseRedirects>
</xos-module-rtmgr>
<xos-module-snmpMaster version="3.0.0.2">
<snmpEngineCLI><snmpEngineID>03:00:04:96:20:ac:d4</snmpEngineID></snmpEngineCLI>
<usmUserEntryCLI><usmUserName>61:64:6d:69:6e</usmUserName><usmUserStorageType>4</usmUserStorageType><numUsers>6</numUsers><usmUserAuthProtocol>1.3.6.1.6.3.10.1.1.2</usmUserAuthProtocol><priv_secret>f4:f5:09:ec:4a:d6:69:23:0c:40:9d:cc:2b:e2:ec:64</priv_secret><usmUserPrivProtocol>1.3.6.1.6.3.10.1.2.2</usmUserPrivProtocol><auth_secret>f4:f5:09:ec:4a:d6:69:23:0c:40:9d:cc:2b:e2:ec:64</auth_secret><usmUserEngineID>80:00:07:7c:03:00:04:96:20:ac:d4</usmUserEngineID></usmUserEntryCLI>
<usmUserEntryCLI><usmUserName>69:6e:69:74:69:61:6c</usmUserName><usmUserStorageType>4</usmUserStorageType><numUsers>6</numUsers><usmUserAuthProtocol>1.3.6.1.6.3.10.1.1.1</usmUserAuthProtocol><usmUserPrivProtocol>1.3.6.1.6.3.10.1.2.1</usmUserPrivProtocol><usmUserEngineID>80:00:07:7c:03:00:04:96:20:ac:d4</usmUserEngineID></usmUserEntryCLI>
<usmUserEntryCLI><usmUserName>69:6e:69:74:69:61:6c:6d:64:35</usmUserName><usmUserStorageType>4</usmUserStorageType><numUsers>6</numUsers><usmUserAuthProtocol>1.3.6.1.6.3.10.1.1.2</usmUserAuthProtocol><usmUserPrivProtocol>1.3.6.1.6.3.10.1.2.1</usmUserPrivProtocol><auth_secret>e5:de:25:c4:79:5f:c4:97:92:df:ef:18:f0:f5:16:8d</auth_secret><usmUserEngineID>80:00:07:7c:03:00:04:96:20:ac:d4</usmUserEngineID></usmUserEntryCLI>
<usmUserEntryCLI><usmUserName>69:6e:69:74:69:61:6c:73:68:61</usmUserName><usmUserStorageType>4</usmUserStorageType><numUsers>6</numUsers><usmUserAuthProtocol>1.3.6.1.6.3.10.1.1.3</usmUserAuthProtocol><usmUserPrivProtocol>1.3.6.1.6.3.10.1.2.1</usmUserPrivProtocol><auth_secret>67:fb:c3:b0:42:00:52:10:96:3b:b1:e1:22:c0:09:83:58:93:ea:13</auth_secret><usmUserEngineID>80:00:07:7c:03:00:04:96:20:ac:d4</usmUserEngineID></usmUserEntryCLI>
<usmUserEntryCLI><usmUserName>69:6e:69:74:69:61:6c:6d:64:35:50:72:69:76</usmUserName><usmUserStorageType>4</usmUserStorageType><numUsers>6</numUsers><usmUserAuthProtocol>1.3.6.1.6.3.10.1.1.2</usmUserAuthProtocol><priv_secret>95:f3:ea:88:93:ea:0c:8c:a4:73:b0:fe:31:23:fd:d5</priv_secret><usmUserPrivProtocol>1.3.6.1.6.3.10.1.2.2</usmUserPrivProtocol><auth_secret>95:f3:ea:88:93:ea:0c:8c:a4:73:b0:fe:31:23:fd:d5</auth_secret><usmUserEngineID>80:00:07:7c:03:00:04:96:20:ac:d4</usmUserEngineID></usmUserEntryCLI>
<usmUserEntryCLI><usmUserName>69:6e:69:74:69:61:6c:73:68:61:50:72:69:76</usmUserName><usmUserStorageType>4</usmUserStorageType><numUsers>6</numUsers><usmUserAuthProtocol>1.3.6.1.6.3.10.1.1.3</usmUserAuthProtocol><priv_secret>0f:45:75:72:2d:e2:29:54:84:96:a5:ea:cf:62:7b:35:24:7b:6e:40</priv_secret><usmUserPrivProtocol>1.3.6.1.6.3.10.1.2.2</usmUserPrivProtocol><auth_secret>0f:45:75:72:2d:e2:29:54:84:96:a5:ea:cf:62:7b:35:24:7b:6e:40</auth_secret><usmUserEngineID>80:00:07:7c:03:00:04:96:20:ac:d4</usmUserEngineID></usmUserEntryCLI>
<vacmSecurityToGroupEntryCLI><vacmSecurityToGroupStatus>1</vacmSecurityToGroupStatus><numGroups>10</numGroups><vacmSecurityModel>1</vacmSecurityModel><vacmSecurityToGroupStorageType>4</vacmSecurityToGroupStorageType><vacmGroupName>76:31:76:32:63:5f:72:6f</vacmGroupName><vacmSecurityName>76:31:76:32:63:5f:72:6f</vacmSecurityName></vacmSecurityToGroupEntryCLI>
<vacmSecurityToGroupEntryCLI><vacmSecurityToGroupStatus>1</vacmSecurityToGroupStatus><numGroups>10</numGroups><vacmSecurityModel>1</vacmSecurityModel><vacmSecurityToGroupStorageType>4</vacmSecurityToGroupStorageType><vacmGroupName>76:31:76:32:63:5f:72:77</vacmGroupName><vacmSecurityName>76:31:76:32:63:5f:72:77</vacmSecurityName></vacmSecurityToGroupEntryCLI>
<vacmSecurityToGroupEntryCLI><vacmSecurityToGroupStatus>1</vacmSecurityToGroupStatus><numGroups>10</numGroups><vacmSecurityModel>2</vacmSecurityModel><vacmSecurityToGroupStorageType>4</vacmSecurityToGroupStorageType><vacmGroupName>76:31:76:32:63:5f:72:6f</vacmGroupName><vacmSecurityName>76:31:76:32:63:5f:72:6f</vacmSecurityName></vacmSecurityToGroupEntryCLI>
<vacmSecurityToGroupEntryCLI><vacmSecurityToGroupStatus>1</vacmSecurityToGroupStatus><numGroups>10</numGroups><vacmSecurityModel>2</vacmSecurityModel><vacmSecurityToGroupStorageType>4</vacmSecurityToGroupStorageType><vacmGroupName>76:31:76:32:63:5f:72:77</vacmGroupName><vacmSecurityName>76:31:76:32:63:5f:72:77</vacmSecurityName></vacmSecurityToGroupEntryCLI>
<vacmSecurityToGroupEntryCLI><vacmSecurityToGroupStatus>1</vacmSecurityToGroupStatus><numGroups>10</numGroups><vacmSecurityModel>3</vacmSecurityModel><vacmSecurityToGroupStorageType>4</vacmSecurityToGroupStorageType><vacmGroupName>61:64:6d:69:6e</vacmGroupName><vacmSecurityName>61:64:6d:69:6e</vacmSecurityName></vacmSecurityToGroupEntryCLI>
<vacmSecurityToGroupEntryCLI><vacmSecurityToGroupStatus>1</vacmSecurityToGroupStatus><numGroups>10</numGroups><vacmSecurityModel>3</vacmSecurityModel><vacmSecurityToGroupStorageType>4</vacmSecurityToGroupStorageType><vacmGroupName>69:6e:69:74:69:61:6c</vacmGroupName><vacmSecurityName>69:6e:69:74:69:61:6c</vacmSecurityName></vacmSecurityToGroupEntryCLI>
<vacmSecurityToGroupEntryCLI><vacmSecurityToGroupStatus>1</vacmSecurityToGroupStatus><numGroups>10</numGroups><vacmSecurityModel>3</vacmSecurityModel><vacmSecurityToGroupStorageType>4</vacmSecurityToGroupStorageType><vacmGroupName>69:6e:69:74:69:61:6c</vacmGroupName><vacmSecurityName>69:6e:69:74:69:61:6c:6d:64:35</vacmSecurityName></vacmSecurityToGroupEntryCLI>
<vacmSecurityToGroupEntryCLI><vacmSecurityToGroupStatus>1</vacmSecurityToGroupStatus><numGroups>10</numGroups><vacmSecurityModel>3</vacmSecurityModel><vacmSecurityToGroupStorageType>4</vacmSecurityToGroupStorageType><vacmGroupName>69:6e:69:74:69:61:6c</vacmGroupName><vacmSecurityName>69:6e:69:74:69:61:6c:73:68:61</vacmSecurityName></vacmSecurityToGroupEntryCLI>
<vacmSecurityToGroupEntryCLI><vacmSecurityToGroupStatus>1</vacmSecurityToGroupStatus><numGroups>10</numGroups><vacmSecurityModel>3</vacmSecurityModel><vacmSecurityToGroupStorageType>4</vacmSecurityToGroupStorageType><vacmGroupName>69:6e:69:74:69:61:6c</vacmGroupName><vacmSecurityName>69:6e:69:74:69:61:6c:6d:64:35:50:72:69:76</vacmSecurityName></vacmSecurityToGroupEntryCLI>
<vacmSecurityToGroupEntryCLI><vacmSecurityToGroupStatus>1</vacmSecurityToGroupStatus><numGroups>10</numGroups><vacmSecurityModel>3</vacmSecurityModel><vacmSecurityToGroupStorageType>4</vacmSecurityToGroupStorageType><vacmGroupName>69:6e:69:74:69:61:6c</vacmGroupName><vacmSecurityName>69:6e:69:74:69:61:6c:73:68:61:50:72:69:76</vacmSecurityName></vacmSecurityToGroupEntryCLI>
<vacmAccessEntryCLI><vacmGroupName>61:64:6d:69:6e</vacmGroupName><vacmAccessContextPrefix></vacmAccessContextPrefix><vacmAccessStorageType>4</vacmAccessStorageType><vacmAccessSecurityModel>3</vacmAccessSecurityModel><vacmAccessContextMatch>1</vacmAccessContextMatch><vacmAccessWriteViewName>64:65:66:61:75:6c:74:41:64:6d:69:6e:56:69:65:77</vacmAccessWriteViewName><numAccess>9</numAccess><vacmAccessReadViewName>64:65:66:61:75:6c:74:41:64:6d:69:6e:56:69:65:77</vacmAccessReadViewName><vacmAccessSecurityLevel>3</vacmAccessSecurityLevel><vacmAccessNotifyViewName>64:65:66:61:75:6c:74:4e:6f:74:69:66:79:56:69:65:77</vacmAccessNotifyViewName><vacmAccessStatus>1</vacmAccessStatus></vacmAccessEntryCLI>
<vacmAccessEntryCLI><vacmGroupName>69:6e:69:74:69:61:6c</vacmGroupName><vacmAccessContextPrefix></vacmAccessContextPrefix><vacmAccessStorageType>4</vacmAccessStorageType><vacmAccessSecurityModel>3</vacmAccessSecurityModel><vacmAccessContextMatch>1</vacmAccessContextMatch><vacmAccessWriteViewName></vacmAccessWriteViewName><numAccess>9</numAccess><vacmAccessReadViewName>64:65:66:61:75:6c:74:55:73:65:72:56:69:65:77</vacmAccessReadViewName><vacmAccessSecurityLevel>1</vacmAccessSecurityLevel><vacmAccessNotifyViewName>64:65:66:61:75:6c:74:4e:6f:74:69:66:79:56:69:65:77</vacmAccessNotifyViewName><vacmAccessStatus>1</vacmAccessStatus></vacmAccessEntryCLI>
<vacmAccessEntryCLI><vacmGroupName>69:6e:69:74:69:61:6c</vacmGroupName><vacmAccessContextPrefix></vacmAccessContextPrefix><vacmAccessStorageType>4</vacmAccessStorageType><vacmAccessSecurityModel>3</vacmAccessSecurityModel><vacmAccessContextMatch>1</vacmAccessContextMatch><vacmAccessWriteViewName>64:65:66:61:75:6c:74:55:73:65:72:56:69:65:77</vacmAccessWriteViewName><numAccess>9</numAccess><vacmAccessReadViewName>64:65:66:61:75:6c:74:55:73:65:72:56:69:65:77</vacmAccessReadViewName><vacmAccessSecurityLevel>2</vacmAccessSecurityLevel><vacmAccessNotifyViewName>64:65:66:61:75:6c:74:4e:6f:74:69:66:79:56:69:65:77</vacmAccessNotifyViewName><vacmAccessStatus>1</vacmAccessStatus></vacmAccessEntryCLI>
<vacmAccessEntryCLI><vacmGroupName>76:31:76:32:63:5f:72:6f</vacmGroupName><vacmAccessContextPrefix></vacmAccessContextPrefix><vacmAccessStorageType>4</vacmAccessStorageType><vacmAccessSecurityModel>1</vacmAccessSecurityModel><vacmAccessContextMatch>1</vacmAccessContextMatch><vacmAccessWriteViewName></vacmAccessWriteViewName><numAccess>9</numAccess><vacmAccessReadViewName>64:65:66:61:75:6c:74:55:73:65:72:56:69:65:77</vacmAccessReadViewName><vacmAccessSecurityLevel>1</vacmAccessSecurityLevel><vacmAccessNotifyViewName>64:65:66:61:75:6c:74:4e:6f:74:69:66:79:56:69:65:77</vacmAccessNotifyViewName><vacmAccessStatus>1</vacmAccessStatus></vacmAccessEntryCLI>
<vacmAccessEntryCLI><vacmGroupName>76:31:76:32:63:5f:72:6f</vacmGroupName><vacmAccessContextPrefix></vacmAccessContextPrefix><vacmAccessStorageType>4</vacmAccessStorageType><vacmAccessSecurityModel>2</vacmAccessSecurityModel><vacmAccessContextMatch>1</vacmAccessContextMatch><vacmAccessWriteViewName></vacmAccessWriteViewName><numAccess>9</numAccess><vacmAccessReadViewName>64:65:66:61:75:6c:74:55:73:65:72:56:69:65:77</vacmAccessReadViewName><vacmAccessSecurityLevel>1</vacmAccessSecurityLevel><vacmAccessNotifyViewName>64:65:66:61:75:6c:74:4e:6f:74:69:66:79:56:69:65:77</vacmAccessNotifyViewName><vacmAccessStatus>1</vacmAccessStatus></vacmAccessEntryCLI>
<vacmAccessEntryCLI><vacmGroupName>76:31:76:32:63:5f:72:77</vacmGroupName><vacmAccessContextPrefix></vacmAccessContextPrefix><vacmAccessStorageType>4</vacmAccessStorageType><vacmAccessSecurityModel>1</vacmAccessSecurityModel><vacmAccessContextMatch>1</vacmAccessContextMatch><vacmAccessWriteViewName>64:65:66:61:75:6c:74:55:73:65:72:56:69:65:77</vacmAccessWriteViewName><numAccess>9</numAccess><vacmAccessReadViewName>64:65:66:61:75:6c:74:55:73:65:72:56:69:65:77</vacmAccessReadViewName><vacmAccessSecurityLevel>1</vacmAccessSecurityLevel><vacmAccessNotifyViewName>64:65:66:61:75:6c:74:4e:6f:74:69:66:79:56:69:65:77</vacmAccessNotifyViewName><vacmAccessStatus>1</vacmAccessStatus></vacmAccessEntryCLI>
<vacmAccessEntryCLI><vacmGroupName>76:31:76:32:63:5f:72:77</vacmGroupName><vacmAccessContextPrefix></vacmAccessContextPrefix><vacmAccessStorageType>4</vacmAccessStorageType><vacmAccessSecurityModel>2</vacmAccessSecurityModel><vacmAccessContextMatch>1</vacmAccessContextMatch><vacmAccessWriteViewName>64:65:66:61:75:6c:74:55:73:65:72:56:69:65:77</vacmAccessWriteViewName><numAccess>9</numAccess><vacmAccessReadViewName>64:65:66:61:75:6c:74:55:73:65:72:56:69:65:77</vacmAccessReadViewName><vacmAccessSecurityLevel>1</vacmAccessSecurityLevel><vacmAccessNotifyViewName>64:65:66:61:75:6c:74:4e:6f:74:69:66:79:56:69:65:77</vacmAccessNotifyViewName><vacmAccessStatus>1</vacmAccessStatus></vacmAccessEntryCLI>
<vacmAccessEntryCLI><vacmGroupName>76:31:76:32:63:4e:6f:74:69:66:79:47:72:6f:75:70</vacmGroupName><vacmAccessContextPrefix></vacmAccessContextPrefix><vacmAccessStorageType>4</vacmAccessStorageType><vacmAccessSecurityModel>1</vacmAccessSecurityModel><vacmAccessContextMatch>1</vacmAccessContextMatch><vacmAccessWriteViewName></vacmAccessWriteViewName><numAccess>9</numAccess><vacmAccessReadViewName></vacmAccessReadViewName><vacmAccessSecurityLevel>1</vacmAccessSecurityLevel><vacmAccessNotifyViewName>64:65:66:61:75:6c:74:4e:6f:74:69:66:79:56:69:65:77</vacmAccessNotifyViewName><vacmAccessStatus>1</vacmAccessStatus></vacmAccessEntryCLI>
<vacmAccessEntryCLI><vacmGroupName>76:31:76:32:63:4e:6f:74:69:66:79:47:72:6f:75:70</vacmGroupName><vacmAccessContextPrefix></vacmAccessContextPrefix><vacmAccessStorageType>4</vacmAccessStorageType><vacmAccessSecurityModel>2</vacmAccessSecurityModel><vacmAccessContextMatch>1</vacmAccessContextMatch><vacmAccessWriteViewName></vacmAccessWriteViewName><numAccess>9</numAccess><vacmAccessReadViewName></vacmAccessReadViewName><vacmAccessSecurityLevel>1</vacmAccessSecurityLevel><vacmAccessNotifyViewName>64:65:66:61:75:6c:74:4e:6f:74:69:66:79:56:69:65:77</vacmAccessNotifyViewName><vacmAccessStatus>1</vacmAccessStatus></vacmAccessEntryCLI>
<vacmViewTreeFamilyEntryCLI><vacmViewTreeFamilyStorageType>4</vacmViewTreeFamilyStorageType><vacmViewTreeFamilyType>1</vacmViewTreeFamilyType><vacmViewTreeFamilyStatus>1</vacmViewTreeFamilyStatus><vacmViewTreeFamilyViewName>64:65:66:61:75:6c:74:55:73:65:72:56:69:65:77</vacmViewTreeFamilyViewName><numViews>8</numViews><vacmViewTreeFamilySubtree>1</vacmViewTreeFamilySubtree><vacmViewTreeFamilyMask></vacmViewTreeFamilyMask></vacmViewTreeFamilyEntryCLI>
<vacmViewTreeFamilyEntryCLI><vacmViewTreeFamilyStorageType>4</vacmViewTreeFamilyStorageType><vacmViewTreeFamilyType>2</vacmViewTreeFamilyType><vacmViewTreeFamilyStatus>1</vacmViewTreeFamilyStatus><vacmViewTreeFamilyViewName>64:65:66:61:75:6c:74:55:73:65:72:56:69:65:77</vacmViewTreeFamilyViewName><numViews>8</numViews><vacmViewTreeFamilySubtree>1.3.6.1.6.3.16</vacmViewTreeFamilySubtree><vacmViewTreeFamilyMask></vacmViewTreeFamilyMask></vacmViewTreeFamilyEntryCLI>
<vacmViewTreeFamilyEntryCLI><vacmViewTreeFamilyStorageType>4</vacmViewTreeFamilyStorageType><vacmViewTreeFamilyType>2</vacmViewTreeFamilyType><vacmViewTreeFamilyStatus>1</vacmViewTreeFamilyStatus><vacmViewTreeFamilyViewName>64:65:66:61:75:6c:74:55:73:65:72:56:69:65:77</vacmViewTreeFamilyViewName><numViews>8</numViews><vacmViewTreeFamilySubtree>1.3.6.1.6.3.18</vacmViewTreeFamilySubtree><vacmViewTreeFamilyMask></vacmViewTreeFamilyMask></vacmViewTreeFamilyEntryCLI>
<vacmViewTreeFamilyEntryCLI><vacmViewTreeFamilyStorageType>4</vacmViewTreeFamilyStorageType><vacmViewTreeFamilyType>2</vacmViewTreeFamilyType><vacmViewTreeFamilyStatus>1</vacmViewTreeFamilyStatus><vacmViewTreeFamilyViewName>64:65:66:61:75:6c:74:55:73:65:72:56:69:65:77</vacmViewTreeFamilyViewName><numViews>8</numViews><vacmViewTreeFamilySubtree>1.3.6.1.6.3.15.1.2.2.1.4</vacmViewTreeFamilySubtree><vacmViewTreeFamilyMask></vacmViewTreeFamilyMask></vacmViewTreeFamilyEntryCLI>
<vacmViewTreeFamilyEntryCLI><vacmViewTreeFamilyStorageType>4</vacmViewTreeFamilyStorageType><vacmViewTreeFamilyType>2</vacmViewTreeFamilyType><vacmViewTreeFamilyStatus>1</vacmViewTreeFamilyStatus><vacmViewTreeFamilyViewName>64:65:66:61:75:6c:74:55:73:65:72:56:69:65:77</vacmViewTreeFamilyViewName><numViews>8</numViews><vacmViewTreeFamilySubtree>1.3.6.1.6.3.15.1.2.2.1.6</vacmViewTreeFamilySubtree><vacmViewTreeFamilyMask></vacmViewTreeFamilyMask></vacmViewTreeFamilyEntryCLI>
<vacmViewTreeFamilyEntryCLI><vacmViewTreeFamilyStorageType>4</vacmViewTreeFamilyStorageType><vacmViewTreeFamilyType>2</vacmViewTreeFamilyType><vacmViewTreeFamilyStatus>1</vacmViewTreeFamilyStatus><vacmViewTreeFamilyViewName>64:65:66:61:75:6c:74:55:73:65:72:56:69:65:77</vacmViewTreeFamilyViewName><numViews>8</numViews><vacmViewTreeFamilySubtree>1.3.6.1.6.3.15.1.2.2.1.9</vacmViewTreeFamilySubtree><vacmViewTreeFamilyMask></vacmViewTreeFamilyMask></vacmViewTreeFamilyEntryCLI>
<vacmViewTreeFamilyEntryCLI><vacmViewTreeFamilyStorageType>4</vacmViewTreeFamilyStorageType><vacmViewTreeFamilyType>1</vacmViewTreeFamilyType><vacmViewTreeFamilyStatus>1</vacmViewTreeFamilyStatus><vacmViewTreeFamilyViewName>64:65:66:61:75:6c:74:41:64:6d:69:6e:56:69:65:77</vacmViewTreeFamilyViewName><numViews>8</numViews><vacmViewTreeFamilySubtree>1</vacmViewTreeFamilySubtree><vacmViewTreeFamilyMask></vacmViewTreeFamilyMask></vacmViewTreeFamilyEntryCLI>
<vacmViewTreeFamilyEntryCLI><vacmViewTreeFamilyStorageType>4</vacmViewTreeFamilyStorageType><vacmViewTreeFamilyType>1</vacmViewTreeFamilyType><vacmViewTreeFamilyStatus>1</vacmViewTreeFamilyStatus><vacmViewTreeFamilyViewName>64:65:66:61:75:6c:74:4e:6f:74:69:66:79:56:69:65:77</vacmViewTreeFamilyViewName><numViews>8</numViews><vacmViewTreeFamilySubtree>1</vacmViewTreeFamilySubtree><vacmViewTreeFamilyMask></vacmViewTreeFamilyMask></vacmViewTreeFamilyEntryCLI>
<snmpCommunityEntryCLI><snmpCommunityStorageType>4</snmpCommunityStorageType><snmpCommunitySecurityName>76:31:76:32:63:5f:72:77</snmpCommunitySecurityName><snmpCommunityIndex>70:72:69:76:61:74:65</snmpCommunityIndex><snmpCommunityName>70:72:69:76:61:74:65</snmpCommunityName><snmpCommunityContextEngineID>80:00:07:7c:03:00:04:96:20:ac:d4</snmpCommunityContextEngineID><snmpCommunityStatus>1</snmpCommunityStatus><snmpCommunityContextName></snmpCommunityContextName><snmpCommunityTransportTag></snmpCommunityTransportTag><numCommunities>4</numCommunities></snmpCommunityEntryCLI>
<snmpCommunityEntryCLI><snmpCommunityStorageType>3</snmpCommunityStorageType><snmpCommunitySecurityName>76:31:76:32:63:5f:72:6f</snmpCommunitySecurityName><snmpCommunityIndex>70:75</snmpCommunityIndex><snmpCommunityName>70:75</snmpCommunityName><snmpCommunityContextEngineID>80:00:07:7c:03:00:04:96:20:ac:d4</snmpCommunityContextEngineID><snmpCommunityStatus>1</snmpCommunityStatus><snmpCommunityContextName></snmpCommunityContextName><snmpCommunityTransportTag></snmpCommunityTransportTag><numCommunities>4</numCommunities></snmpCommunityEntryCLI>
<snmpCommunityEntryCLI><snmpCommunityStorageType>4</snmpCommunityStorageType><snmpCommunitySecurityName>76:31:76:32:63:5f:72:6f</snmpCommunitySecurityName><snmpCommunityIndex>70:75:62:6c:69:63</snmpCommunityIndex><snmpCommunityName>70:75:62:6c:69:63</snmpCommunityName><snmpCommunityContextEngineID>80:00:07:7c:03:00:04:96:20:ac:d4</snmpCommunityContextEngineID><snmpCommunityStatus>1</snmpCommunityStatus><snmpCommunityContextName></snmpCommunityContextName><snmpCommunityTransportTag></snmpCommunityTransportTag><numCommunities>4</numCommunities></snmpCommunityEntryCLI>
<snmpCommunityEntryCLI><snmpCommunityStorageType>3</snmpCommunityStorageType><snmpCommunitySecurityName>76:31:76:32:63:5f:72:77</snmpCommunitySecurityName><snmpCommunityIndex>74:65:73:74:65:6e:76</snmpCommunityIndex><snmpCommunityName>74:65:73:74:65:6e:76</snmpCommunityName><snmpCommunityContextEngineID>80:00:07:7c:03:00:04:96:20:ac:d4</snmpCommunityContextEngineID><snmpCommunityStatus>1</snmpCommunityStatus><snmpCommunityContextName></snmpCommunityContextName><snmpCommunityTransportTag></snmpCommunityTransportTag><numCommunities>4</numCommunities></snmpCommunityEntryCLI>
<snmpNotifyEntryCLI><snmpNotifyName>64:65:66:61:75:6c:74:4e:6f:74:69:66:79</snmpNotifyName><snmpNotifyTag>64:65:66:61:75:6c:74:4e:6f:74:69:66:79</snmpNotifyTag><numNotifys>1</numNotifys><snmpNotifyType>1</snmpNotifyType><snmpNotifyStorageType>4</snmpNotifyStorageType><snmpNotifyRowStatus>1</snmpNotifyRowStatus></snmpNotifyEntryCLI>
<snmpEnableCLI><snmpTrapsEnabled>1</snmpTrapsEnabled><snmpEnabled>1</snmpEnabled><snmpV1V2CEnabled>1</snmpV1V2CEnabled></snmpEnableCLI>
</xos-module-snmpMaster>
<xos-module-stp version="3.0.0.21">
<stp_compatibility><ew_compatible>0</ew_compatible><hitless_failover>1</hitless_failover></stp_compatibility>
<stp_domain><stpd_name><![CDATA[s0]]></stpd_name><default_mode>1</default_mode><hello_time>2</hello_time><stpd_tag>0</stpd_tag><max_bpdu_age>20</max_bpdu_age><snmp_instance>1</snmp_instance><protocol_mode>0</protocol_mode><rapid_root_failover>0</rapid_root_failover><forward_delay>15</forward_delay><priority>32768</priority></stp_domain>
<stp_vlan_autoadd><vlan_name><![CDATA[Default]]></vlan_name><auto_add_enabled>1</auto_add_enabled><stpd_name><![CDATA[s0]]></stpd_name></stp_vlan_autoadd>
<stp_domain_enable><stpd_name><![CDATA[s0]]></stpd_name><stpd_enabled>0</stpd_enabled></stp_domain_enable>
</xos-module-stp>
<xos-module-telnetd version="3.0.0.2">
<telnetd><vrid><![CDATA[all]]></vrid><port>23</port><enable>1</enable><debug>0</debug></telnetd>
</xos-module-telnetd>
<xos-module-tftpd version="3.0.0.2">
<tftpd><port>69</port><read_write>0</read_write><enable>1</enable><debug>0</debug></tftpd>
</xos-module-tftpd>
<xos-module-thttpd version="3.0.0.1">
<thttpd><vrid><![CDATA[all]]></vrid><port>80</port><debug>0</debug></thttpd>
<thttpd_ssl></thttpd_ssl>
</xos-module-thttpd>
<xos-module-vlan version="3.1.0.2">
<vlanGlobalConfig><currVlanIfInstance>1000010</currVlanIfInstance><currVpifInstance>50000159</currVpifInstance><vManEtherType>0x88a8</vManEtherType><dot1qEtherType>0x8100</dot1qEtherType><currL3AddrInstance>0</currL3AddrInstance><globalJumboEnabled>0</globalJumboEnabled><currVlanId>4093</currVlanId><filterIndex>9</filterIndex><mirrorEnable>0</mirrorEnable></vlanGlobalConfig>
<vr><name><![CDATA[VR-Default]]></name><vrId>2</vrId><addPorts>1</addPorts><arpInspection>0</arpInspection><portListInVr>1-26</portListInVr><arpLearnDisabled>0</arpLearnDisabled><arpSecured>0</arpSecured><vrInstance>1000002</vrInstance><arpGratuitousInspection>0</arpGratuitousInspection></vr>
<vlan><ifIndex>1000004</ifIndex><name><![CDATA[Default]]></name><qosProfile>0</qosProfile><ipMtu>1500</ipMtu><arpInspection>0</arpInspection><loopback>0</loopback><arpGratuitousInspection>0</arpGratuitousInspection><vrName><![CDATA[VR-Default]]></vrName><vlanIfInstance>1000004</vlanIfInstance><tagType>1</tagType><type>2</type><tag>1</tag><loopbackMode>2</loopbackMode><tagged>1</tagged><arpLearnDisabled>0</arpLearnDisabled><ipv6Forwarding>0</ipv6Forwarding><arpSecured>0</arpSecured></vlan>
<ports><slot>1</slot><port>1</port><arpInspection>0</arpInspection><enabled>1</enabled><diffServRepEnable>0</diffServRepEnable><enable_flood>0</enable_flood><dot1pExamInnerEnable>0</dot1pExamInnerEnable><arpSecured>0</arpSecured><fdbLearning>1</fdbLearning><vrMode>0</vrMode><qosProfile>0</qosProfile><diffServEnable>0</diffServEnable><flood_mask>0</flood_mask><jumboEnabled>0</jumboEnabled><arpGratuitousInspection>0</arpGratuitousInspection><port2>1</port2><mediumPreferred>0</mediumPreferred><arpLearnDisabled>0</arpLearnDisabled><dot1pRepEnable>0</dot1pRepEnable><forcePreferred>0</forcePreferred></ports>
<ports><slot>1</slot><port>2</port><arpInspection>0</arpInspection><enabled>1</enabled><diffServRepEnable>0</diffServRepEnable><enable_flood>0</enable_flood><dot1pExamInnerEnable>0</dot1pExamInnerEnable><arpSecured>0</arpSecured><fdbLearning>1</fdbLearning><vrMode>0</vrMode><qosProfile>0</qosProfile><diffServEnable>0</diffServEnable><flood_mask>0</flood_mask><jumboEnabled>0</jumboEnabled><arpGratuitousInspection>0</arpGratuitousInspection><port2>2</port2><mediumPreferred>0</mediumPreferred><arpLearnDisabled>0</arpLearnDisabled><dot1pRepEnable>0</dot1pRepEnable><forcePreferred>0</forcePreferred></ports>
<ports><slot>1</slot><port>3</port><arpInspection>0</arpInspection><enabled>1</enabled><diffServRepEnable>0</diffServRepEnable><enable_flood>0</enable_flood><dot1pExamInnerEnable>0</dot1pExamInnerEnable><arpSecured>0</arpSecured><fdbLearning>1</fdbLearning><vrMode>0</vrMode><qosProfile>0</qosProfile><diffServEnable>0</diffServEnable><flood_mask>0</flood_mask><jumboEnabled>0</jumboEnabled><arpGratuitousInspection>0</arpGratuitousInspection><port2>3</port2><mediumPreferred>0</mediumPreferred><arpLearnDisabled>0</arpLearnDisabled><dot1pRepEnable>0</dot1pRepEnable><forcePreferred>0</forcePreferred></ports>
<ports><slot>1</slot><port>4</port><arpInspection>0</arpInspection><enabled>1</enabled><diffServRepEnable>0</diffServRepEnable><enable_flood>0</enable_flood><dot1pExamInnerEnable>0</dot1pExamInnerEnable><arpSecured>0</arpSecured><fdbLearning>1</fdbLearning><vrMode>0</vrMode><qosProfile>0</qosProfile><diffServEnable>0</diffServEnable><flood_mask>0</flood_mask><jumboEnabled>0</jumboEnabled><arpGratuitousInspection>0</arpGratuitousInspection><port2>4</port2><mediumPreferred>0</mediumPreferred><arpLearnDisabled>0</arpLearnDisabled><dot1pRepEnable>0</dot1pRepEnable><forcePreferred>0</forcePreferred></ports>
<ports><slot>1</slot><port>5</port><arpInspection>0</arpInspection><enabled>1</enabled><diffServRepEnable>0</diffServRepEnable><enable_flood>0</enable_flood><autoPolarityDisabled>0</autoPolarityDisabled><dot1pExamInnerEnable>0</dot1pExamInnerEnable><arpSecured>0</arpSecured><fdbLearning>1</fdbLearning><vrMode>0</vrMode><qosProfile>0</qosProfile><diffServEnable>0</diffServEnable><flood_mask>0</flood_mask><jumboEnabled>0</jumboEnabled><arpGratuitousInspection>0</arpGratuitousInspection><port2>5</port2><arpLearnDisabled>0</arpLearnDisabled><dot1pRepEnable>0</dot1pRepEnable></ports>
<ports><slot>1</slot><port>6</port><arpInspection>0</arpInspection><enabled>1</enabled><diffServRepEnable>0</diffServRepEnable><enable_flood>0</enable_flood><autoPolarityDisabled>0</autoPolarityDisabled><dot1pExamInnerEnable>0</dot1pExamInnerEnable><arpSecured>0</arpSecured><fdbLearning>1</fdbLearning><vrMode>0</vrMode><qosProfile>0</qosProfile><diffServEnable>0</diffServEnable><flood_mask>0</flood_mask><jumboEnabled>0</jumboEnabled><arpGratuitousInspection>0</arpGratuitousInspection><port2>6</port2><arpLearnDisabled>0</arpLearnDisabled><dot1pRepEnable>0</dot1pRepEnable></ports>
<ports><slot>1</slot><port>7</port><arpInspection>0</arpInspection><enabled>1</enabled><diffServRepEnable>0</diffServRepEnable><enable_flood>0</enable_flood><autoPolarityDisabled>0</autoPolarityDisabled><dot1pExamInnerEnable>0</dot1pExamInnerEnable><arpSecured>0</arpSecured><fdbLearning>1</fdbLearning><vrMode>0</vrMode><qosProfile>0</qosProfile><diffServEnable>0</diffServEnable><flood_mask>0</flood_mask><jumboEnabled>0</jumboEnabled><arpGratuitousInspection>0</arpGratuitousInspection><port2>7</port2><arpLearnDisabled>0</arpLearnDisabled><dot1pRepEnable>0</dot1pRepEnable></ports>
<ports><slot>1</slot><port>8</port><arpInspection>0</arpInspection><enabled>1</enabled><diffServRepEnable>0</diffServRepEnable><enable_flood>0</enable_flood><autoPolarityDisabled>0</autoPolarityDisabled><dot1pExamInnerEnable>0</dot1pExamInnerEnable><arpSecured>0</arpSecured><fdbLearning>1</fdbLearning><vrMode>0</vrMode><qosProfile>0</qosProfile><diffServEnable>0</diffServEnable><flood_mask>0</flood_mask><jumboEnabled>0</jumboEnabled><arpGratuitousInspection>0</arpGratuitousInspection><port2>8</port2><arpLearnDisabled>0</arpLearnDisabled><dot1pRepEnable>0</dot1pRepEnable></ports>
<ports><slot>1</slot><port>9</port><arpInspection>0</arpInspection><enabled>1</enabled><diffServRepEnable>0</diffServRepEnable><enable_flood>0</enable_flood><autoPolarityDisabled>0</autoPolarityDisabled><dot1pExamInnerEnable>0</dot1pExamInnerEnable><arpSecured>0</arpSecured><fdbLearning>1</fdbLearning><vrMode>0</vrMode><qosProfile>0</qosProfile><diffServEnable>0</diffServEnable><flood_mask>0</flood_mask><jumboEnabled>0</jumboEnabled><arpGratuitousInspection>0</arpGratuitousInspection><port2>9</port2><arpLearnDisabled>0</arpLearnDisabled><dot1pRepEnable>0</dot1pRepEnable></ports>
<ports><slot>1</slot><port>10</port><arpInspection>0</arpInspection><enabled>1</enabled><diffServRepEnable>0</diffServRepEnable><enable_flood>0</enable_flood><autoPolarityDisabled>0</autoPolarityDisabled><dot1pExamInnerEnable>0</dot1pExamInnerEnable><arpSecured>0</arpSecured><fdbLearning>1</fdbLearning><vrMode>0</vrMode><qosProfile>0</qosProfile><diffServEnable>0</diffServEnable><flood_mask>0</flood_mask><jumboEnabled>0</jumboEnabled><arpGratuitousInspection>0</arpGratuitousInspection><port2>10</port2><arpLearnDisabled>0</arpLearnDisabled><dot1pRepEnable>0</dot1pRepEnable></ports>
<ports><slot>1</slot><port>11</port><arpInspection>0</arpInspection><enabled>1</enabled><diffServRepEnable>0</diffServRepEnable><enable_flood>0</enable_flood><autoPolarityDisabled>0</autoPolarityDisabled><dot1pExamInnerEnable>0</dot1pExamInnerEnable><arpSecured>0</arpSecured><fdbLearning>1</fdbLearning><vrMode>0</vrMode><qosProfile>0</qosProfile><diffServEnable>0</diffServEnable><flood_mask>0</flood_mask><jumboEnabled>0</jumboEnabled><arpGratuitousInspection>0</arpGratuitousInspection><port2>11</port2><arpLearnDisabled>0</arpLearnDisabled><dot1pRepEnable>0</dot1pRepEnable></ports>
<ports><slot>1</slot><port>12</port><arpInspection>0</arpInspection><enabled>1</enabled><diffServRepEnable>0</diffServRepEnable><enable_flood>0</enable_flood><autoPolarityDisabled>0</autoPolarityDisabled><dot1pExamInnerEnable>0</dot1pExamInnerEnable><arpSecured>0</arpSecured><fdbLearning>1</fdbLearning><vrMode>0</vrMode><qosProfile>0</qosProfile><diffServEnable>0</diffServEnable><flood_mask>0</flood_mask><jumboEnabled>0</jumboEnabled><arpGratuitousInspection>0</arpGratuitousInspection><port2>12</port2><arpLearnDisabled>0</arpLearnDisabled><dot1pRepEnable>0</dot1pRepEnable></ports>
<ports><slot>1</slot><port>13</port><arpInspection>0</arpInspection><enabled>1</enabled><diffServRepEnable>0</diffServRepEnable><enable_flood>0</enable_flood><autoPolarityDisabled>0</autoPolarityDisabled><dot1pExamInnerEnable>0</dot1pExamInnerEnable><arpSecured>0</arpSecured><fdbLearning>1</fdbLearning><vrMode>0</vrMode><qosProfile>0</qosProfile><diffServEnable>0</diffServEnable><flood_mask>0</flood_mask><jumboEnabled>0</jumboEnabled><arpGratuitousInspection>0</arpGratuitousInspection><port2>13</port2><arpLearnDisabled>0</arpLearnDisabled><dot1pRepEnable>0</dot1pRepEnable></ports>
<ports><slot>1</slot><port>14</port><arpInspection>0</arpInspection><enabled>1</enabled><diffServRepEnable>0</diffServRepEnable><enable_flood>0</enable_flood><autoPolarityDisabled>0</autoPolarityDisabled><dot1pExamInnerEnable>0</dot1pExamInnerEnable><arpSecured>0</arpSecured><fdbLearning>1</fdbLearning><vrMode>0</vrMode><qosProfile>0</qosProfile><diffServEnable>0</diffServEnable><flood_mask>0</flood_mask><jumboEnabled>0</jumboEnabled><arpGratuitousInspection>0</arpGratuitousInspection><port2>14</port2><arpLearnDisabled>0</arpLearnDisabled><dot1pRepEnable>0</dot1pRepEnable></ports>
<ports><slot>1</slot><port>15</port><arpInspection>0</arpInspection><enabled>1</enabled><diffServRepEnable>0</diffServRepEnable><enable_flood>0</enable_flood><autoPolarityDisabled>0</autoPolarityDisabled><dot1pExamInnerEnable>0</dot1pExamInnerEnable><arpSecured>0</arpSecured><fdbLearning>1</fdbLearning><vrMode>0</vrMode><qosProfile>0</qosProfile><diffServEnable>0</diffServEnable><flood_mask>0</flood_mask><jumboEnabled>0</jumboEnabled><arpGratuitousInspection>0</arpGratuitousInspection><port2>15</port2><arpLearnDisabled>0</arpLearnDisabled><dot1pRepEnable>0</dot1pRepEnable></ports>
<ports><slot>1</slot><port>16</port><arpInspection>0</arpInspection><enabled>1</enabled><diffServRepEnable>0</diffServRepEnable><enable_flood>0</enable_flood><autoPolarityDisabled>0</autoPolarityDisabled><dot1pExamInnerEnable>0</dot1pExamInnerEnable><arpSecured>0</arpSecured><fdbLearning>1</fdbLearning><vrMode>0</vrMode><qosProfile>0</qosProfile><diffServEnable>0</diffServEnable><flood_mask>0</flood_mask><jumboEnabled>0</jumboEnabled><arpGratuitousInspection>0</arpGratuitousInspection><port2>16</port2><arpLearnDisabled>0</arpLearnDisabled><dot1pRepEnable>0</dot1pRepEnable></ports>
<ports><slot>1</slot><port>17</port><arpInspection>0</arpInspection><enabled>1</enabled><diffServRepEnable>0</diffServRepEnable><enable_flood>0</enable_flood><autoPolarityDisabled>0</autoPolarityDisabled><dot1pExamInnerEnable>0</dot1pExamInnerEnable><arpSecured>0</arpSecured><fdbLearning>1</fdbLearning><vrMode>0</vrMode><qosProfile>0</qosProfile><diffServEnable>0</diffServEnable><flood_mask>0</flood_mask><jumboEnabled>0</jumboEnabled><arpGratuitousInspection>0</arpGratuitousInspection><port2>17</port2><arpLearnDisabled>0</arpLearnDisabled><dot1pRepEnable>0</dot1pRepEnable></ports>
<ports><slot>1</slot><port>18</port><arpInspection>0</arpInspection><enabled>1</enabled><diffServRepEnable>0</diffServRepEnable><enable_flood>0</enable_flood><autoPolarityDisabled>0</autoPolarityDisabled><dot1pExamInnerEnable>0</dot1pExamInnerEnable><arpSecured>0</arpSecured><fdbLearning>1</fdbLearning><vrMode>0</vrMode><qosProfile>0</qosProfile><diffServEnable>0</diffServEnable><flood_mask>0</flood_mask><jumboEnabled>0</jumboEnabled><arpGratuitousInspection>0</arpGratuitousInspection><port2>18</port2><arpLearnDisabled>0</arpLearnDisabled><dot1pRepEnable>0</dot1pRepEnable></ports>
<ports><slot>1</slot><port>19</port><arpInspection>0</arpInspection><enabled>1</enabled><diffServRepEnable>0</diffServRepEnable><enable_flood>0</enable_flood><autoPolarityDisabled>0</autoPolarityDisabled><dot1pExamInnerEnable>0</dot1pExamInnerEnable><arpSecured>0</arpSecured><fdbLearning>1</fdbLearning><vrMode>0</vrMode><qosProfile>0</qosProfile><diffServEnable>0</diffServEnable><flood_mask>0</flood_mask><jumboEnabled>0</jumboEnabled><arpGratuitousInspection>0</arpGratuitousInspection><port2>19</port2><arpLearnDisabled>0</arpLearnDisabled><dot1pRepEnable>0</dot1pRepEnable></ports>
<ports><slot>1</slot><port>20</port><arpInspection>0</arpInspection><enabled>1</enabled><diffServRepEnable>0</diffServRepEnable><enable_flood>0</enable_flood><autoPolarityDisabled>0</autoPolarityDisabled><dot1pExamInnerEnable>0</dot1pExamInnerEnable><arpSecured>0</arpSecured><fdbLearning>1</fdbLearning><vrMode>0</vrMode><qosProfile>0</qosProfile><diffServEnable>0</diffServEnable><flood_mask>0</flood_mask><jumboEnabled>0</jumboEnabled><arpGratuitousInspection>0</arpGratuitousInspection><port2>20</port2><arpLearnDisabled>0</arpLearnDisabled><dot1pRepEnable>0</dot1pRepEnable></ports>
<ports><slot>1</slot><port>21</port><arpInspection>0</arpInspection><enabled>1</enabled><diffServRepEnable>0</diffServRepEnable><enable_flood>0</enable_flood><autoPolarityDisabled>0</autoPolarityDisabled><dot1pExamInnerEnable>0</dot1pExamInnerEnable><arpSecured>0</arpSecured><fdbLearning>1</fdbLearning><vrMode>0</vrMode><qosProfile>0</qosProfile><diffServEnable>0</diffServEnable><flood_mask>0</flood_mask><jumboEnabled>0</jumboEnabled><arpGratuitousInspection>0</arpGratuitousInspection><port2>21</port2><arpLearnDisabled>0</arpLearnDisabled><dot1pRepEnable>0</dot1pRepEnable></ports>
<ports><slot>1</slot><port>22</port><arpInspection>0</arpInspection><enabled>1</enabled><diffServRepEnable>0</diffServRepEnable><enable_flood>0</enable_flood><autoPolarityDisabled>0</autoPolarityDisabled><dot1pExamInnerEnable>0</dot1pExamInnerEnable><arpSecured>0</arpSecured><fdbLearning>1</fdbLearning><vrMode>0</vrMode><qosProfile>0</qosProfile><diffServEnable>0</diffServEnable><flood_mask>0</flood_mask><jumboEnabled>0</jumboEnabled><arpGratuitousInspection>0</arpGratuitousInspection><port2>22</port2><arpLearnDisabled>0</arpLearnDisabled><dot1pRepEnable>0</dot1pRepEnable></ports>
<ports><slot>1</slot><port>23</port><arpInspection>0</arpInspection><enabled>1</enabled><diffServRepEnable>0</diffServRepEnable><enable_flood>0</enable_flood><autoPolarityDisabled>0</autoPolarityDisabled><dot1pExamInnerEnable>0</dot1pExamInnerEnable><arpSecured>0</arpSecured><fdbLearning>1</fdbLearning><vrMode>0</vrMode><qosProfile>0</qosProfile><diffServEnable>0</diffServEnable><flood_mask>0</flood_mask><jumboEnabled>0</jumboEnabled><arpGratuitousInspection>0</arpGratuitousInspection><port2>23</port2><arpLearnDisabled>0</arpLearnDisabled><dot1pRepEnable>0</dot1pRepEnable></ports>
<ports><slot>1</slot><port>24</port><arpInspection>0</arpInspection><enabled>1</enabled><diffServRepEnable>0</diffServRepEnable><enable_flood>0</enable_flood><autoPolarityDisabled>0</autoPolarityDisabled><dot1pExamInnerEnable>0</dot1pExamInnerEnable><arpSecured>0</arpSecured><fdbLearning>1</fdbLearning><vrMode>0</vrMode><qosProfile>0</qosProfile><diffServEnable>0</diffServEnable><flood_mask>0</flood_mask><jumboEnabled>0</jumboEnabled><arpGratuitousInspection>0</arpGratuitousInspection><port2>24</port2><arpLearnDisabled>0</arpLearnDisabled><dot1pRepEnable>0</dot1pRepEnable></ports>
<ports><slot>1</slot><port>25</port><arpInspection>0</arpInspection><enabled>1</enabled><diffServRepEnable>0</diffServRepEnable><enable_flood>0</enable_flood><dot1pExamInnerEnable>0</dot1pExamInnerEnable><arpSecured>0</arpSecured><fdbLearning>1</fdbLearning><vrMode>0</vrMode><qosProfile>0</qosProfile><diffServEnable>0</diffServEnable><flood_mask>0</flood_mask><jumboEnabled>0</jumboEnabled><arpGratuitousInspection>0</arpGratuitousInspection><port2>25</port2><arpLearnDisabled>0</arpLearnDisabled><dot1pRepEnable>0</dot1pRepEnable></ports>
<ports><slot>1</slot><port>26</port><arpInspection>0</arpInspection><enabled>1</enabled><diffServRepEnable>0</diffServRepEnable><enable_flood>0</enable_flood><dot1pExamInnerEnable>0</dot1pExamInnerEnable><arpSecured>0</arpSecured><fdbLearning>1</fdbLearning><vrMode>0</vrMode><qosProfile>0</qosProfile><diffServEnable>0</diffServEnable><flood_mask>0</flood_mask><jumboEnabled>0</jumboEnabled><arpGratuitousInspection>0</arpGratuitousInspection><port2>26</port2><arpLearnDisabled>0</arpLearnDisabled><dot1pRepEnable>0</dot1pRepEnable></ports>
<vlanPort><vlanName><![CDATA[Default]]></vlanName><untaggedPorts>2-26</untaggedPorts></vlanPort>
<vlanIpAddress><ipaddress>10.100.26.5</ipaddress><vlanName><![CDATA[Default]]></vlanName><ifIndex>1000004</ifIndex><ifIndexForL3Addr>1000007</ifIndexForL3Addr><netmask>255.255.255.0</netmask><secondaryAddr>0</secondaryAddr><ipForwarding>2</ipForwarding></vlanIpAddress>
</xos-module-vlan>
<xos-module-vrrp version="3.0.0.5">
<vrrp_cm_global><vrrpNodeVersion>2</vrrpNodeVersion><vrrpNotificationCntl>1</vrrpNotificationCntl></vrrp_cm_global>
</xos-module-vrrp>
</xos-configuration>


END

