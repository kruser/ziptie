package DataSecurityApplianceFWSM;

use strict;
use warnings;
use Exporter 'import';
our @EXPORT_OK = qw($responsesFWSM);

our $responsesFWSM = {};

$responsesFWSM->{version} = <<'END';
FWSM Firewall Version 3.1(1) <context>
Device Manager Version 5.0(1)F

Compiled on Mon 13-Feb-06 15:36 by dalecki

FWSM up 63 days 22 hours

Hardware:   WS-SVC-FWM-1
The Running Activation Key is not valid, using default settings:

Licensed features for this user context:
Failover                    : Active/Active
VPN-DES                     : Enabled
VPN-3DES-AES                : Enabled
GTP/GPRS                    : Disabled

Configuration last modified by testlab at 20:35:06.510 S Mon Jul 2 2007
FWSM/ceige#
END

$responsesFWSM->{running_config} = <<'END';
: Saved
:
FWSM Version 3.1(1) <context>
!
hostname ceige
enable password oE3TM4HZQ8/zNBWu encrypted
names
!
interface Vlan300
 nameif inside
 security-level 100
 ip address 10.100.25.155 255.255.255.0
!
interface Vlan50
 nameif outside
 security-level 0
 ip address 192.168.101.1 255.255.255.0
!
passwd oE3TM4HZQ8/zNBWu encrypted
object-group service hello tcp
 port-object eq talk
object-group network hobbit1
 network-object 222.222.222.222 255.255.255.255
object-group network network
 network-object 168.11.0.0 255.255.0.0
access-list blarg extended permit icmp object-group hobbit1 any
access-list 110 extended permit tcp any object-group network
pager lines 24
logging enable
mtu inside 1500
mtu outside 1500
icmp permit any inside
no asdm history enable
arp timeout 14400
route inside 0.0.0.0 0.0.0.0 10.100.25.1 1
timeout xlate 3:00:00
timeout conn 1:00:00 half-closed 0:10:00 udp 0:02:00 icmp 0:00:02
timeout sunrpc 0:10:00 h323 0:05:00 h225 1:00:00 mgcp 0:05:00
timeout mgcp-pat 0:05:00 sip 0:30:00 sip_media 0:02:00
timeout uauth 0:05:00 absolute
aaa-server tacacs protocol tacacs+
aaa-server tacacs host 10.100.32.137
 key cisco
username testlab password nflZO8PWDaBqd.Qx encrypted
aaa authentication telnet console tacacs LOCAL
aaa authentication ssh console tacacs LOCAL
aaa authentication enable console tacacs LOCAL
snmp-server location DallasTexas
snmp-server contact BrentMills
snmp-server community blahblah
snmp-server enable traps snmp authentication linkup linkdown coldstart
tunnel-group blarg type ipsec-ra
telnet 0.0.0.0 0.0.0.0 inside
telnet timeout 10
ssh 0.0.0.0 0.0.0.0 inside
ssh timeout 10
!
class-map gold
class-map hiphop
 match access-list 110
class-map inspection_default
 match default-inspection-traffic
class-map testing
 description I am rad
 match port udp eq 522
!
!
policy-map global_policy
 class inspection_default
  inspect dns maximum-length 512
  inspect ftp
  inspect h323 h225
  inspect h323 ras
  inspect rsh
  inspect smtp
  inspect sqlnet
  inspect skinny
  inspect sunrpc
  inspect xdmcp
  inspect sip
  inspect netbios
  inspect tftp
policy-map hiphop2
 class hiphop
  inspect snmp
policy-map testing
 class testing
  set connection conn-max 4000
!
service-policy global_policy global
service-policy hiphop2 interface outside
Cryptochecksum:263ef49ca3beb93bd9fee18a932109ca
: end
FWSM/ceige#
END

$responsesFWSM->{startup_config} = <<'END';
: Saved
: Written by testlab at 18:05:11.860 S Tue Jun 12 2007
!
FWSM Version 3.1(1) <context>
!
hostname ceige
enable password oE3TM4HZQ8/zNBWu encrypted
names
!
interface Vlan300
 nameif inside
 security-level 100
 ip address 10.100.25.155 255.255.255.0
!
interface Vlan50
 nameif outside
 security-level 0
 ip address 192.168.101.1 255.255.255.0
!
passwd oE3TM4HZQ8/zNBWu encrypted
object-group service hello tcp
 port-object eq talk
object-group network hobbit1
 network-object 222.222.222.222 255.255.255.255
object-group network network
 network-object 168.11.0.0 255.255.0.0
access-list blarg extended permit icmp object-group hobbit1 any
access-list 110 extended permit tcp any object-group network
pager lines 24
logging enable
mtu inside 1500
mtu outside 1500
icmp permit any inside
no asdm history enable
arp timeout 14400
route inside 0.0.0.0 0.0.0.0 10.100.25.1 1
timeout xlate 3:00:00
timeout conn 1:00:00 half-closed 0:10:00 udp 0:02:00 icmp 0:00:02
timeout sunrpc 0:10:00 h323 0:05:00 h225 1:00:00 mgcp 0:05:00
timeout mgcp-pat 0:05:00 sip 0:30:00 sip_media 0:02:00
timeout uauth 0:05:00 absolute
aaa-server tacacs protocol tacacs+
aaa-server tacacs host 10.100.32.137
 key cisco
username testlab password nflZO8PWDaBqd.Qx encrypted
aaa authentication telnet console tacacs LOCAL
aaa authentication ssh console tacacs LOCAL
aaa authentication enable console tacacs LOCAL
snmp-server location DallasTexas
snmp-server contact BrentMills
snmp-server community blahblah
snmp-server enable traps snmp authentication linkup linkdown coldstart
tunnel-group blarg type ipsec-ra
telnet 0.0.0.0 0.0.0.0 inside
telnet timeout 10
ssh 0.0.0.0 0.0.0.0 inside
ssh timeout 10
!
class-map hiphop
 match access-list 110
class-map inspection_default
 match default-inspection-traffic
class-map testing
 description I am rad
 match port udp eq 522
!
!
policy-map global_policy
 class inspection_default
  inspect dns maximum-length 512
  inspect ftp
  inspect h323 h225
  inspect h323 ras
  inspect rsh
  inspect smtp
  inspect sqlnet
  inspect skinny
  inspect sunrpc
  inspect xdmcp
  inspect sip
  inspect netbios
  inspect tftp
policy-map hiphop2
 class hiphop
  inspect snmp
policy-map testing
 class testing
  set connection conn-max 4000
!
service-policy global_policy global
service-policy hiphop2 interface outside
Cryptochecksum:263ef49ca3beb93bd9fee18a932109ca
: end
FWSM/ceige#
END

$responsesFWSM->{access_lists} = <<'END';
show access-list
access-list mode auto-commit
access-list cached ACL log flows: total 0, denied 0 (deny-flow-max 4096)
            alert-interval 300
access-list blarg; 1 elements
access-list blarg line 1 extended permit icmp object-group hobbit1 any
access-list blarg line 1 extended permit icmp host 222.222.222.222 any (hitcnt=0)
access-list 110; 1 elements
access-list 110 line 1 extended permit tcp any object-group network
access-list 110 line 1 extended permit tcp any 168.11.0.0 255.255.0.0 (hitcnt=0)
FWSM/ceige#
END

$responsesFWSM->{shun} = <<'END';
show shun
END

$responsesFWSM->{conduit} = <<'END';
show conduit
                    ^
ERROR: % Invalid input detected at '^' marker.
FWSM/ceige#

END

$responsesFWSM->{interfaces} = <<'END';
show interface
Interface Vlan300 "inside", is up, line protocol is up
        MAC address 0014.1c70.6400, MTU 1500
        IP address 10.100.25.155, subnet mask 255.255.255.0
  Traffic Statistics for "inside":
        446375 packets input, 32400741 bytes
        473387 packets output, 110623171 bytes
        2763185 packets dropped
Interface Vlan50 "outside", is up, line protocol is up
        MAC address 0014.1c70.6400, MTU 1500
        IP address 192.168.101.1, subnet mask 255.255.255.0
  Traffic Statistics for "outside":
        0 packets input, 0 bytes
        2 packets output, 136 bytes
        2761356 packets dropped
FWSM/ceige#
END

