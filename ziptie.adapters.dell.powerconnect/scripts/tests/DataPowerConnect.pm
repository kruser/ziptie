package DataPowerConnect;

use strict;
use warnings;
use Exporter 'import';
our @EXPORT_OK = qw($responsesDPC);

our $responsesDPC = {};

$responsesDPC->{'running-config'} = <<'END';


interface ethernet 1/e1
description "Management port with autocrossover"
exit
vlan database
vlan 23
exit
interface ethernet 1/e1
switchport access vlan 23
exit
interface vlan 23
ip address 10.100.3.10 255.255.255.0
exit
ip default-gateway 10.100.3.1
hostname Dellswitch
line console
exec-timeout 60
exit
line telnet
exec-timeout 60
exit
radius-server host 10.100.32.137 auth-port  1812     source 0.0.0.0 
radius-server key cisco


logging 10.10.1.89   
aaa authentication enable default enable 
aaa authentication login default local 
enable password level 15 c7c54e3f90b1bc36934a6a68202d1b6d encrypted
username brandon password 7baa6d93380e30bd4a30d83c977d505b level 15 encrypted
username bshopp password 7baa6d93380e30bd4a30d83c977d505b level 7 encrypted
username testlab password 7baa6d93380e30bd4a30d83c977d505b  encrypted
snmp-server host 1.1.1.1 password
snmp-server host 10.10.1.95 public
snmp-server host 10.10.1.119 testenv
snmp-server location Testing12345
snmp-server contact hoops
snmp-server community Testing132 su
snmp-server community public
snmp-server community testenv rw
snmp-server community testing123
snmp-server community testing321 rw
snmp-server community password 1.1.1.1
snmp-server community public 10.10.1.95
snmp-server community testenv 10.10.1.119


END

$responsesDPC->{'startup-config'} = <<'END';


interface ethernet 1/e1
description "Management port with autocrossover"
exit
vlan database
vlan 23
exit
interface ethernet 1/e1
switchport access vlan 23
exit
interface vlan 23
ip address 10.100.3.10 255.255.255.0
exit
ip default-gateway 10.100.3.1
hostname Dellswitch
line console
exec-timeout 60
exit
line telnet
exec-timeout 60
exit
radius-server host 10.100.32.137 auth-port  1812     source 0.0.0.0 
radius-server key cisco


logging 10.10.1.89   
aaa authentication enable default enable 
aaa authentication login default local 
enable password level 15 c7c54e3f90b1bc36934a6a68202d1b6d encrypted
username brandon password 7baa6d93380e30bd4a30d83c977d505b level 15 encrypted
username bshopp password 7baa6d93380e30bd4a30d83c977d505b level 7 encrypted
username testlab password 7baa6d93380e30bd4a30d83c977d505b  encrypted
snmp-server host 1.1.1.1 password
snmp-server host 10.10.1.95 public
snmp-server host 10.10.1.119 testenv
snmp-server location Testing12345
snmp-server contact hoops
snmp-server community Testing132 su
snmp-server community public
snmp-server community testenv rw
snmp-server community testing123
snmp-server community testing321 rw
snmp-server community password 1.1.1.1
snmp-server community public 10.10.1.95
snmp-server community testenv 10.10.1.119


END

$responsesDPC->{'version'} = <<'END';
show version

SW version    1.2.0.6 ( date  15-Nov-2004 time  14:22:46 )
Boot version    1.0.0.13 ( date  11-May-2003 time  14:58:20 )
HW version    00.00.01


END

$responsesDPC->{'system'} = <<'END';
show system

System Description:                       Ethernet Stackable Switching System
System Up Time (days,hour:min:sec):       265,03:34:54
System Contact:                           hoops
System Name:                              Dellswitch
System Location:                          Testing12345
MAC Address:                              00:0b:db:f4:85:14
Sys Object ID:                            1.3.6.1.4.1.674.10895.3002


Type:  3324



         Power supply               Source       Status    
--------------------------------- ------------ ------------ 
  Internal PowerSupply unit1          AC           OK      




END

$responsesDPC->{'interfaces'} = <<'END';
show interfaces configuration

                                               Flow    Admin     Back   Mdix
Port     Type         Duplex  Speed  Neg      control  State   Pressure Mode
........ ............ ......  .....  ........ .......  .....   ........ ....
1/e1     100M-Copper  Full    100    Enabled  Off      Up      Disabled Auto
1/e2     100M-Copper  Full    100    Enabled  Off      Up      Disabled Auto
1/e3     100M-Copper  Full    100    Enabled  Off      Up      Disabled Auto
1/e4     100M-Copper  Full    100    Enabled  Off      Up      Disabled Auto
1/e5     100M-Copper  Full    100    Enabled  Off      Up      Disabled Auto
1/e6     100M-Copper  Full    100    Enabled  Off      Up      Disabled Auto
1/e7     100M-Copper  Full    100    Enabled  Off      Up      Disabled Auto
1/e8     100M-Copper  Full    100    Enabled  Off      Up      Disabled Auto
1/e9     100M-Copper  Full    100    Enabled  Off      Up      Disabled Auto
1/e10    100M-Copper  Full    100    Enabled  Off      Up      Disabled Auto
1/e11    100M-Copper  Full    100    Enabled  Off      Up      Disabled Auto
1/e12    100M-Copper  Full    100    Enabled  Off      Up      Disabled Auto
1/e13    100M-Copper  Full    100    Enabled  Off      Up      Disabled Auto
1/e14    100M-Copper  Full    100    Enabled  Off      Up      Disabled Auto
1/e15    100M-Copper  Full    100    Enabled  Off      Up      Disabled Auto
1/e16    100M-Copper  Full    100    Enabled  Off      Up      Disabled Auto
1/e17    100M-Copper  Full    100    Enabled  Off      Up      Disabled Auto
1/e18    100M-Copper  Full    100    Enabled  Off      Up      Disabled Auto
1/e19    100M-Copper  Full    100    Enabled  Off      Up      Disabled Auto

1/e21    100M-Copper  Full    100    Enabled  Off      Up      Disabled Auto
1/e22    100M-Copper  Full    100    Enabled  Off      Up      Disabled Auto
1/e23    100M-Copper  Full    100    Enabled  Off      Up      Disabled Auto
1/e24    100M-Copper  Full    100    Enabled  Off      Up      Disabled Auto
1/e25         --      Full      --   Enabled  Off      Up      Disabled Auto
1/e26         --      Full      --   Enabled  Off      Up      Disabled Auto
1/e27         --      Full      --   Enabled  Off      Up      Disabled Auto
1/e28         --      Full      --   Enabled  Off      Up      Disabled Auto
1/e29         --      Full      --   Enabled  Off      Up      Disabled Auto
1/e30         --      Full      --   Enabled  Off      Up      Disabled Auto
1/e31         --      Full      --   Enabled  Off      Up      Disabled Auto
1/e32         --      Full      --   Enabled  Off      Up      Disabled Auto
1/e33         --      Full      --   Enabled  Off      Up      Disabled Auto
1/e34         --      Full      --   Enabled  Off      Up      Disabled Auto
1/e35         --      Full      --   Enabled  Off      Up      Disabled Auto
1/e36         --      Full      --   Enabled  Off      Up      Disabled Auto
1/e37         --      Full      --   Enabled  Off      Up      Disabled Auto
1/e38         --      Full      --   Enabled  Off      Up      Disabled Auto
1/e39         --      Full      --   Enabled  Off      Up      Disabled Auto
1/e40         --      Full      --   Enabled  Off      Up      Disabled Auto
1/e41         --      Full      --   Enabled  Off      Up      Disabled Auto

1/e43         --      Full      --   Enabled  Off      Up      Disabled Auto
1/e44         --      Full      --   Enabled  Off      Up      Disabled Auto
1/e45         --      Full      --   Enabled  Off      Up      Disabled Auto
1/e46         --      Full      --   Enabled  Off      Up      Disabled Auto
1/e47         --      Full      --   Enabled  Off      Up      Disabled Auto
1/e48         --      Full      --   Enabled  Off      Up      Disabled Auto
1/g1     1G-Combo-C   Full    1000   Enabled  Off      Up      Disabled Auto
1/g2     1G-Combo-C   Full    1000   Enabled  Off      Up      Disabled Auto

                                 Flow    Admin     Back
Ch       Type    Speed  Neg      control  State   Pressure
........ ....... .....  ........ .......  .....   ........
ch1         --     --   Enabled  Off      Up      Disabled
ch2         --     --   Enabled  Off      Up      Disabled
ch3         --     --   Enabled  Off      Up      Disabled
ch4         --     --   Enabled  Off      Up      Disabled
ch5         --     --   Enabled  Off      Up      Disabled
ch6         --     --   Enabled  Off      Up      Disabled


END

$responsesDPC->{'stp'} = <<'END';
show spanning-tree



Spanning tree enabled mode STP


 Root ID    Priority    24779
            Address     00:17:94:45:ee:80
            Cost        42
            Port        1/e1
            Hello Time  2 sec  Max Age 20 sec  Forward Delay 15 sec
 Bridge ID  Priority    32768
            Address     00:0b:db:f4:85:14
            Hello Time  2 sec  Max Age 20 sec  Forward Delay 15 sec
 Number of topology changes 1 last change occurred 347:25:47 ago
 Times:  hold 1, topology change 35, notification 2
         hello 2, max age 20, forward delay 15

Interface Port ID                   Designated                       Port ID  
Name  Prio  Sts    Enb    Cost      Cost           Bridge Id         Prio.Nbr 
------ ---- ------ ----- --------- --------- ------------------------ -------- 
1/e1  128   FRW   TRUE     19        23     32971 00:12:d9:e0:4b:80   128 1   
1/e2  128   DSBL  TRUE     100        0     32768 00:0b:db:f4:85:14   128 2   

1/e4  128   DSBL  TRUE     100        0     32768 00:0b:db:f4:85:14   128 4   
1/e5  128   DSBL  TRUE     100        0     32768 00:0b:db:f4:85:14   128 5   
1/e6  128   DSBL  TRUE     100        0     32768 00:0b:db:f4:85:14   128 6   
1/e7  128   DSBL  TRUE     100        0     32768 00:0b:db:f4:85:14   128 7   
1/e8  128   DSBL  TRUE     100        0     32768 00:0b:db:f4:85:14   128 8   
1/e9  128   DSBL  TRUE     100        0     32768 00:0b:db:f4:85:14   128 9   
1/e10  128   DSBL  TRUE     100        0     32768 00:0b:db:f4:85:14   128 10  
1/e11  128   DSBL  TRUE     100        0     32768 00:0b:db:f4:85:14   128 11  
1/e12  128   DSBL  TRUE     100        0     32768 00:0b:db:f4:85:14   128 12  
1/e13  128   DSBL  TRUE     100        0     32768 00:0b:db:f4:85:14   128 13  
1/e14  128   DSBL  TRUE     100        0     32768 00:0b:db:f4:85:14   128 14  
1/e15  128   DSBL  TRUE     100        0     32768 00:0b:db:f4:85:14   128 15  
1/e16  128   DSBL  TRUE     100        0     32768 00:0b:db:f4:85:14   128 16  
1/e17  128   DSBL  TRUE     100        0     32768 00:0b:db:f4:85:14   128 17  
1/e18  128   DSBL  TRUE     100        0     32768 00:0b:db:f4:85:14   128 18  
1/e19  128   DSBL  TRUE     100        0     32768 00:0b:db:f4:85:14   128 19  
1/e20  128   DSBL  TRUE     100        0     32768 00:0b:db:f4:85:14   128 20  
1/e21  128   DSBL  TRUE     100        0     32768 00:0b:db:f4:85:14   128 21  
1/e22  128   DSBL  TRUE     100        0     32768 00:0b:db:f4:85:14   128 22  
1/e23  128   DSBL  TRUE     100        0     32768 00:0b:db:f4:85:14   128 23  
1/e24  128   DSBL  TRUE     100        0     32768 00:0b:db:f4:85:14   128 24  

1/e26  128   DSBL  TRUE     100        0     32768 00:0b:db:f4:85:14   128 26  
1/e27  128   DSBL  TRUE     100        0     32768 00:0b:db:f4:85:14   128 27  
1/e28  128   DSBL  TRUE     100        0     32768 00:0b:db:f4:85:14   128 28  
1/e29  128   DSBL  TRUE     100        0     32768 00:0b:db:f4:85:14   128 29  
1/e30  128   DSBL  TRUE     100        0     32768 00:0b:db:f4:85:14   128 30  
1/e31  128   DSBL  TRUE     100        0     32768 00:0b:db:f4:85:14   128 31  
1/e32  128   DSBL  TRUE     100        0     32768 00:0b:db:f4:85:14   128 32  
1/e33  128   DSBL  TRUE     100        0     32768 00:0b:db:f4:85:14   128 33  
1/e34  128   DSBL  TRUE     100        0     32768 00:0b:db:f4:85:14   128 34  
1/e35  128   DSBL  TRUE     100        0     32768 00:0b:db:f4:85:14   128 35  
1/e36  128   DSBL  TRUE     100        0     32768 00:0b:db:f4:85:14   128 36  
1/e37  128   DSBL  TRUE     100        0     32768 00:0b:db:f4:85:14   128 37  
1/e38  128   DSBL  TRUE     100        0     32768 00:0b:db:f4:85:14   128 38  
1/e39  128   DSBL  TRUE     100        0     32768 00:0b:db:f4:85:14   128 39  
1/e40  128   DSBL  TRUE     100        0     32768 00:0b:db:f4:85:14   128 40  
1/e41  128   DSBL  TRUE     100        0     32768 00:0b:db:f4:85:14   128 41  
1/e42  128   DSBL  TRUE     100        0     32768 00:0b:db:f4:85:14   128 42  
1/e43  128   DSBL  TRUE     100        0     32768 00:0b:db:f4:85:14   128 43  
1/e44  128   DSBL  TRUE     100        0     32768 00:0b:db:f4:85:14   128 44  
1/e45  128   DSBL  TRUE     100        0     32768 00:0b:db:f4:85:14   128 45  
1/e46  128   DSBL  TRUE     100        0     32768 00:0b:db:f4:85:14   128 46  

1/e48  128   DSBL  TRUE     100        0     32768 00:0b:db:f4:85:14   128 48  
1/g1  128   DSBL  TRUE     100        0     32768 00:0b:db:f4:85:14   128 49  
1/g2  128   DSBL  TRUE     100        0     32768 00:0b:db:f4:85:14   128 50  
ch1   128   DSBL  TRUE      4         0     32768 00:0b:db:f4:85:14   128 51  
ch2   128   DSBL  TRUE      4         0     32768 00:0b:db:f4:85:14   128 52  
ch3   128   DSBL  TRUE      4         0     32768 00:0b:db:f4:85:14   128 53  
ch4   128   DSBL  TRUE      4         0     32768 00:0b:db:f4:85:14   128 54  
ch5   128   DSBL  TRUE      4         0     32768 00:0b:db:f4:85:14   128 55  
ch6   128   DSBL  TRUE      4         0     32768 00:0b:db:f4:85:14   128 56  




END

$responsesDPC->{'vlans'} = <<'END';

show vlan
Vlan               Name                          Ports                Type
---- -------------------------------- --------------------------- ------------
 1                  1                 1/e(2-48),1/g(1-2),ch(1-6)     other
 23                 23                           1/e1              permanent

END
 