package DataSSR;

use strict;
use warnings;
use Exporter 'import';
our @EXPORT_OK = qw($responsesSSR);

our $responsesSSR = {};

$responsesSSR->{'sys_contact'} = <<'END';
system [?25l
IPM-2000# system  
[16C[?25h[?25l
IPM-2000# system   
[17C[?25hshow [?25l
IPM-2000# system show  
[21C[?25h[?25l
IPM-2000# system show   
[22C[?25hcontact
Administrative contact: Change1
IPM-2000# 

END

$responsesSSR->{'sys_location'} = <<'END';
system [?25l
IPM-2000# system  
[16C[?25h[?25l
IPM-2000# system   
[17C[?25hshow [?25l
IPM-2000# system show  
[21C[?25h[?25l
IPM-2000# system show   
[22C[?25hlocation
System location: Test12345
IPM-2000# 

END

$responsesSSR->{'sys_name'} = <<'END';
system [?25l
IPM-2000# system  
[16C[?25h[?25l
IPM-2000# system   
[17C[?25hshow [?25l
IPM-2000# system show  
[21C[?25h[?25l
IPM-2000# system show   
[22C[?25hname
System name: IPM-2000
IPM-2000# 

END

$responsesSSR->{'uptime'} = <<'END';
system [?25l
IPM-2000# system  
[16C[?25h[?25l
IPM-2000# system   
[17C[?25hshow [?25l
IPM-2000# system show  
[21C[?25h[?25l
IPM-2000# system show   
[22C[?25huptime
System started 2008-02-21 10:57:07
System up 6 days, 2 hours, 57 minutes, 40 seconds.
IPM-2000# 

END

$responsesSSR->{'version'} = <<'END';
system [?25l
IPM-2000# system  
[16C[?25h[?25l
IPM-2000# system   
[17C[?25hshow [?25l
IPM-2000# system show  
[21C[?25h[?25l
IPM-2000# system show   
[22C[?25hversion
Software Information
  Software Version   : E9.0.7.5
  Copyright          : Copyright (c) 2003 Motorola, Inc.
  Image Information  : Version E9.0.7.5, built on Tue Apr 29 17:28:02 2003
  Image Boot Location: slot0:boot/xp9075/
  Boot Prom Version  : prom-E3.0.0.0
IPM-2000# 

END

$responsesSSR->{'hardware'} = <<'END';
system [?25l
IPM-2000# system  
[16C[?25h[?25l
IPM-2000# system   
[17C[?25hshow [?25l
IPM-2000# system show  
[21C[?25h[?25l
IPM-2000# system show   
[22C[?25hhardware

Hardware Information
  System type        : IPM 2000, Rev. 0
  CPU Module type    : CPU-IPM2, Rev. 0
  Processor          : R5000, Rev 2.1, 160.00 MHz
    Icache size      : 32 Kbytes, 32 bytes/line
    Dcache size      : 32 Kbytes, 32 bytes/line
  CPU Board Frequency: 80.00 MHz
  Backplane frequency: 58.00 MHz
  Flash Memory       : 8MB 
  System Memory size : 128 MBytes
  Network Memory size: 8 MBytes
  MAC Addresses
    System           : 0004bd:2a6580
    10Base-T CPU Port: 0004bd:2a6581
    Internal Use     : 0004bd:2a6582 -> 0004bd:2a65bf
  CPU Mode           : Active

Power Supply Information

  PS1: present
  PS2: none


Slot Information
  Slot    CM,  Module: Control Module  Rev. 0 

  Slot  CM/1,  Module: 10/100-TX  Rev. 1.0 
    Port:   et.1.1,  Media Type: 10/100-Mbit Ethernet,  Physical Port: 17
    Port:   et.1.2,  Media Type: 10/100-Mbit Ethernet,  Physical Port: 18
    Port:   et.1.3,  Media Type: 10/100-Mbit Ethernet,  Physical Port: 19
    Port:   et.1.4,  Media Type: 10/100-Mbit Ethernet,  Physical Port: 20
    Port:   et.1.5,  Media Type: 10/100-Mbit Ethernet,  Physical Port: 21
    Port:   et.1.6,  Media Type: 10/100-Mbit Ethernet,  Physical Port: 22
    Port:   et.1.7,  Media Type: 10/100-Mbit Ethernet,  Physical Port: 23
    Port:   et.1.8,  Media Type: 10/100-Mbit Ethernet,  Physical Port: 24

  Slot     2,  Module: 10/100-TX  Rev. 1.0 
    Port:   et.2.1,  Media Type: 10/100-Mbit Ethernet,  Physical Port: 33
    Port:   et.2.2,  Media Type: 10/100-Mbit Ethernet,  Physical Port: 34
    Port:   et.2.3,  Media Type: 10/100-Mbit Ethernet,  Physical Port: 35
    Port:   et.2.4,  Media Type: 10/100-Mbit Ethernet,  Physical Port: 36
    Port:   et.2.5,  Media Type: 10/100-Mbit Ethernet,  Physical Port: 37
    Port:   et.2.6,  Media Type: 10/100-Mbit Ethernet,  Physical Port: 38
    Port:   et.2.7,  Media Type: 10/100-Mbit Ethernet,  Physical Port: 39
    Port:   et.2.8,  Media Type: 10/100-Mbit Ethernet,  Physical Port: 40
IPM-2000# 

END

$responsesSSR->{'active-config'} = <<'END';
!
! Last modified from Console on 2008-02-21 10:57:26
!
version  9.0
interface create ip manage address-netmask 10.100.2.8/24 port et.1.1
ip add route default gateway 10.100.2.1
system set hashed-password enable KnOAqn 58d7b09580d773b46557f573004d656c
system set hashed-password config pDDGie ed0e48ddc317d7ee0a918f9d81ad0465
system set hashed-password login IOicWj ecb55454f84c71bb533ba3c205102822
system set contact Change1
system set timezone cst
system set location Test12345
system set name IPM-2000
ntp set server 10.10.1.36
ssh-server set protocol-version both
snmp set community public privilege read v1
snmp set community testenv privilege read-write v1
snmp set community Brandon privilege read v1
snmp set community Shopp privilege read-write v1
snmp set target target1 ip-address 1.1.1.1
snmp set target target2 ip-address 10.10.1.110
tacacs-plus accounting command level 15
tacacs-plus authentication login
tacacs-plus authentication enable
tacacs-plus set server 10.100.32.137 key cisco
tacacs-plus enable
system set terminal rows 0


END

$responsesSSR->{'startup-config'} = <<'END';
!
! Last modified from Telnet (10.10.1.218) on 2007-04-24 11:49:06
!
version  9.0
interface create ip manage address-netmask 10.100.2.8/24 port et.1.1
ip add route default gateway 10.100.2.1
system set hashed-password enable KnOAqn 58d7b09580d773b46557f573004d656c
system set hashed-password config pDDGie ed0e48ddc317d7ee0a918f9d81ad0465
system set hashed-password login IOicWj ecb55454f84c71bb533ba3c205102822
system set contact Change1
system set timezone cst
system set location Test12345
system set name IPM-2000
ntp set server 10.10.1.36
ssh-server set protocol-version both
snmp set community public privilege read v1
snmp set community testenv privilege read-write v1
snmp set community Brandon privilege read v1
snmp set community Shopp privilege read-write v1
snmp set target target1 ip-address 1.1.1.1
snmp set target target2 ip-address 10.10.1.110
tacacs-plus accounting command level 15
tacacs-plus authentication login
tacacs-plus authentication enable
tacacs-plus set server 10.100.32.137 key cisco
tacacs-plus enable
system set terminal rows 0


END

$responsesSSR->{'interfaces'} = <<'END';
interface [?25l
IPM-2000# interface  
[19C[?25h[?25l
IPM-2000# interface   
[20C[?25hshow [?25l
IPM-2000# interface show  
[24C[?25h[?25l
IPM-2000# interface show   
[25C[?25hip [?25l
IPM-2000# interface show ip  
[27C[?25h[?25l
IPM-2000# interface show ip   
[28C[?25hall

Interface lo0:
    Admin State:          up
    Operational State:    up
    Capabilities:         <LOOPBACK,MULTICAST>
    Configuration:
       MTU:               1968
       MAC Encapsulation: Unknown
       MAC Address:       None/Unknown
       IP Address:        127.0.0.1/8 

Interface manage:
    Admin State:          up
    Operational State:    up
    Capabilities:         <BROADCAST,SIMPLEX,MULTICAST>
    Configuration:
       VLAN:              SYS_L3_manage
       Ports:             et.1.1
       MTU:               1500
       MAC Encapsulation: ETHERNET_II
       MAC Address:       00:04:BD:2A:65:80
       IP Address:        10.100.2.8/24  (broadcast: 10.100.2.255)
IPM-2000# 

END

$responsesSSR->{'mau'} = <<'END';
port [?25l
IPM-2000# port  
[14C[?25h[?25l
IPM-2000# port   
[15C[?25hshow [?25l
IPM-2000# port show  
[19C[?25h[?25l
IPM-2000# port show   
[20C[?25hMAU [?25l
IPM-2000# port show MAU  
[23C[?25h[?25l
IPM-2000# port show MAU   
[24C[?25hall-ports

                                                                     Auto Neg.
Port     MAU Type         Default Type     Jack Type   Status        Supported
------   --------------   --------------   ---------   -----------   ---------
et.1.1   100 BaseTX FD    100 BaseTX HD    RJ45        operational   yes
et.1.2   100 BaseTX HD    100 BaseTX HD    RJ45        operational   yes
et.1.3   100 BaseTX HD    100 BaseTX HD    RJ45        operational   yes
et.1.4   100 BaseTX HD    100 BaseTX HD    RJ45        operational   yes
et.1.5   100 BaseTX HD    100 BaseTX HD    RJ45        operational   yes
et.1.6   100 BaseTX HD    100 BaseTX HD    RJ45        operational   yes
et.1.7   100 BaseTX HD    100 BaseTX HD    RJ45        operational   yes
et.1.8   100 BaseTX HD    100 BaseTX HD    RJ45        operational   yes
et.2.1   100 BaseTX HD    100 BaseTX HD    RJ45        operational   yes
et.2.2   100 BaseTX HD    100 BaseTX HD    RJ45        operational   yes
et.2.3   100 BaseTX HD    100 BaseTX HD    RJ45        operational   yes
et.2.4   100 BaseTX HD    100 BaseTX HD    RJ45        operational   yes
et.2.5   100 BaseTX HD    100 BaseTX HD    RJ45        operational   yes
et.2.6   100 BaseTX HD    100 BaseTX HD    RJ45        operational   yes
et.2.7   100 BaseTX HD    100 BaseTX HD    RJ45        operational   yes
et.2.8   100 BaseTX HD    100 BaseTX HD    RJ45        operational   yes
IPM-2000# 

END

$responsesSSR->{'ports'} = <<'END';
port [?25l
IPM-2000# port  
[14C[?25h[?25l
IPM-2000# port   
[15C[?25hshow [?25l
IPM-2000# port show  
[19C[?25h[?25l
IPM-2000# port show   
[20C[?25hport-status [?25l
IPM-2000# port show port-status  
[31C[?25h[?25l
IPM-2000# port show port-status   
[32C[?25hall-ports

IFG: is displayed in nanoseconds
Flags: M - Mirroring enabled  B - MLP Bundle  S - SmartTRUNK port P - Configured as 802.1p

                                                 Negot- IFG   Link  Admin 
Port     Port Type             Duplex Speed      iation Value State State Flags
----     ---------             ------ -----      ------ ----- ----- ----- -----
et.1.1   10/100-Mbit Ethernet   Full  100 Mbits  Auto   960.0 Up    Up     
et.1.2   10/100-Mbit Ethernet   n/a   n/a        Auto   n/a   Down  Up     
et.1.3   10/100-Mbit Ethernet   n/a   n/a        Auto   n/a   Down  Up     
et.1.4   10/100-Mbit Ethernet   n/a   n/a        Auto   n/a   Down  Up     
et.1.5   10/100-Mbit Ethernet   n/a   n/a        Auto   n/a   Down  Up     
et.1.6   10/100-Mbit Ethernet   n/a   n/a        Auto   n/a   Down  Up     
et.1.7   10/100-Mbit Ethernet   n/a   n/a        Auto   n/a   Down  Up     
et.1.8   10/100-Mbit Ethernet   n/a   n/a        Auto   n/a   Down  Up     
et.2.1   10/100-Mbit Ethernet   n/a   n/a        Auto   n/a   Down  Up     
et.2.2   10/100-Mbit Ethernet   n/a   n/a        Auto   n/a   Down  Up     
et.2.3   10/100-Mbit Ethernet   n/a   n/a        Auto   n/a   Down  Up     
et.2.4   10/100-Mbit Ethernet   n/a   n/a        Auto   n/a   Down  Up     
et.2.5   10/100-Mbit Ethernet   n/a   n/a        Auto   n/a   Down  Up     
et.2.6   10/100-Mbit Ethernet   n/a   n/a        Auto   n/a   Down  Up     
et.2.7   10/100-Mbit Ethernet   n/a   n/a        Auto   n/a   Down  Up     
et.2.8   10/100-Mbit Ethernet   n/a   n/a        Auto   n/a   Down  Up     
IPM-2000# 

END

$responsesSSR->{'snmp_community'} = <<'END';
snmp [?25l
IPM-2000# snmp  
[14C[?25h[?25l
IPM-2000# snmp   
[15C[?25hshow [?25l
IPM-2000# snmp show  
[19C[?25h[?25l
IPM-2000# snmp show   
[20C[?25hcommunity

Community Table:
Index   Community String               Privilege (SNMPv1)    Privilege (SNMPv2c)
   1.   Brandon                        READ-NOTIFY           NONE               
   2.   Shopp                          READ-WRITE-NOTIFY     NONE               
   3.   public                         READ-NOTIFY           NONE               
   4.   testenv                        READ-WRITE-NOTIFY     NONE               
IPM-2000# 

END

$responsesSSR->{'stp'} = <<'END';
stp [?25l
IPM-2000# stp  
[13C[?25h[?25l
IPM-2000# stp   
[14C[?25hshow [?25l
IPM-2000# stp show  
[18C[?25h[?25l
IPM-2000# stp show   
[19C[?25hbridging-info
Status for Spanning Tree Instance 1
   Bridge ID        : 8000:0004bd2a6580
   Root bridge      : 8000:0004bd2a6580
   To Root via port : n/a
   Ports in bridge  : 0
   Max age          : 20 secs
   Hello time       : 2 secs
   Forward delay    : 15 secs
   Topology changes : 0
   Last Topology Chg: 6 days 2 hours 57 min 39 secs ago
   Protocol Version : STP compatible
IPM-2000# 

END

$responsesSSR->{'route'} = <<'END';
ip [?25l
IPM-2000# ip  
[12C[?25h[?25l
IPM-2000# ip   
[13C[?25hshow [?25l
IPM-2000# ip show  
[17C[?25h[?25l
IPM-2000# ip show   
[18C[?25hroutes

Destination          Gateway              Owner     Netif        
-----------          -------              -----     -----        
default              10.100.2.1           Static    manage 
10.100.2.0/24        directly connected   -         manage 
127.0.0.1            127.0.0.1            -         lo0 
IPM-2000# 

END

