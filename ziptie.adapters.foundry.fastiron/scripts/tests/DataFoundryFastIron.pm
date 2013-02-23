package DataFoundryFastIron;

use strict;
use warnings;
use Exporter 'import';
our @EXPORT_OK = qw($responsesFastIron);

our $responsesFastIron = {};

$responsesFastIron->{'showRun'} = <<'END';
!
module 1 bi-8-port-gig-management-module
module 2 bi-24-port-copper-module
!
!
!
!
gig-default neg-off
aaa authentication web-server default local
aaa authentication enable default tacacs+ enable
aaa authentication login default tacacs+ local
chassis name BigIron
enable telnet authentication
enable telnet password .....
enable skip-page-display
enable super-user-password .....
hostname BigIron
ip dns domain-name alterpoint.com
ip proxy-arp
ip route 0.0.0.0 0.0.0.0 10.100.21.1
!
logging 10.10.1.144
logging 10.10.1.57
logging 10.100.32.88
logging facility local0
username testlab password .....
tacacs-server host 10.100.32.137
tacacs-server key 1 $d=-ds
snmp-server community ..... ro
snmp-server community ..... ro
snmp-server community ..... rw
snmp-server community ..... rw
snmp-server contact gfarris
snmp-server location Austin-Alterpoint
snmp-server host 10.10.1.30 .....
snmp-server host 10.10.1.30 .....
snmp-server host 10.10.1.78 .....
snmp-server host 10.10.1.94 .....
clock summer-time
clock timezone us Central
web-management allow-no-password
banner motd ^C
end^C
!
!
router ospf
 area 0.0.0.21
!
interface ethernet 1/1
 disable
!
interface ethernet 1/2
 disable
!
interface ethernet 1/3
 disable
!
interface ethernet 1/4
 disable
!
interface ethernet 1/5
 disable
!
interface ethernet 1/6
 disable
!
interface ethernet 1/7
 disable
!
interface ethernet 1/8
 disable
!
interface ethernet 2/1
 disable
!
interface ethernet 2/2
 disable
!
interface ethernet 2/3
 disable
!
interface ethernet 2/4
 disable
!
interface ethernet 2/5
 disable
!
interface ethernet 2/6
 disable
!
interface ethernet 2/7
 disable
!
interface ethernet 2/8
 disable
!
interface ethernet 2/9
 disable
!
interface ethernet 2/10
 disable
!
interface ethernet 2/11
 disable
!
interface ethernet 2/12
 disable
!
interface ethernet 2/13
 disable
!
interface ethernet 2/14
 disable
!
interface ethernet 2/16
 disable
!
interface ethernet 2/17
 disable
!
interface ethernet 2/18
 disable
!
interface ethernet 2/19
 disable
!
interface ethernet 2/20
 disable
!
interface ethernet 2/21
 disable
!
interface ethernet 2/22
 disable
!
interface ethernet 2/23
 disable
!
interface ethernet 2/24
 ip address 10.100.21.3 255.255.255.0
 ip ospf area 0.0.0.21
!
!
router bgp
!
!
!
!
crypto key generate rsa public_key "1024 37 130996553683533501574736113430836614740524256708356446152778257103015546644163142379446142394745923205698341946338287326746854419241010412839962766600058014297035776081120676605305542338513421997308785312245591177778115132267394332365208224910847229374898691947409309405700081235766368164437383504424893375499 BigIron@alterpoint.com"
!
crypto key generate rsa private_key "*************************"

!
ip ssh authentication-retries 5
!
end



END

$responsesFastIron->{'showVer'} = <<'END';
show version
  SW: Version 07.6.02T53 Copyright (c) 1996-2002 Foundry Networks, Inc.
      Compiled on Dec 20 2002 at 20:53:17 labeled as B2R07602
      (2753663 bytes) from Primary 
  HW: BigIron 4000 Router, SYSIF version 21
==========================================================================
SL 1: B8GMR Fiber Management Module, SYSIF 2, M3, ACTIVE
      Serial #: Non-exist.
 4096 KB BRAM, SMC version 1, ICBM version 21
  512 KB PRAM(512K+0K) and 2048*8 CAM entries for DMA  0, version 0209
  512 KB PRAM(512K+0K) and shared CAM entries for DMA  1, version 0209
  512 KB PRAM(512K+0K) and 2048*8 CAM entries for DMA  2, version 0209
  512 KB PRAM(512K+0K) and shared CAM entries for DMA  3, version 0209
==========================================================================
SL 2: B24E Copper Switch Module
      Serial #: Non-exist.
 2048 KB BRAM, SMC version 2, ICBM version 21
  256 KB PRAM(256K+0K) and 2048*8 CAM entries for DMA  4, version 0808
  256 KB PRAM(256K+0K) and shared CAM entries for DMA  5, version 0808
  256 KB PRAM(256K+0K) and shared CAM entries for DMA  6, version 0808
==========================================================================
Active management module:
  400 MHz Power PC processor 740 (version 8/8202) 66 MHz bus
  512 KB boot flash memory
 8192 KB code flash memory
  256 KB SRAM
  128 MB DRAM
Fastboot Option is on
The system uptime is 373 days 5 hours 25 minutes 48 seconds 
The system : started=cold start   

telnet@BigIron>

END

$responsesFastIron->{'showChassis'} = <<'END';
show chassis
power supply 1 ok
power supply 2 not present
power supply 1 to 2 from left to right
fan 1 (left side panel, back fan) ok
fan 2 (left side panel, front fan) ok
fan 3 (rear/back panel, left fan) ok
fan 4 (rear/back panel, right fan) ok
Current temperature : 35.0 C degrees
Warning level : 45 C degrees, shutdown level : 55 C degrees
Boot Prom MAC: 00e0.52c1.5800
telnet@BigIron>

END

$responsesFastIron->{'showMod'} = <<'END';
show module
    Module                                 Status    Ports Starting MAC  
S1: B8GMR Fiber Management Module, SYSIF 2 M3, ACTIV   8   00e0.52c1.5800
S2: B24E Copper Switch Module              OK         24   00e0.52c1.5820
S3: 
S4: 
telnet@BigIron>

END

$responsesFastIron->{'showFlash'} = <<'END';
show flash
Active management module:
Code Flash Type: AMD 29F032B, Size: 64 * 65536 = 4194304, Unit: 2
Boot Flash Type: AMD 29F040, Size: 8 * 65536 = 524288
Compressed Pri Code size = 2753663, Version 07.6.02T53
Compressed Sec Code size = 2753663, Version 07.6.02T53
Maximum Code Image Size Supported: 3866112 (0x003afe00)
Boot Image size = 268200, Version 07.06.02
Used Configuration Flash Size=2462, Max Configuration Flash Size=262144.
telnet@BigIron>

END

$responsesFastIron->{'showStart'} = <<'END';
!
module 1 bi-8-port-gig-management-module
module 2 bi-24-port-copper-module
!
!
!
!
gig-default neg-off
aaa authentication web-server default local
aaa authentication enable default tacacs+ enable
aaa authentication login default tacacs+ local
chassis name BigIron
enable telnet authentication
enable telnet password .....
enable skip-page-display
enable super-user-password .....
hostname BigIron
ip dns domain-name alterpoint.com
ip proxy-arp
ip route 0.0.0.0 0.0.0.0 10.100.21.1
!
logging 10.10.1.144
logging 10.10.1.57
logging 10.100.32.88
logging facility local0
username testlab password .....
tacacs-server host 10.100.32.137
tacacs-server key 1 $d=-ds
snmp-server community ..... ro
snmp-server community ..... ro
snmp-server community ..... rw
snmp-server community ..... rw
snmp-server contact gfarris
snmp-server location Austin-Alterpoint
snmp-server host 10.10.1.30 .....
snmp-server host 10.10.1.30 .....
snmp-server host 10.10.1.78 .....
snmp-server host 10.10.1.94 .....
clock summer-time
clock timezone us Central
web-management allow-no-password
banner motd ^C
end^C
!
!
router ospf
 area 0.0.0.21
!
interface ethernet 1/1
 disable
!
interface ethernet 1/2
 disable
!
interface ethernet 1/3
 disable
!
interface ethernet 1/4
 disable
!
interface ethernet 1/5
 disable
!
interface ethernet 1/6
 disable
!
interface ethernet 1/7
 disable
!
interface ethernet 1/8
 disable
!
interface ethernet 2/1
 disable
!
interface ethernet 2/2
 disable
!
interface ethernet 2/3
 disable
!
interface ethernet 2/4
 disable
!
interface ethernet 2/5
 disable
!
interface ethernet 2/6
 disable
!
interface ethernet 2/7
 disable
!
interface ethernet 2/8
 disable
!
interface ethernet 2/9
 disable
!
interface ethernet 2/10
 disable
!
interface ethernet 2/11
 disable
!
interface ethernet 2/12
 disable
!
interface ethernet 2/13
 disable
!
interface ethernet 2/14
 disable
!
interface ethernet 2/16
 disable
!
interface ethernet 2/17
 disable
!
interface ethernet 2/18
 disable
!
interface ethernet 2/19
 disable
!
interface ethernet 2/20
 disable
!
interface ethernet 2/21
 disable
!
interface ethernet 2/22
 disable
!
interface ethernet 2/23
 disable
!
interface ethernet 2/24
 ip address 10.100.21.3 255.255.255.0
 ip ospf area 0.0.0.21
!
!
router bgp
!
!
!
!
ip ssh authentication-retries 5
!
ip ssh permit-empty-passwd yes
!
end



END

$responsesFastIron->{'interfaces'} = <<'END';
show interfaces
GigabitEthernet1/1 is disabled, line protocol is down 
  Hardware is GigabitEthernet, address is 00e0.52c1.5800 (bia 00e0.52c1.5800)
  Configured speed 1Gbit, actual unknown, configured duplex fdx, actual unknown
  Member of L2 VLAN ID 1, port is untagged, port state is DISABLED
  STP configured to ON, priority is level0, flow control enabled
  mirror disabled, monitor disabled
  Not member of any active trunks
  Not member of any configured trunks
  No port name
  MTU 1518 bytes, encapsulation ethernet
  300 second input rate: 0 bits/sec, 0 packets/sec, 0.00% utilization
  300 second output rate: 0 bits/sec, 0 packets/sec, 0.00% utilization
  0 packets input, 0 bytes, 0 no buffer
  Received 0 broadcasts, 0 multicasts, 0 unicasts
  0 input errors, 0 CRC, 0 frame, 0 ignored
  0 runts, 0 giants, DMA received 0 packets
  0 packets output, 0 bytes, 0 underruns
  Transmitted 0 broadcasts, 0 multicasts, 0 unicasts
  0 output errors, 0 collisions, DMA transmitted 0 packets
GigabitEthernet1/2 is disabled, line protocol is down 
  Hardware is GigabitEthernet, address is 00e0.52c1.5801 (bia 00e0.52c1.5801)
  Configured speed 1Gbit, actual unknown, configured duplex fdx, actual unknown
  Member of L2 VLAN ID 1, port is untagged, port state is DISABLED
  STP configured to ON, priority is level0, flow control enabled
  mirror disabled, monitor disabled
  Not member of any active trunks
  Not member of any configured trunks
  No port name
  MTU 1518 bytes, encapsulation ethernet
  300 second input rate: 0 bits/sec, 0 packets/sec, 0.00% utilization
  300 second output rate: 0 bits/sec, 0 packets/sec, 0.00% utilization
  0 packets input, 0 bytes, 0 no buffer
  Received 0 broadcasts, 0 multicasts, 0 unicasts
  0 input errors, 0 CRC, 0 frame, 0 ignored
  0 runts, 0 giants, DMA received 0 packets
  0 packets output, 0 bytes, 0 underruns
  Transmitted 0 broadcasts, 0 multicasts, 0 unicasts
  0 output errors, 0 collisions, DMA transmitted 0 packets
GigabitEthernet1/3 is disabled, line protocol is down 
  Hardware is GigabitEthernet, address is 00e0.52c1.5802 (bia 00e0.52c1.5802)
  Configured speed 1Gbit, actual unknown, configured duplex fdx, actual unknown
  Member of L2 VLAN ID 1, port is untagged, port state is DISABLED
  STP configured to ON, priority is level0, flow control enabled
  mirror disabled, monitor disabled
  Not member of any active trunks
  Not member of any configured trunks
  No port name
  MTU 1518 bytes, encapsulation ethernet
  300 second input rate: 0 bits/sec, 0 packets/sec, 0.00% utilization
  300 second output rate: 0 bits/sec, 0 packets/sec, 0.00% utilization
  0 packets input, 0 bytes, 0 no buffer
  Received 0 broadcasts, 0 multicasts, 0 unicasts
  0 input errors, 0 CRC, 0 frame, 0 ignored
  0 runts, 0 giants, DMA received 0 packets
  0 packets output, 0 bytes, 0 underruns
  Transmitted 0 broadcasts, 0 multicasts, 0 unicasts
  0 output errors, 0 collisions, DMA transmitted 0 packets
GigabitEthernet1/4 is disabled, line protocol is down 
  Hardware is GigabitEthernet, address is 00e0.52c1.5803 (bia 00e0.52c1.5803)
  Configured speed 1Gbit, actual unknown, configured duplex fdx, actual unknown
  Member of L2 VLAN ID 1, port is untagged, port state is DISABLED
  STP configured to ON, priority is level0, flow control enabled
  mirror disabled, monitor disabled
  Not member of any active trunks
  Not member of any configured trunks
  No port name
  MTU 1518 bytes, encapsulation ethernet
  300 second input rate: 0 bits/sec, 0 packets/sec, 0.00% utilization
  300 second output rate: 0 bits/sec, 0 packets/sec, 0.00% utilization
  0 packets input, 0 bytes, 0 no buffer
  Received 0 broadcasts, 0 multicasts, 0 unicasts
  0 input errors, 0 CRC, 0 frame, 0 ignored
  0 runts, 0 giants, DMA received 0 packets
  0 packets output, 0 bytes, 0 underruns
  Transmitted 0 broadcasts, 0 multicasts, 0 unicasts
  0 output errors, 0 collisions, DMA transmitted 0 packets
GigabitEthernet1/5 is disabled, line protocol is down 
  Hardware is GigabitEthernet, address is 00e0.52c1.5804 (bia 00e0.52c1.5804)
  Configured speed 1Gbit, actual unknown, configured duplex fdx, actual unknown
  Member of L2 VLAN ID 1, port is untagged, port state is DISABLED
  STP configured to ON, priority is level0, flow control enabled
  mirror disabled, monitor disabled
  Not member of any active trunks
  Not member of any configured trunks
  No port name
  MTU 1518 bytes, encapsulation ethernet
  300 second input rate: 0 bits/sec, 0 packets/sec, 0.00% utilization
  300 second output rate: 0 bits/sec, 0 packets/sec, 0.00% utilization
  0 packets input, 0 bytes, 0 no buffer
  Received 0 broadcasts, 0 multicasts, 0 unicasts
  0 input errors, 0 CRC, 0 frame, 0 ignored
  0 runts, 0 giants, DMA received 0 packets
  0 packets output, 0 bytes, 0 underruns
  Transmitted 0 broadcasts, 0 multicasts, 0 unicasts
  0 output errors, 0 collisions, DMA transmitted 0 packets
GigabitEthernet1/6 is disabled, line protocol is down 
  Hardware is GigabitEthernet, address is 00e0.52c1.5805 (bia 00e0.52c1.5805)
  Configured speed 1Gbit, actual unknown, configured duplex fdx, actual unknown
  Member of L2 VLAN ID 1, port is untagged, port state is DISABLED
  STP configured to ON, priority is level0, flow control enabled
  mirror disabled, monitor disabled
  Not member of any active trunks
  Not member of any configured trunks
  No port name
  MTU 1518 bytes, encapsulation ethernet
  300 second input rate: 0 bits/sec, 0 packets/sec, 0.00% utilization
  300 second output rate: 0 bits/sec, 0 packets/sec, 0.00% utilization
  0 packets input, 0 bytes, 0 no buffer
  Received 0 broadcasts, 0 multicasts, 0 unicasts
  0 input errors, 0 CRC, 0 frame, 0 ignored
  0 runts, 0 giants, DMA received 0 packets
  0 packets output, 0 bytes, 0 underruns
  Transmitted 0 broadcasts, 0 multicasts, 0 unicasts
  0 output errors, 0 collisions, DMA transmitted 0 packets
GigabitEthernet1/7 is disabled, line protocol is down 
  Hardware is GigabitEthernet, address is 00e0.52c1.5806 (bia 00e0.52c1.5806)
  Configured speed 1Gbit, actual unknown, configured duplex fdx, actual unknown
  Member of L2 VLAN ID 1, port is untagged, port state is DISABLED
  STP configured to ON, priority is level0, flow control enabled
  mirror disabled, monitor disabled
  Not member of any active trunks
  Not member of any configured trunks
  No port name
  MTU 1518 bytes, encapsulation ethernet
  300 second input rate: 0 bits/sec, 0 packets/sec, 0.00% utilization
  300 second output rate: 0 bits/sec, 0 packets/sec, 0.00% utilization
  0 packets input, 0 bytes, 0 no buffer
  Received 0 broadcasts, 0 multicasts, 0 unicasts
  0 input errors, 0 CRC, 0 frame, 0 ignored
  0 runts, 0 giants, DMA received 0 packets
  0 packets output, 0 bytes, 0 underruns
  Transmitted 0 broadcasts, 0 multicasts, 0 unicasts
  0 output errors, 0 collisions, DMA transmitted 0 packets
GigabitEthernet1/8 is disabled, line protocol is down 
  Hardware is GigabitEthernet, address is 00e0.52c1.5807 (bia 00e0.52c1.5807)
  Configured speed 1Gbit, actual unknown, configured duplex fdx, actual unknown
  Member of L2 VLAN ID 1, port is untagged, port state is DISABLED
  STP configured to ON, priority is level0, flow control enabled
  mirror disabled, monitor disabled
  Not member of any active trunks
  Not member of any configured trunks
  No port name
  MTU 1518 bytes, encapsulation ethernet
  300 second input rate: 0 bits/sec, 0 packets/sec, 0.00% utilization
  300 second output rate: 0 bits/sec, 0 packets/sec, 0.00% utilization
  0 packets input, 0 bytes, 0 no buffer
  Received 0 broadcasts, 0 multicasts, 0 unicasts
  0 input errors, 0 CRC, 0 frame, 0 ignored
  0 runts, 0 giants, DMA received 0 packets
  0 packets output, 0 bytes, 0 underruns
  Transmitted 0 broadcasts, 0 multicasts, 0 unicasts
  0 output errors, 0 collisions, DMA transmitted 0 packets
FastEthernet2/1 is disabled, line protocol is down 
  Hardware is FastEthernet, address is 00e0.52c1.5820 (bia 00e0.52c1.5820)
  Configured speed auto, actual unknown, configured duplex fdx, actual unknown
  Member of L2 VLAN ID 1, port is untagged, port state is DISABLED
  STP configured to ON, priority is level0, flow control enabled
  mirror disabled, monitor disabled
  Not member of any active trunks
  Not member of any configured trunks
  No port name
  MTU 1518 bytes, encapsulation ethernet
  300 second input rate: 0 bits/sec, 0 packets/sec, 0.00% utilization
  300 second output rate: 0 bits/sec, 0 packets/sec, 0.00% utilization
  0 packets input, 0 bytes, 0 no buffer
  Received 0 broadcasts, 0 multicasts, 0 unicasts
  0 input errors, 0 CRC, 0 frame, 0 ignored
  0 runts, 0 giants, DMA received 0 packets
  0 packets output, 0 bytes, 0 underruns
  Transmitted 0 broadcasts, 0 multicasts, 0 unicasts
  0 output errors, 0 collisions, DMA transmitted 0 packets
FastEthernet2/2 is disabled, line protocol is down 
  Hardware is FastEthernet, address is 00e0.52c1.5821 (bia 00e0.52c1.5821)
  Configured speed auto, actual unknown, configured duplex fdx, actual unknown
  Member of L2 VLAN ID 1, port is untagged, port state is DISABLED
  STP configured to ON, priority is level0, flow control enabled
  mirror disabled, monitor disabled
  Not member of any active trunks
  Not member of any configured trunks
  No port name
  MTU 1518 bytes, encapsulation ethernet
  300 second input rate: 0 bits/sec, 0 packets/sec, 0.00% utilization
  300 second output rate: 0 bits/sec, 0 packets/sec, 0.00% utilization
  0 packets input, 0 bytes, 0 no buffer
  Received 0 broadcasts, 0 multicasts, 0 unicasts
  0 input errors, 0 CRC, 0 frame, 0 ignored
  0 runts, 0 giants, DMA received 0 packets
  0 packets output, 0 bytes, 0 underruns
  Transmitted 0 broadcasts, 0 multicasts, 0 unicasts
  0 output errors, 0 collisions, DMA transmitted 0 packets
FastEthernet2/3 is disabled, line protocol is down 
  Hardware is FastEthernet, address is 00e0.52c1.5822 (bia 00e0.52c1.5822)
  Configured speed auto, actual unknown, configured duplex fdx, actual unknown
  Member of L2 VLAN ID 1, port is untagged, port state is DISABLED
  STP configured to ON, priority is level0, flow control enabled
  mirror disabled, monitor disabled
  Not member of any active trunks
  Not member of any configured trunks
  No port name
  MTU 1518 bytes, encapsulation ethernet
  300 second input rate: 0 bits/sec, 0 packets/sec, 0.00% utilization
  300 second output rate: 0 bits/sec, 0 packets/sec, 0.00% utilization
  0 packets input, 0 bytes, 0 no buffer
  Received 0 broadcasts, 0 multicasts, 0 unicasts
  0 input errors, 0 CRC, 0 frame, 0 ignored
  0 runts, 0 giants, DMA received 0 packets
  0 packets output, 0 bytes, 0 underruns
  Transmitted 0 broadcasts, 0 multicasts, 0 unicasts
  0 output errors, 0 collisions, DMA transmitted 0 packets
FastEthernet2/4 is disabled, line protocol is down 
  Hardware is FastEthernet, address is 00e0.52c1.5823 (bia 00e0.52c1.5823)
  Configured speed auto, actual unknown, configured duplex fdx, actual unknown
  Member of L2 VLAN ID 1, port is untagged, port state is DISABLED
  STP configured to ON, priority is level0, flow control enabled
  mirror disabled, monitor disabled
  Not member of any active trunks
  Not member of any configured trunks
  No port name
  MTU 1518 bytes, encapsulation ethernet
  300 second input rate: 0 bits/sec, 0 packets/sec, 0.00% utilization
  300 second output rate: 0 bits/sec, 0 packets/sec, 0.00% utilization
  0 packets input, 0 bytes, 0 no buffer
  Received 0 broadcasts, 0 multicasts, 0 unicasts
  0 input errors, 0 CRC, 0 frame, 0 ignored
  0 runts, 0 giants, DMA received 0 packets
  0 packets output, 0 bytes, 0 underruns
  Transmitted 0 broadcasts, 0 multicasts, 0 unicasts
  0 output errors, 0 collisions, DMA transmitted 0 packets
FastEthernet2/5 is disabled, line protocol is down 
  Hardware is FastEthernet, address is 00e0.52c1.5824 (bia 00e0.52c1.5824)
  Configured speed auto, actual unknown, configured duplex fdx, actual unknown
  Member of L2 VLAN ID 1, port is untagged, port state is DISABLED
  STP configured to ON, priority is level0, flow control enabled
  mirror disabled, monitor disabled
  Not member of any active trunks
  Not member of any configured trunks
  No port name
  MTU 1518 bytes, encapsulation ethernet
  300 second input rate: 0 bits/sec, 0 packets/sec, 0.00% utilization
  300 second output rate: 0 bits/sec, 0 packets/sec, 0.00% utilization
  0 packets input, 0 bytes, 0 no buffer
  Received 0 broadcasts, 0 multicasts, 0 unicasts
  0 input errors, 0 CRC, 0 frame, 0 ignored
  0 runts, 0 giants, DMA received 0 packets
  0 packets output, 0 bytes, 0 underruns
  Transmitted 0 broadcasts, 0 multicasts, 0 unicasts
  0 output errors, 0 collisions, DMA transmitted 0 packets
FastEthernet2/6 is disabled, line protocol is down 
  Hardware is FastEthernet, address is 00e0.52c1.5825 (bia 00e0.52c1.5825)
  Configured speed auto, actual unknown, configured duplex fdx, actual unknown
  Member of L2 VLAN ID 1, port is untagged, port state is DISABLED
  STP configured to ON, priority is level0, flow control enabled
  mirror disabled, monitor disabled
  Not member of any active trunks
  Not member of any configured trunks
  No port name
  MTU 1518 bytes, encapsulation ethernet
  300 second input rate: 0 bits/sec, 0 packets/sec, 0.00% utilization
  300 second output rate: 0 bits/sec, 0 packets/sec, 0.00% utilization
  0 packets input, 0 bytes, 0 no buffer
  Received 0 broadcasts, 0 multicasts, 0 unicasts
  0 input errors, 0 CRC, 0 frame, 0 ignored
  0 runts, 0 giants, DMA received 0 packets
  0 packets output, 0 bytes, 0 underruns
  Transmitted 0 broadcasts, 0 multicasts, 0 unicasts
  0 output errors, 0 collisions, DMA transmitted 0 packets
FastEthernet2/7 is disabled, line protocol is down 
  Hardware is FastEthernet, address is 00e0.52c1.5826 (bia 00e0.52c1.5826)
  Configured speed auto, actual unknown, configured duplex fdx, actual unknown
  Member of L2 VLAN ID 1, port is untagged, port state is DISABLED
  STP configured to ON, priority is level0, flow control enabled
  mirror disabled, monitor disabled
  Not member of any active trunks
  Not member of any configured trunks
  No port name
  MTU 1518 bytes, encapsulation ethernet
  300 second input rate: 0 bits/sec, 0 packets/sec, 0.00% utilization
  300 second output rate: 0 bits/sec, 0 packets/sec, 0.00% utilization
  0 packets input, 0 bytes, 0 no buffer
  Received 0 broadcasts, 0 multicasts, 0 unicasts
  0 input errors, 0 CRC, 0 frame, 0 ignored
  0 runts, 0 giants, DMA received 0 packets
  0 packets output, 0 bytes, 0 underruns
  Transmitted 0 broadcasts, 0 multicasts, 0 unicasts
  0 output errors, 0 collisions, DMA transmitted 0 packets
FastEthernet2/8 is disabled, line protocol is down 
  Hardware is FastEthernet, address is 00e0.52c1.5827 (bia 00e0.52c1.5827)
  Configured speed auto, actual unknown, configured duplex fdx, actual unknown
  Member of L2 VLAN ID 1, port is untagged, port state is DISABLED
  STP configured to ON, priority is level0, flow control enabled
  mirror disabled, monitor disabled
  Not member of any active trunks
  Not member of any configured trunks
  No port name
  MTU 1518 bytes, encapsulation ethernet
  300 second input rate: 0 bits/sec, 0 packets/sec, 0.00% utilization
  300 second output rate: 0 bits/sec, 0 packets/sec, 0.00% utilization
  0 packets input, 0 bytes, 0 no buffer
  Received 0 broadcasts, 0 multicasts, 0 unicasts
  0 input errors, 0 CRC, 0 frame, 0 ignored
  0 runts, 0 giants, DMA received 0 packets
  0 packets output, 0 bytes, 0 underruns
  Transmitted 0 broadcasts, 0 multicasts, 0 unicasts
  0 output errors, 0 collisions, DMA transmitted 0 packets
FastEthernet2/9 is disabled, line protocol is down 
  Hardware is FastEthernet, address is 00e0.52c1.5828 (bia 00e0.52c1.5828)
  Configured speed auto, actual unknown, configured duplex fdx, actual unknown
  Member of L2 VLAN ID 1, port is untagged, port state is DISABLED
  STP configured to ON, priority is level0, flow control enabled
  mirror disabled, monitor disabled
  Not member of any active trunks
  Not member of any configured trunks
  No port name
  MTU 1518 bytes, encapsulation ethernet
  300 second input rate: 0 bits/sec, 0 packets/sec, 0.00% utilization
  300 second output rate: 0 bits/sec, 0 packets/sec, 0.00% utilization
  0 packets input, 0 bytes, 0 no buffer
  Received 0 broadcasts, 0 multicasts, 0 unicasts
  0 input errors, 0 CRC, 0 frame, 0 ignored
  0 runts, 0 giants, DMA received 0 packets
  0 packets output, 0 bytes, 0 underruns
  Transmitted 0 broadcasts, 0 multicasts, 0 unicasts
  0 output errors, 0 collisions, DMA transmitted 0 packets
FastEthernet2/10 is disabled, line protocol is down 
  Hardware is FastEthernet, address is 00e0.52c1.5829 (bia 00e0.52c1.5829)
  Configured speed auto, actual unknown, configured duplex fdx, actual unknown
  Member of L2 VLAN ID 1, port is untagged, port state is DISABLED
  STP configured to ON, priority is level0, flow control enabled
  mirror disabled, monitor disabled
  Not member of any active trunks
  Not member of any configured trunks
  No port name
  MTU 1518 bytes, encapsulation ethernet
  300 second input rate: 0 bits/sec, 0 packets/sec, 0.00% utilization
  300 second output rate: 0 bits/sec, 0 packets/sec, 0.00% utilization
  0 packets input, 0 bytes, 0 no buffer
  Received 0 broadcasts, 0 multicasts, 0 unicasts
  0 input errors, 0 CRC, 0 frame, 0 ignored
  0 runts, 0 giants, DMA received 0 packets
  0 packets output, 0 bytes, 0 underruns
  Transmitted 0 broadcasts, 0 multicasts, 0 unicasts
  0 output errors, 0 collisions, DMA transmitted 0 packets
FastEthernet2/11 is disabled, line protocol is down 
  Hardware is FastEthernet, address is 00e0.52c1.582a (bia 00e0.52c1.582a)
  Configured speed auto, actual unknown, configured duplex fdx, actual unknown
  Member of L2 VLAN ID 1, port is untagged, port state is DISABLED
  STP configured to ON, priority is level0, flow control enabled
  mirror disabled, monitor disabled
  Not member of any active trunks
  Not member of any configured trunks
  No port name
  MTU 1518 bytes, encapsulation ethernet
  300 second input rate: 0 bits/sec, 0 packets/sec, 0.00% utilization
  300 second output rate: 0 bits/sec, 0 packets/sec, 0.00% utilization
  0 packets input, 0 bytes, 0 no buffer
  Received 0 broadcasts, 0 multicasts, 0 unicasts
  0 input errors, 0 CRC, 0 frame, 0 ignored
  0 runts, 0 giants, DMA received 0 packets
  0 packets output, 0 bytes, 0 underruns
  Transmitted 0 broadcasts, 0 multicasts, 0 unicasts
  0 output errors, 0 collisions, DMA transmitted 0 packets
FastEthernet2/12 is disabled, line protocol is down 
  Hardware is FastEthernet, address is 00e0.52c1.582b (bia 00e0.52c1.582b)
  Configured speed auto, actual unknown, configured duplex fdx, actual unknown
  Member of L2 VLAN ID 1, port is untagged, port state is DISABLED
  STP configured to ON, priority is level0, flow control enabled
  mirror disabled, monitor disabled
  Not member of any active trunks
  Not member of any configured trunks
  No port name
  MTU 1518 bytes, encapsulation ethernet
  300 second input rate: 0 bits/sec, 0 packets/sec, 0.00% utilization
  300 second output rate: 0 bits/sec, 0 packets/sec, 0.00% utilization
  0 packets input, 0 bytes, 0 no buffer
  Received 0 broadcasts, 0 multicasts, 0 unicasts
  0 input errors, 0 CRC, 0 frame, 0 ignored
  0 runts, 0 giants, DMA received 0 packets
  0 packets output, 0 bytes, 0 underruns
  Transmitted 0 broadcasts, 0 multicasts, 0 unicasts
  0 output errors, 0 collisions, DMA transmitted 0 packets
FastEthernet2/13 is disabled, line protocol is down 
  Hardware is FastEthernet, address is 00e0.52c1.582c (bia 00e0.52c1.582c)
  Configured speed auto, actual unknown, configured duplex fdx, actual unknown
  Member of L2 VLAN ID 1, port is untagged, port state is DISABLED
  STP configured to ON, priority is level0, flow control enabled
  mirror disabled, monitor disabled
  Not member of any active trunks
  Not member of any configured trunks
  No port name
  MTU 1518 bytes, encapsulation ethernet
  300 second input rate: 0 bits/sec, 0 packets/sec, 0.00% utilization
  300 second output rate: 0 bits/sec, 0 packets/sec, 0.00% utilization
  0 packets input, 0 bytes, 0 no buffer
  Received 0 broadcasts, 0 multicasts, 0 unicasts
  0 input errors, 0 CRC, 0 frame, 0 ignored
  0 runts, 0 giants, DMA received 0 packets
  0 packets output, 0 bytes, 0 underruns
  Transmitted 0 broadcasts, 0 multicasts, 0 unicasts
  0 output errors, 0 collisions, DMA transmitted 0 packets
FastEthernet2/14 is disabled, line protocol is down 
  Hardware is FastEthernet, address is 00e0.52c1.582d (bia 00e0.52c1.582d)
  Configured speed auto, actual unknown, configured duplex fdx, actual unknown
  Member of L2 VLAN ID 1, port is untagged, port state is DISABLED
  STP configured to ON, priority is level0, flow control enabled
  mirror disabled, monitor disabled
  Not member of any active trunks
  Not member of any configured trunks
  No port name
  MTU 1518 bytes, encapsulation ethernet
  300 second input rate: 0 bits/sec, 0 packets/sec, 0.00% utilization
  300 second output rate: 0 bits/sec, 0 packets/sec, 0.00% utilization
  0 packets input, 0 bytes, 0 no buffer
  Received 0 broadcasts, 0 multicasts, 0 unicasts
  0 input errors, 0 CRC, 0 frame, 0 ignored
  0 runts, 0 giants, DMA received 0 packets
  0 packets output, 0 bytes, 0 underruns
  Transmitted 0 broadcasts, 0 multicasts, 0 unicasts
  0 output errors, 0 collisions, DMA transmitted 0 packets
FastEthernet2/15 is down, line protocol is down 
  Hardware is FastEthernet, address is 00e0.52c1.582e (bia 00e0.52c1.582e)
  Configured speed auto, actual unknown, configured duplex fdx, actual unknown
  Member of L2 VLAN ID 1, port is untagged, port state is BLOCKING
  STP configured to ON, priority is level0, flow control enabled
  mirror disabled, monitor disabled
  Not member of any active trunks
  Not member of any configured trunks
  No port name
  MTU 1518 bytes, encapsulation ethernet
  300 second input rate: 0 bits/sec, 0 packets/sec, 0.00% utilization
  300 second output rate: 0 bits/sec, 0 packets/sec, 0.00% utilization
  0 packets input, 0 bytes, 0 no buffer
  Received 0 broadcasts, 0 multicasts, 0 unicasts
  0 input errors, 0 CRC, 0 frame, 0 ignored
  0 runts, 0 giants, DMA received 0 packets
  0 packets output, 0 bytes, 0 underruns
  Transmitted 0 broadcasts, 0 multicasts, 0 unicasts
  0 output errors, 0 collisions, DMA transmitted 0 packets
FastEthernet2/16 is disabled, line protocol is down 
  Hardware is FastEthernet, address is 00e0.52c1.582f (bia 00e0.52c1.582f)
  Configured speed auto, actual unknown, configured duplex fdx, actual unknown
  Member of L2 VLAN ID 1, port is untagged, port state is DISABLED
  STP configured to ON, priority is level0, flow control enabled
  mirror disabled, monitor disabled
  Not member of any active trunks
  Not member of any configured trunks
  No port name
  MTU 1518 bytes, encapsulation ethernet
  300 second input rate: 0 bits/sec, 0 packets/sec, 0.00% utilization
  300 second output rate: 0 bits/sec, 0 packets/sec, 0.00% utilization
  0 packets input, 0 bytes, 0 no buffer
  Received 0 broadcasts, 0 multicasts, 0 unicasts
  0 input errors, 0 CRC, 0 frame, 0 ignored
  0 runts, 0 giants, DMA received 0 packets
  0 packets output, 0 bytes, 0 underruns
  Transmitted 0 broadcasts, 0 multicasts, 0 unicasts
  0 output errors, 0 collisions, DMA transmitted 0 packets
FastEthernet2/17 is disabled, line protocol is down 
  Hardware is FastEthernet, address is 00e0.52c1.5830 (bia 00e0.52c1.5830)
  Configured speed auto, actual unknown, configured duplex fdx, actual unknown
  Member of L2 VLAN ID 1, port is untagged, port state is DISABLED
  STP configured to ON, priority is level0, flow control enabled
  mirror disabled, monitor disabled
  Not member of any active trunks
  Not member of any configured trunks
  No port name
  MTU 1518 bytes, encapsulation ethernet
  300 second input rate: 0 bits/sec, 0 packets/sec, 0.00% utilization
  300 second output rate: 0 bits/sec, 0 packets/sec, 0.00% utilization
  0 packets input, 0 bytes, 0 no buffer
  Received 0 broadcasts, 0 multicasts, 0 unicasts
  0 input errors, 0 CRC, 0 frame, 0 ignored
  0 runts, 0 giants, DMA received 0 packets
  0 packets output, 0 bytes, 0 underruns
  Transmitted 0 broadcasts, 0 multicasts, 0 unicasts
  0 output errors, 0 collisions, DMA transmitted 0 packets
FastEthernet2/18 is disabled, line protocol is down 
  Hardware is FastEthernet, address is 00e0.52c1.5831 (bia 00e0.52c1.5831)
  Configured speed auto, actual unknown, configured duplex fdx, actual unknown
  Member of L2 VLAN ID 1, port is untagged, port state is DISABLED
  STP configured to ON, priority is level0, flow control enabled
  mirror disabled, monitor disabled
  Not member of any active trunks
  Not member of any configured trunks
  No port name
  MTU 1518 bytes, encapsulation ethernet
  300 second input rate: 0 bits/sec, 0 packets/sec, 0.00% utilization
  300 second output rate: 0 bits/sec, 0 packets/sec, 0.00% utilization
  0 packets input, 0 bytes, 0 no buffer
  Received 0 broadcasts, 0 multicasts, 0 unicasts
  0 input errors, 0 CRC, 0 frame, 0 ignored
  0 runts, 0 giants, DMA received 0 packets
  0 packets output, 0 bytes, 0 underruns
  Transmitted 0 broadcasts, 0 multicasts, 0 unicasts
  0 output errors, 0 collisions, DMA transmitted 0 packets
FastEthernet2/19 is disabled, line protocol is down 
  Hardware is FastEthernet, address is 00e0.52c1.5832 (bia 00e0.52c1.5832)
  Configured speed auto, actual unknown, configured duplex fdx, actual unknown
  Member of L2 VLAN ID 1, port is untagged, port state is DISABLED
  STP configured to ON, priority is level0, flow control enabled
  mirror disabled, monitor disabled
  Not member of any active trunks
  Not member of any configured trunks
  No port name
  MTU 1518 bytes, encapsulation ethernet
  300 second input rate: 0 bits/sec, 0 packets/sec, 0.00% utilization
  300 second output rate: 0 bits/sec, 0 packets/sec, 0.00% utilization
  0 packets input, 0 bytes, 0 no buffer
  Received 0 broadcasts, 0 multicasts, 0 unicasts
  0 input errors, 0 CRC, 0 frame, 0 ignored
  0 runts, 0 giants, DMA received 0 packets
  0 packets output, 0 bytes, 0 underruns
  Transmitted 0 broadcasts, 0 multicasts, 0 unicasts
  0 output errors, 0 collisions, DMA transmitted 0 packets
FastEthernet2/20 is disabled, line protocol is down 
  Hardware is FastEthernet, address is 00e0.52c1.5833 (bia 00e0.52c1.5833)
  Configured speed auto, actual unknown, configured duplex fdx, actual unknown
  Member of L2 VLAN ID 1, port is untagged, port state is DISABLED
  STP configured to ON, priority is level0, flow control enabled
  mirror disabled, monitor disabled
  Not member of any active trunks
  Not member of any configured trunks
  No port name
  MTU 1518 bytes, encapsulation ethernet
  300 second input rate: 0 bits/sec, 0 packets/sec, 0.00% utilization
  300 second output rate: 0 bits/sec, 0 packets/sec, 0.00% utilization
  0 packets input, 0 bytes, 0 no buffer
  Received 0 broadcasts, 0 multicasts, 0 unicasts
  0 input errors, 0 CRC, 0 frame, 0 ignored
  0 runts, 0 giants, DMA received 0 packets
  0 packets output, 0 bytes, 0 underruns
  Transmitted 0 broadcasts, 0 multicasts, 0 unicasts
  0 output errors, 0 collisions, DMA transmitted 0 packets
FastEthernet2/21 is disabled, line protocol is down 
  Hardware is FastEthernet, address is 00e0.52c1.5834 (bia 00e0.52c1.5834)
  Configured speed auto, actual unknown, configured duplex fdx, actual unknown
  Member of L2 VLAN ID 1, port is untagged, port state is DISABLED
  STP configured to ON, priority is level0, flow control enabled
  mirror disabled, monitor disabled
  Not member of any active trunks
  Not member of any configured trunks
  No port name
  MTU 1518 bytes, encapsulation ethernet
  300 second input rate: 0 bits/sec, 0 packets/sec, 0.00% utilization
  300 second output rate: 0 bits/sec, 0 packets/sec, 0.00% utilization
  0 packets input, 0 bytes, 0 no buffer
  Received 0 broadcasts, 0 multicasts, 0 unicasts
  0 input errors, 0 CRC, 0 frame, 0 ignored
  0 runts, 0 giants, DMA received 0 packets
  0 packets output, 0 bytes, 0 underruns
  Transmitted 0 broadcasts, 0 multicasts, 0 unicasts
  0 output errors, 0 collisions, DMA transmitted 0 packets
FastEthernet2/22 is disabled, line protocol is down 
  Hardware is FastEthernet, address is 00e0.52c1.5835 (bia 00e0.52c1.5835)
  Configured speed auto, actual unknown, configured duplex fdx, actual unknown
  Member of L2 VLAN ID 1, port is untagged, port state is DISABLED
  STP configured to ON, priority is level0, flow control enabled
  mirror disabled, monitor disabled
  Not member of any active trunks
  Not member of any configured trunks
  No port name
  MTU 1518 bytes, encapsulation ethernet
  300 second input rate: 0 bits/sec, 0 packets/sec, 0.00% utilization
  300 second output rate: 0 bits/sec, 0 packets/sec, 0.00% utilization
  0 packets input, 0 bytes, 0 no buffer
  Received 0 broadcasts, 0 multicasts, 0 unicasts
  0 input errors, 0 CRC, 0 frame, 0 ignored
  0 runts, 0 giants, DMA received 0 packets
  0 packets output, 0 bytes, 0 underruns
  Transmitted 0 broadcasts, 0 multicasts, 0 unicasts
  0 output errors, 0 collisions, DMA transmitted 0 packets
FastEthernet2/23 is disabled, line protocol is down 
  Hardware is FastEthernet, address is 00e0.52c1.5836 (bia 00e0.52c1.5836)
  Configured speed auto, actual unknown, configured duplex fdx, actual unknown
  Member of L2 VLAN ID 1, port is untagged, port state is DISABLED
  STP configured to ON, priority is level0, flow control enabled
  mirror disabled, monitor disabled
  Not member of any active trunks
  Not member of any configured trunks
  No port name
  MTU 1518 bytes, encapsulation ethernet
  300 second input rate: 0 bits/sec, 0 packets/sec, 0.00% utilization
  300 second output rate: 0 bits/sec, 0 packets/sec, 0.00% utilization
  0 packets input, 0 bytes, 0 no buffer
  Received 0 broadcasts, 0 multicasts, 0 unicasts
  0 input errors, 0 CRC, 0 frame, 0 ignored
  0 runts, 0 giants, DMA received 0 packets
  0 packets output, 0 bytes, 0 underruns
  Transmitted 0 broadcasts, 0 multicasts, 0 unicasts
  0 output errors, 0 collisions, DMA transmitted 0 packets
FastEthernet2/24 is up, line protocol is up 
  Hardware is FastEthernet, address is 00e0.52c1.5837 (bia 00e0.52c1.5837)
  Configured speed auto, actual 100Mbit, configured duplex fdx, actual fdx
  Member of L2 VLAN ID 1, port is untagged, port state is FORWARDING
  STP configured to ON, priority is level0, flow control enabled
  mirror disabled, monitor disabled
  Not member of any active trunks
  Not member of any configured trunks
  No port name
  Internet address is 10.100.21.3/24, MTU 1518 bytes, encapsulation ethernet
  300 second input rate: 744 bits/sec, 1 packets/sec, 0.00% utilization
  300 second output rate: 144 bits/sec, 0 packets/sec, 0.00% utilization
  47073784 packets input, 3487476649 bytes, 0 no buffer
  Received 543356 broadcasts, 32145936 multicasts, 14384492 unicasts
  0 input errors, 0 CRC, 0 frame, 0 ignored
  0 runts, 0 giants, DMA received 43850562 packets
  11697493 packets output, 1300271282 bytes, 0 underruns
  Transmitted 38435 broadcasts, 3116667 multicasts, 8542391 unicasts
  0 output errors, 0 collisions, DMA transmitted 11697493 packets
telnet@BigIron>

END

$responsesFastIron->{'stp'} = <<'END';
show span

Spanning-tree is not configured on port-vlan 1.
telnet@BigIron>

END

$responsesFastIron->{'ip'} = <<'END';
show ip
Global Settings
  ttl: 64, arp-age: 10, bootp-relay-max-hops: 4
  router-id : 10.100.21.3
  enabled : BGP4  UDP-Broadcast-Forwarding  Source-Route  Load-Sharing  Proxy-ARP  RARP  OSPF  
  disabled: Route-Only  Directed-Broadcast-Forwarding  IRDP  RIP  DVMRP  VRRP  VRRP-Extended  
Static Routes
  Index   IP Address        Subnet Mask       Next Hop Router   Metric Distance
  1       0.0.0.0           0.0.0.0           10.100.21.1       1      1
telnet@BigIron>

END

$responsesFastIron->{'stp'} = <<'END';
show span

Global STP Parameters:

     Root             Root Root Prio Max He- Ho- Fwd Last     Chg  Bridge      
      ID              Cost Port rity Age llo ld  dly Chang    cnt  Address     
                                Hex  sec sec sec sec sec                       
     60de00179445ee80 28   1    8000 20  2   2   15  0        0    00e05202fea4

Port STP Parameters:

     Port Prio Path State      Fwd    Design Design           Design           
     Num  rity Cost            Trans  Cost   Root             Bridge           
          Hex                                                                  
     1    80   5    FORWARDING 1      23     60de00179445ee80 80de000af4506340 
     2    80   0    DISABLED   0      0      0000000000000000 0000000000000000 
     3    80   0    DISABLED   0      0      0000000000000000 0000000000000000 
     4    80   0    DISABLED   0      0      0000000000000000 0000000000000000 
     5    80   0    DISABLED   0      0      0000000000000000 0000000000000000 
     6    80   0    DISABLED   0      0      0000000000000000 0000000000000000 
     7    80   0    DISABLED   0      0      0000000000000000 0000000000000000 
     8    80   0    DISABLED   0      0      0000000000000000 0000000000000000 
     9    80   0    DISABLED   0      0      0000000000000000 0000000000000000 
     10   80   0    DISABLED   0      0      0000000000000000 0000000000000000 
     11   80   0    DISABLED   0      0      0000000000000000 0000000000000000 
     12   80   0    DISABLED   0      0      0000000000000000 0000000000000000 
     13   80   0    DISABLED   0      0      0000000000000000 0000000000000000 
     14   80   0    DISABLED   0      0      0000000000000000 0000000000000000 
     15   80   0    DISABLED   0      0      0000000000000000 0000000000000000 
     16   80   0    DISABLED   0      0      0000000000000000 0000000000000000 
     17   80   0    DISABLED   0      0      0000000000000000 0000000000000000 
     18   80   0    DISABLED   0      0      0000000000000000 0000000000000000 
     19   80   0    DISABLED   0      0      0000000000000000 0000000000000000 
     20   80   0    DISABLED   0      0      0000000000000000 0000000000000000 
     21   80   0    DISABLED   0      0      0000000000000000 0000000000000000 
     22   80   0    DISABLED   0      0      0000000000000000 0000000000000000 
     23   80   0    DISABLED   0      0      0000000000000000 0000000000000000 
     24   80   0    DISABLED   0      0      0000000000000000 0000000000000000 
telnet@FastIron#

END
