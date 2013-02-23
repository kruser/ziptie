package DataSwitch4400;

use strict;
use warnings;
use Exporter 'import';
our @EXPORT_OK = qw($responsesThreeCom);

our $responsesThreeCom = {};

$responsesThreeCom->{'system'} = <<'END';
summary
3Com SuperStack 3
System Name		: 3Com4400
Location		: testing
Contact			: chg5

Time Since Reset	: 6289 Hrs 39 Mins 9 Seconds
Operational Version	: 3.21
Hardware Version	: 05.02.00
Boot Version		: 2.21
MAC Address		: 00-0a-04-de-a6-c0
Product Number		: 3C17203
Serial Number		: 7PVV1Q7DEA6C0

TFTP Server Address	: 0.0.0.0
Filename		: 
Last software upgrade	: General error

  
Select menu option 

END


$responsesThreeCom->{users} = <<'END';
summary

User Name        Access Level     Community String
------------------------------------------------------------
admin            security         testenv
brandon          manager          quit
manager          manager          private
monitor          monitor          public
testlab          security         testlab

Select menu option 

END


$responsesThreeCom->{routes} = <<'END';
summary

Destination       Subnet Mask       Metric      Gateway           Status      
------------------------------------------------------------------------
Default Route     --                --          10.100.2.1        Static      
10.100.2.0        255.255.255.0     --          --                Direct      
  
Select menu option 

END


$responsesThreeCom->{stp} = <<'END';
summary


stpVersion:		2 (RSTP)	defaultPathCosts:	802.1D-1998
stpState:		enabled    	agingTime:			300

Time since topology change:		114 hrs 13 mins 49 seconds
Topology Changes:			319
Bridge Identifier:			8000 000a04dea6c0
Designated Root:			60ca 00179445ee80

maxAge:			20		bridgeMaxAge:		20
helloTime:		2		bridgeHelloTime:	2
forwardDelay:		15		bridgeFwdDelay:		15
holdTime:		1		rootCost:		41
rootPort:		1		priority:		32768

Select menu option 

END


$responsesThreeCom->{eth_summary} = <<'END';
summary all
Refresh Time:10 Seconds 

Port State    Mode                 Rx Packets   Rx Octets    Errors       
-------------------------------------------------------------------------------
                              
1:1  enabled  100full (Auto)       31948684     2541841513   0            
1:2  enabled  Link Down (Auto)     0            0            0            
1:3  enabled  Link Down (Auto)     0            0            0            
1:4  enabled  Link Down (Auto)     0            0            0            
1:5  enabled  Link Down (Auto)     0            0            0            
1:6  enabled  Link Down (Auto)     0            0            0            
1:7  enabled  Link Down (Auto)     0            0            0            
1:8  enabled  Link Down (Auto)     0            0            0            
1:9  enabled  Link Down (Auto)     0            0            0            
1:10 enabled  Link Down (Auto)     0            0            0            
1:11 enabled  Link Down (Auto)     0            0            0            
1:12 enabled  Link Down (Auto)     0            0            0            
1:13 enabled  Link Down (Auto)     0            0            0            
1:14 enabled  Link Down (Auto)     0            0            0            
1:15 enabled  Link Down (Auto)     0            0            0            
1:16 enabled  Link Down (Auto)     0            0            0            
1:17 enabled  Link Down (Auto)     0            0            0            
1:18 enabled  Link Down (Auto)     0            0            0            
Quit    Counters      Differences                              Next                              
1:7  enabled  Link Down (Auto)     0            0            0            
1:8  enabled  Link Down (Auto)     0            0            0            
1:9  enabled  Link Down (Auto)     0            0            0            
1:10 enabled  Link Down (Auto)     0            0            0            
1:11 enabled  Link Down (Auto)     0            0            0            
1:12 enabled  Link Down (Auto)     0            0            0            
1:13 enabled  Link Down (Auto)     0            0            0            
1:14 enabled  Link Down (Auto)     0            0            0            
1:15 enabled  Link Down (Auto)     0            0            0            
1:16 enabled  Link Down (Auto)     0            0            0            
1:17 enabled  Link Down (Auto)     0            0            0            
1:18 enabled  Link Down (Auto)     0            0            0            
1:19 enabled  Link Down (Auto)     0            0            0            
1:20 enabled  Link Down (Auto)     0            0            0            
1:21 enabled  Link Down (Auto)     0            0            0            
1:22 enabled  Link Down (Auto)     0            0            0            
1:23 enabled  Link Down (Auto)     0            0            0            
1:24 enabled  Link Down (Auto)     0            0            0            
Quit    Counters      Differences              Prev                

END


$responsesThreeCom->{'eth_1:1'} = <<'END';

  
Select menu option (physicalInterface/ethernet): detail 1:1

Port:   1:1     State:  enabled      Mode:  100full (Auto)        
Media Type: 10BASE-T/100BASE-TX
Active Features : STAP Enabled, BSC Enabled

Refresh Time:10 Seconds                   0        ss

-Counters-                           -Rx-                    -Tx-          
Unicast Packets:
Non Unicast Packets:
Octets:
Fragments(Rx)/Collisions(Tx):
Discarded Packets(Rx):                                          -

-Rx Errors-
Undersize:                              Oversize:                              
CRC Error:                              Jabbers:                               

-Pkt Analysis-
64 Octets:                              256 to 511 Octets:                     
65 to 127 Octets:                       512 to 1023 Octets:                    
128 to 255 Octets:                      1024 to 1518 Octets:                   

Refresh Time:10 Seconds                                     
-Counters-                           -Rx-                    -Tx-          
Unicast Packets:      9345788                 6875968              Non Unicast Packets:    22602923                   34242              Octets:                 2541843247               769934461              Fragments(Rx)/Collisions(Tx):             0                       0              Discarded Packets(Rx):            0                       -    -                                                                                       0                              0                            0                              0          -Pkt Analysis-                                                                    19296065              428355            17118798               83876             1931827                   0          Quit    Counters      Differences      Rates/Sec     Utilizations

END


$responsesThreeCom->{'eth_1:2'} = <<'END';

  
Select menu option (physicalInterface/ethernet): detail 1:2

Port:   1:2     State:  enabled      Mode:  link down (Auto)      
Media Type: 10BASE-T/100BASE-TX
Active Features : STAP Enabled, BSC Enabled

Refresh Time:10 Seconds                   0        ss

-Counters-                           -Rx-                    -Tx-          
Unicast Packets:
Non Unicast Packets:
Octets:
Fragments(Rx)/Collisions(Tx):
Discarded Packets(Rx):                                          -

-Rx Errors-
Undersize:                              Oversize:                              
CRC Error:                              Jabbers:                               

-Pkt Analysis-
64 Octets:                              256 to 511 Octets:                     
65 to 127 Octets:                       512 to 1023 Octets:                    
128 to 255 Octets:                      1024 to 1518 Octets:                   

Refresh Time:10 Seconds                                     
-Counters-                           -Rx-                    -Tx-          
Unicast Packets:            0                       0              Non Unicast Packets:           0                       0              Octets:                          0                       0              Fragments(Rx)/Collisions(Tx):             0                       0              Discarded Packets(Rx):            0                       -    -                                                                                       0                              0                            0                              0          -Pkt Analysis-                                                                           0                   0                   0                   0                   0                   0          Quit    Counters      Differences      Rates/Sec     Utilizations

END


$responsesThreeCom->{'eth_1:3'} = <<'END';

  
Select menu option (physicalInterface/ethernet): detail 1:3

Port:   1:3     State:  enabled      Mode:  link down (Auto)      
Media Type: 10BASE-T/100BASE-TX
Active Features : STAP Enabled, BSC Enabled

Refresh Time:10 Seconds                   0        ss

-Counters-                           -Rx-                    -Tx-          
Unicast Packets:
Non Unicast Packets:
Octets:
Fragments(Rx)/Collisions(Tx):
Discarded Packets(Rx):                                          -

-Rx Errors-
Undersize:                              Oversize:                              
CRC Error:                              Jabbers:                               

-Pkt Analysis-
64 Octets:                              256 to 511 Octets:                     
65 to 127 Octets:                       512 to 1023 Octets:                    
128 to 255 Octets:                      1024 to 1518 Octets:                   

Refresh Time:10 Seconds                                     
-Counters-                           -Rx-                    -Tx-          
Unicast Packets:            0                       0              Non Unicast Packets:           0                       0              Octets:                          0                       0              Fragments(Rx)/Collisions(Tx):             0                       0              Discarded Packets(Rx):            0                       -    -                                                                                       0                              0                            0                              0          -Pkt Analysis-                                                                           0                   0                   0                   0                   0                   0          Quit    Counters      Differences      Rates/Sec     Utilizations

END


$responsesThreeCom->{'eth_1:4'} = <<'END';

  
Select menu option (physicalInterface/ethernet): detail 1:4

Port:   1:4     State:  enabled      Mode:  link down (Auto)      
Media Type: 10BASE-T/100BASE-TX
Active Features : STAP Enabled, BSC Enabled

Refresh Time:10 Seconds                   0        ss

-Counters-                           -Rx-                    -Tx-          
Unicast Packets:
Non Unicast Packets:
Octets:
Fragments(Rx)/Collisions(Tx):
Discarded Packets(Rx):                                          -

-Rx Errors-
Undersize:                              Oversize:                              
CRC Error:                              Jabbers:                               

-Pkt Analysis-
64 Octets:                              256 to 511 Octets:                     
65 to 127 Octets:                       512 to 1023 Octets:                    
128 to 255 Octets:                      1024 to 1518 Octets:                   

Refresh Time:10 Seconds                                     
-Counters-                           -Rx-                    -Tx-          
Unicast Packets:            0                       0              Non Unicast Packets:           0                       0              Octets:                          0                       0              Fragments(Rx)/Collisions(Tx):             0                       0              Discarded Packets(Rx):            0                       -    -                                                                                       0                              0                            0                              0          -Pkt Analysis-                                                                           0                   0                   0                   0                   0                   0          Quit    Counters      Differences      Rates/Sec     Utilizations

END


$responsesThreeCom->{'eth_1:5'} = <<'END';

  
Select menu option (physicalInterface/ethernet): detail 1:5

Port:   1:5     State:  enabled      Mode:  link down (Auto)      
Media Type: 10BASE-T/100BASE-TX
Active Features : STAP Enabled, BSC Enabled

Refresh Time:10 Seconds                   0        ss

-Counters-                           -Rx-                    -Tx-          
Unicast Packets:
Non Unicast Packets:
Octets:
Fragments(Rx)/Collisions(Tx):
Discarded Packets(Rx):                                          -

-Rx Errors-
Undersize:                              Oversize:                              
CRC Error:                              Jabbers:                               

-Pkt Analysis-
64 Octets:                              256 to 511 Octets:                     
65 to 127 Octets:                       512 to 1023 Octets:                    
128 to 255 Octets:                      1024 to 1518 Octets:                   

Refresh Time:10 Seconds                                     
-Counters-                           -Rx-                    -Tx-          
Unicast Packets:            0                       0              Non Unicast Packets:           0                       0              Octets:                          0                       0              Fragments(Rx)/Collisions(Tx):             0                       0              Discarded Packets(Rx):            0                       -    -                                                                                       0                              0                            0                              0          -Pkt Analysis-                                                                           0                   0                   0                   0                   0                   0          Quit    Counters      Differences      Rates/Sec     Utilizations

END


$responsesThreeCom->{'eth_1:6'} = <<'END';

  
Select menu option (physicalInterface/ethernet): detail 1:6

Port:   1:6     State:  enabled      Mode:  link down (Auto)      
Media Type: 10BASE-T/100BASE-TX
Active Features : STAP Enabled, BSC Enabled

Refresh Time:10 Seconds                   0        ss

-Counters-                           -Rx-                    -Tx-          
Unicast Packets:
Non Unicast Packets:
Octets:
Fragments(Rx)/Collisions(Tx):
Discarded Packets(Rx):                                          -

-Rx Errors-
Undersize:                              Oversize:                              
CRC Error:                              Jabbers:                               

-Pkt Analysis-
64 Octets:                              256 to 511 Octets:                     
65 to 127 Octets:                       512 to 1023 Octets:                    
128 to 255 Octets:                      1024 to 1518 Octets:                   

Refresh Time:10 Seconds                                     
-Counters-                           -Rx-                    -Tx-          
Unicast Packets:            0                       0              Non Unicast Packets:           0                       0              Octets:                          0                       0              Fragments(Rx)/Collisions(Tx):             0                       0              Discarded Packets(Rx):            0                       -    -                                                                                       0                              0                            0                              0          -Pkt Analysis-                                                                           0                   0                   0                   0                   0                   0          Quit    Counters      Differences      Rates/Sec     Utilizations

END


$responsesThreeCom->{'eth_1:7'} = <<'END';

  
Select menu option (physicalInterface/ethernet): detail 1:7

Port:   1:7     State:  enabled      Mode:  link down (Auto)      
Media Type: 10BASE-T/100BASE-TX
Active Features : STAP Enabled, BSC Enabled

Refresh Time:10 Seconds                   0        ss

-Counters-                           -Rx-                    -Tx-          
Unicast Packets:
Non Unicast Packets:
Octets:
Fragments(Rx)/Collisions(Tx):
Discarded Packets(Rx):                                          -

-Rx Errors-
Undersize:                              Oversize:                              
CRC Error:                              Jabbers:                               

-Pkt Analysis-
64 Octets:                              256 to 511 Octets:                     
65 to 127 Octets:                       512 to 1023 Octets:                    
128 to 255 Octets:                      1024 to 1518 Octets:                   

Refresh Time:10 Seconds                                     
-Counters-                           -Rx-                    -Tx-          
Unicast Packets:            0                       0              Non Unicast Packets:           0                       0              Octets:                          0                       0              Fragments(Rx)/Collisions(Tx):             0                       0              Discarded Packets(Rx):            0                       -    -                                                                                       0                              0                            0                              0          -Pkt Analysis-                                                                           0                   0                   0                   0                   0                   0          Quit    Counters      Differences      Rates/Sec     Utilizations

END


$responsesThreeCom->{'eth_1:8'} = <<'END';

  
Select menu option (physicalInterface/ethernet): detail 1:8

Port:   1:8     State:  enabled      Mode:  link down (Auto)      
Media Type: 10BASE-T/100BASE-TX
Active Features : STAP Enabled, BSC Enabled

Refresh Time:10 Seconds                   0        ss

-Counters-                           -Rx-                    -Tx-          
Unicast Packets:
Non Unicast Packets:
Octets:
Fragments(Rx)/Collisions(Tx):
Discarded Packets(Rx):                                          -

-Rx Errors-
Undersize:                              Oversize:                              
CRC Error:                              Jabbers:                               

-Pkt Analysis-
64 Octets:                              256 to 511 Octets:                     
65 to 127 Octets:                       512 to 1023 Octets:                    
128 to 255 Octets:                      1024 to 1518 Octets:                   

Refresh Time:10 Seconds                                     
-Counters-                           -Rx-                    -Tx-          
Unicast Packets:            0                       0              Non Unicast Packets:           0                       0              Octets:                          0                       0              Fragments(Rx)/Collisions(Tx):             0                       0              Discarded Packets(Rx):            0                       -    -                                                                                       0                              0                            0                              0          -Pkt Analysis-                                                                           0                   0                   0                   0                   0                   0          Quit    Counters      Differences      Rates/Sec     Utilizations

END


$responsesThreeCom->{'eth_1:9'} = <<'END';

  
Select menu option (physicalInterface/ethernet): detail 1:9

Port:   1:9     State:  enabled      Mode:  link down (Auto)      
Media Type: 10BASE-T/100BASE-TX
Active Features : STAP Enabled, BSC Enabled

Refresh Time:10 Seconds                   0        ss

-Counters-                           -Rx-                    -Tx-          
Unicast Packets:
Non Unicast Packets:
Octets:
Fragments(Rx)/Collisions(Tx):
Discarded Packets(Rx):                                          -

-Rx Errors-
Undersize:                              Oversize:                              
CRC Error:                              Jabbers:                               

-Pkt Analysis-
64 Octets:                              256 to 511 Octets:                     
65 to 127 Octets:                       512 to 1023 Octets:                    
128 to 255 Octets:                      1024 to 1518 Octets:                   

Refresh Time:10 Seconds                                     
-Counters-                           -Rx-                    -Tx-          
Unicast Packets:            0                       0              Non Unicast Packets:           0                       0              Octets:                          0                       0              Fragments(Rx)/Collisions(Tx):             0                       0              Discarded Packets(Rx):            0                       -    -                                                                                       0                              0                            0                              0          -Pkt Analysis-                                                                           0                   0                   0                   0                   0                   0          Quit    Counters      Differences      Rates/Sec     Utilizations

END


$responsesThreeCom->{'eth_1:10'} = <<'END';

  
Select menu option (physicalInterface/ethernet): detail 1:10

Port:   1:10    State:  enabled      Mode:  link down (Auto)      
Media Type: 10BASE-T/100BASE-TX
Active Features : STAP Enabled, BSC Enabled

Refresh Time:10 Seconds                   0        ss

-Counters-                           -Rx-                    -Tx-          
Unicast Packets:
Non Unicast Packets:
Octets:
Fragments(Rx)/Collisions(Tx):
Discarded Packets(Rx):                                          -

-Rx Errors-
Undersize:                              Oversize:                              
CRC Error:                              Jabbers:                               

-Pkt Analysis-
64 Octets:                              256 to 511 Octets:                     
65 to 127 Octets:                       512 to 1023 Octets:                    
128 to 255 Octets:                      1024 to 1518 Octets:                   

Refresh Time:10 Seconds                                     
-Counters-                           -Rx-                    -Tx-          
Unicast Packets:            0                       0              Non Unicast Packets:           0                       0              Octets:                          0                       0              Fragments(Rx)/Collisions(Tx):             0                       0              Discarded Packets(Rx):            0                       -    -                                                                                       0                              0                            0                              0          -Pkt Analysis-                                                                           0                   0                   0                   0                   0                   0          Quit    Counters      Differences      Rates/Sec     Utilizations

END


$responsesThreeCom->{'eth_1:11'} = <<'END';

  
Select menu option (physicalInterface/ethernet): detail 1:11

Port:   1:11    State:  enabled      Mode:  link down (Auto)      
Media Type: 10BASE-T/100BASE-TX
Active Features : STAP Enabled, BSC Enabled

Refresh Time:10 Seconds                   0        ss

-Counters-                           -Rx-                    -Tx-          
Unicast Packets:
Non Unicast Packets:
Octets:
Fragments(Rx)/Collisions(Tx):
Discarded Packets(Rx):                                          -

-Rx Errors-
Undersize:                              Oversize:                              
CRC Error:                              Jabbers:                               

-Pkt Analysis-
64 Octets:                              256 to 511 Octets:                     
65 to 127 Octets:                       512 to 1023 Octets:                    
128 to 255 Octets:                      1024 to 1518 Octets:                   

Refresh Time:10 Seconds                                     
-Counters-                           -Rx-                    -Tx-          
Unicast Packets:            0                       0              Non Unicast Packets:           0                       0              Octets:                          0                       0              Fragments(Rx)/Collisions(Tx):             0                       0              Discarded Packets(Rx):            0                       -    -                                                                                       0                              0                            0                              0          -Pkt Analysis-                                                                           0                   0                   0                   0                   0                   0          Quit    Counters      Differences      Rates/Sec     Utilizations

END


$responsesThreeCom->{'eth_1:12'} = <<'END';

  
Select menu option (physicalInterface/ethernet): detail 1:12

Port:   1:12    State:  enabled      Mode:  link down (Auto)      
Media Type: 10BASE-T/100BASE-TX
Active Features : STAP Enabled, BSC Enabled

Refresh Time:10 Seconds                   0        ss

-Counters-                           -Rx-                    -Tx-          
Unicast Packets:
Non Unicast Packets:
Octets:
Fragments(Rx)/Collisions(Tx):
Discarded Packets(Rx):                                          -

-Rx Errors-
Undersize:                              Oversize:                              
CRC Error:                              Jabbers:                               

-Pkt Analysis-
64 Octets:                              256 to 511 Octets:                     
65 to 127 Octets:                       512 to 1023 Octets:                    
128 to 255 Octets:                      1024 to 1518 Octets:                   

Refresh Time:10 Seconds                                     
-Counters-                           -Rx-                    -Tx-          
Unicast Packets:            0                       0              Non Unicast Packets:           0                       0              Octets:                          0                       0              Fragments(Rx)/Collisions(Tx):             0                       0              Discarded Packets(Rx):            0                       -    -                                                                                       0                              0                            0                              0          -Pkt Analysis-                                                                           0                   0                   0                   0                   0                   0          Quit    Counters      Differences      Rates/Sec     Utilizations

END


$responsesThreeCom->{'eth_1:13'} = <<'END';

  
Select menu option (physicalInterface/ethernet): detail 1:13

Port:   1:13    State:  enabled      Mode:  link down (Auto)      
Media Type: 10BASE-T/100BASE-TX
Active Features : STAP Enabled, BSC Enabled

Refresh Time:10 Seconds                   0        ss

-Counters-                           -Rx-                    -Tx-          
Unicast Packets:
Non Unicast Packets:
Octets:
Fragments(Rx)/Collisions(Tx):
Discarded Packets(Rx):                                          -

-Rx Errors-
Undersize:                              Oversize:                              
CRC Error:                              Jabbers:                               

-Pkt Analysis-
64 Octets:                              256 to 511 Octets:                     
65 to 127 Octets:                       512 to 1023 Octets:                    
128 to 255 Octets:                      1024 to 1518 Octets:                   

Refresh Time:10 Seconds                                     
-Counters-                           -Rx-                    -Tx-          
Unicast Packets:            0                       0              Non Unicast Packets:           0                       0              Octets:                          0                       0              Fragments(Rx)/Collisions(Tx):             0                       0              Discarded Packets(Rx):            0                       -    -                                                                                       0                              0                            0                              0          -Pkt Analysis-                                                                           0                   0                   0                   0                   0                   0          Quit    Counters      Differences      Rates/Sec     Utilizations

END


$responsesThreeCom->{'eth_1:14'} = <<'END';

  
Select menu option (physicalInterface/ethernet): detail 1:14

Port:   1:14    State:  enabled      Mode:  link down (Auto)      
Media Type: 10BASE-T/100BASE-TX
Active Features : STAP Enabled, BSC Enabled

Refresh Time:10 Seconds                   0        ss

-Counters-                           -Rx-                    -Tx-          
Unicast Packets:
Non Unicast Packets:
Octets:
Fragments(Rx)/Collisions(Tx):
Discarded Packets(Rx):                                          -

-Rx Errors-
Undersize:                              Oversize:                              
CRC Error:                              Jabbers:                               

-Pkt Analysis-
64 Octets:                              256 to 511 Octets:                     
65 to 127 Octets:                       512 to 1023 Octets:                    
128 to 255 Octets:                      1024 to 1518 Octets:                   

Refresh Time:10 Seconds                                     
-Counters-                           -Rx-                    -Tx-          
Unicast Packets:            0                       0              Non Unicast Packets:           0                       0              Octets:                          0                       0              Fragments(Rx)/Collisions(Tx):             0                       0              Discarded Packets(Rx):            0                       -    -                                                                                       0                              0                            0                              0          -Pkt Analysis-                                                                           0                   0                   0                   0                   0                   0          Quit    Counters      Differences      Rates/Sec     Utilizations

END


$responsesThreeCom->{'eth_1:15'} = <<'END';

  
Select menu option (physicalInterface/ethernet): detail 1:15

Port:   1:15    State:  enabled      Mode:  link down (Auto)      
Media Type: 10BASE-T/100BASE-TX
Active Features : STAP Enabled, BSC Enabled

Refresh Time:10 Seconds                   0        ss

-Counters-                           -Rx-                    -Tx-          
Unicast Packets:
Non Unicast Packets:
Octets:
Fragments(Rx)/Collisions(Tx):
Discarded Packets(Rx):                                          -

-Rx Errors-
Undersize:                              Oversize:                              
CRC Error:                              Jabbers:                               

-Pkt Analysis-
64 Octets:                              256 to 511 Octets:                     
65 to 127 Octets:                       512 to 1023 Octets:                    
128 to 255 Octets:                      1024 to 1518 Octets:                   

Refresh Time:10 Seconds                                     
-Counters-                           -Rx-                    -Tx-          
Unicast Packets:            0                       0              Non Unicast Packets:           0                       0              Octets:                          0                       0              Fragments(Rx)/Collisions(Tx):             0                       0              Discarded Packets(Rx):            0                       -    -                                                                                       0                              0                            0                              0          -Pkt Analysis-                                                                           0                   0                   0                   0                   0                   0          Quit    Counters      Differences      Rates/Sec     Utilizations

END


$responsesThreeCom->{'eth_1:16'} = <<'END';

  
Select menu option (physicalInterface/ethernet): detail 1:16

Port:   1:16    State:  enabled      Mode:  link down (Auto)      
Media Type: 10BASE-T/100BASE-TX
Active Features : STAP Enabled, BSC Enabled

Refresh Time:10 Seconds                   0        ss

-Counters-                           -Rx-                    -Tx-          
Unicast Packets:
Non Unicast Packets:
Octets:
Fragments(Rx)/Collisions(Tx):
Discarded Packets(Rx):                                          -

-Rx Errors-
Undersize:                              Oversize:                              
CRC Error:                              Jabbers:                               

-Pkt Analysis-
64 Octets:                              256 to 511 Octets:                     
65 to 127 Octets:                       512 to 1023 Octets:                    
128 to 255 Octets:                      1024 to 1518 Octets:                   

Refresh Time:10 Seconds                                     
-Counters-                           -Rx-                    -Tx-          
Unicast Packets:            0                       0              Non Unicast Packets:           0                       0              Octets:                          0                       0              Fragments(Rx)/Collisions(Tx):             0                       0              Discarded Packets(Rx):            0                       -    -                                                                                       0                              0                            0                              0          -Pkt Analysis-                                                                           0                   0                   0                   0                   0                   0          Quit    Counters      Differences      Rates/Sec     Utilizations

END


$responsesThreeCom->{'eth_1:17'} = <<'END';

  
Select menu option (physicalInterface/ethernet): detail 1:17

Port:   1:17    State:  enabled      Mode:  link down (Auto)      
Media Type: 10BASE-T/100BASE-TX
Active Features : STAP Enabled, BSC Enabled

Refresh Time:10 Seconds                   0        ss

-Counters-                           -Rx-                    -Tx-          
Unicast Packets:
Non Unicast Packets:
Octets:
Fragments(Rx)/Collisions(Tx):
Discarded Packets(Rx):                                          -

-Rx Errors-
Undersize:                              Oversize:                              
CRC Error:                              Jabbers:                               

-Pkt Analysis-
64 Octets:                              256 to 511 Octets:                     
65 to 127 Octets:                       512 to 1023 Octets:                    
128 to 255 Octets:                      1024 to 1518 Octets:                   

Refresh Time:10 Seconds                                     
-Counters-                           -Rx-                    -Tx-          
Unicast Packets:            0                       0              Non Unicast Packets:           0                       0              Octets:                          0                       0              Fragments(Rx)/Collisions(Tx):             0                       0              Discarded Packets(Rx):            0                       -    -                                                                                       0                              0                            0                              0          -Pkt Analysis-                                                                           0                   0                   0                   0                   0                   0          Quit    Counters      Differences      Rates/Sec     Utilizations

END


$responsesThreeCom->{'eth_1:18'} = <<'END';

  
Select menu option (physicalInterface/ethernet): detail 1:18

Port:   1:18    State:  enabled      Mode:  link down (Auto)      
Media Type: 10BASE-T/100BASE-TX
Active Features : STAP Enabled, BSC Enabled

Refresh Time:10 Seconds                   0        ss

-Counters-                           -Rx-                    -Tx-          
Unicast Packets:
Non Unicast Packets:
Octets:
Fragments(Rx)/Collisions(Tx):
Discarded Packets(Rx):                                          -

-Rx Errors-
Undersize:                              Oversize:                              
CRC Error:                              Jabbers:                               

-Pkt Analysis-
64 Octets:                              256 to 511 Octets:                     
65 to 127 Octets:                       512 to 1023 Octets:                    
128 to 255 Octets:                      1024 to 1518 Octets:                   

Refresh Time:10 Seconds                                     
-Counters-                           -Rx-                    -Tx-          
Unicast Packets:            0                       0              Non Unicast Packets:           0                       0              Octets:                          0                       0              Fragments(Rx)/Collisions(Tx):             0                       0              Discarded Packets(Rx):            0                       -    -                                                                                       0                              0                            0                              0          -Pkt Analysis-                                                                           0                   0                   0                   0                   0                   0          Quit    Counters      Differences      Rates/Sec     Utilizations

END


$responsesThreeCom->{'eth_1:7'} = <<'END';

  
Select menu option (physicalInterface/ethernet): detail 1:7

Port:   1:7     State:  enabled      Mode:  link down (Auto)      
Media Type: 10BASE-T/100BASE-TX
Active Features : STAP Enabled, BSC Enabled

Refresh Time:10 Seconds                   0        ss

-Counters-                           -Rx-                    -Tx-          
Unicast Packets:
Non Unicast Packets:
Octets:
Fragments(Rx)/Collisions(Tx):
Discarded Packets(Rx):                                          -

-Rx Errors-
Undersize:                              Oversize:                              
CRC Error:                              Jabbers:                               

-Pkt Analysis-
64 Octets:                              256 to 511 Octets:                     
65 to 127 Octets:                       512 to 1023 Octets:                    
128 to 255 Octets:                      1024 to 1518 Octets:                   

Refresh Time:10 Seconds                                     
-Counters-                           -Rx-                    -Tx-          
Unicast Packets:            0                       0              Non Unicast Packets:           0                       0              Octets:                          0                       0              Fragments(Rx)/Collisions(Tx):             0                       0              Discarded Packets(Rx):            0                       -    -                                                                                       0                              0                            0                              0          -Pkt Analysis-                                                                           0                   0                   0                   0                   0                   0          Quit    Counters      Differences      Rates/Sec     Utilizations

END


$responsesThreeCom->{'eth_1:8'} = <<'END';

  
Select menu option (physicalInterface/ethernet): detail 1:8

Port:   1:8     State:  enabled      Mode:  link down (Auto)      
Media Type: 10BASE-T/100BASE-TX
Active Features : STAP Enabled, BSC Enabled

Refresh Time:10 Seconds                   0        ss

-Counters-                           -Rx-                    -Tx-          
Unicast Packets:
Non Unicast Packets:
Octets:
Fragments(Rx)/Collisions(Tx):
Discarded Packets(Rx):                                          -

-Rx Errors-
Undersize:                              Oversize:                              
CRC Error:                              Jabbers:                               

-Pkt Analysis-
64 Octets:                              256 to 511 Octets:                     
65 to 127 Octets:                       512 to 1023 Octets:                    
128 to 255 Octets:                      1024 to 1518 Octets:                   

Refresh Time:10 Seconds                                     
-Counters-                           -Rx-                    -Tx-          
Unicast Packets:            0                       0              Non Unicast Packets:           0                       0              Octets:                          0                       0              Fragments(Rx)/Collisions(Tx):             0                       0              Discarded Packets(Rx):            0                       -    -                                                                                       0                              0                            0                              0          -Pkt Analysis-                                                                           0                   0                   0                   0                   0                   0          Quit    Counters      Differences      Rates/Sec     Utilizations

END


$responsesThreeCom->{'eth_1:9'} = <<'END';

  
Select menu option (physicalInterface/ethernet): detail 1:9

Port:   1:9     State:  enabled      Mode:  link down (Auto)      
Media Type: 10BASE-T/100BASE-TX
Active Features : STAP Enabled, BSC Enabled

Refresh Time:10 Seconds                   0        ss

-Counters-                           -Rx-                    -Tx-          
Unicast Packets:
Non Unicast Packets:
Octets:
Fragments(Rx)/Collisions(Tx):
Discarded Packets(Rx):                                          -

-Rx Errors-
Undersize:                              Oversize:                              
CRC Error:                              Jabbers:                               

-Pkt Analysis-
64 Octets:                              256 to 511 Octets:                     
65 to 127 Octets:                       512 to 1023 Octets:                    
128 to 255 Octets:                      1024 to 1518 Octets:                   

Refresh Time:10 Seconds                                     
-Counters-                           -Rx-                    -Tx-          
Unicast Packets:            0                       0              Non Unicast Packets:           0                       0              Octets:                          0                       0              Fragments(Rx)/Collisions(Tx):             0                       0              Discarded Packets(Rx):            0                       -    -                                                                                       0                              0                            0                              0          -Pkt Analysis-                                                                           0                   0                   0                   0                   0                   0          Quit    Counters      Differences      Rates/Sec     Utilizations

END


$responsesThreeCom->{'eth_1:10'} = <<'END';

  
Select menu option (physicalInterface/ethernet): detail 1:10

Port:   1:10    State:  enabled      Mode:  link down (Auto)      
Media Type: 10BASE-T/100BASE-TX
Active Features : STAP Enabled, BSC Enabled

Refresh Time:10 Seconds                   0        ss

-Counters-                           -Rx-                    -Tx-          
Unicast Packets:
Non Unicast Packets:
Octets:
Fragments(Rx)/Collisions(Tx):
Discarded Packets(Rx):                                          -

-Rx Errors-
Undersize:                              Oversize:                              
CRC Error:                              Jabbers:                               

-Pkt Analysis-
64 Octets:                              256 to 511 Octets:                     
65 to 127 Octets:                       512 to 1023 Octets:                    
128 to 255 Octets:                      1024 to 1518 Octets:                   

Refresh Time:10 Seconds                                     
-Counters-                           -Rx-                    -Tx-          
Unicast Packets:            0                       0              Non Unicast Packets:           0                       0              Octets:                          0                       0              Fragments(Rx)/Collisions(Tx):             0                       0              Discarded Packets(Rx):            0                       -    -                                                                                       0                              0                            0                              0          -Pkt Analysis-                                                                           0                   0                   0                   0                   0                   0          Quit    Counters      Differences      Rates/Sec     Utilizations

END


$responsesThreeCom->{'eth_1:11'} = <<'END';

  
Select menu option (physicalInterface/ethernet): detail 1:11

Port:   1:11    State:  enabled      Mode:  link down (Auto)      
Media Type: 10BASE-T/100BASE-TX
Active Features : STAP Enabled, BSC Enabled

Refresh Time:10 Seconds                   0        ss

-Counters-                           -Rx-                    -Tx-          
Unicast Packets:
Non Unicast Packets:
Octets:
Fragments(Rx)/Collisions(Tx):
Discarded Packets(Rx):                                          -

-Rx Errors-
Undersize:                              Oversize:                              
CRC Error:                              Jabbers:                               

-Pkt Analysis-
64 Octets:                              256 to 511 Octets:                     
65 to 127 Octets:                       512 to 1023 Octets:                    
128 to 255 Octets:                      1024 to 1518 Octets:                   

Refresh Time:10 Seconds                                     
-Counters-                           -Rx-                    -Tx-          
Unicast Packets:            0                       0              Non Unicast Packets:           0                       0              Octets:                          0                       0              Fragments(Rx)/Collisions(Tx):             0                       0              Discarded Packets(Rx):            0                       -    -                                                                                       0                              0                            0                              0          -Pkt Analysis-                                                                           0                   0                   0                   0                   0                   0          Quit    Counters      Differences      Rates/Sec     Utilizations

END


$responsesThreeCom->{'eth_1:12'} = <<'END';

  
Select menu option (physicalInterface/ethernet): detail 1:12

Port:   1:12    State:  enabled      Mode:  link down (Auto)      
Media Type: 10BASE-T/100BASE-TX
Active Features : STAP Enabled, BSC Enabled

Refresh Time:10 Seconds                   0        ss

-Counters-                           -Rx-                    -Tx-          
Unicast Packets:
Non Unicast Packets:
Octets:
Fragments(Rx)/Collisions(Tx):
Discarded Packets(Rx):                                          -

-Rx Errors-
Undersize:                              Oversize:                              
CRC Error:                              Jabbers:                               

-Pkt Analysis-
64 Octets:                              256 to 511 Octets:                     
65 to 127 Octets:                       512 to 1023 Octets:                    
128 to 255 Octets:                      1024 to 1518 Octets:                   

Refresh Time:10 Seconds                                     
-Counters-                           -Rx-                    -Tx-          
Unicast Packets:            0                       0              Non Unicast Packets:           0                       0              Octets:                          0                       0              Fragments(Rx)/Collisions(Tx):             0                       0              Discarded Packets(Rx):            0                       -    -                                                                                       0                              0                            0                              0          -Pkt Analysis-                                                                           0                   0                   0                   0                   0                   0          Quit    Counters      Differences      Rates/Sec     Utilizations

END


$responsesThreeCom->{'eth_1:13'} = <<'END';

  
Select menu option (physicalInterface/ethernet): detail 1:13

Port:   1:13    State:  enabled      Mode:  link down (Auto)      
Media Type: 10BASE-T/100BASE-TX
Active Features : STAP Enabled, BSC Enabled

Refresh Time:10 Seconds                   0        ss

-Counters-                           -Rx-                    -Tx-          
Unicast Packets:
Non Unicast Packets:
Octets:
Fragments(Rx)/Collisions(Tx):
Discarded Packets(Rx):                                          -

-Rx Errors-
Undersize:                              Oversize:                              
CRC Error:                              Jabbers:                               

-Pkt Analysis-
64 Octets:                              256 to 511 Octets:                     
65 to 127 Octets:                       512 to 1023 Octets:                    
128 to 255 Octets:                      1024 to 1518 Octets:                   

Refresh Time:10 Seconds                                     
-Counters-                           -Rx-                    -Tx-          
Unicast Packets:            0                       0              Non Unicast Packets:           0                       0              Octets:                          0                       0              Fragments(Rx)/Collisions(Tx):             0                       0              Discarded Packets(Rx):            0                       -    -                                                                                       0                              0                            0                              0          -Pkt Analysis-                                                                           0                   0                   0                   0                   0                   0          Quit    Counters      Differences      Rates/Sec     Utilizations

END


$responsesThreeCom->{'eth_1:14'} = <<'END';

  
Select menu option (physicalInterface/ethernet): detail 1:14

Port:   1:14    State:  enabled      Mode:  link down (Auto)      
Media Type: 10BASE-T/100BASE-TX
Active Features : STAP Enabled, BSC Enabled

Refresh Time:10 Seconds                   0        ss

-Counters-                           -Rx-                    -Tx-          
Unicast Packets:
Non Unicast Packets:
Octets:
Fragments(Rx)/Collisions(Tx):
Discarded Packets(Rx):                                          -

-Rx Errors-
Undersize:                              Oversize:                              
CRC Error:                              Jabbers:                               

-Pkt Analysis-
64 Octets:                              256 to 511 Octets:                     
65 to 127 Octets:                       512 to 1023 Octets:                    
128 to 255 Octets:                      1024 to 1518 Octets:                   

Refresh Time:10 Seconds                                     
-Counters-                           -Rx-                    -Tx-          
Unicast Packets:            0                       0              Non Unicast Packets:           0                       0              Octets:                          0                       0              Fragments(Rx)/Collisions(Tx):             0                       0              Discarded Packets(Rx):            0                       -    -                                                                                       0                              0                            0                              0          -Pkt Analysis-                                                                           0                   0                   0                   0                   0                   0          Quit    Counters      Differences      Rates/Sec     Utilizations

END


$responsesThreeCom->{'eth_1:15'} = <<'END';

  
Select menu option (physicalInterface/ethernet): detail 1:15

Port:   1:15    State:  enabled      Mode:  link down (Auto)      
Media Type: 10BASE-T/100BASE-TX
Active Features : STAP Enabled, BSC Enabled

Refresh Time:10 Seconds                   0        ss

-Counters-                           -Rx-                    -Tx-          
Unicast Packets:
Non Unicast Packets:
Octets:
Fragments(Rx)/Collisions(Tx):
Discarded Packets(Rx):                                          -

-Rx Errors-
Undersize:                              Oversize:                              
CRC Error:                              Jabbers:                               

-Pkt Analysis-
64 Octets:                              256 to 511 Octets:                     
65 to 127 Octets:                       512 to 1023 Octets:                    
128 to 255 Octets:                      1024 to 1518 Octets:                   

Refresh Time:10 Seconds                                     
-Counters-                           -Rx-                    -Tx-          
Unicast Packets:            0                       0              Non Unicast Packets:           0                       0              Octets:                          0                       0              Fragments(Rx)/Collisions(Tx):             0                       0              Discarded Packets(Rx):            0                       -    -                                                                                       0                              0                            0                              0          -Pkt Analysis-                                                                           0                   0                   0                   0                   0                   0          Quit    Counters      Differences      Rates/Sec     Utilizations

END


$responsesThreeCom->{'eth_1:16'} = <<'END';

  
Select menu option (physicalInterface/ethernet): detail 1:16

Port:   1:16    State:  enabled      Mode:  link down (Auto)      
Media Type: 10BASE-T/100BASE-TX
Active Features : STAP Enabled, BSC Enabled

Refresh Time:10 Seconds                   0        ss

-Counters-                           -Rx-                    -Tx-          
Unicast Packets:
Non Unicast Packets:
Octets:
Fragments(Rx)/Collisions(Tx):
Discarded Packets(Rx):                                          -

-Rx Errors-
Undersize:                              Oversize:                              
CRC Error:                              Jabbers:                               

-Pkt Analysis-
64 Octets:                              256 to 511 Octets:                     
65 to 127 Octets:                       512 to 1023 Octets:                    
128 to 255 Octets:                      1024 to 1518 Octets:                   

Refresh Time:10 Seconds                                     
-Counters-                           -Rx-                    -Tx-          
Unicast Packets:            0                       0              Non Unicast Packets:           0                       0              Octets:                          0                       0              Fragments(Rx)/Collisions(Tx):             0                       0              Discarded Packets(Rx):            0                       -    -                                                                                       0                              0                            0                              0          -Pkt Analysis-                                                                           0                   0                   0                   0                   0                   0          Quit    Counters      Differences      Rates/Sec     Utilizations

END


$responsesThreeCom->{'eth_1:17'} = <<'END';

  
Select menu option (physicalInterface/ethernet): detail 1:17

Port:   1:17    State:  enabled      Mode:  link down (Auto)      
Media Type: 10BASE-T/100BASE-TX
Active Features : STAP Enabled, BSC Enabled

Refresh Time:10 Seconds                   0        ss

-Counters-                           -Rx-                    -Tx-          
Unicast Packets:
Non Unicast Packets:
Octets:
Fragments(Rx)/Collisions(Tx):
Discarded Packets(Rx):                                          -

-Rx Errors-
Undersize:                              Oversize:                              
CRC Error:                              Jabbers:                               

-Pkt Analysis-
64 Octets:                              256 to 511 Octets:                     
65 to 127 Octets:                       512 to 1023 Octets:                    
128 to 255 Octets:                      1024 to 1518 Octets:                   

Refresh Time:10 Seconds                                     
-Counters-                           -Rx-                    -Tx-          
Unicast Packets:            0                       0              Non Unicast Packets:           0                       0              Octets:                          0                       0              Fragments(Rx)/Collisions(Tx):             0                       0              Discarded Packets(Rx):            0                       -    -                                                                                       0                              0                            0                              0          -Pkt Analysis-                                                                           0                   0                   0                   0                   0                   0          Quit    Counters      Differences      Rates/Sec     Utilizations

END


$responsesThreeCom->{'eth_1:18'} = <<'END';

  
Select menu option (physicalInterface/ethernet): detail 1:18

Port:   1:18    State:  enabled      Mode:  link down (Auto)      
Media Type: 10BASE-T/100BASE-TX
Active Features : STAP Enabled, BSC Enabled

Refresh Time:10 Seconds                   0        ss

-Counters-                           -Rx-                    -Tx-          
Unicast Packets:
Non Unicast Packets:
Octets:
Fragments(Rx)/Collisions(Tx):
Discarded Packets(Rx):                                          -

-Rx Errors-
Undersize:                              Oversize:                              
CRC Error:                              Jabbers:                               

-Pkt Analysis-
64 Octets:                              256 to 511 Octets:                     
65 to 127 Octets:                       512 to 1023 Octets:                    
128 to 255 Octets:                      1024 to 1518 Octets:                   

Refresh Time:10 Seconds                                     
-Counters-                           -Rx-                    -Tx-          
Unicast Packets:            0                       0              Non Unicast Packets:           0                       0              Octets:                          0                       0              Fragments(Rx)/Collisions(Tx):             0                       0              Discarded Packets(Rx):            0                       -    -                                                                                       0                              0                            0                              0          -Pkt Analysis-                                                                           0                   0                   0                   0                   0                   0          Quit    Counters      Differences      Rates/Sec     Utilizations

END


$responsesThreeCom->{'eth_1:19'} = <<'END';

  
Select menu option (physicalInterface/ethernet): detail 1:19

Port:   1:19    State:  enabled      Mode:  link down (Auto)      
Media Type: 10BASE-T/100BASE-TX
Active Features : STAP Enabled, BSC Enabled

Refresh Time:10 Seconds                   0        ss

-Counters-                           -Rx-                    -Tx-          
Unicast Packets:
Non Unicast Packets:
Octets:
Fragments(Rx)/Collisions(Tx):
Discarded Packets(Rx):                                          -

-Rx Errors-
Undersize:                              Oversize:                              
CRC Error:                              Jabbers:                               

-Pkt Analysis-
64 Octets:                              256 to 511 Octets:                     
65 to 127 Octets:                       512 to 1023 Octets:                    
128 to 255 Octets:                      1024 to 1518 Octets:                   

Refresh Time:10 Seconds                                     
-Counters-                           -Rx-                    -Tx-          
Unicast Packets:            0                       0              Non Unicast Packets:           0                       0              Octets:                          0                       0              Fragments(Rx)/Collisions(Tx):             0                       0              Discarded Packets(Rx):            0                       -    -                                                                                       0                              0                            0                              0          -Pkt Analysis-                                                                           0                   0                   0                   0                   0                   0          Quit    Counters      Differences      Rates/Sec     Utilizations

END


$responsesThreeCom->{'eth_1:20'} = <<'END';

  
Select menu option (physicalInterface/ethernet): detail 1:20

Port:   1:20    State:  enabled      Mode:  link down (Auto)      
Media Type: 10BASE-T/100BASE-TX
Active Features : STAP Enabled, BSC Enabled

Refresh Time:10 Seconds                   0        ss

-Counters-                           -Rx-                    -Tx-          
Unicast Packets:
Non Unicast Packets:
Octets:
Fragments(Rx)/Collisions(Tx):
Discarded Packets(Rx):                                          -

-Rx Errors-
Undersize:                              Oversize:                              
CRC Error:                              Jabbers:                               

-Pkt Analysis-
64 Octets:                              256 to 511 Octets:                     
65 to 127 Octets:                       512 to 1023 Octets:                    
128 to 255 Octets:                      1024 to 1518 Octets:                   

Refresh Time:10 Seconds                                     
-Counters-                           -Rx-                    -Tx-          
Unicast Packets:            0                       0              Non Unicast Packets:           0                       0              Octets:                          0                       0              Fragments(Rx)/Collisions(Tx):             0                       0              Discarded Packets(Rx):            0                       -    -                                                                                       0                              0                            0                              0          -Pkt Analysis-                                                                           0                   0                   0                   0                   0                   0          Quit    Counters      Differences      Rates/Sec     Utilizations

END


$responsesThreeCom->{'eth_1:21'} = <<'END';

  
Select menu option (physicalInterface/ethernet): detail 1:21

Port:   1:21    State:  enabled      Mode:  link down (Auto)      
Media Type: 10BASE-T/100BASE-TX
Active Features : STAP Enabled, BSC Enabled

Refresh Time:10 Seconds                   0        ss

-Counters-                           -Rx-                    -Tx-          
Unicast Packets:
Non Unicast Packets:
Octets:
Fragments(Rx)/Collisions(Tx):
Discarded Packets(Rx):                                          -

-Rx Errors-
Undersize:                              Oversize:                              
CRC Error:                              Jabbers:                               

-Pkt Analysis-
64 Octets:                              256 to 511 Octets:                     
65 to 127 Octets:                       512 to 1023 Octets:                    
128 to 255 Octets:                      1024 to 1518 Octets:                   

Refresh Time:10 Seconds                                     
-Counters-                           -Rx-                    -Tx-          
Unicast Packets:            0                       0              Non Unicast Packets:           0                       0              Octets:                          0                       0              Fragments(Rx)/Collisions(Tx):             0                       0              Discarded Packets(Rx):            0                       -    -                                                                                       0                              0                            0                              0          -Pkt Analysis-                                                                           0                   0                   0                   0                   0                   0          Quit    Counters      Differences      Rates/Sec     Utilizations

END


$responsesThreeCom->{'eth_1:22'} = <<'END';

  
Select menu option (physicalInterface/ethernet): detail 1:22

Port:   1:22    State:  enabled      Mode:  link down (Auto)      
Media Type: 10BASE-T/100BASE-TX
Active Features : STAP Enabled, BSC Enabled

Refresh Time:10 Seconds                   0        ss

-Counters-                           -Rx-                    -Tx-          
Unicast Packets:
Non Unicast Packets:
Octets:
Fragments(Rx)/Collisions(Tx):
Discarded Packets(Rx):                                          -

-Rx Errors-
Undersize:                              Oversize:                              
CRC Error:                              Jabbers:                               

-Pkt Analysis-
64 Octets:                              256 to 511 Octets:                     
65 to 127 Octets:                       512 to 1023 Octets:                    
128 to 255 Octets:                      1024 to 1518 Octets:                   

Refresh Time:10 Seconds                                     
-Counters-                           -Rx-                    -Tx-          
Unicast Packets:            0                       0              Non Unicast Packets:           0                       0              Octets:                          0                       0              Fragments(Rx)/Collisions(Tx):             0                       0              Discarded Packets(Rx):            0                       -    -                                                                                       0                              0                            0                              0          -Pkt Analysis-                                                                           0                   0                   0                   0                   0                   0          Quit    Counters      Differences      Rates/Sec     Utilizations

END


$responsesThreeCom->{'eth_1:23'} = <<'END';

  
Select menu option (physicalInterface/ethernet): detail 1:23

Port:   1:23    State:  enabled      Mode:  link down (Auto)      
Media Type: 10BASE-T/100BASE-TX
Active Features : STAP Enabled, BSC Enabled

Refresh Time:10 Seconds                   0        ss

-Counters-                           -Rx-                    -Tx-          
Unicast Packets:
Non Unicast Packets:
Octets:
Fragments(Rx)/Collisions(Tx):
Discarded Packets(Rx):                                          -

-Rx Errors-
Undersize:                              Oversize:                              
CRC Error:                              Jabbers:                               

-Pkt Analysis-
64 Octets:                              256 to 511 Octets:                     
65 to 127 Octets:                       512 to 1023 Octets:                    
128 to 255 Octets:                      1024 to 1518 Octets:                   

Refresh Time:10 Seconds                                     
-Counters-                           -Rx-                    -Tx-          
Unicast Packets:            0                       0              Non Unicast Packets:           0                       0              Octets:                          0                       0              Fragments(Rx)/Collisions(Tx):             0                       0              Discarded Packets(Rx):            0                       -    -                                                                                       0                              0                            0                              0          -Pkt Analysis-                                                                           0                   0                   0                   0                   0                   0          Quit    Counters      Differences      Rates/Sec     Utilizations

END


$responsesThreeCom->{'eth_1:24'} = <<'END';

  
Select menu option (physicalInterface/ethernet): detail 1:24

Port:   1:24    State:  enabled      Mode:  link down (Auto)      
Media Type: 10BASE-T/100BASE-TX
Active Features : STAP Enabled, BSC Enabled

Refresh Time:10 Seconds                   0        ss

-Counters-                           -Rx-                    -Tx-          
Unicast Packets:
Non Unicast Packets:
Octets:
Fragments(Rx)/Collisions(Tx):
Discarded Packets(Rx):                                          -

-Rx Errors-
Undersize:                              Oversize:                              
CRC Error:                              Jabbers:                               

-Pkt Analysis-
64 Octets:                              256 to 511 Octets:                     
65 to 127 Octets:                       512 to 1023 Octets:                    
128 to 255 Octets:                      1024 to 1518 Octets:                   

Refresh Time:10 Seconds                                     
-Counters-                           -Rx-                    -Tx-          
Unicast Packets:            0                       0              Non Unicast Packets:           0                       0              Octets:                          0                       0              Fragments(Rx)/Collisions(Tx):             0                       0              Discarded Packets(Rx):            0                       -    -                                                                                       0                              0                            0                              0          -Pkt Analysis-                                                                           0                   0                   0                   0                   0                   0          Quit    Counters      Differences      Rates/Sec     Utilizations

END


$responsesThreeCom->{'config'} = <<'END';
#<header>3Com_DEVICE</header>
#<key>3C17203M1:11</key>
#<version>1</version>
#<description>IP address 10.100.2.2, 3Com SuperStack 3, chg5, 3Com4400, testing</description>
#<usernotes>ZipTie Backup</usernotes>
#<mode>ERROR_CHECK_ON</mode>

#
# WARNING:  This file is  automatically  generated  and follows  specific
# command ordering  rules. Users  may add  or alter commands in this file
# but must do so with caution as it may affect the ability to restore the
# configuration of the device.
#
# Password, community string and IP address information may be added to
# this file but are not automatically saved by the system to avoid breaches
# of security. If these commands are to be added please add them at the
# end of the file.
#
# The following key can be used to disable the error checking while the
# configuration is restored:
#     #<mode>ERROR_CHECK_OFF</mode>
# To re-enable error checking use the following key:
#     #<mode>ERROR_CHECK_ON</mode>
#

#--------------------------------------------------------------
#  PRODUCT  INFORMATION  SECTION
#--------------------------------------------------------------
# Unit Number		: 1
# Description		: Switch 4400
# Product Number	: 3C17203
# MAC Address		: 00:0a:04:de:a6:c0
# Serial Number		: 7PVV1Q7DEA6C0
# Software Version	: 3.21
# Hardware Version	: 05.02.00
# Module Slot 1		: No module fitted
# Module Slot 2		: No module fitted
#

#--------------------------------------------------------------
#  FEATURE SAFE BACKUP  SECTION
#--------------------------------------------------------------
bridge spanningTree stpState enable
bridge port lacpState 1:1-1:24 disable
bridge linkAggregation modify partnerID 1 0x8000 none
bridge linkAggregation modify partnerID 2 0x8000 none
bridge linkAggregation modify partnerID 3 0x8000 none
bridge linkAggregation modify partnerID 4 0x8000 none

#--------------------------------------------------------------
#  BRIDGE  PORT  SECTION
#--------------------------------------------------------------
bridge port stpCost 1:1-1:24,AL1-AL4 auto
bridge port defaultPriority 1:1-1:24,AL1-AL4 0
bridge port stpFastStart 1:1-1:24 enable
bridge port stpFastStart AL1-AL4 disable

#--------------------------------------------------------------
#  PHYSICALINTERFACE  ETHERNET  SECTION
#--------------------------------------------------------------
physicalInterface ethernet flowControl 1:1-1:24 on
physicalInterface ethernet portMode 1:1-1:24 enable 100half
physicalInterface ethernet portState 1:1-1:24 enable
physicalInterface ethernet smartAutoSense enable

#--------------------------------------------------------------
#  PHYSICALINTERFACE  POWER  SECTION
#--------------------------------------------------------------

#--------------------------------------------------------------
#  BRIDGE  VLAN  SECTION
#--------------------------------------------------------------

#--------------------------------------------------------------
#  BRIDGE VLAN MODIFY  SECTION
#--------------------------------------------------------------

#--------------------------------------------------------------
#  BRIDGE  ADDRESSDATABASE  SECTION
#--------------------------------------------------------------
bridge addressDatabase agingTime 300

#--------------------------------------------------------------
#  BRIDGE  LINKAGGREGATION  SECTION
#--------------------------------------------------------------
bridge linkAggregation modify linkState 1 enable
bridge linkAggregation modify linkState 2 enable
bridge linkAggregation modify linkState 3 enable
bridge linkAggregation modify linkState 4 enable
bridge port lacpState 1:1-1:24 disable

#--------------------------------------------------------------
#  BRIDGE  SPANNINGTREE  SECTION
#--------------------------------------------------------------
bridge spanningTree stpVersion 2
bridge spanningTree stpDefaultPathCost 1
bridge spanningTree stpPriority 32768
bridge spanningTree stpMaxAge 20
bridge spanningTree stpHelloTime 2
bridge spanningTree stpForwardDelay 15
bridge spanningTree stpState enable

#--------------------------------------------------------------
#  BRIDGE  MULITICASTFILTER  IGMP  SECTION
#--------------------------------------------------------------
bridge multicastFilter igmp queryMode disable
bridge multicastFilter igmp snoopMode enable

#--------------------------------------------------------------
#  BRIDGE  MULTICASTFILTER  ROUTERPORT  SECTION
#--------------------------------------------------------------
bridge multicastFilter routerPort autoDiscovery enable

#--------------------------------------------------------------
#  BRIDGE  BROADCASTSTORMCONTROL  SECTION
#--------------------------------------------------------------
bridge broadcastStormCont enable 3000

#--------------------------------------------------------------
#  FEATURE  CACHECONFIG  SECTION
#--------------------------------------------------------------

#--------------------------------------------------------------
#  FEATURE  ROVINGANALYSIS  SECTION
#--------------------------------------------------------------

#--------------------------------------------------------------
#  PROTOCOL  IP  INTERFACE  SECTION
#--------------------------------------------------------------

#--------------------------------------------------------------
#  PROTOCOL  IP  ROUTE  SECTION
#--------------------------------------------------------------

#--------------------------------------------------------------
#  SECURITY  RADIUS  SECTION
#--------------------------------------------------------------
security radius authentication modify 0.0.0.0 1812 0.0.0.0 1812
security radius accounting modify 0.0.0.0 1813 0.0.0.0 1813 reject
security radius retries 4 2

#--------------------------------------------------------------
#  SECURITY  DEVICE  ACCESS  SECTION
#--------------------------------------------------------------
security device access modify monitor enable enable enable enable
security device access modify manager enable enable enable enable
security device access modify security enable enable enable enable

#--------------------------------------------------------------
#  SECURITY  DEVICE  AUTHENTICATION  SECTION
#--------------------------------------------------------------
security device authentication systemMode local yes yes

#--------------------------------------------------------------
#  SECURITY  DEVICE  USER  SECTION
#--------------------------------------------------------------

#--------------------------------------------------------------
#  SECURITY NETWORK ACCESS  SECTION
#--------------------------------------------------------------
security network access systemMode enable
security network access portSecurity 1:1-1:24 noSecurity

#--------------------------------------------------------------
#  SYSTEM  MANAGEMENT  SECTION
#--------------------------------------------------------------
system management name "3Com4400"
system management location "testing"
system management contact "chg5"
system management remoteAccess enable

#--------------------------------------------------------------
#  SYSTEM  MANAGEMENT  SNMP  TRAP  SECTION
#--------------------------------------------------------------
system management snmp trap create public 10.10.1.62
system management snmp trap create monitor 1.1.1.1
system management snmp trap create admin 10.10.1.119
system management snmp trap create monitor 1.1.1.1
system management snmp trap create public 10.10.1.62
system management snmp trap create monitor 1.1.1.1
system management snmp trap create admin 10.10.1.119
system management snmp trap create monitor 1.1.1.1

#--------------------------------------------------------------
#  SYSTEM  MANAGEMENT  ALERT  SECTION
#--------------------------------------------------------------
system management alert create email 1.1.1.1 25 "alert1" "user@user.com" ""

#--------------------------------------------------------------
#  SYSTEM MANAGEMENT MONITOR  SECTION
#--------------------------------------------------------------
system management monitor modify systemDevice off none none
system management monitor modify port 1:1-1:24 off none none

#--------------------------------------------------------------
#  TRAFFICMANAGEMENT  QOS  CLASSIFIER  SECTION
#--------------------------------------------------------------
trafficManagement qos classifier modify 1 "All Traffic"
trafficManagement qos classifier modify 2 "3Com NBX Voice-LAN"  0x8868
trafficManagement qos classifier modify 3 "3Com NBX Voice-IP"  46
trafficManagement qos classifier modify 4 "Web-HTTP"  tcp 80
trafficManagement qos classifier modify 5 "Network Management-SNMP"  udp 161

#--------------------------------------------------------------
#  TRAFFICMANAGEMENT  QOS  SERVICELEVEL  SECTION
#--------------------------------------------------------------
trafficManagement qos serviceLevel modify 2 "Best Effort" 0 0
trafficManagement qos serviceLevel modify 3 "Business Critical" 3 16
trafficManagement qos serviceLevel modify 4 "Video Applications" 5 24
trafficManagement qos serviceLevel modify 5 "Voice Applications" 6 46
trafficManagement qos serviceLevel modify 6 "Network Control" 7 48

#--------------------------------------------------------------
#  TRAFFICMANAGEMENT QOS PROFILE  SECTION
#--------------------------------------------------------------
trafficManagement qos profile modify 1 "No Classifiers"
trafficManagement qos profile modify 2 "Default"
trafficManagement qos profile addClassifier 2 2 5
trafficManagement qos profile addClassifier 2 3 5
trafficManagement qos profile assign 1:1-1:24 2

#--------------------------------------------------------------
#  BRIDGE  RESILIENTLINKS  SECTION
#--------------------------------------------------------------

#
# End of automatically generated configuration.
# You can enter further commands, if they are supported on the product, after these comments:
#
# Note: If you restore RADIUS configuration you can add the shared secret below.
#       You can also change the authentication mode to RADIUS with the following
#       command:
#  security authentication systemMode RADIUS yes yes
#
# Examples:
#  physical ethernet portCapabilities 1:1 10h
#  protocol ip basicConfig manual 10.16.25.26 255.255.255.0 10.16.25.250
#  protocol ip rip authentication 10.16.25.32 password "my rip password" "my rip password"
#  security device user create "my name" monitor "my password" "my password" "my community"
#  security device user modify admin "secret" "secret" "private"
#  security radius sharedSecret "this is my shared secret"
#  system management snmp community "private" "manager" "public"



#----------------- End of configuration file ------------------


END
