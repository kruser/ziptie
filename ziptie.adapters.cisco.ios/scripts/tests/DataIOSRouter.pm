package DataIOSRouter;

use strict;
use warnings;
use Exporter 'import';
our @EXPORT_OK = qw($show_diag $show_fs $show_flash $bgp $ospf_ints $ospf $protocols $eigrp $running_config $startup_config $version $acls $interfaces);

our $running_config = <<'END_RUNNING_CONFIG';
Building configuration...

Current configuration : 20632 bytes
!
! Last configuration change at 22:25:33 CST Fri Mar 5 1993 by testlab
! NVRAM config last updated at 22:25:34 CST Fri Mar 5 1993 by testlab
!
version 12.2
no service pad
service tcp-keepalives-in
service tcp-keepalives-out
service timestamps debug datetime localtime
service timestamps log datetime localtime
service password-encryption
!
hostname cisco2610-LAB
!
boot system flash:c2600-i-mz.122-12e.bin
logging buffered 4096 debugging
aaa new-model
aaa authentication login default group tacacs+ local
aaa authentication enable default group tacacs+ enable
aaa authorization commands 15 default group tacacs+ local none 
enable secret 5 $1$xtvt$PJIP8d47e5b31vuNWRwH10
enable password 7 030C5E12
!
username eric password 7 06041A2D405D014811
username testlab privilege 15 password 7 000C1C0406521F
username kelly password 7 06534A7058
memory-size iomem 15
clock timezone CST -6
clock summer-time CST recurring
ip subnet-zero
ip cef
!
!
ip finger
no ip ftp passive
ip ftp username alterpoint
ip ftp password 7 050A0A1B725E5E59580B03
ip domain-name eclyptic.com
ip name-server 10.10.1.9
!
no ip bootp server
frame-relay switching
!
!
!
interface Loopback0
 description Eric is Great
 no ip address
!
interface Loopback1
 description KrissyGolic
 no ip address
 shutdown
!
interface Loopback4
 description blah blah blah
 ip address 99.2.1.1 255.255.255.255 secondary
 ip address 99.1.1.1 255.255.255.255
!
interface Loopback5
 description THIS IS A TEST OF THE EMERGENCY BROADCAST SYSTEM
 no ip address
 load-interval 30
!
interface Loopback9
 description THIS IS NOT A TEST, THIS IS AN ACTUAL EMERGENCY
 no ip address
 load-interval 30
!
interface Loopback22
 description this is a testube baby
 no ip address
!
interface Loopback33
 description this is a test of the emergency broadcast system
 no ip address
!
interface Loopback35
 description testing 123
 no ip address
!
interface Loopback58
 description test
 no ip address
!
interface Ethernet0/0
 description Martin is Testing
 bandwidth 5544
 ip address 10.100.4.8 255.255.255.0
 ip access-group B1-to out
 ip helper-address 2.2.2.2
 ip helper-address 5.2.2.2
 no ip redirects
 no ip proxy-arp
 ip accounting output-packets
 ip hello-interval eigrp 100 57
 ip hold-time eigrp 100 57
 no ip route-cache
 ip ospf authentication
 no ip mroute-cache
 delay 4433
 half-duplex
 priority-group 1
!
interface Serial0/0
 description Transit T1 roll to 2610FR2
 bandwidth 1544
 ip address 10.100.40.201 255.255.255.252
 ip access-group TransitInbound in
 ip access-group 113 out
 no ip redirects
 no ip unreachables
 ip accounting output-packets
 rate-limit input 2000000000 1000000 1000000 conform-action transmit exceed-action drop
 encapsulation frame-relay IETF
 no ip mroute-cache
 no fair-queue
 service-module t1 timeslots 1-24
 frame-relay intf-type dce
!
interface Serial0/0.1 point-to-point
 description DLCI 16 to 2610FR2
 bandwidth 256
 ip address 100.100.1.1 255.255.255.252
 no ip redirects
 ip accounting output-packets
 no ip mroute-cache
 frame-relay interface-dlci 16 IETF   
!
interface Serial0/0.11 multipoint
 description Frame-Relay Map
 bandwidth 128
 ip address 10.138.176.1 255.255.255.0
 no ip redirects
 ip accounting output-packets
 rate-limit input access-group 99 8000 8000 8000 conform-action transmit exceed-action drop
 no ip split-horizon
 ip ospf network point-to-multipoint
 no ip mroute-cache
 frame-relay map ip 10.138.176.2 310 broadcast
 frame-relay map ip 10.138.176.3 340 broadcast
 frame-relay map ip 10.138.176.6 390 broadcast
 frame-relay map ip 10.138.176.9 380 broadcast
!
interface Serial0/0.17 point-to-point
 description DLCI 17 to 2610FR2
 ip address 100.100.1.5 255.255.255.252
 no ip redirects
 ip accounting output-packets
 no ip mroute-cache
 frame-relay interface-dlci 17 IETF   
!
interface Serial0/0.18 point-to-point
 description DLCI 18 Uplink to ACMEco Main Office
 ip address 24.24.24.2 255.255.255.252 secondary
 ip address 10.200.0.1 255.255.255.252
 no ip redirects
 ip accounting output-packets
 no ip mroute-cache
 frame-relay class voip_qos_512k
 frame-relay interface-dlci 18   
!
interface Serial0/0.19 point-to-point
 description to location A
 no ip redirects
 no ip mroute-cache
 frame-relay interface-dlci 19 protocol ip 209.209.210.2
!
interface Serial0/0.20 point-to-point
 description to location B
 no ip redirects
 no ip mroute-cache
 frame-relay interface-dlci 20 ppp Virtual-Template1
!
interface Serial0/0.21 point-to-point
 no ip redirects
 no ip mroute-cache
 frame-relay interface-dlci 21 CISCO protocol ip 209.209.212.2
!
interface BRI0/0
 no ip address
 encapsulation hdlc
 shutdown
!
interface Virtual-Template1
 no ip address
 no ip redirects
!
interface Group-Async1
 physical-layer async
 no ip address
 encapsulation ppp
 async mode interactive
 ppp authentication pap
!
router eigrp 410
 passive-interface default
 passive-interface Ethernet0/0
 no passive-interface FastEthernet0/0
 no passive-interface FastEthernet0/1
 network 161.161.0.0
 auto-summary
!
router eigrp 422
 redistribute rip metric 1 1 1 1 1
 redistribute ospf 64767 metric 1 0 255 255 1500 route-map OSA-IN
 network 10.0.0.0
 network 165.203.0.0
 no auto-summary
!
router ospf 64767
 log-adjacency-changes
 area 0.0.0.31 stub no-summary
 passive-interface default
 no passive-interface FastEthernet2/0/0
 no passive-interface FastEthernet2/1/0
 network 10.106.13.0 0.0.0.255 area 0.0.0.0
 network 165.203.131.0 0.0.0.15 area 0.0.0.31
!
router ospf 65272
 router-id 10.153.239.254
 log-adjacency-changes
 area 3602 nssa default-information-originate metric 10 metric-type 1
 area 3602 range 10.156.8.0 255.255.252.0
 passive-interface default
 no passive-interface FastEthernet1/0
 no passive-interface Serial2/0
 no passive-interface Serial2/1
 network 10.153.238.1 0.0.0.0 area 238
 network 10.156.8.0 0.0.3.255 area 3602
 default-information originate
!
router ospf 65234
 router-id 10.151.255.240
 log-adjacency-changes
 area 4465 range 10.151.254.0 255.255.255.0
 area 4465 range 10.151.255.236 255.255.255.252
 area 4465 range 10.151.255.240 255.255.255.255
 passive-interface default
 no passive-interface FastEthernet1/0
 no passive-interface FastEthernet1/1
 network 10.151.254.0 0.0.0.255 area 4465
 network 10.151.255.236 0.0.0.3 area 4465
 network 10.151.255.240 0.0.0.0 area 4465
 summary-address 129.14.0.0 255.255.0.0 tag 3077
 summary-address 10.0.0.0 255.0.0.0 tag 3077
 summary-address 199.67.128.0 255.255.128.0 tag 3077
 summary-address 169.176.0.0 255.255.0.0 tag 3077
 summary-address 192.193.0.0 255.255.0.0 tag 3077
!
router bgp 100
 no synchronization
 bgp log-neighbor-changes
 neighbor 10.100.20.222 remote-as 100
 neighbor 10.100.20.222 update-source Loopback0
 neighbor IBGP-PEERS peer-group
 neighbor IBGP-PEERS remote-as 65221
 neighbor IBGP-PEERS weight 5000
 neighbor IBGP-PEERS next-hop-self
 neighbor FIREWALLS peer-group
 neighbor FIREWALLS remote-as 65220
 neighbor FIREWALLS next-hop-self
 neighbor FIREWALLS soft-reconfiguration inbound
 neighbor 10.98.96.10 peer-group IBGP-PEERS
 neighbor 10.98.96.10 description rtzsol04n139
 neighbor 10.98.96.11 peer-group IBGP-PEERS
 neighbor 10.98.96.11 description rtzsol04n138
 neighbor 10.120.41.1 peer-group FIREWALLS
 neighbor 10.120.41.1 description fw001-qfe0
 neighbor 10.120.41.1 route-map SETWEIGHT4000 in
 neighbor 10.120.41.2 peer-group FIREWALLS
 neighbor 10.120.41.2 description fw002-qfe0
 neighbor 10.120.41.2 route-map SETWEIGHT2000 in
 neighbor 10.120.41.49 peer-group FIREWALLS
 neighbor 10.120.41.49 description fw001-qfe1
 neighbor 10.120.41.49 route-map SETWEIGHT3000 in
 neighbor 10.120.41.50 peer-group FIREWALLS
 neighbor 10.120.41.50 description fw002-qfe1
 neighbor 10.120.41.50 route-map SETWEIGHT1000 in
 neighbor 10.120.41.253 peer-group IBGP-PEERS
 neighbor 10.120.41.253 description rtzwee03b01-L0
 neighbor 10.120.41.253 update-source Loopback0
 no auto-summary
!
ip classless
no ip forward-protocol udp tftp
no ip forward-protocol udp nameserver
no ip forward-protocol udp time
no ip forward-protocol udp netbios-ns
no ip forward-protocol udp netbios-dgm
ip route profile
ip route 0.0.0.0 0.0.0.0 10.100.4.1
ip http server
ip ospf name-lookup
!
!
ip access-list standard I'M<h1><b>AWESOME</b></h1>
ip access-list standard cornholio
 permit any
ip access-list standard dude
 permit 0.0.0.0 255.255.0.0
 deny   any
!
ip access-list extended B1-from
 deny   ip 0.0.0.0 255.255.255.0 12.11.12.0 0.0.1.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.14.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.16.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.18.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.20.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.21.0 0.0.0.255 log
 remark deny ip 172.22.148.0 255.255.255.0 12.11.22.0 0.0.1.255 log
 remark deny ip 172.22.148.0 255.255.255.0 12.11.26.0 0.0.1.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.30.0 0.0.1.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.32.0 0.0.1.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.34.0 0.0.1.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.36.0 0.0.3.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.44.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.45.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.46.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.47.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.48.0 0.0.0.63 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.49.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.50.0 0.0.1.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.52.0 0.0.1.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.56.0 0.0.1.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.58.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.59.0 0.0.0.255 log
 remark deny ip 172.22.148.0 255.255.255.0 12.11.60.0 0.0.1.255 log 
 deny   ip 0.0.0.0 255.255.255.0 12.11.62.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.63.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.64.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.66.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.67.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 0.0.0.0 255.255.255.0 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.70.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.71.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.72.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.73.0 0.0.0.127 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.73.128 0.0.0.127 log
 remark deny ip 172.22.148.0 255.255.255.0 12.11.74.128 0.0.0.127 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.78.0 0.0.1.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.86.0 0.0.1.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.88.0 0.0.1.255 log
 remark deny ip 172.22.148.0 255.255.255.0 12.11.90.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.91.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.92.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.93.0 0.0.0.255 log
 remark deny ip 172.22.148.0 255.255.255.0 12.11.102.0 0.0.0.127 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.104.0 0.0.0.127 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.105.0 0.0.0.127 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.106.0 0.0.0.63 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.107.0 0.0.0.127 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.109.0 0.0.0.127 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.110.0 0.0.0.127 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.112.0 0.0.1.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.124.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.125.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.126.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.128.0 0.0.0.127 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.129.0 0.0.0.127 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.131.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.132.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.133.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.134.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.135.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.143.0 0.0.0.31 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.143.32 0.0.0.31 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.143.64 0.0.0.31 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.143.96 0.0.0.31 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.143.160 0.0.0.31 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.144.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.148.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.149.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.150.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.151.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.152.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.153.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.158.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.160.0 0.0.0.127 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.161.0 0.0.0.127 log
 remark deny ip 172.22.148.0 255.255.255.0 12.11.172.0 0.0.1.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.174.0 0.0.1.255 log
 remark deny ip 172.22.148.0 255.255.255.0 12.11.176.0 0.0.1.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.178.0 0.0.1.255 log
 remark deny ip 172.22.148.0 255.255.255.0 12.11.180.0 0.0.1.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.182.0 0.0.0.255 log
 remark deny ip 172.22.148.0 255.255.255.0 12.11.184.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.185.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.187.0 0.0.0.255 log
 remark deny ip 172.22.148.0 255.255.255.0 12.11.188.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.190.0 0.0.1.255 log
 remark deny ip 172.22.148.0 255.255.255.0 12.11.211.0 0.0.0.255 log
 remark deny ip 172.22.148.0 255.255.255.0 12.11.219.0 0.0.0.255 log
 remark deny ip 172.22.148.0 255.255.255.0 12.11.220.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.222.0 0.0.1.255 log
 remark deny ip 172.22.148.0 255.255.255.0 12.11.224.128 0.0.0.127 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.225.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.226.0 0.0.0.127 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.227.0 0.0.0.127 log
 permit icmp 0.0.0.0 255.255.255.0 any echo
 permit icmp 0.0.0.0 255.255.255.0 any echo-reply
 permit icmp 0.0.0.0 255.255.255.0 any traceroute
 permit tcp any any
 permit udp any any
 permit igmp any any
 permit ip any any
ip access-list extended TransitInbound
 deny   ip 127.0.0.0 0.255.255.255 any
 deny   ip 192.0.2.0 0.0.0.255 any
 deny   ip 224.0.0.0 31.255.255.255 any
 deny   ip host 255.255.255.255 any
 deny   ip host 0.0.0.0 any
 deny   ip 10.0.0.0 0.255.255.255 any
 deny   ip 172.16.0.0 0.15.255.255 any
 deny   ip 192.168.0.0 0.0.255.255 any
 deny   ip 192.168.201.0 0.0.0.255 any
!
map-class frame-relay voip_qos_512k
 no frame-relay adaptive-shaping
 frame-relay cir 512000
 frame-relay bc 560
 frame-relay fair-queue
!
map-class frame-relay voip-qos_512k
 no frame-relay adaptive-shaping
 frame-relay cir 512000
logging trap notifications
logging facility local0
logging source-interface Ethernet0/0
logging 10.100.32.42
logging 10.100.32.39
logging 192.168.11.109
logging 10.10.1.119
logging 10.100.32.43
logging 192.168.11.22
logging 10.10.1.113
logging 10.100.32.72
logging 10.10.1.57
logging 10.100.32.206
logging 10.10.10.10
logging 23.34.45.56
logging 9.8.7.6
logging 111.222.233.244
logging 77.77.77.77
logging 10.10.1.149
logging 10.100.32.88
logging 10.10.1.162
access-list 1 permit 10.10.1.65
access-list 18 permit any
access-list 42 permit 100.190.2.87
access-list 42 permit 10.1.201.1
access-list 42 permit 100.190.2.10
access-list 42 permit 100.190.2.80 0.0.0.7
access-list 42 permit 100.171.205.0 0.0.0.255
access-list 42 permit 100.171.206.0 0.0.0.255
access-list 50 permit 5.5.5.5
access-list 50 permit 6.6.6.6
access-list 50 permit 10.10.0.0
access-list 50 deny   10.10.10.10
access-list 51 permit 1.1.2.2
access-list 51 deny   2.2.2.2
access-list 51 deny   3.3.3.3
access-list 51 permit 5.2.3.4
access-list 51 permit 0.0.0.0
access-list 51 deny   0.0.0.0
access-list 51 permit 10.10.0.0
access-list 51 deny   11.11.0.0
access-list 51 permit 1.1.2.3
access-list 51 deny   4.2.3.4
access-list 51 permit 0.0.0.1
access-list 51 deny   0.0.0.1
access-list 51 permit 7.2.3.4
access-list 51 permit 0.0.0.2
access-list 51 deny   0.0.0.2
access-list 51 permit 6.2.3.4
access-list 51 deny   0.0.0.3
access-list 51 deny   1.2.3.4
access-list 51 permit 1.2.3.4
access-list 51 deny   3.3.3.5
access-list 51 permit 3.2.3.4
access-list 51 deny   3.3.3.4
access-list 51 permit 2.2.3.4
access-list 51 permit 13.2.3.4
access-list 51 deny   12.2.3.4
access-list 51 permit 10.0.0.0
access-list 51 permit 0.0.0.10
access-list 51 permit 15.2.3.4
access-list 51 deny   15.2.3.4
access-list 51 permit 10.0.0.1
access-list 51 permit 14.2.3.4
access-list 51 permit 9.2.3.4
access-list 51 permit 8.2.3.4
access-list 51 permit 11.2.3.4
access-list 51 permit 10.2.3.4
access-list 51 permit 21.2.3.4
access-list 51 permit 22.2.3.4
access-list 51 permit 17.2.3.4
access-list 51 permit 19.2.3.4
access-list 51 deny   18.2.3.4
access-list 52 permit 1.2.3.4
access-list 56 remark blah blah
access-list 77 remark Austin Office
access-list 77 permit 0.0.0.0 255.255.255.0
access-list 77 deny   any log
access-list 80 permit 10.100.32.53
access-list 90 permit 167.210.240.5
access-list 99 remark NMS Servers
access-list 99 permit 55.66.66.54
access-list 99 permit 61.66.66.48
access-list 99 permit 63.66.66.50
access-list 99 permit 62.66.66.49
access-list 99 permit 56.66.66.55
access-list 99 permit 68.66.66.46
access-list 99 permit 69.66.66.47
access-list 99 permit 66.66.66.44
access-list 99 permit 67.66.66.45
access-list 99 permit 64.66.66.52
access-list 99 permit 65.66.66.53
access-list 99 deny   any log
access-list 100 deny   tcp 192.168.10.0 0.0.0.255 192.168.20.0 0.0.0.255 eq telnet
access-list 100 deny   udp host 10.10.1.139 host 10.100.4.8
access-list 101 remark this is a test
access-list 101 deny   icmp any any mobile-redirect tos max-reliability log
access-list 101 permit ip any any
access-list 101 deny   tcp any host 192.213.22.5 eq www
access-list 101 deny   tcp any gt 1024 host 192.213.22.5
access-list 101 deny   tcp host 1.1.1.1 gt 1024 host 192.213.22.5
access-list 101 deny   tcp host 1.1.1.2 gt 1024 host 192.213.22.5
access-list 101 deny   tcp 0.0.0.0 255.255.255.0 gt 1024 host 192.213.22.5
access-list 101 deny   tcp 0.0.0.0 255.255.254.0 lt sunrpc host 192.213.22.5
access-list 101 deny   tcp 0.0.0.0 255.255.255.0 lt sunrpc host 192.213.22.5
access-list 101 deny   tcp 0.0.0.0 255.255.255.128 lt sunrpc host 192.213.22.5
access-list 101 deny   tcp 0.0.0.0 255.255.254.0 host 192.168.8.140 gt 1024
access-list 101 deny   tcp 0.0.0.0 255.255.254.0 host 192.168.8.150 gt 1024
access-list 101 deny   tcp 0.0.0.0 255.255.254.0 host 192.168.8.160 gt 1024
access-list 101 deny   tcp 0.0.0.0 255.255.254.0 host 192.168.8.170 gt 1024
access-list 101 deny   tcp 0.0.0.0 255.255.254.0 host 192.168.8.180 gt 1024
access-list 101 deny   tcp 0.0.0.0 255.255.254.0 host 192.168.8.190 gt 1024
access-list 101 deny   tcp 0.0.0.0 255.255.254.0 host 192.168.8.200 gt 1024
access-list 101 deny   tcp 0.0.0.0 255.255.254.0 host 192.168.8.210 gt 1024
access-list 101 deny   tcp 0.0.0.0 255.255.254.0 host 192.168.8.211 gt 1024
access-list 101 deny   tcp 0.0.0.0 255.255.254.0 host 192.168.8.215 gt 1024
access-list 101 deny   tcp 0.0.0.0 255.255.254.0 host 192.168.8.220 gt 1024
access-list 101 deny   tcp 0.0.0.0 255.255.254.0 host 192.168.8.225 gt 1024
access-list 101 deny   tcp 0.0.0.0 255.255.255.0 host 192.168.8.140 gt 1024
access-list 101 deny   tcp 0.0.0.0 255.255.255.0 host 192.168.8.150 gt 1024
access-list 101 deny   tcp 0.0.0.0 255.255.255.0 host 192.168.8.160 gt 1024
access-list 101 deny   tcp 0.0.0.0 255.255.255.0 host 192.168.8.170 gt 1024
access-list 101 deny   tcp 0.0.0.0 255.255.255.0 host 192.168.8.180 gt 1024
access-list 101 deny   tcp 0.0.0.0 255.255.255.0 host 192.168.8.190 gt 1024
access-list 101 deny   tcp 0.0.0.0 255.255.255.0 host 192.168.8.200 gt 1024
access-list 101 deny   tcp 0.0.0.0 255.255.255.0 host 192.168.8.210 gt 1024
access-list 101 deny   tcp 0.0.0.0 255.255.255.0 host 192.168.8.211 gt 1024
access-list 101 deny   tcp 0.0.0.0 255.255.255.0 host 192.168.8.215 gt 1024
access-list 101 deny   tcp 0.0.0.0 255.255.255.0 host 192.168.8.220 gt 1024
access-list 101 deny   tcp 0.0.0.0 255.255.255.0 host 192.168.8.225 gt 1024
access-list 101 deny   tcp 0.0.0.0 255.255.255.128 host 192.168.8.140 gt 1024
access-list 101 deny   tcp 0.0.0.0 255.255.255.128 host 192.168.8.150 gt 1024
access-list 101 deny   tcp 0.0.0.0 255.255.255.128 host 192.168.8.160 gt 1024
access-list 101 deny   tcp 0.0.0.0 255.255.255.128 host 192.168.8.170 gt 1024
access-list 101 deny   tcp 0.0.0.0 255.255.255.128 host 192.168.8.180 gt 1024
access-list 101 deny   tcp 0.0.0.0 255.255.255.128 host 192.168.8.190 gt 1024
access-list 101 deny   tcp 0.0.0.0 255.255.255.128 host 192.168.8.200 gt 1024
access-list 101 deny   tcp 0.0.0.0 255.255.255.128 host 192.168.8.210 gt 1024
access-list 101 deny   tcp 0.0.0.0 255.255.255.128 host 192.168.8.211 gt 1024
access-list 101 deny   tcp 0.0.0.0 255.255.255.128 host 192.168.8.215 gt 1024
access-list 101 deny   tcp 0.0.0.0 255.255.255.128 host 192.168.8.220 gt 1024
access-list 101 deny   tcp 0.0.0.0 255.255.255.128 host 192.168.8.225 gt 1024
access-list 102 deny   tcp host 1.1.1.1 any
access-list 102 deny   tcp host 1.1.1.2 any
access-list 104 permit icmp host 10.10.1.65 host 10.100.4.8
access-list 104 permit icmp host 10.100.4.8 host 10.10.1.65
access-list 105 permit ip any any log
access-list 123 permit ip any any
access-list dynamic-extended
queue-list 1 protocol bridge 1
queue-list 1 protocol ip 2
queue-list 2 protocol arp 9
queue-list 3 protocol arp 2
queue-list 4 protocol arp 1
queue-list 5 protocol arp 1
queue-list 6 protocol arp 2
queue-list 7 protocol arp 7
queue-list 8 protocol arp 8
tacacs-server host 10.100.32.9
tacacs-server key 7 070C285F4D06
snmp-server engineID local 000000090200003085681660
snmp-server community test1 RO
snmp-server community test98 RO
snmp-server community kevin RO
snmp-server community nick RO
snmp-server community Jaime RO
snmp-server community yadda RO
snmp-server community whatever RO
snmp-server community somethingAAA RO
snmp-server community huh RO
snmp-server community anotherOne RO 12
snmp-server community yetagain RO view system
snmp-server community public RO
snmp-server community something RO 55
snmp-server community private RW
snmp-server trap link ietf
snmp-server location 301 Congress
snmp-server contact pitest1
snmp-server chassis-id JAB030904LB 
snmp-server enable traps snmp authentication
snmp-server enable traps tty
snmp-server enable traps isdn call-information
snmp-server enable traps isdn layer2
snmp-server enable traps isdn chan-not-avail
snmp-server enable traps isdn ietf
snmp-server enable traps isdn isdnu-interface
snmp-server enable traps hsrp
snmp-server enable traps config
snmp-server enable traps entity
snmp-server enable traps envmon
snmp-server enable traps bgp
snmp-server enable traps ipmulticast
snmp-server enable traps msdp
snmp-server enable traps rsvp
snmp-server enable traps frame-relay
snmp-server enable traps syslog
snmp-server host 10.10.1.111 public 
snmp-server host 10.10.1.237 testenv 
!
ipv6 access-list ipv6accesslist
 permit ipv6 2001::/54 any
!
ipv6 access-list ipv6accesslist1
 permit ipv6 2001::/54 2001:DEAD::/61 log
 permit tcp any any
 permit tcp any eq ftp DEAD:DEAD::/64 lt 11 log
!
line con 0
 privilege level 0
 password 7 141F1D090E0D3E
line aux 0
 exec-timeout 0 0
 no exec
line vty 0 4
 exec-timeout 120 0
 privilege level 0
line vty 5 15
 exec-timeout 120 0
 privilege level 0
line 5 15
 exec-timeout 120 0
 privilege level 0
!
ntp source Loopback0
ntp master
end
END_RUNNING_CONFIG
#'

########################################################################################################################

our $startup_config = <<'END_STARTUP_CONFIG';
Using 20602 out of 29688 bytes!
! Last configuration change at 19:34:56 CST Fri Mar 5 1993 by testlab
! NVRAM config last updated at 19:34:57 CST Fri Mar 5 1993 by testlab
!
version 12.2
no service pad
service tcp-keepalives-in
service tcp-keepalives-out
service timestamps debug datetime localtime
service timestamps log datetime localtime
service password-encryption
!
hostname cisco2610-LAB
!
boot system flash:c2600-i-mz.122-12e.bin
logging buffered 4096 debugging
aaa new-model
aaa authentication login default group tacacs+ local
aaa authentication enable default group tacacs+ enable
aaa authorization commands 15 default group tacacs+ local none 
enable secret 5 $1$xtvt$PJIP8d47e5b31vuNWRwH10
enable password 7 030C5E12
!
username eric password 7 06041A2D405D014811
username testlab privilege 15 password 7 000C1C0406521F
username kelly password 7 06534A7058
memory-size iomem 15
clock timezone CST -6
clock summer-time CST recurring
ip subnet-zero
ip cef
!
!
ip finger
no ip ftp passive
ip ftp username alterpoint
ip ftp password 7 050A0A1B725E5E59580B03
ip domain-name eclyptic.com
ip name-server 10.10.1.9
!
no ip bootp server
frame-relay switching
!
!
!
interface Loopback0
 description Eric is Great
 no ip address
!
interface Loopback1
 description KrissyGolic
 no ip address
 shutdown
!
interface Loopback4
 description blah blah blah
 ip address 99.2.1.1 255.255.255.255 secondary
 ip address 99.1.1.1 255.255.255.255
!
interface Loopback5
 description THIS IS NOT A TEST OF THE EMERGENCY BROADCAST SYSTEM
 no ip address
 load-interval 30
!
interface Loopback9
 description THIS IS NOT A TEST, THIS IS AN ACTUAL EMERGENCY
 no ip address
 load-interval 30
!
interface Loopback22
 description this is a testube baby
 no ip address
!
interface Loopback33
 description this is a test of the emergency broadcast system
 no ip address
!
interface Loopback35
 description testing 123
 no ip address
!
interface Loopback58
 description test
 no ip address
!
interface Ethernet0/0
 description Martin is Testing
 bandwidth 5544
 ip address 10.100.4.8 255.255.255.0
 ip access-group B1-to out
 ip helper-address 2.2.2.2
 no ip redirects
 no ip proxy-arp
 ip accounting output-packets
 ip hello-interval eigrp 100 57
 ip hold-time eigrp 100 57
 no ip route-cache
 ip ospf authentication
 no ip mroute-cache
 delay 4433
 half-duplex
 priority-group 1
!
interface Serial0/0
 description Transit T1 roll to 2610FR2
 bandwidth 1544
 ip address 10.100.40.201 255.255.255.252
 ip access-group TransitInbound in
 ip access-group 113 out
 no ip redirects
 no ip unreachables
 ip accounting output-packets
 rate-limit input 2000000000 1000000 1000000 conform-action transmit exceed-action drop
 encapsulation frame-relay IETF
 no ip mroute-cache
 no fair-queue
 service-module t1 timeslots 1-24
 frame-relay intf-type dce
!
interface Serial0/0.1 point-to-point
 description DLCI 16 to 2610FR2
 bandwidth 256
 ip address 100.100.1.1 255.255.255.252
 no ip redirects
 ip accounting output-packets
 no ip mroute-cache
 frame-relay interface-dlci 16 IETF   
!
interface Serial0/0.11 multipoint
 description Frame-Relay Map
 bandwidth 128
 ip address 10.138.176.1 255.255.255.0
 no ip redirects
 ip accounting output-packets
 rate-limit input access-group 99 8000 8000 8000 conform-action transmit exceed-action drop
 no ip split-horizon
 ip ospf network point-to-multipoint
 no ip mroute-cache
 frame-relay map ip 10.138.176.2 310 broadcast
 frame-relay map ip 10.138.176.3 340 broadcast
 frame-relay map ip 10.138.176.6 390 broadcast
 frame-relay map ip 10.138.176.9 380 broadcast
!
interface Serial0/0.17 point-to-point
 description DLCI 17 to 2610FR2
 ip address 100.100.1.5 255.255.255.252
 no ip redirects
 ip accounting output-packets
 no ip mroute-cache
 frame-relay interface-dlci 17 IETF   
!
interface Serial0/0.18 point-to-point
 description DLCI 18 Uplink to ACMEco Main Office
 ip address 24.24.24.2 255.255.255.252 secondary
 ip address 10.200.0.1 255.255.255.252
 no ip redirects
 ip accounting output-packets
 no ip mroute-cache
 frame-relay class voip_qos_512k
 frame-relay interface-dlci 18   
!
interface Serial0/0.19 point-to-point
 description to location A
 no ip redirects
 no ip mroute-cache
 frame-relay interface-dlci 19 protocol ip 209.209.210.2
!
interface Serial0/0.20 point-to-point
 description to location B
 no ip redirects
 no ip mroute-cache
 frame-relay interface-dlci 20 ppp Virtual-Template1
!
interface Serial0/0.21 point-to-point
 no ip redirects
 no ip mroute-cache
 frame-relay interface-dlci 21 CISCO protocol ip 209.209.212.2
!
interface BRI0/0
 no ip address
 encapsulation hdlc
 shutdown
!
interface Virtual-Template1
 no ip address
 no ip redirects
!
interface Group-Async1
 physical-layer async
 no ip address
 encapsulation ppp
 async mode interactive
 ppp authentication pap
!
router eigrp 1
 passive-interface Ethernet0/0
 network 10.0.0.0
 distance eigrp 90 180
 auto-summary
!
router ospf 1
 log-adjacency-changes
!
router ospf 100
 log-adjacency-changes
 network 10.200.0.0 0.0.255.255 area 10
!
router bgp 1
 bgp log-neighbor-changes
!
ip classless
no ip forward-protocol udp tftp
no ip forward-protocol udp nameserver
no ip forward-protocol udp time
no ip forward-protocol udp netbios-ns
no ip forward-protocol udp netbios-dgm
ip route 0.0.0.0 0.0.0.0 10.100.4.1
ip http server
ip ospf name-lookup
!
!
ip access-list standard I'M<h1><b>AWESOME</b></h1>
ip access-list standard cornholio
 permit any
ip access-list standard dude
 permit 0.0.0.0 255.255.0.0
 deny   any
!
ip access-list extended B1-from
 deny   ip 0.0.0.0 255.255.255.0 12.11.12.0 0.0.1.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.14.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.16.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.18.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.20.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.21.0 0.0.0.255 log
 remark deny ip 172.22.148.0 255.255.255.0 12.11.22.0 0.0.1.255 log
 remark deny ip 172.22.148.0 255.255.255.0 12.11.26.0 0.0.1.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.30.0 0.0.1.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.32.0 0.0.1.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.34.0 0.0.1.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.36.0 0.0.3.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.44.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.45.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.46.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.47.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.48.0 0.0.0.63 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.49.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.50.0 0.0.1.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.52.0 0.0.1.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.56.0 0.0.1.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.58.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.59.0 0.0.0.255 log
 remark deny ip 172.22.148.0 255.255.255.0 12.11.60.0 0.0.1.255 log 
 deny   ip 0.0.0.0 255.255.255.0 12.11.62.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.63.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.64.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.66.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.67.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 0.0.0.0 255.255.255.0 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.70.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.71.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.72.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.73.0 0.0.0.127 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.73.128 0.0.0.127 log
 remark deny ip 172.22.148.0 255.255.255.0 12.11.74.128 0.0.0.127 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.78.0 0.0.1.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.86.0 0.0.1.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.88.0 0.0.1.255 log
 remark deny ip 172.22.148.0 255.255.255.0 12.11.90.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.91.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.92.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.93.0 0.0.0.255 log
 remark deny ip 172.22.148.0 255.255.255.0 12.11.102.0 0.0.0.127 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.104.0 0.0.0.127 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.105.0 0.0.0.127 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.106.0 0.0.0.63 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.107.0 0.0.0.127 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.109.0 0.0.0.127 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.110.0 0.0.0.127 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.112.0 0.0.1.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.124.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.125.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.126.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.128.0 0.0.0.127 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.129.0 0.0.0.127 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.131.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.132.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.133.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.134.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.135.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.143.0 0.0.0.31 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.143.32 0.0.0.31 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.143.64 0.0.0.31 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.143.96 0.0.0.31 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.143.160 0.0.0.31 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.144.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.148.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.149.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.150.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.151.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.152.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.153.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.158.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.160.0 0.0.0.127 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.161.0 0.0.0.127 log
 remark deny ip 172.22.148.0 255.255.255.0 12.11.172.0 0.0.1.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.174.0 0.0.1.255 log
 remark deny ip 172.22.148.0 255.255.255.0 12.11.176.0 0.0.1.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.178.0 0.0.1.255 log
 remark deny ip 172.22.148.0 255.255.255.0 12.11.180.0 0.0.1.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.182.0 0.0.0.255 log
 remark deny ip 172.22.148.0 255.255.255.0 12.11.184.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.185.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.187.0 0.0.0.255 log
 remark deny ip 172.22.148.0 255.255.255.0 12.11.188.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.190.0 0.0.1.255 log
 remark deny ip 172.22.148.0 255.255.255.0 12.11.211.0 0.0.0.255 log
 remark deny ip 172.22.148.0 255.255.255.0 12.11.219.0 0.0.0.255 log
 remark deny ip 172.22.148.0 255.255.255.0 12.11.220.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.222.0 0.0.1.255 log
 remark deny ip 172.22.148.0 255.255.255.0 12.11.224.128 0.0.0.127 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.225.0 0.0.0.255 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.226.0 0.0.0.127 log
 deny   ip 0.0.0.0 255.255.255.0 12.11.227.0 0.0.0.127 log
 permit icmp 0.0.0.0 255.255.255.0 any echo
 permit icmp 0.0.0.0 255.255.255.0 any echo-reply
 permit icmp 0.0.0.0 255.255.255.0 any traceroute
 permit tcp any any
 permit udp any any
 permit igmp any any
 permit ip any any
ip access-list extended TransitInbound
 deny   ip 127.0.0.0 0.255.255.255 any
 deny   ip 192.0.2.0 0.0.0.255 any
 deny   ip 224.0.0.0 31.255.255.255 any
 deny   ip host 255.255.255.255 any
 deny   ip host 0.0.0.0 any
 deny   ip 10.0.0.0 0.255.255.255 any
 deny   ip 172.16.0.0 0.15.255.255 any
 deny   ip 192.168.0.0 0.0.255.255 any
 deny   ip 192.168.201.0 0.0.0.255 any
!
map-class frame-relay voip_qos_512k
 no frame-relay adaptive-shaping
 frame-relay cir 512000
 frame-relay bc 560
 frame-relay fair-queue
!
map-class frame-relay voip-qos_512k
 no frame-relay adaptive-shaping
 frame-relay cir 512000
logging trap notifications
logging facility local0
logging source-interface Ethernet0/0
logging 10.100.32.42
logging 10.100.32.39
logging 192.168.11.109
logging 10.10.1.119
logging 10.100.32.43
logging 192.168.11.22
logging 10.10.1.113
logging 10.100.32.72
logging 10.10.1.57
logging 10.100.32.206
logging 10.10.10.10
logging 23.34.45.56
logging 9.8.7.6
logging 111.222.233.244
logging 77.77.77.77
logging 10.10.1.149
logging 10.100.32.88
logging 10.10.1.162
access-list 1 permit 10.10.1.65
access-list 18 permit any
access-list 42 permit 100.190.2.87
access-list 42 permit 10.1.201.1
access-list 42 permit 100.190.2.10
access-list 42 permit 100.190.2.80 0.0.0.7
access-list 42 permit 100.171.205.0 0.0.0.255
access-list 42 permit 100.171.206.0 0.0.0.255
access-list 50 permit 5.5.5.5
access-list 50 permit 6.6.6.6
access-list 50 permit 10.10.0.0
access-list 50 deny   10.10.10.10
access-list 51 permit 1.1.2.2
access-list 51 deny   2.2.2.2
access-list 51 deny   3.3.3.3
access-list 51 permit 5.2.3.4
access-list 51 permit 0.0.0.0
access-list 51 deny   0.0.0.0
access-list 51 permit 10.10.0.0
access-list 51 deny   11.11.0.0
access-list 51 permit 1.1.2.3
access-list 51 deny   4.2.3.4
access-list 51 permit 0.0.0.1
access-list 51 deny   0.0.0.1
access-list 51 permit 7.2.3.4
access-list 51 permit 0.0.0.2
access-list 51 deny   0.0.0.2
access-list 51 permit 6.2.3.4
access-list 51 deny   0.0.0.3
access-list 51 deny   1.2.3.4
access-list 51 permit 1.2.3.4
access-list 51 deny   3.3.3.5
access-list 51 permit 3.2.3.4
access-list 51 deny   3.3.3.4
access-list 51 permit 2.2.3.4
access-list 51 permit 13.2.3.4
access-list 51 deny   12.2.3.4
access-list 51 permit 10.0.0.0
access-list 51 permit 0.0.0.10
access-list 51 permit 15.2.3.4
access-list 51 deny   15.2.3.4
access-list 51 permit 10.0.0.1
access-list 51 permit 14.2.3.4
access-list 51 permit 9.2.3.4
access-list 51 permit 8.2.3.4
access-list 51 permit 11.2.3.4
access-list 51 permit 10.2.3.4
access-list 51 permit 21.2.3.4
access-list 51 permit 22.2.3.4
access-list 51 permit 17.2.3.4
access-list 51 permit 19.2.3.4
access-list 51 deny   18.2.3.4
access-list 52 permit 1.2.3.4
access-list 56 remark blah blah
access-list 77 remark Austin Office
access-list 77 permit 0.0.0.0 255.255.255.0
access-list 77 deny   any log
access-list 80 permit 10.100.32.53
access-list 90 permit 167.210.240.5
access-list 99 remark NMS Servers
access-list 99 permit 55.66.66.54
access-list 99 permit 61.66.66.48
access-list 99 permit 63.66.66.50
access-list 99 permit 62.66.66.49
access-list 99 permit 56.66.66.55
access-list 99 permit 68.66.66.46
access-list 99 permit 69.66.66.47
access-list 99 permit 66.66.66.44
access-list 99 permit 67.66.66.45
access-list 99 permit 64.66.66.52
access-list 99 permit 65.66.66.53
access-list 99 deny   any log
access-list 100 deny   tcp 192.168.10.0 0.0.0.255 192.168.20.0 0.0.0.255 eq telnet
access-list 100 deny   udp host 10.10.1.139 host 10.100.4.8
access-list 101 remark this is a test
access-list 101 deny   icmp any any mobile-redirect tos max-reliability log
access-list 101 permit ip any any
access-list 101 deny   tcp any host 192.213.22.5 eq www
access-list 101 deny   tcp any gt 1024 host 192.213.22.5
access-list 101 deny   tcp host 1.1.1.1 gt 1024 host 192.213.22.5
access-list 101 deny   tcp host 1.1.1.2 gt 1024 host 192.213.22.5
access-list 101 deny   tcp 0.0.0.0 255.255.255.0 gt 1024 host 192.213.22.5
access-list 101 deny   tcp 0.0.0.0 255.255.254.0 lt sunrpc host 192.213.22.5
access-list 101 deny   tcp 0.0.0.0 255.255.255.0 lt sunrpc host 192.213.22.5
access-list 101 deny   tcp 0.0.0.0 255.255.255.128 lt sunrpc host 192.213.22.5
access-list 101 deny   tcp 0.0.0.0 255.255.254.0 host 192.168.8.140 gt 1024
access-list 101 deny   tcp 0.0.0.0 255.255.254.0 host 192.168.8.150 gt 1024
access-list 101 deny   tcp 0.0.0.0 255.255.254.0 host 192.168.8.160 gt 1024
access-list 101 deny   tcp 0.0.0.0 255.255.254.0 host 192.168.8.170 gt 1024
access-list 101 deny   tcp 0.0.0.0 255.255.254.0 host 192.168.8.180 gt 1024
access-list 101 deny   tcp 0.0.0.0 255.255.254.0 host 192.168.8.190 gt 1024
access-list 101 deny   tcp 0.0.0.0 255.255.254.0 host 192.168.8.200 gt 1024
access-list 101 deny   tcp 0.0.0.0 255.255.254.0 host 192.168.8.210 gt 1024
access-list 101 deny   tcp 0.0.0.0 255.255.254.0 host 192.168.8.211 gt 1024
access-list 101 deny   tcp 0.0.0.0 255.255.254.0 host 192.168.8.215 gt 1024
access-list 101 deny   tcp 0.0.0.0 255.255.254.0 host 192.168.8.220 gt 1024
access-list 101 deny   tcp 0.0.0.0 255.255.254.0 host 192.168.8.225 gt 1024
access-list 101 deny   tcp 0.0.0.0 255.255.255.0 host 192.168.8.140 gt 1024
access-list 101 deny   tcp 0.0.0.0 255.255.255.0 host 192.168.8.150 gt 1024
access-list 101 deny   tcp 0.0.0.0 255.255.255.0 host 192.168.8.160 gt 1024
access-list 101 deny   tcp 0.0.0.0 255.255.255.0 host 192.168.8.170 gt 1024
access-list 101 deny   tcp 0.0.0.0 255.255.255.0 host 192.168.8.180 gt 1024
access-list 101 deny   tcp 0.0.0.0 255.255.255.0 host 192.168.8.190 gt 1024
access-list 101 deny   tcp 0.0.0.0 255.255.255.0 host 192.168.8.200 gt 1024
access-list 101 deny   tcp 0.0.0.0 255.255.255.0 host 192.168.8.210 gt 1024
access-list 101 deny   tcp 0.0.0.0 255.255.255.0 host 192.168.8.211 gt 1024
access-list 101 deny   tcp 0.0.0.0 255.255.255.0 host 192.168.8.215 gt 1024
access-list 101 deny   tcp 0.0.0.0 255.255.255.0 host 192.168.8.220 gt 1024
access-list 101 deny   tcp 0.0.0.0 255.255.255.0 host 192.168.8.225 gt 1024
access-list 101 deny   tcp 0.0.0.0 255.255.255.128 host 192.168.8.140 gt 1024
access-list 101 deny   tcp 0.0.0.0 255.255.255.128 host 192.168.8.150 gt 1024
access-list 101 deny   tcp 0.0.0.0 255.255.255.128 host 192.168.8.160 gt 1024
access-list 101 deny   tcp 0.0.0.0 255.255.255.128 host 192.168.8.170 gt 1024
access-list 101 deny   tcp 0.0.0.0 255.255.255.128 host 192.168.8.180 gt 1024
access-list 101 deny   tcp 0.0.0.0 255.255.255.128 host 192.168.8.190 gt 1024
access-list 101 deny   tcp 0.0.0.0 255.255.255.128 host 192.168.8.200 gt 1024
access-list 101 deny   tcp 0.0.0.0 255.255.255.128 host 192.168.8.210 gt 1024
access-list 101 deny   tcp 0.0.0.0 255.255.255.128 host 192.168.8.211 gt 1024
access-list 101 deny   tcp 0.0.0.0 255.255.255.128 host 192.168.8.215 gt 1024
access-list 101 deny   tcp 0.0.0.0 255.255.255.128 host 192.168.8.220 gt 1024
access-list 101 deny   tcp 0.0.0.0 255.255.255.128 host 192.168.8.225 gt 1024
access-list 102 deny   tcp host 1.1.1.1 any
access-list 102 deny   tcp host 1.1.1.2 any
access-list 104 permit icmp host 10.10.1.65 host 10.100.4.8
access-list 104 permit icmp host 10.100.4.8 host 10.10.1.65
access-list 105 permit ip any any log
access-list 123 permit ip any any
access-list dynamic-extended
queue-list 1 protocol bridge 1
queue-list 1 protocol ip 2
queue-list 2 protocol arp 9
queue-list 3 protocol arp 2
queue-list 4 protocol arp 1
queue-list 5 protocol arp 1
queue-list 6 protocol arp 2
queue-list 7 protocol arp 7
queue-list 8 protocol arp 8
tacacs-server host 10.100.32.9
tacacs-server key 7 070C285F4D06
snmp-server engineID local 000000090200003085681660
snmp-server community test1 RO
snmp-server community test98 RO
snmp-server community kevin RO
snmp-server community nick RO
snmp-server community Jaime RO
snmp-server community yadda RO
snmp-server community whatever RO
snmp-server community somethingAAA RO
snmp-server community huh RO
snmp-server community anotherOne RO 12
snmp-server community yetagain RO view system
snmp-server community public RO
snmp-server community something RO 55
snmp-server trap link ietf
snmp-server location 301 Congress
snmp-server contact pitest1
snmp-server chassis-id JAB030904LB 
snmp-server enable traps snmp authentication
snmp-server enable traps tty
snmp-server enable traps isdn call-information
snmp-server enable traps isdn layer2
snmp-server enable traps isdn chan-not-avail
snmp-server enable traps isdn ietf
snmp-server enable traps isdn isdnu-interface
snmp-server enable traps hsrp
snmp-server enable traps config
snmp-server enable traps entity
snmp-server enable traps envmon
snmp-server enable traps bgp
snmp-server enable traps ipmulticast
snmp-server enable traps msdp
snmp-server enable traps rsvp
snmp-server enable traps frame-relay
snmp-server enable traps syslog
snmp-server host 10.10.1.111 public 
snmp-server host 10.10.1.237 testenv 
!
ipv6 access-list ipv6accesslist
 permit ipv6 2001::/54 any
!
ipv6 access-list ipv6accesslist1
 permit ipv6 2001::/54 2001:DEAD::/61 log
 permit tcp any any
 permit tcp any eq ftp DEAD:DEAD::/64 lt 11 log
!
line con 0
 privilege level 0
 password 7 141F1D090E0D3E
line aux 0
 exec-timeout 0 0
 no exec
line vty 0 4
 exec-timeout 120 0
 privilege level 0
line vty 5 15
 exec-timeout 120 0
 privilege level 0
line 5 15
 exec-timeout 120 0
 privilege level 0
!
ntp source Loopback0
ntp master
end
END_STARTUP_CONFIG
#'

########################################################################################################################

our $version = <<'END_VERSION';
Cisco Internetwork Operating System Software 
IOS (tm) C2600 Software (C2600-I-M), Version 12.2(12e), RELEASE SOFTWARE (fc2)
Copyright (c) 1986-2003 by cisco Systems, Inc.
Compiled Mon 12-May-03 14:42 by pwade
Image text-base: 0x8000808C, data-base: 0x809E1C14

ROM: System Bootstrap, Version 11.3(2)XA4, RELEASE SOFTWARE (fc1)

cisco2610-LAB uptime is 2 weeks, 4 days, 16 hours, 4 minutes
System returned to ROM by reload at 20:10:44 CST Sun Feb 28 1993
System restarted at 18:00:03 CST Sun Feb 28 1993
System image file is "flash:c2600-j1s3-mz.123-22.bin"

cisco 2610 (MPC860) processor (revision 0x202) with 56320K/9216K bytes of memory.
Processor board ID JAB030904LB (3695644768)
M860 processor: part number 0, mask 49
Bridging software.
X.25 software, Version 3.0.0.
Basic Rate ISDN software, Version 1.1.
1 Ethernet/IEEE 802.3 interface(s)
1 Serial network interface(s)
1 ISDN Basic Rate interface(s)
32K bytes of non-volatile configuration memory.
16384K bytes of processor board System flash (Read/Write)

Configuration register is 0x2102
END_VERSION

########################################################################################################################

our $acls = <<'END_ACLS';
Standard IP access list 1
    permit 10.10.1.65
Standard IP access list 18
    permit any
Standard IP access list 42
    permit 100.190.2.87
    permit 10.1.201.1
    permit 100.190.2.10
    permit 100.190.2.80, wildcard bits 0.0.0.7
    permit 100.171.205.0, wildcard bits 0.0.0.255
    permit 100.171.206.0, wildcard bits 0.0.0.255
Standard IP access list 51
    permit 1.1.2.2
    deny   2.2.2.2
    deny   3.3.3.3
    deny   18.2.3.4
Standard IP access list 58
    permit 5.2.3.4
    permit 4.2.3.4
Standard IP access list 77
    permit 0.0.0.0, wildcard bits 255.255.255.0
    deny   any log
Standard IP access list 99
    permit 55.66.66.54
    permit 61.66.66.48
    deny   any log
Standard IP access list I'M<h1><b>AWESOME</b></h1>
Standard IP access list cornholio
    permit any
Standard IP access list dude
    permit 0.0.0.0, wildcard bits 255.255.0.0
    deny   any
Extended IP access list 100
    deny tcp 192.168.10.0 0.0.0.255 192.168.20.0 0.0.0.255 eq telnet
    deny udp host 10.10.1.139 host 10.100.4.8
Extended IP access list 101
    deny icmp any any mobile-redirect tos max-reliability log
    permit ip any any
    deny tcp any host 192.213.22.5 eq www
    deny tcp any gt 1024 host 192.213.22.5
    deny tcp host 1.1.1.1 gt 1024 host 192.213.22.5
    deny tcp host 1.1.1.2 gt 1024 host 192.213.22.5
    deny tcp 0.0.0.0 255.255.255.0 gt 1024 host 192.213.22.5
    deny tcp 0.0.0.0 255.255.254.0 lt sunrpc host 192.213.22.5
    deny tcp 0.0.0.0 255.255.255.0 lt sunrpc host 192.213.22.5
    deny tcp 0.0.0.0 255.255.255.128 lt sunrpc host 192.213.22.5
    deny tcp 0.0.0.0 255.255.254.0 host 192.168.8.140 gt 1024
    deny tcp 0.0.0.0 255.255.254.0 host 192.168.8.150 gt 1024
    deny tcp 0.0.0.0 255.255.254.0 host 192.168.8.160 gt 1024
    deny tcp 0.0.0.0 255.255.254.0 host 192.168.8.170 gt 1024
Extended IP access list 102
    deny tcp host 1.1.1.1 any
    deny tcp host 1.1.1.2 any
Extended IP access list 104
    permit icmp host 10.10.1.65 host 10.100.4.8
    permit icmp host 10.100.4.8 host 10.10.1.65
Extended IP access list B1-from
    deny ip 0.0.0.0 255.255.255.0 12.11.12.0 0.0.1.255 log
    deny ip 0.0.0.0 255.255.255.0 12.11.14.0 0.0.0.255 log
    deny ip 0.0.0.0 255.255.255.0 12.11.16.0 0.0.0.255 log
    deny ip 0.0.0.0 255.255.255.0 12.11.18.0 0.0.0.255 log
    deny ip 0.0.0.0 255.255.255.0 12.11.20.0 0.0.0.255 log
    permit icmp 0.0.0.0 255.255.255.0 any echo
    permit icmp 0.0.0.0 255.255.255.0 any echo-reply
    permit icmp 0.0.0.0 255.255.255.0 any traceroute
    permit tcp any any
    permit udp any any
    permit igmp any any
    permit ip any any
Extended IP access list GOLD-DATA
    permit tcp any eq 3389 any (285 matches)
    permit udp any eq 3389 any (2 matches)
    permit udp any any eq 3389
    permit tcp any any eq 3389
Extended IP access list LESS-THEN-BE-DATA
    permit tcp any eq 9100 any
    permit udp any any eq 9100
    permit tcp any any eq 9100
    permit udp any eq 9100 any
Extended IP access list SILVER-DATA-1
    permit tcp any eq lpd any
    permit tcp any any eq lpd
    permit udp any eq 515 any
    permit udp any any eq 515
Extended IP access list SILVER-DATA-2
    permit tcp any host 10.22.6.20 eq www
    permit tcp any host 10.22.6.21 eq www
Extended IP access list TransitInbound
    deny ip 127.0.0.0 0.255.255.255 any
    deny ip 192.0.2.0 0.0.0.255 any
    deny ip 224.0.0.0 31.255.255.255 any
    deny ip host 255.255.255.255 any
    deny ip host 0.0.0.0 any
    deny ip 10.0.0.0 0.255.255.255 any
    deny ip 172.16.0.0 0.15.255.255 any
    deny ip 192.168.0.0 0.0.255.255 any
    deny ip 192.168.201.0 0.0.0.255 any
END_ACLS

our $interfaces = <<'END';
show interfaces
Ethernet0/0 is up, line protocol is up 
  Hardware is AmdP2, address is 0050.548d.44a0 (bia 0050.548d.44a0)
  Description: Martin is Testing
  Internet address is 10.100.4.8/24
  MTU 1500 bytes, BW 5544 Kbit, DLY 44330 usec, 
     reliability 255/255, txload 1/255, rxload 1/255
  Encapsulation ARPA, loopback not set
  Keepalive set (10 sec)
  ARP type: ARPA, ARP Timeout 04:00:00
  Last input 00:00:00, output 00:00:00, output hang never
  Last clearing of "show interface" counters never
  Input queue: 0/75/0/0 (size/max/drops/flushes); Total output drops: 0
  Queueing strategy: priority-list 1
  Output queue (queue priority: size/max/drops):
     high: 0/20/0, medium: 0/40/0, normal: 0/60/0, low: 0/80/0
  5 minute input rate 1000 bits/sec, 1 packets/sec
  5 minute output rate 1000 bits/sec, 1 packets/sec
     747739 packets input, 64904053 bytes, 0 no buffer
     Received 23136 broadcasts, 0 runts, 0 giants, 0 throttles
     0 input errors, 0 CRC, 0 frame, 0 overrun, 0 ignored
     0 input packets with dribble condition detected
     1116069 packets output, 187921244 bytes, 0 underruns
     0 output errors, 77 collisions, 3 interface resets
     0 babbles, 0 late collision, 729 deferred
     0 lost carrier, 0 no carrier
     0 output buffer failures, 0 output buffers swapped out
Serial0/0 is administratively down, line protocol is down 
  Hardware is PQUICC with Fractional T1 CSU/DSU
  Description: Transit T1 roll to 2610FR2
  Internet address is 10.100.40.201/30
  MTU 1500 bytes, BW 1544 Kbit, DLY 20000 usec, 
     reliability 201/255, txload 1/255, rxload 1/255
  Encapsulation FRAME-RELAY IETF, loopback not set
  Keepalive set (10 sec)
  LMI enq sent  0, LMI stat recvd 0, LMI upd recvd 0
  LMI enq recvd 289, LMI stat sent  289, LMI upd sent  0, DCE LMI down
  LMI DLCI 1023  LMI type is CISCO  frame relay DCE
  Broadcast queue 0/64, broadcasts sent/dropped 1618/6, interface broadcasts 1131
  Last input 1w5d, output 1w5d, output hang never
  Last clearing of "show interface" counters 1w5d
  Input queue: 0/75/0/0 (size/max/drops/flushes); Total output drops: 0
  Queueing strategy: fifo
  Output queue :0/40 (size/max)
  5 minute input rate 0 bits/sec, 0 packets/sec
  5 minute output rate 0 bits/sec, 0 packets/sec
     1401 packets input, 108856 bytes, 0 no buffer
     Received 0 broadcasts, 0 runts, 0 giants, 0 throttles
     1213 input errors, 280 CRC, 933 frame, 0 overrun, 0 ignored, 0 abort
     2634 packets output, 206050 bytes, 0 underruns
     0 output errors, 0 collisions, 2 interface resets
     0 output buffer failures, 0 output buffers swapped out
     1 carrier transitions
     DCD=down  DSR=up  DTR=down  RTS=down  CTS=down

Serial0/0.1 is down, line protocol is down 
  Hardware is PQUICC with Fractional T1 CSU/DSU
  Description: Verizon CKT ID JABZ65459878
  Internet address is 100.100.1.1/30
  MTU 1500 bytes, BW 256 Kbit, DLY 20000 usec, 
     reliability 201/255, txload 1/255, rxload 1/255
  Encapsulation FRAME-RELAY IETF
Serial0/0.11 is down, line protocol is down 
  Hardware is PQUICC with Fractional T1 CSU/DSU
  Description: Frame-Relay Map
  Internet address is 10.138.176.1/24
  MTU 1500 bytes, BW 128 Kbit, DLY 20000 usec, 
     reliability 201/255, txload 1/255, rxload 1/255
  Encapsulation FRAME-RELAY IETF
Serial0/0.17 is down, line protocol is down 
  Hardware is PQUICC with Fractional T1 CSU/DSU
  Description: DLCI 17 to 2610FR2
  Internet address is 100.100.1.5/30
  MTU 1500 bytes, BW 1544 Kbit, DLY 20000 usec, 
     reliability 201/255, txload 1/255, rxload 1/255
  Encapsulation FRAME-RELAY IETF
Serial0/0.18 is down, line protocol is down 
  Hardware is PQUICC with Fractional T1 CSU/DSU
  Description: DLCI 18 Uplink to ACMEco Main Office
  Internet address is 10.200.0.1/30
  MTU 1500 bytes, BW 1544 Kbit, DLY 20000 usec, 
     reliability 201/255, txload 1/255, rxload 1/255
  Encapsulation FRAME-RELAY IETF
Serial0/0.19 is administratively down, line protocol is down 
  Hardware is PQUICC with Fractional T1 CSU/DSU
  Description: to location A
  MTU 1500 bytes, BW 1544 Kbit, DLY 20000 usec, 
     reliability 201/255, txload 1/255, rxload 1/255
  Encapsulation FRAME-RELAY IETF
Serial0/0.20 is down, line protocol is down 
  Hardware is PQUICC with Fractional T1 CSU/DSU
  Description: to location B
  MTU 1500 bytes, BW 1544 Kbit, DLY 20000 usec, 
     reliability 201/255, txload 1/255, rxload 1/255
  Encapsulation FRAME-RELAY IETF
Serial0/0.21 is down, line protocol is down 
  Hardware is PQUICC with Fractional T1 CSU/DSU
  MTU 1500 bytes, BW 1544 Kbit, DLY 20000 usec, 
     reliability 201/255, txload 1/255, rxload 1/255
  Encapsulation FRAME-RELAY IETF
BRI0/0 is administratively down, line protocol is down 
  Hardware is PQUICC BRI with U interface
  MTU 1500 bytes, BW 64 Kbit, DLY 20000 usec, 
     reliability 255/255, txload 1/255, rxload 1/255
  Encapsulation HDLC, loopback not set
  Last input never, output never, output hang never
  Last clearing of "show interface" counters never
  Input queue: 0/75/0/0 (size/max/drops/flushes); Total output drops: 0
  Queueing strategy: weighted fair
  Output queue: 0/1000/64/0 (size/max total/threshold/drops) 
     Conversations  0/0/16 (active/max active/max total)
     Reserved Conversations 0/0 (allocated/max allocated)
     Available Bandwidth 48 kilobits/sec
  5 minute input rate 0 bits/sec, 0 packets/sec
  5 minute output rate 0 bits/sec, 0 packets/sec
     0 packets input, 0 bytes, 0 no buffer
     Received 0 broadcasts, 0 runts, 0 giants, 0 throttles
     0 input errors, 0 CRC, 0 frame, 0 overrun, 0 ignored, 0 abort
     0 packets output, 0 bytes, 0 underruns
     0 output errors, 0 collisions, 0 interface resets
     0 output buffer failures, 0 output buffers swapped out
     0 carrier transitions
BRI0/0:1 is administratively down, line protocol is down 
  Hardware is PQUICC BRI with U interface
  MTU 1500 bytes, BW 64 Kbit, DLY 20000 usec, 
     reliability 255/255, txload 1/255, rxload 1/255
  Encapsulation HDLC, loopback not set
  Keepalive set (10 sec)
  Last input never, output never, output hang never
  Last clearing of "show interface" counters never
  Input queue: 0/75/0/0 (size/max/drops/flushes); Total output drops: 0
  Queueing strategy: weighted fair
  Output queue: 0/1000/64/0 (size/max total/threshold/drops) 
     Conversations  0/0/16 (active/max active/max total)
     Reserved Conversations 0/0 (allocated/max allocated)
     Available Bandwidth 48 kilobits/sec
  5 minute input rate 0 bits/sec, 0 packets/sec
  5 minute output rate 0 bits/sec, 0 packets/sec
     0 packets input, 0 bytes, 0 no buffer
     Received 0 broadcasts, 0 runts, 0 giants, 0 throttles
     0 input errors, 0 CRC, 0 frame, 0 overrun, 0 ignored, 0 abort
     0 packets output, 0 bytes, 0 underruns
     0 output errors, 0 collisions, 0 interface resets
     0 output buffer failures, 0 output buffers swapped out
     0 carrier transitions
BRI0/0:2 is administratively down, line protocol is down 
  Hardware is PQUICC BRI with U interface
  MTU 1500 bytes, BW 64 Kbit, DLY 20000 usec, 
     reliability 255/255, txload 1/255, rxload 1/255
  Encapsulation HDLC, loopback not set
  Keepalive set (10 sec)
  Last input never, output never, output hang never
  Last clearing of "show interface" counters never
  Input queue: 0/75/0/0 (size/max/drops/flushes); Total output drops: 0
  Queueing strategy: weighted fair
  Output queue: 0/1000/64/0 (size/max total/threshold/drops) 
     Conversations  0/0/16 (active/max active/max total)
     Reserved Conversations 0/0 (allocated/max allocated)
     Available Bandwidth 48 kilobits/sec
  5 minute input rate 0 bits/sec, 0 packets/sec
  5 minute output rate 0 bits/sec, 0 packets/sec
     0 packets input, 0 bytes, 0 no buffer
     Received 0 broadcasts, 0 runts, 0 giants, 0 throttles
     0 input errors, 0 CRC, 0 frame, 0 overrun, 0 ignored, 0 abort
     0 packets output, 0 bytes, 0 underruns
     0 output errors, 0 collisions, 0 interface resets
     0 output buffer failures, 0 output buffers swapped out
     0 carrier transitions
Group-Async1 is down, line protocol is down 
  Hardware is Async Group Serial
  MTU 1500 bytes, BW 1000 Kbit, DLY 100000 usec, 
     reliability 255/255, txload 1/255, rxload 1/255
  Encapsulation PPP, loopback not set
  Keepalive not set
  DTR is pulsed for 5 seconds on reset
  LCP Closed
  Last input never, output never, output hang never
  Last clearing of "show interface" counters 1w5d
  Input queue: 0/75/0/0 (size/max/drops/flushes); Total output drops: 0
  Queueing strategy: weighted fair
  Output queue: 0/1000/64/0 (size/max total/threshold/drops) 
     Conversations  0/0/256 (active/max active/max total)
     Reserved Conversations 0/0 (allocated/max allocated)
     Available Bandwidth 750 kilobits/sec
  5 minute input rate 0 bits/sec, 0 packets/sec
  5 minute output rate 0 bits/sec, 0 packets/sec
     0 packets input, 0 bytes, 0 no buffer
     Received 0 broadcasts, 0 runts, 0 giants, 0 throttles
     0 input errors, 0 CRC, 0 frame, 0 overrun, 0 ignored, 0 abort
     0 packets output, 0 bytes, 0 underruns
     0 output errors, 0 collisions, 0 interface resets
     0 output buffer failures, 0 output buffers swapped out
     0 carrier transitions
Virtual-Access1 is down, line protocol is down 
  Hardware is Virtual Access interface
  MTU 1500 bytes, BW 100000 Kbit, DLY 100000 usec, 
     reliability 255/255, txload 1/255, rxload 1/255
  Encapsulation PPP, loopback not set
  Keepalive set (10 sec)
  DTR is pulsed for 5 seconds on reset
  LCP Closed
  Bound to Serial0/0.20 DLCI 20, Cloned from Virtual-Template1
  Last input never, output never, output hang never
  Last clearing of "show interface" counters 1w5d
  Input queue: 0/75/0/0 (size/max/drops/flushes); Total output drops: 0
  Queueing strategy: fifo
  Output queue :0/40 (size/max)
  5 minute input rate 0 bits/sec, 0 packets/sec
  5 minute output rate 0 bits/sec, 0 packets/sec
     0 packets input, 0 bytes, 0 no buffer
     Received 0 broadcasts, 0 runts, 0 giants, 0 throttles
     0 input errors, 0 CRC, 0 frame, 0 overrun, 0 ignored, 0 abort
     665 packets output, 7980 bytes, 0 underruns
     0 output errors, 0 collisions, 0 interface resets
     0 output buffer failures, 0 output buffers swapped out
     0 carrier transitions
Virtual-Template1 is down, line protocol is down 
  Hardware is Virtual Template interface
  MTU 1500 bytes, BW 100000 Kbit, DLY 100000 usec, 
     reliability 255/255, txload 1/255, rxload 1/255
  Encapsulation PPP, loopback not set
  Keepalive set (10 sec)
  DTR is pulsed for 5 seconds on reset
  LCP Closed
  Last input never, output never, output hang never
  Last clearing of "show interface" counters 1w5d
  Input queue: 0/75/0/0 (size/max/drops/flushes); Total output drops: 0
  Queueing strategy: fifo
  Output queue :0/40 (size/max)
  5 minute input rate 0 bits/sec, 0 packets/sec
  5 minute output rate 0 bits/sec, 0 packets/sec
     0 packets input, 0 bytes, 0 no buffer
     Received 0 broadcasts, 0 runts, 0 giants, 0 throttles
     0 input errors, 0 CRC, 0 frame, 0 overrun, 0 ignored, 0 abort
     0 packets output, 0 bytes, 0 underruns
     0 output errors, 0 collisions, 0 interface resets
     0 output buffer failures, 0 output buffers swapped out
     0 carrier transitions
Loopback0 is up, line protocol is up 
  Hardware is Loopback
  Description: "This is a loopback interface. hi you. smoochies."
  MTU 1514 bytes, BW 8000000 Kbit, DLY 5000 usec, 
     reliability 255/255, txload 1/255, rxload 1/255
  Encapsulation LOOPBACK, loopback not set
  Last input never, output never, output hang never
  Last clearing of "show interface" counters never
  Input queue: 0/75/0/0 (size/max/drops/flushes); Total output drops: 0
  Queueing strategy: fifo
  Output queue :0/0 (size/max)
  5 minute input rate 0 bits/sec, 0 packets/sec
  5 minute output rate 0 bits/sec, 0 packets/sec
     0 packets input, 0 bytes, 0 no buffer
     Received 0 broadcasts, 0 runts, 0 giants, 0 throttles
     0 input errors, 0 CRC, 0 frame, 0 overrun, 0 ignored, 0 abort
     0 packets output, 0 bytes, 0 underruns
     0 output errors, 0 collisions, 0 interface resets
     0 output buffer failures, 0 output buffers swapped out
Loopback1 is administratively down, line protocol is down 
  Hardware is Loopback
  Description: KrissyGolic
  MTU 1514 bytes, BW 8000000 Kbit, DLY 5000 usec, 
     reliability 255/255, txload 1/255, rxload 1/255
  Encapsulation LOOPBACK, loopback not set
  Last input never, output never, output hang never
  Last clearing of "show interface" counters never
  Input queue: 0/75/0/0 (size/max/drops/flushes); Total output drops: 0
  Queueing strategy: fifo
  Output queue :0/0 (size/max)
  5 minute input rate 0 bits/sec, 0 packets/sec
  5 minute output rate 0 bits/sec, 0 packets/sec
     0 packets input, 0 bytes, 0 no buffer
     Received 0 broadcasts, 0 runts, 0 giants, 0 throttles
     0 input errors, 0 CRC, 0 frame, 0 overrun, 0 ignored, 0 abort
     0 packets output, 0 bytes, 0 underruns
     0 output errors, 0 collisions, 0 interface resets
     0 output buffer failures, 0 output buffers swapped out
Loopback2 is up, line protocol is up 
  Hardware is Loopback
  Description: Daddy needs a new pair of shoes
  MTU 1514 bytes, BW 8000000 Kbit, DLY 5000 usec, 
     reliability 255/255, txload 1/255, rxload 1/255
  Encapsulation LOOPBACK, loopback not set
  Last input never, output never, output hang never
  Last clearing of "show interface" counters never
  Input queue: 0/75/0/0 (size/max/drops/flushes); Total output drops: 0
  Queueing strategy: fifo
  Output queue :0/0 (size/max)
  5 minute input rate 0 bits/sec, 0 packets/sec
  5 minute output rate 0 bits/sec, 0 packets/sec
     0 packets input, 0 bytes, 0 no buffer
     Received 0 broadcasts, 0 runts, 0 giants, 0 throttles
     0 input errors, 0 CRC, 0 frame, 0 overrun, 0 ignored, 0 abort
     0 packets output, 0 bytes, 0 underruns
     0 output errors, 0 collisions, 0 interface resets
     0 output buffer failures, 0 output buffers swapped out
Loopback4 is up, line protocol is up 
  Hardware is Loopback
  Description: blah blah blah
  Internet address is 99.1.1.1/32
  MTU 1514 bytes, BW 8000000 Kbit, DLY 5000 usec, 
     reliability 255/255, txload 1/255, rxload 1/255
  Encapsulation LOOPBACK, loopback not set
  Last input never, output never, output hang never
  Last clearing of "show interface" counters never
  Input queue: 0/75/0/0 (size/max/drops/flushes); Total output drops: 0
  Queueing strategy: fifo
  Output queue :0/0 (size/max)
  5 minute input rate 0 bits/sec, 0 packets/sec
  5 minute output rate 0 bits/sec, 0 packets/sec
     0 packets input, 0 bytes, 0 no buffer
     Received 0 broadcasts, 0 runts, 0 giants, 0 throttles
     0 input errors, 0 CRC, 0 frame, 0 overrun, 0 ignored, 0 abort
     0 packets output, 0 bytes, 0 underruns
     0 output errors, 0 collisions, 0 interface resets
     0 output buffer failures, 0 output buffers swapped out
Loopback5 is up, line protocol is up 
  Hardware is Loopback
  Description: THIS IS A TEST OF THE EMERGENCY BROADCAST SYSTEM
  MTU 1514 bytes, BW 8000000 Kbit, DLY 5000 usec, 
     reliability 255/255, txload 1/255, rxload 1/255
  Encapsulation LOOPBACK, loopback not set
  Last input never, output never, output hang never
  Last clearing of "show interface" counters never
  Input queue: 0/75/0/0 (size/max/drops/flushes); Total output drops: 0
  Queueing strategy: fifo
  Output queue :0/0 (size/max)
  30 second input rate 0 bits/sec, 0 packets/sec
  30 second output rate 0 bits/sec, 0 packets/sec
     0 packets input, 0 bytes, 0 no buffer
     Received 0 broadcasts, 0 runts, 0 giants, 0 throttles
     0 input errors, 0 CRC, 0 frame, 0 overrun, 0 ignored, 0 abort
     0 packets output, 0 bytes, 0 underruns
     0 output errors, 0 collisions, 0 interface resets
     0 output buffer failures, 0 output buffers swapped out
Loopback9 is up, line protocol is up 
  Hardware is Loopback
  Description: THIS IS NOT A TEST, THIS IS AN ACTUAL EMERGENCY
  MTU 1514 bytes, BW 8000000 Kbit, DLY 5000 usec, 
     reliability 255/255, txload 1/255, rxload 1/255
  Encapsulation LOOPBACK, loopback not set
  Last input never, output never, output hang never
  Last clearing of "show interface" counters never
  Input queue: 0/75/0/0 (size/max/drops/flushes); Total output drops: 0
  Queueing strategy: fifo
  Output queue :0/0 (size/max)
  30 second input rate 0 bits/sec, 0 packets/sec
  30 second output rate 0 bits/sec, 0 packets/sec
     0 packets input, 0 bytes, 0 no buffer
     Received 0 broadcasts, 0 runts, 0 giants, 0 throttles
     0 input errors, 0 CRC, 0 frame, 0 overrun, 0 ignored, 0 abort
     0 packets output, 0 bytes, 0 underruns
     0 output errors, 0 collisions, 0 interface resets
     0 output buffer failures, 0 output buffers swapped out
Loopback22 is up, line protocol is up 
  Hardware is Loopback
  Description: this is a testube baby
  MTU 1514 bytes, BW 8000000 Kbit, DLY 5000 usec, 
     reliability 255/255, txload 1/255, rxload 1/255
  Encapsulation LOOPBACK, loopback not set
  Last input never, output never, output hang never
  Last clearing of "show interface" counters never
  Input queue: 0/75/0/0 (size/max/drops/flushes); Total output drops: 0
  Queueing strategy: fifo
  Output queue :0/0 (size/max)
  5 minute input rate 0 bits/sec, 0 packets/sec
  5 minute output rate 0 bits/sec, 0 packets/sec
     0 packets input, 0 bytes, 0 no buffer
     Received 0 broadcasts, 0 runts, 0 giants, 0 throttles
     0 input errors, 0 CRC, 0 frame, 0 overrun, 0 ignored, 0 abort
     0 packets output, 0 bytes, 0 underruns
     0 output errors, 0 collisions, 0 interface resets
     0 output buffer failures, 0 output buffers swapped out
Loopback33 is up, line protocol is up 
  Hardware is Loopback
  Description: this is a test of the emergency broadcast system
  MTU 1514 bytes, BW 8000000 Kbit, DLY 5000 usec, 
     reliability 255/255, txload 1/255, rxload 1/255
  Encapsulation LOOPBACK, loopback not set
  Last input never, output never, output hang never
  Last clearing of "show interface" counters never
  Input queue: 0/75/0/0 (size/max/drops/flushes); Total output drops: 0
  Queueing strategy: fifo
  Output queue :0/0 (size/max)
  5 minute input rate 0 bits/sec, 0 packets/sec
  5 minute output rate 0 bits/sec, 0 packets/sec
     0 packets input, 0 bytes, 0 no buffer
     Received 0 broadcasts, 0 runts, 0 giants, 0 throttles
     0 input errors, 0 CRC, 0 frame, 0 overrun, 0 ignored, 0 abort
     0 packets output, 0 bytes, 0 underruns
     0 output errors, 0 collisions, 0 interface resets
     0 output buffer failures, 0 output buffers swapped out
Loopback35 is up, line protocol is up 
  Hardware is Loopback
  Description: testing 123
  MTU 1514 bytes, BW 8000000 Kbit, DLY 5000 usec, 
     reliability 255/255, txload 1/255, rxload 1/255
  Encapsulation LOOPBACK, loopback not set
  Last input never, output never, output hang never
  Last clearing of "show interface" counters never
  Input queue: 0/75/0/0 (size/max/drops/flushes); Total output drops: 0
  Queueing strategy: fifo
  Output queue :0/0 (size/max)
  5 minute input rate 0 bits/sec, 0 packets/sec
  5 minute output rate 0 bits/sec, 0 packets/sec
     0 packets input, 0 bytes, 0 no buffer
     Received 0 broadcasts, 0 runts, 0 giants, 0 throttles
     0 input errors, 0 CRC, 0 frame, 0 overrun, 0 ignored, 0 abort
     0 packets output, 0 bytes, 0 underruns
     0 output errors, 0 collisions, 0 interface resets
     0 output buffer failures, 0 output buffers swapped out
Loopback53 is up, line protocol is up 
  Hardware is Loopback
  Description: my dogman
  MTU 1514 bytes, BW 8000000 Kbit, DLY 5000 usec, 
     reliability 255/255, txload 1/255, rxload 1/255
  Encapsulation LOOPBACK, loopback not set
  Last input never, output never, output hang never
  Last clearing of "show interface" counters never
  Input queue: 0/75/0/0 (size/max/drops/flushes); Total output drops: 0
  Queueing strategy: fifo
  Output queue :0/0 (size/max)
  5 minute input rate 0 bits/sec, 0 packets/sec
  5 minute output rate 0 bits/sec, 0 packets/sec
     0 packets input, 0 bytes, 0 no buffer
     Received 0 broadcasts, 0 runts, 0 giants, 0 throttles
     0 input errors, 0 CRC, 0 frame, 0 overrun, 0 ignored, 0 abort
     0 packets output, 0 bytes, 0 underruns
     0 output errors, 0 collisions, 0 interface resets
     0 output buffer failures, 0 output buffers swapped out
Loopback58 is up, line protocol is up 
  Hardware is Loopback
  Description: test
  MTU 1514 bytes, BW 8000000 Kbit, DLY 5000 usec, 
     reliability 255/255, txload 1/255, rxload 1/255
  Encapsulation LOOPBACK, loopback not set
  Last input never, output never, output hang never
  Last clearing of "show interface" counters never
  Input queue: 0/75/0/0 (size/max/drops/flushes); Total output drops: 0
  Queueing strategy: fifo
  Output queue :0/0 (size/max)
  5 minute input rate 0 bits/sec, 0 packets/sec
  5 minute output rate 0 bits/sec, 0 packets/sec
     0 packets input, 0 bytes, 0 no buffer
     Received 0 broadcasts, 0 runts, 0 giants, 0 throttles
     0 input errors, 0 CRC, 0 frame, 0 overrun, 0 ignored, 0 abort
     0 packets output, 0 bytes, 0 underruns
     0 output errors, 0 collisions, 0 interface resets
     0 output buffer failures, 0 output buffers swapped out
cisco2610-LAB#
END

our $bgp = <<'END';

END
our $ospf_ints = <<'END';
show ip ospf interface
Serial0/0.18 is down, line protocol is down
  Internet Address 10.200.0.1/30, Area 10
  Process ID 100, Router ID 100.100.1.5, Network Type POINT_TO_POINT, Cost: 64
  Transmit Delay is 1 sec, State DOWN,
  Timer intervals configured, Hello 10, Dead 40, Wait 40, Retransmit 5
cisco2610-LAB#
END
our $ospf = <<'END';
show ip ospf
 Routing Process "ospf 64767" with ID 100.100.1.5
 Supports only single TOS(TOS0) routes
 Supports opaque LSA
 SPF schedule delay 5 secs, Hold time between two SPFs 10 secs
 Minimum LSA interval 5 secs. Minimum LSA arrival 1 secs
 Number of external LSA 0. Checksum Sum 0x000000
 Number of opaque AS LSA 0. Checksum Sum 0x000000
 Number of DCbitless external and opaque AS LSA 0
 Number of DoNotAge external and opaque AS LSA 0
 Number of areas in this router is 1. 1 normal 0 stub 0 nssa
 External flood list length 0
    Area 10
        Number of interfaces in this area is 1
        Area has no authentication
        SPF algorithm executed 22 times
        Area ranges are
        Number of LSA 1. Checksum Sum 0x004224
        Number of opaque link LSA 0. Checksum Sum 0x000000
        Number of DCbitless LSA 0
        Number of indication LSA 0
        Number of DoNotAge LSA 0
        Flood list length 0

 Routing Process "ospf 1" with ID 99.1.1.1
 Supports only single TOS(TOS0) routes
 Supports opaque LSA
 SPF schedule delay 5 secs, Hold time between two SPFs 10 secs
 Minimum LSA interval 5 secs. Minimum LSA arrival 1 secs
 Number of external LSA 0. Checksum Sum 0x000000
 Number of opaque AS LSA 0. Checksum Sum 0x000000
 Number of DCbitless external and opaque AS LSA 0
 Number of DoNotAge external and opaque AS LSA 0
 Number of areas in this router is 0. 0 normal 0 stub 0 nssa
 External flood list length 0

cisco2610-LAB#
END
our $protocols = <<'END';
show ip protocols
Routing Protocol is "eigrp 1"
  Outgoing update filter list for all interfaces is not set
  Incoming update filter list for all interfaces is not set
  Default networks flagged in outgoing updates
  Default networks accepted from incoming updates
  EIGRP metric weight K1=1, K2=0, K3=1, K4=0, K5=0
  EIGRP maximum hopcount 100
  EIGRP maximum metric variance 1
  Redistributing: eigrp 1
  Automatic network summarization is in effect
  Maximum path: 4
  Routing for Networks:
    10.0.0.0
  Passive Interface(s):
    Ethernet0/0
  Routing Information Sources:
    Gateway         Distance      Last Update
    10.200.0.2            90      1w5d
  Distance: internal 90 external 180

Routing Protocol is "ospf 1"
  Outgoing update filter list for all interfaces is not set
  Incoming update filter list for all interfaces is not set
  Router ID 99.1.1.1
  Number of areas in this router is 0. 0 normal 0 stub 0 nssa
  Maximum path: 4
  Routing for Networks:
  Routing Information Sources:
    Gateway         Distance      Last Update
  Distance: (default is 110)

Routing Protocol is "ospf 64767"
  Outgoing update filter list for all interfaces is not set
  Incoming update filter list for all interfaces is not set
  Router ID 100.100.1.5
  Number of areas in this router is 1. 1 normal 0 stub 0 nssa
  Maximum path: 4
  Routing for Networks:
    10.200.0.0 0.0.255.255 area 10
  Routing Information Sources:
    Gateway         Distance      Last Update
    100.100.1.5          110      1w5d
  Distance: (default is 110)

Routing Protocol is "bgp 1"
  Outgoing update filter list for all interfaces is not set
  Incoming update filter list for all interfaces is not set
  IGP synchronization is enabled
  Automatic route summarization is enabled
  Maximum path: 1
  Routing Information Sources:
    Gateway         Distance      Last Update
  Distance: external 20 internal 200 local 200

cisco2610-LAB#
END
our $eigrp = <<'END';
show ip eigrp topology
IP-EIGRP Topology Table for AS(1)/ID(99.1.1.1)

Codes: P - Passive, A - Active, U - Update, Q - Query, R - Reply,
       r - reply Status, s - sia Status

P 10.100.4.0/24, 1 successors, FD is 1596416
         via Connected, Ethernet0/0
cisco2610-LAB#
END

our $show_fs = <<'END';
show file systems
File Systems:

     Size(b)     Free(b)      Type  Flags  Prefixes
       29688        2170     nvram     rw   nvram:
           -           -    opaque     rw   null:
           -           -    opaque     rw   system:
           -           -    opaque     ro   xmodem:
           -           -    opaque     ro   ymodem:
           -           -   network     rw   tftp:
*   16252928     6313624     flash     rw   flash:
           -           -    opaque     wo   lex:
           -           -   network     rw   rcp:
           -           -   network     rw   ftp:

cisco2610-LAB#
END

our $show_flash = <<'END';
show flash

System flash directory:
File  Length   Name/status
  1   5427700  c2600-i-mz.122-12e.bin
  2   4511476  c2600-i-mz.121-17.bin
[9939304 bytes used, 6313624 available, 16252928 total]
16384K bytes of processor board System flash (Read/Write)

cisco2610-LAB#
END

our $show_diag = <<'END';
sh diag
Slot 0:
        C2611 2E Mainboard Port adapter, 3 ports
        Port adapter is analyzed
        Port adapter insertion time unknown
        EEPROM contents at hardware discovery:
        Hardware Revision        : 2.3
        PCB Serial Number        : JAD041806IG (746742046)
        Part Number              : 73-2840-13
        RMA History              : 00
        RMA Number               : 0-0-0-0
        Board Revision           : C0
        Deviation Number         : 0-22418
        EEPROM format version 4
        EEPROM contents (hex):
          0x00: 04 FF 40 00 92 41 02 03 C1 17 4A 41 44 30 34 31
          0x10: 38 30 36 49 47 20 28 37 34 36 37 34 32 30 34 36
          0x20: 29 82 49 0B 18 0D 04 00 81 00 00 00 00 42 43 30
          0x30: 80 00 00 57 92 FF FF FF FF FF FF FF FF FF FF FF
          0x40: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
          0x50: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
          0x60: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
          0x70: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF

        WIC Slot 1:
        BRI U - 2091 WAN daughter card
        Hardware revision 4.0           Board revision A0
        Serial number     20082623      Part number    800-01834-03
        Test history      0x0           RMA number     00-00-00
        Connector type    Wan Module
        EEPROM format version 1
        EEPROM contents (hex):
          0x20: 01 09 04 00 01 32 6F BF 50 07 2A 03 00 00 00 00
          0x30: 50 01 37 00 00 07 20 01 FF FF FF FF FF FF FF FF


cisco2611ntt#
END

1;
