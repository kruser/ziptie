package DataPassport1600;

use strict;
use warnings;
use Exporter 'import';
our @EXPORT_OK = qw($responsesNP1600);

our $responsesNP1600 = {};

$responsesNP1600->{'switch'} = <<'END';
show switch

Command: show switch


Device Type       : Passport-1612G (1.2.1.0)

MAC Address       : 00-0C-F7-0D-D0-00

IP Address        : 10.100.2.25 (Manual)

VLAN Name         : default

Subnet Mask       : 255.255.255.0

Default Gateway   : 10.100.2.1

Boot PROM Version : Build 0.00.003

Firmware Version  : Build KKKKKKKK

Hardware Version  : 5A1 (Samsung A)

Device S/N        : SDLI2G004M

System Name       : passport1612g

System Location   : 

System Contact    : pablo

Primary Power     : Ready

Redundant Power   : Not Ready

Spanning Tree     : Enabled

IGMP Snooping     : Disabled

RIP               : Disabled

DVMRP             : Disabled

OSPF              : Disabled

TELNET            : Enabled (TCP 23)

ICMP Unreachable  : Disabled

 [7mCTRL+C[0m [7mESC[0m [7mq[0m Quit [7mSPACE[0m [7mn[0m Next Page
                                                                                
[1A[28C

SSH               : Enabled (TCP 22)

TACACS+           : Enabled

VRRP              : Disabled

SYSLOG            : Disabled

WEB               : Enabled (TCP 80)

RMON              : Disabled

SNMP              : Enabled

Auto Topology     : Enabled

SNTP              : Enabled

System Boot Time  : 2007/11/07 19:35:27

passport1612g:4# 

END


$responsesNP1600->{'config'} = <<'END';


#---------------------------------------------

#2008/4/1 17:15:54 TUE

#Box Type             : Passport-1600

#Software Release     : 1.2.1.0     

#---------------------------------------------



# BASIC


config serial_port baud_rate 9600 auto_logout 10_minutes

enable telnet 23

enable web 80

enable tdp

config password_aging 999

config secure_mode normal

config banner default TRUE


# STORM


config traffic control dlf disabled

config traffic control 1-12 broadcast disabled multicast disabled

config cp_limit 1-12 state disabled

config cp_limit 1-12 multicast_limit 2000 broadcast_limit 1700


# FILTER



# SYSLOG


disable syslog

config syslog max_hosts 5

config remote_user log state disabled


# MIRROR


disable mirror


# QOS


config 802.1p default_priority 1-12 priority 0


# PORT


config mgmt_port speed auto flow_control disabled state enabled

config ports 1-12 speed auto flow_control disabled learning enabled state enabled


# MANAGEMENT


enable snmp traps 

enable snmp authenticate traps 

config snmp system_contact FCA_ALTERPOINT

disable rmon 

enable snmp 
 create snmp community 4DBB21C938E23FF75C32E849B2FDC778E5FB6C104DBB21C938E23FF75C32E849B2FDC778E5FB6C103DCE43A551813FF75C32E849B2FDC778E5FB6C104DBB21C938E23FF75C32E849B2FDC778E5FB6C10 readonly
 create snmp community 49AB30D134EF49F75C32E849B2FDC778E5FB6C1049AB30D134EF49F75C32E849B2FDC778E5FB6C103DCE43A551813FF75C32E849B2FDC778E5FB6C1049AB30D134EF49F75C32E849B2FDC778E5FB6C10 readwrite


# VLAN


config vlan default delete 1-12

config vlan default add untagged 1-12

config vlan_ports 1-12 ingress_checking enabled

config vlan_ports 1-12 acceptable_frame all


# FDB


config fdb aging_time 300


# STP


 disable stp

 config stp version stp-compatible

 config stp maxage 20 hellotime 2 forwarddelay 15 priority 32768 fbpdu enable

 config stp ports 1-12 cost auto priority 128 state enable

 enable stp


# FLCLS


config flow_classifier template_1 mode l4_switch template_2 mode qos

config flow_classifier template_id 1 mode_parameters l4_session tcp_session fields dip

config flow_classifier template_id 2 mode_parameters qos_flavor 802.1p

disable ip_fragment_filter

config scheduling ports 1-12 class_id 0 max_packet 16

config scheduling ports 1-12 class_id 1 max_packet 24

config scheduling ports 1-12 class_id 2 max_packet 40


# SNOOP



# LACP



# IP


config ipif System vlan default ipaddress 10.100.2.25/24 state enabled directed-broadcast enabled

config ip_forwarding enabled


# ROUTE


config route preference static 60

config route preference rip 100

config route preference ospfIntra 80

config route preference ospfInter 90

config route preference ospfExt1 110

config route preference ospfExt2 115

create iproute default 10.100.2.1 1


# ARP


config arp_aging time 20
disable arp_req_rate_limit
config arp_req_rate_limit 50


# IGMP


config igmp ipif System version 2 query_interval 125 max_response_time 10 robustness_variable 2 last_member_query_interval 1 state disabled 


# DVMRP


disable dvmrp

config dvmrp ipif System metric 1 probe 10 neighbor_timeout 35 state disabled 


# RIP


config rip ipif System authentication disabled tx_mode v1_compatible rx_mode v1_and_v2 state disabled

disable rip


# MD5



# OSPF


config ospf ipif System area 0.0.0.0 priority 1 hello_interval 10 dead_interval 40 metric 1 authentication none state disabled

config ospf router_id 0.0.0.0

disable ospf


# DNSR


disable dnsr

config dnsr primary nameserver 0.0.0.0

config dnsr secondary nameserver 0.0.0.0

disable dnsr cache

disable dnsr static


# BOOTP


disable bootp_relay

config bootp_relay hops 4 time 0 


# AAA


config login_authen response_timeout 30

config authentication login console local 

config authentication login telnet tacacs+ local

config authentication login ssh tacacs+ local

config authentication admin console local 

config authentication admin telnet tacacs+ local

config authentication admin ssh tacacs+ local

create tacacs+_server 10.100.32.137 tcp_port 49 key cisco timeout 5

enable authentication


# VRRP


disable vrrp

disable vrrp ping


# NTP

config sntp primary server 10.10.1.58 Retry Interval 5 Unicast Polling Interval 0 Timezone GMT Minus 5 : 0 state enabled
config time Daylight-Saving-Time state disabled offset 0 start 0 0 0 end 0 0 0


# SSH


config ssh server maxsession 3

config ssh server timeout 120

config ssh server authfail 5

config ssh server rekey never

config ssh server port 22

enable ssh

#EOF
END


$responsesNP1600->{'ipif'} = <<'END';
show ipif

Command: show ipif


 IP Interface Settings


 Interface Name    : System

 IP Address        : 10.100.2.25     (MANUAL)

 Subnet Mask       : 255.255.255.0

 VLAN Name         : default

 Admin. State      : Enabled

 Interface Status  : Link UP

 Directed-Broadcast: Enabled

 Member Ports      : 1-12,mgmt_port


Total Entries : 1


passport1612g:4# 

END


$responsesNP1600->{'routes'} = <<'END';
show iproute

Command: show iproute



Routing Table


IP Address/Netmask Gateway         Interface    Cost     Protocol       PREF

------------------ --------------- ------------ -------- -------------- ----

0.0.0.0            10.100.2.1      System       1        Default        60  

10.100.2.0/24      10.100.2.25     System       1        Local          0   


Total Entries : 2


passport1612g:4# 

END

$responsesNP1600->{'accounts'} = <<'END';
show account
Command: show account

 Current Accounts:
 Username             Access Level  Log
 ---------------      ------------  -------
 rw                   User          Enabled
 rwa                  Admin         Enabled
 ssh                  Admin         Enabled
 testlab              Admin         Enabled

Total Entries: 4

passport1612g:4#

END

$responsesNP1600->{'snmp'} = <<'END';
show snmp
Command: show snmp

System Name        : passport1612g
System Location    : 
System Contact     : pablo
SNMP Trap          : Enabled
Authenticate Traps : Enabled
SNMP Status        : Enabled

Community String                             Rights
-------------------------------------------- -----------
****                                         Read-Only
****                                         Read/Write

Total Entries: 2 


Trap receiver is not set!
passport1612g:4#

END

$responsesNP1600->{'ports'} = <<'END';
show ports

Command: show ports


 Port   Port           Settings             Connection           Address 

        State    Speed/Duplex/FlowCtrl  Speed/Duplex/FlowCtrl    Learning

 ----  --------  ---------------------  ---------------------    --------

 1     Enabled    Auto/Disabled          Link Down               Enabled 

 2     Enabled    Auto/Disabled          Link Down               Enabled 

 3     Enabled    Auto/Disabled          Link Down               Enabled 

 4     Enabled    Auto/Disabled          Link Down               Enabled 

 5     Enabled    Auto/Disabled          Link Down               Enabled 

 6     Enabled    Auto/Disabled          Link Down               Enabled 

 7     Enabled    Auto/Disabled          Link Down               Enabled 

 8     Enabled    Auto/Disabled          Link Down               Enabled 

 9     Enabled    Auto/Disabled          Link Down               Enabled 

 10    Enabled    Auto/Disabled          Link Down               Enabled 

 11    Enabled    Auto/Disabled          Link Down               Enabled 

 12    Enabled    Auto/Disabled          Link Down               Enabled 









 [7mCTRL+C[0m [7mESC[0m [7mq[0m Quit [7mSPACE[0m [7mn[0m Next Page [7mp[0m Previous Page [7mr[0m Refresh 


END


$responsesNP1600->{'stp_ports'} = <<'END';
show stp ports 1-12

Command: show stp ports 1-12



 Port Connection          State    Cost      Priority Status     STP Name

 ---- ------------------- -------- --------- -------- ---------- --------

 1    Link Down           Enabled *4         128      Disabled   s0    

 2    Link Down           Enabled *4         128      Disabled   s0    

 3    Link Down           Enabled *4         128      Disabled   s0    

 4    Link Down           Enabled *4         128      Disabled   s0    

 5    Link Down           Enabled *4         128      Disabled   s0    

 6    Link Down           Enabled *4         128      Disabled   s0    

 7    Link Down           Enabled *4         128      Disabled   s0    

 8    Link Down           Enabled *4         128      Disabled   s0    

 9    Link Down           Enabled *4         128      Disabled   s0    

 10   Link Down           Enabled *4         128      Disabled   s0    

 11   Link Down           Enabled *4         128      Disabled   s0    

 12   Link Down           Enabled *4         128      Disabled   s0    










 [7mCTRL+C[0m [7mESC[0m [7mq[0m Quit [7mSPACE[0m [7mn[0m Next Page

END


$responsesNP1600->{'port_mgmt'} = <<'END';
show mgmt_port

Command: show mgmt_port


 Port           Settings             Connection        

 State     Speed/Duplex/FlowCtrl  Speed/Duplex/FlowCtrl

 --------  ---------------------  ---------------------

 Enabled    Auto/Disabled          100M/Full/None      




















 [7mCTRL+C[0m [7mESC[0m [7mq[0m Quit [7mSPACE[0m [7mn[0m Next Page [7mp[0m Previous Page [7mr[0m Refresh 

END


$responsesNP1600->{'stp'} = <<'END';
show stp

Command: show stp


 STP Bridge Global Settings

 ---------------------------

 STP Status        : Enabled 

 STP Version       : STP compatible

 Max Age           : 20     [0J

 Hello Time        : 2      

 Priority          : 32768  

 Forward Delay     : 15     

 Forwarding BPDU   : Enabled


 Designated Root Bridge : 00-0C-F7-0D-D0-00

 Root Priority          : 32768

 Cost to Root           : 0                      

 Root Port              : None                

 Last Topology Change   : 9369124    sec

 Topology Changes Count : 0                      








 [7mCTRL+C[0m [7mESC[0m [7mq[0m Quit [7mSPACE[0m [7mn[0m Next Page [7mp[0m Previous Page [7mr[0m Refresh 

END


