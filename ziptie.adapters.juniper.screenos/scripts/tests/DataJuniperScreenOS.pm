package DataJuniperScreenOS;

use strict;
use warnings;
use Exporter 'import';
our @EXPORT_OK = qw($responsesJuniperScreenOS);

our $responsesJuniperScreenOS = {};

$responsesJuniperScreenOS->{'system'} = <<'END';
get system
Product Name: NS5XP
Serial Number: 0018092002000730, Control Number: 00000000
Hardware Version: 3010(0)-(00), FPGA checksum: 00000000, VLAN1 IP (0.0.0.0)
Software Version: 5.0.0r11.0, Type: Firewall+VPN
Base Mac: 0010.db28.1150
File Name: ns5xp.5.0.0r11.0, Checksum: de0034d5


Date 10/05/2007 12:37:56, Daylight Saving Time enabled
The Network Time Protocol is Disabled
Up 8881 hours 1 minutes 55 seconds Since 30 Sept 2006 11:36:01
Total Device Resets: 2, Last Device Reset at: 04/01/2005 15:02:45

System in NAT/route mode.

Use interface IP, Config Port: 80
User Name: testlab

Interface trust:
  number 2, if_info 176, if_index 0, mode nat
  link up, phy-link up/half-duplex
  vsys Root, zone Trust, vr trust-vr
  dhcp client disabled
  PPPoE disabled
  *ip 10.100.2.10/24   mac 0010.db28.1152
  *manage ip 10.100.2.10, mac 0010.db28.1152
  route-deny disable
Interface untrust:
  number 1, if_info 88, if_index 0, mode route
  link down, phy-link down
  vsys Root, zone Untrust, vr trust-vr
  dhcp client disabled
  PPPoE disabled
  *ip 0.0.0.0/0   mac 0010.db28.1151
  *manage ip 0.0.0.0, mac 0010.db28.1151
ns5xp-> 

END

$responsesJuniperScreenOS->{'config'} = <<'END';
get config
Total Config size 3640:
set clock timezone 0
set vrouter trust-vr sharable
unset vrouter "trust-vr" auto-route-export
set auth-server "Local" id 0
set auth-server "Local" server-name "Local"
set auth-server "vm-rme" id 1
set auth-server "vm-rme" server-name "10.100.32.137"
set auth-server "vm-rme" account-type auth 
set auth-server "vm-rme" radius secret "cisco"
set auth default auth server "Local"
set admin name "testlab"
set admin password "nP9TAKrcN2+CcdPO0sMERHMtNsAmdn"
set admin auth timeout 10
set admin auth server "vm-rme"
set admin privilege read-write
set admin format dos
set zone "Trust" vrouter "trust-vr"
set zone "Untrust" vrouter "trust-vr"
set zone "VLAN" vrouter "trust-vr"
set zone "Trust" tcp-rst 
set zone "Untrust" block 
unset zone "Untrust" tcp-rst 
set zone "MGT" block 
set zone "VLAN" block 
set zone "VLAN" tcp-rst 
set zone "Untrust" screen tear-drop
set zone "Untrust" screen syn-flood
set zone "Untrust" screen ping-death
set zone "Untrust" screen ip-filter-src
set zone "Untrust" screen land
set zone "V1-Untrust" screen tear-drop
set zone "V1-Untrust" screen syn-flood
set zone "V1-Untrust" screen ping-death
set zone "V1-Untrust" screen ip-filter-src
set zone "V1-Untrust" screen land
set interface "trust" zone "Trust"
set interface "untrust" zone "Untrust"
unset interface vlan1 ip
set interface trust ip 10.100.2.10/24
set interface trust nat
unset interface vlan1 bypass-others-ipsec
unset interface vlan1 bypass-non-ip
set interface trust ip manageable
set interface trust dhcp server service
set interface trust dhcp server auto
set interface trust dhcp server option gateway 192.168.1.1 
set interface trust dhcp server option netmask 255.255.255.0 
set interface trust dhcp server ip 192.168.1.33 to 192.168.1.126 
set flow tcp-mss
set console page 0
set hostname ns5xp
set user "testlab" uid 1
set user "testlab" type  auth
set user "testlab" hash-password "02ihMFpiS/ROXFYKkgMn+7TCTaEZwNgjssZiM="
set user "testlab" "enable"
set ike respond-bad-spi 1
set pki authority default scep mode "auto"
set pki x509 default cert-path partial
set policy id 0 from "Trust" to "Untrust"  "Any" "Any" "ANY" permit log count 
set policy id 1 name "acl-of-ryan" from "Trust" to "Untrust"  "Any" "Any" "FTP" deny log count 
set syslog config "10.100.32.43"
set syslog config "10.100.32.43" facilities local0 local0
set syslog src-interface trust
set syslog enable
set nsmgmt report proto-dist enable
set nsmgmt report statistics ethernet enable
set nsmgmt report statistics attack enable
set nsmgmt report statistics flow enable
set nsmgmt report statistics policy enable
set nsmgmt report alarm traffic enable
set nsmgmt report alarm attack enable
set nsmgmt report alarm other enable
set nsmgmt report alarm di enable
set nsmgmt report log config enable
set nsmgmt report log info enable
set nsmgmt report log self enable
set nsmgmt report log traffic enable
set nsmgmt init id 5FB7A8B467CEBD0443C36ED809757CB40B1052E900
set nsmgmt server primary 10.100.32.75 port 7800
set nsmgmt server primary 10.100.32.75 src-interface trust
set nsmgmt hb-interval 20
set nsmgmt hb-threshold 5
set nsmgmt enable
set ssh version v1
set ssh enable
set config lock timeout 5
set snmp community "public" Read-Write Trap-on  traffic version v1
set snmp host "public" 10.0.0.0 255.0.0.0 
set snmp location "Here"
set snmp contact "pitest22"
set snmp name "ns5xp"
set snmp port listen 161
set snmp port trap 162
set vrouter "untrust-vr"
exit
set vrouter "trust-vr"
unset add-default-route
set route  0.0.0.0/0 interface trust gateway 10.100.2.1
exit
ns5xp-> 

END

$responsesJuniperScreenOS->{'memory'} = <<'END';
get memory
Memory: allocated 11827504, left 9353328, frag 3107
ns5xp-> 

END

$responsesJuniperScreenOS->{'file_info'} = <<'END';
get file info
There are 26038272 bytes free (31262720 total) on disk "flash:"
ns5xp-> 

END

$responsesJuniperScreenOS->{'files'} = <<'END';
get file
    flash:/envar.rec                       80
    flash:/golerd.rec                       0
    flash:/dnstb.rec                        1
    flash:/crash.dmp                    16384
    flash:/dhcpservl.txt                   52
    flash:/license.key                    358
    flash:/ns_sys_config                 1457
nshsc-> 

END

$responsesJuniperScreenOS->{'addresses'} = <<'END';
get address
Total 10 addresses and 0 groups in address book.

addr zone name Trust
Trust Addresses:
Name                 Address         Netmask         Flag  Comments
Any                  0.0.0.0         0.0.0.0           02  All Addr
Dial-Up VPN          255.255.255.255 255.255.255.255   02  Dial-Up VPN Addr

addr zone name Untrust
Untrust Addresses:
Name                 Address         Netmask         Flag  Comments
Any                  0.0.0.0         0.0.0.0           02  All Addr
Dial-Up VPN          255.255.255.255 255.255.255.255   02  Dial-Up VPN Addr

addr zone name Global
Global Addresses:
Name                 Address         Netmask         Flag  Comments
Any                  0.0.0.0         0.0.0.0           02  All Addr

addr zone name V1-Trust
V1-Trust Addresses:
Name                 Address         Netmask         Flag  Comments
Any                  0.0.0.0         0.0.0.0           02  All Addr
Dial-Up VPN          255.255.255.255 255.255.255.255   02  Dial-Up VPN Addr

addr zone name V1-Untrust
V1-Untrust Addresses:
Name                 Address         Netmask         Flag  Comments
Any                  0.0.0.0         0.0.0.0           02  All Addr
Dial-Up VPN          255.255.255.255 255.255.255.255   02  Dial-Up VPN Addr

ns5xp-> 

END

$responsesJuniperScreenOS->{'policy'} = <<'END';
get policy
Total regular policies 2, Default deny.
    ID From     To       Src-address  Dst-address  Service  Action State   ASTLCB
     0 Trust    Untrust  Any          Any          ANY      Permit enabled ---XXX
     1 Trust    Untrust  Any          Any          FTP      Deny   enabled ---XXX
ns5xp-> 

END

$responsesJuniperScreenOS->{'acl_0'} = <<'END';
get policy id 0
name:"none" (id 0), zone Trust -> Untrust,action Permit, status "enabled"
src "Any", dst "Any", serv "ANY"
Policies on this vpn tunnel: 0
nat off, url filtering OFF
vpn unknown vpn, policy flag 0000, session backup: on
traffic shapping off, scheduler n/a, serv flag 00
log yes, log count 0, alert no, counter yes(1) byte rate(sec/min) 0/0
total octets 0, counter(session/packet/octet) 0/0/1
priority 7, diffserv marking Off
tadapter: state off, gbw/mbw 0/-1
No Authentication
No User, User Group or Group expression set
ns5xp-> 

END

$responsesJuniperScreenOS->{'acl_1'} = <<'END';
get policy id 1
name:"acl-of-ryan" (id 1), zone Trust -> Untrust,action Deny, status "enabled"
src "Any", dst "Any", serv "FTP"
Policies on this vpn tunnel: 0
nat off, url filtering OFF
vpn unknown vpn, policy flag 0000, session backup: on
traffic shapping off, scheduler n/a, serv flag 00
log yes, log count 0, alert no, counter yes(2) byte rate(sec/min) 0/0
total octets 0, counter(session/packet/octet) 0/0/2
priority 7, diffserv marking Off
tadapter: state off, gbw/mbw 0/-1
No Authentication
No User, User Group or Group expression set
ns5xp-> 

END

$responsesJuniperScreenOS->{'interfaces'} = <<'END';
get interface

A - Active, I - Inactive, U - Up, D - Down, R - Ready 

Interfaces in vsys Root: 
Name           IP Address         Zone        MAC            VLAN State VSD      
trust          10.100.2.10/24     Trust       0010.db28.1152    -   U   -  
untrust        0.0.0.0/0          Untrust     0010.db28.1151    -   D   -  
vlan1          0.0.0.0/0          VLAN        0010.db28.115f    1   D   -  
ns5xp-> 

END

$responsesJuniperScreenOS->{'if_trust'} = <<'END';
get interface trust
Interface trust:
  number 2, if_info 176, if_index 0, mode nat
  link up, phy-link up/half-duplex
  vsys Root, zone Trust, vr trust-vr
  dhcp client disabled
  PPPoE disabled
  *ip 10.100.2.10/24   mac 0010.db28.1152
  *manage ip 10.100.2.10, mac 0010.db28.1152
  route-deny disable
  ping enabled, telnet enabled, SSH enabled, SNMP enabled
  web enabled, ident-reset disabled, SSL enabled
  webauth disabled, webauth-ip 0.0.0.0
  RIP disabled
  bandwidth: physical 10000kbps, configured 0kbps, current 0kbps
             total configured gbw 0kbps, total allocated gbw 0kbps
  DHCP-Relay disabled
  DHCP-server enabled, status on.
ns5xp-> 

END

$responsesJuniperScreenOS->{'if_untrust'} = <<'END';
get interface untrust
Interface untrust:
  number 1, if_info 88, if_index 0, mode route
  link down, phy-link down
  vsys Root, zone Untrust, vr trust-vr
  dhcp client disabled
  PPPoE disabled
  *ip 0.0.0.0/0   mac 0010.db28.1151
  *manage ip 0.0.0.0, mac 0010.db28.1151
  ping disabled, telnet disabled, SSH disabled, SNMP disabled
  web disabled, ident-reset disabled, SSL disabled
  webauth disabled, webauth-ip 0.0.0.0
  RIP disabled
  bandwidth: physical 10000kbps, configured 0kbps, current 0kbps
             total configured gbw 0kbps, total allocated gbw 0kbps
  DHCP-Relay disabled
  DHCP-server disabled
ns5xp-> 

END

$responsesJuniperScreenOS->{'if_vlan1'} = <<'END';
get interface vlan1
Interface vlan1:
  number 15, if_info 1320, if_index 0, VLAN tag 1, mode route
  link down, phy-link down
  vsys Root, zone VLAN, vr trust-vr
  *ip 0.0.0.0/0   mac 0010.db28.115f
  *manage ip 0.0.0.0, mac 0010.db28.115f
  ping enabled, telnet enabled, SSH enabled, SNMP enabled
  web enabled, ident-reset disabled, SSL enabled
  webauth disabled, webauth-ip 0.0.0.0
  bandwidth: physical 10000kbps, configured 0kbps, current 0kbps
             total configured gbw 0kbps, total allocated gbw 0kbps
  DHCP-Relay disabled
  DHCP-server disabled
  unknown mac address resolve method: FLOOD
  vlan trunk: Off
  bypass others IPSEC: Off
  bypass non IP: multicast
  In backup mode, only traffic from V1-Trust can manage the box
ns5xp-> 

END

$responsesJuniperScreenOS->{'routes'} = <<'END';
get route
untrust-vr (0 entries)
--------------------------------------------------------------------------------
C - Connected, S - Static, A - Auto-Exported, I - Imported, R - RIP
trust-vr (2 entries)
--------------------------------------------------------------------------------
   ID          IP-Prefix      Interface         Gateway   P Pref    Mtr     Vsys
--------------------------------------------------------------------------------
*   2          0.0.0.0/0          trust      10.100.2.1   S   20      1     Root
*   1      10.100.2.0/24          trust         0.0.0.0   C    0      0     Root
ns5xp-> 

END

