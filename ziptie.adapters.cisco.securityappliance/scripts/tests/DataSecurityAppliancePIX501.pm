package DataSecurityAppliancePIX501;

use strict;
use warnings;
use Exporter 'import';
our @EXPORT_OK = qw($responses501);

our $responses501 = {};

$responses501->{version} = <<'END';
Cisco PIX Firewall Version 6.1(1)
Cisco PIX Device Manager Version 1.1(2)

Compiled on Tue 11-Sep-01 07:45 by morlee

pix-501 up 40 days 23 hours

Hardware:   PIX-501, 16 MB RAM, CPU Am5x86 133 MHz
Flash E28F640J3 @ 0x3000000, 8MB
BIOS Flash E28F640J3 @ 0xfffd8000, 128KB

0: ethernet0: address is 0009.e89c.fd5c, irq 9
1: ethernet1: address is 0009.e89c.fd5d, irq 10

Licensed Features:
Failover:	Disabled
VPN-DES: 	Enabled
VPN-3DES: 	Enabled
Maximum Interfaces:	2
Cut-through Proxy: 	Enabled
Guards: 	Enabled
Websense: 	Enabled
Inside Hosts: 	10
Throughput: 	Limited
ISAKMP peers: 	5

Serial Number: 806245458 (0x300e5452)
Activation Key: 0x3d209958 0xb2bd8b92 0x1e557e17 0x2236f310 
pix-501#  

END

$responses501->{running_config} = <<'END';
Building configuration...
: Saved
:
PIX Version 6.1(1)
nameif ethernet0 outside security0
nameif ethernet1 inside security100
enable password oE3TM4HZQ8/zNBWu encrypted
passwd sJqLGlridh7YAcms encrypted
hostname pix-501
domain-name elyptic.com
fixup protocol ftp 21
fixup protocol http 80
fixup protocol h323 1720
fixup protocol rsh 514
fixup protocol rtsp 554
fixup protocol smtp 25
fixup protocol sqlnet 1521
fixup protocol sip 5060
fixup protocol skinny 2000
names
access-list 101 permit tcp any any 
access-list 101 permit udp any any eq 22 
access-list 151 permit tcp any host 201.22.1.17 eq ftp-data 
no pager
logging monitor debugging
logging trap notifications
logging history notifications
logging host inside 10.10.1.156
logging host inside 10.100.32.71
interface ethernet0 10baset shutdown
interface ethernet1 10full
icmp permit any inside
mtu outside 1500
mtu inside 1500
ip address outside 10.10.42.1 255.255.255.0
ip address inside 10.100.1.6 255.255.255.0
ip audit info action alarm
ip audit attack action alarm
pdm history enable
arp timeout 14400
access-group 101 in interface inside
conduit permit tcp host 66.77.89.175 eq www any 
conduit permit tcp host 66.77.89.173 eq www any 
conduit permit udp host 66.77.89.168 eq isakmp any 
conduit permit tcp host 66.77.89.172 eq www any 
conduit permit tcp host 66.77.89.147 eq www any 
conduit permit tcp host 167.167.181.12 eq ftp 172.18.214.0 255.255.254.0 
conduit permit tcp host 167.167.181.12 eq ftp-data 172.18.214.0 255.255.254.0 
conduit permit tcp host 66.77.89.149 eq 10002 any 
conduit permit tcp host 66.77.89.150 eq 10002 any 
conduit permit tcp host 66.77.89.151 eq 10002 any 
conduit permit tcp 192.168.64.0 255.255.255.0 eq www 172.18.214.0 255.255.254.0 
conduit permit tcp host 66.77.124.50 eq www any 
conduit permit tcp 66.77.124.0 255.255.255.0 eq www host 192.168.5.8 
conduit permit tcp 66.77.124.0 255.255.255.0 eq ftp host 192.168.5.8 
conduit permit tcp 66.77.124.0 255.255.255.0 eq ftp-data host 192.168.5.8 
conduit permit tcp 66.77.124.0 255.255.255.0 eq 554 host 192.168.5.8 
conduit permit tcp 66.77.124.0 255.255.255.0 eq 1755 host 192.168.5.8 
conduit permit tcp 66.77.124.0 255.255.255.0 eq www host 192.168.5.9 
conduit permit tcp 66.77.124.0 255.255.255.0 eq ftp host 192.168.5.9 
conduit permit tcp 66.77.124.0 255.255.255.0 eq ftp-data host 192.168.5.9 
conduit permit tcp 66.77.124.0 255.255.255.0 eq 554 host 192.168.5.9 
conduit permit tcp 66.77.124.0 255.255.255.0 eq 1755 host 192.168.5.9 
conduit permit tcp host 66.77.124.99 eq www any 
conduit permit tcp host 172.23.2.242 range 3100 3399 172.18.214.0 255.255.254.0 
conduit permit tcp 66.77.89.0 255.255.255.0 eq www host 192.168.5.8 
conduit permit tcp 66.77.89.0 255.255.255.0 eq ftp host 192.168.5.8 
conduit permit tcp 66.77.89.0 255.255.255.0 eq ftp-data host 192.168.5.8 
conduit permit tcp 66.77.89.0 255.255.255.0 eq 554 host 192.168.5.8 
conduit permit tcp 66.77.89.0 255.255.255.0 eq 1755 host 192.168.5.8 
conduit permit tcp 66.77.89.0 255.255.255.0 eq www host 192.168.5.9 
conduit permit tcp 66.77.89.0 255.255.255.0 eq ftp host 192.168.5.9 
conduit permit tcp 66.77.89.0 255.255.255.0 eq ftp-data host 192.168.5.9 
conduit permit tcp 66.77.89.0 255.255.255.0 eq 554 host 192.168.5.9 
conduit permit tcp 66.77.89.0 255.255.255.0 eq 1755 host 192.168.5.9 
conduit permit tcp host 66.77.88.10 eq www any 
conduit permit tcp host 66.77.88.11 eq www any 
conduit permit tcp host 66.77.88.12 eq www any 
conduit permit tcp host 66.77.88.13 eq www any 
conduit permit tcp host 66.77.88.14 eq www any 
conduit permit tcp host 66.77.88.15 eq www any 
conduit permit tcp host 66.77.88.16 eq www any 
conduit permit tcp host 66.77.124.91 eq www any 
conduit permit tcp host 66.77.88.99 eq www any 
conduit permit tcp host 66.77.88.110 eq www any 
conduit permit icmp 66.77.124.0 255.255.255.0 host 63.150.159.50 
conduit permit icmp 66.77.124.0 255.255.255.0 host 63.150.159.51 
conduit permit udp 66.77.124.0 255.255.255.0 range snmp snmptrap 208.45.147.96 255.255.255.240 
conduit permit tcp 66.77.124.0 255.255.255.0 208.45.147.96 255.255.255.240 
conduit permit icmp 66.77.124.0 255.255.255.0 208.45.147.96 255.255.255.240 
conduit permit tcp host 172.22.133.39 eq lpd 172.18.214.0 255.255.254.0 
conduit permit tcp host 172.22.133.39 eq 9100 172.18.214.0 255.255.254.0 
conduit permit udp host 172.22.133.39 eq snmp 172.18.214.0 255.255.254.0 
conduit permit tcp host 3.152.24.50 eq telnet 172.18.214.0 255.255.254.0 
conduit permit tcp host 66.77.89.143 eq 8000 any 
conduit permit tcp host 3.156.135.27 eq sqlnet host 192.251.68.46 
conduit permit tcp host 3.156.135.27 eq ftp 172.18.214.0 255.255.254.0 
conduit permit tcp host 3.156.135.27 eq sqlnet host 192.251.68.49 
conduit permit tcp host 3.156.135.28 eq sqlnet host 192.251.68.47 
conduit permit tcp host 3.156.135.28 eq ftp 172.18.214.0 255.255.254.0 
conduit permit udp host 3.156.135.29 eq netbios-dgm host 192.251.68.46 
conduit permit udp host 3.156.135.29 eq netbios-dgm host 192.251.68.48 
conduit permit udp host 3.156.135.29 eq netbios-dgm host 192.251.68.47 
conduit permit udp host 3.156.135.29 eq netbios-dgm host 192.251.68.49 
conduit permit udp host 3.156.135.30 eq netbios-dgm host 192.251.68.46 
route inside 0.0.0.0 0.0.0.0 10.100.1.1 1
route inside 192.168.10.0 255.255.255.0 10.10.15.1 1
timeout xlate 3:00:00
timeout conn 1:00:00 half-closed 0:10:00 udp 0:02:00 rpc 0:10:00 h323 0:05:00 sip 0:30:00 sip_media 0:02:00
timeout uauth 0:05:00 absolute
aaa-server TACACS+ protocol tacacs+ 
aaa-server TACACS+ (inside) host 10.100.32.9 cisco timeout 10
aaa-server RADIUS protocol radius 
aaa authentication ssh console TACACS+
aaa authentication telnet console TACACS+
http server enable
http 10.0.0.0 255.0.0.0 inside
snmp-server location austin
snmp-server contact xxxxxxxxxx
snmp-server community public
snmp-server enable traps
floodguard enable
no sysopt route dnat
isakmp policy 10 authentication pre-share
isakmp policy 10 encryption des
isakmp policy 10 hash sha
isakmp policy 10 group 2
isakmp policy 10 lifetime 86400
telnet 10.0.0.0 255.0.0.0 inside
telnet 192.168.0.0 255.255.0.0 inside
telnet timeout 5
ssh 10.0.0.0 255.0.0.0 inside
ssh 192.168.0.0 255.255.0.0 inside
ssh timeout 5
terminal width 81
Cryptochecksum:2ab0e943d112e3066d830e29a140d8a9
: end
[OK]

END

$responses501->{startup_config} = <<'END';
: Saved
:
PIX Version 6.1(1)
nameif ethernet0 outside security0
nameif ethernet1 inside security100
enable password oE3TM4HZQ8/zNBWu encrypted
passwd sJqLGlridh7YAcms encrypted
hostname pix-501
domain-name elyptic.com
fixup protocol ftp 21
fixup protocol http 80
fixup protocol h323 1720
fixup protocol rsh 514
fixup protocol rtsp 554
fixup protocol smtp 25
fixup protocol sqlnet 1521
fixup protocol sip 5060
fixup protocol skinny 2000
names
access-list 101 permit tcp any any 
access-list 101 permit udp any any eq 22 
access-list 151 permit tcp any host 201.22.1.17 eq ftp-data 
no pager
logging monitor debugging
logging trap notifications
logging history notifications
logging host inside 10.10.1.156
logging host inside 10.100.32.71
interface ethernet0 10baset shutdown
interface ethernet1 10full
icmp permit any inside
mtu outside 1500
mtu inside 1500
ip address outside 10.10.42.1 255.255.255.0
ip address inside 10.100.1.6 255.255.255.0
ip audit info action alarm
ip audit attack action alarm
pdm history enable
arp timeout 14400
access-group 101 in interface inside
conduit permit tcp host 66.77.89.175 eq www any 
conduit permit tcp host 66.77.89.173 eq www any 
conduit permit udp host 66.77.89.168 eq isakmp any 
conduit permit tcp host 66.77.89.172 eq www any 
conduit permit tcp host 66.77.89.147 eq www any 
conduit permit tcp host 167.167.181.12 eq ftp 172.18.214.0 255.255.254.0 
conduit permit tcp host 167.167.181.12 eq ftp-data 172.18.214.0 255.255.254.0 
conduit permit tcp host 66.77.89.149 eq 10002 any 
conduit permit tcp host 66.77.89.150 eq 10002 any 
conduit permit tcp host 66.77.89.151 eq 10002 any 
conduit permit tcp 192.168.64.0 255.255.255.0 eq www 172.18.214.0 255.255.254.0 
conduit permit tcp host 66.77.124.50 eq www any 
conduit permit tcp 66.77.124.0 255.255.255.0 eq www host 192.168.5.8 
conduit permit tcp 66.77.124.0 255.255.255.0 eq ftp host 192.168.5.8 
conduit permit tcp 66.77.124.0 255.255.255.0 eq ftp-data host 192.168.5.8 
conduit permit tcp 66.77.124.0 255.255.255.0 eq 554 host 192.168.5.8 
conduit permit tcp 66.77.124.0 255.255.255.0 eq 1755 host 192.168.5.8 
conduit permit tcp 66.77.124.0 255.255.255.0 eq www host 192.168.5.9 
conduit permit tcp 66.77.124.0 255.255.255.0 eq ftp host 192.168.5.9 
conduit permit tcp 66.77.124.0 255.255.255.0 eq ftp-data host 192.168.5.9 
conduit permit tcp 66.77.124.0 255.255.255.0 eq 554 host 192.168.5.9 
conduit permit tcp 66.77.124.0 255.255.255.0 eq 1755 host 192.168.5.9 
conduit permit tcp host 66.77.124.99 eq www any 
conduit permit tcp host 172.23.2.242 range 3100 3399 172.18.214.0 255.255.254.0 
conduit permit tcp 66.77.89.0 255.255.255.0 eq www host 192.168.5.8 
conduit permit tcp 66.77.89.0 255.255.255.0 eq ftp host 192.168.5.8 
conduit permit tcp 66.77.89.0 255.255.255.0 eq ftp-data host 192.168.5.8 
conduit permit tcp 66.77.89.0 255.255.255.0 eq 554 host 192.168.5.8 
conduit permit tcp 66.77.89.0 255.255.255.0 eq 1755 host 192.168.5.8 
conduit permit tcp 66.77.89.0 255.255.255.0 eq www host 192.168.5.9 
conduit permit tcp 66.77.89.0 255.255.255.0 eq ftp host 192.168.5.9 
conduit permit tcp 66.77.89.0 255.255.255.0 eq ftp-data host 192.168.5.9 
conduit permit tcp 66.77.89.0 255.255.255.0 eq 554 host 192.168.5.9 
conduit permit tcp 66.77.89.0 255.255.255.0 eq 1755 host 192.168.5.9 
conduit permit tcp host 66.77.88.10 eq www any 
conduit permit tcp host 66.77.88.11 eq www any 
conduit permit tcp host 66.77.88.12 eq www any 
conduit permit tcp host 66.77.88.13 eq www any 
conduit permit tcp host 66.77.88.14 eq www any 
conduit permit tcp host 66.77.88.15 eq www any 
conduit permit tcp host 66.77.88.16 eq www any 
conduit permit tcp host 66.77.124.91 eq www any 
conduit permit tcp host 66.77.88.99 eq www any 
conduit permit tcp host 66.77.88.110 eq www any 
conduit permit icmp 66.77.124.0 255.255.255.0 host 63.150.159.50 
conduit permit icmp 66.77.124.0 255.255.255.0 host 63.150.159.51 
conduit permit udp 66.77.124.0 255.255.255.0 range snmp snmptrap 208.45.147.96 255.255.255.240 
conduit permit tcp 66.77.124.0 255.255.255.0 208.45.147.96 255.255.255.240 
conduit permit icmp 66.77.124.0 255.255.255.0 208.45.147.96 255.255.255.240 
conduit permit tcp host 172.22.133.39 eq lpd 172.18.214.0 255.255.254.0 
conduit permit tcp host 172.22.133.39 eq 9100 172.18.214.0 255.255.254.0 
conduit permit udp host 172.22.133.39 eq snmp 172.18.214.0 255.255.254.0 
conduit permit tcp host 3.152.24.50 eq telnet 172.18.214.0 255.255.254.0 
conduit permit tcp host 66.77.89.143 eq 8000 any 
conduit permit tcp host 3.156.135.27 eq sqlnet host 192.251.68.46 
conduit permit tcp host 3.156.135.27 eq ftp 172.18.214.0 255.255.254.0 
conduit permit tcp host 3.156.135.27 eq sqlnet host 192.251.68.49 
conduit permit tcp host 3.156.135.28 eq sqlnet host 192.251.68.47 
conduit permit tcp host 3.156.135.28 eq ftp 172.18.214.0 255.255.254.0 
conduit permit udp host 3.156.135.29 eq netbios-dgm host 192.251.68.46 
conduit permit udp host 3.156.135.29 eq netbios-dgm host 192.251.68.48 
conduit permit udp host 3.156.135.29 eq netbios-dgm host 192.251.68.47 
conduit permit udp host 3.156.135.29 eq netbios-dgm host 192.251.68.49 
conduit permit udp host 3.156.135.30 eq netbios-dgm host 192.251.68.46 
route inside 0.0.0.0 0.0.0.0 10.100.1.1 1
route inside 192.168.10.0 255.255.255.0 10.10.15.1 1
timeout xlate 3:00:00
timeout conn 1:00:00 half-closed 0:10:00 udp 0:02:00 rpc 0:10:00 h323 0:05:00 sip 0:30:00 sip_media 0:02:00
timeout uauth 0:05:00 absolute
aaa-server TACACS+ protocol tacacs+ 
aaa-server TACACS+ (inside) host 10.100.32.9 cisco timeout 10
aaa-server RADIUS protocol radius 
aaa authentication ssh console TACACS+
aaa authentication telnet console TACACS+
http server enable
http 10.0.0.0 255.0.0.0 inside
snmp-server location austin
snmp-server contact xxxxxxxxxx
snmp-server community public
snmp-server enable traps
floodguard enable
no sysopt route dnat
isakmp policy 10 authentication pre-share
isakmp policy 10 encryption des
isakmp policy 10 hash sha
isakmp policy 10 group 2
isakmp policy 10 lifetime 86400
telnet 10.0.0.0 255.0.0.0 inside
telnet 192.168.0.0 255.255.0.0 inside
telnet timeout 5
ssh 10.0.0.0 255.0.0.0 inside
ssh 192.168.0.0 255.255.0.0 inside
ssh timeout 5
terminal width 81
Cryptochecksum:2ab0e943d112e3066d830e29a140d8a9
pix-501#  

END

$responses501->{access_lists} = <<'END';
access-list 101 permit tcp any any (hitcnt=0) 
access-list 101 permit udp any any eq 22 (hitcnt=0) 
access-list 151 permit tcp any host 201.22.1.17 eq ftp-data (hitcnt=0) 
pix-501#  

END

$responses501->{shun} = <<'END';
Shun 99.99.99.100 99.99.99.104 161 161
Shun 99.99.99.101 99.99.99.104 53 53
Shun 99.99.99.99 0.0.0.0 0 0
pix-501#  

END

$responses501->{conduit} = <<'END';
conduit permit tcp host 66.77.89.175 eq www any (hitcnt=0) 
conduit permit tcp host 66.77.89.173 eq www any (hitcnt=0) 
conduit permit udp host 66.77.89.168 eq isakmp any (hitcnt=0) 
conduit permit tcp host 66.77.89.172 eq www any (hitcnt=0) 
conduit permit tcp host 66.77.89.147 eq www any (hitcnt=0) 
conduit permit tcp host 167.167.181.12 eq ftp 172.18.214.0 255.255.254.0 (hitcnt=0) 
conduit permit tcp host 167.167.181.12 eq ftp-data 172.18.214.0 255.255.254.0 (hitcnt=0) 
conduit permit tcp host 66.77.89.149 eq 10002 any (hitcnt=0) 
conduit permit tcp host 66.77.89.150 eq 10002 any (hitcnt=0) 
conduit permit tcp host 66.77.89.151 eq 10002 any (hitcnt=0) 
conduit permit tcp 192.168.64.0 255.255.255.0 eq www 172.18.214.0 255.255.254.0 (hitcnt=0) 
conduit permit tcp host 66.77.124.50 eq www any (hitcnt=0) 
conduit permit tcp 66.77.124.0 255.255.255.0 eq www host 192.168.5.8 (hitcnt=0) 
conduit permit tcp 66.77.124.0 255.255.255.0 eq ftp host 192.168.5.8 (hitcnt=0) 
conduit permit tcp 66.77.124.0 255.255.255.0 eq ftp-data host 192.168.5.8 (hitcnt=0) 
conduit permit tcp 66.77.124.0 255.255.255.0 eq 554 host 192.168.5.8 (hitcnt=0) 
conduit permit tcp 66.77.124.0 255.255.255.0 eq 1755 host 192.168.5.8 (hitcnt=0) 
conduit permit tcp 66.77.124.0 255.255.255.0 eq www host 192.168.5.9 (hitcnt=0) 
conduit permit tcp 66.77.124.0 255.255.255.0 eq ftp host 192.168.5.9 (hitcnt=0) 
conduit permit tcp 66.77.124.0 255.255.255.0 eq ftp-data host 192.168.5.9 (hitcnt=0) 
conduit permit tcp 66.77.124.0 255.255.255.0 eq 554 host 192.168.5.9 (hitcnt=0) 
conduit permit tcp 66.77.124.0 255.255.255.0 eq 1755 host 192.168.5.9 (hitcnt=0) 
conduit permit tcp host 66.77.124.99 eq www any (hitcnt=0) 
conduit permit tcp host 172.23.2.242 range 3100 3399 172.18.214.0 255.255.254.0 (hitcnt=0) 
conduit permit tcp 66.77.89.0 255.255.255.0 eq www host 192.168.5.8 (hitcnt=0) 
conduit permit tcp 66.77.89.0 255.255.255.0 eq ftp host 192.168.5.8 (hitcnt=0) 
conduit permit tcp 66.77.89.0 255.255.255.0 eq ftp-data host 192.168.5.8 (hitcnt=0) 
conduit permit tcp 66.77.89.0 255.255.255.0 eq 554 host 192.168.5.8 (hitcnt=0) 
conduit permit tcp 66.77.89.0 255.255.255.0 eq 1755 host 192.168.5.8 (hitcnt=0) 
conduit permit tcp 66.77.89.0 255.255.255.0 eq www host 192.168.5.9 (hitcnt=0) 
conduit permit tcp 66.77.89.0 255.255.255.0 eq ftp host 192.168.5.9 (hitcnt=0) 
conduit permit tcp 66.77.89.0 255.255.255.0 eq ftp-data host 192.168.5.9 (hitcnt=0) 
conduit permit tcp 66.77.89.0 255.255.255.0 eq 554 host 192.168.5.9 (hitcnt=0) 
conduit permit tcp 66.77.89.0 255.255.255.0 eq 1755 host 192.168.5.9 (hitcnt=0) 
conduit permit tcp host 66.77.88.10 eq www any (hitcnt=0) 
conduit permit tcp host 66.77.88.11 eq www any (hitcnt=0) 
conduit permit tcp host 66.77.88.12 eq www any (hitcnt=0) 
conduit permit tcp host 66.77.88.13 eq www any (hitcnt=0) 
conduit permit tcp host 66.77.88.14 eq www any (hitcnt=0) 
conduit permit tcp host 66.77.88.15 eq www any (hitcnt=0) 
conduit permit tcp host 66.77.88.16 eq www any (hitcnt=0) 
conduit permit tcp host 66.77.124.91 eq www any (hitcnt=0) 
conduit permit tcp host 66.77.88.99 eq www any (hitcnt=0) 
conduit permit tcp host 66.77.88.110 eq www any (hitcnt=0) 
conduit permit icmp 66.77.124.0 255.255.255.0 host 63.150.159.50 (hitcnt=0) 
conduit permit icmp 66.77.124.0 255.255.255.0 host 63.150.159.51 (hitcnt=0) 
conduit permit udp 66.77.124.0 255.255.255.0 range snmp snmptrap 208.45.147.96 255.255.255.240 (hitcnt=0) 
conduit permit tcp 66.77.124.0 255.255.255.0 208.45.147.96 255.255.255.240 (hitcnt=0) 
conduit permit icmp 66.77.124.0 255.255.255.0 208.45.147.96 255.255.255.240 (hitcnt=0) 
conduit permit tcp host 172.22.133.39 eq lpd 172.18.214.0 255.255.254.0 (hitcnt=0) 
conduit permit tcp host 172.22.133.39 eq 9100 172.18.214.0 255.255.254.0 (hitcnt=0) 
conduit permit udp host 172.22.133.39 eq snmp 172.18.214.0 255.255.254.0 (hitcnt=0) 
conduit permit tcp host 3.152.24.50 eq telnet 172.18.214.0 255.255.254.0 (hitcnt=0) 
conduit permit tcp host 66.77.89.143 eq 8000 any (hitcnt=0) 
conduit permit tcp host 3.156.135.27 eq sqlnet host 192.251.68.46 (hitcnt=0) 
conduit permit tcp host 3.156.135.27 eq ftp 172.18.214.0 255.255.254.0 (hitcnt=0) 
conduit permit tcp host 3.156.135.27 eq sqlnet host 192.251.68.49 (hitcnt=0) 
conduit permit tcp host 3.156.135.28 eq sqlnet host 192.251.68.47 (hitcnt=0) 
conduit permit tcp host 3.156.135.28 eq ftp 172.18.214.0 255.255.254.0 (hitcnt=0) 
conduit permit udp host 3.156.135.29 eq netbios-dgm host 192.251.68.46 (hitcnt=0) 
conduit permit udp host 3.156.135.29 eq netbios-dgm host 192.251.68.48 (hitcnt=0) 
conduit permit udp host 3.156.135.29 eq netbios-dgm host 192.251.68.47 (hitcnt=0) 
conduit permit udp host 3.156.135.29 eq netbios-dgm host 192.251.68.49 (hitcnt=0) 
conduit permit udp host 3.156.135.30 eq netbios-dgm host 192.251.68.46 (hitcnt=0) 
pix-501#  

END

$responses501->{interfaces} = <<'END';
interface ethernet0 "outside" is administratively down, line protocol is down
  Hardware is i82559 ethernet, address is 0009.e89c.fd5c
  IP address 10.10.42.1, subnet mask 255.255.255.0
  MTU 1500 bytes, BW 10000 Kbit half duplex
	0 packets input, 0 bytes, 0 no buffer
	Received 0 broadcasts, 0 runts, 0 giants
	0 input errors, 0 CRC, 0 frame, 0 overrun, 0 ignored, 0 abort
	0 packets output, 0 bytes, 0 underruns
	0 output errors, 0 collisions, 0 interface resets
	0 babbles, 0 late collisions, 0 deferred
	0 lost carrier, 0 no carrier
	input queue (curr/max blocks): hardware (128/128) software (0/0)
	output queue (curr/max blocks): hardware (0/0) software (0/0)
interface ethernet1 "inside" is up, line protocol is up
  Hardware is i82559 ethernet, address is 0009.e89c.fd5d
  IP address 10.100.1.6, subnet mask 255.255.255.0
  MTU 1500 bytes, BW 10000 Kbit full duplex
	550778 packets input, 61401320 bytes, 0 no buffer
	Received 392796 broadcasts, 0 runts, 0 giants
	0 input errors, 0 CRC, 0 frame, 0 overrun, 0 ignored, 0 abort
	195669 packets output, 49115047 bytes, 0 underruns
	0 output errors, 0 collisions, 0 interface resets
	0 babbles, 0 late collisions, 0 deferred
	0 lost carrier, 0 no carrier
	input queue (curr/max blocks): hardware (128/128) software (0/11)
	output queue (curr/max blocks): hardware (1/11) software (0/3)
pix-501#  

END
