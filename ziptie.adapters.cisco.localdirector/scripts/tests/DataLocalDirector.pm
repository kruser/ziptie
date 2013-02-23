package DataLocalDirector;

use strict;
use warnings;
use Exporter 'import';
our @EXPORT_OK = qw($responsesLD);

our $responsesLD = {};

$responsesLD->{config} = <<'END';
: Saved
: LocalDirector 416 Version 3.2.3
syslog output 16.7
no syslog console
syslog host 10.100.32.43
enable password c7c54e3f90b1bc36934a6a68202d1b encrypted
hostname LocalDir416
no shutdown ethernet 0
no shutdown ethernet 1
no shutdown ethernet 2
interface ethernet 0 auto
interface ethernet 1 auto
interface ethernet 2 auto
mtu 0 1500
mtu 1 1500
mtu 2 1500
multiring all
no secure  0
no secure  1
no secure  2
no ping-allow 0
no ping-allow 1
no ping-allow 2
ip address 10.100.25.5 255.255.255.0
route 0.0.0.0 0.0.0.0 10.100.25.1 1
no rip passive
rip version 1
failover ip address 10.100.25.199
no failover
failover hellotime 30
password hobbit
telnet 10.0.0.0 255.0.0.0
telnet 192.168.0.0 255.255.0.0
snmp-server host 10.0.0.0
snmp-server enable traps
snmp-server community public
snmp-server contact PITester1 
snmp-server location DallasTexas 
tftp-server 10.10.1.54 port 69 / 
: end


END

$responsesLD->{hw} = <<'END';
show hw
SE440BX, 32 MB RAM, CPU Pentium II 333 MHz

LocalDir416# 

END

$responsesLD->{version} = <<'END';
show version
LocalDirector 416 Version 3.2.3

LocalDir416# 

END

$responsesLD->{interfaces} = <<'END';
show interface
ethernet 0 is up, line protocol is down
  Hardware is i82557 rev 8 ethernet, address is 00d0.b709.1f38
  MTU 1500 bytes, BW 10000 Kbit half duplex
	0 packets input, 0 bytes, 0 no buffer
	Received 0 broadcasts, 0 runts, 0 giants
	0 input errors, 0 CRC, 0 frame, 0 overrun, 0 ignored, 0 abort
	1004460 packets output, 64909693 bytes, 0 underruns
ethernet 1 is up, line protocol is down
  Hardware is i82557 rev 8 ethernet, address is 00d0.b709.1f38
  MTU 1500 bytes, BW 10000 Kbit half duplex
	0 packets input, 0 bytes, 0 no buffer
	Received 0 broadcasts, 0 runts, 0 giants
	0 input errors, 0 CRC, 0 frame, 0 overrun, 0 ignored, 0 abort
	1004460 packets output, 64909693 bytes, 0 underruns
ethernet 2 is up, line protocol is up
  Hardware is i82557 rev 8 ethernet, address is 00d0.b709.1f38
  MTU 1500 bytes, BW 100000 Kbit full duplex
	1171336 packets input, 76441112 bytes, 0 no buffer
	Received 21689 broadcasts, 0 runts, 0 giants
	0 input errors, 0 CRC, 0 frame, 0 overrun, 0 ignored, 0 abort
	35188 packets output, 2028617 bytes, 0 underruns

LocalDir416# 

END

$responsesLD->{routes} = <<'END';
show route
	0.0.0.0 0.0.0.0 10.100.25.1 1 OTHER static

LocalDir416# 

END

