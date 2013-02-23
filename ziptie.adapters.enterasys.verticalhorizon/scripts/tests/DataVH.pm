package DataVH;

use strict;
use warnings;
use Exporter 'import';
our @EXPORT_OK = qw($responsesVH);

our $responsesVH = {};

$responsesVH->{'system'} = <<'END';
                   Vertical Horizon Stack Local Management                                                                                            
                                                                                                                                                      
                                                                                                                                                      
                            System Information                                                                                                        
                                                                                                                                                      
                                                                                                                                                      
                                                                                                                                                      
         System Description : Vertical Horizon Stack                                                                                                  
                                                                                                                                                      
         System Object ID   : 1.3.6.1.4.1.5624.2.1.11                                                                                                 
                                                                                                                                                      
         System Up Time     : 129238848 (14 day 22 hr 59 min 48 sec)                                                                                  
                                                                                                                                                      
         System Name        : Enterasys Vertical Horizon                                                                                              
                                                                                                                                                      
         System Contact     : java.lang.Thread.sleep(50);                                                                                             
                                                                                                                                                      
         System Location    : Alterpoint.progress('Within Loop' + i);                                                                                 
                                                                                                                                                      
                                                                                                                                                      
                                                                                                                                                      
               <APPLY>               <OK>               <CANCEL>                                                                                      
                      The name of this system.                     | READ/WRITE                                                                       
          Use <TAB> or arrow keys to move, other keys to make changes.                                                                                
                                                                                                                                                      


END

$responsesVH->{'switch'} = <<'END';
Switch Information : Unit: 1                                                                                             
                                                                                                                                                      
                             Main Board                                                                                                               
                      Hardware Version         : V3.0                                                                                                 
                      Firmware Version         : V1.11                                                                                                
                      MAC Address              : 00-01-F4-DE-F3-E0                                                                                    
                      Port Number              : 24                                                                                                   
                      Internal Power Status    : Active                                                                                               
                      Redundant Power Status   : Inactive                                                                                             
                      Expansion Slot 1         : ---------------------                                                                                
                      Expansion Slot 2         : Stacking                                                                                             
                      MainBoard Type           : VH-2402S                                                                                             
                                                                                                                                                      
                             Agent Module                                                                                                             
                      Hardware Version         : V2.0 (801 CPU)                                                                                       
                      POST ROM Version         : V1.11                                                                                                
                      Firmware Version         : 02.05.09                                                                                             
                      SNMP Agent               : Master                                                                                               
                                                                                                                                                      
               <OK>
Switch Information : Unit: 2                                                                                             
                                                                                                                                                      
                             Main Board                                                                                                               
                      Hardware Version         : V3.0                                                                                                 
                      Firmware Version         : V1.11                                                                                                
                      MAC Address              : 00-E0-63-F1-9F-80                                                                                    
                      Port Number              : 24                                                                                                   
                      Internal Power Status    : Active                                                                                               
                      Redundant Power Status   : Inactive                                                                                             
                      Expansion Slot 1         : ---------------------                                                                                
                      Expansion Slot 2         : Stacking                                                                                             
                      MainBoard Type           : VH-2402S                                                                                             
                                                                                                                                                      
                             Agent Module                                                                                                             
                      Hardware Version         : N/A                                                                                                  
                      POST ROM Version         : N/A                                                                                                  
                      Firmware Version         : N/A                                                                                                  
                      SNMP Agent               : Slave                                                                                                
                                                                                                                                                      
               <OK>

END

$responsesVH->{'snmp_communities'} = <<'END';
                   Vertical Horizon Stack Local Management                                                                                            
                                                                                                                                                      
                                                                                                                                                      
                                                                                                                                                      
                                                                                                                                                      
                   SNMP Configuration : SNMP Communities                                                                                              
                                                                                                                                                      
                                                                                                                                                      
                                                                                                                                                      
                       Community Name      Access        Status                                                                                       
                                                                                                                                                      
                1.  public                READ ONLY     ENABLED                                                                                       
                2.  testenv               READ/WRITE    ENABLED                                                                                       
                3.                                                                                                                                    
                4.                                                                                                                                    
                5.                                                                                                                                    
                                                                                                                                                      
                                                                                                                                                      
                                                                                                                                                      
                                                                                                                                                      
                                                                                                                                                      
               <APPLY>               <OK>               <CANCEL>                                                                                      
                   The community name of entry 1.                  | READ/WRITE                                                                       
          Use <TAB> or arrow keys to move, other keys to make changes.                                                                                
                                                                                                                                                      


END

$responsesVH->{'snmp_traps'} = <<'END';
                   Vertical Horizon Stack Local Management                                                                                            
                                                                                                                                                      
                                                                                                                                                      
                                                                                                                                                      
                                                                                                                                                      
                   SNMP Configuration : IP Trap Managers                                                                                              
                                                                                                                                                      
                                                                                                                                                      
                                                                                                                                                      
                 IP Address           Community Name          Status                                                                                  
                                                                                                                                                      
             1.                                                                                                                                       
             2.                                                                                                                                       
             3.                                                                                                                                       
             4.                                                                                                                                       
             5.                                                                                                                                       
                                                                                                                                                      
                                                                                                                                                      
                                                                                                                                                      
                                                                                                                                                      
                                                                                                                                                      
               <APPLY>               <OK>                 <CANCEL>                                                                                    
                     The IP address of entry 1.                    | READ/WRITE                                                                       
          Use <TAB> or arrow keys to move, other keys to make changes.                                                                                
                                                                                                                                                      


END

$responsesVH->{'interfaces'} = <<'END';
1    10/100TX     ENABLED       ENABLED            AUTO                                                                                  
             2    10/100TX     ENABLED       ENABLED            10_HALF                                                                               
             3    10/100TX     ENABLED       ENABLED            AUTO                                                                                  
             4    10/100TX     DISABLED      ENABLED            10_FULL                                                                               
             5    10/100TX     ENABLED       ENABLED            AUTO                                                                                  
             6    10/100TX     ENABLED       ENABLED            100_HALF                                                                              
             7    10/100TX     ENABLED       ENABLED            AUTO                                                                                  
             8    10/100TX     ENABLED       ENABLED            100_FULL                                                                              
             9    10/100TX     ENABLED       ENABLED            AUTO                                                                                  
            10    10/100TX     ENABLED       ENABLED            AUTO                                                                                  
            11    10/100TX     ENABLED       ENABLED            AUTO                                                                                  
            12    10/100TX     ENABLED       ENABLED            AUTO
13    10/100TX     ENABLED       ENABLED            AUTO                                                                                  
            14    10/100TX     ENABLED       ENABLED            AUTO                                                                                  
            15    10/100TX     ENABLED       ENABLED            10_HALF                                                                               
            16    10/100TX     ENABLED       ENABLED            AUTO                                                                                  
            17    10/100TX     ENABLED       ENABLED            10_FULL                                                                               
            18    10/100TX     ENABLED       ENABLED            AUTO                                                                                  
            19    10/100TX     ENABLED       ENABLED            AUTO                                                                                  
            20    10/100TX     ENABLED       ENABLED            100_HALF                                                                              
            21    10/100TX     ENABLED       ENABLED            AUTO                                                                                  
            22    10/100TX     ENABLED       ENABLED            AUTO                                                                                  
            23    10/100TX     ENABLED       ENABLED            10_FULL                                                                               
            24    10/100TX     ENABLED       ENABLED            AUTO

END

$responsesVH->{'bridge_conf'} = <<'END';
                   Vertical Horizon Stack Local Management                                                                                            
                                                                                                                                                      
                                                                                                                                                      
                                                                                                                                                      
                                                                                                                                                      
              Spanning Tree Configuration : STA Bridge Configuration                                                                                  
                                                                                                                                                      
                                                                                                                                                      
                                                                                                                                                      
                        Spanning Tree Protocol     : ENABLED                                                                                          
                                                                                                                                                      
                        Priority                   : 32768                                                                                            
                                                                                                                                                      
                        Hello Time (in seconds)    : 2                                                                                                
                                                                                                                                                      
                        Max Age (in seconds)       : 20                                                                                               
                                                                                                                                                      
                        Forward Delay (in seconds) : 15                                                                                               
                                                                                                                                                      
                                                                                                                                                      
                                                                                                                                                      
               <APPLY>               <OK>               <CANCEL>                                                                                      
        The state of spanning tree protocol on the system.        | READ/SELECT                                                                       
          Use <TAB> or arrow keys to move, <Space> to scroll options.                                                                                 
                                                                                                                                                      


END

$responsesVH->{'ports_stp'} = <<'END';
1      10/100TX      128        19      DISABLED                                                                                     
                 2      10/100TX      128       100      DISABLED                                                                                     
                 3      10/100TX      128        19      DISABLED                                                                                     
                 4      10/100TX      128        19      DISABLED                                                                                     
                 5      10/100TX      128        19      DISABLED                                                                                     
                 6      10/100TX      128        19      DISABLED                                                                                     
                 7      10/100TX      128        19      DISABLED                                                                                     
                 8      10/100TX      128        19      DISABLED                                                                                     
                 9      10/100TX      128        19      DISABLED                                                                                     
                10      10/100TX      128        19      DISABLED                                                                                     
                11      10/100TX      128        19      DISABLED                                                                                     
                12      10/100TX      128        19      DISABLED
13      10/100TX      128        19      DISABLED                                                                                     
                14      10/100TX      128        19      DISABLED                                                                                     
                15      10/100TX      128        19      DISABLED                                                                                     
                16      10/100TX      128        19      DISABLED                                                                                     
                17      10/100TX      128        19      DISABLED                                                                                     
                18      10/100TX      128        19      DISABLED                                                                                     
                19      10/100TX      128        19      DISABLED                                                                                     
                20      10/100TX      128        19      DISABLED                                                                                     
                21      10/100TX      128        19      DISABLED                                                                                     
                22      10/100TX      128        19      DISABLED                                                                                     
                23      10/100TX      128        19      DISABLED                                                                                     
                24      10/100TX      128        19      DISABLED

END

$responsesVH->{'bridge_info'} = <<'END';
                   Vertical Horizon Stack Local Management                                                                                            
                                                                                                                                                      
                                                                                                                                                      
                                                                                                                                                      
                                                                                                                                                      
                   Spanning Tree Information : STA Bridge Information                                                                                 
                                                                                                                                                      
                                                                                                                                                      
         Priority                   : 32768                                                                                                           
         Hello Time (in seconds)    : 2                                                                                                               
         Max Age (in seconds)       : 20                                                                                                              
         Forward Delay (in seconds) : 15                                                                                                              
         Hold Time (in seconds)     : 1                                                                                                               
         Designated Root            : 24779.00179445EE80                                                                                              
         Root Cost                  : 42                                                                                                              
         Root Port                  : 33                                                                                                              
         Configuration Changes      : 5                                                                                                               
         Topology Up Time           : 119699809 (13 day 20 hr 29 min 58 sec)                                                                          
                                                                                                                                                      
                                                                                                                                                      
                                                                                                                                                      
                                     <OK>                                                                                                             
                           Return to previous panel.                                                                                                  
                               <Enter> to select.                                                                                                     
                                                                                                                                                      


END

