package DataExtremeSwitch;

use strict;
use warnings;
use Exporter 'import';
our @EXPORT_OK = qw($responsesExtremeSwitch);

our $responsesExtremeSwitch = {};

$responsesExtremeSwitch->{memory} = <<'END';
show memory

System Memory Information
-----------------------
Total DRAM Size: 134217728 (128MB)

 status   bytes    blocks   avg block  max block
 ------ --------- -------- ---------- ----------
current
   free  35794096      944      37917  34694592
  alloc  51964848    49639       1046        -
cumulative
  alloc  -211993824  11359512        359        -


Software Packet Memory Statistics
---------------------------------
                Type:    Short    Long    Jumbo
         Total Alloc:     512     512      64
          Total Free:     418     509      64
             Failure:       0
         Data Blocks:      10
        Other Blocks:      84



Memory Utilization Statistics
-----------------------
          Size     16     32     48     64     80     96    112    128    144    176
                  208    256    384    512    768   1024   2048   4096   8192  16384
    ---------- ------ ------ ------ ------ ------ ------ ------ ------ ------ ------
   Total Block  13104   5408    254    101    168    144   1143    226    204     85
                   72     64     64     64     40     32     32    368     40      4
    Used Block  13000   4878    161     34    104    102   1123    104    101     23
                    3     56      6     60      2     21     17    324     34      1
    Free Block    104    530     93     67     64     42     20    122    103     62
                   69      8     58      4     38     11     15     44      6      3
        System      0     43      0      0      0      0      0      0      0      0
                    0      0      0      0      0      0      0      1      0      0
          Mgmt  12976   4812    136     34     68    102   1111     99     90     21
                    0     51      0     18      1     17     17    323     34      0
          Esrp      0      0      0      0      1      0      0      0      1      0
                    0      0      1      4      0      0      0      0      0      0
            IP      3      6      0      0      0      0      1      0      5      0
                    0      0      0      0      0      0      0      0      0      0
          OSPF      0      0      1      0      0      0      0      0      0      0
                    0      0      0      0      0      0      0      0      0      0
          VRRP      1      0      0      0      0      0      0      0      0      0
                    0      0      0      0      0      1      0      0      0      0
           STP      6      0      0      0      0      0      0      0      0      0
                    0      0      0      1      0      0      0      0      0      0
           EMS      0      0      0      0      4      0      2      5      5      2
                    3      5      5      2      1      2      0      0      0      0
           SDK      0     17     10      0      0      0      0      0      0      0
                    0      0      0     35      0      0      0      0      0      1
* MIA-Extreme300:10 #

END

$responsesExtremeSwitch->{switch} = <<'END';
show  switch

SysName:          MIA-Extreme300
SysLocation:      Alterpoint Lab1
SysContact:       Pitest3
System MAC:       00:04:96:1F:8C:ED

Platform:         Summit300-24

License:          Advanced Edge + Security
System Mode:      802.1Q EtherType is 8100 (Hex).

Recovery Mode:    None
System Watchdog:  Enabled
Reboot Loop Prot: Disabled
ESRP-Aware Mode:  Enabled

Current Time:     Fri Aug 31 11:37:39 2007
Timezone:         [Auto DST Enabled] GMT Offset: 0 minutes, name is GMT.
                  DST of 60 minutes is currently in effect, name is not set.
                  DST begins every first Sunday April at 2:00
                  DST ends every last Sunday October at 2:00
Boot Time:        Tue Aug 28 14:45:36 2007
Config Modified:  Fri Aug 31 11:37:26 2007
Next Reboot:      None scheduled
Timed Upload:     None scheduled
Timed Download:   None scheduled

Temperature:      Normal.    All fans are operational.
Power supply:     Internal power supply OK, External power supply not present.

Default Cfg Mode: Standard     


Primary EW Ver:   7.3e.0b1 [unknown-ssh] 
Secondary EW Ver: 7.4e.3.5 [ssh] 
Image Selected:   Secondary    
Image Booted:     Secondary    

Config Selected:  Primary      
Config Booted:    Primary      
Primary Config:   Created by EW Version:
		  7.4e.3.5 [51]
                  10574 bytes saved on Wed Aug 29 15:37:22 2007
Secondary Config: Created by EW Version:
		  7.4e.3.5 [51]
                  7081 bytes saved on Mon Jan 30 16:19:49 2006

* MIA-Extreme300:4 # 

END

$responsesExtremeSwitch->{version} = <<'END';
show version

System Serial Number:  800138-00-03 0443G-01141  CP: 04
Assembly: 8EVT24POE2A1   P08451848
PoE module: 02  3A1
Image : Extremeware  Version 7.4e.3.5 [ssh] by Release_Master on 12/12/05 12:22:03

BootROM : 5.1

* MIA-Extreme300:5 #

END

$responsesExtremeSwitch->{accounts} = <<'END';
show accounts
   User Name      Access LoginOK  Failed User Type
----------------  ------ -------  ------ ---------
           admin    R/W        0       0     Admin
            user    RO         0       0      User
         testlab    R/W      188       1     Admin
       testbling    R/W        0       0     Admin
--------------------------------------------------
(*) - Account locked
* MIA-Extreme300:6 #

END

$responsesExtremeSwitch->{routes} = <<'END';
show iproute detail


Destination: 10.100.5.0/24     
Gateway: 10.100.5.4       Metric: 1            Origin:  Direct
Flags: -------u---        Acct-1: 0            Duration: 2d:21h:16m:50s
Use: 0       M-Use: 0     VLAN: Default
 
Destination: 192.168.5.0/24    
Gateway: 192.168.5.2      Metric: 1            Origin: *Direct
Flags: U------u---        Acct-1: 0            Duration: 2d:21h:16m:50s
Use: 162     M-Use: 0     VLAN: vlan52
 
Destination: 10.125.125.0/24   
Gateway: 10.125.125.1     Metric: 1            Origin:  Direct
Flags: -------u---        Acct-1: 0            Duration: 2d:21h:16m:50s
Use: 0       M-Use: 0     VLAN: vlan12
 
Destination: 127.0.0.1/8       
Gateway: 127.0.0.1        Metric: 0            Origin: *Direct
Flags: U-H----um--        Acct-1: 0            Duration: 2d:21h:16m:50s
Use: 0       M-Use: 0     VLAN: Default
 
Destination: Default Route     
Gateway: 192.168.5.1      Metric: 1            Origin: *Static
Flags: UG---S-um--        Acct-1: 0            Duration: 2d:21h:16m:50s
Use: 169977  M-Use: 0     VLAN: vlan52
 
Origin(OR): (b) BlackHole, (bo) BOOTP, (ct) CBT, (d) Direct, (df) DownIF
            (dv) DVMRP, (h) Hardcoded, (i) ICMP, (mo) MOSPF, (o) OSPF
            (o1) OSPFExt1, (o2) OSPFExt2, (oa) OSPFIntra, (oe) OSPFAsExt
            (or) OSPFInter, (pd) PIM-DM, (ps) PIM-SM, (r) RIP, (ra) RtAdvrt
            (s) Static, (*) Preferred route

Flags: (B) BlackHole, (D) Dynamic, (G) Gateway, (H) Host Route
       (L) Direct LDP LSP, (l) Indirect LDP LSP, (m) Multicast
       (P) LPM-routing, (R) Modified, (S) Static, (T) Direct RSVP-TE LSP
       (t) Indirect RSVP-TE LSP, (u) Unicast, (U) Up

Mask distribution:
    1 default routes     	    1 routes at length  8	
    3 routes at length 24	

Route origin distribution:
    4 routes from Direct      	    1 routes from Static      	

Total number of routes = 5.

* MIA-Extreme300:7 #

END

$responsesExtremeSwitch->{stp} = <<'END';
show stpd detail
Stpd: s0		Stp: ENABLED		Number of Ports: 2
Rapid Root Failover: Disabled
Operational Mode: 802.1D
802.1Q Tag: (none)
Ports: 2,19
Active Vlans:  vlan12 Default
Bridge Priority: 32768
BridgeID:		80:00:00:04:96:1f:8c:ed
Designated root:	80:00:00:04:96:1f:8c:ed
RootPathCost: 0 	Root Port: ----
MaxAge: 20s		HelloTime: 2s		ForwardDelay: 15s
CfgBrMaxAge: 20s	CfgBrHelloTime: 2s	CfgBrForwardDelay: 15s
Topology Change Time: 35s			Hold time: 1s
Topology Change Detected: FALSE			Topology Change: FALSE
Number of Topology Changes: 0
Time Since Last Topology Change: 0s

* MIA-Extreme300:8 #

END

$responsesExtremeSwitch->{vlans} = <<'END';
show vlan detail
VLAN Interface[0-200] with name "Default" created by user
     Tagging:	802.1Q Tag 1
     Priority:	802.1P Priority 7 
     IP:	10.100.5.4/255.255.255.0    
     STPD:	s0(Enabled,Auto-bind) 
     Protocol:	Match all unfiltered protocols.
     Loopback:	Disable
     RateShape:	Disable
     QosProfile:QP1
     Ports:	1.     (Number of active ports=0)
	Flags:	(*) Active, (!) Disabled
	      	(B) BcastDisabled, (R) RateLimited, (L) Loopback
	      	(g) Load Share Group
	Untag:	 2   


VLAN Interface[1-201] with name "MacVlanDiscover" created by user
     Tagging:	Untagged (Internal tag 4094) 
     Priority:	802.1P Priority 7 
     STPD:	None
     Protocol:	Match all unfiltered protocols.
     Loopback:	Disable
     RateShape:	Disable
     QosProfile:QP1
     Ports:	0.     (Number of active ports=0)


VLAN Interface[2-202] with name "vlan12" created by user
     Tagging:	802.1Q Tag 12
     Priority:	802.1P Priority 7 
     IP:	10.125.125.1/255.255.255.0    
     STPD:	s0(Enabled,Auto-bind) 
     Protocol:	Match all unfiltered protocols.
     Loopback:	Disable
     RateShape:	Disable
     QosProfile:QP1
     Ports:	1.     (Number of active ports=0)
	Flags:	(*) Active, (!) Disabled
	      	(B) BcastDisabled, (R) RateLimited, (L) Loopback
	      	(g) Load Share Group
	Untag:	 19  


VLAN Interface[3-203] with name "vlan52" created by user
     Tagging:	Untagged (Internal tag 4092) 
     Priority:	802.1P Priority 7 
     IP:	192.168.5.2/255.255.255.0    
     STPD:	None
     Protocol:	Match all unfiltered protocols.
     Loopback:	Disable
     RateShape:	Disable
     QosProfile:QP1
     Ports:	3.     (Number of active ports=3)
	Flags:	(*) Active, (!) Disabled
	      	(B) BcastDisabled, (R) RateLimited, (L) Loopback
	      	(g) Load Share Group
	Untag:	*1   *3   *8   



Total number of Vlan(s) : 4
* MIA-Extreme300:9 #

END

$responsesExtremeSwitch->{config} = <<'END';
show configuration detail
# Full Detail Configuration


#
# Summit300-24 Configuration generated Mon Sep 3 11:22:45 2007
# Software Version 7.4e.3.5 [ssh] by Release_Master on 12/12/05 12:22:03

# Configuration Mode
configure configuration-mode standard
configure sys-recovery-level none
enable system-watchdog
configure reboot-loop-protection threshold 0
enable esrp-aware
configure vlan default delete ports all
create vlan "vlan12" 
create vlan "vlan52" 
#
# Config information for VLAN Default.
configure vlan "Default" tag 1     # VLAN-ID=0x1  Global Tag 1
configure stpd s0 add vlan "Default"
configure vlan "Default" protocol "ANY"
configure vlan "Default" qosprofile "QP1" 
configure vlan "Default" ipaddress 10.100.5.4 255.255.255.0 
configure vlan "Default" add port 2 untagged
#
# Config information for VLAN MacVlanDiscover.
# No VLAN-ID is associated with VLAN MacVlanDiscover.
configure vlan "MacVlanDiscover" protocol "ANY"
configure vlan "MacVlanDiscover" qosprofile "QP1" 
# No IP address is configured for VLAN MacVlanDiscover.
# No port is associated with VLAN MacVlanDiscover.
#
# Config information for VLAN vlan12.
configure vlan "vlan12" tag 12     # VLAN-ID=0xc  Global Tag 3
configure stpd s0 add vlan "vlan12"
configure vlan "vlan12" protocol "ANY"
configure vlan "vlan12" qosprofile "QP1" 
configure vlan "vlan12" ipaddress 10.125.125.1 255.255.255.0 
configure vlan "vlan12" add port 19 untagged
#
# Config information for VLAN vlan52.
# No VLAN-ID is associated with VLAN vlan52.
configure vlan "vlan52" protocol "ANY"
configure vlan "vlan52" qosprofile "QP1" 
configure vlan "vlan52" ipaddress 192.168.5.2 255.255.255.0 
configure vlan "vlan52" add port 1 untagged
configure vlan "vlan52" add port 3 untagged
configure vlan "vlan52" add port 8 untagged

# Boot information
use image secondary

#Configuration Information
use configuration primary
delete account user
configure account admin encrypted
452ejK$KkunfCWJoYDtilAhn0/oq0
452ejK$KkunfCWJoYDtilAhn0/oq0
create account user "user" encrypted "fw3NfO$t389o7FDPHOFA3g2rDima."
create account admin "testlab" encrypted "1s.afO$hVD1XFD9vays26MQ5FTxk1"
create account admin "testbling" encrypted "0q2LrO$ciw7/QlkYDr.7k08GzdbO."
enable telnet access-profile none port 23
#
# Banner Configuration
#
configure banner


configure banner netlogin


enable web http
enable web http access-profile none port 80
enable web https
enable web https access-profile "none" port 443
# SNMP Configuration

configure snmp access-profile readonly None
configure snmp access-profile readwrite None
enable snmp access
disable snmp dot1dTpFdbTable
enable snmp trap
enable snmp traps port-up-down ports 1
enable snmp traps port-up-down ports 2
enable snmp traps port-up-down ports 3
enable snmp traps port-up-down ports 4
enable snmp traps port-up-down ports 5
enable snmp traps port-up-down ports 6
enable snmp traps port-up-down ports 7
enable snmp traps port-up-down ports 8
enable snmp traps port-up-down ports 9
enable snmp traps port-up-down ports 10
enable snmp traps port-up-down ports 11
enable snmp traps port-up-down ports 12
enable snmp traps port-up-down ports 13
enable snmp traps port-up-down ports 14
enable snmp traps port-up-down ports 15
enable snmp traps port-up-down ports 16
enable snmp traps port-up-down ports 17
enable snmp traps port-up-down ports 18
enable snmp traps port-up-down ports 19
enable snmp traps port-up-down ports 20
enable snmp traps port-up-down ports 21
enable snmp traps port-up-down ports 22
enable snmp traps port-up-down ports 23
enable snmp traps port-up-down ports 24
enable snmp traps port-up-down ports 25
enable snmp traps port-up-down ports 26
configure snmp sysName "MIA-Extreme300"
configure snmp sysLocation "Alterpoint Lab1"
configure snmp sysContact "Pitest3"
disable rmon
disable idletimeouts
config idletimeouts 20
config web login-timeout 30
disable clipaging
enable cli-prompt-number
enable cli-config-logging

# Ports AutoNeg Configuration

# Load Sharing Configuration

# Ports Configuration
disable lbdetect port 1
config port 1 aggregate-bandwidth percent 100
enable smartredundancy 1
enable smartredundancy 1
disable lbdetect port 2
config port 2 aggregate-bandwidth percent 100
enable smartredundancy 2
enable smartredundancy 2
disable lbdetect port 3
config port 3 aggregate-bandwidth percent 100
enable smartredundancy 3
enable smartredundancy 3
disable lbdetect port 4
config port 4 aggregate-bandwidth percent 100
enable smartredundancy 4
enable smartredundancy 4
disable lbdetect port 5
config port 5 aggregate-bandwidth percent 100
enable smartredundancy 5
enable smartredundancy 5
disable lbdetect port 6
config port 6 aggregate-bandwidth percent 100
enable smartredundancy 6
enable smartredundancy 6
disable lbdetect port 7
config port 7 aggregate-bandwidth percent 100
enable smartredundancy 7
enable smartredundancy 7
disable lbdetect port 8
config port 8 aggregate-bandwidth percent 100
enable smartredundancy 8
enable smartredundancy 8
disable lbdetect port 9
config port 9 aggregate-bandwidth percent 100
enable smartredundancy 9
enable smartredundancy 9
disable lbdetect port 10
config port 10 aggregate-bandwidth percent 100
enable smartredundancy 10
enable smartredundancy 10
disable lbdetect port 11
config port 11 aggregate-bandwidth percent 100
enable smartredundancy 11
enable smartredundancy 11
disable lbdetect port 12
config port 12 aggregate-bandwidth percent 100
enable smartredundancy 12
enable smartredundancy 12
disable lbdetect port 13
config port 13 aggregate-bandwidth percent 100
enable smartredundancy 13
enable smartredundancy 13
disable lbdetect port 14
config port 14 aggregate-bandwidth percent 100
enable smartredundancy 14
enable smartredundancy 14
disable lbdetect port 15
config port 15 aggregate-bandwidth percent 100
enable smartredundancy 15
enable smartredundancy 15
disable lbdetect port 16
config port 16 aggregate-bandwidth percent 100
enable smartredundancy 16
enable smartredundancy 16
disable lbdetect port 17
config port 17 aggregate-bandwidth percent 100
enable smartredundancy 17
enable smartredundancy 17
disable lbdetect port 18
config port 18 aggregate-bandwidth percent 100
enable smartredundancy 18
enable smartredundancy 18
disable lbdetect port 19
config port 19 aggregate-bandwidth percent 100
enable smartredundancy 19
enable smartredundancy 19
disable lbdetect port 20
config port 20 aggregate-bandwidth percent 100
enable smartredundancy 20
enable smartredundancy 20
disable lbdetect port 21
config port 21 aggregate-bandwidth percent 100
enable smartredundancy 21
enable smartredundancy 21
disable lbdetect port 22
config port 22 aggregate-bandwidth percent 100
enable smartredundancy 22
enable smartredundancy 22
disable lbdetect port 23
config port 23 aggregate-bandwidth percent 100
enable smartredundancy 23
enable smartredundancy 23
disable lbdetect port 24
config port 24 aggregate-bandwidth percent 100
enable smartredundancy 24
enable smartredundancy 24
disable lbdetect port 25
config port 25 aggregate-bandwidth percent 100
enable smartredundancy 25
enable smartredundancy 25
configure port 25 preferred-medium fiber
disable lbdetect port 26
config port 26 aggregate-bandwidth percent 100
enable smartredundancy 26
enable smartredundancy 26
configure port 26 preferred-medium fiber

# Spanning tree information 
configure stpd s0 mode dot1d
configure stpd s0 port link-type broadcast 2
configure stpd s0 port cost 10 19
configure stpd s0 port link-type broadcast 19
enable stpd s0

# MAC FDB configuration and static entries
configure fdb agingtime 300

configure ipfdb agingtime 0

# -- IP Interface[0] = "Default"
configure ip-mtu 1500 vlan "Default"
unconfigure vlan "MacVlanDiscover" ipaddress

# -- IP Interface[1] = "vlan12"
configure ip-mtu 1500 vlan "vlan12"

# -- IP Interface[2] = "vlan52"
configure ip-mtu 1500 vlan "vlan52"

# Global IP settings.
configure irdp 450 600 1800 0
configure irdp broadcast
disable icmp useredirects
disable icmp access-list 
disable iproute sharing
configure ipfdb route-add clear-all
disable bootprelay
configure ip-down-vlan-action forward
#
# IP ARP Configuration

configure iparp timeout 20
configure iparp max-entries 8192
configure iparp max-pending-entries 256
enable iparp checking
enable iparp refresh
#
# IP Route Configuration
configure iproute add default 192.168.5.1 1
# Multicast configuration
configure igmp 125 10 1
configure igmp snooping timer 260 260
enable igmp snooping 
enable igmp snooping vlan "Default"
enable igmp snooping vlan "MacVlanDiscover"
enable igmp snooping vlan "vlan12"
enable igmp snooping vlan "vlan52"
enable igmp snooping with-proxy
configure igmp snooping leave-timeout 1000
configure igmp snooping flood-list "None"
disable ipmcforwarding vlan "vlan52" 
enable igmp vlan "vlan52" 
disable ipmcforwarding vlan "vlan12" 
enable igmp vlan "vlan12" 
disable ipmcforwarding vlan "Default" 
enable igmp vlan "Default" 
# RIP interface configuration 
configure rip delete vlan "vlan52" 
configure rip txmode v2only vlan "vlan52" 
configure rip rxmode any vlan "vlan52" 
configure rip vlan "vlan52" cost 1
configure rip vlan "vlan52" trusted-gateway None
configure rip vlan "vlan52" import-filter None
configure rip vlan "vlan52" export-filter None
configure rip delete vlan "vlan12" 
configure rip txmode v2only vlan "vlan12" 
configure rip rxmode any vlan "vlan12" 
configure rip vlan "vlan12" cost 1
configure rip vlan "vlan12" trusted-gateway None
configure rip vlan "vlan12" import-filter None
configure rip vlan "vlan12" export-filter None
configure rip delete vlan "Default" 
configure rip txmode v2only vlan "Default" 
configure rip rxmode any vlan "Default" 
configure rip vlan "Default" cost 1
configure rip vlan "Default" trusted-gateway None
configure rip vlan "Default" import-filter None
configure rip vlan "Default" export-filter None
# RIP global parameter configuration 
disable rip aggregation
enable rip splithorizon
enable rip poisonreverse
enable rip triggerupdate
disable rip export static
disable rip export ospf-intra
disable rip export ospf-inter
disable rip export ospf-extern1
disable rip export ospf-extern2

disable rip export direct
disable rip originate-default
configure rip updatetime 30
configure rip routetimeout 180
configure rip garbagetime 120
# RIP Global enable/disable state
disable rip

#
# PIM Router Configuration
#
disable pim 
configure pim crp timer 60
configure pim register-suppress-interval 60 register-probe-interval 5
configure pim register-rate-limit-interval 0 
configure pim spt-threshold 0 0
configure pim register-checksum-to include-data

#
# Static MRoute Configuration

# Ospf Area Configuration
create ospf area 0.0.0.0
configure ospf area 0.0.0.0 interarea-filter "None"
configure ospf area 0.0.0.0 external-filter "None"
create ospf area 10.100.0.0
configure ospf area 10.100.0.0 interarea-filter "None"
configure ospf area 10.100.0.0 external-filter "None"

# Ospf Range Configuration

# Interface Configuration
configure ospf vlan "vlan52" area 0.0.0.0
configure ospf vlan "vlan52" timer 5 1 10 40
configure ospf vlan "vlan52" authentication none
configure ospf vlan "vlan12" area 0.0.0.0
configure ospf vlan "vlan12" timer 5 1 10 40
configure ospf vlan "vlan12" authentication none
configure ospf vlan "Default" area 10.100.0.0
configure ospf vlan "Default" timer 5 1 10 40
configure ospf vlan "Default" authentication none

# Virtual Link Configuration

# Ospf ASE Summary Configuration

# OSPF Router Configuration
configure ospf routerid 10.100.5.4
configure ospf lsa-batch-interval 30
configure ospf metric-table 10M 10 100M 5 1G 4 10G 2
configure ospf spf-hold-time 3
enable ospf capability opaque-lsa
configure ospf ase-limit 0 timeout 0

disable ospf export static
disable ospf export direct
disable ospf export rip

# ESRP Interface Configuration
configure vlan "vlan12" esrp priority 0
configure vlan "vlan12" esrp group 0
configure vlan "vlan12" esrp timer 2 esrp-nbr-timeout 6
configure vlan "vlan12" esrp esrp-premaster-timeout 0
configure vlan "vlan12" esrp elrp-master-poll disable
configure vlan "vlan12" esrp elrp-premaster-poll disable
configure vlan "vlan12" esrp esrp-election ports-track-priority-mac
configure vlan "vlan52" esrp priority 0
configure vlan "vlan52" esrp group 0
configure vlan "vlan52" esrp timer 2 esrp-nbr-timeout 6
configure vlan "vlan52" esrp esrp-premaster-timeout 0
configure vlan "vlan52" esrp elrp-master-poll disable
configure vlan "vlan52" esrp elrp-premaster-poll disable
configure vlan "vlan52" esrp esrp-election ports-track-priority-mac


#ELRP Configuration

# VRRP Configuration

# EAPS configuration
disable eaps
configure eaps fast-convergence off

# EAPS shared port configuration

# NAT configuration
configure nat timeout 300
configure nat tcp-timeout 120
configure nat udp-timeout 120
configure nat icmp-timeout 3
configure nat finrst-timeout 60
configure nat syn-timeout 60

disable nat
configure dns-client add name-server 10.10.1.9
configure dns-client add name-server 10.10.1.11

# SNTP client configuration
disable sntp-client
configure sntp-client primary server ""
configure sntp-client secondary server ""
configure sntp-client update-interval 64
configure timezone name GMT 0 autodst begins every first Sunday April at 2:00 ends every last Sunday October at 2:00
#
# Radius configuration 
#
enable radius
configure radius primary shared-secret encrypted "aezie"
configure radius primary server 10.100.32.137 1645 client-ip 192.168.5.2 
configure radius primary server 10.100.32.137 timeout 3
disable radius-accounting

# TACACS configuration
disable tacacs
configure tacacs primary shared-secret encrypted "aezie"
configure tacacs primary server 10.100.32.137 49 client-ip 192.168.5.2 
configure tacacs primary server 10.100.32.137 timeout 3
enable tacacs-authorization
disable tacacs-accounting
configure auth mgmt-access tacacs primary 10.100.32.137 
configure auth netlogin radius primary 10.100.32.137 

# Mac Vlan Configurations

# SSH configuration
configure ssh2 key pregenerated
P2/56wAAAgIAAAAmZGwtbW9kcHtzaWdue2RzYS1uaXN0LXNoYTF9LGRoe3BsYWlufX0AAAAEbm9uZQAA
AcQAAAHAAAAAAAAABADrFmkCZ1U3SB3ukC54HIaE+/3RliF7rWe3+LNo3gVw6H+dUfRP9BxrC0dDH5sP
T384jzImIcqYtV8g/+4VkW9CQvByR8d6CR0WtAgS7V4qFTPipjmAMexAvgAviPKMRyjG1tXIscVqZpg+
q3PlFNtWOtvNW0SdOPQnPnx9QkQHewAABADP7q+Dxe/722c16FHVgub3t9sY45OwEQgmuoDkrDTH0lpL
7o3nsMOw177KJ29eHZBFe6CcP7nnOgcRvzvUsgSXgCTVlXyzH9cWexYsM8jfxNXqtSnXMv7W07/HkWxu
1v/3xpAkG5bGhnikAqnFDkp/c1cDahXDjMSnYZYQUgcDmgAAAKCGPFtWZokia7PIM/2GEv9/4iVgzwAA
BAC9AKT3uiaCe1cY5wqFsTTZiOcDg4bSVRglk6gHRfxwh4cYCE66hD0KVnHK4hheYciGqyESYUho/URa
1orFDl/Ns2bZpCOY5I+e6LpM3RUjKYYU44WQMWKYNeuZ+uNdQxYHYpcL8mfnGo19RXc8i3Jhvx/vYMYG
eZJvrVqJ9k85HwAAAJ4leCMY1lFoz/wM+/WQzpWy9YDxXg==

enable ssh2 access-profile none port 22
#
# Access-mask Configuration
#
# Access-list Configuration
#
# Rate-limit Configuration

#
# System Dump Configuration
#

## SNMPV3 EngineID Configuration
#
## SNMPV3 USM Users Configuration
#
#
# SNMPV3 MIB Views Configuration
#
#
# SNMPV3 VACM Access Configuration
#
#
# SNMPV3 USM Groups Configuration
#
#
# SNMPV3 Community Table Configuration
#
config snmpv3 add community encrypted "=" name encrypted "=" user "v1v2c_rw"
config snmpv3 add community encrypted "acz~kskgc" name encrypted "acz~kskgc" user "v1v2c_ro"
config snmpv3 add community encrypted "jude" name encrypted "jude" user "v1v2c_ro"
config snmpv3 add community encrypted "puhd" name encrypted "puhd" user "v1v2c_ro"
#
# SNMPV3 Target Addr Configuration
#
#
# SNMPV3 Target Params Configuration
#
#
# SNMPV3 Notify Configuration
#
#
# SNMPV3 Notify Filter Profile Configuration
#
#
# SNMPV3 Notify Filter Configuration
#



# System-wide Debug Configuration 
#No System-wide debug tracing configured

#Vlan Based Debug Configuration
#
#No Vlan-based debug-tracing configured

#Port Based Debug Configuration
#
#No Port based debug-tracing configured

# IP subnet lookup configuration

# Network Login Configuration
configure netlogin base-url "network-access.net"
configure netlogin redirect-page "http://www.extremenetworks.com"
disable netlogin Session-Refresh  3 
enable netlogin logout-privilege
configure netlogin mac auth-retry-count 3
configure netlogin mac reauth-period 1800
enable netlogin web-based
enable netlogin dot1x
enable netlogin mac

# Event Management System Configuration

# Event Management System Log Filter Configuration

# Event Management System Log Target Configuration
disable syslog

configure log target nvram filter "DefaultFilter" severity warning
configure log target nvram match ""
configure log target nvram format priority off date mm-dd-yyyy time hundredths host-name off tag-name off tag-id off sequence-number off severity on event-name condition process-name off process-id off source-function off source-line off 
enable log target nvram

configure log target memory-buffer number-of-messages 1000
configure log target memory-buffer filter "DefaultFilter" severity debug-data
configure log target memory-buffer match ""
configure log target memory-buffer format priority off date mm-dd-yyyy time hundredths host-name off tag-name off tag-id off sequence-number off severity on event-name condition process-name off process-id off source-function off source-line off 
enable log target memory-buffer

configure log target console-display filter "DefaultFilter" severity info
configure log target console-display match ""
configure log target console-display format priority off date mm-dd-yyyy time hundredths host-name off tag-name off tag-id off sequence-number off severity on event-name condition process-name off process-id off source-function off source-line off 
enable log target console-display


# cpu denial-of-service protection configuration
disable cpu-dos-protect
config cpu-dos-protect notice-threshold 4000
config cpu-dos-protect alert-threshold 4000
config cpu-dos-protect timeout 15
config cpu-dos-protect filter-type-allowed  destination
config cpu-dos-protect trusted-ports  none
config cpu-dos-protect filter-precedence 10
config cpu-dos-protect messages on

# cpu denial-of-service protection port configuration
config cpu-dos-protect port 1 alert-threshold 150 interval-time 1
config cpu-dos-protect port 2 alert-threshold 150 interval-time 1
config cpu-dos-protect port 3 alert-threshold 150 interval-time 1
config cpu-dos-protect port 4 alert-threshold 150 interval-time 1
config cpu-dos-protect port 5 alert-threshold 150 interval-time 1
config cpu-dos-protect port 6 alert-threshold 150 interval-time 1
config cpu-dos-protect port 7 alert-threshold 150 interval-time 1
config cpu-dos-protect port 8 alert-threshold 150 interval-time 1
config cpu-dos-protect port 9 alert-threshold 150 interval-time 1
config cpu-dos-protect port 10 alert-threshold 150 interval-time 1
config cpu-dos-protect port 11 alert-threshold 150 interval-time 1
config cpu-dos-protect port 12 alert-threshold 150 interval-time 1
config cpu-dos-protect port 13 alert-threshold 150 interval-time 1
config cpu-dos-protect port 14 alert-threshold 150 interval-time 1
config cpu-dos-protect port 15 alert-threshold 150 interval-time 1
config cpu-dos-protect port 16 alert-threshold 150 interval-time 1
config cpu-dos-protect port 17 alert-threshold 150 interval-time 1
config cpu-dos-protect port 18 alert-threshold 150 interval-time 1
config cpu-dos-protect port 19 alert-threshold 150 interval-time 1
config cpu-dos-protect port 20 alert-threshold 150 interval-time 1
config cpu-dos-protect port 21 alert-threshold 150 interval-time 1
config cpu-dos-protect port 22 alert-threshold 150 interval-time 1
config cpu-dos-protect port 23 alert-threshold 150 interval-time 1
config cpu-dos-protect port 24 alert-threshold 150 interval-time 1
config cpu-dos-protect port 25 alert-threshold 150 interval-time 1
config cpu-dos-protect port 26 alert-threshold 150 interval-time 1
# Enhanced-dos-protect configuration
disable enhanced-dos-protect ipfdb
disable enhanced-dos-protect rate-limit
# Source IP Guard Configuration 
#
# Wireless Configuration 
#
config wireless Country-code USA/Canada/HongKong
config wireless management-vlan Default
config wireless default-gateway 10.100.5.1
#
# RF Profile configuration
#
create rf-profile DEFAULT_A mode A
config rf-profile DEFAULT_A beacon-interval 40
config rf-profile DEFAULT_A dtim 2
config rf-profile DEFAULT_A frag-length 2345
config rf-profile DEFAULT_A rts-threshold 2330
config rf-profile DEFAULT_A preamble Short
config rf-profile DEFAULT_A short-retry 4
config rf-profile DEFAULT_A long-retry 7


create rf-profile DEFAULT_BG mode B_G
config rf-profile DEFAULT_BG beacon-interval 40
config rf-profile DEFAULT_BG dtim 2
config rf-profile DEFAULT_BG frag-length 2345
config rf-profile DEFAULT_BG rts-threshold 2330
config rf-profile DEFAULT_BG preamble Long
config rf-profile DEFAULT_BG short-retry 4
config rf-profile DEFAULT_BG long-retry 7


create rf-profile DEFAULT_B mode B
config rf-profile DEFAULT_B beacon-interval 40
config rf-profile DEFAULT_B dtim 2
config rf-profile DEFAULT_B frag-length 2345
config rf-profile DEFAULT_B rts-threshold 2330
config rf-profile DEFAULT_B preamble Long
config rf-profile DEFAULT_B short-retry 4
config rf-profile DEFAULT_B long-retry 7


create rf-profile DEFAULT_G mode G
config rf-profile DEFAULT_G beacon-interval 40
config rf-profile DEFAULT_G dtim 2
config rf-profile DEFAULT_G frag-length 2345
config rf-profile DEFAULT_G rts-threshold 2330
config rf-profile DEFAULT_G preamble Long
config rf-profile DEFAULT_G short-retry 4
config rf-profile DEFAULT_G long-retry 7



# Security Profile configuration
#
create security-profile Unsecure
config security-profile Unsecure ess-name DEFAULT_ESS
configure security-profile Unsecure dot11-auth open network-auth none encryption none
configure security-profile Unsecure default-user-vlan Default
configure security-profile Unsecure use-dynamic-vlan yes
configure security-profile Unsecure ssid-in-beacon on


create security-profile Secure
config security-profile Secure ess-name Trial
configure security-profile Secure dot11-auth open network-auth none encryption none
configure security-profile Secure default-user-vlan Default
configure security-profile Secure use-dynamic-vlan yes
configure security-profile Secure ssid-in-beacon off



# Antenna Profile configuration
#
create antenna-profile detachable_extr_15901
configure antenna-profile detachable_extr_15901 2.4ghz-gain 4 5ghz-gain 4 



# Wireless Port configuration
#
#
# Wireless port configuration for port 1
#
configure wireless ports 1 ipaddress 0.0.0.0
configure wireless ports 1 location "Unknown Location"
configure wireless ports 1 detected-station-timeout 600
configure wireless ports 1 antenna-profile detachable_extr_15901
configure wireless ports 1 antenna-location indoor
configure wireless ports 1 health-check on
disable wireless ports 1
#
# Wireless port configuration for port 2
#
configure wireless ports 2 ipaddress 10.100.5.7
configure wireless ports 2 location "Unknown Location"
configure wireless ports 2 detected-station-timeout 600
configure wireless ports 2 antenna-profile detachable_extr_15901
configure wireless ports 2 antenna-location indoor
configure wireless ports 2 health-check on
enable wireless ports 2
#
# Wireless port configuration for port 3
#
configure wireless ports 3 ipaddress 0.0.0.0
configure wireless ports 3 location "Unknown Location"
configure wireless ports 3 detected-station-timeout 600
configure wireless ports 3 antenna-profile detachable_extr_15901
configure wireless ports 3 antenna-location indoor
configure wireless ports 3 health-check on
disable wireless ports 3
#
# Wireless port configuration for port 4
#
configure wireless ports 4 ipaddress 0.0.0.0
configure wireless ports 4 location "Unknown Location"
configure wireless ports 4 detected-station-timeout 600
configure wireless ports 4 antenna-profile detachable_extr_15901
configure wireless ports 4 antenna-location indoor
configure wireless ports 4 health-check on
disable wireless ports 4
#
# Wireless port configuration for port 5
#
configure wireless ports 5 ipaddress 0.0.0.0
configure wireless ports 5 location "Unknown Location"
configure wireless ports 5 detected-station-timeout 600
configure wireless ports 5 antenna-profile detachable_extr_15901
configure wireless ports 5 antenna-location indoor
configure wireless ports 5 health-check on
disable wireless ports 5
#
# Wireless port configuration for port 6
#
configure wireless ports 6 ipaddress 0.0.0.0
configure wireless ports 6 location "Unknown Location"
configure wireless ports 6 detected-station-timeout 600
configure wireless ports 6 antenna-profile detachable_extr_15901
configure wireless ports 6 antenna-location indoor
configure wireless ports 6 health-check on
disable wireless ports 6
#
# Wireless port configuration for port 7
#
configure wireless ports 7 ipaddress 0.0.0.0
configure wireless ports 7 location "Unknown Location"
configure wireless ports 7 detected-station-timeout 600
configure wireless ports 7 antenna-profile detachable_extr_15901
configure wireless ports 7 antenna-location indoor
configure wireless ports 7 health-check on
disable wireless ports 7
#
# Wireless port configuration for port 8
#
configure wireless ports 8 ipaddress 0.0.0.0
configure wireless ports 8 location "Unknown Location"
configure wireless ports 8 detected-station-timeout 600
configure wireless ports 8 antenna-profile detachable_extr_15901
configure wireless ports 8 antenna-location indoor
configure wireless ports 8 health-check on
disable wireless ports 8
#
# Wireless port configuration for port 9
#
configure wireless ports 9 ipaddress 0.0.0.0
configure wireless ports 9 location "Unknown Location"
configure wireless ports 9 detected-station-timeout 600
configure wireless ports 9 antenna-profile detachable_extr_15901
configure wireless ports 9 antenna-location indoor
configure wireless ports 9 health-check on
disable wireless ports 9
#
# Wireless port configuration for port 10
#
configure wireless ports 10 ipaddress 0.0.0.0
configure wireless ports 10 location "Unknown Location"
configure wireless ports 10 detected-station-timeout 600
configure wireless ports 10 antenna-profile detachable_extr_15901
configure wireless ports 10 antenna-location indoor
configure wireless ports 10 health-check on
disable wireless ports 10
#
# Wireless port configuration for port 11
#
configure wireless ports 11 ipaddress 0.0.0.0
configure wireless ports 11 location "Unknown Location"
configure wireless ports 11 detected-station-timeout 600
configure wireless ports 11 antenna-profile detachable_extr_15901
configure wireless ports 11 antenna-location indoor
configure wireless ports 11 health-check on
disable wireless ports 11
#
# Wireless port configuration for port 12
#
configure wireless ports 12 ipaddress 0.0.0.0
configure wireless ports 12 location "Unknown Location"
configure wireless ports 12 detected-station-timeout 600
configure wireless ports 12 antenna-profile detachable_extr_15901
configure wireless ports 12 antenna-location indoor
configure wireless ports 12 health-check on
disable wireless ports 12
#
# Wireless port configuration for port 13
#
configure wireless ports 13 ipaddress 0.0.0.0
configure wireless ports 13 location "Unknown Location"
configure wireless ports 13 detected-station-timeout 600
configure wireless ports 13 antenna-profile detachable_extr_15901
configure wireless ports 13 antenna-location indoor
configure wireless ports 13 health-check on
disable wireless ports 13
#
# Wireless port configuration for port 14
#
configure wireless ports 14 ipaddress 0.0.0.0
configure wireless ports 14 location "Unknown Location"
configure wireless ports 14 detected-station-timeout 600
configure wireless ports 14 antenna-profile detachable_extr_15901
configure wireless ports 14 antenna-location indoor
configure wireless ports 14 health-check on
disable wireless ports 14
#
# Wireless port configuration for port 15
#
configure wireless ports 15 ipaddress 0.0.0.0
configure wireless ports 15 location "Unknown Location"
configure wireless ports 15 detected-station-timeout 600
configure wireless ports 15 antenna-profile detachable_extr_15901
configure wireless ports 15 antenna-location indoor
configure wireless ports 15 health-check on
disable wireless ports 15
#
# Wireless port configuration for port 16
#
configure wireless ports 16 ipaddress 0.0.0.0
configure wireless ports 16 location "Unknown Location"
configure wireless ports 16 detected-station-timeout 600
configure wireless ports 16 antenna-profile detachable_extr_15901
configure wireless ports 16 antenna-location indoor
configure wireless ports 16 health-check on
disable wireless ports 16
#
# Wireless port configuration for port 17
#
configure wireless ports 17 ipaddress 0.0.0.0
configure wireless ports 17 location "Unknown Location"
configure wireless ports 17 detected-station-timeout 600
configure wireless ports 17 antenna-profile detachable_extr_15901
configure wireless ports 17 antenna-location indoor
configure wireless ports 17 health-check on
disable wireless ports 17
#
# Wireless port configuration for port 18
#
configure wireless ports 18 ipaddress 0.0.0.0
configure wireless ports 18 location "Unknown Location"
configure wireless ports 18 detected-station-timeout 600
configure wireless ports 18 antenna-profile detachable_extr_15901
configure wireless ports 18 antenna-location indoor
configure wireless ports 18 health-check on
disable wireless ports 18
#
# Wireless port configuration for port 19
#
configure wireless ports 19 ipaddress 0.0.0.0
configure wireless ports 19 location "Unknown Location"
configure wireless ports 19 detected-station-timeout 600
configure wireless ports 19 antenna-profile detachable_extr_15901
configure wireless ports 19 antenna-location indoor
configure wireless ports 19 health-check on
disable wireless ports 19
#
# Wireless port configuration for port 20
#
configure wireless ports 20 ipaddress 0.0.0.0
configure wireless ports 20 location "Unknown Location"
configure wireless ports 20 detected-station-timeout 600
configure wireless ports 20 antenna-profile detachable_extr_15901
configure wireless ports 20 antenna-location indoor
configure wireless ports 20 health-check on
disable wireless ports 20
#
# Wireless port configuration for port 21
#
configure wireless ports 21 ipaddress 0.0.0.0
configure wireless ports 21 location "Unknown Location"
configure wireless ports 21 detected-station-timeout 600
configure wireless ports 21 antenna-profile detachable_extr_15901
configure wireless ports 21 antenna-location indoor
configure wireless ports 21 health-check on
disable wireless ports 21
#
# Wireless port configuration for port 22
#
configure wireless ports 22 ipaddress 0.0.0.0
configure wireless ports 22 location "Unknown Location"
configure wireless ports 22 detected-station-timeout 600
configure wireless ports 22 antenna-profile detachable_extr_15901
configure wireless ports 22 antenna-location indoor
configure wireless ports 22 health-check on
disable wireless ports 22
#
# Wireless port configuration for port 23
#
configure wireless ports 23 ipaddress 0.0.0.0
configure wireless ports 23 location "Unknown Location"
configure wireless ports 23 detected-station-timeout 600
configure wireless ports 23 antenna-profile detachable_extr_15901
configure wireless ports 23 antenna-location indoor
configure wireless ports 23 health-check on
disable wireless ports 23
#
# Wireless port configuration for port 24
#
configure wireless ports 24 ipaddress 0.0.0.0
configure wireless ports 24 location "Unknown Location"
configure wireless ports 24 detected-station-timeout 600
configure wireless ports 24 antenna-profile detachable_extr_15901
configure wireless ports 24 antenna-location indoor
configure wireless ports 24 health-check on
disable wireless ports 24

# Wireless Interface configuration
#
#
# Wireless Interface Configuration for Interface 1:1
#
enable wireless port 1 interface 1
configure wireless port 1 interface 1 rf-profile DEFAULT_A
configure wireless port 1 interface 1 security-profile Unsecure
configure wireless port 1 interface 1 transmit-power FULL
configure wireless port 1 interface 1 channel 0
configure wireless port 1 interface 1 transmit-rate auto
configure wireless port 1 interface 1 max-clients 100
configure wireless port 1 interface 1 wireless-bridging on
enable wireless port 1 interface 1 iapp
disable wireless port 1 interface 1 svp
#
# Wireless Interface Configuration for Interface 1:2
#
enable wireless port 1 interface 2
configure wireless port 1 interface 2 rf-profile DEFAULT_BG
configure wireless port 1 interface 2 security-profile Unsecure
configure wireless port 1 interface 2 transmit-power FULL
configure wireless port 1 interface 2 channel 0
configure wireless port 1 interface 2 transmit-rate auto
configure wireless port 1 interface 2 max-clients 100
configure wireless port 1 interface 2 wireless-bridging on
enable wireless port 1 interface 2 iapp
disable wireless port 1 interface 2 svp
#
# Wireless Interface Configuration for Interface 2:1
#
enable wireless port 2 interface 1
configure wireless port 2 interface 1 rf-profile DEFAULT_A
configure wireless port 2 interface 1 security-profile Unsecure
configure wireless port 2 interface 1 transmit-power FULL
configure wireless port 2 interface 1 channel 0
configure wireless port 2 interface 1 transmit-rate auto
configure wireless port 2 interface 1 max-clients 100
configure wireless port 2 interface 1 wireless-bridging on
enable wireless port 2 interface 1 iapp
disable wireless port 2 interface 1 svp
#
# Wireless Interface Configuration for Interface 2:2
#
enable wireless port 2 interface 2
configure wireless port 2 interface 2 rf-profile DEFAULT_BG
configure wireless port 2 interface 2 security-profile Unsecure
configure wireless port 2 interface 2 transmit-power FULL
configure wireless port 2 interface 2 channel 0
configure wireless port 2 interface 2 transmit-rate auto
configure wireless port 2 interface 2 max-clients 100
configure wireless port 2 interface 2 wireless-bridging on
enable wireless port 2 interface 2 iapp
disable wireless port 2 interface 2 svp
#
# Wireless Interface Configuration for Interface 3:1
#
enable wireless port 3 interface 1
configure wireless port 3 interface 1 rf-profile DEFAULT_A
configure wireless port 3 interface 1 security-profile Unsecure
configure wireless port 3 interface 1 transmit-power FULL
configure wireless port 3 interface 1 channel 0
configure wireless port 3 interface 1 transmit-rate auto
configure wireless port 3 interface 1 max-clients 100
configure wireless port 3 interface 1 wireless-bridging on
enable wireless port 3 interface 1 iapp
disable wireless port 3 interface 1 svp
#
# Wireless Interface Configuration for Interface 3:2
#
enable wireless port 3 interface 2
configure wireless port 3 interface 2 rf-profile DEFAULT_BG
configure wireless port 3 interface 2 security-profile Unsecure
configure wireless port 3 interface 2 transmit-power FULL
configure wireless port 3 interface 2 channel 0
configure wireless port 3 interface 2 transmit-rate auto
configure wireless port 3 interface 2 max-clients 100
configure wireless port 3 interface 2 wireless-bridging on
enable wireless port 3 interface 2 iapp
disable wireless port 3 interface 2 svp
#
# Wireless Interface Configuration for Interface 4:1
#
enable wireless port 4 interface 1
configure wireless port 4 interface 1 rf-profile DEFAULT_A
configure wireless port 4 interface 1 security-profile Unsecure
configure wireless port 4 interface 1 transmit-power FULL
configure wireless port 4 interface 1 channel 0
configure wireless port 4 interface 1 transmit-rate auto
configure wireless port 4 interface 1 max-clients 100
configure wireless port 4 interface 1 wireless-bridging on
enable wireless port 4 interface 1 iapp
disable wireless port 4 interface 1 svp
#
# Wireless Interface Configuration for Interface 4:2
#
enable wireless port 4 interface 2
configure wireless port 4 interface 2 rf-profile DEFAULT_BG
configure wireless port 4 interface 2 security-profile Unsecure
configure wireless port 4 interface 2 transmit-power FULL
configure wireless port 4 interface 2 channel 0
configure wireless port 4 interface 2 transmit-rate auto
configure wireless port 4 interface 2 max-clients 100
configure wireless port 4 interface 2 wireless-bridging on
enable wireless port 4 interface 2 iapp
disable wireless port 4 interface 2 svp
#
# Wireless Interface Configuration for Interface 5:1
#
enable wireless port 5 interface 1
configure wireless port 5 interface 1 rf-profile DEFAULT_A
configure wireless port 5 interface 1 security-profile Unsecure
configure wireless port 5 interface 1 transmit-power FULL
configure wireless port 5 interface 1 channel 0
configure wireless port 5 interface 1 transmit-rate auto
configure wireless port 5 interface 1 max-clients 100
configure wireless port 5 interface 1 wireless-bridging on
enable wireless port 5 interface 1 iapp
disable wireless port 5 interface 1 svp
#
# Wireless Interface Configuration for Interface 5:2
#
enable wireless port 5 interface 2
configure wireless port 5 interface 2 rf-profile DEFAULT_BG
configure wireless port 5 interface 2 security-profile Unsecure
configure wireless port 5 interface 2 transmit-power FULL
configure wireless port 5 interface 2 channel 0
configure wireless port 5 interface 2 transmit-rate auto
configure wireless port 5 interface 2 max-clients 100
configure wireless port 5 interface 2 wireless-bridging on
enable wireless port 5 interface 2 iapp
disable wireless port 5 interface 2 svp
#
# Wireless Interface Configuration for Interface 6:1
#
enable wireless port 6 interface 1
configure wireless port 6 interface 1 rf-profile DEFAULT_A
configure wireless port 6 interface 1 security-profile Unsecure
configure wireless port 6 interface 1 transmit-power FULL
configure wireless port 6 interface 1 channel 0
configure wireless port 6 interface 1 transmit-rate auto
configure wireless port 6 interface 1 max-clients 100
configure wireless port 6 interface 1 wireless-bridging on
enable wireless port 6 interface 1 iapp
disable wireless port 6 interface 1 svp
#
# Wireless Interface Configuration for Interface 6:2
#
enable wireless port 6 interface 2
configure wireless port 6 interface 2 rf-profile DEFAULT_BG
configure wireless port 6 interface 2 security-profile Unsecure
configure wireless port 6 interface 2 transmit-power FULL
configure wireless port 6 interface 2 channel 0
configure wireless port 6 interface 2 transmit-rate auto
configure wireless port 6 interface 2 max-clients 100
configure wireless port 6 interface 2 wireless-bridging on
enable wireless port 6 interface 2 iapp
disable wireless port 6 interface 2 svp
#
# Wireless Interface Configuration for Interface 7:1
#
enable wireless port 7 interface 1
configure wireless port 7 interface 1 rf-profile DEFAULT_A
configure wireless port 7 interface 1 security-profile Unsecure
configure wireless port 7 interface 1 transmit-power FULL
configure wireless port 7 interface 1 channel 0
configure wireless port 7 interface 1 transmit-rate auto
configure wireless port 7 interface 1 max-clients 100
configure wireless port 7 interface 1 wireless-bridging on
enable wireless port 7 interface 1 iapp
disable wireless port 7 interface 1 svp
#
# Wireless Interface Configuration for Interface 7:2
#
enable wireless port 7 interface 2
configure wireless port 7 interface 2 rf-profile DEFAULT_BG
configure wireless port 7 interface 2 security-profile Unsecure
configure wireless port 7 interface 2 transmit-power FULL
configure wireless port 7 interface 2 channel 0
configure wireless port 7 interface 2 transmit-rate auto
configure wireless port 7 interface 2 max-clients 100
configure wireless port 7 interface 2 wireless-bridging on
enable wireless port 7 interface 2 iapp
disable wireless port 7 interface 2 svp
#
# Wireless Interface Configuration for Interface 8:1
#
enable wireless port 8 interface 1
configure wireless port 8 interface 1 rf-profile DEFAULT_A
configure wireless port 8 interface 1 security-profile Unsecure
configure wireless port 8 interface 1 transmit-power FULL
configure wireless port 8 interface 1 channel 0
configure wireless port 8 interface 1 transmit-rate auto
configure wireless port 8 interface 1 max-clients 100
configure wireless port 8 interface 1 wireless-bridging on
enable wireless port 8 interface 1 iapp
disable wireless port 8 interface 1 svp
#
# Wireless Interface Configuration for Interface 8:2
#
enable wireless port 8 interface 2
configure wireless port 8 interface 2 rf-profile DEFAULT_BG
configure wireless port 8 interface 2 security-profile Unsecure
configure wireless port 8 interface 2 transmit-power FULL
configure wireless port 8 interface 2 channel 0
configure wireless port 8 interface 2 transmit-rate auto
configure wireless port 8 interface 2 max-clients 100
configure wireless port 8 interface 2 wireless-bridging on
enable wireless port 8 interface 2 iapp
disable wireless port 8 interface 2 svp
#
# Wireless Interface Configuration for Interface 9:1
#
enable wireless port 9 interface 1
configure wireless port 9 interface 1 rf-profile DEFAULT_A
configure wireless port 9 interface 1 security-profile Unsecure
configure wireless port 9 interface 1 transmit-power FULL
configure wireless port 9 interface 1 channel 0
configure wireless port 9 interface 1 transmit-rate auto
configure wireless port 9 interface 1 max-clients 100
configure wireless port 9 interface 1 wireless-bridging on
enable wireless port 9 interface 1 iapp
disable wireless port 9 interface 1 svp
#
# Wireless Interface Configuration for Interface 9:2
#
enable wireless port 9 interface 2
configure wireless port 9 interface 2 rf-profile DEFAULT_BG
configure wireless port 9 interface 2 security-profile Unsecure
configure wireless port 9 interface 2 transmit-power FULL
configure wireless port 9 interface 2 channel 0
configure wireless port 9 interface 2 transmit-rate auto
configure wireless port 9 interface 2 max-clients 100
configure wireless port 9 interface 2 wireless-bridging on
enable wireless port 9 interface 2 iapp
disable wireless port 9 interface 2 svp
#
# Wireless Interface Configuration for Interface 10:1
#
enable wireless port 10 interface 1
configure wireless port 10 interface 1 rf-profile DEFAULT_A
configure wireless port 10 interface 1 security-profile Unsecure
configure wireless port 10 interface 1 transmit-power FULL
configure wireless port 10 interface 1 channel 0
configure wireless port 10 interface 1 transmit-rate auto
configure wireless port 10 interface 1 max-clients 100
configure wireless port 10 interface 1 wireless-bridging on
enable wireless port 10 interface 1 iapp
disable wireless port 10 interface 1 svp
#
# Wireless Interface Configuration for Interface 10:2
#
enable wireless port 10 interface 2
configure wireless port 10 interface 2 rf-profile DEFAULT_BG
configure wireless port 10 interface 2 security-profile Unsecure
configure wireless port 10 interface 2 transmit-power FULL
configure wireless port 10 interface 2 channel 0
configure wireless port 10 interface 2 transmit-rate auto
configure wireless port 10 interface 2 max-clients 100
configure wireless port 10 interface 2 wireless-bridging on
enable wireless port 10 interface 2 iapp
disable wireless port 10 interface 2 svp
#
# Wireless Interface Configuration for Interface 11:1
#
enable wireless port 11 interface 1
configure wireless port 11 interface 1 rf-profile DEFAULT_A
configure wireless port 11 interface 1 security-profile Unsecure
configure wireless port 11 interface 1 transmit-power FULL
configure wireless port 11 interface 1 channel 0
configure wireless port 11 interface 1 transmit-rate auto
configure wireless port 11 interface 1 max-clients 100
configure wireless port 11 interface 1 wireless-bridging on
enable wireless port 11 interface 1 iapp
disable wireless port 11 interface 1 svp
#
# Wireless Interface Configuration for Interface 11:2
#
enable wireless port 11 interface 2
configure wireless port 11 interface 2 rf-profile DEFAULT_BG
configure wireless port 11 interface 2 security-profile Unsecure
configure wireless port 11 interface 2 transmit-power FULL
configure wireless port 11 interface 2 channel 0
configure wireless port 11 interface 2 transmit-rate auto
configure wireless port 11 interface 2 max-clients 100
configure wireless port 11 interface 2 wireless-bridging on
enable wireless port 11 interface 2 iapp
disable wireless port 11 interface 2 svp
#
# Wireless Interface Configuration for Interface 12:1
#
enable wireless port 12 interface 1
configure wireless port 12 interface 1 rf-profile DEFAULT_A
configure wireless port 12 interface 1 security-profile Unsecure
configure wireless port 12 interface 1 transmit-power FULL
configure wireless port 12 interface 1 channel 0
configure wireless port 12 interface 1 transmit-rate auto
configure wireless port 12 interface 1 max-clients 100
configure wireless port 12 interface 1 wireless-bridging on
enable wireless port 12 interface 1 iapp
disable wireless port 12 interface 1 svp
#
# Wireless Interface Configuration for Interface 12:2
#
enable wireless port 12 interface 2
configure wireless port 12 interface 2 rf-profile DEFAULT_BG
configure wireless port 12 interface 2 security-profile Unsecure
configure wireless port 12 interface 2 transmit-power FULL
configure wireless port 12 interface 2 channel 0
configure wireless port 12 interface 2 transmit-rate auto
configure wireless port 12 interface 2 max-clients 100
configure wireless port 12 interface 2 wireless-bridging on
enable wireless port 12 interface 2 iapp
disable wireless port 12 interface 2 svp
#
# Wireless Interface Configuration for Interface 13:1
#
enable wireless port 13 interface 1
configure wireless port 13 interface 1 rf-profile DEFAULT_A
configure wireless port 13 interface 1 security-profile Unsecure
configure wireless port 13 interface 1 transmit-power FULL
configure wireless port 13 interface 1 channel 0
configure wireless port 13 interface 1 transmit-rate auto
configure wireless port 13 interface 1 max-clients 100
configure wireless port 13 interface 1 wireless-bridging on
enable wireless port 13 interface 1 iapp
disable wireless port 13 interface 1 svp
#
# Wireless Interface Configuration for Interface 13:2
#
enable wireless port 13 interface 2
configure wireless port 13 interface 2 rf-profile DEFAULT_BG
configure wireless port 13 interface 2 security-profile Unsecure
configure wireless port 13 interface 2 transmit-power FULL
configure wireless port 13 interface 2 channel 0
configure wireless port 13 interface 2 transmit-rate auto
configure wireless port 13 interface 2 max-clients 100
configure wireless port 13 interface 2 wireless-bridging on
enable wireless port 13 interface 2 iapp
disable wireless port 13 interface 2 svp
#
# Wireless Interface Configuration for Interface 14:1
#
enable wireless port 14 interface 1
configure wireless port 14 interface 1 rf-profile DEFAULT_A
configure wireless port 14 interface 1 security-profile Unsecure
configure wireless port 14 interface 1 transmit-power FULL
configure wireless port 14 interface 1 channel 0
configure wireless port 14 interface 1 transmit-rate auto
configure wireless port 14 interface 1 max-clients 100
configure wireless port 14 interface 1 wireless-bridging on
enable wireless port 14 interface 1 iapp
disable wireless port 14 interface 1 svp
#
# Wireless Interface Configuration for Interface 14:2
#
enable wireless port 14 interface 2
configure wireless port 14 interface 2 rf-profile DEFAULT_BG
configure wireless port 14 interface 2 security-profile Unsecure
configure wireless port 14 interface 2 transmit-power FULL
configure wireless port 14 interface 2 channel 0
configure wireless port 14 interface 2 transmit-rate auto
configure wireless port 14 interface 2 max-clients 100
configure wireless port 14 interface 2 wireless-bridging on
enable wireless port 14 interface 2 iapp
disable wireless port 14 interface 2 svp
#
# Wireless Interface Configuration for Interface 15:1
#
enable wireless port 15 interface 1
configure wireless port 15 interface 1 rf-profile DEFAULT_A
configure wireless port 15 interface 1 security-profile Unsecure
configure wireless port 15 interface 1 transmit-power FULL
configure wireless port 15 interface 1 channel 0
configure wireless port 15 interface 1 transmit-rate auto
configure wireless port 15 interface 1 max-clients 100
configure wireless port 15 interface 1 wireless-bridging on
enable wireless port 15 interface 1 iapp
disable wireless port 15 interface 1 svp
#
# Wireless Interface Configuration for Interface 15:2
#
enable wireless port 15 interface 2
configure wireless port 15 interface 2 rf-profile DEFAULT_BG
configure wireless port 15 interface 2 security-profile Unsecure
configure wireless port 15 interface 2 transmit-power FULL
configure wireless port 15 interface 2 channel 0
configure wireless port 15 interface 2 transmit-rate auto
configure wireless port 15 interface 2 max-clients 100
configure wireless port 15 interface 2 wireless-bridging on
enable wireless port 15 interface 2 iapp
disable wireless port 15 interface 2 svp
#
# Wireless Interface Configuration for Interface 16:1
#
enable wireless port 16 interface 1
configure wireless port 16 interface 1 rf-profile DEFAULT_A
configure wireless port 16 interface 1 security-profile Unsecure
configure wireless port 16 interface 1 transmit-power FULL
configure wireless port 16 interface 1 channel 0
configure wireless port 16 interface 1 transmit-rate auto
configure wireless port 16 interface 1 max-clients 100
configure wireless port 16 interface 1 wireless-bridging on
enable wireless port 16 interface 1 iapp
disable wireless port 16 interface 1 svp
#
# Wireless Interface Configuration for Interface 16:2
#
enable wireless port 16 interface 2
configure wireless port 16 interface 2 rf-profile DEFAULT_BG
configure wireless port 16 interface 2 security-profile Unsecure
configure wireless port 16 interface 2 transmit-power FULL
configure wireless port 16 interface 2 channel 0
configure wireless port 16 interface 2 transmit-rate auto
configure wireless port 16 interface 2 max-clients 100
configure wireless port 16 interface 2 wireless-bridging on
enable wireless port 16 interface 2 iapp
disable wireless port 16 interface 2 svp
#
# Wireless Interface Configuration for Interface 17:1
#
enable wireless port 17 interface 1
configure wireless port 17 interface 1 rf-profile DEFAULT_A
configure wireless port 17 interface 1 security-profile Unsecure
configure wireless port 17 interface 1 transmit-power FULL
configure wireless port 17 interface 1 channel 0
configure wireless port 17 interface 1 transmit-rate auto
configure wireless port 17 interface 1 max-clients 100
configure wireless port 17 interface 1 wireless-bridging on
enable wireless port 17 interface 1 iapp
disable wireless port 17 interface 1 svp
#
# Wireless Interface Configuration for Interface 17:2
#
enable wireless port 17 interface 2
configure wireless port 17 interface 2 rf-profile DEFAULT_BG
configure wireless port 17 interface 2 security-profile Unsecure
configure wireless port 17 interface 2 transmit-power FULL
configure wireless port 17 interface 2 channel 0
configure wireless port 17 interface 2 transmit-rate auto
configure wireless port 17 interface 2 max-clients 100
configure wireless port 17 interface 2 wireless-bridging on
enable wireless port 17 interface 2 iapp
disable wireless port 17 interface 2 svp
#
# Wireless Interface Configuration for Interface 18:1
#
enable wireless port 18 interface 1
configure wireless port 18 interface 1 rf-profile DEFAULT_A
configure wireless port 18 interface 1 security-profile Unsecure
configure wireless port 18 interface 1 transmit-power FULL
configure wireless port 18 interface 1 channel 0
configure wireless port 18 interface 1 transmit-rate auto
configure wireless port 18 interface 1 max-clients 100
configure wireless port 18 interface 1 wireless-bridging on
enable wireless port 18 interface 1 iapp
disable wireless port 18 interface 1 svp
#
# Wireless Interface Configuration for Interface 18:2
#
enable wireless port 18 interface 2
configure wireless port 18 interface 2 rf-profile DEFAULT_BG
configure wireless port 18 interface 2 security-profile Unsecure
configure wireless port 18 interface 2 transmit-power FULL
configure wireless port 18 interface 2 channel 0
configure wireless port 18 interface 2 transmit-rate auto
configure wireless port 18 interface 2 max-clients 100
configure wireless port 18 interface 2 wireless-bridging on
enable wireless port 18 interface 2 iapp
disable wireless port 18 interface 2 svp
#
# Wireless Interface Configuration for Interface 19:1
#
enable wireless port 19 interface 1
configure wireless port 19 interface 1 rf-profile DEFAULT_A
configure wireless port 19 interface 1 security-profile Unsecure
configure wireless port 19 interface 1 transmit-power FULL
configure wireless port 19 interface 1 channel 0
configure wireless port 19 interface 1 transmit-rate auto
configure wireless port 19 interface 1 max-clients 100
configure wireless port 19 interface 1 wireless-bridging on
enable wireless port 19 interface 1 iapp
disable wireless port 19 interface 1 svp
#
# Wireless Interface Configuration for Interface 19:2
#
enable wireless port 19 interface 2
configure wireless port 19 interface 2 rf-profile DEFAULT_BG
configure wireless port 19 interface 2 security-profile Unsecure
configure wireless port 19 interface 2 transmit-power FULL
configure wireless port 19 interface 2 channel 0
configure wireless port 19 interface 2 transmit-rate auto
configure wireless port 19 interface 2 max-clients 100
configure wireless port 19 interface 2 wireless-bridging on
enable wireless port 19 interface 2 iapp
disable wireless port 19 interface 2 svp
#
# Wireless Interface Configuration for Interface 20:1
#
enable wireless port 20 interface 1
configure wireless port 20 interface 1 rf-profile DEFAULT_A
configure wireless port 20 interface 1 security-profile Unsecure
configure wireless port 20 interface 1 transmit-power FULL
configure wireless port 20 interface 1 channel 0
configure wireless port 20 interface 1 transmit-rate auto
configure wireless port 20 interface 1 max-clients 100
configure wireless port 20 interface 1 wireless-bridging on
enable wireless port 20 interface 1 iapp
disable wireless port 20 interface 1 svp
#
# Wireless Interface Configuration for Interface 20:2
#
enable wireless port 20 interface 2
configure wireless port 20 interface 2 rf-profile DEFAULT_BG
configure wireless port 20 interface 2 security-profile Unsecure
configure wireless port 20 interface 2 transmit-power FULL
configure wireless port 20 interface 2 channel 0
configure wireless port 20 interface 2 transmit-rate auto
configure wireless port 20 interface 2 max-clients 100
configure wireless port 20 interface 2 wireless-bridging on
enable wireless port 20 interface 2 iapp
disable wireless port 20 interface 2 svp
#
# Wireless Interface Configuration for Interface 21:1
#
enable wireless port 21 interface 1
configure wireless port 21 interface 1 rf-profile DEFAULT_A
configure wireless port 21 interface 1 security-profile Unsecure
configure wireless port 21 interface 1 transmit-power FULL
configure wireless port 21 interface 1 channel 0
configure wireless port 21 interface 1 transmit-rate auto
configure wireless port 21 interface 1 max-clients 100
configure wireless port 21 interface 1 wireless-bridging on
enable wireless port 21 interface 1 iapp
disable wireless port 21 interface 1 svp
#
# Wireless Interface Configuration for Interface 21:2
#
enable wireless port 21 interface 2
configure wireless port 21 interface 2 rf-profile DEFAULT_BG
configure wireless port 21 interface 2 security-profile Unsecure
configure wireless port 21 interface 2 transmit-power FULL
configure wireless port 21 interface 2 channel 0
configure wireless port 21 interface 2 transmit-rate auto
configure wireless port 21 interface 2 max-clients 100
configure wireless port 21 interface 2 wireless-bridging on
enable wireless port 21 interface 2 iapp
disable wireless port 21 interface 2 svp
#
# Wireless Interface Configuration for Interface 22:1
#
enable wireless port 22 interface 1
configure wireless port 22 interface 1 rf-profile DEFAULT_A
configure wireless port 22 interface 1 security-profile Unsecure
configure wireless port 22 interface 1 transmit-power FULL
configure wireless port 22 interface 1 channel 0
configure wireless port 22 interface 1 transmit-rate auto
configure wireless port 22 interface 1 max-clients 100
configure wireless port 22 interface 1 wireless-bridging on
enable wireless port 22 interface 1 iapp
disable wireless port 22 interface 1 svp
#
# Wireless Interface Configuration for Interface 22:2
#
enable wireless port 22 interface 2
configure wireless port 22 interface 2 rf-profile DEFAULT_BG
configure wireless port 22 interface 2 security-profile Unsecure
configure wireless port 22 interface 2 transmit-power FULL
configure wireless port 22 interface 2 channel 0
configure wireless port 22 interface 2 transmit-rate auto
configure wireless port 22 interface 2 max-clients 100
configure wireless port 22 interface 2 wireless-bridging on
enable wireless port 22 interface 2 iapp
disable wireless port 22 interface 2 svp
#
# Wireless Interface Configuration for Interface 23:1
#
enable wireless port 23 interface 1
configure wireless port 23 interface 1 rf-profile DEFAULT_A
configure wireless port 23 interface 1 security-profile Unsecure
configure wireless port 23 interface 1 transmit-power FULL
configure wireless port 23 interface 1 channel 0
configure wireless port 23 interface 1 transmit-rate auto
configure wireless port 23 interface 1 max-clients 100
configure wireless port 23 interface 1 wireless-bridging on
enable wireless port 23 interface 1 iapp
disable wireless port 23 interface 1 svp
#
# Wireless Interface Configuration for Interface 23:2
#
enable wireless port 23 interface 2
configure wireless port 23 interface 2 rf-profile DEFAULT_BG
configure wireless port 23 interface 2 security-profile Unsecure
configure wireless port 23 interface 2 transmit-power FULL
configure wireless port 23 interface 2 channel 0
configure wireless port 23 interface 2 transmit-rate auto
configure wireless port 23 interface 2 max-clients 100
configure wireless port 23 interface 2 wireless-bridging on
enable wireless port 23 interface 2 iapp
disable wireless port 23 interface 2 svp
#
# Wireless Interface Configuration for Interface 24:1
#
enable wireless port 24 interface 1
configure wireless port 24 interface 1 rf-profile DEFAULT_A
configure wireless port 24 interface 1 security-profile Unsecure
configure wireless port 24 interface 1 transmit-power FULL
configure wireless port 24 interface 1 channel 0
configure wireless port 24 interface 1 transmit-rate auto
configure wireless port 24 interface 1 max-clients 100
configure wireless port 24 interface 1 wireless-bridging on
enable wireless port 24 interface 1 iapp
disable wireless port 24 interface 1 svp
#
# Wireless Interface Configuration for Interface 24:2
#
enable wireless port 24 interface 2
configure wireless port 24 interface 2 rf-profile DEFAULT_BG
configure wireless port 24 interface 2 security-profile Unsecure
configure wireless port 24 interface 2 transmit-power FULL
configure wireless port 24 interface 2 channel 0
configure wireless port 24 interface 2 transmit-rate auto
configure wireless port 24 interface 2 max-clients 100
configure wireless port 24 interface 2 wireless-bridging on
enable wireless port 24 interface 2 iapp
disable wireless port 24 interface 2 svp

# Wireless AP scan, client scan and client history configuration 
#
#
# Wireless Interface Configuration for Interface 1:1
#
disable wireless port 1 interface 1 ap-scan 
disable wireless port 1 interface 1 ap-scan off-channel
configure wireless port 1 interface 1 ap-scan off-channel all 
configure wireless port 1 interface 1 ap-scan send-probe off 
configure wireless port 1 interface 1 ap-scan probe-interval 100 
configure wireless port 1 interface 1 ap-scan off-channel max-wait 600 
configure wireless port 1 interface 1 ap-scan off-channel min-wait 60 
configure wireless port 1 interface 1 ap-scan results size 128 
configure wireless port 1 interface 1 ap-scan results timeout 300  
configure wireless port 1 interface 1 ap-scan added-trap off  
configure wireless port 1 interface 1 ap-scan removed-trap off  
configure wireless port 1 interface 1 ap-scan updated-trap off 
configure wireless port 1 interface 1 ap-scan off-channel continuous off
disable wireless port 1 interface 1 client-scan 
configure wireless port 1 interface 1 client-scan results size 128 
configure wireless port 1 interface 1 client-scan results timeout 600 
configure wireless port 1 interface 1 client-scan added-trap off 
configure wireless port 1 interface 1 client-scan removed-trap off 
disable wireless port 1 interface 1 client-history
configure wireless port 1 interface 1 client-history size 128
configure wireless port 1 interface 1 client-history timeout 600
#
# Wireless Interface Configuration for Interface 1:2
#
disable wireless port 1 interface 2 ap-scan 
disable wireless port 1 interface 2 ap-scan off-channel
configure wireless port 1 interface 2 ap-scan off-channel all 
configure wireless port 1 interface 2 ap-scan send-probe off 
configure wireless port 1 interface 2 ap-scan probe-interval 100 
configure wireless port 1 interface 2 ap-scan off-channel max-wait 600 
configure wireless port 1 interface 2 ap-scan off-channel min-wait 60 
configure wireless port 1 interface 2 ap-scan results size 128 
configure wireless port 1 interface 2 ap-scan results timeout 300  
configure wireless port 1 interface 2 ap-scan added-trap off  
configure wireless port 1 interface 2 ap-scan removed-trap off  
configure wireless port 1 interface 2 ap-scan updated-trap off 
configure wireless port 1 interface 2 ap-scan off-channel continuous off
disable wireless port 1 interface 2 client-scan 
configure wireless port 1 interface 2 client-scan results size 128 
configure wireless port 1 interface 2 client-scan results timeout 600 
configure wireless port 1 interface 2 client-scan added-trap off 
configure wireless port 1 interface 2 client-scan removed-trap off 
disable wireless port 1 interface 2 client-history
configure wireless port 1 interface 2 client-history size 128
configure wireless port 1 interface 2 client-history timeout 600
#
# Wireless Interface Configuration for Interface 2:1
#
disable wireless port 2 interface 1 ap-scan 
disable wireless port 2 interface 1 ap-scan off-channel
configure wireless port 2 interface 1 ap-scan off-channel all 
configure wireless port 2 interface 1 ap-scan send-probe off 
configure wireless port 2 interface 1 ap-scan probe-interval 100 
configure wireless port 2 interface 1 ap-scan off-channel max-wait 600 
configure wireless port 2 interface 1 ap-scan off-channel min-wait 60 
configure wireless port 2 interface 1 ap-scan results size 128 
configure wireless port 2 interface 1 ap-scan results timeout 300  
configure wireless port 2 interface 1 ap-scan added-trap off  
configure wireless port 2 interface 1 ap-scan removed-trap off  
configure wireless port 2 interface 1 ap-scan updated-trap off 
configure wireless port 2 interface 1 ap-scan off-channel continuous off
disable wireless port 2 interface 1 client-scan 
configure wireless port 2 interface 1 client-scan results size 128 
configure wireless port 2 interface 1 client-scan results timeout 600 
configure wireless port 2 interface 1 client-scan added-trap off 
configure wireless port 2 interface 1 client-scan removed-trap off 
disable wireless port 2 interface 1 client-history
configure wireless port 2 interface 1 client-history size 128
configure wireless port 2 interface 1 client-history timeout 600
#
# Wireless Interface Configuration for Interface 2:2
#
disable wireless port 2 interface 2 ap-scan 
disable wireless port 2 interface 2 ap-scan off-channel
configure wireless port 2 interface 2 ap-scan off-channel all 
configure wireless port 2 interface 2 ap-scan send-probe off 
configure wireless port 2 interface 2 ap-scan probe-interval 100 
configure wireless port 2 interface 2 ap-scan off-channel max-wait 600 
configure wireless port 2 interface 2 ap-scan off-channel min-wait 60 
configure wireless port 2 interface 2 ap-scan results size 128 
configure wireless port 2 interface 2 ap-scan results timeout 300  
configure wireless port 2 interface 2 ap-scan added-trap off  
configure wireless port 2 interface 2 ap-scan removed-trap off  
configure wireless port 2 interface 2 ap-scan updated-trap off 
configure wireless port 2 interface 2 ap-scan off-channel continuous off
disable wireless port 2 interface 2 client-scan 
configure wireless port 2 interface 2 client-scan results size 128 
configure wireless port 2 interface 2 client-scan results timeout 600 
configure wireless port 2 interface 2 client-scan added-trap off 
configure wireless port 2 interface 2 client-scan removed-trap off 
disable wireless port 2 interface 2 client-history
configure wireless port 2 interface 2 client-history size 128
configure wireless port 2 interface 2 client-history timeout 600
#
# Wireless Interface Configuration for Interface 3:1
#
disable wireless port 3 interface 1 ap-scan 
disable wireless port 3 interface 1 ap-scan off-channel
configure wireless port 3 interface 1 ap-scan off-channel all 
configure wireless port 3 interface 1 ap-scan send-probe off 
configure wireless port 3 interface 1 ap-scan probe-interval 100 
configure wireless port 3 interface 1 ap-scan off-channel max-wait 600 
configure wireless port 3 interface 1 ap-scan off-channel min-wait 60 
configure wireless port 3 interface 1 ap-scan results size 128 
configure wireless port 3 interface 1 ap-scan results timeout 300  
configure wireless port 3 interface 1 ap-scan added-trap off  
configure wireless port 3 interface 1 ap-scan removed-trap off  
configure wireless port 3 interface 1 ap-scan updated-trap off 
configure wireless port 3 interface 1 ap-scan off-channel continuous off
disable wireless port 3 interface 1 client-scan 
configure wireless port 3 interface 1 client-scan results size 128 
configure wireless port 3 interface 1 client-scan results timeout 600 
configure wireless port 3 interface 1 client-scan added-trap off 
configure wireless port 3 interface 1 client-scan removed-trap off 
disable wireless port 3 interface 1 client-history
configure wireless port 3 interface 1 client-history size 128
configure wireless port 3 interface 1 client-history timeout 600
#
# Wireless Interface Configuration for Interface 3:2
#
disable wireless port 3 interface 2 ap-scan 
disable wireless port 3 interface 2 ap-scan off-channel
configure wireless port 3 interface 2 ap-scan off-channel all 
configure wireless port 3 interface 2 ap-scan send-probe off 
configure wireless port 3 interface 2 ap-scan probe-interval 100 
configure wireless port 3 interface 2 ap-scan off-channel max-wait 600 
configure wireless port 3 interface 2 ap-scan off-channel min-wait 60 
configure wireless port 3 interface 2 ap-scan results size 128 
configure wireless port 3 interface 2 ap-scan results timeout 300  
configure wireless port 3 interface 2 ap-scan added-trap off  
configure wireless port 3 interface 2 ap-scan removed-trap off  
configure wireless port 3 interface 2 ap-scan updated-trap off 
configure wireless port 3 interface 2 ap-scan off-channel continuous off
disable wireless port 3 interface 2 client-scan 
configure wireless port 3 interface 2 client-scan results size 128 
configure wireless port 3 interface 2 client-scan results timeout 600 
configure wireless port 3 interface 2 client-scan added-trap off 
configure wireless port 3 interface 2 client-scan removed-trap off 
disable wireless port 3 interface 2 client-history
configure wireless port 3 interface 2 client-history size 128
configure wireless port 3 interface 2 client-history timeout 600
#
# Wireless Interface Configuration for Interface 4:1
#
disable wireless port 4 interface 1 ap-scan 
disable wireless port 4 interface 1 ap-scan off-channel
configure wireless port 4 interface 1 ap-scan off-channel all 
configure wireless port 4 interface 1 ap-scan send-probe off 
configure wireless port 4 interface 1 ap-scan probe-interval 100 
configure wireless port 4 interface 1 ap-scan off-channel max-wait 600 
configure wireless port 4 interface 1 ap-scan off-channel min-wait 60 
configure wireless port 4 interface 1 ap-scan results size 128 
configure wireless port 4 interface 1 ap-scan results timeout 300  
configure wireless port 4 interface 1 ap-scan added-trap off  
configure wireless port 4 interface 1 ap-scan removed-trap off  
configure wireless port 4 interface 1 ap-scan updated-trap off 
configure wireless port 4 interface 1 ap-scan off-channel continuous off
disable wireless port 4 interface 1 client-scan 
configure wireless port 4 interface 1 client-scan results size 128 
configure wireless port 4 interface 1 client-scan results timeout 600 
configure wireless port 4 interface 1 client-scan added-trap off 
configure wireless port 4 interface 1 client-scan removed-trap off 
disable wireless port 4 interface 1 client-history
configure wireless port 4 interface 1 client-history size 128
configure wireless port 4 interface 1 client-history timeout 600
#
# Wireless Interface Configuration for Interface 4:2
#
disable wireless port 4 interface 2 ap-scan 
disable wireless port 4 interface 2 ap-scan off-channel
configure wireless port 4 interface 2 ap-scan off-channel all 
configure wireless port 4 interface 2 ap-scan send-probe off 
configure wireless port 4 interface 2 ap-scan probe-interval 100 
configure wireless port 4 interface 2 ap-scan off-channel max-wait 600 
configure wireless port 4 interface 2 ap-scan off-channel min-wait 60 
configure wireless port 4 interface 2 ap-scan results size 128 
configure wireless port 4 interface 2 ap-scan results timeout 300  
configure wireless port 4 interface 2 ap-scan added-trap off  
configure wireless port 4 interface 2 ap-scan removed-trap off  
configure wireless port 4 interface 2 ap-scan updated-trap off 
configure wireless port 4 interface 2 ap-scan off-channel continuous off
disable wireless port 4 interface 2 client-scan 
configure wireless port 4 interface 2 client-scan results size 128 
configure wireless port 4 interface 2 client-scan results timeout 600 
configure wireless port 4 interface 2 client-scan added-trap off 
configure wireless port 4 interface 2 client-scan removed-trap off 
disable wireless port 4 interface 2 client-history
configure wireless port 4 interface 2 client-history size 128
configure wireless port 4 interface 2 client-history timeout 600
#
# Wireless Interface Configuration for Interface 5:1
#
disable wireless port 5 interface 1 ap-scan 
disable wireless port 5 interface 1 ap-scan off-channel
configure wireless port 5 interface 1 ap-scan off-channel all 
configure wireless port 5 interface 1 ap-scan send-probe off 
configure wireless port 5 interface 1 ap-scan probe-interval 100 
configure wireless port 5 interface 1 ap-scan off-channel max-wait 600 
configure wireless port 5 interface 1 ap-scan off-channel min-wait 60 
configure wireless port 5 interface 1 ap-scan results size 128 
configure wireless port 5 interface 1 ap-scan results timeout 300  
configure wireless port 5 interface 1 ap-scan added-trap off  
configure wireless port 5 interface 1 ap-scan removed-trap off  
configure wireless port 5 interface 1 ap-scan updated-trap off 
configure wireless port 5 interface 1 ap-scan off-channel continuous off
disable wireless port 5 interface 1 client-scan 
configure wireless port 5 interface 1 client-scan results size 128 
configure wireless port 5 interface 1 client-scan results timeout 600 
configure wireless port 5 interface 1 client-scan added-trap off 
configure wireless port 5 interface 1 client-scan removed-trap off 
disable wireless port 5 interface 1 client-history
configure wireless port 5 interface 1 client-history size 128
configure wireless port 5 interface 1 client-history timeout 600
#
# Wireless Interface Configuration for Interface 5:2
#
disable wireless port 5 interface 2 ap-scan 
disable wireless port 5 interface 2 ap-scan off-channel
configure wireless port 5 interface 2 ap-scan off-channel all 
configure wireless port 5 interface 2 ap-scan send-probe off 
configure wireless port 5 interface 2 ap-scan probe-interval 100 
configure wireless port 5 interface 2 ap-scan off-channel max-wait 600 
configure wireless port 5 interface 2 ap-scan off-channel min-wait 60 
configure wireless port 5 interface 2 ap-scan results size 128 
configure wireless port 5 interface 2 ap-scan results timeout 300  
configure wireless port 5 interface 2 ap-scan added-trap off  
configure wireless port 5 interface 2 ap-scan removed-trap off  
configure wireless port 5 interface 2 ap-scan updated-trap off 
configure wireless port 5 interface 2 ap-scan off-channel continuous off
disable wireless port 5 interface 2 client-scan 
configure wireless port 5 interface 2 client-scan results size 128 
configure wireless port 5 interface 2 client-scan results timeout 600 
configure wireless port 5 interface 2 client-scan added-trap off 
configure wireless port 5 interface 2 client-scan removed-trap off 
disable wireless port 5 interface 2 client-history
configure wireless port 5 interface 2 client-history size 128
configure wireless port 5 interface 2 client-history timeout 600
#
# Wireless Interface Configuration for Interface 6:1
#
disable wireless port 6 interface 1 ap-scan 
disable wireless port 6 interface 1 ap-scan off-channel
configure wireless port 6 interface 1 ap-scan off-channel all 
configure wireless port 6 interface 1 ap-scan send-probe off 
configure wireless port 6 interface 1 ap-scan probe-interval 100 
configure wireless port 6 interface 1 ap-scan off-channel max-wait 600 
configure wireless port 6 interface 1 ap-scan off-channel min-wait 60 
configure wireless port 6 interface 1 ap-scan results size 128 
configure wireless port 6 interface 1 ap-scan results timeout 300  
configure wireless port 6 interface 1 ap-scan added-trap off  
configure wireless port 6 interface 1 ap-scan removed-trap off  
configure wireless port 6 interface 1 ap-scan updated-trap off 
configure wireless port 6 interface 1 ap-scan off-channel continuous off
disable wireless port 6 interface 1 client-scan 
configure wireless port 6 interface 1 client-scan results size 128 
configure wireless port 6 interface 1 client-scan results timeout 600 
configure wireless port 6 interface 1 client-scan added-trap off 
configure wireless port 6 interface 1 client-scan removed-trap off 
disable wireless port 6 interface 1 client-history
configure wireless port 6 interface 1 client-history size 128
configure wireless port 6 interface 1 client-history timeout 600
#
# Wireless Interface Configuration for Interface 6:2
#
disable wireless port 6 interface 2 ap-scan 
disable wireless port 6 interface 2 ap-scan off-channel
configure wireless port 6 interface 2 ap-scan off-channel all 
configure wireless port 6 interface 2 ap-scan send-probe off 
configure wireless port 6 interface 2 ap-scan probe-interval 100 
configure wireless port 6 interface 2 ap-scan off-channel max-wait 600 
configure wireless port 6 interface 2 ap-scan off-channel min-wait 60 
configure wireless port 6 interface 2 ap-scan results size 128 
configure wireless port 6 interface 2 ap-scan results timeout 300  
configure wireless port 6 interface 2 ap-scan added-trap off  
configure wireless port 6 interface 2 ap-scan removed-trap off  
configure wireless port 6 interface 2 ap-scan updated-trap off 
configure wireless port 6 interface 2 ap-scan off-channel continuous off
disable wireless port 6 interface 2 client-scan 
configure wireless port 6 interface 2 client-scan results size 128 
configure wireless port 6 interface 2 client-scan results timeout 600 
configure wireless port 6 interface 2 client-scan added-trap off 
configure wireless port 6 interface 2 client-scan removed-trap off 
disable wireless port 6 interface 2 client-history
configure wireless port 6 interface 2 client-history size 128
configure wireless port 6 interface 2 client-history timeout 600
#
# Wireless Interface Configuration for Interface 7:1
#
disable wireless port 7 interface 1 ap-scan 
disable wireless port 7 interface 1 ap-scan off-channel
configure wireless port 7 interface 1 ap-scan off-channel all 
configure wireless port 7 interface 1 ap-scan send-probe off 
configure wireless port 7 interface 1 ap-scan probe-interval 100 
configure wireless port 7 interface 1 ap-scan off-channel max-wait 600 
configure wireless port 7 interface 1 ap-scan off-channel min-wait 60 
configure wireless port 7 interface 1 ap-scan results size 128 
configure wireless port 7 interface 1 ap-scan results timeout 300  
configure wireless port 7 interface 1 ap-scan added-trap off  
configure wireless port 7 interface 1 ap-scan removed-trap off  
configure wireless port 7 interface 1 ap-scan updated-trap off 
configure wireless port 7 interface 1 ap-scan off-channel continuous off
disable wireless port 7 interface 1 client-scan 
configure wireless port 7 interface 1 client-scan results size 128 
configure wireless port 7 interface 1 client-scan results timeout 600 
configure wireless port 7 interface 1 client-scan added-trap off 
configure wireless port 7 interface 1 client-scan removed-trap off 
disable wireless port 7 interface 1 client-history
configure wireless port 7 interface 1 client-history size 128
configure wireless port 7 interface 1 client-history timeout 600
#
# Wireless Interface Configuration for Interface 7:2
#
disable wireless port 7 interface 2 ap-scan 
disable wireless port 7 interface 2 ap-scan off-channel
configure wireless port 7 interface 2 ap-scan off-channel all 
configure wireless port 7 interface 2 ap-scan send-probe off 
configure wireless port 7 interface 2 ap-scan probe-interval 100 
configure wireless port 7 interface 2 ap-scan off-channel max-wait 600 
configure wireless port 7 interface 2 ap-scan off-channel min-wait 60 
configure wireless port 7 interface 2 ap-scan results size 128 
configure wireless port 7 interface 2 ap-scan results timeout 300  
configure wireless port 7 interface 2 ap-scan added-trap off  
configure wireless port 7 interface 2 ap-scan removed-trap off  
configure wireless port 7 interface 2 ap-scan updated-trap off 
configure wireless port 7 interface 2 ap-scan off-channel continuous off
disable wireless port 7 interface 2 client-scan 
configure wireless port 7 interface 2 client-scan results size 128 
configure wireless port 7 interface 2 client-scan results timeout 600 
configure wireless port 7 interface 2 client-scan added-trap off 
configure wireless port 7 interface 2 client-scan removed-trap off 
disable wireless port 7 interface 2 client-history
configure wireless port 7 interface 2 client-history size 128
configure wireless port 7 interface 2 client-history timeout 600
#
# Wireless Interface Configuration for Interface 8:1
#
disable wireless port 8 interface 1 ap-scan 
disable wireless port 8 interface 1 ap-scan off-channel
configure wireless port 8 interface 1 ap-scan off-channel all 
configure wireless port 8 interface 1 ap-scan send-probe off 
configure wireless port 8 interface 1 ap-scan probe-interval 100 
configure wireless port 8 interface 1 ap-scan off-channel max-wait 600 
configure wireless port 8 interface 1 ap-scan off-channel min-wait 60 
configure wireless port 8 interface 1 ap-scan results size 128 
configure wireless port 8 interface 1 ap-scan results timeout 300  
configure wireless port 8 interface 1 ap-scan added-trap off  
configure wireless port 8 interface 1 ap-scan removed-trap off  
configure wireless port 8 interface 1 ap-scan updated-trap off 
configure wireless port 8 interface 1 ap-scan off-channel continuous off
disable wireless port 8 interface 1 client-scan 
configure wireless port 8 interface 1 client-scan results size 128 
configure wireless port 8 interface 1 client-scan results timeout 600 
configure wireless port 8 interface 1 client-scan added-trap off 
configure wireless port 8 interface 1 client-scan removed-trap off 
disable wireless port 8 interface 1 client-history
configure wireless port 8 interface 1 client-history size 128
configure wireless port 8 interface 1 client-history timeout 600
#
# Wireless Interface Configuration for Interface 8:2
#
disable wireless port 8 interface 2 ap-scan 
disable wireless port 8 interface 2 ap-scan off-channel
configure wireless port 8 interface 2 ap-scan off-channel all 
configure wireless port 8 interface 2 ap-scan send-probe off 
configure wireless port 8 interface 2 ap-scan probe-interval 100 
configure wireless port 8 interface 2 ap-scan off-channel max-wait 600 
configure wireless port 8 interface 2 ap-scan off-channel min-wait 60 
configure wireless port 8 interface 2 ap-scan results size 128 
configure wireless port 8 interface 2 ap-scan results timeout 300  
configure wireless port 8 interface 2 ap-scan added-trap off  
configure wireless port 8 interface 2 ap-scan removed-trap off  
configure wireless port 8 interface 2 ap-scan updated-trap off 
configure wireless port 8 interface 2 ap-scan off-channel continuous off
disable wireless port 8 interface 2 client-scan 
configure wireless port 8 interface 2 client-scan results size 128 
configure wireless port 8 interface 2 client-scan results timeout 600 
configure wireless port 8 interface 2 client-scan added-trap off 
configure wireless port 8 interface 2 client-scan removed-trap off 
disable wireless port 8 interface 2 client-history
configure wireless port 8 interface 2 client-history size 128
configure wireless port 8 interface 2 client-history timeout 600
#
# Wireless Interface Configuration for Interface 9:1
#
disable wireless port 9 interface 1 ap-scan 
disable wireless port 9 interface 1 ap-scan off-channel
configure wireless port 9 interface 1 ap-scan off-channel all 
configure wireless port 9 interface 1 ap-scan send-probe off 
configure wireless port 9 interface 1 ap-scan probe-interval 100 
configure wireless port 9 interface 1 ap-scan off-channel max-wait 600 
configure wireless port 9 interface 1 ap-scan off-channel min-wait 60 
configure wireless port 9 interface 1 ap-scan results size 128 
configure wireless port 9 interface 1 ap-scan results timeout 300  
configure wireless port 9 interface 1 ap-scan added-trap off  
configure wireless port 9 interface 1 ap-scan removed-trap off  
configure wireless port 9 interface 1 ap-scan updated-trap off 
configure wireless port 9 interface 1 ap-scan off-channel continuous off
disable wireless port 9 interface 1 client-scan 
configure wireless port 9 interface 1 client-scan results size 128 
configure wireless port 9 interface 1 client-scan results timeout 600 
configure wireless port 9 interface 1 client-scan added-trap off 
configure wireless port 9 interface 1 client-scan removed-trap off 
disable wireless port 9 interface 1 client-history
configure wireless port 9 interface 1 client-history size 128
configure wireless port 9 interface 1 client-history timeout 600
#
# Wireless Interface Configuration for Interface 9:2
#
disable wireless port 9 interface 2 ap-scan 
disable wireless port 9 interface 2 ap-scan off-channel
configure wireless port 9 interface 2 ap-scan off-channel all 
configure wireless port 9 interface 2 ap-scan send-probe off 
configure wireless port 9 interface 2 ap-scan probe-interval 100 
configure wireless port 9 interface 2 ap-scan off-channel max-wait 600 
configure wireless port 9 interface 2 ap-scan off-channel min-wait 60 
configure wireless port 9 interface 2 ap-scan results size 128 
configure wireless port 9 interface 2 ap-scan results timeout 300  
configure wireless port 9 interface 2 ap-scan added-trap off  
configure wireless port 9 interface 2 ap-scan removed-trap off  
configure wireless port 9 interface 2 ap-scan updated-trap off 
configure wireless port 9 interface 2 ap-scan off-channel continuous off
disable wireless port 9 interface 2 client-scan 
configure wireless port 9 interface 2 client-scan results size 128 
configure wireless port 9 interface 2 client-scan results timeout 600 
configure wireless port 9 interface 2 client-scan added-trap off 
configure wireless port 9 interface 2 client-scan removed-trap off 
disable wireless port 9 interface 2 client-history
configure wireless port 9 interface 2 client-history size 128
configure wireless port 9 interface 2 client-history timeout 600
#
# Wireless Interface Configuration for Interface 10:1
#
disable wireless port 10 interface 1 ap-scan 
disable wireless port 10 interface 1 ap-scan off-channel
configure wireless port 10 interface 1 ap-scan off-channel all 
configure wireless port 10 interface 1 ap-scan send-probe off 
configure wireless port 10 interface 1 ap-scan probe-interval 100 
configure wireless port 10 interface 1 ap-scan off-channel max-wait 600 
configure wireless port 10 interface 1 ap-scan off-channel min-wait 60 
configure wireless port 10 interface 1 ap-scan results size 128 
configure wireless port 10 interface 1 ap-scan results timeout 300  
configure wireless port 10 interface 1 ap-scan added-trap off  
configure wireless port 10 interface 1 ap-scan removed-trap off  
configure wireless port 10 interface 1 ap-scan updated-trap off 
configure wireless port 10 interface 1 ap-scan off-channel continuous off
disable wireless port 10 interface 1 client-scan 
configure wireless port 10 interface 1 client-scan results size 128 
configure wireless port 10 interface 1 client-scan results timeout 600 
configure wireless port 10 interface 1 client-scan added-trap off 
configure wireless port 10 interface 1 client-scan removed-trap off 
disable wireless port 10 interface 1 client-history
configure wireless port 10 interface 1 client-history size 128
configure wireless port 10 interface 1 client-history timeout 600
#
# Wireless Interface Configuration for Interface 10:2
#
disable wireless port 10 interface 2 ap-scan 
disable wireless port 10 interface 2 ap-scan off-channel
configure wireless port 10 interface 2 ap-scan off-channel all 
configure wireless port 10 interface 2 ap-scan send-probe off 
configure wireless port 10 interface 2 ap-scan probe-interval 100 
configure wireless port 10 interface 2 ap-scan off-channel max-wait 600 
configure wireless port 10 interface 2 ap-scan off-channel min-wait 60 
configure wireless port 10 interface 2 ap-scan results size 128 
configure wireless port 10 interface 2 ap-scan results timeout 300  
configure wireless port 10 interface 2 ap-scan added-trap off  
configure wireless port 10 interface 2 ap-scan removed-trap off  
configure wireless port 10 interface 2 ap-scan updated-trap off 
configure wireless port 10 interface 2 ap-scan off-channel continuous off
disable wireless port 10 interface 2 client-scan 
configure wireless port 10 interface 2 client-scan results size 128 
configure wireless port 10 interface 2 client-scan results timeout 600 
configure wireless port 10 interface 2 client-scan added-trap off 
configure wireless port 10 interface 2 client-scan removed-trap off 
disable wireless port 10 interface 2 client-history
configure wireless port 10 interface 2 client-history size 128
configure wireless port 10 interface 2 client-history timeout 600
#
# Wireless Interface Configuration for Interface 11:1
#
disable wireless port 11 interface 1 ap-scan 
disable wireless port 11 interface 1 ap-scan off-channel
configure wireless port 11 interface 1 ap-scan off-channel all 
configure wireless port 11 interface 1 ap-scan send-probe off 
configure wireless port 11 interface 1 ap-scan probe-interval 100 
configure wireless port 11 interface 1 ap-scan off-channel max-wait 600 
configure wireless port 11 interface 1 ap-scan off-channel min-wait 60 
configure wireless port 11 interface 1 ap-scan results size 128 
configure wireless port 11 interface 1 ap-scan results timeout 300  
configure wireless port 11 interface 1 ap-scan added-trap off  
configure wireless port 11 interface 1 ap-scan removed-trap off  
configure wireless port 11 interface 1 ap-scan updated-trap off 
configure wireless port 11 interface 1 ap-scan off-channel continuous off
disable wireless port 11 interface 1 client-scan 
configure wireless port 11 interface 1 client-scan results size 128 
configure wireless port 11 interface 1 client-scan results timeout 600 
configure wireless port 11 interface 1 client-scan added-trap off 
configure wireless port 11 interface 1 client-scan removed-trap off 
disable wireless port 11 interface 1 client-history
configure wireless port 11 interface 1 client-history size 128
configure wireless port 11 interface 1 client-history timeout 600
#
# Wireless Interface Configuration for Interface 11:2
#
disable wireless port 11 interface 2 ap-scan 
disable wireless port 11 interface 2 ap-scan off-channel
configure wireless port 11 interface 2 ap-scan off-channel all 
configure wireless port 11 interface 2 ap-scan send-probe off 
configure wireless port 11 interface 2 ap-scan probe-interval 100 
configure wireless port 11 interface 2 ap-scan off-channel max-wait 600 
configure wireless port 11 interface 2 ap-scan off-channel min-wait 60 
configure wireless port 11 interface 2 ap-scan results size 128 
configure wireless port 11 interface 2 ap-scan results timeout 300  
configure wireless port 11 interface 2 ap-scan added-trap off  
configure wireless port 11 interface 2 ap-scan removed-trap off  
configure wireless port 11 interface 2 ap-scan updated-trap off 
configure wireless port 11 interface 2 ap-scan off-channel continuous off
disable wireless port 11 interface 2 client-scan 
configure wireless port 11 interface 2 client-scan results size 128 
configure wireless port 11 interface 2 client-scan results timeout 600 
configure wireless port 11 interface 2 client-scan added-trap off 
configure wireless port 11 interface 2 client-scan removed-trap off 
disable wireless port 11 interface 2 client-history
configure wireless port 11 interface 2 client-history size 128
configure wireless port 11 interface 2 client-history timeout 600
#
# Wireless Interface Configuration for Interface 12:1
#
disable wireless port 12 interface 1 ap-scan 
disable wireless port 12 interface 1 ap-scan off-channel
configure wireless port 12 interface 1 ap-scan off-channel all 
configure wireless port 12 interface 1 ap-scan send-probe off 
configure wireless port 12 interface 1 ap-scan probe-interval 100 
configure wireless port 12 interface 1 ap-scan off-channel max-wait 600 
configure wireless port 12 interface 1 ap-scan off-channel min-wait 60 
configure wireless port 12 interface 1 ap-scan results size 128 
configure wireless port 12 interface 1 ap-scan results timeout 300  
configure wireless port 12 interface 1 ap-scan added-trap off  
configure wireless port 12 interface 1 ap-scan removed-trap off  
configure wireless port 12 interface 1 ap-scan updated-trap off 
configure wireless port 12 interface 1 ap-scan off-channel continuous off
disable wireless port 12 interface 1 client-scan 
configure wireless port 12 interface 1 client-scan results size 128 
configure wireless port 12 interface 1 client-scan results timeout 600 
configure wireless port 12 interface 1 client-scan added-trap off 
configure wireless port 12 interface 1 client-scan removed-trap off 
disable wireless port 12 interface 1 client-history
configure wireless port 12 interface 1 client-history size 128
configure wireless port 12 interface 1 client-history timeout 600
#
# Wireless Interface Configuration for Interface 12:2
#
disable wireless port 12 interface 2 ap-scan 
disable wireless port 12 interface 2 ap-scan off-channel
configure wireless port 12 interface 2 ap-scan off-channel all 
configure wireless port 12 interface 2 ap-scan send-probe off 
configure wireless port 12 interface 2 ap-scan probe-interval 100 
configure wireless port 12 interface 2 ap-scan off-channel max-wait 600 
configure wireless port 12 interface 2 ap-scan off-channel min-wait 60 
configure wireless port 12 interface 2 ap-scan results size 128 
configure wireless port 12 interface 2 ap-scan results timeout 300  
configure wireless port 12 interface 2 ap-scan added-trap off  
configure wireless port 12 interface 2 ap-scan removed-trap off  
configure wireless port 12 interface 2 ap-scan updated-trap off 
configure wireless port 12 interface 2 ap-scan off-channel continuous off
disable wireless port 12 interface 2 client-scan 
configure wireless port 12 interface 2 client-scan results size 128 
configure wireless port 12 interface 2 client-scan results timeout 600 
configure wireless port 12 interface 2 client-scan added-trap off 
configure wireless port 12 interface 2 client-scan removed-trap off 
disable wireless port 12 interface 2 client-history
configure wireless port 12 interface 2 client-history size 128
configure wireless port 12 interface 2 client-history timeout 600
#
# Wireless Interface Configuration for Interface 13:1
#
disable wireless port 13 interface 1 ap-scan 
disable wireless port 13 interface 1 ap-scan off-channel
configure wireless port 13 interface 1 ap-scan off-channel all 
configure wireless port 13 interface 1 ap-scan send-probe off 
configure wireless port 13 interface 1 ap-scan probe-interval 100 
configure wireless port 13 interface 1 ap-scan off-channel max-wait 600 
configure wireless port 13 interface 1 ap-scan off-channel min-wait 60 
configure wireless port 13 interface 1 ap-scan results size 128 
configure wireless port 13 interface 1 ap-scan results timeout 300  
configure wireless port 13 interface 1 ap-scan added-trap off  
configure wireless port 13 interface 1 ap-scan removed-trap off  
configure wireless port 13 interface 1 ap-scan updated-trap off 
configure wireless port 13 interface 1 ap-scan off-channel continuous off
disable wireless port 13 interface 1 client-scan 
configure wireless port 13 interface 1 client-scan results size 128 
configure wireless port 13 interface 1 client-scan results timeout 600 
configure wireless port 13 interface 1 client-scan added-trap off 
configure wireless port 13 interface 1 client-scan removed-trap off 
disable wireless port 13 interface 1 client-history
configure wireless port 13 interface 1 client-history size 128
configure wireless port 13 interface 1 client-history timeout 600
#
# Wireless Interface Configuration for Interface 13:2
#
disable wireless port 13 interface 2 ap-scan 
disable wireless port 13 interface 2 ap-scan off-channel
configure wireless port 13 interface 2 ap-scan off-channel all 
configure wireless port 13 interface 2 ap-scan send-probe off 
configure wireless port 13 interface 2 ap-scan probe-interval 100 
configure wireless port 13 interface 2 ap-scan off-channel max-wait 600 
configure wireless port 13 interface 2 ap-scan off-channel min-wait 60 
configure wireless port 13 interface 2 ap-scan results size 128 
configure wireless port 13 interface 2 ap-scan results timeout 300  
configure wireless port 13 interface 2 ap-scan added-trap off  
configure wireless port 13 interface 2 ap-scan removed-trap off  
configure wireless port 13 interface 2 ap-scan updated-trap off 
configure wireless port 13 interface 2 ap-scan off-channel continuous off
disable wireless port 13 interface 2 client-scan 
configure wireless port 13 interface 2 client-scan results size 128 
configure wireless port 13 interface 2 client-scan results timeout 600 
configure wireless port 13 interface 2 client-scan added-trap off 
configure wireless port 13 interface 2 client-scan removed-trap off 
disable wireless port 13 interface 2 client-history
configure wireless port 13 interface 2 client-history size 128
configure wireless port 13 interface 2 client-history timeout 600
#
# Wireless Interface Configuration for Interface 14:1
#
disable wireless port 14 interface 1 ap-scan 
disable wireless port 14 interface 1 ap-scan off-channel
configure wireless port 14 interface 1 ap-scan off-channel all 
configure wireless port 14 interface 1 ap-scan send-probe off 
configure wireless port 14 interface 1 ap-scan probe-interval 100 
configure wireless port 14 interface 1 ap-scan off-channel max-wait 600 
configure wireless port 14 interface 1 ap-scan off-channel min-wait 60 
configure wireless port 14 interface 1 ap-scan results size 128 
configure wireless port 14 interface 1 ap-scan results timeout 300  
configure wireless port 14 interface 1 ap-scan added-trap off  
configure wireless port 14 interface 1 ap-scan removed-trap off  
configure wireless port 14 interface 1 ap-scan updated-trap off 
configure wireless port 14 interface 1 ap-scan off-channel continuous off
disable wireless port 14 interface 1 client-scan 
configure wireless port 14 interface 1 client-scan results size 128 
configure wireless port 14 interface 1 client-scan results timeout 600 
configure wireless port 14 interface 1 client-scan added-trap off 
configure wireless port 14 interface 1 client-scan removed-trap off 
disable wireless port 14 interface 1 client-history
configure wireless port 14 interface 1 client-history size 128
configure wireless port 14 interface 1 client-history timeout 600
#
# Wireless Interface Configuration for Interface 14:2
#
disable wireless port 14 interface 2 ap-scan 
disable wireless port 14 interface 2 ap-scan off-channel
configure wireless port 14 interface 2 ap-scan off-channel all 
configure wireless port 14 interface 2 ap-scan send-probe off 
configure wireless port 14 interface 2 ap-scan probe-interval 100 
configure wireless port 14 interface 2 ap-scan off-channel max-wait 600 
configure wireless port 14 interface 2 ap-scan off-channel min-wait 60 
configure wireless port 14 interface 2 ap-scan results size 128 
configure wireless port 14 interface 2 ap-scan results timeout 300  
configure wireless port 14 interface 2 ap-scan added-trap off  
configure wireless port 14 interface 2 ap-scan removed-trap off  
configure wireless port 14 interface 2 ap-scan updated-trap off 
configure wireless port 14 interface 2 ap-scan off-channel continuous off
disable wireless port 14 interface 2 client-scan 
configure wireless port 14 interface 2 client-scan results size 128 
configure wireless port 14 interface 2 client-scan results timeout 600 
configure wireless port 14 interface 2 client-scan added-trap off 
configure wireless port 14 interface 2 client-scan removed-trap off 
disable wireless port 14 interface 2 client-history
configure wireless port 14 interface 2 client-history size 128
configure wireless port 14 interface 2 client-history timeout 600
#
# Wireless Interface Configuration for Interface 15:1
#
disable wireless port 15 interface 1 ap-scan 
disable wireless port 15 interface 1 ap-scan off-channel
configure wireless port 15 interface 1 ap-scan off-channel all 
configure wireless port 15 interface 1 ap-scan send-probe off 
configure wireless port 15 interface 1 ap-scan probe-interval 100 
configure wireless port 15 interface 1 ap-scan off-channel max-wait 600 
configure wireless port 15 interface 1 ap-scan off-channel min-wait 60 
configure wireless port 15 interface 1 ap-scan results size 128 
configure wireless port 15 interface 1 ap-scan results timeout 300  
configure wireless port 15 interface 1 ap-scan added-trap off  
configure wireless port 15 interface 1 ap-scan removed-trap off  
configure wireless port 15 interface 1 ap-scan updated-trap off 
configure wireless port 15 interface 1 ap-scan off-channel continuous off
disable wireless port 15 interface 1 client-scan 
configure wireless port 15 interface 1 client-scan results size 128 
configure wireless port 15 interface 1 client-scan results timeout 600 
configure wireless port 15 interface 1 client-scan added-trap off 
configure wireless port 15 interface 1 client-scan removed-trap off 
disable wireless port 15 interface 1 client-history
configure wireless port 15 interface 1 client-history size 128
configure wireless port 15 interface 1 client-history timeout 600
#
# Wireless Interface Configuration for Interface 15:2
#
disable wireless port 15 interface 2 ap-scan 
disable wireless port 15 interface 2 ap-scan off-channel
configure wireless port 15 interface 2 ap-scan off-channel all 
configure wireless port 15 interface 2 ap-scan send-probe off 
configure wireless port 15 interface 2 ap-scan probe-interval 100 
configure wireless port 15 interface 2 ap-scan off-channel max-wait 600 
configure wireless port 15 interface 2 ap-scan off-channel min-wait 60 
configure wireless port 15 interface 2 ap-scan results size 128 
configure wireless port 15 interface 2 ap-scan results timeout 300  
configure wireless port 15 interface 2 ap-scan added-trap off  
configure wireless port 15 interface 2 ap-scan removed-trap off  
configure wireless port 15 interface 2 ap-scan updated-trap off 
configure wireless port 15 interface 2 ap-scan off-channel continuous off
disable wireless port 15 interface 2 client-scan 
configure wireless port 15 interface 2 client-scan results size 128 
configure wireless port 15 interface 2 client-scan results timeout 600 
configure wireless port 15 interface 2 client-scan added-trap off 
configure wireless port 15 interface 2 client-scan removed-trap off 
disable wireless port 15 interface 2 client-history
configure wireless port 15 interface 2 client-history size 128
configure wireless port 15 interface 2 client-history timeout 600
#
# Wireless Interface Configuration for Interface 16:1
#
disable wireless port 16 interface 1 ap-scan 
disable wireless port 16 interface 1 ap-scan off-channel
configure wireless port 16 interface 1 ap-scan off-channel all 
configure wireless port 16 interface 1 ap-scan send-probe off 
configure wireless port 16 interface 1 ap-scan probe-interval 100 
configure wireless port 16 interface 1 ap-scan off-channel max-wait 600 
configure wireless port 16 interface 1 ap-scan off-channel min-wait 60 
configure wireless port 16 interface 1 ap-scan results size 128 
configure wireless port 16 interface 1 ap-scan results timeout 300  
configure wireless port 16 interface 1 ap-scan added-trap off  
configure wireless port 16 interface 1 ap-scan removed-trap off  
configure wireless port 16 interface 1 ap-scan updated-trap off 
configure wireless port 16 interface 1 ap-scan off-channel continuous off
disable wireless port 16 interface 1 client-scan 
configure wireless port 16 interface 1 client-scan results size 128 
configure wireless port 16 interface 1 client-scan results timeout 600 
configure wireless port 16 interface 1 client-scan added-trap off 
configure wireless port 16 interface 1 client-scan removed-trap off 
disable wireless port 16 interface 1 client-history
configure wireless port 16 interface 1 client-history size 128
configure wireless port 16 interface 1 client-history timeout 600
#
# Wireless Interface Configuration for Interface 16:2
#
disable wireless port 16 interface 2 ap-scan 
disable wireless port 16 interface 2 ap-scan off-channel
configure wireless port 16 interface 2 ap-scan off-channel all 
configure wireless port 16 interface 2 ap-scan send-probe off 
configure wireless port 16 interface 2 ap-scan probe-interval 100 
configure wireless port 16 interface 2 ap-scan off-channel max-wait 600 
configure wireless port 16 interface 2 ap-scan off-channel min-wait 60 
configure wireless port 16 interface 2 ap-scan results size 128 
configure wireless port 16 interface 2 ap-scan results timeout 300  
configure wireless port 16 interface 2 ap-scan added-trap off  
configure wireless port 16 interface 2 ap-scan removed-trap off  
configure wireless port 16 interface 2 ap-scan updated-trap off 
configure wireless port 16 interface 2 ap-scan off-channel continuous off
disable wireless port 16 interface 2 client-scan 
configure wireless port 16 interface 2 client-scan results size 128 
configure wireless port 16 interface 2 client-scan results timeout 600 
configure wireless port 16 interface 2 client-scan added-trap off 
configure wireless port 16 interface 2 client-scan removed-trap off 
disable wireless port 16 interface 2 client-history
configure wireless port 16 interface 2 client-history size 128
configure wireless port 16 interface 2 client-history timeout 600
#
# Wireless Interface Configuration for Interface 17:1
#
disable wireless port 17 interface 1 ap-scan 
disable wireless port 17 interface 1 ap-scan off-channel
configure wireless port 17 interface 1 ap-scan off-channel all 
configure wireless port 17 interface 1 ap-scan send-probe off 
configure wireless port 17 interface 1 ap-scan probe-interval 100 
configure wireless port 17 interface 1 ap-scan off-channel max-wait 600 
configure wireless port 17 interface 1 ap-scan off-channel min-wait 60 
configure wireless port 17 interface 1 ap-scan results size 128 
configure wireless port 17 interface 1 ap-scan results timeout 300  
configure wireless port 17 interface 1 ap-scan added-trap off  
configure wireless port 17 interface 1 ap-scan removed-trap off  
configure wireless port 17 interface 1 ap-scan updated-trap off 
configure wireless port 17 interface 1 ap-scan off-channel continuous off
disable wireless port 17 interface 1 client-scan 
configure wireless port 17 interface 1 client-scan results size 128 
configure wireless port 17 interface 1 client-scan results timeout 600 
configure wireless port 17 interface 1 client-scan added-trap off 
configure wireless port 17 interface 1 client-scan removed-trap off 
disable wireless port 17 interface 1 client-history
configure wireless port 17 interface 1 client-history size 128
configure wireless port 17 interface 1 client-history timeout 600
#
# Wireless Interface Configuration for Interface 17:2
#
disable wireless port 17 interface 2 ap-scan 
disable wireless port 17 interface 2 ap-scan off-channel
configure wireless port 17 interface 2 ap-scan off-channel all 
configure wireless port 17 interface 2 ap-scan send-probe off 
configure wireless port 17 interface 2 ap-scan probe-interval 100 
configure wireless port 17 interface 2 ap-scan off-channel max-wait 600 
configure wireless port 17 interface 2 ap-scan off-channel min-wait 60 
configure wireless port 17 interface 2 ap-scan results size 128 
configure wireless port 17 interface 2 ap-scan results timeout 300  
configure wireless port 17 interface 2 ap-scan added-trap off  
configure wireless port 17 interface 2 ap-scan removed-trap off  
configure wireless port 17 interface 2 ap-scan updated-trap off 
configure wireless port 17 interface 2 ap-scan off-channel continuous off
disable wireless port 17 interface 2 client-scan 
configure wireless port 17 interface 2 client-scan results size 128 
configure wireless port 17 interface 2 client-scan results timeout 600 
configure wireless port 17 interface 2 client-scan added-trap off 
configure wireless port 17 interface 2 client-scan removed-trap off 
disable wireless port 17 interface 2 client-history
configure wireless port 17 interface 2 client-history size 128
configure wireless port 17 interface 2 client-history timeout 600
#
# Wireless Interface Configuration for Interface 18:1
#
disable wireless port 18 interface 1 ap-scan 
disable wireless port 18 interface 1 ap-scan off-channel
configure wireless port 18 interface 1 ap-scan off-channel all 
configure wireless port 18 interface 1 ap-scan send-probe off 
configure wireless port 18 interface 1 ap-scan probe-interval 100 
configure wireless port 18 interface 1 ap-scan off-channel max-wait 600 
configure wireless port 18 interface 1 ap-scan off-channel min-wait 60 
configure wireless port 18 interface 1 ap-scan results size 128 
configure wireless port 18 interface 1 ap-scan results timeout 300  
configure wireless port 18 interface 1 ap-scan added-trap off  
configure wireless port 18 interface 1 ap-scan removed-trap off  
configure wireless port 18 interface 1 ap-scan updated-trap off 
configure wireless port 18 interface 1 ap-scan off-channel continuous off
disable wireless port 18 interface 1 client-scan 
configure wireless port 18 interface 1 client-scan results size 128 
configure wireless port 18 interface 1 client-scan results timeout 600 
configure wireless port 18 interface 1 client-scan added-trap off 
configure wireless port 18 interface 1 client-scan removed-trap off 
disable wireless port 18 interface 1 client-history
configure wireless port 18 interface 1 client-history size 128
configure wireless port 18 interface 1 client-history timeout 600
#
# Wireless Interface Configuration for Interface 18:2
#
disable wireless port 18 interface 2 ap-scan 
disable wireless port 18 interface 2 ap-scan off-channel
configure wireless port 18 interface 2 ap-scan off-channel all 
configure wireless port 18 interface 2 ap-scan send-probe off 
configure wireless port 18 interface 2 ap-scan probe-interval 100 
configure wireless port 18 interface 2 ap-scan off-channel max-wait 600 
configure wireless port 18 interface 2 ap-scan off-channel min-wait 60 
configure wireless port 18 interface 2 ap-scan results size 128 
configure wireless port 18 interface 2 ap-scan results timeout 300  
configure wireless port 18 interface 2 ap-scan added-trap off  
configure wireless port 18 interface 2 ap-scan removed-trap off  
configure wireless port 18 interface 2 ap-scan updated-trap off 
configure wireless port 18 interface 2 ap-scan off-channel continuous off
disable wireless port 18 interface 2 client-scan 
configure wireless port 18 interface 2 client-scan results size 128 
configure wireless port 18 interface 2 client-scan results timeout 600 
configure wireless port 18 interface 2 client-scan added-trap off 
configure wireless port 18 interface 2 client-scan removed-trap off 
disable wireless port 18 interface 2 client-history
configure wireless port 18 interface 2 client-history size 128
configure wireless port 18 interface 2 client-history timeout 600
#
# Wireless Interface Configuration for Interface 19:1
#
disable wireless port 19 interface 1 ap-scan 
disable wireless port 19 interface 1 ap-scan off-channel
configure wireless port 19 interface 1 ap-scan off-channel all 
configure wireless port 19 interface 1 ap-scan send-probe off 
configure wireless port 19 interface 1 ap-scan probe-interval 100 
configure wireless port 19 interface 1 ap-scan off-channel max-wait 600 
configure wireless port 19 interface 1 ap-scan off-channel min-wait 60 
configure wireless port 19 interface 1 ap-scan results size 128 
configure wireless port 19 interface 1 ap-scan results timeout 300  
configure wireless port 19 interface 1 ap-scan added-trap off  
configure wireless port 19 interface 1 ap-scan removed-trap off  
configure wireless port 19 interface 1 ap-scan updated-trap off 
configure wireless port 19 interface 1 ap-scan off-channel continuous off
disable wireless port 19 interface 1 client-scan 
configure wireless port 19 interface 1 client-scan results size 128 
configure wireless port 19 interface 1 client-scan results timeout 600 
configure wireless port 19 interface 1 client-scan added-trap off 
configure wireless port 19 interface 1 client-scan removed-trap off 
disable wireless port 19 interface 1 client-history
configure wireless port 19 interface 1 client-history size 128
configure wireless port 19 interface 1 client-history timeout 600
#
# Wireless Interface Configuration for Interface 19:2
#
disable wireless port 19 interface 2 ap-scan 
disable wireless port 19 interface 2 ap-scan off-channel
configure wireless port 19 interface 2 ap-scan off-channel all 
configure wireless port 19 interface 2 ap-scan send-probe off 
configure wireless port 19 interface 2 ap-scan probe-interval 100 
configure wireless port 19 interface 2 ap-scan off-channel max-wait 600 
configure wireless port 19 interface 2 ap-scan off-channel min-wait 60 
configure wireless port 19 interface 2 ap-scan results size 128 
configure wireless port 19 interface 2 ap-scan results timeout 300  
configure wireless port 19 interface 2 ap-scan added-trap off  
configure wireless port 19 interface 2 ap-scan removed-trap off  
configure wireless port 19 interface 2 ap-scan updated-trap off 
configure wireless port 19 interface 2 ap-scan off-channel continuous off
disable wireless port 19 interface 2 client-scan 
configure wireless port 19 interface 2 client-scan results size 128 
configure wireless port 19 interface 2 client-scan results timeout 600 
configure wireless port 19 interface 2 client-scan added-trap off 
configure wireless port 19 interface 2 client-scan removed-trap off 
disable wireless port 19 interface 2 client-history
configure wireless port 19 interface 2 client-history size 128
configure wireless port 19 interface 2 client-history timeout 600
#
# Wireless Interface Configuration for Interface 20:1
#
disable wireless port 20 interface 1 ap-scan 
disable wireless port 20 interface 1 ap-scan off-channel
configure wireless port 20 interface 1 ap-scan off-channel all 
configure wireless port 20 interface 1 ap-scan send-probe off 
configure wireless port 20 interface 1 ap-scan probe-interval 100 
configure wireless port 20 interface 1 ap-scan off-channel max-wait 600 
configure wireless port 20 interface 1 ap-scan off-channel min-wait 60 
configure wireless port 20 interface 1 ap-scan results size 128 
configure wireless port 20 interface 1 ap-scan results timeout 300  
configure wireless port 20 interface 1 ap-scan added-trap off  
configure wireless port 20 interface 1 ap-scan removed-trap off  
configure wireless port 20 interface 1 ap-scan updated-trap off 
configure wireless port 20 interface 1 ap-scan off-channel continuous off
disable wireless port 20 interface 1 client-scan 
configure wireless port 20 interface 1 client-scan results size 128 
configure wireless port 20 interface 1 client-scan results timeout 600 
configure wireless port 20 interface 1 client-scan added-trap off 
configure wireless port 20 interface 1 client-scan removed-trap off 
disable wireless port 20 interface 1 client-history
configure wireless port 20 interface 1 client-history size 128
configure wireless port 20 interface 1 client-history timeout 600
#
# Wireless Interface Configuration for Interface 20:2
#
disable wireless port 20 interface 2 ap-scan 
disable wireless port 20 interface 2 ap-scan off-channel
configure wireless port 20 interface 2 ap-scan off-channel all 
configure wireless port 20 interface 2 ap-scan send-probe off 
configure wireless port 20 interface 2 ap-scan probe-interval 100 
configure wireless port 20 interface 2 ap-scan off-channel max-wait 600 
configure wireless port 20 interface 2 ap-scan off-channel min-wait 60 
configure wireless port 20 interface 2 ap-scan results size 128 
configure wireless port 20 interface 2 ap-scan results timeout 300  
configure wireless port 20 interface 2 ap-scan added-trap off  
configure wireless port 20 interface 2 ap-scan removed-trap off  
configure wireless port 20 interface 2 ap-scan updated-trap off 
configure wireless port 20 interface 2 ap-scan off-channel continuous off
disable wireless port 20 interface 2 client-scan 
configure wireless port 20 interface 2 client-scan results size 128 
configure wireless port 20 interface 2 client-scan results timeout 600 
configure wireless port 20 interface 2 client-scan added-trap off 
configure wireless port 20 interface 2 client-scan removed-trap off 
disable wireless port 20 interface 2 client-history
configure wireless port 20 interface 2 client-history size 128
configure wireless port 20 interface 2 client-history timeout 600
#
# Wireless Interface Configuration for Interface 21:1
#
disable wireless port 21 interface 1 ap-scan 
disable wireless port 21 interface 1 ap-scan off-channel
configure wireless port 21 interface 1 ap-scan off-channel all 
configure wireless port 21 interface 1 ap-scan send-probe off 
configure wireless port 21 interface 1 ap-scan probe-interval 100 
configure wireless port 21 interface 1 ap-scan off-channel max-wait 600 
configure wireless port 21 interface 1 ap-scan off-channel min-wait 60 
configure wireless port 21 interface 1 ap-scan results size 128 
configure wireless port 21 interface 1 ap-scan results timeout 300  
configure wireless port 21 interface 1 ap-scan added-trap off  
configure wireless port 21 interface 1 ap-scan removed-trap off  
configure wireless port 21 interface 1 ap-scan updated-trap off 
configure wireless port 21 interface 1 ap-scan off-channel continuous off
disable wireless port 21 interface 1 client-scan 
configure wireless port 21 interface 1 client-scan results size 128 
configure wireless port 21 interface 1 client-scan results timeout 600 
configure wireless port 21 interface 1 client-scan added-trap off 
configure wireless port 21 interface 1 client-scan removed-trap off 
disable wireless port 21 interface 1 client-history
configure wireless port 21 interface 1 client-history size 128
configure wireless port 21 interface 1 client-history timeout 600
#
# Wireless Interface Configuration for Interface 21:2
#
disable wireless port 21 interface 2 ap-scan 
disable wireless port 21 interface 2 ap-scan off-channel
configure wireless port 21 interface 2 ap-scan off-channel all 
configure wireless port 21 interface 2 ap-scan send-probe off 
configure wireless port 21 interface 2 ap-scan probe-interval 100 
configure wireless port 21 interface 2 ap-scan off-channel max-wait 600 
configure wireless port 21 interface 2 ap-scan off-channel min-wait 60 
configure wireless port 21 interface 2 ap-scan results size 128 
configure wireless port 21 interface 2 ap-scan results timeout 300  
configure wireless port 21 interface 2 ap-scan added-trap off  
configure wireless port 21 interface 2 ap-scan removed-trap off  
configure wireless port 21 interface 2 ap-scan updated-trap off 
configure wireless port 21 interface 2 ap-scan off-channel continuous off
disable wireless port 21 interface 2 client-scan 
configure wireless port 21 interface 2 client-scan results size 128 
configure wireless port 21 interface 2 client-scan results timeout 600 
configure wireless port 21 interface 2 client-scan added-trap off 
configure wireless port 21 interface 2 client-scan removed-trap off 
disable wireless port 21 interface 2 client-history
configure wireless port 21 interface 2 client-history size 128
configure wireless port 21 interface 2 client-history timeout 600
#
# Wireless Interface Configuration for Interface 22:1
#
disable wireless port 22 interface 1 ap-scan 
disable wireless port 22 interface 1 ap-scan off-channel
configure wireless port 22 interface 1 ap-scan off-channel all 
configure wireless port 22 interface 1 ap-scan send-probe off 
configure wireless port 22 interface 1 ap-scan probe-interval 100 
configure wireless port 22 interface 1 ap-scan off-channel max-wait 600 
configure wireless port 22 interface 1 ap-scan off-channel min-wait 60 
configure wireless port 22 interface 1 ap-scan results size 128 
configure wireless port 22 interface 1 ap-scan results timeout 300  
configure wireless port 22 interface 1 ap-scan added-trap off  
configure wireless port 22 interface 1 ap-scan removed-trap off  
configure wireless port 22 interface 1 ap-scan updated-trap off 
configure wireless port 22 interface 1 ap-scan off-channel continuous off
disable wireless port 22 interface 1 client-scan 
configure wireless port 22 interface 1 client-scan results size 128 
configure wireless port 22 interface 1 client-scan results timeout 600 
configure wireless port 22 interface 1 client-scan added-trap off 
configure wireless port 22 interface 1 client-scan removed-trap off 
disable wireless port 22 interface 1 client-history
configure wireless port 22 interface 1 client-history size 128
configure wireless port 22 interface 1 client-history timeout 600
#
# Wireless Interface Configuration for Interface 22:2
#
disable wireless port 22 interface 2 ap-scan 
disable wireless port 22 interface 2 ap-scan off-channel
configure wireless port 22 interface 2 ap-scan off-channel all 
configure wireless port 22 interface 2 ap-scan send-probe off 
configure wireless port 22 interface 2 ap-scan probe-interval 100 
configure wireless port 22 interface 2 ap-scan off-channel max-wait 600 
configure wireless port 22 interface 2 ap-scan off-channel min-wait 60 
configure wireless port 22 interface 2 ap-scan results size 128 
configure wireless port 22 interface 2 ap-scan results timeout 300  
configure wireless port 22 interface 2 ap-scan added-trap off  
configure wireless port 22 interface 2 ap-scan removed-trap off  
configure wireless port 22 interface 2 ap-scan updated-trap off 
configure wireless port 22 interface 2 ap-scan off-channel continuous off
disable wireless port 22 interface 2 client-scan 
configure wireless port 22 interface 2 client-scan results size 128 
configure wireless port 22 interface 2 client-scan results timeout 600 
configure wireless port 22 interface 2 client-scan added-trap off 
configure wireless port 22 interface 2 client-scan removed-trap off 
disable wireless port 22 interface 2 client-history
configure wireless port 22 interface 2 client-history size 128
configure wireless port 22 interface 2 client-history timeout 600
#
# Wireless Interface Configuration for Interface 23:1
#
disable wireless port 23 interface 1 ap-scan 
disable wireless port 23 interface 1 ap-scan off-channel
configure wireless port 23 interface 1 ap-scan off-channel all 
configure wireless port 23 interface 1 ap-scan send-probe off 
configure wireless port 23 interface 1 ap-scan probe-interval 100 
configure wireless port 23 interface 1 ap-scan off-channel max-wait 600 
configure wireless port 23 interface 1 ap-scan off-channel min-wait 60 
configure wireless port 23 interface 1 ap-scan results size 128 
configure wireless port 23 interface 1 ap-scan results timeout 300  
configure wireless port 23 interface 1 ap-scan added-trap off  
configure wireless port 23 interface 1 ap-scan removed-trap off  
configure wireless port 23 interface 1 ap-scan updated-trap off 
configure wireless port 23 interface 1 ap-scan off-channel continuous off
disable wireless port 23 interface 1 client-scan 
configure wireless port 23 interface 1 client-scan results size 128 
configure wireless port 23 interface 1 client-scan results timeout 600 
configure wireless port 23 interface 1 client-scan added-trap off 
configure wireless port 23 interface 1 client-scan removed-trap off 
disable wireless port 23 interface 1 client-history
configure wireless port 23 interface 1 client-history size 128
configure wireless port 23 interface 1 client-history timeout 600
#
# Wireless Interface Configuration for Interface 23:2
#
disable wireless port 23 interface 2 ap-scan 
disable wireless port 23 interface 2 ap-scan off-channel
configure wireless port 23 interface 2 ap-scan off-channel all 
configure wireless port 23 interface 2 ap-scan send-probe off 
configure wireless port 23 interface 2 ap-scan probe-interval 100 
configure wireless port 23 interface 2 ap-scan off-channel max-wait 600 
configure wireless port 23 interface 2 ap-scan off-channel min-wait 60 
configure wireless port 23 interface 2 ap-scan results size 128 
configure wireless port 23 interface 2 ap-scan results timeout 300  
configure wireless port 23 interface 2 ap-scan added-trap off  
configure wireless port 23 interface 2 ap-scan removed-trap off  
configure wireless port 23 interface 2 ap-scan updated-trap off 
configure wireless port 23 interface 2 ap-scan off-channel continuous off
disable wireless port 23 interface 2 client-scan 
configure wireless port 23 interface 2 client-scan results size 128 
configure wireless port 23 interface 2 client-scan results timeout 600 
configure wireless port 23 interface 2 client-scan added-trap off 
configure wireless port 23 interface 2 client-scan removed-trap off 
disable wireless port 23 interface 2 client-history
configure wireless port 23 interface 2 client-history size 128
configure wireless port 23 interface 2 client-history timeout 600
#
# Wireless Interface Configuration for Interface 24:1
#
disable wireless port 24 interface 1 ap-scan 
disable wireless port 24 interface 1 ap-scan off-channel
configure wireless port 24 interface 1 ap-scan off-channel all 
configure wireless port 24 interface 1 ap-scan send-probe off 
configure wireless port 24 interface 1 ap-scan probe-interval 100 
configure wireless port 24 interface 1 ap-scan off-channel max-wait 600 
configure wireless port 24 interface 1 ap-scan off-channel min-wait 60 
configure wireless port 24 interface 1 ap-scan results size 128 
configure wireless port 24 interface 1 ap-scan results timeout 300  
configure wireless port 24 interface 1 ap-scan added-trap off  
configure wireless port 24 interface 1 ap-scan removed-trap off  
configure wireless port 24 interface 1 ap-scan updated-trap off 
configure wireless port 24 interface 1 ap-scan off-channel continuous off
disable wireless port 24 interface 1 client-scan 
configure wireless port 24 interface 1 client-scan results size 128 
configure wireless port 24 interface 1 client-scan results timeout 600 
configure wireless port 24 interface 1 client-scan added-trap off 
configure wireless port 24 interface 1 client-scan removed-trap off 
disable wireless port 24 interface 1 client-history
configure wireless port 24 interface 1 client-history size 128
configure wireless port 24 interface 1 client-history timeout 600
#
# Wireless Interface Configuration for Interface 24:2
#
disable wireless port 24 interface 2 ap-scan 
disable wireless port 24 interface 2 ap-scan off-channel
configure wireless port 24 interface 2 ap-scan off-channel all 
configure wireless port 24 interface 2 ap-scan send-probe off 
configure wireless port 24 interface 2 ap-scan probe-interval 100 
configure wireless port 24 interface 2 ap-scan off-channel max-wait 600 
configure wireless port 24 interface 2 ap-scan off-channel min-wait 60 
configure wireless port 24 interface 2 ap-scan results size 128 
configure wireless port 24 interface 2 ap-scan results timeout 300  
configure wireless port 24 interface 2 ap-scan added-trap off  
configure wireless port 24 interface 2 ap-scan removed-trap off  
configure wireless port 24 interface 2 ap-scan updated-trap off 
configure wireless port 24 interface 2 ap-scan off-channel continuous off
disable wireless port 24 interface 2 client-scan 
configure wireless port 24 interface 2 client-scan results size 128 
configure wireless port 24 interface 2 client-scan results timeout 600 
configure wireless port 24 interface 2 client-scan added-trap off 
configure wireless port 24 interface 2 client-scan removed-trap off 
disable wireless port 24 interface 2 client-history
configure wireless port 24 interface 2 client-history size 128
configure wireless port 24 interface 2 client-history timeout 600

# SSL configuration
configure ssl certificate pregenerated





-----BEGIN CERTIFICATE-----
MIIDLDCCAhSgAwIBAgIBADANBgkqhkiG9w0BAQQFADBPMQswCQYDVQQGEwJVUzEf
MB0GA1UEChMWRXh0cmVtZSBOZXR3b3JrcywgSW5jLjEfMB0GA1UEAxMWRXh0cmVt
ZSBOZXR3b3JrcywgSW5jLjAeFw0wMzEwMjEwNTMzNDdaFw0wNDEwMjAwNTMzNDda
ME8xCzAJBgNVBAYTAlVTMR8wHQYDVQQKExZFeHRyZW1lIE5ldHdvcmtzLCBJbmMu
MR8wHQYDVQQDExZFeHRyZW1lIE5ldHdvcmtzLCBJbmMuMIIBIjANBgkqhkiG9w0B
AQEFAAOCAQ8AMIIBCgKCAQEAwb1Ijc8GxujcjRy1ILPJL0NIPuWt4qI2hYjJuQM3
dkgZre+GywnBS0u0UA4o+uoRHBLDQACZ+nDcUWOwEOnfXz4tXTd3tX+yon9/slfc
WGTdFoHACP+rOZmStDu6FohlJCtmvEUSUYxUfuKBquMtmv2Tk8PPfu2Y+8dVAv+I
zHLWE6QjGWDF2sHZSYF1O6QBH5dE+g3Hs+aPNAhALTarUYYSI64CBe+w7xkbAOWH
6v96HiN/C2AoinmrhxdYOpRzpCaKMUWkabeLb2vND/LBqUyeN7WNAfzzVTdKNQ6v
as4caxvpixMWNNiLWWvmrIeA0eVaVJhmWbJ7j0VKJl8gMQIDAQABoxMwETAPBgNV
HRMBAf8EBTADAQH/MA0GCSqGSIb3DQEBBAUAA4IBAQA3gbwT2UTO0Sb28XakWYAp
XfcBzQJ4z6P7OM0V+Fv8aFGMVYj7NfX3znSwNPOHAyGA2a9WH+m1dDitq+22Gjkv
ifn6z5bx+uex2ZNXhxYowSkzwTFwS6fCccu8AXt2Tss1Ipq1AAbMIKqzphYuyF02
1qmdKGy0TXoJ6ILv7KZNXihzhX2J5Kg5DZoTooUTPBtN31Odoa2Zd5Pz0P8Wvm0B
2JLH8eKAlwXEj44IgRYZa/hc97TOrcpMbxpgvfMlDvxkcYnOmr8CKaKfEvkys9GQ
SV3fX2hPGciZurN0kGIQjqmyxHG2BmljZYAqAGwSOdNxK/QLmmSRY16ie0rWignT
-----END CERTIFICATE-----

.
configure ssl privkey pregenerated
-----BEGIN RSA PRIVATE KEY-----
Proc-Type: 4,ENCRYPTED
DEK-Info: DES-EDE3-CBC,64B58D632256A0CD

6DxuMKhxtFv+RQNS52O1enVpCVrdbYlUfo0vdvJdJicxNUo1C29Krk9FZJBlyqp4
h4Mx02dSd3nnIgZSTsS77LQo1tP6h4Lxccr5lT3v5+e+/Fh1DW3bmLOPpVlVtF31
N2W1imot9e7KLaMaR8+xPSdwwoaCxsUP/Gbo2dWKjt+73ILNd6dUKm15L4YP9KnG
jOTedHJTok44krmpikP7uw7dQSnk9ihNf3d3TYTkFbxuWgENock/ZRcctPZ15M8P
0b2Axs9Keb5ULrkSRzJOdUMigEWd7oDdsCUiOhAYpdZO3jQoGeqwflJlHygTHJI+
iqmIvpeHaC+aVFwda0VeaCXViVjHKD+iJECIVLdMNFzHUJnmY+akg6bKE+zRR1zk
gbHT/9BILXlgQtgkbeBdIaKssCNdWaUCDfqunIonM1BfRC/whsCe1DUE/+zLd47v
jTouzUGvLZy69PODXHU38eq37J5zP8SBx4yyLgRg0i2dnGvAO089Dt8CX93ooGMj
NRvs4Zhl2mbtBHevPXHsBsXCCZrb02a4sCRQdVgxl1og4gb0o9f66s+xyVEm/vYt
+o/9grkT0h6tPoQIE2O+/J6dOIH8Bt3n625im1klgkiTtIkS9N5a3IUUIEjrT/8v
WKEekKjsnkYDRXLeiuW4X0WcGXRJOjQhayYbWKdK28SInS+XP/zwEBA5bF0a62Wc
l5tnja0GUCjY/2ycpbuLD9EVo8DV6E2ARaXqF3Hya6KLog+3fcJ2dAIWkXPxkI39
dyEh3a+kkSw1WNf+r5BDQBFGM+rmuaCi7g6Sb+ctSMlObwSW4ag0DpJb+o9Ft1ZH
v0Y2hJx/ctPspO8Rk295QRCMUPk8ctRC/4bpg+itrXVL2YUeufw+x9L67r8k301l
1Wi3OlfQKddHsqrp+K0mYrLD+pywOuDrapkXHwSNqZkRLYa8J1AkUsz9j643MQES
b16LuOgyNmfibtZlKpXWhUe3qqRVP9vkrS88T1TvLjPTHJBQ7uKyQb32khSDEi4J
yWCzc1yLGDTkJ1qEQjryjk5Gjq6Im3s2u0MDfcE3/1GaKg5xF0X2RJ29yh1Ug75L
0cKmwIBVgLYk/+3Puf1OzxUwv9C+crptFUCd3Ln6JauinOt2qV9HZGcMB3hESeRy
iznpqJGqSTLqpG1xEup1OtLGPKe3RTqRs2C5eU/nqElNr3x3+jhofp1jSqq0STAy
ppiq4YUKquoJ2Aq2dbrsFeAEa2fB+9BdGCYxwUL4MBWRNtaiQhyJH1S1o6A543XK
HA72IA6DoxUnhNGGyVolxxf0L2yhyx74n2pkCIQ3fBhZJTztaqpoOBibm15uNvrR
2gNlrzBR3mjEw2jKJ/tm+9JwK7KUDI4nofvlJZP+/9c0sfCf7mgjlqVX635isrUk
62XJRzu9k2+7mlEgeAh3Yin9lbBeCcEEqJ/zvRT85L6x8Bv7FgLwqX1AgMIr0VxK
porL4LSjIzWNBfXiRiKR6EZ1QY4xVEaaahBIrwc+NImh9IBi1oV/FTcOicSAuH5l
qdg5+9/cSVFJuoE9TJGK74TSM0VkL/fdVO3VSOjx7fu4w+HATVHOzQ==
-----END RSA PRIVATE KEY-----
.

#Power Over Ethernet configurations

configure inline-power usage-threshold 90
disable inline-power ports 1
configure inline-power operator-limit 15400 ports 1
configure inline-power type  other  ports 1
configure inline-power violation-precedence  max-class-operator ports 1
enable inline-power ports 1
disable inline-power ports 2
configure inline-power operator-limit 15400 ports 2
configure inline-power type  other  ports 2
configure inline-power violation-precedence  max-class-operator ports 2
enable inline-power ports 2
disable inline-power ports 3
configure inline-power operator-limit 15400 ports 3
configure inline-power type  other  ports 3
configure inline-power violation-precedence  max-class-operator ports 3
enable inline-power ports 3
disable inline-power ports 4
configure inline-power operator-limit 15400 ports 4
configure inline-power type  other  ports 4
configure inline-power violation-precedence  max-class-operator ports 4
enable inline-power ports 4
disable inline-power ports 5
configure inline-power operator-limit 15400 ports 5
configure inline-power type  other  ports 5
configure inline-power violation-precedence  max-class-operator ports 5
enable inline-power ports 5
disable inline-power ports 6
configure inline-power operator-limit 15400 ports 6
configure inline-power type  other  ports 6
configure inline-power violation-precedence  max-class-operator ports 6
enable inline-power ports 6
disable inline-power ports 7
configure inline-power operator-limit 15400 ports 7
configure inline-power type  other  ports 7
configure inline-power violation-precedence  max-class-operator ports 7
enable inline-power ports 7
disable inline-power ports 8
configure inline-power operator-limit 15400 ports 8
configure inline-power type  other  ports 8
configure inline-power violation-precedence  max-class-operator ports 8
enable inline-power ports 8
disable inline-power ports 9
configure inline-power operator-limit 15400 ports 9
configure inline-power type  other  ports 9
configure inline-power violation-precedence  max-class-operator ports 9
enable inline-power ports 9
disable inline-power ports 10
configure inline-power operator-limit 15400 ports 10
configure inline-power type  other  ports 10
configure inline-power violation-precedence  max-class-operator ports 10
enable inline-power ports 10
disable inline-power ports 11
configure inline-power operator-limit 15400 ports 11
configure inline-power type  other  ports 11
configure inline-power violation-precedence  max-class-operator ports 11
enable inline-power ports 11
disable inline-power ports 12
configure inline-power operator-limit 15400 ports 12
configure inline-power type  other  ports 12
configure inline-power violation-precedence  max-class-operator ports 12
enable inline-power ports 12
disable inline-power ports 13
configure inline-power operator-limit 15400 ports 13
configure inline-power type  other  ports 13
configure inline-power violation-precedence  max-class-operator ports 13
enable inline-power ports 13
disable inline-power ports 14
configure inline-power operator-limit 15400 ports 14
configure inline-power type  other  ports 14
configure inline-power violation-precedence  max-class-operator ports 14
enable inline-power ports 14
disable inline-power ports 15
configure inline-power operator-limit 15400 ports 15
configure inline-power type  other  ports 15
configure inline-power violation-precedence  max-class-operator ports 15
enable inline-power ports 15
disable inline-power ports 16
configure inline-power operator-limit 15400 ports 16
configure inline-power type  other  ports 16
configure inline-power violation-precedence  max-class-operator ports 16
enable inline-power ports 16
disable inline-power ports 17
configure inline-power operator-limit 15400 ports 17
configure inline-power type  other  ports 17
configure inline-power violation-precedence  max-class-operator ports 17
enable inline-power ports 17
disable inline-power ports 18
configure inline-power operator-limit 15400 ports 18
configure inline-power type  other  ports 18
configure inline-power violation-precedence  max-class-operator ports 18
enable inline-power ports 18
disable inline-power ports 19
configure inline-power operator-limit 15400 ports 19
configure inline-power type  other  ports 19
configure inline-power violation-precedence  max-class-operator ports 19
enable inline-power ports 19
disable inline-power ports 20
configure inline-power operator-limit 15400 ports 20
configure inline-power type  other  ports 20
configure inline-power violation-precedence  max-class-operator ports 20
enable inline-power ports 20
disable inline-power ports 21
configure inline-power operator-limit 15400 ports 21
configure inline-power type  other  ports 21
configure inline-power violation-precedence  max-class-operator ports 21
enable inline-power ports 21
disable inline-power ports 22
configure inline-power operator-limit 15400 ports 22
configure inline-power type  other  ports 22
configure inline-power violation-precedence  max-class-operator ports 22
enable inline-power ports 22
disable inline-power ports 23
configure inline-power operator-limit 15400 ports 23
configure inline-power type  other  ports 23
configure inline-power violation-precedence  max-class-operator ports 23
enable inline-power ports 23
disable inline-power ports 24
configure inline-power operator-limit 15400 ports 24
configure inline-power type  other  ports 24
configure inline-power violation-precedence  max-class-operator ports 24
enable inline-power ports 24
# LLDP
configure lldp transmit-interval 30
configure lldp transmit-hold 4
configure lldp transmit-delay 2
configure lldp reinitialize-delay 2
configure lldp snmp-notification-interval 5
enable lldp ports 1
configure lldp ports 1 advertise port-description
configure lldp ports 1 advertise system-name
configure lldp ports 1 advertise system-description
configure lldp ports 1 advertise system-capabilities
configure lldp ports 1 advertise management-address
configure lldp ports 1 advertise vendor-specific dot1 vlan-name vlan vlan52
configure lldp ports 1 advertise vendor-specific dot3 mac-phy
configure lldp ports 1 advertise vendor-specific dot3 link-aggregation
enable snmp traps lldp port 1
enable lldp ports 2
configure lldp ports 2 advertise port-description
configure lldp ports 2 advertise system-name
configure lldp ports 2 advertise system-description
configure lldp ports 2 advertise system-capabilities
configure lldp ports 2 advertise management-address
configure lldp ports 2 advertise vendor-specific dot1 vlan-name vlan Default
configure lldp ports 2 advertise vendor-specific dot3 mac-phy
configure lldp ports 2 advertise vendor-specific dot3 link-aggregation
enable snmp traps lldp port 2
enable lldp ports 3
configure lldp ports 3 advertise port-description
configure lldp ports 3 advertise system-name
configure lldp ports 3 advertise system-description
configure lldp ports 3 advertise system-capabilities
configure lldp ports 3 advertise management-address
configure lldp ports 3 advertise vendor-specific dot1 vlan-name vlan vlan52
configure lldp ports 3 advertise vendor-specific dot3 mac-phy
configure lldp ports 3 advertise vendor-specific dot3 link-aggregation
enable snmp traps lldp port 3
enable lldp ports 4
configure lldp ports 4 advertise port-description
configure lldp ports 4 advertise system-name
configure lldp ports 4 advertise system-description
configure lldp ports 4 advertise system-capabilities
configure lldp ports 4 advertise management-address
configure lldp ports 4 advertise vendor-specific dot3 mac-phy
configure lldp ports 4 advertise vendor-specific dot3 link-aggregation
enable snmp traps lldp port 4
enable lldp ports 5
configure lldp ports 5 advertise port-description
configure lldp ports 5 advertise system-name
configure lldp ports 5 advertise system-description
configure lldp ports 5 advertise system-capabilities
configure lldp ports 5 advertise management-address
configure lldp ports 5 advertise vendor-specific dot3 mac-phy
configure lldp ports 5 advertise vendor-specific dot3 link-aggregation
enable snmp traps lldp port 5
enable lldp ports 6
configure lldp ports 6 advertise port-description
configure lldp ports 6 advertise system-name
configure lldp ports 6 advertise system-description
configure lldp ports 6 advertise system-capabilities
configure lldp ports 6 advertise management-address
configure lldp ports 6 advertise vendor-specific dot3 mac-phy
configure lldp ports 6 advertise vendor-specific dot3 link-aggregation
enable snmp traps lldp port 6
enable lldp ports 7
configure lldp ports 7 advertise port-description
configure lldp ports 7 advertise system-name
configure lldp ports 7 advertise system-description
configure lldp ports 7 advertise system-capabilities
configure lldp ports 7 advertise management-address
configure lldp ports 7 advertise vendor-specific dot3 mac-phy
configure lldp ports 7 advertise vendor-specific dot3 link-aggregation
enable snmp traps lldp port 7
enable lldp ports 8
configure lldp ports 8 advertise port-description
configure lldp ports 8 advertise system-name
configure lldp ports 8 advertise system-description
configure lldp ports 8 advertise system-capabilities
configure lldp ports 8 advertise management-address
configure lldp ports 8 advertise vendor-specific dot1 vlan-name vlan vlan52
configure lldp ports 8 advertise vendor-specific dot3 mac-phy
configure lldp ports 8 advertise vendor-specific dot3 link-aggregation
enable snmp traps lldp port 8
enable lldp ports 9
configure lldp ports 9 advertise port-description
configure lldp ports 9 advertise system-name
configure lldp ports 9 advertise system-description
configure lldp ports 9 advertise system-capabilities
configure lldp ports 9 advertise management-address
configure lldp ports 9 advertise vendor-specific dot3 mac-phy
configure lldp ports 9 advertise vendor-specific dot3 link-aggregation
enable snmp traps lldp port 9
enable lldp ports 10
configure lldp ports 10 advertise port-description
configure lldp ports 10 advertise system-name
configure lldp ports 10 advertise system-description
configure lldp ports 10 advertise system-capabilities
configure lldp ports 10 advertise management-address
configure lldp ports 10 advertise vendor-specific dot3 mac-phy
configure lldp ports 10 advertise vendor-specific dot3 link-aggregation
enable snmp traps lldp port 10
enable lldp ports 11
configure lldp ports 11 advertise port-description
configure lldp ports 11 advertise system-name
configure lldp ports 11 advertise system-description
configure lldp ports 11 advertise system-capabilities
configure lldp ports 11 advertise management-address
configure lldp ports 11 advertise vendor-specific dot3 mac-phy
configure lldp ports 11 advertise vendor-specific dot3 link-aggregation
enable snmp traps lldp port 11
enable lldp ports 12
configure lldp ports 12 advertise port-description
configure lldp ports 12 advertise system-name
configure lldp ports 12 advertise system-description
configure lldp ports 12 advertise system-capabilities
configure lldp ports 12 advertise management-address
configure lldp ports 12 advertise vendor-specific dot3 mac-phy
configure lldp ports 12 advertise vendor-specific dot3 link-aggregation
enable snmp traps lldp port 12
enable lldp ports 13
configure lldp ports 13 advertise port-description
configure lldp ports 13 advertise system-name
configure lldp ports 13 advertise system-description
configure lldp ports 13 advertise system-capabilities
configure lldp ports 13 advertise management-address
configure lldp ports 13 advertise vendor-specific dot3 mac-phy
configure lldp ports 13 advertise vendor-specific dot3 link-aggregation
enable snmp traps lldp port 13
enable lldp ports 14
configure lldp ports 14 advertise port-description
configure lldp ports 14 advertise system-name
configure lldp ports 14 advertise system-description
configure lldp ports 14 advertise system-capabilities
configure lldp ports 14 advertise management-address
configure lldp ports 14 advertise vendor-specific dot3 mac-phy
configure lldp ports 14 advertise vendor-specific dot3 link-aggregation
enable snmp traps lldp port 14
enable lldp ports 15
configure lldp ports 15 advertise port-description
configure lldp ports 15 advertise system-name
configure lldp ports 15 advertise system-description
configure lldp ports 15 advertise system-capabilities
configure lldp ports 15 advertise management-address
configure lldp ports 15 advertise vendor-specific dot3 mac-phy
configure lldp ports 15 advertise vendor-specific dot3 link-aggregation
enable snmp traps lldp port 15
enable lldp ports 16
configure lldp ports 16 advertise port-description
configure lldp ports 16 advertise system-name
configure lldp ports 16 advertise system-description
configure lldp ports 16 advertise system-capabilities
configure lldp ports 16 advertise management-address
configure lldp ports 16 advertise vendor-specific dot3 mac-phy
configure lldp ports 16 advertise vendor-specific dot3 link-aggregation
enable snmp traps lldp port 16
enable lldp ports 17
configure lldp ports 17 advertise port-description
configure lldp ports 17 advertise system-name
configure lldp ports 17 advertise system-description
configure lldp ports 17 advertise system-capabilities
configure lldp ports 17 advertise management-address
configure lldp ports 17 advertise vendor-specific dot3 mac-phy
configure lldp ports 17 advertise vendor-specific dot3 link-aggregation
enable snmp traps lldp port 17
enable lldp ports 18
configure lldp ports 18 advertise port-description
configure lldp ports 18 advertise system-name
configure lldp ports 18 advertise system-description
configure lldp ports 18 advertise system-capabilities
configure lldp ports 18 advertise management-address
configure lldp ports 18 advertise vendor-specific dot3 mac-phy
configure lldp ports 18 advertise vendor-specific dot3 link-aggregation
enable snmp traps lldp port 18
enable lldp ports 19
configure lldp ports 19 advertise port-description
configure lldp ports 19 advertise system-name
configure lldp ports 19 advertise system-description
configure lldp ports 19 advertise system-capabilities
configure lldp ports 19 advertise management-address
configure lldp ports 19 advertise vendor-specific dot1 vlan-name vlan vlan12
configure lldp ports 19 advertise vendor-specific dot3 mac-phy
configure lldp ports 19 advertise vendor-specific dot3 link-aggregation
enable snmp traps lldp port 19
enable lldp ports 20
configure lldp ports 20 advertise port-description
configure lldp ports 20 advertise system-name
configure lldp ports 20 advertise system-description
configure lldp ports 20 advertise system-capabilities
configure lldp ports 20 advertise management-address
configure lldp ports 20 advertise vendor-specific dot3 mac-phy
configure lldp ports 20 advertise vendor-specific dot3 link-aggregation
enable snmp traps lldp port 20
enable lldp ports 21
configure lldp ports 21 advertise port-description
configure lldp ports 21 advertise system-name
configure lldp ports 21 advertise system-description
configure lldp ports 21 advertise system-capabilities
configure lldp ports 21 advertise management-address
configure lldp ports 21 advertise vendor-specific dot3 mac-phy
configure lldp ports 21 advertise vendor-specific dot3 link-aggregation
enable snmp traps lldp port 21
enable lldp ports 22
configure lldp ports 22 advertise port-description
configure lldp ports 22 advertise system-name
configure lldp ports 22 advertise system-description
configure lldp ports 22 advertise system-capabilities
configure lldp ports 22 advertise management-address
configure lldp ports 22 advertise vendor-specific dot3 mac-phy
configure lldp ports 22 advertise vendor-specific dot3 link-aggregation
enable snmp traps lldp port 22
enable lldp ports 23
configure lldp ports 23 advertise port-description
configure lldp ports 23 advertise system-name
configure lldp ports 23 advertise system-description
configure lldp ports 23 advertise system-capabilities
configure lldp ports 23 advertise management-address
configure lldp ports 23 advertise vendor-specific dot3 mac-phy
configure lldp ports 23 advertise vendor-specific dot3 link-aggregation
enable snmp traps lldp port 23
enable lldp ports 24
configure lldp ports 24 advertise port-description
configure lldp ports 24 advertise system-name
configure lldp ports 24 advertise system-description
configure lldp ports 24 advertise system-capabilities
configure lldp ports 24 advertise management-address
configure lldp ports 24 advertise vendor-specific dot3 mac-phy
configure lldp ports 24 advertise vendor-specific dot3 link-aggregation
enable snmp traps lldp port 24
enable lldp ports 25
configure lldp ports 25 advertise port-description
configure lldp ports 25 advertise system-name
configure lldp ports 25 advertise system-description
configure lldp ports 25 advertise system-capabilities
configure lldp ports 25 advertise management-address
configure lldp ports 25 advertise vendor-specific dot3 mac-phy
configure lldp ports 25 advertise vendor-specific dot3 link-aggregation
enable snmp traps lldp port 25
enable lldp ports 26
configure lldp ports 26 advertise port-description
configure lldp ports 26 advertise system-name
configure lldp ports 26 advertise system-description
configure lldp ports 26 advertise system-capabilities
configure lldp ports 26 advertise management-address
configure lldp ports 26 advertise vendor-specific dot3 mac-phy
configure lldp ports 26 advertise vendor-specific dot3 link-aggregation
enable snmp traps lldp port 26

#
# End of configuration file for "MIA-Extreme300".
#

END
