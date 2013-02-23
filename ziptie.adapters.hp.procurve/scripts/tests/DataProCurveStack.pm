package DataProCurveStack;

use warnings;
use Exporter 'import';
our @EXPORT_OK = qw($responsesHP2500);

our $responsesHP2500 = {};

$responsesHP2500->{sysDescr} = <<'SYS_DESCR';
sysDescr.0 = HP J4813A ProCurve Switch 2524, revision F.05.17, ROM F.01.01  (/sw
/code/build/info(s02))
hp2524#
SYS_DESCR

$responsesHP2500->{running_config} = <<'END_RUNNING_CONFIG';                                                    
                                                                                
Running configuration:                                                          
                                                                                
; J4813A Configuration Editor; Created on release #F.05.17                      
                                                                                
hostname "hp2524"                                                               
snmp-server contact "Changed1"                                                  
snmp-server location "CostaRica"                                                
cdp run                                                                         
interface 5                                                                     
   name "Mave!!!!!"                                                             
   flow-control                                                                 
   speed-duplex 10-half                                                         
exit                                                                            
ip default-gateway 10.100.2.1                                                   
no timesync                                                                     
snmp-server community "public" Unrestricted                                     
snmp-server community "testenv" Unrestricted                                    
snmp-server community "testing123" Operator                                     
snmp-server community "testing321"                                              
snmp-server community "operator" Operator                                       
snmp-server host 10.10.1.89 "traps"                                             
snmp-server host 1.1.1.1 "public" Debug                                         
snmp-server host 10.10.1.119 "testenv" All                                      
vlan 1                                                                          
   name "rifetest"                                                              
   untagged 1-4,6-26                                                            
   ip address 10.100.2.16 255.255.255.0                                         
   no untagged 5                                                                
   exit                                                                         
vlan 5                                                                          
   name "icemanvlan"                                                            
   untagged 5                                                                   
   ip address 10.10.100.1 255.255.255.0                                         
   exit                                                                         
ip authorized-managers 10.0.0.0 255.0.0.0                                       
ip authorized-managers 192.168.0.0 255.255.0.0                                  
ip route 0.0.0.0 0.0.0.0 10.100.2.1                                             
no stack auto-join                                                              
aaa authentication telnet login tacacs local                                    
aaa authentication telnet enable tacacs local                                   
aaa authentication ssh login tacacs local                                       
aaa authentication ssh enable tacacs local                                      
tacacs-server host 10.100.32.137 key cisco                                      
ip ssh                                                                          
ip ssh key-size 1024                                                            
no aaa port-access authenticator active                                         
spanning-tree                                                                   
password manager                                                                
password operator                                                               
                                                                                
hp2524#                                                                         
END_RUNNING_CONFIG

$responsesHP2500->{startup_config} = <<'END_STARTUP_CONFIG';
Startup configuration:

; J4813A Configuration Editor; Created on release #F.05.17

hostname "hp2524"
snmp-server contact "Changed1"
snmp-server location "CostaRica"
cdp run
interface 5
   name "Mave!!!!!"
   flow-control
   speed-duplex 10-half
exit
ip default-gateway 10.100.2.1
no timesync
snmp-server community "public" Unrestricted
snmp-server community "testenv" Unrestricted
snmp-server community "testing123" Operator
snmp-server community "testing321"
snmp-server community "operator" Operator
snmp-server host 10.10.1.89 "traps"
snmp-server host 1.1.1.1 "public" Debug
snmp-server host 10.10.1.119 "testenv" All
vlan 1
   name "rifetest"
   untagged 1-4,6-26
   ip address 10.100.2.16 255.255.255.0
   no untagged 5
   exit
vlan 5
   name "icemanvlan"
   untagged 5
   ip address 10.10.100.1 255.255.255.0
   exit
ip authorized-managers 10.0.0.0 255.0.0.0
ip authorized-managers 192.168.0.0 255.255.0.0
ip route 0.0.0.0 0.0.0.0 10.100.2.1
no stack auto-join
aaa authentication telnet login tacacs local
aaa authentication telnet enable tacacs local
aaa authentication ssh login tacacs local
aaa authentication ssh enable tacacs local
tacacs-server host 10.100.32.137 key cisco
ip ssh
ip ssh key-size 1024
   no untagged 5
   exit
vlan 5
   name "icemanvlan"
   untagged 5
   ip address 10.10.100.1 255.255.255.0
   exit
ip authorized-managers 10.0.0.0 255.0.0.0
ip authorized-managers 192.168.0.0 255.255.0.0
ip route 0.0.0.0 0.0.0.0 10.100.2.1
no stack auto-join
aaa authentication telnet login tacacs local
aaa authentication telnet enable tacacs local
aaa authentication ssh login tacacs local
aaa authentication ssh enable tacacs local
tacacs-server host 10.100.32.137 key cisco
ip ssh
ip ssh key-size 1024
no aaa port-access authenticator active
spanning-tree
password manager
password operator

hp2524#
END_STARTUP_CONFIG

$responsesHP2500->{version}= <<'END_VERSION';                                                            
Image stamp:    /sw/code/build/info(s02)                                        
                Apr  3 2003 13:26:54                                            
                F.05.17                                                         
                5908                                                            
hp2524#                                                                         
 Status and Counters - General System Information                               
                                                                                
  System Name        : hp2524                                                   
  System Contact     : Changed1                                                 
  System Location    : CostaRica                                                
                                                                                
  MAC Age Time (sec) : 300                                                      
                                                                                
  Time Zone          : 0                                                        
  Daylight Time Rule : None                                                     
                                                                                
                                                                                
  Firmware revision  : F.05.17          Base MAC Addr      : 0001e7-7c99c0      
  ROM Version        : F.01.01          Serial Number      : TW10302565         
                                                                                
  Up Time            : 236 days         Memory   - Total   : 10,497,436         
  CPU Util (%)       : 46                          Free    : 7,942,516          
                                                                                
  IP Mgmt  - Pkts Rx : 7,807,077        Packet   - Total   : 512                
             Pkts Tx : 7,200,875        Buffers    Free    : 510                
                                                   Lowest  : 362                
                                                   Missed  : 0                  
                                                                                
hp2524#                                                                         
END_VERSION

$responsesHP2500->{interfaces} = <<'END_INTERFACES';                                                   
                                                                                
 Status and Counters - Port Status                                              
                                                                                
                 | Intrusion                           Flow  Bcast              
  Port Type      | Alert     Enabled Status Mode       Ctrl  Limit              
  ---- --------- + --------- ------- ------ ---------- ----- ------             
  1    10/100TX  | No        Yes     Up     100FDx     off   0                  
  2    10/100TX  | No        Yes     Down   10FDx      off   0                  
  3    10/100TX  | No        Yes     Down   10FDx      off   0                  
  4    10/100TX  | No        Yes     Down   10FDx      off   0                  
  5    10/100TX  | No        Yes     Down   10HDx      on    0                  
  6    10/100TX  | No        Yes     Down   10FDx      off   0                  
  7    10/100TX  | No        Yes     Down   10FDx      off   0                  
  8    10/100TX  | No        Yes     Down   10FDx      off   0                  
  9    10/100TX  | No        Yes     Down   10FDx      off   0                  
  10   10/100TX  | No        Yes     Down   10FDx      off   0                  
  11   10/100TX  | No        Yes     Down   10FDx      off   0                  
  12   10/100TX  | No        Yes     Down   10FDx      off   0                  
  13   10/100TX  | No        Yes     Down   10FDx      off   0                  
  14   10/100TX  | No        Yes     Down   10FDx      off   0                  
  15   10/100TX  | No        Yes     Down   10FDx      off   0                  
  16   10/100TX  | No        Yes     Down   10FDx      off   0                  
  17   10/100TX  | No        Yes     Down   10FDx      off   0                  
  18   10/100TX  | No        Yes     Down   10FDx      off   0                  
  19   10/100TX  | No        Yes     Down   10FDx      off   0                  
  20   10/100TX  | No        Yes     Down   10FDx      off   0                  
  21   10/100TX  | No        Yes     Down   10FDx      off   0                  
  22   10/100TX  | No        Yes     Down   10FDx      off   0                  
  23   10/100TX  | No        Yes     Down   10FDx      off   0                  
  24   10/100TX  | No        Yes     Down   10FDx      off   0                  
  25             | No        Yes     Down              off   0                  
  26             | No        Yes     Down              off   0                  
                                                                                
hp2524#                                                                         
END_INTERFACES

$responsesHP2500->{snmp} = <<'END_SNMP';
                                                                                
 SNMP Communities                                                               
                                                                                
  Community Name   MIB View Write Access                                        
  ---------------- -------- ------------                                        
  public           Manager  Unrestricted                                        
  testenv          Manager  Unrestricted                                        
  testing123       Operator Restricted                                          
  testing321       Manager  Restricted                                          
  operator         Operator Restricted                                          
                                                                                
 Trap Receivers                                                                 
                                                                                
  Send Authentication Traps [No] : No                                           
                                                                                
  Address                Community        Events Sent in Trap                   
  ---------------------- ---------------- -------------------                   
  10.10.1.89             traps            None                                  
  1.1.1.1                public           Debug                                 
  10.10.1.119            testenv          All                                   
                                                                                
                                                                                
                                                                                
                                                                                
hp2524#                                                                         
END_SNMP

$responsesHP2500->{stp} = <<'END_STP';                                                      
                                                                                
 Status and Counters - Spanning Tree Information                                
                                                                                
  Protocol Version : RSTP                                                       
  STP Enabled : Yes                                                             
  Force Version : RSTP-operation                                                
                                                                                
  Switch Priority : 32768               Hello Time : 2                          
  Max Age : 20                          Forward Delay : 15                      
                                                                                
  Topology Change Count : 1036                                                  
  Time Since Last Change : 21 hours                                             
                                                                                
  Root MAC Address : 001794-45ee80                                              
  Root Path Cost : 200023                                                       
  Root Port : 1                                                                 
  Root Priority : 24778                                                         
                                                                                
  Port Type      Cost      Priority State      | Designated Bridge              
  ---- --------- --------- -------- ---------- + -----------------              
  1    10/100TX  200000    128      Forwarding | 000ded-3c8180                  
  2    10/100TX  200000    128      Disabled   |                                
  3    10/100TX  200000    128      Disabled   |                                
  4    10/100TX  200000    128      Disabled   |                                
  5    10/100TX  200000    128      Disabled   |                                
  6    10/100TX  200000    128      Disabled   |                                
  7    10/100TX  200000    128      Disabled   |                                
  8    10/100TX  200000    128      Disabled   |                                
  9    10/100TX  200000    128      Disabled   |                                
  10   10/100TX  200000    128      Disabled   |                                
  11   10/100TX  200000    128      Disabled   |                                
  12   10/100TX  200000    128      Disabled   |                                
  13   10/100TX  200000    128      Disabled   |                                
  14   10/100TX  200000    128      Disabled   |                                
  15   10/100TX  200000    128      Disabled   |                                
  16   10/100TX  200000    128      Disabled   |                                
  17   10/100TX  200000    128      Disabled   |                                
  18   10/100TX  200000    128      Disabled   |                                
  19   10/100TX  200000    128      Disabled   |                                
  20   10/100TX  200000    128      Disabled   |                                
  21   10/100TX  200000    128      Disabled   |                                
  22   10/100TX  200000    128      Disabled   |                                
  23   10/100TX  200000    128      Disabled   |                                
  24   10/100TX  200000    128      Disabled   |                                
  25             2000000   128      Disabled   |                                
  26             2000000   128      Disabled   |                                
                                                                                
                                                                                
hp2524#                                                                         
END_STP

$responsesHP2500->{vlans} = <<'END_VLANINFO'; 

  Status and Counters - VLAN Information - Ports - VLAN 1
 
   802.1Q VLAN ID : 1
   Name          : rifetest
   Status        : Static
 
   Port Information Mode     Unknown VLAN Status
   ---------------- -------- ------------ ----------
   1                Untagged Learn        Up
   2                Untagged Learn        Down
   3                Untagged Learn        Down
   4                Untagged Learn        Down
   6                Untagged Learn        Down
   7                Untagged Learn        Down
   8                Untagged Learn        Down
   9                Untagged Learn        Down
   10               Untagged Learn        Down
   11               Untagged Learn        Down
   12               Untagged Learn        Down
   13               Untagged Learn        Down
   14               Untagged Learn        Down
  15               Untagged Learn        Down

END_VLANINFO
