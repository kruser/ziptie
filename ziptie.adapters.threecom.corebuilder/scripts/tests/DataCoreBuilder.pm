package DataCoreBuilder;

use strict;
use warnings;
use Exporter 'import';
our @EXPORT_OK = qw($responsesCoreBuilder);

our $responsesCoreBuilder = {};

$responsesCoreBuilder->{uptime} = 66844700;

$responsesCoreBuilder->{system} = <<'SYSTEM';

Select menu option: system display
SuperStack II Switch 9300 (rev 0.0) - System ID 9ece61
Version 1.0.1 - Built 05/19/98 03:45:10 PM
System up time: 153 Days 4 Hours 10 Minutes 24 Seconds
Time in Service: 1134 Days
System Name: SuperStack II Switch-9ECE61

                                       Rev Diagnostics  Serial       3C Number
    1000BaseSX M/B, 9 MMF SC ports      AB Passed       2KCE011465   3C93011
    1000BaseLX:SX, 1:2 MMF:SMF SC ports AB Passed       2KTE000850   3C93011
    10BaseT OOB, 1 RJ45 port            AB Passed       2KEE003272   3C93011

AP Memory Size     : 8 Mb
FP Memory Size     : 0 Mb
Flash Memory Size  : 2 Mb
Buffer Memory Size : 0 Mb

Menu options (SuperStack II Switch-9ECE61): ------------------------------------
  system                   - Administer system-level functions
  management               - Administer system management interface
  ethernet                 - Administer Ethernet ports
  bridge                   - Administer bridging/VLANs
  ip                       - Administer IP
  snmp                     - Administer SNMP
  script                   - Run a script of console commands
  logout                   - Logout of the Administration Console

Type ? for help.
--------------------------------------------------------------------------------
Select menu option:

SYSTEM


$responsesCoreBuilder->{config} = <<'CONFIG';
----------------------------------------------------------------------------    

Screen system/display                                                           
Processing screen system/display
SuperStack II Switch 9300 (rev 0.0) - System ID 9ece61                          
Version 1.0.1 - Built 05/19/98 03:45:10 PM                                      
System up time: 33 Minutes 47 Seconds                                           
Time in Service: 1136 Days                                                      
System Name: SuperStack II Switch-9ECE61
                                       
                                       Rev Diagnostics  Serial       3C Number  
    1000BaseSX M/B, 9 MMF SC ports      AB Passed       2KCE011465   3C93011    
    1000BaseLX:SX, 1:2 MMF:SMF SC ports AB Passed       2KTE000850   3C93011    
    10BaseT OOB, 1 RJ45 port            AB Passed       2KEE003272   3C93011    

AP Memory Size     : 8 Mb                                                      
FP Memory Size     : 0 Mb                                                       
Flash Memory Size  : 2 Mb                                                       
Buffer Memory Size : 0 Mb                                                       
----------------------------------------------------------------------------    

Screen system/baseline/display                                                  
Processing screen system/baseline/display

A baseline has not yet been set.
                                              
----------------------------------------------------------------------------    

Screen management/summary                                                       
Processing screen management/summary

                                 portLabel                                      
                                                                                

                                  portType            portState                 
                             10BaseT(RJ45)              on-line                 

           linkStatus          autoNegMode         autoNegState                 
              enabled                  n/a                  n/a                 

          reqPortMode       actualPortMode       reqFlowControl                 
               10half               10half                  n/a                 

    actualFlowControl             rxFrames             txFrames                 
                  n/a                 1216                 1076                 

              rxBytes              txBytes               rxErrs                 
                95936               226688                    0                 

               txErrs          noRxBuffers         txQOverflows                 
                    0                  n/a                  n/a                 

           macAddress                                                           
    00-80-3e-9e-ce-61                                                           
----------------------------------------------------------------------------    

Screen ethernet/summary                                                         
Processing screen ethernet/summary

port                                              portLabel                     
1                                                                               
2                                                                               
3                                                                               
4                                                                               
5                                                                               
6                                                                               
7                                                                               
8                                                                               
9                                                                               
10                                                                              
11                                                                              
12                                                                              

port                                               portType            portState
1                                          1000BaseLX(SC)SM             off-line
2                                          1000BaseLX(SC)SM             off-line
3                                            1000BaseSX(SC)             off-line
4                                            1000BaseSX(SC)             off-line
5                                            1000BaseSX(SC)             off-line
6                                            1000BaseSX(SC)             off-line
7                                            1000BaseSX(SC)             off-line
8                                            1000BaseSX(SC)             off-line
9                                            1000BaseSX(SC)             off-line
10                                           1000BaseSX(SC)             off-line
11                                           1000BaseSX(SC)             off-line
12                                           1000BaseSX(SC)             off-line

port                        linkStatus          autoNegMode         autoNegState
1                             disabled               enable             disabled
2                             disabled               enable             disabled
3                             disabled               enable             disabled
4                             disabled               enable             disabled
5                             disabled               enable               failed
6                             disabled               enable               failed
7                             disabled               enable               failed
8                             disabled               enable               failed
9                             disabled               enable               failed
10                            disabled               enable               failed
11                            disabled               enable               failed
12                            disabled               enable               failed

port                       reqPortMode       actualPortMode       reqFlowControl
1                             1000full             1000full                 rxOn
2                             1000full             1000full                 rxOn
3                             1000full             1000full                 rxOn
4                             1000full             1000full                 rxOn
5                             1000full             1000full                 rxOn
6                             1000full             1000full                 rxOn
7                             1000full             1000full                 rxOn
8                             1000full             1000full                 rxOn
9                             1000full             1000full                 rxOn
10                            1000full             1000full                 rxOn
11                            1000full             1000full                 rxOn
12                            1000full             1000full                 rxOn

port                 actualFlowControl             rxFrames             txFrames
1                                  off                    0                    0
2                                  off                    0                    0
3                                  off                    0                    0
4                                  off                    0                    0
5                                  off                    0                    0
6                                  off                    0                    0
7                                  off                    0                    0
8                                  off                    0                    0
9                                  off                    0                    0
10                                 off                    0                    0
11                                 off                    0                    0
12                                 off                    0                    0

port                           rxBytes              txBytes               rxErrs
1                                    0                    0                  n/a
2                                    0                    0                  n/a
3                                    0                    0                  n/a
4                                    0                    0                  n/a
5                                    0                    0                  n/a
6                                    0                    0                  n/a
7                                    0                    0                  n/a
8                                    0                    0                  n/a
9                                    0                    0                  n/a
10                                   0                    0                  n/a
11                                   0                    0                  n/a
12                                   0                    0                  n/a

port                            txErrs          noRxBuffers         txQOverflows
1                                  n/a                    0                    0
2                                  n/a                    0                    0
3                                  n/a                    0                    0
4                                  n/a                    0                    0
5                                  n/a                    0                    0
6                                  n/a                    0                    0
7                                  n/a                    0                    0
8                                  n/a                    0                    0
9                                  n/a                    0                    0
10                                 n/a                    0                    0
11                                 n/a                    0                    0
12                                 n/a                    0                    0

port                        macAddress                                          
1                    00-80-3e-9e-ce-62                                          
2                    00-80-3e-9e-ce-63                                          
3                    00-80-3e-9e-ce-64                                          
4                    00-80-3e-9e-ce-65                                          
5                    00-80-3e-9e-ce-66                                          
6                    00-80-3e-9e-ce-67                                          
7                    00-80-3e-9e-ce-68                                          
8                    00-80-3e-9e-ce-69                                          
9                    00-80-3e-9e-ce-6a                                          
10                   00-80-3e-9e-ce-6b                                          
11                   00-80-3e-9e-ce-6c                                          
12                   00-80-3e-9e-ce-6d                                          
----------------------------------------------------------------------------    

Screen bridge/display                                                           
Processing screen bridge/display

             stpState               timeSinceLastTopologyChange                 
             disabled                       0 hrs 0 mins 0 secs                 

  topologyChangeCount   topologyChangeFlag     BridgeIdentifier                 
                    0                false    8000 00803e9ece62                 

       designatedRoot      stpGroupAddress         bridgeMaxAge                 
    0000 000000000000    01-80-c2-00-00-00                   20                 

               maxAge      bridgeHelloTime            helloTime                 
                   20                    2                    2                 

       bridgeFwdDelay         forwardDelay             holdTime                 
                   15                   15                    1                 

             rootCost             rootPort             priority                 
                    0              No port               0x8000                 

            agingTime                 mode        addrTableSize                 
                  300          transparent                16384                 

         addressCount        peakAddrCount        addrThreshold                 
                    1                    1                  n/a                 

           lowLatency                                                           
                  n/a                                                           
----------------------------------------------------------------------------    

Screen bridge/port/summary                                                      
Processing screen bridge/port/summary

port                          rxFrames           rxDiscards             txFrames
1-4                                  0                    0                 3900
5                                    0                    0                  975
6                                    0                    0                  975
7                                    0                    0                  975
8                                    0                    0                  975
9                                    0                    0                  975
10                                   0                    0                  975
11                                   0                    0                  975
12                                   0                    0                  975

port                                             portNumber               portId
1-4                                                       1               0x8001
5                                                         2               0x8002
6                                                         3               0x8003
7                                                         4               0x8004
8                                                         5               0x8005
9                                                         6               0x8006
10                                                        7               0x8007
11                                                        8               0x8008
12                                                        9               0x8009

port                    fwdTransitions                  stp            linkState
1-4                                  0              enabled                 down
5                                    0              enabled                 down
6                                    0              enabled                 down
7                                    0              enabled                 down
8                                    0              enabled                 down
9                                    0              enabled                 down
10                                   0              enabled                 down
11                                   0              enabled                 down
12                                   0              enabled                 down

port                             state                                          
1-4                           disabled                                          
5                             disabled                                          
6                             disabled                                          
7                             disabled                                          
8                             disabled                                          
9                             disabled                                          
10                            disabled                                          
11                            disabled                                          
12                            disabled                                          
----------------------------------------------------------------------------    

Screen bridge/vlan/summary                                                      
Processing screen bridge/vlan/summary

VLAN summary

VLAN Mode: allOpen
                                              

Index   VID  Type    Origin  Name                              Ports           
    1     1  open    static  Test1                             8                
----------------------------------------------------------------------------    

Screen bridge/trunk/summary                                                     
Processing screen bridge/trunk/summary

Trunk summary
                                                                 

Index  Name                              State      TCMP      Ports            
    1  trunk1                            down       enabled   1-4               
----------------------------------------------------------------------------    

Screen ip/interface/summary                                                     
Processing screen ip/interface/summary
                                                                                

Index  Type        IP address       Subnet mask      State                     
    1  System      10.100.21.4      255.255.255.0    Up                         
----------------------------------------------------------------------------    

Screen ip/route/display                                                         
Processing screen ip/route/display

                                                                                

There are 3 Routing Table entries                                               

   Destination      Subnet mask      Metric  Gateway          Status            
   Default Route     --                  --  10.100.21.1      Static            
   10.100.21.0      255.255.255.0        --   --              Direct            
   10.100.21.4      255.255.255.255      --   --              Local             
----------------------------------------------------------------------------    

Screen ip/arp/display                                                           
Processing screen ip/arp/display

                                                                                

There is 1 ARP cache entry                                                      

IP address      Type     I/F                         Hardware address Circuit   
10.100.21.1     dynamic  1                           00-17-94-45-ee-d0 -/-      
----------------------------------------------------------------------------    

Screen ip/rip/display                                                           
Processing screen ip/rip/display

                                                                                

  RIP interface information:                                                    

  Index  Mode       Cost  PoisonReverse  AdvertisementAddress                   
  1      learn      1     enabled        10.100.21.255                          
----------------------------------------------------------------------------    

Screen ip/dns/display                                                           
Processing screen ip/dns/display

No Domain Name is defined                                                       
No Name Server IP addresses are defined                                         
----------------------------------------------------------------------------    

Screen snmp/display                                                             
Processing screen snmp/display
Read-only community is public                                                   
Read-write community is testenv                                                 
----------------------------------------------------------------------------    

Screen snmp/trap/display                                                        
Processing screen snmp/trap/display
No trap destination info configured                                             

Menu options (SuperStack II Switch-9ECE61): ------------------------------------
  system                   - Administer system-level functions                 
  management               - Administer system management interface            
  ethernet                 - Administer Ethernet ports                         
  bridge                   - Administer bridging/VLANs                         
  ip                       - Administer IP                                     
  snmp                     - Administer SNMP                                   
  script                   - Run a script of console commands                  
  logout                   - Logout of the Administration Console              

Type ? for help.
--------------------------------------------------------------------------------

CONFIG

$responsesCoreBuilder->{interfaces} = <<'INTS';
Select menu option: ethernet summary all

port                                              portLabel
1
2
3
4
5
6
7
8
9
10
11
12

port                                               portType            portState
1                                          1000BaseLX(SC)SM             off-line
2                                          1000BaseLX(SC)SM             off-line
3                                            1000BaseSX(SC)             off-line
4                                            1000BaseSX(SC)             off-line
5                                            1000BaseSX(SC)             off-line
6                                            1000BaseSX(SC)             off-line
7                                            1000BaseSX(SC)             off-line
8                                            1000BaseSX(SC)             off-line
9                                            1000BaseSX(SC)             off-line
10                                           1000BaseSX(SC)             off-line
11                                           1000BaseSX(SC)             off-line
12                                           1000BaseSX(SC)             off-line

port                        linkStatus          autoNegMode         autoNegState
1                             disabled               enable             disabled
2                             disabled               enable             disabled
3                             disabled               enable             disabled
4                             disabled               enable             disabled
5                             disabled               enable               failed
6                             disabled               enable               failed
7                             disabled               enable               failed
8                             disabled               enable               failed
9                             disabled               enable               failed
10                            disabled               enable               failed
11                            disabled               enable               failed
12                            disabled               enable               failed

port                       reqPortMode       actualPortMode       reqFlowControl
1                             1000full             1000full                 rxOn
2                             1000full             1000full                 rxOn
3                             1000full             1000full                 rxOn
4                             1000full             1000full                 rxOn
5                             1000full             1000full                 rxOn
6                             1000full             1000full                 rxOn
7                             1000full             1000full                 rxOn
8                             1000full             1000full                 rxOn
9                             1000full             1000full                 rxOn
10                            1000full             1000full                 rxOn
11                            1000full             1000full                 rxOn
12                            1000full             1000full                 rxOn

port                 actualFlowControl             rxFrames             txFrames
1                                  off                    0                    0
2                                  off                    0                    0
3                                  off                    0                    0
4                                  off                    0                    0
5                                  off                    0                    0
6                                  off                    0                    0
7                                  off                    0                    0
8                                  off                    0                    0
9                                  off                    0                    0
10                                 off                    0                    0
11                                 off                    0                    0
12                                 off                    0                    0

port                           rxBytes              txBytes               rxErrs
1                                    0                    0                  n/a
2                                    0                    0                  n/a
3                                    0                    0                  n/a
4                                    0                    0                  n/a
5                                    0                    0                  n/a
6                                    0                    0                  n/a
7                                    0                    0                  n/a
8                                    0                    0                  n/a
9                                    0                    0                  n/a
10                                   0                    0                  n/a
11                                   0                    0                  n/a
12                                   0                    0                  n/a

port                            txErrs          noRxBuffers         txQOverflows
1                                  n/a                    0                    0
2                                  n/a                    0                    0
3                                  n/a                    0                    0
4                                  n/a                    0                    0
5                                  n/a                    0                    0
6                                  n/a                    0                    0
7                                  n/a                    0                    0
8                                  n/a                    0                    0
9                                  n/a                    0                    0
10                                 n/a                    0                    0
11                                 n/a                    0                    0
12                                 n/a                    0                    0

port                        macAddress
1                    00-80-3e-9e-ce-62
2                    00-80-3e-9e-ce-63
3                    00-80-3e-9e-ce-64
4                    00-80-3e-9e-ce-65
5                    00-80-3e-9e-ce-66
6                    00-80-3e-9e-ce-67
7                    00-80-3e-9e-ce-68
8                    00-80-3e-9e-ce-69
9                    00-80-3e-9e-ce-6a
10                   00-80-3e-9e-ce-6b
11                   00-80-3e-9e-ce-6c
12                   00-80-3e-9e-ce-6d

Menu options (SuperStack): -----------------------------------------------------
  system                   - Administer system-level functions
  management               - Administer system management interface
  ethernet                 - Administer Ethernet ports
  bridge                   - Administer bridging/VLANs
  ip                       - Administer IP
  snmp                     - Administer SNMP
  script                   - Run a script of console commands
  logout                   - Logout of the Administration Console

Type ? for help.
--------------------------------------------------------------------------------
Select menu option:



INTS

$responsesCoreBuilder->{snmp} = <<'SNMP';

Select menu option: snmp display
Read-only community is public
Read-write community is testenv

Menu options (SuperStack II Switch-9ECE61): ------------------------------------
  system                   - Administer system-level functions
  management               - Administer system management interface
  ethernet                 - Administer Ethernet ports
  bridge                   - Administer bridging/VLANs
  ip                       - Administer IP
  snmp                     - Administer SNMP
  script                   - Run a script of console commands
  logout                   - Logout of the Administration Console

Type ? for help.
--------------------------------------------------------------------------------
Select menu option:


SNMP

$responsesCoreBuilder->{routes} = <<'ROUTES';

Select menu option: ip route display



There are 3 Routing Table entries

   Destination      Subnet mask      Metric  Gateway          Status
   Default Route     --                  --  10.100.21.1      Static
   10.100.21.0      255.255.255.0        --   --              Direct
   10.100.21.4      255.255.255.255      --   --              Local

Menu options (SuperStack II Switch-9ECE61): ------------------------------------
  system                   - Administer system-level functions
  management               - Administer system management interface
  ethernet                 - Administer Ethernet ports
  bridge                   - Administer bridging/VLANs
  ip                       - Administer IP
  snmp                     - Administer SNMP
  script                   - Run a script of console commands
  logout                   - Logout of the Administration Console

Type ? for help.
--------------------------------------------------------------------------------
Select menu option:


ROUTES

$responsesCoreBuilder->{stp} = <<'STP';

Select menu option: bridge display

             stpState               timeSinceLastTopologyChange
             disabled                       0 hrs 0 mins 0 secs

  topologyChangeCount   topologyChangeFlag     BridgeIdentifier
                    0                false    8000 00803e9ece62

       designatedRoot      stpGroupAddress         bridgeMaxAge
    0000 000000000000    01-80-c2-00-00-00                   20

               maxAge      bridgeHelloTime            helloTime
                   20                    2                    2

       bridgeFwdDelay         forwardDelay             holdTime
                   15                   15                    1

             rootCost             rootPort             priority
                    0              No port               0x8000

            agingTime                 mode        addrTableSize
                  300          transparent                16384

         addressCount        peakAddrCount        addrThreshold
                    0                    0                  n/a

           lowLatency
                  n/a

Menu options (SuperStack II Switch-9ECE61): ------------------------------------
  system                   - Administer system-level functions
  management               - Administer system management interface
  ethernet                 - Administer Ethernet ports
  bridge                   - Administer bridging/VLANs
  ip                       - Administer IP
  snmp                     - Administer SNMP
  script                   - Run a script of console commands
  logout                   - Logout of the Administration Console

Type ? for help.
--------------------------------------------------------------------------------
Select menu option:


STP


$responsesCoreBuilder->{stp_ifs} = <<'STP_IFS';

Select menu option: bridge port detail all

port                          rxFrames                            rxSameSegDiscs
1-4                                  0                                         0
5                                    0                                         0
6                                    0                                         0
7                                    0                                         0
8                                    0                                         0
9                                    0                                         0
10                                   0                                         0
11                                   0                                         0
12                                   0                                         0

port                     rxNoDestDiscs         rxErrorDiscs     rxMcastLimitType
1-4                                  0                    0           McastBcast
5                                    0                    0           McastBcast
6                                    0                    0           McastBcast
7                                    0                    0           McastBcast
8                                    0                    0           McastBcast
9                                    0                    0           McastBcast
10                                   0                    0           McastBcast
11                                   0                    0           McastBcast
12                                   0                    0           McastBcast

port                      rxMcastLimit      rxMcastExcDiscs       rxMcastExceeds
1-4                                  0                    0                    0
5                                    0                    0                    0
6                                    0                    0                    0
7                                    0                    0                    0
8                                    0                    0                    0
9                                    0                    0                    0
10                                   0                    0                    0
11                                   0                    0                    0
12                                   0                    0                    0

port                   rxSecurityDiscs         rxOtherDiscs      rxForwardUcasts
1-4                                  0                    0                    0
5                                    0                    0                    0
6                                    0                    0                    0
7                                    0                    0                    0
8                                    0                    0                    0
9                                    0                    0                    0
10                                   0                    0                    0
11                                   0                    0                    0
12                                   0                    0                    0

port                     rxFloodUcasts      rxForwardMcasts             txFrames
1-4                                  0                    0              5650792
5                                    0                    0              1412698
6                                    0                    0              1412698
7                                    0                    0              1412698
8                                    0                    0              1412698
9                                    0                    0              1412698
10                                   0                    0              1412698
11                                   0                    0              1412698
12                                   0                    0              1412698

port                        portNumber               portId       fwdTransitions
1-4                                  1               0x8001                    0
5                                    2               0x8002                    0
6                                    3               0x8003                    0
7                                    4               0x8004                    0
8                                    5               0x8005                    0
9                                    6               0x8006                    0
10                                   7               0x8007                    0
11                                   8               0x8008                    0
12                                   9               0x8009                    0

port                               stp            linkState                state
1-4                            enabled                 down             disabled
5                              enabled                 down             disabled
6                              enabled                 down             disabled
7                              enabled                 down             disabled
8                              enabled                 down             disabled
9                              enabled                 down             disabled
10                             enabled                 down             disabled
11                             enabled                 down             disabled
12                             enabled                 down             disabled

port                          priority             pathCost       designatedCost
1-4                               0x80                    1                    0
5                                 0x80                    1                    0
6                                 0x80                    1                    0
7                                 0x80                    1                    0
8                                 0x80                    1                    0
9                                 0x80                    1                    0
10                                0x80                    1                    0
11                                0x80                    1                    0
12                                0x80                    1                    0

port                    designatedPort       designatedRoot     designatedBridge
1-4                                0x0    0000 000000000000    0000 000000000000
5                                  0x0    0000 000000000000    0000 000000000000
6                                  0x0    0000 000000000000    0000 000000000000
7                                  0x0    0000 000000000000    0000 000000000000
8                                  0x0    0000 000000000000    0000 000000000000
9                                  0x0    0000 000000000000    0000 000000000000
10                                 0x0    0000 000000000000    0000 000000000000
11                                 0x0    0000 000000000000    0000 000000000000
12                                 0x0    0000 000000000000    0000 000000000000

Menu options (SuperStack): -----------------------------------------------------
  system                   - Administer system-level functions
  management               - Administer system management interface
  ethernet                 - Administer Ethernet ports
  bridge                   - Administer bridging/VLANs
  ip                       - Administer IP
  snmp                     - Administer SNMP
  script                   - Run a script of console commands
  logout                   - Logout of the Administration Console

Type ? for help.
--------------------------------------------------------------------------------
Select menu option:

STP_IFS
