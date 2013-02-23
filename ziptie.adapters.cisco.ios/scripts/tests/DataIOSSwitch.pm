package DataIOSSwitch;

use strict;
use warnings;
use Exporter 'import';
our @EXPORT_OK = qw($stp $cat_vlans $vtp_status);

our $cat_vlans = <<'END';
show vlan

VLAN Name                             Status    Ports
---- -------------------------------- --------- -------------------------------
1    default                          active    Fa3/3, Fa3/4, Fa3/5, Fa3/6, Fa3/7, Fa3/8, Fa3/9, Fa3/10, Fa3/11, Fa3/47
25   ceige1                           active
26   ceige3                           active    Fa3/35
50   ceige2                           active    Fa3/37
51   ceige4                           active
100  Inside                           active    Fa3/15
200  FWSMOutside                      active    Fa3/2
300  FWSMInside                       active    Fa3/1, Fa3/25
950  dork                             active
1002 fddi-default                     act/unsup
1003 token-ring-default               act/unsup
1004 fddinet-default                  act/unsup
1005 trnet-default                    act/unsup

VLAN Type  SAID       MTU   Parent RingNo BridgeNo Stp  BrdgMode Trans1 Trans2
---- ----- ---------- ----- ------ ------ -------- ---- -------- ------ ------
1    enet  100001     1500  -      -      -        -    -        0      0
25   enet  100025     1500  -      -      -        -    -        0      0
26   enet  100026     1500  -      -      -        -    -        0      0
50   enet  100050     1500  -      -      -        -    -        0      0

VLAN Type  SAID       MTU   Parent RingNo BridgeNo Stp  BrdgMode Trans1 Trans2
---- ----- ---------- ----- ------ ------ -------- ---- -------- ------ ------
51   enet  100051     1500  -      -      -        -    -        0      0
100  enet  100100     1500  -      -      -        -    -        0      0
200  enet  100200     1500  -      -      -        -    -        0      0
300  enet  100300     1500  -      -      -        -    -        0      0
950  enet  100950     1500  -      -      -        -    -        0      0
1002 fddi  101002     1500  -      -      -        -    -        0      0
1003 tr    101003     1500  -      -      -        -    -        0      0
1004 fdnet 101004     1500  -      -      -        ieee -        0      0
1005 trnet 101005     1500  -      -      -        ibm  -        0      0

Remote SPAN VLANs
------------------------------------------------------------------------------


Primary Secondary Type              Ports
------- --------- ----------------- ------------------------------------------

AUS-6506#
END

our $stp = <<'END';
sh spanning-tree

VLAN0025
  Spanning tree enabled protocol ieee
  Root ID    Priority    32768
             Address     0011.5db2.7ad9
             This bridge is the root
             Hello Time   2 sec  Max Age 20 sec  Forward Delay 15 sec

  Bridge ID  Priority    32768
             Address     0011.5db2.7ad9
             Hello Time   2 sec  Max Age 20 sec  Forward Delay 15 sec
             Aging Time 300

Interface        Role Sts Cost      Prio.Nbr Type
---------------- ---- --- --------- -------- --------------------------------
Po275            Desg FWD 3         128.1665 Edge P2p


VLAN0026
  Spanning tree enabled protocol ieee
  Root ID    Priority    32768
             Address     0011.5db2.7ada
             This bridge is the root
             Hello Time   2 sec  Max Age 20 sec  Forward Delay 15 sec

  Bridge ID  Priority    32768
             Address     0011.5db2.7ada
             Hello Time   2 sec  Max Age 20 sec  Forward Delay 15 sec
             Aging Time 300

Interface        Role Sts Cost      Prio.Nbr Type
---------------- ---- --- --------- -------- --------------------------------
Po275            Desg FWD 3         128.1665 Edge P2p


VLAN0050
  Spanning tree enabled protocol ieee
  Root ID    Priority    32768
             Address     0011.5db2.7af2
             This bridge is the root
             Hello Time   2 sec  Max Age 20 sec  Forward Delay 15 sec

  Bridge ID  Priority    32768
             Address     0011.5db2.7af2
             Hello Time   2 sec  Max Age 20 sec  Forward Delay 15 sec
             Aging Time 300

Interface        Role Sts Cost      Prio.Nbr Type
---------------- ---- --- --------- -------- --------------------------------
Po275            Desg FWD 3         128.1665 Edge P2p


VLAN0051
  Spanning tree enabled protocol ieee
  Root ID    Priority    32768
             Address     0011.5db2.7af3
             This bridge is the root
             Hello Time   2 sec  Max Age 20 sec  Forward Delay 15 sec

  Bridge ID  Priority    32768
             Address     0011.5db2.7af3
             Hello Time   2 sec  Max Age 20 sec  Forward Delay 15 sec
             Aging Time 300

Interface        Role Sts Cost      Prio.Nbr Type
---------------- ---- --- --------- -------- --------------------------------
Po275            Desg FWD 3         128.1665 Edge P2p


VLAN0200
  Spanning tree enabled protocol ieee
  Root ID    Priority    32768
             Address     0011.5db2.7b88
             This bridge is the root
             Hello Time   2 sec  Max Age 20 sec  Forward Delay 15 sec

  Bridge ID  Priority    32768
             Address     0011.5db2.7b88
             Hello Time   2 sec  Max Age 20 sec  Forward Delay 15 sec
             Aging Time 300

Interface        Role Sts Cost      Prio.Nbr Type
---------------- ---- --- --------- -------- --------------------------------
Po275            Desg FWD 3         128.1665 Edge P2p


VLAN0300
  Spanning tree enabled protocol ieee
  Root ID    Priority    24801
             Address     0017.9445.ee80
             Cost        42
             Port        281 (FastEthernet3/25)
             Hello Time   2 sec  Max Age 20 sec  Forward Delay 15 sec

  Bridge ID  Priority    32768
             Address     0011.5db2.7bec
             Hello Time   2 sec  Max Age 20 sec  Forward Delay 15 sec
             Aging Time 300

Interface        Role Sts Cost      Prio.Nbr Type
---------------- ---- --- --------- -------- --------------------------------
Fa3/25           Root FWD 19        128.281  P2p
Po275            Desg FWD 3         128.1665 Edge P2p

AUS-6506#
END

our $vtp_status = <<'END_VTP';
AUS-6506#sh vtp status
VTP Version                     : 2
Configuration Revision          : 0
Maximum VLANs supported locally : 1005
Number of existing VLANs        : 13
VTP Operating Mode              : Transparent
VTP Domain Name                 :
VTP Pruning Mode                : Disabled
VTP V2 Mode                     : Disabled
VTP Traps Generation            : Disabled
MD5 digest                      : 0x3E 0x83 0x64 0x61 0x15 0x7F 0xA9 0x73
Configuration last modified by 0.0.0.0 at 0-0-00 00:00:00
AUS-6506#
END_VTP
