package DataTiara;

use strict;
use warnings;
use Exporter 'import';
our @EXPORT_OK = qw($responsesTiara);

our $responsesTiara = {};

$responsesTiara->{startupConfig} = <<'END';

# Tasman Networks Inc. system configuration file (.CFG).
#
# Tasman Networks Inc. assumes no responsibility for product reliability,
# performance, or both if the user modifies the .CFG file.  Full
# responsibility for any modification made to the .CFG file, by
# the user, is assumed by the user.
#
# Version: r8.2.1
# File Created: 02/01/2008-14:29:06



module  t1 1
    exit t1
module  t1 2
    exit t1
module  t1 3
    exit t1
module  t1 4
    exit t1
interface  ethernet 0
    mtu 2000
    exit ethernet
interface  ethernet 1
    ip  address 10.100.3.4 255.255.255.0
    exit ethernet
snmp-server
  community public ro
  community testenv rw
  contact "change2"
  location costarica
  chassis-id Tasman-1200
  exit snmp-server
hostname Tasman-1200
log utc
ssh_server
  enable
  exit ssh_server
system  alarm_relay closed
system  hdlc_error 1000
ip
  load_balance per_flow
  route 0.0.0.0 0.0.0.0 10.100.3.1 1
  exit ip
firewall global
  exit firewall
firewall internet
  exit firewall
firewall corp
  policy 1024 out
    exit policy
  exit firewall

Tasman-1200#



END

$responsesTiara->{runningConfig} = <<'END';

Please wait... (up to a minute)


module  t1 1
    exit t1
module  t1 2
    exit t1
module  t1 3
    exit t1
module  t1 4
    exit t1
interface  ethernet 0
    mtu 2000
    exit ethernet
interface  ethernet 1
    ip  address 10.100.3.4 255.255.255.0
    exit ethernet
snmp-server
  community public ro
  community testenv rw
  contact "change2"
  location costarica
  chassis-id Tasman-1200
  enable  traps
      bgp trap_est established trap_back backward
      exit traps
  exit snmp-server
hostname Tasman-1200
log utc
ssh_server
  enable
  exit ssh_server
system  alarm_relay closed
system  hdlc_error 1000
ip
  load_balance per_flow
  route 0.0.0.0 0.0.0.0 10.100.3.1 1
  exit ip
firewall global
  exit firewall
firewall internet
  exit firewall
firewall corp
  policy 1024 out
    exit policy
  exit firewall

Tasman-1200#


END

$responsesTiara->{system} = <<'END';
Tasman-1200# show system configuration

----------------------------------------
NCM System Configuration:

Hardware Status:

DRAM quantity:  256MB
DRAM type:      SDRAM
Flash:          16MB
Model Number:   1200
Serial Number:  12000ATAD5750002
Processor ID:   IDT R5000 150MHz
Processor Rev:  33
Board Revision: B
Internal Level 2 Cache:  NO (0000K)
External Level 2 Cache:  NO  (0000K)
Level 3 Cache:  NO  (0000K)

----------------------------------------
Interface Card 1 System Configuration:
        Interface Card Type:    QT1
        RAM Size:               16MB
        Flash Memory Size:      2MB


----------------------------------------
VPN Accelerator card is not present
WAN Interface ports -
             T1 - 4 ports available

----------------------------------------
Alarm Relay:    closed when there is no alarm

----------------------------------------
Software Status:

Application Image Version:  r8.2.1
Mode:              Routing

----------------------------------------
Tasman-1200#


END

$responsesTiara->{snmp}->{sysContact} = 'change2';
$responsesTiara->{snmp}->{sysDescr} = 'Tasman Networks Inc. Snmp Agent';
$responsesTiara->{snmp}->{sysLocation} = 'costarica';
$responsesTiara->{snmp}->{sysName} = 'Tasman-1200';
$responsesTiara->{snmp}->{sysObjectId} = '.1.3.6.1.4.1.3174.1.7';

$responsesTiara->{interfaces}->{interface}[0]->{adminStatus} = 'up';
$responsesTiara->{interfaces}->{interface}[0]->{interfaceType} = 'other';
$responsesTiara->{interfaces}->{interface}[0]->{mtu} = 0;
$responsesTiara->{interfaces}->{interface}[0]->{name} = 'T1 4';
$responsesTiara->{interfaces}->{interface}[0]->{physical} = 'true';
$responsesTiara->{interfaces}->{interface}[0]->{speed} = 1544000;

$responsesTiara->{interfaces}->{interface}[1]->{adminStatus} = 'up';
$responsesTiara->{interfaces}->{interface}[1]->{interfaceType} = 'other';
$responsesTiara->{interfaces}->{interface}[1]->{mtu} = 0;
$responsesTiara->{interfaces}->{interface}[1]->{name} = 'null';
$responsesTiara->{interfaces}->{interface}[1]->{physical} = 'true';
$responsesTiara->{interfaces}->{interface}[1]->{speed} = 0;


$responsesTiara->{files} = <<'END';
Tasman-1200# show flash

CONTENTS OF /flash1:

  size          date       time       name
--------       ------     ------    --------
 7234981    JUL-28-2005  12:25:22   NCM.Z
  790444    JUL-28-2005  12:25:48   IC.Z
     229    NOV-10-2005  20:56:12   SHRSAKEY.PUB
    1111    FEB-01-2008  14:29:08   SYSTEM.CFG
     887    NOV-10-2005  20:56:08   SHRSAKEY
     672    NOV-10-2005  21:02:54   SHDSAKEY
     609    NOV-10-2005  21:02:58   SHDSAKEY.PUB

Total bytes:  8028933
Bytes Free on /flash1:   7602176
Tasman-1200#


END

$responsesTiara->{version} = <<'END';
Tasman-1200# show version
ASSEMBLY VERSION        : B
PCB REVISION            : B
NCM BOOT VERSION        : d5b060602
NCM SW VERSION          : r8.2.1
Tasman-1200#

END

$responsesTiara->{routes} = <<'END';
Tasman-1200# show ip routes protocol static
Codes: C - connected, S - static, O - OSPF, R - RIP, B - BGP, A - Aggregate,
       D - directly connected, OA - OSPF intra area, IA - OSPF inter area,
       N1 - OSPF NSSA external type 1, N2 - OSPF NSSA external type 2,
       E1 - OSPF external type 1, E2 - OSPF external type 2, X - Redirect

IP Load balancing policy is per_flow

     Network            Next Hop        Interface    PVC# Distance   Metric
     -------            --------        ----------------- --------   ------
S    0.0.0.0/0          10.100.3.1      ethernet1         1          0
Tasman-1200#


END



