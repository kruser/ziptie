package DataCS500;

use strict;
use warnings;
use Exporter 'import';
our @EXPORT_OK = qw($responsesCS500);

our $responsesCS500 = {};

$responsesCS500->{version} = <<'END';
CS-500#show version
CS Software (CS500-KR), Version 9.21(3), RELEASE SOFTWARE (fc1)
Copyright (c) 1986-1994 by cisco Systems, Inc.
Compiled Tue 03-May-94 16:25 by jyang

ROM: System Bootstrap, Version 4.7(3), RELEASE SOFTWARE

CS-500 uptime is 52 weeks, 6 days, 9 hours, 18 minutes
System restarted by power-on
System image file is unknown, booted via 192.168.10.137
Host configuration file is "10.100.1.16.config", booted via tftp from 10.10.101.
138

Cisco-CS500 (68331) processor with 4096K bytes of memory.
SuperLAT software (copyright 1990 by Meridian Technology Corp).
1 Ethernet/IEEE 802.3 interface.
16 terminal lines.
32K bytes of non-volatile configuration memory.
Configuration register is 0x101

END

$responsesCS500->{config} = <<'END';
CS-500#show configuration
Using 2014 out of 32512 bytes
!
version 9.21
no service pad
service timestamps debug datetime localtime
service timestamps log datetime localtime
service password-encryption
!
hostname CS-500
!
clock timezone Eastern -5
enable password 7 082345491D1C1D
!
username testlab password 7 0503090D23455A
username superfly
no ip domain-lookup
!
interface Ethernet0
ip address 10.100.1.16 255.255.255.0
no ip route-cache
!
ip default-gateway 10.100.1.1
ip host PORT3 2003 1.1.1.1
ip host PORT5 2005 1.1.1.1
ip host C4003-CATIOS 2005 1.1.1.1
ip host C4003-CATOS 2004 1.1.1.1
ip host PIX501 2006 1.1.1.1
ip host PORT9 2009 1.1.1.1
ip host C3640 2008 1.1.1.1
ip host LD415 2002 1.1.1.1
ip host C2621 2003 1.1.1.1
ip host CLD415 2002 1.1.1.1
ip host PORT2 2002 1.1.1.1
ip host PORT4 2004 1.1.1.1
ip host PORT6 2006 1.1.1.1
ip host PORT7 2007 1.1.1.1
ip host PORT8 2008 1.1.1.1
ip host PORT10 2010 1.1.1.1
ip host PORT11 2011 1.1.1.1
ip host PORT12 2012 1.1.1.1
ip host PORT13 2013 1.1.1.1
ip host PORT14 2014 1.1.1.1
ip host PORT15 2015 1.1.1.1
ip host PORT16 2016 1.1.1.1
ip domain-name alterpoint.com
ip name-server 10.10.1.9
snmp-server community
snmp-server community public RO
snmp-server community DAVETEST RW
snmp-server community wookie RW
snmp-server community jedi RW
snmp-server community blah0-new RW
snmp-server community DAVETEST1 RW
snmp-server community pablito RW
snmp-server location alterpoint
snmp-server contact tweety
snmp-server host 10.10.1.65 b00g3r3at3r
banner exec ^CC
This is my new banner.
^C
!
line con 0
line 1 16
line vty 0
access-class 123 in
exec-timeout 0 30
password 7 0503090D23455A
login local
line vty 1
access-class 123 in
exec-timeout 60 0
password 7 060E00234E471D
login local
line vty 2
access-class 123 in
exec-timeout 60 0
password 7 0944410B1B0C03
login local
line vty 3
access-class 123 in
exec-timeout 60 0
password 7 11011607151B1F
login local
line vty 4
access-class 123 in
exec-timeout 60 0
password 7 130D1810090510
login local
line vty 5 6
access-class 123 in
login local
line vty 7 15
login local
!
end

CS-500#

END

$responsesCS500->{interfaces} = <<'END';
CS-500#show interfaces
Ethernet0 is up, line protocol is up
  Hardware is Lance, address is 0000.0cff.efc4 (bia 0000.0cff.efc4)
  Internet address is 10.100.1.16, subnet mask is 255.255.255.0
  MTU 1500 bytes, BW 10000 Kbit, DLY 1000 usec, rely 255/255, load 1/255
  Encapsulation ARPA, loopback not set, keepalive set (10 sec)
  ARP type: ARPA, ARP Timeout 4:00:00
  Last input 0:00:00, output 0:00:00, output hang never
  Last clearing of "show interface" counters never
  Output queue 0/40, 0 drops; input queue 0/75, 1614 drops
  Five minute input rate 0 bits/sec, 1 packets/sec
  Five minute output rate 0 bits/sec, 1 packets/sec
     4504392 packets input, 401325408 bytes, 0 no buffer
     Received 3113596 broadcasts, 0 runts, 0 giants
     0 input errors, 0 CRC, 0 frame, 0 overrun, 0 ignored, 0 abort
     0 input packets with dribble condition detected
     5118974 packets output, 568283500 bytes, 0 underruns
     18 output errors, 74 collisions, 3 interface resets, 0 restarts
CS-500#
END

$responsesCS500->{accessPorts} = <<'END';
CS-500#show line
 Tty Typ    Tx/Rx    A Modem  Roty AccO AccI  Uses    Noise   Overruns
   0 CTY             -    -      -    -    -     0        0        0/0
   1 TTY  9600/9600  -    -      -    -    -     0        0        0/0
   2 TTY  9600/9600  -    -      -    -    -     0        0        0/0
   3 TTY  9600/9600  -    -      -    -    -     0        0        0/0
   4 TTY  9600/9600  -    -      -    -    -     0        0        0/0
   5 TTY  9600/9600  -    -      -    -    -     0        0        0/0
   6 TTY  9600/9600  -    -      -    -    -     0        0        0/0
   7 TTY  9600/9600  -    -      -    -    -     0        0        0/0
   8 TTY  9600/9600  -    -      -    -    -     0        0        0/0
   9 TTY  9600/9600  -    -      -    -    -     0        0        0/0
  10 TTY  9600/9600  -    -      -    -    -     0        0        0/0
  11 TTY  9600/9600  -    -      -    -    -     0        0        0/0
  12 TTY  9600/9600  -    -      -    -    -     0        0        0/0
  13 TTY  9600/9600  -    -      -    -    -     0        0        0/0
  14 TTY  9600/9600  -    -      -    -    -     0        0        0/0
  15 TTY  9600/9600  -    -      -    -    -     0        0        0/0
  16 TTY  9600/9600  -    -      -    -    -     0        0        0/0
* 17 VTY  9600/9600  -    -      -    -  123 17271        0        0/0
  18 VTY  9600/9600  -    -      -    -  123  1560        0        0/0
  19 VTY  9600/9600  -    -      -    -  123    63        0        0/0
  20 VTY  9600/9600  -    -      -    -  123     4        0        0/0
  21 VTY  9600/9600  -    -      -    -  123     0        0        0/0
  22 VTY  9600/9600  -    -      -    -  123     0        0        0/0
  23 VTY  9600/9600  -    -      -    -  123     0        0        0/0
  24 VTY  9600/9600  -    -      -    -    -     0        0        0/0
  25 VTY  9600/9600  -    -      -    -    -     0        0        0/0
  26 VTY  9600/9600  -    -      -    -    -     0        0        0/0
  27 VTY  9600/9600  -    -      -    -    -     0        0        0/0
  28 VTY  9600/9600  -    -      -    -    -     0        0        0/0
  29 VTY  9600/9600  -    -      -    -    -     0        0        0/0
  30 VTY  9600/9600  -    -      -    -    -     0        0        0/0
  31 VTY  9600/9600  -    -      -    -    -     0        0        0/0
  32 VTY  9600/9600  -    -      -    -    -     0        0        0/0
  
CS-500#
END


