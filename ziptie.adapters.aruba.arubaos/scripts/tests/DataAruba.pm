package DataAruba;

use strict;
use warnings;
use Exporter 'import';
our @EXPORT_OK = qw($responsesAruba);

our $responsesAruba = {};

$responsesAruba->{switchinfo} = <<'END';
show switchinfo
Hostname is Aruba800


Location not configured
System Time:Thu Nov  8 21:54:16 CST 2007

Aruba Operating System Software.
ArubaOS (MODEL: Aruba800), Version 2.5.3.0
Website: http://www.arubanetworks.com
Copyright (c) 2002-2006, Aruba Wireless Networks Inc.
Compiled on 2006-06-28 at 11:11:47 PDT (build 12779) by p4build

ROM: System Bootstrap, Version CPBoot 1.1.3 (Feb 25 2004 - 13:00:04)

Switch uptime is 6 months 15 days 12 hours 40 minutes 38 seconds
Reboot Cause: User reboot.
Supervisor Card
Processor (revision 16.20 (pvr 8081 1014)) with 256M bytes of memory. 
32K bytes of non-volatile configuration memory.
128M bytes of Supervisor Card System flash (model=TOSHIBA THNCF128MBA).

Config File: 1158273822234.da.cfg

Boot Partition: PARTITION 0


VLAN1 is up line protocol is up
Hardware is CPU Interface, Interface address is 00:0B:86:50:38:90 (bia 00:0B:86:50:38:90)
Description: 802.1Q VLAN
Internet address is 10.100.26.3  255.255.255.0 
Routing interface is enable, Forwarding mode is enabled 
Directed broadcast is disabled
Encapsulation 802, loopback not set
MTU 1500 bytes
Last clearing of "show interface" counters 195 day 12 hr 40 min 38 sec 
link status last changed 195 day 12 hr 39 min 12 sec 


switchrole:master
masterip:127.0.0.1
Configuration Changed since last save
Crash information available.
Reboot Cause: User reboot.
(Aruba800) #

END

$responsesAruba->{contact} = <<'END';
show syscontact

microsoft

(Aruba800) #

END

$responsesAruba->{config_plain} = <<'END';
show config

version 2.5
enable secret "ca609fdbcea4b37e99ecffea5fe27ef5"
telnet cli
hostname "Aruba800"
logging level warnings stm
clock timezone CST -6
ip access-list extended 102
  deny any host 99.99.99.99 host 99.99.99.99 
!
netservice svc-snmp-trap udp 162
netservice svc-dhcp udp 67 68
netservice svc-smb-tcp tcp 445
netservice svc-https tcp 443
netservice svc-ike udp 500
netservice svc-l2tp udp 1701
netservice svc-syslog udp 514
netservice svc-pptp tcp 1723
netservice svc-telnet tcp 23
netservice svc-sccp tcp 2000
netservice svc-tftp udp 69
netservice svc-sip-tcp tcp 5060
netservice svc-kerberos udp 88
netservice svc-pop3 tcp 110
netservice svc-adp udp 8200
netservice svc-cfgm-tcp tcp 8211
netservice svc-dns udp 53
netservice svc-msrpc-tcp tcp 135 139
netservice svc-rtsp tcp 554
netservice svc-http tcp 80
netservice svc-vocera udp 5002
netservice svc-nterm tcp 1026 1028
netservice svc-sip-udp udp 5060
netservice svc-papi udp 8211
netservice svc-ftp tcp 21
netservice svc-natt udp 4500
netservice svc-svp 119
netservice svc-gre 47
netservice svc-smtp tcp 25
netservice svc-smb-udp udp 445
netservice svc-esp 50
netservice svc-bootp udp 67 69
netservice svc-snmp udp 161
netservice svc-icmp 1
netservice svc-ntp udp 123
netservice svc-msrpc-udp udp 135 139
netservice svc-ssh tcp 22
ip access-list session control
  user any udp 68 deny 
  any any svc-icmp permit 
  any any svc-dns permit 
  any any svc-papi permit 
  any any svc-cfgm-tcp permit 
  any any svc-adp permit 
  any any svc-tftp permit 
  any any svc-dhcp permit 
  any any svc-natt permit 
!
ip access-list session validuser
  any any any permit 
!
ip access-list session vocera-acl
  any any svc-vocera permit queue high 
!
ip access-list session captiveportal
  user   alias mswitch svc-https dst-nat 
  user any svc-http dst-nat 8080 
  user any svc-https dst-nat 8081 
!
ip access-list session allowall
  any any any permit 
!
ip access-list session sip-acl
  any any svc-sip-udp permit queue high 
  any any svc-sip-tcp permit queue high 
!
ip access-list session https-acl
  any any svc-https permit 
!
ip access-list session dns-acl
  any any svc-dns permit 
!
ip access-list session vpnlogon
  user any svc-ike permit 
  user any svc-esp permit 
  any any svc-l2tp permit 
  any any svc-pptp permit 
  any any svc-gre permit 
!
ip access-list session srcnat
  user any any src-nat 
!
ip access-list session skinny-acl
  any any svc-sccp permit queue high 
!
ip access-list session tftp-acl
  any any svc-tftp permit 
!
ip access-list session cplogout
  user   alias mswitch svc-https dst-nat 
!
ip access-list session guest
!
ip access-list session dhcp-acl
  any any svc-dhcp permit 
!
ip access-list session http-acl
  any any svc-http permit 
!
ip access-list session ap-acl
  any any svc-gre permit 
  any any svc-syslog permit 
  any user svc-snmp permit 
  user any svc-snmp-trap permit 
  user any svc-ntp permit 
!
ip access-list session svp-acl
  any any svc-svp permit queue high 
  user host 224.0.1.116 any permit 
!
vpn-dialer default-dialer
  ike authentication PRE-SHARE 54b558a5c3649b1ebc24c733f8a6b55c61b5f54ea0847a77
!
user-role ap-role
 session-acl control
 session-acl ap-acl
!
user-role pre-employee
 session-acl allowall
!
user-role trusted-ap
 session-acl allowall
!
user-role default-vpn-role
 session-acl allowall
!
user-role guest
 session-acl control
 session-acl cplogout
!
user-role stateful-dot1x
!
user-role stateful
 session-acl control
!
user-role pre-voice
 session-acl sip-acl
 session-acl svp-acl
 session-acl vocera-acl
 session-acl skinny-acl
 session-acl dhcp-acl
 session-acl tftp-acl
 session-acl dns-acl
!
user-role logon
 session-acl control
 session-acl captiveportal
 session-acl vpnlogon
!
user-role pre-guest
 session-acl http-acl
 session-acl https-acl
 session-acl dhcp-acl
 session-acl dns-acl
!
aaa tacacs-server 10.100.32.137 host 10.100.32.137 key c0cf072cc8e3aacf7b7f98eece6d725f mode disable
aaa derivation-rules user
  set role condition essid equals "Aruba2344" set-value pre-employee 
! 
aaa vpn-authentication default-role default-vpn-role 
aaa mgmt-authentication mode disable
aaa mgmt-authentication auth-server 10.100.32.137
aaa pubcookie-authentication
!
aaa tacacs-accounting auth-server 10.100.32.137 mode enable command all
aaa dot1x enforce-machine-authentication
 mode disable
!
dot1x timeout wpa-key-timeout 1

interface mgmt
	shutdown
!


interface fastethernet 1/0
	description "fe1/0"
	trusted
	switchport trunk allowed vlan 1,3-4094
!

interface fastethernet 1/1
	description "fe1/1"
	trusted
	switchport trunk allowed vlan 1,3-4094
!

interface fastethernet 1/2
	description "fe1/2"
	trusted
!

interface fastethernet 1/3
	description "fe1/3"
	trusted
!

interface fastethernet 1/4
	description "fe1/4"
	trusted
!

interface fastethernet 1/5
	description "fe1/5"
	trusted
!

interface fastethernet 1/6
	description "fe1/6"
	trusted
!

interface fastethernet 1/7
	description "fe1/7"
	trusted
!

interface gigabitethernet  1/8
	description "gig1/8"
	trusted
!

interface vlan 1
	ip address 10.100.26.3 255.255.255.0
!

ip default-gateway 10.100.26.2

country US

ap location 0.0.0
ap-logging level informational snmpd

double-encrypt disable
ap-logging level informational sapd
ap-logging level warnings am
ap-logging level warnings stm
max-imalive-retries 10
bkplms-ip 0.0.0.0
opmode opensystem
mode ap_mode
authalgo opensystem
rts-threshhold 2333
essid "aruba-ap"
tx-power 2
max-retries 4
dtim-period 1
max-clients 64
beacon-period 100
ap-enable enable
power-mgmt enable
ageout 1000
hide-ssid disable
deny-bcast disable
rf-band g
bootstrap-threshold 7
local-probe-response enable
max-tx-fail 0
forward-mode tunnel
native-vlan-id 1
arm assignment disable
arm client-aware enable
arm scanning disable
arm scan-time 110
arm scan-interval 10
arm multi-band-scan disable
arm voip-aware-scan enable
arm max-tx-power 4
arm min-tx-power 0
arm rogue-ap-aware disable
voip call-admission-control disable
voip drop-sip-invite-for-cac disable
voip active-load-balancing disable
voip vocera-call-capacity 10
voip sip-call-capacity 10
voip svp-call-capacity 10
voip sccp-call-capacity 10
voip call-handoff-reservation 20
voip high-capacity-threshold 20
virtual-ap "Aruba2344" vlan-id 1 opmode wpa2-aes-psk deny-bcast enable wpa-passphrase ee4ceac1a5db889c1654d11089ddefe93119742de676c097 hide-ssid enable dtim-period 1
  phy-type a
    channel 52
    rates 6,12,24
    txrates 6,9,12,18,24,36,48,54
  !
  phy-type g
    short-preamble enable
    channel 1
    rates 1,2
    txrates 1,2,5,11,6,9,12,18,24,36,48,54
    bg-mode mixed
  !
!
ap location 0.0.0
  phy-type enet1
    mode active-standby
    switchport mode access
    switchport access vlan 1
    switchport trunk native vlan 1
    switchport trunk allowed vlan ALL
    trusted disable
  !
!
wms
 general poll-interval 60000
 general poll-retries 2
 general ap-ageout-interval 30
 general sta-ageout-interval 30
 general ap-inactivity-timeout 5
 general sta-inactivity-timeout 60
 general grace-time 2000
 general laser-beam enable
 general laser-beam-debug disable
 general wired-laser-beam disable
 general stat-update enable
 general am-stats-update-interval 0
 ap-policy learn-ap disable
 ap-policy classification enable
 ap-policy protect-unsecure-ap disable
 ap-policy detect-misconfigured-ap disable
 ap-policy protect-misconfigured-ap disable
 ap-policy protect-mt-channel-split disable
 ap-policy protect-mt-ssid disable
 ap-policy detect-ap-impersonation disable
 ap-policy protect-ap-impersonation disable
 ap-policy beacon-diff-threshold 50
 ap-policy beacon-inc-wait-time 3
 ap-policy min-pot-ap-beacon-rate 25
 ap-policy min-pot-ap-monitor-time 3
 ap-policy protect-ibss disable
 ap-policy ap-load-balancing disable
 ap-policy ap-lb-max-retries 8
 ap-policy ap-lb-util-high-wm 90
 ap-policy ap-lb-util-low-wm 80
 ap-policy ap-lb-util-wait-time 30
 ap-policy ap-lb-user-high-wm 255
 ap-policy ap-lb-user-low-wm 230
 ap-policy persistent-known-interfering disable
 ap-config short-preamble enable
 ap-config privacy enable
 ap-config wpa disable
 station-policy protect-valid-sta disable
 station-policy handoff-assist disable
 station-policy rssi-falloff-wait-time 4
 station-policy low-rssi-threshold 20
 station-policy rssi-check-frequency 3
 station-policy detect-association-failure disable
 global-policy detect-bad-wep disable
 global-policy detect-interference disable
 global-policy interference-inc-threshold 100
 global-policy interference-inc-timeout 30
 global-policy interference-wait-time 30
 event-threshold fer-high-wm 0
 event-threshold fer-low-wm 0
 event-threshold frr-high-wm 16
 event-threshold frr-low-wm 8
 event-threshold flsr-high-wm 16
 event-threshold flsr-low-wm 8
 event-threshold fnur-high-wm 0
 event-threshold fnur-low-wm 0
 event-threshold frer-high-wm 16
 event-threshold frer-low-wm 8
 event-threshold ffr-high-wm 16
 event-threshold ffr-low-wm 8
 event-threshold bwr-high-wm 0
 event-threshold bwr-low-wm 0
 valid-11b-channel 1 mode enable
 valid-11b-channel 6 mode enable
 valid-11b-channel 11 mode enable
 valid-11a-channel 36 mode enable
 valid-11a-channel 40 mode enable
 valid-11a-channel 44 mode enable
 valid-11a-channel 48 mode enable
 valid-11a-channel 52 mode enable
 valid-11a-channel 56 mode enable
 valid-11a-channel 60 mode enable
 valid-11a-channel 64 mode enable
 valid-11a-channel 149 mode enable
 valid-11a-channel 153 mode enable
 valid-11a-channel 157 mode enable
 valid-11a-channel 161 mode enable
 ids-policy signature-check disable
 ids-policy rate-check disable
 ids-policy dsta-check disable
 ids-policy sequence-check disable
 ids-policy mac-oui-check disable
 ids-policy eap-check disable
 ids-policy ap-flood-check disable
 ids-policy adhoc-check disable
 ids-policy wbridge-check disable
 ids-policy sequence-diff 300
 ids-policy sequence-time-tolerance 300
 ids-policy sequence-quiet-time 900
 ids-policy eap-rate-threshold 10
 ids-policy eap-rate-time-interval 60
 ids-policy eap-rate-quiet-time 900
 ids-policy ap-flood-threshold 50
 ids-policy ap-flood-inc-time 3
 ids-policy ap-flood-quiet-time 900
 ids-policy signature-quiet-time 900
 ids-policy dsta-quiet-time 900
 ids-policy adhoc-quiet-time 900
 ids-policy wbridge-quiet-time 900
 ids-policy mac-oui-quiet-time 900
 ids-policy rate-frame-type-param assoc channel-threshold 30
 ids-policy rate-frame-type-param assoc channel-inc-time 3
 ids-policy rate-frame-type-param assoc channel-quiet-time 900
 ids-policy rate-frame-type-param assoc node-threshold 30
 ids-policy rate-frame-type-param assoc node-time-interval 60
 ids-policy rate-frame-type-param assoc node-quiet-time 900
 ids-policy rate-frame-type-param disassoc channel-threshold 30
 ids-policy rate-frame-type-param disassoc channel-inc-time 3
 ids-policy rate-frame-type-param disassoc channel-quiet-time 900
 ids-policy rate-frame-type-param disassoc node-threshold 30
 ids-policy rate-frame-type-param disassoc node-time-interval 60
 ids-policy rate-frame-type-param disassoc node-quiet-time 900
 ids-policy rate-frame-type-param deauth channel-threshold 30
 ids-policy rate-frame-type-param deauth channel-inc-time 3
 ids-policy rate-frame-type-param deauth channel-quiet-time 900
 ids-policy rate-frame-type-param deauth node-threshold 20
 ids-policy rate-frame-type-param deauth node-time-interval 60
 ids-policy rate-frame-type-param deauth node-quiet-time 900
 ids-policy rate-frame-type-param probe-request channel-threshold 200
 ids-policy rate-frame-type-param probe-request channel-inc-time 3
 ids-policy rate-frame-type-param probe-request channel-quiet-time 900
 ids-policy rate-frame-type-param probe-request node-threshold 200
 ids-policy rate-frame-type-param probe-request node-time-interval 15
 ids-policy rate-frame-type-param probe-request node-quiet-time 900
 ids-policy rate-frame-type-param probe-response channel-threshold 200
 ids-policy rate-frame-type-param probe-response channel-inc-time 3
 ids-policy rate-frame-type-param probe-response channel-quiet-time 900
 ids-policy rate-frame-type-param probe-response node-threshold 150
 ids-policy rate-frame-type-param probe-response node-time-interval 15
 ids-policy rate-frame-type-param probe-response node-quiet-time 900
 ids-policy rate-frame-type-param auth channel-threshold 30
 ids-policy rate-frame-type-param auth channel-inc-time 3
 ids-policy rate-frame-type-param auth channel-quiet-time 900
 ids-policy rate-frame-type-param auth node-threshold 30
 ids-policy rate-frame-type-param auth node-time-interval 60
 ids-policy rate-frame-type-param auth node-quiet-time 900
 ids-signature "ASLEAP"
   mode enable
   frame-type beacon ssid asleap
 !
 ids-signature "Null-Probe-Response"
   mode enable
   frame-type probe-response ssid-length 0
 !
 ids-signature "AirJack"
   mode enable
   frame-type beacon ssid AirJack
 !
 ids-signature "NetStumbler Generic"
   mode enable
   payload 0x00601d 3
   payload 0x0001 6
 !
 ids-signature "NetStumbler Version 3.3.0x"
   mode enable
   payload 0x00601d 3
   payload 0x000102 12
 !
 ids-signature "Deauth-Broadcast"
   mode enable
   frame-type deauth
   dst-mac ff:ff:ff:ff:ff:ff
 !
!
site-survey calibration-max-packets 256
site-survey calibration-transmit-rate 500
site-survey rra-max-compute-time 600000
site-survey max-ha-neighbors 3
site-survey neighbor-tx-power-bump 2
site-survey ha-compute-time 0


arm min-scan-time 8
arm ideal-coverage-index 5
arm acceptable-coverage-index 2
arm wait-time 15
arm free-channel-index 25
arm backoff-time 240
arm error-rate-threshold 0
arm error-rate-wait-time 30
arm noise-threshold 0
arm noise-wait-time 120

ems server-ip 0.0.0.0

crypto isakmp groupname changeme

vpdn group l2tp
  ppp authentication PAP
!

ip dhcp pool dhcp
 domain-name alterpoint.com
 lease 5 0 0
 network 10.100.26.12 255.255.255.252
!
ip dhcp pool vlan2-pool
 default-router 192.168.2.1
 dns-server 10.10.1.9
 domain-name alterpoint.com
 lease 2 0 0
 network 192.168.2.0 255.255.255.0
 authoritative
!
service dhcp
masterip 127.0.0.1
location "Building1.floor1" 
mobility
  parameters 60 buffer 32
  manager disable
  proxy-dhcp enable
  station-masquerade enable
  on-association disable
  trusted-roam disable
  ignore-l2-broadcast disable
  block-dhcp-release disable
  no new-user-roaming
  max-dhcp-requests 4
  secure 1000 shared-secret 2814f7bff0de0edf63501c9bafe17a74
!
mobility-local
  local-ha disable
!
mobagent
  home-agent parameters 1000 bindings 300
  secure-mobile spi 1000 554fbba3fea347d95a01dcd385186ccd
  foreign-agent parameters 1100 bindings 300 pending 0 pending-time 300
!

syscontact "microsoft"
snmp-server community public 
vpdn group pptp
  ppp authentication MSCHAPv2
!

stm dos-prevention disable
stm vlan-mobility disable
stm strict-compliance enable
stm fast-roaming disable
stm sta-dos-prevention disable
stm sta-dos-block-time 3600
stm auth-failure-block-time 0
stm coverage-hole-detection disable
stm good-rssi-threshold 20
stm poor-rssi-threshold 10
stm hole-detection-interval 180
stm good-sta-ageout 30
stm idle-sta-ageout 90
stm ap-inactivity-timeout 15

mux-address 0.0.0.0

adp discovery enable
adp igmp-join enable
adp igmp-vlan 0

voip prioritization enable


mgmt-role guest-provisioning
	description "This is a Guest Provisioning Role."
	permit local-userdb read write 
!
mgmt-role root
	description "This is Default Super User Role"
	permit super-user 
!
mgmt-user admin root 4278d6d4cafed15ef97da2f3c6858b0d
mgmt-user testlab root 47dd2e765019bfbc401c10a836247edc


no database synchronize
database synchronize rf-plan-data


ip igmp
!

packet-capture-defaults tcp disable udp disable sysmsg disable other disable
end

(Aruba800) #

END

$responsesAruba->{storage} = <<'END';
show storage
Filesystem                Size      Used Available Use% Mounted on
/dev/root                60.0M     60.0M         0 100% /
none                     70.0M      1.3M     68.7M   2% /tmp
/dev/hda3                25.2M      2.3M     21.7M   9% /flash

(Aruba800) #

END

$responsesAruba->{dir} = <<'END';
dir

-rw-r--r--    1 root     root        15610 May 21 12:36 1158273822234.da.cfg
-rw-r--r--    1 root     root        13905 Oct 14  2004 aruba800_running
-rw-r--r--    1 root     root        15008 Aug 31  2006 default.cfg
-rw-r--r--    1 root     root        89313 Nov  1  2004 exportdb.log
-rw-r--r--    1 root     root       209920 Oct 26  2004 logs-10-26-04-1143am.tar
-rw-r--r--    1 root     root       491520 Oct 29  2004 logs.tar
-rw-------    1 root     root          117 Oct 14  2004 webtrace

(Aruba800) #

END

$responsesAruba->{inventory} = <<'END';
show inventory

Supervisor Card slot      	: 0
Supervisor FPGA           	: CABERNET Rev 0x7
System Serial#            	: A10000910
Optical Card              	: Absent
SC      Assembly#         	: 2000008C (Rev:06.00) 
SC      Serial#           	: C00002127 (Date:05/25/04) 
HW MAC Addr               	: 00:0B:86:50:38:90 to 00:0B:86:50:38:9F
Line Card 1			: Present
Line Card 1 FPGA		: CABERNET Rev 0x7
Line Card 1 Switch Chip		: RoboSwitch BCM5382 Rev 0x12
Line Card 1 Mez Card		: Absent
Line Card 1 SPOE		: Present
Line Card 1 Sup Card 0 		: Present (Active)
Internal Temperature		: 36.00 degrees Celsius (NORMAL)


(Aruba800) #

END

$responsesAruba->{'running-config'} = <<'END';
version 2.5
enable secret "adf795d0d77c9bef34f2be11d9714eb9"
telnet cli
hostname "Aruba800"
logging level warnings stm
clock timezone CST -6
ip access-list standard mkisthmus
  permit 10.0.0.0 0.255.255.255 
!
ip access-list extended 102
  deny any host 99.99.99.99 host 99.99.99.99 
!
netservice svc-snmp-trap udp 162
netservice svc-dhcp udp 67 68
netservice svc-smb-tcp tcp 445
netservice svc-https tcp 443
netservice svc-ike udp 500
netservice svc-l2tp udp 1701
netservice svc-syslog udp 514
netservice svc-pptp tcp 1723
netservice svc-telnet tcp 23
netservice svc-sccp tcp 2000
netservice svc-tftp udp 69
netservice svc-sip-tcp tcp 5060
netservice svc-kerberos udp 88
netservice svc-pop3 tcp 110
netservice svc-adp udp 8200
netservice svc-cfgm-tcp tcp 8211
netservice svc-dns udp 53
netservice svc-msrpc-tcp tcp 135 139
netservice svc-rtsp tcp 554
netservice svc-http tcp 80
netservice svc-vocera udp 5002
netservice svc-nterm tcp 1026 1028
netservice svc-sip-udp udp 5060
netservice svc-papi udp 8211
netservice svc-ftp tcp 21
netservice svc-natt udp 4500
netservice svc-svp 119
netservice svc-gre 47
netservice svc-smtp tcp 25
netservice svc-smb-udp udp 445
netservice svc-esp 50
netservice svc-bootp udp 67 69
netservice svc-snmp udp 161
netservice svc-icmp 1
netservice svc-ntp udp 123
netservice svc-msrpc-udp udp 135 139
netservice svc-ssh tcp 22
time-range hiphop absolute start 10/10/2007 10:00 end 10/30/2007 10:10
ip access-list session control
  user any udp 68 deny 
  any any svc-icmp permit 
  any any svc-dns permit 
  any any svc-papi permit 
  any any svc-cfgm-tcp permit 
  any any svc-adp permit 
  any any svc-tftp permit 
  any any svc-dhcp permit 
  any any svc-natt permit 
!
ip access-list session validuser
  any any any permit 
!
ip access-list session vocera-acl
  any any svc-vocera permit queue high 
!
ip access-list session captiveportal
  user   alias mswitch svc-https dst-nat 
  user any svc-http dst-nat 8080 
  user any svc-https dst-nat 8081 
!
ip access-list session allowall
  any any any permit 
!
ip access-list session sip-acl
  any any svc-sip-udp permit queue high 
  any any svc-sip-tcp permit queue high 
!
ip access-list session https-acl
  any any svc-https permit 
!
ip access-list session dns-acl
  any any svc-dns permit 
!
ip access-list session mkisthmus1
  any any any src-nat log 
!
ip access-list session vpnlogon
  user any svc-ike permit 
  user any svc-esp permit 
  any any svc-l2tp permit 
  any any svc-pptp permit 
  any any svc-gre permit 
!
ip access-list session srcnat
  user any any src-nat 
!
ip access-list session skinny-acl
  any any svc-sccp permit queue high 
!
ip access-list session tftp-acl
  any any svc-tftp permit 
!
ip access-list session cplogout
  user   alias mswitch svc-https dst-nat 
!
ip access-list session guest
!
ip access-list session dhcp-acl
  any any svc-dhcp permit 
!
ip access-list session http-acl
  any any svc-http permit 
!
ip access-list session ap-acl
  any any svc-gre permit 
  any any svc-syslog permit 
  any user svc-snmp permit 
  user any svc-snmp-trap permit 
  user any svc-ntp permit 
!
ip access-list session svp-acl
  any any svc-svp permit queue high 
  user host 224.0.1.116 any permit 
!
vpn-dialer default-dialer
  ike authentication PRE-SHARE 6fa3dafd8071f0f4cef587ebc2db68816ea6762a8598f98d
!
user-role ap-role
 session-acl control
 session-acl ap-acl
!
user-role pre-employee
 session-acl allowall
!
user-role trusted-ap
 session-acl allowall
!
user-role default-vpn-role
 session-acl allowall
!
user-role guest
 session-acl control
 session-acl cplogout
!
user-role stateful-dot1x
!
user-role stateful
 session-acl control
!
user-role pre-voice
 session-acl sip-acl
 session-acl svp-acl
 session-acl vocera-acl
 session-acl skinny-acl
 session-acl dhcp-acl
 session-acl tftp-acl
 session-acl dns-acl
!
user-role logon
 session-acl control
 session-acl captiveportal
 session-acl vpnlogon
!
user-role pre-guest
 session-acl http-acl
 session-acl https-acl
 session-acl dhcp-acl
 session-acl dns-acl
!
aaa tacacs-server 10.100.32.137 host 10.100.32.137 key f3c95099412753a7a87f0e10884b3c1f mode disable
aaa derivation-rules user
  set role condition essid equals "Aruba2344" set-value pre-employee 
! 
aaa vpn-authentication default-role default-vpn-role 
aaa mgmt-authentication mode disable
aaa mgmt-authentication auth-server 10.100.32.137
aaa pubcookie-authentication
!
aaa tacacs-accounting auth-server 10.100.32.137 mode enable command all
aaa dot1x enforce-machine-authentication
 mode disable
!
dot1x timeout wpa-key-timeout 1

interface mgmt
	shutdown
!


interface fastethernet 1/0
	description "fe1/0"
	trusted
	switchport trunk allowed vlan 1,3-4094
!

interface fastethernet 1/1
	description "fe1/1"
	trusted
	switchport trunk allowed vlan 1,3-4094
!

interface fastethernet 1/2
	description "fe1/2"
	trusted
!

interface fastethernet 1/3
	description "fe1/3"
	trusted
!

interface fastethernet 1/4
	description "fe1/4"
	trusted
!

interface fastethernet 1/5
	description "fe1/5"
	trusted
!

interface fastethernet 1/6
	description "fe1/6"
	trusted
!

interface fastethernet 1/7
	description "fe1/7"
	trusted
!

interface gigabitethernet  1/8
	description "gig1/8"
	trusted
!

interface vlan 1
	ip address 10.100.26.3 255.255.255.0
!

ip default-gateway 10.100.26.2

country US

ap location 0.0.0
ap-logging level informational snmpd

double-encrypt disable
ap-logging level informational sapd
ap-logging level warnings am
ap-logging level warnings stm
max-imalive-retries 10
bkplms-ip 0.0.0.0
opmode opensystem
mode ap_mode
authalgo opensystem
rts-threshhold 2333
essid "aruba-ap"
tx-power 2
max-retries 4
dtim-period 1
max-clients 64
beacon-period 100
ap-enable enable
power-mgmt enable
ageout 1000
hide-ssid disable
deny-bcast disable
rf-band g
bootstrap-threshold 7
local-probe-response enable
max-tx-fail 0
forward-mode tunnel
native-vlan-id 1
arm assignment disable
arm client-aware enable
arm scanning disable
arm scan-time 110
arm scan-interval 10
arm multi-band-scan disable
arm voip-aware-scan enable
arm max-tx-power 4
arm min-tx-power 0
arm rogue-ap-aware disable
voip call-admission-control disable
voip drop-sip-invite-for-cac disable
voip active-load-balancing disable
voip vocera-call-capacity 10
voip sip-call-capacity 10
voip svp-call-capacity 10
voip sccp-call-capacity 10
voip call-handoff-reservation 20
voip high-capacity-threshold 20
virtual-ap "Aruba2344" vlan-id 1 opmode wpa2-aes-psk deny-bcast enable wpa-passphrase 2c78a9013d4304df23f29859c3a015f2a0811f5f64c3f028 hide-ssid enable dtim-period 1
  phy-type a
    channel 52
    rates 6,12,24
    txrates 6,9,12,18,24,36,48,54
  !
  phy-type g
    short-preamble enable
    channel 1
    rates 1,2
    txrates 1,2,5,11,6,9,12,18,24,36,48,54
    bg-mode mixed
  !
!
ap location 0.0.0
  phy-type enet1
    mode active-standby
    switchport mode access
    switchport access vlan 1
    switchport trunk native vlan 1
    switchport trunk allowed vlan ALL
    trusted disable
  !
!
wms
 general poll-interval 60000
 general poll-retries 2
 general ap-ageout-interval 30
 general sta-ageout-interval 30
 general ap-inactivity-timeout 5
 general sta-inactivity-timeout 60
 general grace-time 2000
 general laser-beam enable
 general laser-beam-debug disable
 general wired-laser-beam disable
 general stat-update enable
 general am-stats-update-interval 0
 ap-policy learn-ap disable
 ap-policy classification enable
 ap-policy protect-unsecure-ap disable
 ap-policy detect-misconfigured-ap disable
 ap-policy protect-misconfigured-ap disable
 ap-policy protect-mt-channel-split disable
 ap-policy protect-mt-ssid disable
 ap-policy detect-ap-impersonation disable
 ap-policy protect-ap-impersonation disable
 ap-policy beacon-diff-threshold 50
 ap-policy beacon-inc-wait-time 3
 ap-policy min-pot-ap-beacon-rate 25
 ap-policy min-pot-ap-monitor-time 3
 ap-policy protect-ibss disable
 ap-policy ap-load-balancing disable
 ap-policy ap-lb-max-retries 8
 ap-policy ap-lb-util-high-wm 90
 ap-policy ap-lb-util-low-wm 80
 ap-policy ap-lb-util-wait-time 30
 ap-policy ap-lb-user-high-wm 255
 ap-policy ap-lb-user-low-wm 230
 ap-policy persistent-known-interfering disable
 ap-config short-preamble enable
 ap-config privacy enable
 ap-config wpa disable
 station-policy protect-valid-sta disable
 station-policy handoff-assist disable
 station-policy rssi-falloff-wait-time 4
 station-policy low-rssi-threshold 20
 station-policy rssi-check-frequency 3
 station-policy detect-association-failure disable
 global-policy detect-bad-wep disable
 global-policy detect-interference disable
 global-policy interference-inc-threshold 100
 global-policy interference-inc-timeout 30
 global-policy interference-wait-time 30
 event-threshold fer-high-wm 0
 event-threshold fer-low-wm 0
 event-threshold frr-high-wm 16
 event-threshold frr-low-wm 8
 event-threshold flsr-high-wm 16
 event-threshold flsr-low-wm 8
 event-threshold fnur-high-wm 0
 event-threshold fnur-low-wm 0
 event-threshold frer-high-wm 16
 event-threshold frer-low-wm 8
 event-threshold ffr-high-wm 16
 event-threshold ffr-low-wm 8
 event-threshold bwr-high-wm 0
 event-threshold bwr-low-wm 0
 valid-11b-channel 1 mode enable
 valid-11b-channel 6 mode enable
 valid-11b-channel 11 mode enable
 valid-11a-channel 36 mode enable
 valid-11a-channel 40 mode enable
 valid-11a-channel 44 mode enable
 valid-11a-channel 48 mode enable
 valid-11a-channel 52 mode enable
 valid-11a-channel 56 mode enable
 valid-11a-channel 60 mode enable
 valid-11a-channel 64 mode enable
 valid-11a-channel 149 mode enable
 valid-11a-channel 153 mode enable
 valid-11a-channel 157 mode enable
 valid-11a-channel 161 mode enable
 ids-policy signature-check disable
 ids-policy rate-check disable
 ids-policy dsta-check disable
 ids-policy sequence-check disable
 ids-policy mac-oui-check disable
 ids-policy eap-check disable
 ids-policy ap-flood-check disable
 ids-policy adhoc-check disable
 ids-policy wbridge-check disable
 ids-policy sequence-diff 300
 ids-policy sequence-time-tolerance 300
 ids-policy sequence-quiet-time 900
 ids-policy eap-rate-threshold 10
 ids-policy eap-rate-time-interval 60
 ids-policy eap-rate-quiet-time 900
 ids-policy ap-flood-threshold 50
 ids-policy ap-flood-inc-time 3
 ids-policy ap-flood-quiet-time 900
 ids-policy signature-quiet-time 900
 ids-policy dsta-quiet-time 900
 ids-policy adhoc-quiet-time 900
 ids-policy wbridge-quiet-time 900
 ids-policy mac-oui-quiet-time 900
 ids-policy rate-frame-type-param assoc channel-threshold 30
 ids-policy rate-frame-type-param assoc channel-inc-time 3
 ids-policy rate-frame-type-param assoc channel-quiet-time 900
 ids-policy rate-frame-type-param assoc node-threshold 30
 ids-policy rate-frame-type-param assoc node-time-interval 60
 ids-policy rate-frame-type-param assoc node-quiet-time 900
 ids-policy rate-frame-type-param disassoc channel-threshold 30
 ids-policy rate-frame-type-param disassoc channel-inc-time 3
 ids-policy rate-frame-type-param disassoc channel-quiet-time 900
 ids-policy rate-frame-type-param disassoc node-threshold 30
 ids-policy rate-frame-type-param disassoc node-time-interval 60
 ids-policy rate-frame-type-param disassoc node-quiet-time 900
 ids-policy rate-frame-type-param deauth channel-threshold 30
 ids-policy rate-frame-type-param deauth channel-inc-time 3
 ids-policy rate-frame-type-param deauth channel-quiet-time 900
 ids-policy rate-frame-type-param deauth node-threshold 20
 ids-policy rate-frame-type-param deauth node-time-interval 60
 ids-policy rate-frame-type-param deauth node-quiet-time 900
 ids-policy rate-frame-type-param probe-request channel-threshold 200
 ids-policy rate-frame-type-param probe-request channel-inc-time 3
 ids-policy rate-frame-type-param probe-request channel-quiet-time 900
 ids-policy rate-frame-type-param probe-request node-threshold 200
 ids-policy rate-frame-type-param probe-request node-time-interval 15
 ids-policy rate-frame-type-param probe-request node-quiet-time 900
 ids-policy rate-frame-type-param probe-response channel-threshold 200
 ids-policy rate-frame-type-param probe-response channel-inc-time 3
 ids-policy rate-frame-type-param probe-response channel-quiet-time 900
 ids-policy rate-frame-type-param probe-response node-threshold 150
 ids-policy rate-frame-type-param probe-response node-time-interval 15
 ids-policy rate-frame-type-param probe-response node-quiet-time 900
 ids-policy rate-frame-type-param auth channel-threshold 30
 ids-policy rate-frame-type-param auth channel-inc-time 3
 ids-policy rate-frame-type-param auth channel-quiet-time 900
 ids-policy rate-frame-type-param auth node-threshold 30
 ids-policy rate-frame-type-param auth node-time-interval 60
 ids-policy rate-frame-type-param auth node-quiet-time 900
 ids-signature "ASLEAP"
   mode enable
   frame-type beacon ssid asleap
 !
 ids-signature "Null-Probe-Response"
   mode enable
   frame-type probe-response ssid-length 0
 !
 ids-signature "AirJack"
   mode enable
   frame-type beacon ssid AirJack
 !
 ids-signature "NetStumbler Generic"
   mode enable
   payload 0x00601d 3
   payload 0x0001 6
 !
 ids-signature "NetStumbler Version 3.3.0x"
   mode enable
   payload 0x00601d 3
   payload 0x000102 12
 !
 ids-signature "Deauth-Broadcast"
   mode enable
   frame-type deauth
   dst-mac ff:ff:ff:ff:ff:ff
 !
!
site-survey calibration-max-packets 256
site-survey calibration-transmit-rate 500
site-survey rra-max-compute-time 600000
site-survey max-ha-neighbors 3
site-survey neighbor-tx-power-bump 2
site-survey ha-compute-time 0


arm min-scan-time 8
arm ideal-coverage-index 5
arm acceptable-coverage-index 2
arm wait-time 15
arm free-channel-index 25
arm backoff-time 240
arm error-rate-threshold 0
arm error-rate-wait-time 30
arm noise-threshold 0
arm noise-wait-time 120

ems server-ip 0.0.0.0

crypto isakmp groupname changeme

vpdn group l2tp
  ppp authentication PAP
!

ip dhcp pool dhcp
 domain-name alterpoint.com
 lease 5 0 0
 network 10.100.26.12 255.255.255.252
!
ip dhcp pool vlan2-pool
 default-router 192.168.2.1
 dns-server 10.10.1.9
 domain-name alterpoint.com
 lease 2 0 0
 network 192.168.2.0 255.255.255.0
 authoritative
!
service dhcp
masterip 127.0.0.1
location "Building1.floor1" 
mobility
  parameters 60 buffer 32
  manager disable
  proxy-dhcp enable
  station-masquerade enable
  on-association disable
  trusted-roam disable
  ignore-l2-broadcast disable
  block-dhcp-release disable
  no new-user-roaming
  max-dhcp-requests 4
  secure 1000 shared-secret 97782bb19f70650ac89c84920c91cd7f
!
mobility-local
  local-ha disable
!
mobagent
  home-agent parameters 1000 bindings 300
  secure-mobile spi 1000 a541c3fbf996edbbcab5d8bb0d378515
  foreign-agent parameters 1100 bindings 300 pending 0 pending-time 300
!

syscontact "microsoft"
snmp-server community public 
vpdn group pptp
  ppp authentication MSCHAPv2
!

stm dos-prevention disable
stm vlan-mobility disable
stm strict-compliance enable
stm fast-roaming disable
stm sta-dos-prevention disable
stm sta-dos-block-time 3600
stm auth-failure-block-time 0
stm coverage-hole-detection disable
stm good-rssi-threshold 20
stm poor-rssi-threshold 10
stm hole-detection-interval 180
stm good-sta-ageout 30
stm idle-sta-ageout 90
stm ap-inactivity-timeout 15

mux-address 0.0.0.0

adp discovery enable
adp igmp-join enable
adp igmp-vlan 0

voip prioritization enable


mgmt-role guest-provisioning
	description "This is a Guest Provisioning Role."
	permit local-userdb read write 
!
mgmt-role root
	description "This is Default Super User Role"
	permit super-user 
!
mgmt-user admin root 30b1ea99bd613b5116f231186a7fdf72
mgmt-user testlab root af43fa2954e9d53826d4ee2422f5f99f


no database synchronize
database synchronize rf-plan-data


ip igmp
!

packet-capture-defaults tcp disable udp disable sysmsg disable other disable
end


END

$responsesAruba->{'startup-config'} = <<'END';
version 2.5
enable secret "ca609fdbcea4b37e99ecffea5fe27ef5"
telnet cli
hostname "Aruba800"
logging level warnings stm
clock timezone CST -6
ip access-list extended 102
  deny any host 99.99.99.99 host 99.99.99.99 
!
netservice svc-snmp-trap udp 162
netservice svc-dhcp udp 67 68
netservice svc-smb-tcp tcp 445
netservice svc-https tcp 443
netservice svc-ike udp 500
netservice svc-l2tp udp 1701
netservice svc-syslog udp 514
netservice svc-pptp tcp 1723
netservice svc-telnet tcp 23
netservice svc-sccp tcp 2000
netservice svc-tftp udp 69
netservice svc-sip-tcp tcp 5060
netservice svc-kerberos udp 88
netservice svc-pop3 tcp 110
netservice svc-adp udp 8200
netservice svc-cfgm-tcp tcp 8211
netservice svc-dns udp 53
netservice svc-msrpc-tcp tcp 135 139
netservice svc-rtsp tcp 554
netservice svc-http tcp 80
netservice svc-vocera udp 5002
netservice svc-nterm tcp 1026 1028
netservice svc-sip-udp udp 5060
netservice svc-papi udp 8211
netservice svc-ftp tcp 21
netservice svc-natt udp 4500
netservice svc-svp 119
netservice svc-gre 47
netservice svc-smtp tcp 25
netservice svc-smb-udp udp 445
netservice svc-esp 50
netservice svc-bootp udp 67 69
netservice svc-snmp udp 161
netservice svc-icmp 1
netservice svc-ntp udp 123
netservice svc-msrpc-udp udp 135 139
netservice svc-ssh tcp 22
ip access-list session control
  user any udp 68 deny 
  any any svc-icmp permit 
  any any svc-dns permit 
  any any svc-papi permit 
  any any svc-cfgm-tcp permit 
  any any svc-adp permit 
  any any svc-tftp permit 
  any any svc-dhcp permit 
  any any svc-natt permit 
!
ip access-list session validuser
  any any any permit 
!
ip access-list session vocera-acl
  any any svc-vocera permit queue high 
!
ip access-list session captiveportal
  user   alias mswitch svc-https dst-nat 
  user any svc-http dst-nat 8080 
  user any svc-https dst-nat 8081 
!
ip access-list session allowall
  any any any permit 
!
ip access-list session sip-acl
  any any svc-sip-udp permit queue high 
  any any svc-sip-tcp permit queue high 
!
ip access-list session https-acl
  any any svc-https permit 
!
ip access-list session dns-acl
  any any svc-dns permit 
!
ip access-list session vpnlogon
  user any svc-ike permit 
  user any svc-esp permit 
  any any svc-l2tp permit 
  any any svc-pptp permit 
  any any svc-gre permit 
!
ip access-list session srcnat
  user any any src-nat 
!
ip access-list session skinny-acl
  any any svc-sccp permit queue high 
!
ip access-list session tftp-acl
  any any svc-tftp permit 
!
ip access-list session cplogout
  user   alias mswitch svc-https dst-nat 
!
ip access-list session guest
!
ip access-list session dhcp-acl
  any any svc-dhcp permit 
!
ip access-list session http-acl
  any any svc-http permit 
!
ip access-list session ap-acl
  any any svc-gre permit 
  any any svc-syslog permit 
  any user svc-snmp permit 
  user any svc-snmp-trap permit 
  user any svc-ntp permit 
!
ip access-list session svp-acl
  any any svc-svp permit queue high 
  user host 224.0.1.116 any permit 
!
vpn-dialer default-dialer
  ike authentication PRE-SHARE 54b558a5c3649b1ebc24c733f8a6b55c61b5f54ea0847a77
!
user-role ap-role
 session-acl control
 session-acl ap-acl
!
user-role pre-employee
 session-acl allowall
!
user-role trusted-ap
 session-acl allowall
!
user-role default-vpn-role
 session-acl allowall
!
user-role guest
 session-acl control
 session-acl cplogout
!
user-role stateful-dot1x
!
user-role stateful
 session-acl control
!
user-role pre-voice
 session-acl sip-acl
 session-acl svp-acl
 session-acl vocera-acl
 session-acl skinny-acl
 session-acl dhcp-acl
 session-acl tftp-acl
 session-acl dns-acl
!
user-role logon
 session-acl control
 session-acl captiveportal
 session-acl vpnlogon
!
user-role pre-guest
 session-acl http-acl
 session-acl https-acl
 session-acl dhcp-acl
 session-acl dns-acl
!
aaa tacacs-server 10.100.32.137 host 10.100.32.137 key c0cf072cc8e3aacf7b7f98eece6d725f mode disable
aaa derivation-rules user
  set role condition essid equals "Aruba2344" set-value pre-employee 
! 
aaa vpn-authentication default-role default-vpn-role 
aaa mgmt-authentication mode disable
aaa mgmt-authentication auth-server 10.100.32.137
aaa pubcookie-authentication
!
aaa tacacs-accounting auth-server 10.100.32.137 mode enable command all
aaa dot1x enforce-machine-authentication
 mode disable
!
dot1x timeout wpa-key-timeout 1

interface mgmt
	shutdown
!


interface fastethernet 1/0
	description "fe1/0"
	trusted
	switchport trunk allowed vlan 1,3-4094
!

interface fastethernet 1/1
	description "fe1/1"
	trusted
	switchport trunk allowed vlan 1,3-4094
!

interface fastethernet 1/2
	description "fe1/2"
	trusted
!

interface fastethernet 1/3
	description "fe1/3"
	trusted
!

interface fastethernet 1/4
	description "fe1/4"
	trusted
!

interface fastethernet 1/5
	description "fe1/5"
	trusted
!

interface fastethernet 1/6
	description "fe1/6"
	trusted
!

interface fastethernet 1/7
	description "fe1/7"
	trusted
!

interface gigabitethernet  1/8
	description "gig1/8"
	trusted
!

interface vlan 1
	ip address 10.100.26.3 255.255.255.0
!

ip default-gateway 10.100.26.2

country US

ap location 0.0.0
ap-logging level informational snmpd

double-encrypt disable
ap-logging level informational sapd
ap-logging level warnings am
ap-logging level warnings stm
max-imalive-retries 10
bkplms-ip 0.0.0.0
opmode opensystem
mode ap_mode
authalgo opensystem
rts-threshhold 2333
essid "aruba-ap"
tx-power 2
max-retries 4
dtim-period 1
max-clients 64
beacon-period 100
ap-enable enable
power-mgmt enable
ageout 1000
hide-ssid disable
deny-bcast disable
rf-band g
bootstrap-threshold 7
local-probe-response enable
max-tx-fail 0
forward-mode tunnel
native-vlan-id 1
arm assignment disable
arm client-aware enable
arm scanning disable
arm scan-time 110
arm scan-interval 10
arm multi-band-scan disable
arm voip-aware-scan enable
arm max-tx-power 4
arm min-tx-power 0
arm rogue-ap-aware disable
voip call-admission-control disable
voip drop-sip-invite-for-cac disable
voip active-load-balancing disable
voip vocera-call-capacity 10
voip sip-call-capacity 10
voip svp-call-capacity 10
voip sccp-call-capacity 10
voip call-handoff-reservation 20
voip high-capacity-threshold 20
virtual-ap "Aruba2344" vlan-id 1 opmode wpa2-aes-psk deny-bcast enable wpa-passphrase ee4ceac1a5db889c1654d11089ddefe93119742de676c097 hide-ssid enable dtim-period 1
  phy-type a
    channel 52
    rates 6,12,24
    txrates 6,9,12,18,24,36,48,54
  !
  phy-type g
    short-preamble enable
    channel 1
    rates 1,2
    txrates 1,2,5,11,6,9,12,18,24,36,48,54
    bg-mode mixed
  !
!
ap location 0.0.0
  phy-type enet1
    mode active-standby
    switchport mode access
    switchport access vlan 1
    switchport trunk native vlan 1
    switchport trunk allowed vlan ALL
    trusted disable
  !
!
wms
 general poll-interval 60000
 general poll-retries 2
 general ap-ageout-interval 30
 general sta-ageout-interval 30
 general ap-inactivity-timeout 5
 general sta-inactivity-timeout 60
 general grace-time 2000
 general laser-beam enable
 general laser-beam-debug disable
 general wired-laser-beam disable
 general stat-update enable
 general am-stats-update-interval 0
 ap-policy learn-ap disable
 ap-policy classification enable
 ap-policy protect-unsecure-ap disable
 ap-policy detect-misconfigured-ap disable
 ap-policy protect-misconfigured-ap disable
 ap-policy protect-mt-channel-split disable
 ap-policy protect-mt-ssid disable
 ap-policy detect-ap-impersonation disable
 ap-policy protect-ap-impersonation disable
 ap-policy beacon-diff-threshold 50
 ap-policy beacon-inc-wait-time 3
 ap-policy min-pot-ap-beacon-rate 25
 ap-policy min-pot-ap-monitor-time 3
 ap-policy protect-ibss disable
 ap-policy ap-load-balancing disable
 ap-policy ap-lb-max-retries 8
 ap-policy ap-lb-util-high-wm 90
 ap-policy ap-lb-util-low-wm 80
 ap-policy ap-lb-util-wait-time 30
 ap-policy ap-lb-user-high-wm 255
 ap-policy ap-lb-user-low-wm 230
 ap-policy persistent-known-interfering disable
 ap-config short-preamble enable
 ap-config privacy enable
 ap-config wpa disable
 station-policy protect-valid-sta disable
 station-policy handoff-assist disable
 station-policy rssi-falloff-wait-time 4
 station-policy low-rssi-threshold 20
 station-policy rssi-check-frequency 3
 station-policy detect-association-failure disable
 global-policy detect-bad-wep disable
 global-policy detect-interference disable
 global-policy interference-inc-threshold 100
 global-policy interference-inc-timeout 30
 global-policy interference-wait-time 30
 event-threshold fer-high-wm 0
 event-threshold fer-low-wm 0
 event-threshold frr-high-wm 16
 event-threshold frr-low-wm 8
 event-threshold flsr-high-wm 16
 event-threshold flsr-low-wm 8
 event-threshold fnur-high-wm 0
 event-threshold fnur-low-wm 0
 event-threshold frer-high-wm 16
 event-threshold frer-low-wm 8
 event-threshold ffr-high-wm 16
 event-threshold ffr-low-wm 8
 event-threshold bwr-high-wm 0
 event-threshold bwr-low-wm 0
 valid-11b-channel 1 mode enable
 valid-11b-channel 6 mode enable
 valid-11b-channel 11 mode enable
 valid-11a-channel 36 mode enable
 valid-11a-channel 40 mode enable
 valid-11a-channel 44 mode enable
 valid-11a-channel 48 mode enable
 valid-11a-channel 52 mode enable
 valid-11a-channel 56 mode enable
 valid-11a-channel 60 mode enable
 valid-11a-channel 64 mode enable
 valid-11a-channel 149 mode enable
 valid-11a-channel 153 mode enable
 valid-11a-channel 157 mode enable
 valid-11a-channel 161 mode enable
 ids-policy signature-check disable
 ids-policy rate-check disable
 ids-policy dsta-check disable
 ids-policy sequence-check disable
 ids-policy mac-oui-check disable
 ids-policy eap-check disable
 ids-policy ap-flood-check disable
 ids-policy adhoc-check disable
 ids-policy wbridge-check disable
 ids-policy sequence-diff 300
 ids-policy sequence-time-tolerance 300
 ids-policy sequence-quiet-time 900
 ids-policy eap-rate-threshold 10
 ids-policy eap-rate-time-interval 60
 ids-policy eap-rate-quiet-time 900
 ids-policy ap-flood-threshold 50
 ids-policy ap-flood-inc-time 3
 ids-policy ap-flood-quiet-time 900
 ids-policy signature-quiet-time 900
 ids-policy dsta-quiet-time 900
 ids-policy adhoc-quiet-time 900
 ids-policy wbridge-quiet-time 900
 ids-policy mac-oui-quiet-time 900
 ids-policy rate-frame-type-param assoc channel-threshold 30
 ids-policy rate-frame-type-param assoc channel-inc-time 3
 ids-policy rate-frame-type-param assoc channel-quiet-time 900
 ids-policy rate-frame-type-param assoc node-threshold 30
 ids-policy rate-frame-type-param assoc node-time-interval 60
 ids-policy rate-frame-type-param assoc node-quiet-time 900
 ids-policy rate-frame-type-param disassoc channel-threshold 30
 ids-policy rate-frame-type-param disassoc channel-inc-time 3
 ids-policy rate-frame-type-param disassoc channel-quiet-time 900
 ids-policy rate-frame-type-param disassoc node-threshold 30
 ids-policy rate-frame-type-param disassoc node-time-interval 60
 ids-policy rate-frame-type-param disassoc node-quiet-time 900
 ids-policy rate-frame-type-param deauth channel-threshold 30
 ids-policy rate-frame-type-param deauth channel-inc-time 3
 ids-policy rate-frame-type-param deauth channel-quiet-time 900
 ids-policy rate-frame-type-param deauth node-threshold 20
 ids-policy rate-frame-type-param deauth node-time-interval 60
 ids-policy rate-frame-type-param deauth node-quiet-time 900
 ids-policy rate-frame-type-param probe-request channel-threshold 200
 ids-policy rate-frame-type-param probe-request channel-inc-time 3
 ids-policy rate-frame-type-param probe-request channel-quiet-time 900
 ids-policy rate-frame-type-param probe-request node-threshold 200
 ids-policy rate-frame-type-param probe-request node-time-interval 15
 ids-policy rate-frame-type-param probe-request node-quiet-time 900
 ids-policy rate-frame-type-param probe-response channel-threshold 200
 ids-policy rate-frame-type-param probe-response channel-inc-time 3
 ids-policy rate-frame-type-param probe-response channel-quiet-time 900
 ids-policy rate-frame-type-param probe-response node-threshold 150
 ids-policy rate-frame-type-param probe-response node-time-interval 15
 ids-policy rate-frame-type-param probe-response node-quiet-time 900
 ids-policy rate-frame-type-param auth channel-threshold 30
 ids-policy rate-frame-type-param auth channel-inc-time 3
 ids-policy rate-frame-type-param auth channel-quiet-time 900
 ids-policy rate-frame-type-param auth node-threshold 30
 ids-policy rate-frame-type-param auth node-time-interval 60
 ids-policy rate-frame-type-param auth node-quiet-time 900
 ids-signature "ASLEAP"
   mode enable
   frame-type beacon ssid asleap
 !
 ids-signature "Null-Probe-Response"
   mode enable
   frame-type probe-response ssid-length 0
 !
 ids-signature "AirJack"
   mode enable
   frame-type beacon ssid AirJack
 !
 ids-signature "NetStumbler Generic"
   mode enable
   payload 0x00601d 3
   payload 0x0001 6
 !
 ids-signature "NetStumbler Version 3.3.0x"
   mode enable
   payload 0x00601d 3
   payload 0x000102 12
 !
 ids-signature "Deauth-Broadcast"
   mode enable
   frame-type deauth
   dst-mac ff:ff:ff:ff:ff:ff
 !
!
site-survey calibration-max-packets 256
site-survey calibration-transmit-rate 500
site-survey rra-max-compute-time 600000
site-survey max-ha-neighbors 3
site-survey neighbor-tx-power-bump 2
site-survey ha-compute-time 0


arm min-scan-time 8
arm ideal-coverage-index 5
arm acceptable-coverage-index 2
arm wait-time 15
arm free-channel-index 25
arm backoff-time 240
arm error-rate-threshold 0
arm error-rate-wait-time 30
arm noise-threshold 0
arm noise-wait-time 120

ems server-ip 0.0.0.0

crypto isakmp groupname changeme

vpdn group l2tp
  ppp authentication PAP
!

ip dhcp pool dhcp
 domain-name alterpoint.com
 lease 5 0 0
 network 10.100.26.12 255.255.255.252
!
ip dhcp pool vlan2-pool
 default-router 192.168.2.1
 dns-server 10.10.1.9
 domain-name alterpoint.com
 lease 2 0 0
 network 192.168.2.0 255.255.255.0
 authoritative
!
service dhcp
masterip 127.0.0.1
location "Building1.floor1" 
mobility
  parameters 60 buffer 32
  manager disable
  proxy-dhcp enable
  station-masquerade enable
  on-association disable
  trusted-roam disable
  ignore-l2-broadcast disable
  block-dhcp-release disable
  no new-user-roaming
  max-dhcp-requests 4
  secure 1000 shared-secret 2814f7bff0de0edf63501c9bafe17a74
!
mobility-local
  local-ha disable
!
mobagent
  home-agent parameters 1000 bindings 300
  secure-mobile spi 1000 554fbba3fea347d95a01dcd385186ccd
  foreign-agent parameters 1100 bindings 300 pending 0 pending-time 300
!

syscontact "microsoft"
snmp-server community public 
vpdn group pptp
  ppp authentication MSCHAPv2
!

stm dos-prevention disable
stm vlan-mobility disable
stm strict-compliance enable
stm fast-roaming disable
stm sta-dos-prevention disable
stm sta-dos-block-time 3600
stm auth-failure-block-time 0
stm coverage-hole-detection disable
stm good-rssi-threshold 20
stm poor-rssi-threshold 10
stm hole-detection-interval 180
stm good-sta-ageout 30
stm idle-sta-ageout 90
stm ap-inactivity-timeout 15

mux-address 0.0.0.0

adp discovery enable
adp igmp-join enable
adp igmp-vlan 0

voip prioritization enable


mgmt-role guest-provisioning
	description "This is a Guest Provisioning Role."
	permit local-userdb read write 
!
mgmt-role root
	description "This is Default Super User Role"
	permit super-user 
!
mgmt-user admin root 4278d6d4cafed15ef97da2f3c6858b0d
mgmt-user testlab root 47dd2e765019bfbc401c10a836247edc


no database synchronize
database synchronize rf-plan-data


ip igmp
!

packet-capture-defaults tcp disable udp disable sysmsg disable other disable
end


END

$responsesAruba->{destination} = <<'END';
show netdestination

user
----
Position  Type     IP addr           Mask/Range
--------  ----     -------           ----------
1         network  255.255.255.255   0.0.0.0

mswitch
-------
Position  Type  IP addr       Mask/Range
--------  ----  -------       ----------
1         host  10.100.26.3    

any
---
Position  Type     IP addr   Mask/Range
--------  ----     -------   ----------
1         network  0.0.0.0   0.0.0.0


(Aruba800) #

END

$responsesAruba->{netservice} = <<'END';
show netservice

Services
--------
Name           Protocol  Ports      ALG
----           --------  -----      ---
svc-snmp-trap  udp       162        
svc-dhcp       udp       67 68      
svc-smb-tcp    tcp       445        
svc-https      tcp       443        
svc-ike        udp       500        
svc-l2tp       udp       1701       
svc-syslog     udp       514        
svc-pptp       tcp       1723       
svc-telnet     tcp       23         
svc-sccp       tcp       2000       
svc-tftp       udp       69         
svc-sip-tcp    tcp       5060       
svc-kerberos   udp       88         
svc-pop3       tcp       110        
svc-adp        udp       8200       
svc-cfgm-tcp   tcp       8211       
svc-dns        udp       53         
svc-msrpc-tcp  tcp       135 139    
svc-rtsp       tcp       554        
svc-http       tcp       80         
svc-vocera     udp       5002       
svc-nterm      tcp       1026 1028  
svc-sip-udp    udp       5060       
svc-papi       udp       8211       
svc-ftp        tcp       21         
svc-natt       udp       4500       
svc-svp        119       0          
svc-gre        gre       0          
svc-smtp       tcp       25         
svc-smb-udp    udp       445        
svc-esp        esp       0          
svc-bootp      udp       67 69      
svc-snmp       udp       161        
svc-icmp       icmp      0          
svc-ntp        udp       123        
svc-msrpc-udp  udp       135 139    
svc-ssh        tcp       22         
any            any       0          

(Aruba800) #

END

$responsesAruba->{acls} = <<'END';
show access-list brief

Access list table
-----------------
Name               Type      Use Count  Roles
----               ----      ---------  -----
control            session   4          ap-role guest stateful logon 
validuser          session   0          
vocera-acl         session   1          pre-voice 
mkisthmus          standard             
102                extended             
captiveportal      session   1          logon 
allowall           session   3          pre-employee trusted-ap default-vpn-role 
sip-acl            session   1          pre-voice 
https-acl          session   1          pre-guest 
dns-acl            session   2          pre-voice pre-guest 
mkisthmus1         session   0          
vpnlogon           session   1          logon 
srcnat             session   0          
skinny-acl         session   1          pre-voice 
tftp-acl           session   1          pre-voice 
cplogout           session   1          guest 
guest              session   0          
dhcp-acl           session   2          pre-voice pre-guest 
http-acl           session   1          pre-guest 
stateful-dot1x     session   0          
ap-acl             session   1          ap-role 
svp-acl            session   1          pre-voice 
stateful-kerberos  session   0          

(Aruba800) #

END

$responsesAruba->{'acl_control'} = <<'END';
show access-list control

ip access-list session control
control
-------
Priority  Source  Destination  Service       Action  TimeRange  Log  Expired  Queue  TOS  8021P  Blacklist  Mirror
--------  ------  -----------  -------       ------  ---------  ---  -------  -----  ---  -----  ---------  ------
1         user    any          udp 68        deny                             Low                            
2         any     any          svc-icmp      permit                           Low                            
3         any     any          svc-dns       permit                           Low                            
4         any     any          svc-papi      permit                           Low                            
5         any     any          svc-cfgm-tcp  permit                           Low                            
6         any     any          svc-adp       permit                           Low                            
7         any     any          svc-tftp      permit                           Low                            
8         any     any          svc-dhcp      permit                           Low                            
9         any     any          svc-natt      permit                           Low                            


(Aruba800) #

END

$responsesAruba->{'acl_validuser'} = <<'END';
show access-list validuser

ip access-list session validuser
validuser
---------
Priority  Source  Destination  Service  Action  TimeRange  Log  Expired  Queue  TOS  8021P  Blacklist  Mirror
--------  ------  -----------  -------  ------  ---------  ---  -------  -----  ---  -----  ---------  ------
1         any     any          any      permit                           Low                            


(Aruba800) #

END

$responsesAruba->{'acl_vocera-acl'} = <<'END';
show access-list vocera-acl

ip access-list session vocera-acl
vocera-acl
----------
Priority  Source  Destination  Service     Action  TimeRange  Log  Expired  Queue  TOS  8021P  Blacklist  Mirror
--------  ------  -----------  -------     ------  ---------  ---  -------  -----  ---  -----  ---------  ------
1         any     any          svc-vocera  permit                           High                           


(Aruba800) #

END

$responsesAruba->{'acl_mkisthmus'} = <<'END';
show access-list mkisthmus

ip access-list standard mkisthmus
  permit 10.0.0.0 0.255.255.255 


(Aruba800) #

END

$responsesAruba->{'acl_102'} = <<'END';
show access-list 102

ip access-list extended 102
  deny 0 host 99.99.99.99 host 99.99.99.99 


(Aruba800) #

END

$responsesAruba->{'acl_captiveportal'} = <<'END';
show access-list captiveportal

ip access-list session captiveportal
captiveportal
-------------
Priority  Source  Destination  Service    Action        TimeRange  Log  Expired  Queue  TOS  8021P  Blacklist  Mirror
--------  ------  -----------  -------    ------        ---------  ---  -------  -----  ---  -----  ---------  ------
1         user    mswitch      svc-https  dst-nat                                Low                            
2         user    any          svc-http   dst-nat 8080                           Low                            
3         user    any          svc-https  dst-nat 8081                           Low                            


(Aruba800) #

END

$responsesAruba->{'acl_allowall'} = <<'END';
show access-list allowall

ip access-list session allowall
allowall
--------
Priority  Source  Destination  Service  Action  TimeRange  Log  Expired  Queue  TOS  8021P  Blacklist  Mirror
--------  ------  -----------  -------  ------  ---------  ---  -------  -----  ---  -----  ---------  ------
1         any     any          any      permit                           Low                            


(Aruba800) #

END

$responsesAruba->{'acl_sip-acl'} = <<'END';
show access-list sip-acl

ip access-list session sip-acl
sip-acl
-------
Priority  Source  Destination  Service      Action  TimeRange  Log  Expired  Queue  TOS  8021P  Blacklist  Mirror
--------  ------  -----------  -------      ------  ---------  ---  -------  -----  ---  -----  ---------  ------
1         any     any          svc-sip-udp  permit                           High                           
2         any     any          svc-sip-tcp  permit                           High                           


(Aruba800) #

END

$responsesAruba->{'acl_https-acl'} = <<'END';
show access-list https-acl

ip access-list session https-acl
https-acl
---------
Priority  Source  Destination  Service    Action  TimeRange  Log  Expired  Queue  TOS  8021P  Blacklist  Mirror
--------  ------  -----------  -------    ------  ---------  ---  -------  -----  ---  -----  ---------  ------
1         any     any          svc-https  permit                           Low                            


(Aruba800) #

END

$responsesAruba->{'acl_dns-acl'} = <<'END';
show access-list dns-acl

ip access-list session dns-acl
dns-acl
-------
Priority  Source  Destination  Service  Action  TimeRange  Log  Expired  Queue  TOS  8021P  Blacklist  Mirror
--------  ------  -----------  -------  ------  ---------  ---  -------  -----  ---  -----  ---------  ------
1         any     any          svc-dns  permit                           Low                            


(Aruba800) #

END

$responsesAruba->{'acl_mkisthmus1'} = <<'END';
show access-list mkisthmus1

ip access-list session mkisthmus1
mkisthmus1
----------
Priority  Source  Destination  Service  Action   TimeRange  Log  Expired  Queue  TOS  8021P  Blacklist  Mirror
--------  ------  -----------  -------  ------   ---------  ---  -------  -----  ---  -----  ---------  ------
1         any     any          any      src-nat             Yes           Low                            


(Aruba800) #

END

$responsesAruba->{'acl_vpnlogon'} = <<'END';
show access-list vpnlogon

ip access-list session vpnlogon
vpnlogon
--------
Priority  Source  Destination  Service   Action  TimeRange  Log  Expired  Queue  TOS  8021P  Blacklist  Mirror
--------  ------  -----------  -------   ------  ---------  ---  -------  -----  ---  -----  ---------  ------
1         user    any          svc-ike   permit                           Low                            
2         user    any          svc-esp   permit                           Low                            
3         any     any          svc-l2tp  permit                           Low                            
4         any     any          svc-pptp  permit                           Low                            
5         any     any          svc-gre   permit                           Low                            


(Aruba800) #

END

$responsesAruba->{'acl_srcnat'} = <<'END';
show access-list srcnat

ip access-list session srcnat
srcnat
------
Priority  Source  Destination  Service  Action   TimeRange  Log  Expired  Queue  TOS  8021P  Blacklist  Mirror
--------  ------  -----------  -------  ------   ---------  ---  -------  -----  ---  -----  ---------  ------
1         user    any          any      src-nat                           Low                            


(Aruba800) #

END

$responsesAruba->{'acl_skinny-acl'} = <<'END';
show access-list skinny-acl

ip access-list session skinny-acl
skinny-acl
----------
Priority  Source  Destination  Service   Action  TimeRange  Log  Expired  Queue  TOS  8021P  Blacklist  Mirror
--------  ------  -----------  -------   ------  ---------  ---  -------  -----  ---  -----  ---------  ------
1         any     any          svc-sccp  permit                           High                           


(Aruba800) #

END

$responsesAruba->{'acl_tftp-acl'} = <<'END';
show access-list tftp-acl

ip access-list session tftp-acl
tftp-acl
--------
Priority  Source  Destination  Service   Action  TimeRange  Log  Expired  Queue  TOS  8021P  Blacklist  Mirror
--------  ------  -----------  -------   ------  ---------  ---  -------  -----  ---  -----  ---------  ------
1         any     any          svc-tftp  permit                           Low                            


(Aruba800) #

END

$responsesAruba->{'acl_cplogout'} = <<'END';
show access-list cplogout

ip access-list session cplogout
cplogout
--------
Priority  Source  Destination  Service    Action   TimeRange  Log  Expired  Queue  TOS  8021P  Blacklist  Mirror
--------  ------  -----------  -------    ------   ---------  ---  -------  -----  ---  -----  ---------  ------
1         user    mswitch      svc-https  dst-nat                           Low                            


(Aruba800) #

END

$responsesAruba->{'acl_guest'} = <<'END';
show access-list guest

ip access-list session guest
guest
-----
Priority  Source  Destination  Service  Action  TimeRange  Log  Expired  Queue  TOS  8021P  Blacklist  Mirror
--------  ------  -----------  -------  ------  ---------  ---  -------  -----  ---  -----  ---------  ------


(Aruba800) #

END

$responsesAruba->{'acl_dhcp-acl'} = <<'END';
show access-list dhcp-acl

ip access-list session dhcp-acl
dhcp-acl
--------
Priority  Source  Destination  Service   Action  TimeRange  Log  Expired  Queue  TOS  8021P  Blacklist  Mirror
--------  ------  -----------  -------   ------  ---------  ---  -------  -----  ---  -----  ---------  ------
1         any     any          svc-dhcp  permit                           Low                            


(Aruba800) #

END

$responsesAruba->{'acl_http-acl'} = <<'END';
show access-list http-acl

ip access-list session http-acl
http-acl
--------
Priority  Source  Destination  Service   Action  TimeRange  Log  Expired  Queue  TOS  8021P  Blacklist  Mirror
--------  ------  -----------  -------   ------  ---------  ---  -------  -----  ---  -----  ---------  ------
1         any     any          svc-http  permit                           Low                            


(Aruba800) #

END

$responsesAruba->{'acl_stateful-dot1x'} = <<'END';
show access-list stateful-dot1x

ip access-list session stateful-dot1x
stateful-dot1x
--------------
Priority  Source  Destination  Service  Action  TimeRange  Log  Expired  Queue  TOS  8021P  Blacklist  Mirror
--------  ------  -----------  -------  ------  ---------  ---  -------  -----  ---  -----  ---------  ------


(Aruba800) #

END

$responsesAruba->{'acl_ap-acl'} = <<'END';
show access-list ap-acl

ip access-list session ap-acl
ap-acl
------
Priority  Source  Destination  Service        Action  TimeRange  Log  Expired  Queue  TOS  8021P  Blacklist  Mirror
--------  ------  -----------  -------        ------  ---------  ---  -------  -----  ---  -----  ---------  ------
1         any     any          svc-gre        permit                           Low                            
2         any     any          svc-syslog     permit                           Low                            
3         any     user         svc-snmp       permit                           Low                            
4         user    any          svc-snmp-trap  permit                           Low                            
5         user    any          svc-ntp        permit                           Low                            


(Aruba800) #

END

$responsesAruba->{'acl_svp-acl'} = <<'END';
show access-list svp-acl

ip access-list session svp-acl
svp-acl
-------
Priority  Source  Destination  Service  Action  TimeRange  Log  Expired  Queue  TOS  8021P  Blacklist  Mirror
--------  ------  -----------  -------  ------  ---------  ---  -------  -----  ---  -----  ---------  ------
1         any     any          svc-svp  permit                           High                           
2         user    224.0.1.116  any      permit                           Low                            


(Aruba800) #

END

$responsesAruba->{'acl_stateful-kerberos'} = <<'END';
show access-list stateful-kerberos

ip access-list session stateful-kerberos
stateful-kerberos
-----------------
Priority  Source  Destination  Service       Action              TimeRange  Log  Expired  Queue  TOS  8021P  Blacklist  Mirror
--------  ------  -----------  -------       ------              ---------  ---  -------  -----  ---  -----  ---------  ------
1         any     any          svc-kerberos  redirect opcode 51                           Low                            


(Aruba800) #

END

$responsesAruba->{span_tree} = <<'END';
show spantree

Designated Root MAC       00:01:63:bb:c3:4a
Designated Root Priority  32768
Root Max Age 20 sec   Hello Time 2 sec   Forward Delay 15 sec

Bridge MAC                00:0b:86:50:38:90
Bridge Priority           32768
Configured Max Age 20 sec   Hello Time 2 sec   Forward Delay 15 sec

Spanning-Tree port configuration
--------------------------------
Port     State       Cost  Prio  PortFast
----     -----       ----  ----  --------
Fa 1/0   Disable     0     128   Disable
Fa 1/1   Disable     0     128   Disable
Fa 1/2   Disable     0     128   Disable
Fa 1/3   Disable     0     128   Disable
Fa 1/4   Disable     0     128   Disable
Fa 1/5   Disable     0     128   Disable
Fa 1/6   Disable     0     128   Disable
Fa 1/7   Disable     0     128   Disable
Gig 1/8  Forwarding  19    128   Disable

(Aruba800) #

END

$responsesAruba->{'if-mgmt'} = <<'END';
show interface mgmt
Management Interface is not supported on this platform

(Aruba800) #

END

$responsesAruba->{'if-fastethernet-1/0'} = <<'END';
show interface fastethernet 1/0

Fa 1/0 is up, line protocol is down
Hardware is FastEthernet, address is 00:0B:86:50:38:91 (bia 00:0B:86:50:38:91)
Description: fe1/0
Encapsulation ARPA, loopback not set
Configured: Duplex ( AUTO ), speed ( AUTO )
MTU 1500 bytes, BW is 100 Mbit
Last clearing of "show interface" counters 195 day 12 hr 41 min 1 sec 
link status last changed 177 day 11 hr 55 min 43 sec 
    219798 packets input, 41939370 bytes
    Received 116073 broadcasts, 0 runts, 0 giants, 0 throttles
    0 input error bytes, 0 CRC, 0 frame
    0 multicast, 103725 unicast
    567093 packets output, 81043410 bytes
    0 output errors bytes, 0 deferred
    0 collisions, 0 late collisions, 0 throttles
This port is TRUSTED 
POE Status of the port is OFF 

(Aruba800) #

END

$responsesAruba->{'if-fastethernet-1/1'} = <<'END';
show interface fastethernet 1/1

Fa 1/1 is up, line protocol is down
Hardware is FastEthernet, address is 00:0B:86:50:38:92 (bia 00:0B:86:50:38:92)
Description: fe1/1
Encapsulation ARPA, loopback not set
Configured: Duplex ( AUTO ), speed ( AUTO )
MTU 1500 bytes, BW is 100 Mbit
Last clearing of "show interface" counters 195 day 12 hr 41 min 2 sec 
link status last changed 177 day 11 hr 55 min 48 sec 
    219779 packets input, 41934965 bytes
    Received 116061 broadcasts, 0 runts, 0 giants, 0 throttles
    0 input error bytes, 0 CRC, 0 frame
    0 multicast, 103718 unicast
    567024 packets output, 81038592 bytes
    0 output errors bytes, 0 deferred
    0 collisions, 0 late collisions, 0 throttles
This port is TRUSTED 
POE Status of the port is OFF 

(Aruba800) #

END

$responsesAruba->{'if-fastethernet-1/2'} = <<'END';
show interface fastethernet 1/2

Fa 1/2 is up, line protocol is down
Hardware is FastEthernet, address is 00:0B:86:50:38:93 (bia 00:0B:86:50:38:93)
Description: fe1/2
Encapsulation ARPA, loopback not set
Configured: Duplex ( AUTO ), speed ( AUTO )
MTU 1500 bytes, BW is 100 Mbit
Last clearing of "show interface" counters 195 day 12 hr 41 min 2 sec 
link status last changed 195 day 12 hr 41 min 2 sec 
    0 packets input, 0 bytes
    Received 0 broadcasts, 0 runts, 0 giants, 0 throttles
    0 input error bytes, 0 CRC, 0 frame
    0 multicast, 0 unicast
    0 packets output, 0 bytes
    0 output errors bytes, 0 deferred
    0 collisions, 0 late collisions, 0 throttles
This port is TRUSTED 
POE Status of the port is OFF 

(Aruba800) #

END

$responsesAruba->{'if-fastethernet-1/3'} = <<'END';
show interface fastethernet 1/3

Fa 1/3 is up, line protocol is down
Hardware is FastEthernet, address is 00:0B:86:50:38:94 (bia 00:0B:86:50:38:94)
Description: fe1/3
Encapsulation ARPA, loopback not set
Configured: Duplex ( AUTO ), speed ( AUTO )
MTU 1500 bytes, BW is 100 Mbit
Last clearing of "show interface" counters 195 day 12 hr 41 min 3 sec 
link status last changed 195 day 12 hr 41 min 3 sec 
    0 packets input, 0 bytes
    Received 0 broadcasts, 0 runts, 0 giants, 0 throttles
    0 input error bytes, 0 CRC, 0 frame
    0 multicast, 0 unicast
    0 packets output, 0 bytes
    0 output errors bytes, 0 deferred
    0 collisions, 0 late collisions, 0 throttles
This port is TRUSTED 
POE Status of the port is OFF 

(Aruba800) #

END

$responsesAruba->{'if-fastethernet-1/4'} = <<'END';
show interface fastethernet 1/4

Fa 1/4 is up, line protocol is down
Hardware is FastEthernet, address is 00:0B:86:50:38:95 (bia 00:0B:86:50:38:95)
Description: fe1/4
Encapsulation ARPA, loopback not set
Configured: Duplex ( AUTO ), speed ( AUTO )
MTU 1500 bytes, BW is 100 Mbit
Last clearing of "show interface" counters 195 day 12 hr 41 min 3 sec 
link status last changed 195 day 12 hr 41 min 3 sec 
    0 packets input, 0 bytes
    Received 0 broadcasts, 0 runts, 0 giants, 0 throttles
    0 input error bytes, 0 CRC, 0 frame
    0 multicast, 0 unicast
    0 packets output, 0 bytes
    0 output errors bytes, 0 deferred
    0 collisions, 0 late collisions, 0 throttles
This port is TRUSTED 
POE Status of the port is OFF 

(Aruba800) #

END

$responsesAruba->{'if-fastethernet-1/5'} = <<'END';
show interface fastethernet 1/5

Fa 1/5 is up, line protocol is down
Hardware is FastEthernet, address is 00:0B:86:50:38:96 (bia 00:0B:86:50:38:96)
Description: fe1/5
Encapsulation ARPA, loopback not set
Configured: Duplex ( AUTO ), speed ( AUTO )
MTU 1500 bytes, BW is 100 Mbit
Last clearing of "show interface" counters 195 day 12 hr 41 min 4 sec 
link status last changed 195 day 12 hr 41 min 4 sec 
    0 packets input, 0 bytes
    Received 0 broadcasts, 0 runts, 0 giants, 0 throttles
    0 input error bytes, 0 CRC, 0 frame
    0 multicast, 0 unicast
    0 packets output, 0 bytes
    0 output errors bytes, 0 deferred
    0 collisions, 0 late collisions, 0 throttles
This port is TRUSTED 
POE Status of the port is OFF 

(Aruba800) #

END

$responsesAruba->{'if-fastethernet-1/6'} = <<'END';
show interface fastethernet 1/6

Fa 1/6 is up, line protocol is down
Hardware is FastEthernet, address is 00:0B:86:50:38:97 (bia 00:0B:86:50:38:97)
Description: fe1/6
Encapsulation ARPA, loopback not set
Configured: Duplex ( AUTO ), speed ( AUTO )
MTU 1500 bytes, BW is 100 Mbit
Last clearing of "show interface" counters 195 day 12 hr 41 min 4 sec 
link status last changed 195 day 12 hr 41 min 4 sec 
    0 packets input, 0 bytes
    Received 0 broadcasts, 0 runts, 0 giants, 0 throttles
    0 input error bytes, 0 CRC, 0 frame
    0 multicast, 0 unicast
    0 packets output, 0 bytes
    0 output errors bytes, 0 deferred
    0 collisions, 0 late collisions, 0 throttles
This port is TRUSTED 
POE Status of the port is OFF 

(Aruba800) #

END

$responsesAruba->{'if-fastethernet-1/7'} = <<'END';
show interface fastethernet 1/7

Fa 1/7 is up, line protocol is down
Hardware is FastEthernet, address is 00:0B:86:50:38:98 (bia 00:0B:86:50:38:98)
Description: fe1/7
Encapsulation ARPA, loopback not set
Configured: Duplex ( AUTO ), speed ( AUTO )
MTU 1500 bytes, BW is 100 Mbit
Last clearing of "show interface" counters 195 day 12 hr 41 min 4 sec 
link status last changed 195 day 12 hr 41 min 4 sec 
    0 packets input, 0 bytes
    Received 0 broadcasts, 0 runts, 0 giants, 0 throttles
    0 input error bytes, 0 CRC, 0 frame
    0 multicast, 0 unicast
    0 packets output, 0 bytes
    0 output errors bytes, 0 deferred
    0 collisions, 0 late collisions, 0 throttles
This port is TRUSTED 
POE Status of the port is OFF 

(Aruba800) #

END

$responsesAruba->{'if-gigabitethernet-1/8'} = <<'END';
show interface gigabitethernet 1/8

Gig 1/8 is up, line protocol is up
Hardware is Gigabit Ethernet, address is 00:0B:86:50:38:99 (bia 00:0B:86:50:38:99)
Description: gig1/8
Encapsulation ARPA, loopback not set
Configured: Duplex ( AUTO ), speed ( AUTO )
Negotiated: Duplex (Full), speed (100 Mbps)
MTU 1500 bytes, BW is 100 Mbit
Last clearing of "show interface" counters 195 day 12 hr 41 min 5 sec 
link status last changed 195 day 12 hr 40 min 9 sec 
    17388987 packets input, 1691907541 bytes
    Received 13952508 broadcasts, 0 runts, 0 giants, 0 throttles
    0 input error bytes, 0 CRC, 0 frame
    13723261 multicast, 3436479 unicast
    1452468 packets output, 301384367 bytes
    0 output errors bytes, 0 deferred
    0 collisions, 0 late collisions, 0 throttles
This port is TRUSTED 

(Aruba800) #

END

$responsesAruba->{'if-vlan-1'} = <<'END';
show interface vlan 1

VLAN1 is up line protocol is up
Hardware is CPU Interface, Interface address is 00:0B:86:50:38:90 (bia 00:0B:86:50:38:90)
Description: 802.1Q VLAN
Internet address is 10.100.26.3  255.255.255.0 
Routing interface is enable, Forwarding mode is enabled 
Directed broadcast is disabled
Encapsulation 802, loopback not set
MTU 1500 bytes
Last clearing of "show interface" counters 195 day 12 hr 41 min 5 sec 
link status last changed 195 day 12 hr 39 min 39 sec 

(Aruba800) #

END

$responsesAruba->{snmp_comm} = <<'END';
show snmp community

SNMP COMMUNITIES
----------------
COMMUNITY  ACCESS     VERSION
---------  ------     -------
 public    READ_ONLY  V1, V2c

(Aruba800) #

END

$responsesAruba->{ip_route} = <<'END';
show ip route

Codes: C - connected, O - OSPF, R - RIP, S - static
       M - mgmt, U - route usable, * - candidate default

Gateway of last resort is 10.100.26.2 to network 0.0.0.0

S*    0.0.0.0/0  [0/0] via 10.100.26.2*
C    10.100.26.0 is directly connected, VLAN1

(Aruba800) #

END

$responsesAruba->{vlans} = <<'END';
show vlan

VLAN CONFIGURATION
------------------
VLAN  Name      Ports
----  ----      -----
1     Default   Fa1/0-7 Gig1/8 

(Aruba800) #

END
