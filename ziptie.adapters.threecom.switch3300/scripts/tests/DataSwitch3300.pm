package DataSwitch3300;

use strict;
use warnings;
use Exporter 'import';
our @EXPORT_OK = qw($responsesThreeCom);

our $responsesThreeCom = {};

$responsesThreeCom->{'system'} = <<'END';

Select menu option: system display
3Com SuperStack II
System Name             : 3Com 3300
Location                : Lab
Contact                 : Eric Basham

Time Since Reset                : 7302 Hrs 25 Mins 54 Seconds
Operational Version             : 2.66
Hardware Version                : 2
Boot Version                    : 1.00
MAC Address                     : 00:30:1e:34:47:b8
Product Number                  : 3C16980
Serial Number                   : KZNS43447B8

Select menu option:


END


$responsesThreeCom->{interfaces}->{interface}[0]->{adminStatus} = 'up';
$responsesThreeCom->{interfaces}->{interface}[0]->{interfaceType} = 'other';
$responsesThreeCom->{interfaces}->{interface}[0]->{mtu} = 1500;
$responsesThreeCom->{interfaces}->{interface}[0]->{name} = 'Local Workgroup Encapsulation Tag 9';
$responsesThreeCom->{interfaces}->{interface}[0]->{physical} = 'true';
$responsesThreeCom->{interfaces}->{interface}[0]->{speed} = 0;

$responsesThreeCom->{interfaces}->{interface}[1]->{adminStatus} = 'up';
$responsesThreeCom->{interfaces}->{interface}[1]->{interfaceType} = 'other';
$responsesThreeCom->{interfaces}->{interface}[1]->{mtu} = 1500;
$responsesThreeCom->{interfaces}->{interface}[1]->{name} = '802.1Q Encapsulation Tag 3001';
$responsesThreeCom->{interfaces}->{interface}[1]->{physical} = 'true';
$responsesThreeCom->{interfaces}->{interface}[1]->{speed} = 0;


$responsesThreeCom->{users} = <<'END';
Select menu option: system security user display

Name           Access Level   Community String
admin          security       private
manager        manager        manager
monitor        monitor        public
testlab        security       testlab
security       security       testenv

Select menu option:

END


$responsesThreeCom->{snmp}->{sysContact} = 'Eric Basham';
$responsesThreeCom->{snmp}->{sysDescr} = '3Com SuperStack II';
$responsesThreeCom->{snmp}->{sysLocation} = 'Lab';
$responsesThreeCom->{snmp}->{sysName} = '3Com 3300';
$responsesThreeCom->{snmp}->{sysObjectId} = '.1.3.6.1.4.1.43.10.27.4.1.2.2';


$responsesThreeCom->{stp} = <<'END';
Select menu option: bridge display


stpState:       enabled         agingTime:      1800

Time since topology change:             3 hrs 2 mins 48 seconds
Topology Changes:                       554
Bridge Identifier:                      8000 00301e3447b8
Designated Root:                        60ca 00179445ee80

maxAge:                 20              bridgeMaxAge:           20
helloTime:              2               bridgeHelloTime:        2
forwardDelay:           15              bridgeFwdDelay:         15
holdTime:               1               rootCost:               41
rootPort:               7               priority:               0x8000

Select menu option:

END


$responsesThreeCom->{vlan}->{'1'} = <<'END';
Select menu option: bridge vlan detail 1

VLAN ID: 1      Local ID: 1     Name: Default VLAN

Unit            Ports
1               2, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19,
                20, 21, 22, 23, 24

Unicast Frames:         21797935        Octets:                 1828593669
Multicast Frames:       24145686        Broadcast Frames:       1755974

Select menu option:
 
END


$responsesThreeCom->{vlan}->{'2'}= <<'END';
Select menu option: bridge vlan detail 2

VLAN ID: 2      Local ID: 2     Name: .15

Unit            Ports
1               6

Unicast Frames:         0               Octets:                 0
Multicast Frames:       0               Broadcast Frames:       0

Select menu option:
 
END


$responsesThreeCom->{vlan}->{'5'} = <<'END';
Select menu option: bridge vlan detail 5

VLAN ID: 5      Local ID: 5     Name: protocol

Unit            Ports
1               6

Unicast Frames:         0               Octets:                 0
Multicast Frames:       0               Broadcast Frames:       0

Select menu option:

  
END


$responsesThreeCom->{vlan}->{'7'} = <<'END';
Select menu option:  bridge vlan detail 7

VLAN ID: 7      Local ID: 7     Name: VLAN 7

Unit            Ports
1               6

Unicast Frames:         0               Octets:                 0
Multicast Frames:       0               Broadcast Frames:       0

Select menu option:

 
END

