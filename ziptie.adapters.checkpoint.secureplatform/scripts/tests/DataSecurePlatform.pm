package DataSecurePlatform;

use strict;
use warnings;
use Exporter 'import';
our @EXPORT_OK = qw($responses);

our $responses = {};

$responses->{hostname} = <<'END_HOSTNAME';
hostname
cpspp
[Expert@cpspp]# 
END_HOSTNAME

$responses->{users} = <<'END_USERS';
showusers
admin
rkruse
[Expert@cpspp]# 
END_USERS

$responses->{routes} = <<'END_ROUTE';
route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
224.0.0.2       0.0.0.0         255.255.255.255 UHD   0      0        0 lo
127.0.0.1       0.0.0.0         255.255.255.255 UH    0      0        0 lo
10.100.20.108   0.0.0.0         255.255.255.252 U     0      0        0 eth1
10.100.4.0      0.0.0.0         255.255.255.0   U     0      0        0 eth0
127.0.0.0       -               255.0.0.0       !D    0      -        0 -
0.0.0.0         10.100.4.1      0.0.0.0         UG    0      0        0 eth0
[Expert@cpspp]#
END_ROUTE

$responses->{interfaces} = <<'END_INTS';
ifconfig -a
eth0      Link encap:Ethernet  HWaddr 00:02:B3:B4:0D:87  
          inet addr:10.100.4.10  Bcast:10.100.4.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:25694 errors:0 dropped:0 overruns:0 frame:0
          TX packets:26728 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:100 
          RX bytes:2339789 (2.2 Mb)  TX bytes:15131065 (14.4 Mb)
          Base address:0xc000 Memory:ff8e0000-ff900000 

eth1      Link encap:Ethernet  HWaddr 00:E0:81:22:78:70  
          inet addr:10.100.20.109  Bcast:10.100.20.111  Mask:255.255.255.252
          UP BROADCAST MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)
          Interrupt:4 Base address:0xc400 Memory:ff8de000-ff8de038 

eth2      Link encap:Ethernet  HWaddr 00:E0:81:22:78:71  
          BROADCAST MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)
          Interrupt:10 Base address:0xc800 Memory:ff8df000-ff8df038 

lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          UP LOOPBACK RUNNING  MTU:16436  Metric:1
          RX packets:2892 errors:0 dropped:0 overruns:0 frame:0
          TX packets:2892 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:357883 (349.4 Kb)  TX bytes:357883 (349.4 Kb)
          
[Expert@cpspp]# 
END_INTS

$responses->{snmp} = <<'END_SNMP';
cat /etc/snmp/snmpd.conf 
###########################################################################
#
# snmpd.conf
#
#   - created by the snmpconf configuration program
#
###########################################################################

###########################################################################
# SECTION: Extending the Agent
#
#   You can extend the snmp agent to have it return information
#   that you yourself define.

# pass: Run a command that intepretes the request for an entire tree.
#   The pass program defined here will get called for all
#   requests below a certain point in the mib tree.  It is then
#   responsible for returning the right data beyond that point.
#   
#   arguments: miboid program
#   
#   example: pass .1.3.6.1.4.1.2021.255 /path/to/local/passtest
#   
#   See the snmpd.conf manual page for further information.
#   
#   Consider using "pass_persist" for a performance increase.

master agentx

###########################################################################
# SECTION: Monitor Various Aspects of the Running Host
#
#   The following check up on various aspects of a host.

# proc: Check for processes that should be running.
#     proc NAME [MAX=0] [MIN=0]
#   
#     NAME:  the name of the process to check for.  It must match
#            exactly (ie, http will not find httpd processes).
#     MAX:   the maximum number allowed to be running.  Defaults to 0.
#     MIN:   the minimum number to be running.  Defaults to 0.
#   
#   The results are reported in the prTable section of the UCD-SNMP-MIB tree
#   Special Case:  When the min and max numbers are both 0, it assumes
#   you want a max of infinity and a min of 1.

# disk: Check for disk space usage of a partition.
#   The agent can check the amount of available disk space, and make
#   sure it is above a set limit.  
#   
#    disk PATH [MIN=100000]
#   
#    PATH:  mount path to the disk in question.
#    MIN:   Disks with space below this value will have the Mib's errorFlag set.
#           Can be a raw byte value or a percentage followed by the %
#           symbol.  Default value = 100000.
#   
#   The results are reported in the dskTable section of the UCD-SNMP-MIB tree


# load: Check for unreasonable load average values.
#   Watch the load average levels on the machine.
#   
#    load [1MAX=12.0] [5MAX=12.0] [15MAX=12.0]
#   
#    1MAX:   If the 1 minute load average is above this limit at query
#            time, the errorFlag will be set.
#    5MAX:   Similar, but for 5 min average.
#    15MAX:  Similar, but for 15 min average.
#   
#   The results are reported in the laTable section of the UCD-SNMP-MIB tree


###########################################################################
# SECTION: System Information Setup
#
#   This section defines some of the information reported in
#   the "system" mib group in the mibII tree.

# syslocation: The [typically physical] location of the system.
#   arguments:  location_string

syslocation  "Unknown"

# syscontact: The contact information for the administrator
#   arguments:  contact_string

syscontact  Unknown

# sysservices: The proper value for the sysServices object.
#   arguments:  sysservices_number

sysservices 76

smuxpeer 1.3.6.1.4.1.4.3.1.4
[Expert@cpspp]# 
END_SNMP

1;