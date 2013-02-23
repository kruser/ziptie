package DataHPProcurveM;

use strict;
use warnings;
use Exporter 'import';
our @EXPORT_OK = qw($responsesHPProcurveM);

our $responsesHPProcurveM = {};

$responsesHPProcurveM->{'system'} = <<'END';
                                                                              14                                                                      
                                                                                                                                                      
                                                                                                                                                      
                Status and Counters - General System Information                                                                                      
                                                                                                                                                      
  System Contact     : Change1                                                                                                                        
  System Location    : Austin                                                                                                                         
                                                                                                                                                      
  Firmware revision  : C.09.16          Base MAC Addr      : 001083-0e4b00                                                                            
  ROM Version        : C.06.01          Serial Number      : SG91500503                                                                               
                                                                                                                                                      
  Up Time            : 192 days         Memory   - Total   : 7,367,520                                                                                
  CPU Util (%)       : 10                          Free    : 4,321,920                                                                                
                                                                                                                                                      
  IP Mgmt  - Pkts Rx : 3,642,451        Packet   - Total   : 382                                                                                      
             Pkts Tx : 50,536,915       Buffers    Free    : 139                                                                                      
                                                   Lowest  : 39                                                                                       
                                                   Missed  : 0                                                                                        
                                                                                                                                                      
 Actions->   Back     Help                                                                                                                            
                                                                                                                                                      
Return to previous screen.                                                                                                                            
Use arrow keys to change action selection and <Enter> to execute action.                                                                              
                                                                                                                                                      
                                                                                                                                                      

END

$responsesHPProcurveM->{module} = <<'END';
                                                           12-Jul-1990   2:12:06                                                                      
                                                                                                                                                      
                                                                                                                                                      
                    Status and Counters - Module Information                                                                                          
                                                                                                                                                      
  Slot    Module Type                 Module Description                                                                                              
  ----  ---------------  ---------------------------------------------                                                                                
  A     10/100TX         HP J4111A 8-port 10/100Base-TX module                                                                                        
  B                      Slot Available                                                                                                               
  C                      Slot Available                                                                                                               
  D                      Slot Available                                                                                                               
  E                      Slot Available                                                                                                               
  F                      Slot Available                                                                                                               
  G                      Slot Available                                                                                                               
  H                      Slot Available                                                                                                               
  I                      Slot Available                                                                                                               
  J                      Slot Available                                                                                                               
                                                                                                                                                      
                                                                                                                                                      
 Actions->   Back     Help                                                                                                                            
                                                                                                                                                      
Return to previous screen.                                                                                                                            
Use up/down arrow keys to scroll to other entries, left/right arrow keys to                                                                           
change action selection, and <Enter> to execute action.                                                                                               
                                                                                                                                                      

END

$responsesHPProcurveM->{config_plain} = <<'END';
                                                            5-Jul-1990  23:48:10                                                                      
                                                                                                                                                      
                                                                                                                                                      
                               System Information                                                                                                     
                                                                                                                                                      
  System Name : HP4000M                                                                                                                               
  System Contact : Change1                                                                                                                            
  System Location : Austin                                                                                                                            
                                                                                                                                                      
  Inactivity Timeout (min) [0] : 0                                                                                                                    
  MAC Age Interval (min) [5] : 5                                                                                                                      
  Web Agent Enabled [Yes] : Yes         Enable CDP [Yes] : Yes                                                                                        
                                        CDP Hold Time [180] : 180                                                                                     
                                        CDP Transmit Interval [60] : 60                                                                               
                                                                                                                                                      
                                                                                                                                                      
                                                                                                                                                      
  Time Zone [0] : 0                                                                                                                                   
  Daylight Time Rule [None] : None                                                                                                                    
                                                                                                                                                      
                                                                                                                                                      
==============================================================================                                                                        
                                 Port Settings                                                                                                        
-- MORE --                                                                                                                                            
                                                                                                                                                      
                                                            5-Jul-1990  23:48:13                                                                      
                                                                                                                                                      
                                                                                                                                                      
                                                                                                                                                      
   Port      Type    | Enabled      Mode      Flow Ctrl  Bcast Limit                                                                                  
  -------  --------- + -------  ------------  ---------  -----------                                                                                  
  A1       10/100TX  | Yes      10HDx         Disable    0                                                                                            
  A2       10/100TX  | Yes      Auto          Disable    0                                                                                            
  A3       10/100TX  | Yes      Auto          Disable    0                                                                                            
  A4-Trk4  10/100TX  | Yes      Auto          Disable    0                                                                                            
  A5-Mesh  10/100TX  | Yes      Auto          Disable    0                                                                                            
  A6       10/100TX  | Yes      Auto          Disable    0                                                                                            
  A7       10/100TX  | Yes      Auto          Disable    0                                                                                            
  A8-Trk1  10/100TX  | Yes      Auto          Disable    0                                                                                            
                                                                                                                                                      
                                                                                                                                                      
==============================================================================                                                                        
                             Internet (IP) Service                                                                                                    
                                                                                                                                                      
  Time Sync. mode [None] : SNTP                                                                                                                       
  SNTP Mode [Disabled] : Unicast                                                                                                                      
                                                                                                                                                      
                                                                                                                                                      
-- MORE --                                                                                                                                            
                                                                                                                                                      
                                                            5-Jul-1990  23:48:17                                                                      
                                                                                                                                                      
                                                                                                                                                      
  Server Address   Server Version                                                                                                                     
  ---------------  --------------                                                                                                                     
  10.10.1.36       3                                                                                                                                  
                                                                                                                                                      
                                                                                                                                                      
      VLAN     | IP Config     IP Address       Subnet Mask        Gateway                                                                            
  ------------ + ----------  ---------------  ---------------  ---------------                                                                        
  DEFAULT_VLAN | Manual      10.100.2.7       255.255.255.0    10.100.2.1                                                                             
  vlan2        | DHCP/Bootp  0.0.0.0          0.0.0.0          0.0.0.0                                                                                
                                                                                                                                                      
                                                                                                                                                      
==============================================================================                                                                        
                                   VLAN Names                                                                                                         
                                                                                                                                                      
      Name      802.1Q VLAN ID                                                                                                                        
  ------------  --------------                                                                                                                        
  DEFAULT_VLAN  1                                                                                                                                     
  vlan2         2                                                                                                                                     
                                                                                                                                                      
                                                                                                                                                      
-- MORE --                                                                                                                                            
                                                                                                                                                      
                                                            5-Jul-1990  23:48:20                                                                      
                                                                                                                                                      
                                                                                                                                                      
------------------------------------------------------------------------------                                                                        
                                                                                                                                                      
  Name : DEFAULT_VLAN                                                                                                                                 
  802.1Q VLAN ID : 1                                                                                                                                  
                                                                                                                                                      
------------------------------------------------------------------------------                                                                        
                                                                                                                                                      
  Name : vlan2                                                                                                                                        
  802.1Q VLAN ID : 2                                                                                                                                  
                                                                                                                                                      
==============================================================================                                                                        
                              VLAN Port Assignment                                                                                                    
                                                                                                                                                      
      VLAN      Port | DEFAULT_VLA      vlan2                                                                                                         
  ------------  ---- + ------------  ------------                                                                                                     
  DEFAULT_VLAN  A1   | Untagged      No                                                                                                               
  DEFAULT_VLAN  A2   | Untagged      No                                                                                                               
  DEFAULT_VLAN  A3   | Untagged      No                                                                                                               
  DEFAULT_VLAN  A6   | Untagged      No                                                                                                               
  DEFAULT_VLAN  A7   | Untagged      No                                                                                                               
-- MORE --                                                                                                                                            
                                                                                                                                                      
                                                            5-Jul-1990  23:48:23                                                                      
                                                                                                                                                      
                                                                                                                                                      
  DEFAULT_VLAN  Trk1 | Untagged      No                                                                                                               
  DEFAULT_VLAN  Trk4 | Untagged      Tagged                                                                                                           
  DEFAULT_VLAN  Mesh | Tagged        Tagged                                                                                                           
                                                                                                                                                      
                                                                                                                                                      
==============================================================================                                                                        
                                  IGMP Service                                                                                                        
                                                                                                                                                      
      VLAN      IGMP Enabled  Forward with High Priority                                                                                              
  ------------  ------------  --------------------------                                                                                              
  DEFAULT_VLAN  No            No                                                                                                                      
  vlan2         Yes           Yes                                                                                                                     
                                                                                                                                                      
                                                                                                                                                      
------------------------------------------------------------------------------                                                                        
                          IGMP Service - DEFAULT_VLAN                                                                                                 
                                                                                                                                                      
  IGMP Enabled [No] : No                                                                                                                              
  Forward with High Priority [No] : No                                                                                                                
                                                                                                                                                      
-- MORE --                                                                                                                                            
                                                                                                                                                      
                                                            5-Jul-1990  23:48:26                                                                      
                                                                                                                                                      
                                                                                                                                                      
  Port    Type    | IP Mcast                                                                                                                          
  ----  --------- + --------                                                                                                                          
  A1    10/100TX  | Auto                                                                                                                              
  A2    10/100TX  | Auto                                                                                                                              
  A3    10/100TX  | Auto                                                                                                                              
  A6    10/100TX  | Auto                                                                                                                              
  A7    10/100TX  | Auto                                                                                                                              
  Trk1  Trunk     | Auto                                                                                                                              
  Trk4  Trunk     | Auto                                                                                                                              
  Mesh  Mesh      | Auto                                                                                                                              
                                                                                                                                                      
                                                                                                                                                      
------------------------------------------------------------------------------                                                                        
                              IGMP Service - vlan2                                                                                                    
                                                                                                                                                      
  IGMP Enabled [No] : Yes                                                                                                                             
  Forward with High Priority [No] : Yes                                                                                                               
                                                                                                                                                      
  Port    Type    | IP Mcast                                                                                                                          
  ----  --------- + --------                                                                                                                          
-- MORE --                                                                                                                                            
                                                                                                                                                      
                                                            5-Jul-1990  23:48:29                                                                      
                                                                                                                                                      
                                                                                                                                                      
  Trk4  Trunk     | Auto                                                                                                                              
  Mesh  Mesh      | Auto                                                                                                                              
                                                                                                                                                      
                                                                                                                                                      
==============================================================================                                                                        
                                SNMP Communities                                                                                                      
                                                                                                                                                      
   Community Name   MIB View  Write Access                                                                                                            
  ----------------  --------  ------------                                                                                                            
  public            Manager   Unrestricted                                                                                                            
  testenv           Manager   Unrestricted                                                                                                            
  brandon           Manager   Unrestricted                                                                                                            
                                                                                                                                                      
                                                                                                                                                      
------------------------------------------------------------------------------                                                                        
                                                                                                                                                      
  Community Name : public                                                                                                                             
  MIB View : Manager                    Write Access : Unrestricted                                                                                   
                                                                                                                                                      
     Manager Address                                                                                                                                  
-- MORE --                                                                                                                                            
                                                                                                                                                      
                                                            5-Jul-1990  23:48:32                                                                      
                                                                                                                                                      
                                                                                                                                                      
  ----------------------                                                                                                                              
                                                                                                                                                      
                                                                                                                                                      
------------------------------------------------------------------------------                                                                        
                                                                                                                                                      
  Community Name : testenv                                                                                                                            
  MIB View : Manager                    Write Access : Unrestricted                                                                                   
                                                                                                                                                      
     Manager Address                                                                                                                                  
  ----------------------                                                                                                                              
                                                                                                                                                      
                                                                                                                                                      
------------------------------------------------------------------------------                                                                        
                                                                                                                                                      
  Community Name : brandon                                                                                                                            
  MIB View : Manager                    Write Access : Unrestricted                                                                                   
                                                                                                                                                      
     Manager Address                                                                                                                                  
  ----------------------                                                                                                                              
  1.1.1.1                                                                                                                                             
-- MORE --                                                                                                                                            
                                                                                                                                                      
                                                            5-Jul-1990  23:48:35                                                                      
                                                                                                                                                      
                                                                                                                                                      
                                                                                                                                                      
                                                                                                                                                      
==============================================================================                                                                        
                                 Trap Receivers                                                                                                       
                                                                                                                                                      
  Send Authentication Traps [No] : Yes                                                                                                                
                                                                                                                                                      
         Address             Community      Events Sent in Trap                                                                                       
  ----------------------  ----------------  -------------------                                                                                       
  10.10.1.245             public            All                                                                                                       
  10.10.1.74              public            All                                                                                                       
  10.10.1.50              public            All                                                                                                       
                                                                                                                                                      
                                                                                                                                                      
==============================================================================                                                                        
                              Console/Serial Link                                                                                                     
                                                                                                                                                      
  Inbound Telnet Enabled [Yes] : Yes                                                                                                                  
  Web Agent Enabled [Yes] : Yes                                                                                                                       
  Terminal Type [VT100] : VT100                                                                                                                       
-- MORE --                                                                                                                                            
                                                                                                                                                      
                                                            5-Jul-1990  23:48:39                                                                      
                                                                                                                                                      
                                                                                                                                                      
  Screen Refresh Interval (sec) [3] : 3                                                                                                               
  Displayed Events [All] : All                                                                                                                        
                                                                                                                                                      
  Baud Rate [Speed Sense] : Speed Sense                                                                                                               
  Flow Control [XON/XOFF] : None                                                                                                                      
  Session Inactivity Time (min) [0] : 0                                                                                                               
                                                                                                                                                      
==============================================================================                                                                        
                                  IP Managers                                                                                                         
                                                                                                                                                      
  Authorized Manager IP          IP Mask               Access Level                                                                                   
  ----------------------  ----------------------  ----------------------                                                                              
  10.10.1.189             255.255.255.0           Manager                                                                                             
  10.0.0.0                255.0.0.0               Manager                                                                                             
  10.0.0.0                255.255.255.255         Manager                                                                                             
  192.168.0.0             255.255.0.0             Manager                                                                                             
                                                                                                                                                      
                                                                                                                                                      
------------------------------------------------------------------------------                                                                        
                                                                                                                                                      
-- MORE --                                                                                                                                            
                                                                                                                                                      
                                                            5-Jul-1990  23:48:42                                                                      
                                                                                                                                                      
                                                                                                                                                      
                                                                                                                                                      
 Authorized Manager IP : 10.10.1.189                                                                                                                  
 IP Mask [255.255.255.255] : 255.255.255.0                                                                                                            
 Access Level : Manager                                                                                                                               
                                                                                                                                                      
------------------------------------------------------------------------------                                                                        
                                                                                                                                                      
                                                                                                                                                      
 Authorized Manager IP : 10.0.0.0                                                                                                                     
 IP Mask [255.255.255.255] : 255.0.0.0                                                                                                                
 Access Level : Manager                                                                                                                               
                                                                                                                                                      
------------------------------------------------------------------------------                                                                        
                                                                                                                                                      
                                                                                                                                                      
 Authorized Manager IP : 10.0.0.0                                                                                                                     
 IP Mask [255.255.255.255] : 255.255.255.255                                                                                                          
 Access Level : Manager                                                                                                                               
                                                                                                                                                      
------------------------------------------------------------------------------                                                                        
-- MORE --                                                                                                                                            
                                                                                                                                                      
                                                            5-Jul-1990  23:48:45                                                                      
                                                                                                                                                      
                                                                                                                                                      
                                                                                                                                                      
                                                                                                                                                      
 Authorized Manager IP : 192.168.0.0                                                                                                                  
 IP Mask [255.255.255.255] : 255.255.0.0                                                                                                              
 Access Level : Manager                                                                                                                               
                                                                                                                                                      
==============================================================================                                                                        
                            Network Monitoring Port                                                                                                   
                                                                                                                                                      
  Monitoring Enabled [No] : No                                                                                                                        
                                                                                                                                                      
                                                                                                                                                      
                                                                                                                                                      
==============================================================================                                                                        
                            Spanning Tree Operation                                                                                                   
                                                                                                                                                      
  Spanning Tree Enabled [No] : No                                                                                                                     
  STP Priority [32768] : 32768          Hello Time [2] : 2                                                                                            
  Max Age [20] : 20                     Forward Delay [15] : 15                                                                                       
                                                                                                                                                      
-- MORE --                                                                                                                                            
                                                                                                                                                      
                                                            5-Jul-1990  23:48:48                                                                      
                                                                                                                                                      
                                                                                                                                                      
  Port    Type    | Cost   Pri  Mode                                                                                                                  
  ----  --------- + -----  ---  ----                                                                                                                  
  A1    10/100TX  | 10     64   Norm                                                                                                                  
  A2    10/100TX  | 10     64   Norm                                                                                                                  
  A3    10/100TX  | 10     64   Norm                                                                                                                  
  A6    10/100TX  | 10     64   Norm                                                                                                                  
  A7    10/100TX  | 10     64   Norm                                                                                                                  
  Trk1  Trunk     | 10     64   Norm                                                                                                                  
  Trk4  Trunk     | 10     64   Norm                                                                                                                  
  Mesh  Mesh      | 10     1    Norm                                                                                                                  
                                                                                                                                                      
                                                                                                                                                      
==============================================================================                                                                        
                          Automatic Broadcast Control                                                                                                 
                                                                                                                                                      
                                                                                                                                                      
                                                                                                                                                      
      VLAN     | ABC Enabled  IP RIP Control  Auto Gateway  IPX RIP/SAP Control                                                                       
  ------------ + -----------  --------------  ------------  -------------------                                                                       
  DEFAULT_VLAN | Disabled                                                                                                                             
-- MORE --                                                                                                                                            
                                                                                                                                                      
                                                            5-Jul-1990  23:48:51                                                                      
                                                                                                                                                      
                                                                                                                                                      
  vlan2        | Disabled                                                                                                                             
                                                                                                                                                      
                                                                                                                                                      
==============================================================================                                                                        
                                 Port Security                                                                                                        
                                                                                                                                                      
   Port    Learn Mode | Eavesdrop Prevention           Action                                                                                         
  -------  ---------- + --------------------  ------------------------                                                                                
  A1       Continuous | Enabled               Send Alarm                                                                                              
  A2       Continuous | Disabled              None                                                                                                    
  A3       Continuous | Disabled              None                                                                                                    
  A6       Continuous | Disabled              None                                                                                                    
  A7       Continuous | Disabled              None                                                                                                    
                                                                                                                                                      
                                                                                                                                                      
------------------------------------------------------------------------------                                                                        
                                                                                                                                                      
  Port : A1                                                                                                                                           
  Learn Mode [Continuous] : Continuous                                                                                                                
  Eavesdrop Prevention [Disabled] : Enabled                                                                                                           
-- MORE --                                                                                                                                            
                                                                                                                                                      
                                                            5-Jul-1990  23:48:54                                                                      
                                                                                                                                                      
                                                                                                                                                      
  Action [None] : Send Alarm                                                                                                                          
                                                                                                                                                      
------------------------------------------------------------------------------                                                                        
                                                                                                                                                      
  Port : A2                                                                                                                                           
  Learn Mode [Continuous] : Continuous                                                                                                                
  Eavesdrop Prevention [Disabled] : Disabled                                                                                                          
  Action [None] : None                                                                                                                                
                                                                                                                                                      
------------------------------------------------------------------------------                                                                        
                                                                                                                                                      
  Port : A3                                                                                                                                           
  Learn Mode [Continuous] : Continuous                                                                                                                
  Eavesdrop Prevention [Disabled] : Disabled                                                                                                          
  Action [None] : None                                                                                                                                
                                                                                                                                                      
------------------------------------------------------------------------------                                                                        
                                                                                                                                                      
  Port : A6                                                                                                                                           
  Learn Mode [Continuous] : Continuous                                                                                                                
-- MORE --                                                                                                                                            
                                                                                                                                                      
                                                            5-Jul-1990  23:48:58                                                                      
                                                                                                                                                      
                                                                                                                                                      
  Eavesdrop Prevention [Disabled] : Disabled                                                                                                          
  Action [None] : None                                                                                                                                
                                                                                                                                                      
------------------------------------------------------------------------------                                                                        
                                                                                                                                                      
  Port : A7                                                                                                                                           
  Learn Mode [Continuous] : Continuous                                                                                                                
  Eavesdrop Prevention [Disabled] : Disabled                                                                                                          
  Action [None] : None                                                                                                                                
                                                                                                                                                      
==============================================================================                                                                        
                              Cos - VLAN Priority                                                                                                     
                                                                                                                                                      
      VLAN     |  Priority                                                                                                                            
  ------------ + -----------                                                                                                                          
  DEFAULT_VLAN | 0                                                                                                                                    
  vlan2        | No override                                                                                                                          
                                                                                                                                                      
                                                                                                                                                      
==============================================================================                                                                        
-- MORE --                                                                                                                                            
                                                                                                                                                      
                                                            5-Jul-1990  23:49:01                                                                      
                                                                                                                                                      
                                                                                                                                                      
                            Cos - Protocol Priority                                                                                                   
                                                                                                                                                      
  Protocol  |  Priority                                                                                                                               
  --------- + -----------                                                                                                                             
  IP        | No override                                                                                                                             
  IPX       | No override                                                                                                                             
  ARP       | No override                                                                                                                             
  DEC LAT   | No override                                                                                                                             
  AppleTalk | No override                                                                                                                             
  SNA       | No override                                                                                                                             
  NetBEUI   | No override                                                                                                                             
                                                                                                                                                      
                                                                                                                                                      
==============================================================================                                                                        
                             Cos - Device Priority                                                                                                    
                                                                                                                                                      
        IP Address        Priority                                                                                                                    
  ----------------------  --------                                                                                                                    
  10.10.1.54              0                                                                                                                           
                                                                                                                                                      
-- MORE --                                                                                                                                            
                                                                                                                                                      
                                                            5-Jul-1990  23:49:04                                                                      
                                                                                                                                                      
                                                                                                                                                      
                             Cos - Device Priority                                                                                                    
                                                                                                                                                      
        IP Address        Priority                                                                                                                    
  ----------------------  --------                                                                                                                    
  10.10.1.54              0                                                                                                                           
                                                                                                                                                      
                                                                                                                                                      
------------------------------------------------------------------------------                                                                        
                                                                                                                                                      
  IP Address : 10.10.1.54                                                                                                                             
  Priority [0] : 0                                                                                                                                    
                                                                                                                                                      
==============================================================================                                                                        
                             Cos -  Type of Service                                                                                                   
                                                                                                                                                      
  Type of Service [Disabled] : Disabled                                                                                                               
                                                                                                                                                      
==============================================================================                                                                        
                                                                                                                                                      
                                                                                                                                                      
                           Press any key to continue                                                                                                  
                                                                                                                                                      

END

$responsesHPProcurveM->{config} = <<'END';
                                                           12-Jul-1990   2:05:21                                                                      
                                                                                                                                                      
                                                                                                                                                      
; J4121A Configuration Editor; Created on release #C.09.16                                                                                            
                                                                                                                                                      
SYSTEM (                                                                                                                                              
NAME=~HP4000M~                                                                                                                                        
CONTACT=~Change1~                                                                                                                                     
LOCATION=~Austin~                                                                                                                                     
CDP_ENABLE=1                                                                                                                                          
RFILEs=~hp-4000.conf~                                                                                                                                 
ADDR=10.10.1.52                                                                                                                                       
DST_RULE=1                                                                                                                                            
)                                                                                                                                                     
                                                                                                                                                      
CONSOLE (                                                                                                                                             
XON=1                                                                                                                                                 
)                                                                                                                                                     
                                                                                                                                                      
CCT (                                                                                                                                                 
NAME=A1                                                                                                                                               
PORT_ID=1                                                                                                                                             
TYPE=62                                                                                                                                               
-- MORE --                                                                                                                                            
                                                                                                                                                      
                                                           12-Jul-1990   2:05:23                                                                      
                                                                                                                                                      
                                                                                                                                                      
ETHER100MODE=1                                                                                                                                        
PRIORITY=64                                                                                                                                           
EAVESDROP=1                                                                                                                                           
ALARM=2                                                                                                                                               
)                                                                                                                                                     
                                                                                                                                                      
CCT (                                                                                                                                                 
NAME=A2                                                                                                                                               
PORT_ID=2                                                                                                                                             
TYPE=62                                                                                                                                               
PRIORITY=64                                                                                                                                           
)                                                                                                                                                     
                                                                                                                                                      
CCT (                                                                                                                                                 
NAME=A3                                                                                                                                               
PORT_ID=3                                                                                                                                             
TYPE=62                                                                                                                                               
PRIORITY=64                                                                                                                                           
)                                                                                                                                                     
                                                                                                                                                      
-- MORE --                                                                                                                                            
                                                                                                                                                      
                                                           12-Jul-1990   2:05:26                                                                      
                                                                                                                                                      
                                                                                                                                                      
CCT (                                                                                                                                                 
NAME=A4                                                                                                                                               
PORT_ID=4                                                                                                                                             
TYPE=62                                                                                                                                               
TRUNK=4                                                                                                                                               
TRUNKTYPE=1                                                                                                                                           
PRIORITY=64                                                                                                                                           
)                                                                                                                                                     
                                                                                                                                                      
CCT (                                                                                                                                                 
NAME=A5                                                                                                                                               
PORT_ID=5                                                                                                                                             
TYPE=62                                                                                                                                               
TRUNK=11                                                                                                                                              
PRIORITY=1                                                                                                                                            
)                                                                                                                                                     
                                                                                                                                                      
CCT (                                                                                                                                                 
NAME=A6                                                                                                                                               
PORT_ID=6                                                                                                                                             
-- MORE --                                                                                                                                            
                                                                                                                                                      
                                                           12-Jul-1990   2:05:29                                                                      
                                                                                                                                                      
                                                                                                                                                      
TYPE=62                                                                                                                                               
PRIORITY=64                                                                                                                                           
)                                                                                                                                                     
                                                                                                                                                      
CCT (                                                                                                                                                 
NAME=A7                                                                                                                                               
PORT_ID=7                                                                                                                                             
TYPE=62                                                                                                                                               
PRIORITY=64                                                                                                                                           
)                                                                                                                                                     
                                                                                                                                                      
CCT (                                                                                                                                                 
NAME=A8                                                                                                                                               
PORT_ID=8                                                                                                                                             
TYPE=62                                                                                                                                               
TRUNK=1                                                                                                                                               
TRUNKTYPE=1                                                                                                                                           
PRIORITY=64                                                                                                                                           
)                                                                                                                                                     
                                                                                                                                                      
-- MORE --                                                                                                                                            
                                                                                                                                                      
                                                           12-Jul-1990   2:05:32                                                                      
                                                                                                                                                      
                                                                                                                                                      
CCT (                                                                                                                                                 
NAME=B1                                                                                                                                               
PORT_ID=9                                                                                                                                             
TYPE=62                                                                                                                                               
PRIORITY=64                                                                                                                                           
)                                                                                                                                                     
                                                                                                                                                      
CCT (                                                                                                                                                 
NAME=B2                                                                                                                                               
PORT_ID=10                                                                                                                                            
TYPE=62                                                                                                                                               
PRIORITY=64                                                                                                                                           
)                                                                                                                                                     
                                                                                                                                                      
CCT (                                                                                                                                                 
NAME=B3                                                                                                                                               
PORT_ID=11                                                                                                                                            
TYPE=62                                                                                                                                               
TRUNK=2                                                                                                                                               
TRUNKTYPE=1                                                                                                                                           
-- MORE --                                                                                                                                            
                                                                                                                                                      
                                                           12-Jul-1990   2:05:36                                                                      
                                                                                                                                                      
                                                                                                                                                      
PRIORITY=64                                                                                                                                           
)                                                                                                                                                     
                                                                                                                                                      
CCT (                                                                                                                                                 
NAME=B4                                                                                                                                               
PORT_ID=12                                                                                                                                            
TYPE=62                                                                                                                                               
TRUNK=8                                                                                                                                               
TRUNKTYPE=1                                                                                                                                           
PRIORITY=64                                                                                                                                           
)                                                                                                                                                     
                                                                                                                                                      
CCT (                                                                                                                                                 
NAME=B5                                                                                                                                               
PORT_ID=13                                                                                                                                            
TYPE=62                                                                                                                                               
TRUNK=2                                                                                                                                               
TRUNKTYPE=1                                                                                                                                           
PRIORITY=64                                                                                                                                           
)                                                                                                                                                     
-- MORE --                                                                                                                                            
                                                                                                                                                      
                                                           12-Jul-1990   2:05:39                                                                      
                                                                                                                                                      
                                                                                                                                                      
                                                                                                                                                      
CCT (                                                                                                                                                 
NAME=B6                                                                                                                                               
PORT_ID=14                                                                                                                                            
TYPE=62                                                                                                                                               
TRUNK=3                                                                                                                                               
TRUNKTYPE=1                                                                                                                                           
PRIORITY=64                                                                                                                                           
)                                                                                                                                                     
                                                                                                                                                      
CCT (                                                                                                                                                 
NAME=B7                                                                                                                                               
PORT_ID=15                                                                                                                                            
TYPE=62                                                                                                                                               
TRUNK=3                                                                                                                                               
TRUNKTYPE=1                                                                                                                                           
PRIORITY=64                                                                                                                                           
)                                                                                                                                                     
                                                                                                                                                      
CCT (                                                                                                                                                 
-- MORE --                                                                                                                                            
                                                                                                                                                      
                                                           12-Jul-1990   2:05:42                                                                      
                                                                                                                                                      
                                                                                                                                                      
NAME=B8                                                                                                                                               
PORT_ID=16                                                                                                                                            
TYPE=62                                                                                                                                               
TRUNK=4                                                                                                                                               
TRUNKTYPE=1                                                                                                                                           
PRIORITY=64                                                                                                                                           
)                                                                                                                                                     
                                                                                                                                                      
CCT (                                                                                                                                                 
NAME=Trk1                                                                                                                                             
PORT_ID=81                                                                                                                                            
TYPE=54                                                                                                                                               
COST=10                                                                                                                                               
PRIORITY=64                                                                                                                                           
)                                                                                                                                                     
                                                                                                                                                      
CCT (                                                                                                                                                 
NAME=Trk2                                                                                                                                             
PORT_ID=82                                                                                                                                            
TYPE=54                                                                                                                                               
-- MORE --                                                                                                                                            
                                                                                                                                                      
                                                           12-Jul-1990   2:05:45                                                                      
                                                                                                                                                      
                                                                                                                                                      
COST=10                                                                                                                                               
PRIORITY=64                                                                                                                                           
)                                                                                                                                                     
                                                                                                                                                      
CCT (                                                                                                                                                 
NAME=Trk3                                                                                                                                             
PORT_ID=83                                                                                                                                            
TYPE=54                                                                                                                                               
COST=10                                                                                                                                               
PRIORITY=64                                                                                                                                           
)                                                                                                                                                     
                                                                                                                                                      
CCT (                                                                                                                                                 
NAME=Trk4                                                                                                                                             
PORT_ID=84                                                                                                                                            
TYPE=54                                                                                                                                               
COST=10                                                                                                                                               
PRIORITY=64                                                                                                                                           
)                                                                                                                                                     
                                                                                                                                                      
-- MORE --                                                                                                                                            
                                                                                                                                                      
                                                           12-Jul-1990   2:05:48                                                                      
                                                                                                                                                      
                                                                                                                                                      
CCT (                                                                                                                                                 
NAME=Mesh                                                                                                                                             
PORT_ID=91                                                                                                                                            
TYPE=1                                                                                                                                                
COST=10                                                                                                                                               
PRIORITY=1                                                                                                                                            
)                                                                                                                                                     
                                                                                                                                                      
CCT (                                                                                                                                                 
NAME=Trk8                                                                                                                                             
PORT_ID=88                                                                                                                                            
TYPE=54                                                                                                                                               
COST=10                                                                                                                                               
PRIORITY=64                                                                                                                                           
)                                                                                                                                                     
                                                                                                                                                      
STP (                                                                                                                                                 
)                                                                                                                                                     
                                                                                                                                                      
IPX (                                                                                                                                                 
-- MORE --                                                                                                                                            
                                                                                                                                                      
                                                           12-Jul-1990   2:05:49                                                                      
                                                                                                                                                      
                                                                                                                                                      
                                                                                                                                                      
IPX_NW (                                                                                                                                              
NODE_ADDR=0010830e4b00                                                                                                                                
INIT=1                                                                                                                                                
GW_ENCAP=5                                                                                                                                            
)                                                                                                                                                     
                                                                                                                                                      
IPX_NW (                                                                                                                                              
VLAN_ID=2                                                                                                                                             
NODE_ADDR=0010830e4b01                                                                                                                                
INIT=1                                                                                                                                                
GW_ENCAP=5                                                                                                                                            
)                                                                                                                                                     
)                                                                                                                                                     
                                                                                                                                                      
IP (                                                                                                                                                  
TIME_SYNC=2                                                                                                                                           
TIMEP=3                                                                                                                                               
SNTP_STATE=2                                                                                                                                          
IP_ADDR=10.10.1.36                                                                                                                                    
-- MORE --                                                                                                                                            
                                                                                                                                                      
                                                           12-Jul-1990   2:05:51                                                                      
                                                                                                                                                      
                                                                                                                                                      
SNTP_POLL=7200                                                                                                                                        
                                                                                                                                                      
SNTP (                                                                                                                                                
ROW_STATUS=1                                                                                                                                          
IP_ADDR=10.10.1.36                                                                                                                                    
)                                                                                                                                                     
                                                                                                                                                      
IP_NW (                                                                                                                                               
INIT=1                                                                                                                                                
ADDR=10.100.2.7                                                                                                                                       
SNET_MSK=255.255.255.0                                                                                                                                
GATEWAY=10.100.2.1                                                                                                                                    
)                                                                                                                                                     
                                                                                                                                                      
IP_NW (                                                                                                                                               
VLAN_ID=2                                                                                                                                             
INIT=3                                                                                                                                                
ADDR=0.0.0.0                                                                                                                                          
SNET_MSK=0.0.0.0                                                                                                                                      
)                                                                                                                                                     
-- MORE --                                                                                                                                            
                                                                                                                                                      
                                                           12-Jul-1990   2:05:55                                                                      
                                                                                                                                                      
                                                                                                                                                      
)                                                                                                                                                     
                                                                                                                                                      
SNMPS (                                                                                                                                               
ROW_STATUS=1                                                                                                                                          
NAME=public                                                                                                                                           
VIEW=5                                                                                                                                                
MODE=5                                                                                                                                                
)                                                                                                                                                     
                                                                                                                                                      
SNMPS (                                                                                                                                               
ROW_STATUS=1                                                                                                                                          
COM_ID=2                                                                                                                                              
NAME=testenv                                                                                                                                          
VIEW=5                                                                                                                                                
MODE=5                                                                                                                                                
)                                                                                                                                                     
                                                                                                                                                      
SNMPS (                                                                                                                                               
ROW_STATUS=1                                                                                                                                          
COM_ID=3                                                                                                                                              
-- MORE --                                                                                                                                            
                                                                                                                                                      
                                                           12-Jul-1990   2:05:56                                                                      
                                                                                                                                                      
                                                                                                                                                      
NAME=brandon                                                                                                                                          
VIEW=5                                                                                                                                                
MODE=5                                                                                                                                                
                                                                                                                                                      
MGR_ADDR (                                                                                                                                            
IP_ADDR=1.1.1.1                                                                                                                                       
)                                                                                                                                                     
)                                                                                                                                                     
                                                                                                                                                      
TRAPS (                                                                                                                                               
SUPPRESS_AUTH_TRAPS=1                                                                                                                                 
                                                                                                                                                      
TRAPADDR (                                                                                                                                            
IP_ADDR=10.10.1.245                                                                                                                                   
COMMUNITY=public                                                                                                                                      
FILTER=4                                                                                                                                              
)                                                                                                                                                     
                                                                                                                                                      
TRAPADDR (                                                                                                                                            
TRAPADDR_ID=2                                                                                                                                         
-- MORE --                                                                                                                                            
                                                                                                                                                      
                                                           12-Jul-1990   2:05:58                                                                      
                                                                                                                                                      
                                                                                                                                                      
IP_ADDR=10.10.1.74                                                                                                                                    
COMMUNITY=public                                                                                                                                      
FILTER=4                                                                                                                                              
)                                                                                                                                                     
                                                                                                                                                      
TRAPADDR (                                                                                                                                            
TRAPADDR_ID=3                                                                                                                                         
IP_ADDR=10.10.1.50                                                                                                                                    
COMMUNITY=public                                                                                                                                      
FILTER=4                                                                                                                                              
)                                                                                                                                                     
)                                                                                                                                                     
                                                                                                                                                      
LB_TF (                                                                                                                                               
TF_TYPE=1                                                                                                                                             
SRC_MAC=ffffffffff00                                                                                                                                  
TF_PORT_MASK=000000000000000000000000                                                                                                                 
)                                                                                                                                                     
                                                                                                                                                      
LB_TF (                                                                                                                                               
-- MORE --                                                                                                                                            
                                                                                                                                                      
                                                           12-Jul-1990   2:06:01                                                                      
                                                                                                                                                      
                                                                                                                                                      
TF_ID=2                                                                                                                                               
TF_TYPE=2                                                                                                                                             
VALUE=33079                                                                                                                                           
TF_PORT_MASK=f98e00000000000000000000                                                                                                                 
)                                                                                                                                                     
                                                                                                                                                      
LB_TF (                                                                                                                                               
TF_ID=3                                                                                                                                               
TF_TYPE=3                                                                                                                                             
PORT_ID=2                                                                                                                                             
TF_PORT_MASK=000000000000000000000000                                                                                                                 
)                                                                                                                                                     
                                                                                                                                                      
LB_TF (                                                                                                                                               
TF_ID=4                                                                                                                                               
TF_TYPE=3                                                                                                                                             
PORT_ID=13                                                                                                                                            
TF_PORT_MASK=80f700000000000000000000                                                                                                                 
)                                                                                                                                                     
                                                                                                                                                      
-- MORE --                                                                                                                                            
                                                                                                                                                      
                                                           12-Jul-1990   2:06:04                                                                      
                                                                                                                                                      
                                                                                                                                                      
VLAN (                                                                                                                                                
NAME=DEFAULT_VLAN                                                                                                                                     
PORT_MAP=ffff0000000000000000f120                                                                                                                     
MODE=2222222222222222----------------------------------------------------------------2222---1--1                                                      
COS_PRIORITY=0                                                                                                                                        
)                                                                                                                                                     
                                                                                                                                                      
VLAN (                                                                                                                                                
VLAN_ID=2                                                                                                                                             
NAME=vlan2                                                                                                                                            
VLAN_QID=2                                                                                                                                            
PORT_MAP=ffff0000000000000000f120                                                                                                                     
MODE=--------1--------------------------------------------------------------------------1------1                                                      
)                                                                                                                                                     
                                                                                                                                                      
PROBE (                                                                                                                                               
INIT=2                                                                                                                                                
PROBE_TYPE=1                                                                                                                                          
MONITORED_PORT_MASK=000000000000000000000000                                                                                                          
)                                                                                                                                                     
-- MORE --                                                                                                                                            
                                                                                                                                                      
                                                           12-Jul-1990   2:06:07                                                                      
                                                                                                                                                      
                                                                                                                                                      
                                                                                                                                                      
IGMP (                                                                                                                                                
)                                                                                                                                                     
                                                                                                                                                      
IGMP (                                                                                                                                                
VLAN_ID=2                                                                                                                                             
IGMP_STATE=1                                                                                                                                          
IGMP_PRIORITY=1                                                                                                                                       
)                                                                                                                                                     
                                                                                                                                                      
ABC (                                                                                                                                                 
                                                                                                                                                      
ABC_NW (                                                                                                                                              
ABC_CONF=4                                                                                                                                            
)                                                                                                                                                     
                                                                                                                                                      
ABC_NW (                                                                                                                                              
VLAN_ID=2                                                                                                                                             
ABC_CONF=4                                                                                                                                            
)                                                                                                                                                     
-- MORE --                                                                                                                                            
                                                                                                                                                      
                                                           12-Jul-1990   2:06:10                                                                      
                                                                                                                                                      
                                                                                                                                                      
)                                                                                                                                                     
                                                                                                                                                      
FAULT_FINDER (                                                                                                                                        
FAULT_ID=1                                                                                                                                            
)                                                                                                                                                     
                                                                                                                                                      
FAULT_FINDER (                                                                                                                                        
FAULT_ID=2                                                                                                                                            
)                                                                                                                                                     
                                                                                                                                                      
FAULT_FINDER (                                                                                                                                        
FAULT_ID=3                                                                                                                                            
)                                                                                                                                                     
                                                                                                                                                      
FAULT_FINDER (                                                                                                                                        
FAULT_ID=4                                                                                                                                            
)                                                                                                                                                     
                                                                                                                                                      
FAULT_FINDER (                                                                                                                                        
FAULT_ID=5                                                                                                                                            
-- MORE --                                                                                                                                            
                                                                                                                                                      
                                                           12-Jul-1990   2:06:13                                                                      
                                                                                                                                                      
                                                                                                                                                      
)                                                                                                                                                     
                                                                                                                                                      
FAULT_FINDER (                                                                                                                                        
FAULT_ID=6                                                                                                                                            
)                                                                                                                                                     
                                                                                                                                                      
FAULT_FINDER (                                                                                                                                        
FAULT_ID=11                                                                                                                                           
)                                                                                                                                                     
                                                                                                                                                      
IPMGR (                                                                                                                                               
IP_ADDR=10.10.1.189                                                                                                                                   
IPMGR_MASK=255.255.255.0                                                                                                                              
)                                                                                                                                                     
                                                                                                                                                      
IPMGR (                                                                                                                                               
IPMGRID=2                                                                                                                                             
IP_ADDR=10.0.0.0                                                                                                                                      
IPMGR_MASK=255.0.0.0                                                                                                                                  
)                                                                                                                                                     
-- MORE --                                                                                                                                            
                                                                                                                                                      
                                                           12-Jul-1990   2:06:17                                                                      
                                                                                                                                                      
                                                                                                                                                      
                                                                                                                                                      
IPMGR (                                                                                                                                               
IPMGRID=3                                                                                                                                             
IP_ADDR=10.0.0.0                                                                                                                                      
)                                                                                                                                                     
                                                                                                                                                      
IPMGR (                                                                                                                                               
IPMGRID=4                                                                                                                                             
IP_ADDR=192.168.0.0                                                                                                                                   
IPMGR_MASK=255.255.0.0                                                                                                                                
)                                                                                                                                                     
                                                                                                                                                      
GVRP (                                                                                                                                                
GVRP_VLAN=2                                                                                                                                           
)                                                                                                                                                     
                                                                                                                                                      
COS_PROTO (                                                                                                                                           
TYPE=1                                                                                                                                                
)                                                                                                                                                     
                                                                                                                                                      
-- MORE --                                                                                                                                            
                                                                                                                                                      
                                                           12-Jul-1990   2:06:20                                                                      
                                                                                                                                                      
                                                                                                                                                      
COS_PROTO (                                                                                                                                           
TYPE=2                                                                                                                                                
)                                                                                                                                                     
                                                                                                                                                      
COS_PROTO (                                                                                                                                           
TYPE=3                                                                                                                                                
)                                                                                                                                                     
                                                                                                                                                      
COS_PROTO (                                                                                                                                           
TYPE=4                                                                                                                                                
)                                                                                                                                                     
                                                                                                                                                      
COS_PROTO (                                                                                                                                           
TYPE=5                                                                                                                                                
)                                                                                                                                                     
                                                                                                                                                      
COS_PROTO (                                                                                                                                           
TYPE=6                                                                                                                                                
)                                                                                                                                                     
                                                                                                                                                      
-- MORE --                                                                                                                                            
                                                                                                                                                      
                                                           12-Jul-1990   2:06:23                                                                      
                                                                                                                                                      
                                                                                                                                                      
COS_PROTO (                                                                                                                                           
TYPE=7                                                                                                                                                
)                                                                                                                                                     
                                                                                                                                                      
COS_ADDR (                                                                                                                                            
IP_ADDR=10.10.1.54                                                                                                                                    
)                                                                                                                                                     
                                                                                                                                                      
COS_TOS (                                                                                                                                             
TOS_MODE=1                                                                                                                                            
)                                                                                                                                                     
                                                                                                                                                      
COS_TOSDS (                                                                                                                                           
REC_MASK=ffffffffffffffff00000000                                                                                                                     
)                                                                                                                                                     
                                                                                                                                                      
HPDP (                                                                                                                                                
)                                                                                                                                                     
                                                                                                                                                      
STACK (                                                                                                                                               
-- MORE --                                                                                                                                            
                                                                                                                                                      
                                                           12-Jul-1990   2:06:26                                                                      
                                                                                                                                                      
                                                                                                                                                      
ADMIN_STATUS=0                                                                                                                                        
)                                                                                                                                                     
                                                                                                                                                      
AUTHENTICATION (                                                                                                                                      
                                                                                                                                                      
AUTHEN_TASK (                                                                                                                                         
AUTHEN_TASK_ID=1                                                                                                                                      
)                                                                                                                                                     
                                                                                                                                                      
AUTHEN_TASK (                                                                                                                                         
AUTHEN_TASK_ID=2                                                                                                                                      
AUTHEN_LOGIN_PRI=2                                                                                                                                    
AUTHEN_LOGIN_SEC=1                                                                                                                                    
AUTHEN_ENABLE_PRI=2                                                                                                                                   
)                                                                                                                                                     
)                                                                                                                                                     
                                                                                                                                                      
TACACS (                                                                                                                                              
TACACS_ENCRYPT_KEY=~cisco~                                                                                                                            
                                                                                                                                                      
-- MORE --                                                                                                                                            
                                                                                                                                                      
                                                           12-Jul-1990   2:06:29                                                                      
                                                                                                                                                      
                                                                                                                                                      
AUTHEN_TASK (                                                                                                                                         
AUTHEN_TASK_ID=2                                                                                                                                      
AUTHEN_LOGIN_PRI=2                                                                                                                                    
AUTHEN_LOGIN_SEC=1                                                                                                                                    
AUTHEN_ENABLE_PRI=2                                                                                                                                   
)                                                                                                                                                     
)                                                                                                                                                     
                                                                                                                                                      
TACACS (                                                                                                                                              
TACACS_ENCRYPT_KEY=~cisco~                                                                                                                            
                                                                                                                                                      
TACACS_SERVER (                                                                                                                                       
INDEX=2                                                                                                                                               
TACACS_SERVER_ADDR=10.100.32.137                                                                                                                      
TACACS_SERVER_KEY=~cisco~                                                                                                                             
ROW_STATUS=1                                                                                                                                          
)                                                                                                                                                     
)                                                                                                                                                     
                                                                                                                                                      
                                                                                                                                                      
DEFAULT_VLAN:                                                                                                                                         
                                                                                                                                                      

END

