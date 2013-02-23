package DataBayRS;

use strict;
use warnings;
use Exporter 'import';
our @EXPORT_OK = qw($responsesBayRS);

our $responsesBayRS = {};

$responsesBayRS->{system_info} = <<'END';
show system information

show system information                          Oct 02, 2007 15:20:32 [GMT+12]


System Information:
-------------------

System Name:                                                   
    Contact: KrissyKrissyGolicGolic                            
   Location: rack4-austin-tx                                   
      Image: rel/14.20/ Created on Wed Feb 14 08:20:12 EST 2001.                                                                                            
MIB Version: x14.20                                            
    Up Time:   1 days  3 hr 37 min 36 sec
bcc> 

END

$responsesBayRS->{config_plain} = <<'END';
show config

Reading configuration information, please wait . . . done.
stack
#   build-date {Wed Feb 14 08:20:12 EST 2001} 
#   build-version {BayRS 14.20/rel BCC 14.20/rel builder vobadm} 
    contact KrissyKrissyGolicGolic 
#   description {Image: rel/14.20/ Created on Wed Feb 14 08:20:12 EST 2001.} 
    help-file-name {} 
    location rack4-austin-tx 
#   type asn 
#   uptime 9951446 
Port Config: Invalid Slot-Conn Combination for "ethernet/1/4/1"

bcc> 

END

$responsesBayRS->{memory} = <<'END';
show hardware memory

show hardware memory                             Oct 02, 2007 15:23:40 [GMT+12]


     Local    Global   Total
Slot Memory   Memory   Memory
---- -------- -------- --------
   1    12288     4096    16384
bcc> 

END

$responsesBayRS->{dinfo} = <<'END';
dinfo


VOL    STATE      TOTAL SIZE    FREE SPACE    CONTIG FREE SPACE
---------------------------------------------------------------
 1:    FORMATTED   20971520      13638962         13597602

bcc> 

END

$responsesBayRS->{dir} = <<'END';
dir


 Volume in drive 1: is 
 Directory of 1:

File Name             Size     Date      Day      Time
--------------------------------------------------------
asn.exe            7327300  09/19/2006  Tues.   14:30:53
config                5156  10/02/2007  Tues.   15:14:40

20971520 bytes - Total size
13638962 bytes - Available free space
13597602 bytes - Contiguous free space

bcc> 

END

$responsesBayRS->{backplane} = <<'END';
show hardware backplane

show hardware backplane                          Oct 02, 2007 15:35:03 [GMT+12]


          Backplane Type: asn                                               
      Backplane Revision: 0                                                 
 Backplane Serial Number: 0                                                 
bcc> 

END

$responsesBayRS->{sys_image} = <<'END';
show hardware image

show hardware image                              Oct 02, 2007 15:36:36 [GMT+12]


Slot File Name        Source                             Date and Time
---- ---------------- ---------------------------------- --------------------
   1 1:asn.exe        rel/14.20/                         Wed Feb 14 08:20:12 
                                                         EST 2001            
bcc> 

END

$responsesBayRS->{show_slots} = <<'END';
show hardware slots

show hardware slots                              Oct 02, 2007 15:39:07 [GMT+12]


                 Processor                        Net Module
----------------------------------------- ----------------------------
Slot Module           Revision Serial#    Module   Revision Serial No.
---- ---------------- -------- ---------- -------- -------- ----------
   1 asn2                   14     128857 denm            1     951767
   1 asn2                   14     128857 denm            1     969642
   1 asn2                   14     128857 dsnm1nis        5     108886
                                          dn                          
   1 asn2                   14     128857 dtnm            3     105204
bcc> 

END

$responsesBayRS->{show_daughter} = <<'END';
show hardware daughter_card

show hardware daughter_card                      Oct 02, 2007 15:40:10 [GMT+12]



Slot      Card Type      Revision    Serial No. 
-----  ---------------  -----------  -----------
    1  0                v0.00                  0
bcc> 

END

$responsesBayRS->{snmp} = <<'END';
show snmp community

show snmp community                              Oct 02, 2007 15:45:26 [GMT+12]

SNMP Management Communities:
---------------------------
      Community            Community
Index Name                 Access
----- -------------------- ------------
    1 public               read-write  
    2 public123            read-only   
    3 testenv123           read-write  

SNMP Managers Information:
-------------------------
Manager         Manager         Trap   Trap       Community
Address         Name            Port   Type       Name
--------------- --------------- ------ ---------- --------------------
0.0.0.0                            162 generic    public              
10.10.1.79                         162 all        public              
10.10.1.91                         162 all        public              
10.10.1.246                        162 all        public              
bcc> 

END

$responsesBayRS->{interfaces} = <<'END';
show ethernet detail

show ethernet detail                             Oct 02, 2007 15:42:23 [GMT+12]


Name: E121   Number: 101201   Slot/Connector:  1/21
Admin State: up   Operational State: up   Up/Down Time: 1d03h59m

MAC Address: 00.00.A2.FD.DC.91
MTU: 1518   Line Speed: 10BASE-T Mpbs   HW Filter: disable 
BOFL: enable   BOFL TMO: 5

IP Address: 10.100.23.3   Mask: 255.255.255.0
Encapsulation: enet   ARP Type: arp

                          Receive                                Transmit
Receive      Receive      Average      Transmit     Transmit     Average
Bytes        Frames       Packet       Bytes        Frames       Packet
------------ ------------ ------------ ------------ ------------ ------------
     9490028       123377           76      6393504        66963           95

Transmit     .------Total Errors-----. .---Number of Buffers---.
Deferred     Receive      Transmit     Receive      Transmit
------------ ------------ ------------ ------------ ------------
         153            0            0           63           63

Multicast Receive: 84928

RECEIVE ERRORS:

Checksum  Alignment Overflow  Frames    Symbol    Internal   Late
Errors    Errors    Errors    TooLong   Errors    MAC Errors Collision
--------- --------- --------- --------- --------- ---------- ---------
        0         0         0         0         0          0         0

TRANSMIT ERRORS:

Frames     Underflow  Internal    Deadlock   Excessive   Late
Too Long   Errors     MAC Errors  Errors     Collisions  Collisions
---------- ---------- ----------- ---------- ----------- -----------
         0          0          0          0          0          0

SYSTEM ERRORS:

Memory     Collision  Internal   Loss Of
Errors     Errors     Errors     Carrier
---------- ---------- ---------- ----------
         0          0          0          0

PROTOCOLS CONFIGURED:

IP ARP 
bcc> 

END

$responsesBayRS->{ip_routes} = <<'END';
show ip routes

show ip routes                                   Oct 02, 2007 15:44:10 [GMT+12]

Network/Mask        Proto        Age Slot     Cost  NextHop Address     AS
------------------- ------ --------- ---- --------- ---------------- -----
0.0.0.0/0           Static    100847    1         1 10.100.23.1           
10.100.23.0/24      Direct    100849    1         0 10.100.23.3           

   Total Networks on Slot 1 = 2

bcc> 

END

