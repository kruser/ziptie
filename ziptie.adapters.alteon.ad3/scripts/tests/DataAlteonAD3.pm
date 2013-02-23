package DataAlteonAD3;

use strict;
use warnings;
use Exporter 'import';
our @EXPORT_OK = qw($responsesAlteonAD3);

our $responsesAlteonAD3 = {};

$responsesAlteonAD3->{info_dump} = <<'END';
y
System Information at 20:11:51 Thu Nov 29, 2007

Alteon AD3
sysName:     Alteon AD3
sysLocation: Alterpoint

Switch is up 227 days, 5 hours, 8 minutes and 3 seconds.
Last boot: 14:51:53 Mon Apr 16, 2007 (power cycle)

MAC address: 00:60:cf:48:1e:c0    IP (If 1) address: 10.100.21.222
Hardware Revision: A
Hardware Part No: E08_5B-B_7B-A
Software Version 10.0.33-SSH (FLASH image1), active configuration.

Temperature:    Rear Left Sensor    = 30C    Rear Middle Sensor  = 34C
		Front Middle Sensor = 38C    Front Right Sensor  = 38C


Sample Testing

Last 30 syslog message information:
Nov 29 14:21:45 NOTICE  telnet/ssh-2: admin logout from Telnet/SSH
Nov 29 14:27:10 NOTICE  telnet/ssh-2: admin login from host 192.168.11.129
Nov 29 14:27:12 NOTICE  telnet/ssh-2: admin logout from Telnet/SSH
Nov 29 14:29:51 NOTICE  telnet/ssh-2: admin login from host 192.168.11.129
Nov 29 14:29:53 NOTICE  telnet/ssh-2: admin logout from Telnet/SSH
Nov 29 14:31:10 NOTICE  telnet/ssh-2: admin login from host 192.168.11.129
Nov 29 14:31:13 NOTICE  telnet/ssh-2: admin logout from Telnet/SSH
Nov 29 14:38:54 NOTICE  telnet/ssh-2: admin login from host 192.168.11.129
Nov 29 14:38:56 NOTICE  telnet/ssh-2: admin logout from Telnet/SSH
Nov 29 14:43:46 NOTICE  telnet/ssh-2: admin login from host 192.168.11.129
Nov 29 14:43:49 NOTICE  telnet/ssh-2: admin logout from Telnet/SSH
Nov 29 14:44:16 NOTICE  telnet/ssh-2: admin login from host 192.168.11.129
Nov 29 14:44:18 NOTICE  telnet/ssh-2: admin logout from Telnet/SSH
Nov 29 14:44:50 NOTICE  telnet/ssh-2: admin login from host 192.168.11.129
Nov 29 14:44:52 NOTICE  telnet/ssh-2: admin logout from Telnet/SSH
Nov 29 14:45:19 NOTICE  telnet/ssh-2: admin login from host 192.168.11.129
Nov 29 14:45:22 NOTICE  telnet/ssh-2: admin logout from Telnet/SSH
Nov 29 14:45:55 NOTICE  telnet/ssh-2: admin login from host 192.168.11.129
Nov 29 14:45:57 NOTICE  telnet/ssh-2: admin logout from Telnet/SSH
Nov 29 14:46:23 NOTICE  telnet/ssh-2: admin login from host 192.168.11.129
Nov 29 14:46:25 NOTICE  telnet/ssh-2: admin logout from Telnet/SSH
Nov 29 14:51:14 NOTICE  telnet/ssh-2: admin login from host 192.168.11.129
Nov 29 14:51:16 NOTICE  telnet/ssh-2: admin logout from Telnet/SSH
Nov 29 14:51:35 NOTICE  telnet/ssh-2: admin login from host 192.168.11.129
Nov 29 14:51:38 NOTICE  telnet/ssh-2: admin logout from Telnet/SSH
Nov 29 15:44:24 NOTICE  telnet/ssh-1: admin idle timeout from Telnet/SSH
Nov 29 20:04:36 ALERT   ip: cannot contact default gateway 10.100.21.1
Nov 29 20:05:55 NOTICE  ip: default gateway 10.100.21.1 operational
Nov 29 20:05:55 NOTICE  ip: default gateway 10.100.21.1 enabled
Nov 29 20:11:50 NOTICE  telnet/ssh-1: admin login from host 192.168.11.129
------------------------------------------------------------------
Port   Speed    Duplex     Flow Ctrl      Link
----   -----   --------  --TX-----RX--   ------
  1      100     full     yes    yes       up 
  2    10/100     any     yes    yes      down
  3    10/100     any     yes    yes      down
  4    10/100     any     yes    yes    disabled
  5    10/100     any     yes    yes      down
  6    10/100     any     yes    yes      down
  7    10/100     any     yes    yes      down
  8    10/100     any     yes    yes      down
  9     1000     full     yes    yes      down
------------------------------------------------------------------
Spanning Tree Group 1: On

Current Root:            Path-Cost  Port Hello MaxAge FwdDel Aging
 01a4 00:60:cf:48:1e:c0        0       0    1     14      6    300

Parameters:  Priority  Hello  MaxAge  FwdDel  Aging
                420      1      14       9     450

Port  Priority  Cost      State       Designated Bridge     Des Port
----  --------  ----   -----------  ----------------------  --------
  1       128      5   FORWARDING   01a4-00:60:cf:48:1e:c0    32769
  2       128      0    DISABLED   
  4       128      0    DISABLED   
  5       128      0    DISABLED   
  7       128      0    DISABLED   
  9       128      0    DISABLED   
------------------------------------------------------------------
Spanning Tree Group 2: On

Current Root:            Path-Cost  Port Hello MaxAge FwdDel Aging
 0004 00:60:cf:48:1e:c0        0       0    3      8      6    555

Parameters:  Priority  Hello  MaxAge  FwdDel  Aging
                  4      3       8       6     555

Port  Priority  Cost      State       Designated Bridge     Des Port
----  --------  ----   -----------  ----------------------  --------
  6       128     19    DISABLED   
  8        44     34    DISABLED   
------------------------------------------------------------------
Spanning Tree Group 3: On

Current Root:            Path-Cost  Port Hello MaxAge FwdDel Aging
 8000 00:60:cf:48:1e:c0        0       0    2     20     15    300

Parameters:  Priority  Hello  MaxAge  FwdDel  Aging
              32768      2      20      15     300

Port  Priority  Cost      State       Designated Bridge     Des Port
----  --------  ----   -----------  ----------------------  --------
  3       128      0    DISABLED   
VLAN                Name               Status Jumbo  Ports
----  -------------------------------- ------ -----  ----------------
1     Default VLAN                       ena    n   1 2 4 5 7 9
2     ceige                              ena    n   6 8
3     VLAN 3                             dis    n   empty
6     testvlan6                          ena    n   3
Port  Tag  PVID       NAME               VLAN(s)
----  ---  ----  -------------  -----------------------
  1    n      1                     1 
  2    n      1                     1 
  3    n      6                     6 
  4    n      1  ceige              1 
  5    n      1                     1 
  6    n      2  ceige              2 
  7    n      1                     1 
  8    n      2                     2 
  9    n      1                     1 
Trunk group 1, port state:
  6: STG  2 DOWN

Forwarding database information:
     MAC address     VLAN  Port  State  Referenced ports
  -----------------  ----  ----  -----  ----------------
  00:0a:41:fd:74:81     1    1    FWD    1
  00:17:94:45:ee:d0     1    1    FWD    1
  00:e0:52:c1:58:37     1    1    FWD    1
Port Mirroring is disabled

Monitoring port	Mirrored ports
1		none
2		none
3		none
4		none
5		none
6		none
7		none
8		none
9		none
Interface information:
  1: 10.100.21.222   255.255.255.0   10.100.21.255,   vlan 1, up
  6: 192.168.0.1     255.255.255.0   192.168.0.255,   vlan 2, DOWN
  8: 192.168.8.43    255.255.254.0   192.168.8.255,   vlan 1, DISABLED
  9: 192.168.1.1     255.255.255.0   192.168.1.255,   vlan 1, DISABLED

Default gateway information: metric strict
  1: 10.100.21.1,     up

Current IP forwarding settings: ON, dirbr disabled

Current local networks:

Current IP port settings:
  All other ports have forwarding ON
Virtual Router Redundancy is globally turned OFF.
ARP cache information:
    IP address    Flags    MAC address    VLAN Port Referenced ports
  --------------- ----- ----------------- ---- ---- ----------------
  10.100.21.1           00:17:94:45:ee:d0    1   1   empty
  10.100.21.3           00:e0:52:c1:58:37    1   1   empty
  10.100.21.222    P    00:60:cf:48:1e:c0    1       1-9
  192.168.0.1      P    00:60:cf:48:1e:c0    2       1-9
ARP address information:
    IP address        IP mask        MAC address    VLAN Flags
  --------------- --------------- ----------------- ---- -----
  10.100.21.222   255.255.255.255 00:60:cf:48:1e:c0    1 
Route table information:
    Destination         Mask          Gateway        Type      Tag    Metr If
  --------------- --------------- --------------- --------- --------- ---- --
  0.0.0.0         0.0.0.0         10.100.21.1     indirect  static          1
  10.100.21.0     255.255.255.0   10.100.21.222   direct    fixed           1
  10.100.21.222   255.255.255.255 10.100.21.222   local     addr            1
  10.100.21.255   255.255.255.255 10.100.21.255   broadcast broadcast       1
  127.0.0.0       255.0.0.0       0.0.0.0         martian   martian        
  224.0.0.0       224.0.0.0       0.0.0.0         martian   martian        
  255.255.255.255 255.255.255.255 255.255.255.255 broadcast broadcast      
Server Load Balancing is globally turned OFF.
Enabled Software features:
  Layer 4: SLB + WCR

SYN attack detection is currently off

>> Information# 

END

