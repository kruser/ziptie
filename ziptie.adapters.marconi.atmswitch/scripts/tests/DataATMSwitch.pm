package DataATMSwitch;

use strict;
use warnings;
use Exporter 'import';
our @EXPORT_OK = qw($responsesATM);

our $responsesATM = {};

$responsesATM->{'system'} = <<'END';
system show




Description:                  Marconi ESX-3000



Switch Uptime:                22 days 03:45



Hardware Version:             A



Software Version:             S_ForeThought_7.1.0 FCS-Patch (1.118147)



System Name:                  ESX-3000-2 CONFIG-A



System Contact:               Unknown



System Location:              Unknown



Maximum Virtual Paths:        262144



Maximum Virtual Channels:     262144



Fabric ID (MAC Address)       00:20:48:58:10:f9     (   Default   )



SPANS Address:                00000200.f25810f9



PMP Minimum Reserved VCI:     155



PMP Maximum Reserved VCI:     255



Transfer Protocol:            tftp



PVx Connection Preservation:  enabled



SVx/SPVx       Preservation:  N/A         (Operational Status:     N/A    )



PMP Feature:                  enabled



ATM Layer OAM Processing:     disabled



HTTP Help Url:                default



Clock Scaling Factor          1



Preferred IP Interface (SNMP) N/A





ESX-3000-2 CONFIG-A:-> 

END


$responsesATM->{'version'} = <<'END';
system version

Software versions installed: FT8.2 FT6.2_1 FT7.1



Current Flash-Boot Version:  FT7.1





ESX-3000-2 CONFIG-A:-> 

END


$responsesATM->{'fabric'} = <<'END';
hardware fabric show

Fabric     Model          Ver   S/N            NMs    CtlPort Multicast



1          esx3000        C     99440505       6      512     mcast1K





ESX-3000-2 CONFIG-A:-> 

END


$responsesATM->{'scp'} = <<'END';
hardware scp show

            CPU         DRAM    Flash IDE     Board Prom



CPU Type    Rev State   Size    Size  Size    Rev   Rev  MAC Address  S/N



1X  p55     67  normal  128.0M  N/A   64.0M   N/A   I    08003e2a17aa N/A





ESX-3000-2 CONFIG-A:-> 

END


$responsesATM->{'portcard'} = <<'END';
hardware portcard show

Portcard Hw.Version Mfg.Revision  S/N       Model



1                76            B  99490530  2 ports OC-12c MMF SC series-1



3                 8            A  99500568  12 ports OC-3c MMF SC series-1



5              6194            A  00160666  24 ports 10/100 Ethernet SH





ESX-3000-2 CONFIG-A:-> 

END


$responsesATM->{'netmod'} = <<'END';
hardware netmod show

Netmod Series Admin    Speed  Ports Timing Rev.  S/N       ProductNumber



1A     LE     up       622.0M 1     yes    B     99490530  2-622MM-PC-1



1B     LE     up       622.0M 1     yes    B     99490530  2-622MM-PC-1



3A     LE     up       155.0M 4     yes    A     99500568  12-155MMSC-PC-1



3B     LE     up       155.0M 4     yes    A     99500568  12-155MMSC-PC-1



3C     LE     up       155.0M 4     yes    A     99500568  12-155MMSC-PC-1



5A     BFE-B  up       833.0M 24    no     A     00160666  24-10/100-PC-1





ESX-3000-2 CONFIG-A:-> 

END


$responsesATM->{'free'} = <<'END';
filesystem free

  (system filesystem free)


Available space on flash (in bytes): 30201856





ESX-3000-2 CONFIG-A:-> 

END


$responsesATM->{'dir'} = <<'END';
dir

  (system filesystem dir)


Contents of  :


      Size  Date         Time      Name


 ---------  -----------  --------  ------------


       512  JUL-22-2003  16:20:56  FT8.2/


         6  AUG-08-2003  20:25:20  CURRENT


     57057  JUL-22-2003  20:23:24  APCONFIG


       512  AUG-08-2003  20:08:52  FT6.2_1/


       512  AUG-08-2003  20:25:04  FT7.1/




ESX-3000-2 CONFIG-A:-> 

END


$responsesATM->{'power'} = <<'END';
hardware power

PS Type          InputState OutputState 5VoltState Current SerialNumber Version



1  N/A           normal     normal      N/A        N/A     N/A          N/A





ESX-3000-2 CONFIG-A:-> 

END


$responsesATM->{'config'} = <<'END';
# LES Configuration
# LECS Configuration
# LEC Mode Configuration
interfaces lec defaultlecs modify wellknown
# LEC Configuration
#
#
# IP Configuration
interfaces ip modify asx0 -state down
interfaces ip modify qaa0 -state down
interfaces ip modify qaa1 -state down
interfaces ip modify qaa2 -state down
interfaces ip modify qaa3 -state down
interfaces ip modify ie0 10.10.17.45 255.255.255.0 up -bcast 1
# IP Routing Table
interfaces ip route new default 10.10.17.1 1 net
interfaces ip route new 10.10.17.0 10.10.17.45 0 net
interfaces ip route new 127.0.0.0 127.0.0.1 0 net
# DNS Configuration Table
services dns modify -primary 0.0.0.0 -secondary 0.0.0.0 -state disabled
          -retryInterval 2 -retryMax 1
# NTP Server Status
services ntp modify disabled disabled 0
# NTP Peer Configuration Table
# NTP Restriction Configuration Table
# Kerberos IpAddress-to-hostname Mapping
# Kerberos Realms
# Telnet Configuration Table
security telnet daemon 1 60
# Switch Alarm Table
system alarm modify powerSupplyInputFailed disabled enabled
system alarm modify powerSupplyOutputFailed disabled enabled
system alarm modify fanBankFailed disabled enabled
system alarm modify linkFailed enabled disabled -reset disabled
system alarm modify spansFailed enabled disabled -reset disabled
system alarm modify netmodRemovedHighPrio disabled disabled
system alarm modify netmodRemovedLowPrio disabled disabled
system alarm modify fabricRemoved disabled disabled -reset disabled
system alarm modify genPortFailure disabled disabled
# new-pvc
# new-svc
# ATM Interface Connection Scheduling Table
interfaces atmif schedule modify 1A1 CBR roundrobin -override on
interfaces atmif schedule modify 1A1 rtVBR roundrobin -override on
interfaces atmif schedule modify 1A1 nrtVBR roundrobin -override on
interfaces atmif schedule modify 1A1 UBR roundrobin -override on
interfaces atmif schedule modify 1B1 CBR roundrobin -override on
interfaces atmif schedule modify 1B1 rtVBR roundrobin -override on
interfaces atmif schedule modify 1B1 nrtVBR roundrobin -override on
interfaces atmif schedule modify 1B1 UBR roundrobin -override on
interfaces atmif schedule modify 3A1 CBR roundrobin -override on
interfaces atmif schedule modify 3A1 rtVBR roundrobin -override on
interfaces atmif schedule modify 3A1 nrtVBR roundrobin -override on
interfaces atmif schedule modify 3A1 UBR roundrobin -override on
interfaces atmif schedule modify 3A2 CBR roundrobin -override on
interfaces atmif schedule modify 3A2 rtVBR roundrobin -override on
interfaces atmif schedule modify 3A2 nrtVBR roundrobin -override on
interfaces atmif schedule modify 3A2 UBR roundrobin -override on
interfaces atmif schedule modify 3A3 CBR roundrobin -override on
interfaces atmif schedule modify 3A3 rtVBR roundrobin -override on
interfaces atmif schedule modify 3A3 nrtVBR roundrobin -override on
interfaces atmif schedule modify 3A3 UBR roundrobin -override on
interfaces atmif schedule modify 3A4 CBR roundrobin -override on
interfaces atmif schedule modify 3A4 rtVBR roundrobin -override on
interfaces atmif schedule modify 3A4 nrtVBR roundrobin -override on
interfaces atmif schedule modify 3A4 UBR roundrobin -override on
interfaces atmif schedule modify 3B1 CBR roundrobin -override on
interfaces atmif schedule modify 3B1 rtVBR roundrobin -override on
interfaces atmif schedule modify 3B1 nrtVBR roundrobin -override on
interfaces atmif schedule modify 3B1 UBR roundrobin -override on
interfaces atmif schedule modify 3B2 CBR roundrobin -override on
interfaces atmif schedule modify 3B2 rtVBR roundrobin -override on
interfaces atmif schedule modify 3B2 nrtVBR roundrobin -override on
interfaces atmif schedule modify 3B2 UBR roundrobin -override on
interfaces atmif schedule modify 3B3 CBR roundrobin -override on
interfaces atmif schedule modify 3B3 rtVBR roundrobin -override on
interfaces atmif schedule modify 3B3 nrtVBR roundrobin -override on
interfaces atmif schedule modify 3B3 UBR roundrobin -override on
interfaces atmif schedule modify 3B4 CBR roundrobin -override on
interfaces atmif schedule modify 3B4 rtVBR roundrobin -override on
interfaces atmif schedule modify 3B4 nrtVBR roundrobin -override on
interfaces atmif schedule modify 3B4 UBR roundrobin -override on
interfaces atmif schedule modify 3C1 CBR roundrobin -override on
interfaces atmif schedule modify 3C1 rtVBR roundrobin -override on
interfaces atmif schedule modify 3C1 nrtVBR roundrobin -override on
interfaces atmif schedule modify 3C1 UBR roundrobin -override on
interfaces atmif schedule modify 3C2 CBR roundrobin -override on
interfaces atmif schedule modify 3C2 rtVBR roundrobin -override on
interfaces atmif schedule modify 3C2 nrtVBR roundrobin -override on
interfaces atmif schedule modify 3C2 UBR roundrobin -override on
interfaces atmif schedule modify 3C3 CBR roundrobin -override on
interfaces atmif schedule modify 3C3 rtVBR roundrobin -override on
interfaces atmif schedule modify 3C3 nrtVBR roundrobin -override on
interfaces atmif schedule modify 3C3 UBR roundrobin -override on
interfaces atmif schedule modify 3C4 CBR roundrobin -override on
interfaces atmif schedule modify 3C4 rtVBR roundrobin -override on
interfaces atmif schedule modify 3C4 nrtVBR roundrobin -override on
interfaces atmif schedule modify 3C4 UBR roundrobin -override on
# Audit Logging Configuration
security audit off off off off off off off off
# Fabric Table
hardware fabric modify 1 mcast1K
# Fabric Traffic Management
# Switch Simple BOOTP Relay Table
# QoS Class Expansion Table
# Path Extension QoS Metric Table
# Units used for upc information
connections upc units cps
# UPC Contract Table
# Terminating Path Configuration
connections path term new 1A1 0 term -minvci 1 -maxvci 511
connections path term new 1A1 0 orig -minvci 1 -maxvci 511 -shaping flat
connections path term new 1B1 0 term -minvci 1 -maxvci 511
connections path term new 1B1 0 orig -minvci 1 -maxvci 511 -shaping flat
connections path term new 3A1 0 term -minvci 1 -maxvci 511
connections path term new 3A1 0 orig -minvci 1 -maxvci 511 -shaping flat
connections path term new 3A2 0 term -minvci 1 -maxvci 511
connections path term new 3A2 0 orig -minvci 1 -maxvci 511 -shaping flat
connections path term new 3A3 0 term -minvci 1 -maxvci 511
connections path term new 3A3 0 orig -minvci 1 -maxvci 511 -shaping flat
connections path term new 3A4 0 term -minvci 1 -maxvci 511
connections path term new 3A4 0 orig -minvci 1 -maxvci 511 -shaping flat
connections path term new 3B1 0 term -minvci 1 -maxvci 511
connections path term new 3B1 0 orig -minvci 1 -maxvci 511 -shaping flat
connections path term new 3B2 0 term -minvci 1 -maxvci 511
connections path term new 3B2 0 orig -minvci 1 -maxvci 511 -shaping flat
connections path term new 3B3 0 term -minvci 1 -maxvci 511
connections path term new 3B3 0 orig -minvci 1 -maxvci 511 -shaping flat
connections path term new 3B4 0 term -minvci 1 -maxvci 511
connections path term new 3B4 0 orig -minvci 1 -maxvci 511 -shaping flat
connections path term new 3C1 0 term -minvci 1 -maxvci 511
connections path term new 3C1 0 orig -minvci 1 -maxvci 511 -shaping flat
connections path term new 3C2 0 term -minvci 1 -maxvci 511
connections path term new 3C2 0 orig -minvci 1 -maxvci 511 -shaping flat
connections path term new 3C3 0 term -minvci 1 -maxvci 511
connections path term new 3C3 0 orig -minvci 1 -maxvci 511 -shaping flat
connections path term new 3C4 0 term -minvci 1 -maxvci 511
connections path term new 3C4 0 orig -minvci 1 -maxvci 511 -shaping flat
connections path term new 5ACTL 0 term -minvci 1 -maxvci 511
connections path term new 5ACTL 0 orig -minvci 1 -maxvci 511 -shaping flat
connections path term modify CTL 0 term -maxvci 4095 -cbr default -rtvbr
          default -nrtvbr default -abr default -ubr default
connections path term modify CTL 0 orig -maxvci 4095 -cbr default -rtvbr
          default -nrtvbr default -abr default -ubr default
# PVC Table
# Charting of Table Fields
security http chart enabled
# Topology Distribution Parameters
routing deprecated_features ftpnni modify 500 10000 20 20% 50 20
          47.0005.80.ffe100.0000.f258.10f9 104 0 -pgsnreachcostmethod default
          -ftpnniforearea 4 -ftpnniforelevel 4 -ftpnniborderswitch disabled
          -lbubr disabled -spansareaid 242 -spansborderswitch disabled
# FT-PNNI DTL Hop Table
# NSAP Static Route Address Table
# Path & Connection Trace Base Group
connections trace parameters 5 1466
# E.164 Address Mapping Table
# Fabric Temperature Thresholds
# Configure batch script processing
system batch configuration off on
# InterDomain Static Routes
# PNNI Crankback Tries
routing pnni crankback 2
# PNNI DTL Table
# PNNI DTL Tag Table
# PNNI Export Policy Table
# PNNI Profile Table
# PNNI Routing Domain Configuration
routing domain new 1 pnni 47.0005.80.ffe100.0000.f258.10f9 default disabled
# PNNI Parameters
routing pnni parameters modify 20 false
# FTPNNI Metrics Table
# Web Server State
security http webserver enabled
# Interface Table
interfaces if modify 1 up
interfaces if modify 2 down
interfaces if modify 3 down
interfaces if modify 4 down
interfaces if modify 5 down
interfaces if modify 6 down
interfaces if modify 7 up
interfaces if modify 1024 up disabled
interfaces if modify 4194356 up disabled false
interfaces if modify 4718644 up disabled false
interfaces if modify 12582964 up disabled false
interfaces if modify 12583016 up disabled false
interfaces if modify 12583068 up disabled false
interfaces if modify 12583120 up disabled false
interfaces if modify 13107252 up disabled false
interfaces if modify 13107304 up disabled false
interfaces if modify 13107356 up disabled false
interfaces if modify 13107408 up disabled false
interfaces if modify 13631540 up disabled false
interfaces if modify 13631592 up disabled false
interfaces if modify 13631644 up disabled false
interfaces if modify 13631696 up disabled false
interfaces if modify 20971572 up enabled false
interfaces if modify 20971624 up enabled false
interfaces if modify 20971676 up enabled false
interfaces if modify 20971728 up enabled false
interfaces if modify 20971780 up enabled false
interfaces if modify 20971832 up enabled false
interfaces if modify 20971884 up enabled false
interfaces if modify 20971936 up enabled false
interfaces if modify 20971988 up enabled false
interfaces if modify 20972040 up enabled false
interfaces if modify 20972092 up enabled false
interfaces if modify 20972144 up enabled false
interfaces if modify 20972196 up enabled false
interfaces if modify 20972248 up enabled false
interfaces if modify 20972300 up enabled false
interfaces if modify 20972352 up enabled false
interfaces if modify 20972404 up enabled false
interfaces if modify 20972456 up enabled false
interfaces if modify 20972508 up enabled false
interfaces if modify 20972560 up enabled false
interfaces if modify 20972612 up enabled false
interfaces if modify 20972664 up enabled false
interfaces if modify 20972716 up enabled false
interfaces if modify 20972768 up enabled false
interfaces if modify 21299199 up disabled false
interfaces if modify 66912255 up disabled false
# IP forwarding
interfaces ip forwarding off
# IP Filter: Acceptable IP addresses
# IP Filter: Flags
security ipfiltering flags allow allow allow
# DLE Peers Configuration Table
# ATM Interface Table
interfaces atmif modify 1A1 up 250 disabled 1 20 100000 100000 enabled default
          default default svcOff svcOff svcOff svcOff svcOn svcOn svcOn svcOn
          svcOff managed -spvx_call_redirection disabled
interfaces atmif modify 1B1 up 250 disabled 1 20 100000 100000 enabled default
          default default svcOff svcOff svcOff svcOff svcOn svcOn svcOn svcOn
          svcOff managed -spvx_call_redirection disabled
interfaces atmif modify 3A1 up 250 disabled 1 20 100000 100000 enabled default
          default default svcOff svcOff svcOff svcOff svcOn svcOn svcOn svcOn
          svcOff managed -spvx_call_redirection disabled
interfaces atmif modify 3A2 up 250 disabled 1 20 100000 100000 enabled default
          default default svcOff svcOff svcOff svcOff svcOn svcOn svcOn svcOn
          svcOff managed -spvx_call_redirection disabled
interfaces atmif modify 3A3 up 250 disabled 1 20 100000 100000 enabled default
          default default svcOff svcOff svcOff svcOff svcOn svcOn svcOn svcOn
          svcOff managed -spvx_call_redirection disabled
interfaces atmif modify 3A4 up 250 disabled 1 20 100000 100000 enabled default
          default default svcOff svcOff svcOff svcOff svcOn svcOn svcOn svcOn
          svcOff managed -spvx_call_redirection disabled
interfaces atmif modify 3B1 up 250 disabled 1 20 100000 100000 enabled default
          default default svcOff svcOff svcOff svcOff svcOn svcOn svcOn svcOn
          svcOff managed -spvx_call_redirection disabled
interfaces atmif modify 3B2 up 250 disabled 1 20 100000 100000 enabled default
          default default svcOff svcOff svcOff svcOff svcOn svcOn svcOn svcOn
          svcOff managed -spvx_call_redirection disabled
interfaces atmif modify 3B3 up 250 disabled 1 20 100000 100000 enabled default
          default default svcOff svcOff svcOff svcOff svcOn svcOn svcOn svcOn
          svcOff managed -spvx_call_redirection disabled
interfaces atmif modify 3B4 up 250 disabled 1 20 100000 100000 enabled default
          default default svcOff svcOff svcOff svcOff svcOn svcOn svcOn svcOn
          svcOff managed -spvx_call_redirection disabled
interfaces atmif modify 3C1 up 250 disabled 1 20 100000 100000 enabled default
          default default svcOff svcOff svcOff svcOff svcOn svcOn svcOn svcOn
          svcOff managed -spvx_call_redirection disabled
interfaces atmif modify 3C2 up 250 disabled 1 20 100000 100000 enabled default
          default default svcOff svcOff svcOff svcOff svcOn svcOn svcOn svcOn
          svcOff managed -spvx_call_redirection disabled
interfaces atmif modify 3C3 up 250 disabled 1 20 100000 100000 enabled default
          default default svcOff svcOff svcOff svcOff svcOn svcOn svcOn svcOn
          svcOff managed -spvx_call_redirection disabled
interfaces atmif modify 3C4 up 250 disabled 1 20 100000 100000 enabled default
          default default svcOff svcOff svcOff svcOff svcOn svcOn svcOn svcOn
          svcOff managed -spvx_call_redirection disabled
interfaces atmif modify 5ACTL up 5000 disabled 0 0 0 0 enabled default default
          default svcOff svcOff svcOff svcOff svcOn svcOn svcOn svcOn svcOff
          managed -spvx_call_redirection disabled
interfaces atmif modify CTL up 5000 -icdv 0 -imaxctd 0 -ocdv 0 -omaxctd 0
          -gcracbr default -gcrartvbr default -gcranrtvbr default -gcraubr
          svcOff -pppcbr svcOff -ppprtvbr svcOff -pppnrtvbr svcOff -ubrtagging
          svcOff -mgmtstatus managed -spvx_call_redirection disabled
# ATM Interface Overbooking Table
interfaces atmif overbooking modify 1A1 100 100 100 100 100
interfaces atmif overbooking modify 1B1 100 100 100 100 100
interfaces atmif overbooking modify 3A1 100 100 100 100 100
interfaces atmif overbooking modify 3A2 100 100 100 100 100
interfaces atmif overbooking modify 3A3 100 100 100 100 100
interfaces atmif overbooking modify 3A4 100 100 100 100 100
interfaces atmif overbooking modify 3B1 100 100 100 100 100
interfaces atmif overbooking modify 3B2 100 100 100 100 100
interfaces atmif overbooking modify 3B3 100 100 100 100 100
interfaces atmif overbooking modify 3B4 100 100 100 100 100
interfaces atmif overbooking modify 3C1 100 100 100 100 100
interfaces atmif overbooking modify 3C2 100 100 100 100 100
interfaces atmif overbooking modify 3C3 100 100 100 100 100
interfaces atmif overbooking modify 3C4 100 100 100 100 100
# Netmod Table
hardware netmod modify 1A up
hardware netmod modify 1B up
hardware netmod modify 3A up
hardware netmod modify 3B up
hardware netmod modify 3C up
hardware netmod modify 5A up
# Netmod Alarm Table
hardware netmod alarms modify 1A none
hardware netmod alarms modify 1B none
hardware netmod alarms modify 1C none
hardware netmod alarms modify 1D none
hardware netmod alarms modify 2A none
hardware netmod alarms modify 2B none
hardware netmod alarms modify 2C none
hardware netmod alarms modify 2D none
hardware netmod alarms modify 3A none
hardware netmod alarms modify 3B none
hardware netmod alarms modify 3C none
hardware netmod alarms modify 3D none
hardware netmod alarms modify 4A none
hardware netmod alarms modify 4B none
hardware netmod alarms modify 4C none
hardware netmod alarms modify 4D none
hardware netmod alarms modify 5A none
hardware netmod alarms modify 5B none
hardware netmod alarms modify 5C none
hardware netmod alarms modify 5D none
hardware netmod alarms modify 6A none
hardware netmod alarms modify 6B none
hardware netmod alarms modify 6C none
hardware netmod alarms modify 6D none
hardware netmod alarms modify 7A none
hardware netmod alarms modify 7B none
hardware netmod alarms modify 7C none
hardware netmod alarms modify 7D none
hardware netmod alarms modify 8A none
hardware netmod alarms modify 8B none
hardware netmod alarms modify 8C none
hardware netmod alarms modify 8D none
# Enable/Disable NCCI
system ncci disabled
# VPCI Maps Table
# VPCI Groups
# proxyDirGroup Table
# proxyDirEntry Table
# Signalling Redundancy Table
# TNS Screening Profiles
# ATMF Signalling Configuration
signalling new 1A1 0 5 up -admintype auto -ilmivci 16 -adminminvci 32
          -adminmaxvci 511 -adminversion auto -ilmireg enable -addressformat
          private -e164address disabled -ftpnniorigcost 100 -sigmode auto
          -sigscope auto -isigupc 0 -sscoptimer 10 -insapfilter 0 -onsapfilter
          0 -qosexp 0 -domain 1 -plantype unknown -maxvpi 4094
          -acceleratedclear disabled -pnni_rcc_vci 18 -useiefilter disabled
          -cg no -cgs yes -cds yes -bhli yes -blli yes -blli23 yes -aal yes
          -usedefaddr disabled -defaultcpn
          0x0000000000000000000000000000000000000000 -ubrCalls on -cbrCalls on
          -abrCalls on -rtvbrCalls on -nrtvbrCalls on -tnsScreening disabled
          -tnsProfile none -tnsStrip enabled
signalling new 1B1 0 5 up -admintype auto -ilmivci 16 -adminminvci 32
          -adminmaxvci 511 -adminversion auto -ilmireg enable -addressformat
          private -e164address disabled -ftpnniorigcost 100 -sigmode auto
          -sigscope auto -isigupc 0 -sscoptimer 10 -insapfilter 0 -onsapfilter
          0 -qosexp 0 -domain 1 -plantype unknown -maxvpi 4094
          -acceleratedclear disabled -pnni_rcc_vci 18 -useiefilter disabled
          -cg no -cgs yes -cds yes -bhli yes -blli yes -blli23 yes -aal yes
          -usedefaddr disabled -defaultcpn
          0x0000000000000000000000000000000000000000 -ubrCalls on -cbrCalls on
          -abrCalls on -rtvbrCalls on -nrtvbrCalls on -tnsScreening disabled
          -tnsProfile none -tnsStrip enabled
signalling new 3A1 0 5 up -admintype auto -ilmivci 16 -adminminvci 32
          -adminmaxvci 511 -adminversion auto -ilmireg enable -addressformat
          private -e164address disabled -ftpnniorigcost 100 -sigmode auto
          -sigscope auto -isigupc 0 -sscoptimer 10 -insapfilter 0 -onsapfilter
          0 -qosexp 0 -domain 1 -plantype unknown -maxvpi 1022
          -acceleratedclear disabled -pnni_rcc_vci 18 -useiefilter disabled
          -cg no -cgs yes -cds yes -bhli yes -blli yes -blli23 yes -aal yes
          -usedefaddr disabled -defaultcpn
          0x0000000000000000000000000000000000000000 -ubrCalls on -cbrCalls on
          -abrCalls on -rtvbrCalls on -nrtvbrCalls on -tnsScreening disabled
          -tnsProfile none -tnsStrip enabled
signalling new 3A2 0 5 up -admintype auto -ilmivci 16 -adminminvci 32
          -adminmaxvci 511 -adminversion auto -ilmireg enable -addressformat
          private -e164address disabled -ftpnniorigcost 100 -sigmode auto
          -sigscope auto -isigupc 0 -sscoptimer 10 -insapfilter 0 -onsapfilter
          0 -qosexp 0 -domain 1 -plantype unknown -maxvpi 1022
          -acceleratedclear disabled -pnni_rcc_vci 18 -useiefilter disabled
          -cg no -cgs yes -cds yes -bhli yes -blli yes -blli23 yes -aal yes
          -usedefaddr disabled -defaultcpn
          0x0000000000000000000000000000000000000000 -ubrCalls on -cbrCalls on
          -abrCalls on -rtvbrCalls on -nrtvbrCalls on -tnsScreening disabled
          -tnsProfile none -tnsStrip enabled
signalling new 3A3 0 5 up -admintype auto -ilmivci 16 -adminminvci 32
          -adminmaxvci 511 -adminversion auto -ilmireg enable -addressformat
          private -e164address disabled -ftpnniorigcost 100 -sigmode auto
          -sigscope auto -isigupc 0 -sscoptimer 10 -insapfilter 0 -onsapfilter
          0 -qosexp 0 -domain 1 -plantype unknown -maxvpi 1022
          -acceleratedclear disabled -pnni_rcc_vci 18 -useiefilter disabled
          -cg no -cgs yes -cds yes -bhli yes -blli yes -blli23 yes -aal yes
          -usedefaddr disabled -defaultcpn
          0x0000000000000000000000000000000000000000 -ubrCalls on -cbrCalls on
          -abrCalls on -rtvbrCalls on -nrtvbrCalls on -tnsScreening disabled
          -tnsProfile none -tnsStrip enabled
signalling new 3A4 0 5 up -admintype auto -ilmivci 16 -adminminvci 32
          -adminmaxvci 511 -adminversion auto -ilmireg enable -addressformat
          private -e164address disabled -ftpnniorigcost 100 -sigmode auto
          -sigscope auto -isigupc 0 -sscoptimer 10 -insapfilter 0 -onsapfilter
          0 -qosexp 0 -domain 1 -plantype unknown -maxvpi 1022
          -acceleratedclear disabled -pnni_rcc_vci 18 -useiefilter disabled
          -cg no -cgs yes -cds yes -bhli yes -blli yes -blli23 yes -aal yes
          -usedefaddr disabled -defaultcpn
          0x0000000000000000000000000000000000000000 -ubrCalls on -cbrCalls on
          -abrCalls on -rtvbrCalls on -nrtvbrCalls on -tnsScreening disabled
          -tnsProfile none -tnsStrip enabled
signalling new 3B1 0 5 up -admintype auto -ilmivci 16 -adminminvci 32
          -adminmaxvci 511 -adminversion auto -ilmireg enable -addressformat
          private -e164address disabled -ftpnniorigcost 100 -sigmode auto
          -sigscope auto -isigupc 0 -sscoptimer 10 -insapfilter 0 -onsapfilter
          0 -qosexp 0 -domain 1 -plantype unknown -maxvpi 1022
          -acceleratedclear disabled -pnni_rcc_vci 18 -useiefilter disabled
          -cg no -cgs yes -cds yes -bhli yes -blli yes -blli23 yes -aal yes
          -usedefaddr disabled -defaultcpn
          0x0000000000000000000000000000000000000000 -ubrCalls on -cbrCalls on
          -abrCalls on -rtvbrCalls on -nrtvbrCalls on -tnsScreening disabled
          -tnsProfile none -tnsStrip enabled
signalling new 3B2 0 5 up -admintype auto -ilmivci 16 -adminminvci 32
          -adminmaxvci 511 -adminversion auto -ilmireg enable -addressformat
          private -e164address disabled -ftpnniorigcost 100 -sigmode auto
          -sigscope auto -isigupc 0 -sscoptimer 10 -insapfilter 0 -onsapfilter
          0 -qosexp 0 -domain 1 -plantype unknown -maxvpi 1022
          -acceleratedclear disabled -pnni_rcc_vci 18 -useiefilter disabled
          -cg no -cgs yes -cds yes -bhli yes -blli yes -blli23 yes -aal yes
          -usedefaddr disabled -defaultcpn
          0x0000000000000000000000000000000000000000 -ubrCalls on -cbrCalls on
          -abrCalls on -rtvbrCalls on -nrtvbrCalls on -tnsScreening disabled
          -tnsProfile none -tnsStrip enabled
signalling new 3B3 0 5 up -admintype auto -ilmivci 16 -adminminvci 32
          -adminmaxvci 511 -adminversion auto -ilmireg enable -addressformat
          private -e164address disabled -ftpnniorigcost 100 -sigmode auto
          -sigscope auto -isigupc 0 -sscoptimer 10 -insapfilter 0 -onsapfilter
          0 -qosexp 0 -domain 1 -plantype unknown -maxvpi 1022
          -acceleratedclear disabled -pnni_rcc_vci 18 -useiefilter disabled
          -cg no -cgs yes -cds yes -bhli yes -blli yes -blli23 yes -aal yes
          -usedefaddr disabled -defaultcpn
          0x0000000000000000000000000000000000000000 -ubrCalls on -cbrCalls on
          -abrCalls on -rtvbrCalls on -nrtvbrCalls on -tnsScreening disabled
          -tnsProfile none -tnsStrip enabled
signalling new 3B4 0 5 up -admintype auto -ilmivci 16 -adminminvci 32
          -adminmaxvci 511 -adminversion auto -ilmireg enable -addressformat
          private -e164address disabled -ftpnniorigcost 100 -sigmode auto
          -sigscope auto -isigupc 0 -sscoptimer 10 -insapfilter 0 -onsapfilter
          0 -qosexp 0 -domain 1 -plantype unknown -maxvpi 1022
          -acceleratedclear disabled -pnni_rcc_vci 18 -useiefilter disabled
          -cg no -cgs yes -cds yes -bhli yes -blli yes -blli23 yes -aal yes
          -usedefaddr disabled -defaultcpn
          0x0000000000000000000000000000000000000000 -ubrCalls on -cbrCalls on
          -abrCalls on -rtvbrCalls on -nrtvbrCalls on -tnsScreening disabled
          -tnsProfile none -tnsStrip enabled
signalling new 3C1 0 5 up -admintype auto -ilmivci 16 -adminminvci 32
          -adminmaxvci 511 -adminversion auto -ilmireg enable -addressformat
          private -e164address disabled -ftpnniorigcost 100 -sigmode auto
          -sigscope auto -isigupc 0 -sscoptimer 10 -insapfilter 0 -onsapfilter
          0 -qosexp 0 -domain 1 -plantype unknown -maxvpi 1022
          -acceleratedclear disabled -pnni_rcc_vci 18 -useiefilter disabled
          -cg no -cgs yes -cds yes -bhli yes -blli yes -blli23 yes -aal yes
          -usedefaddr disabled -defaultcpn
          0x0000000000000000000000000000000000000000 -ubrCalls on -cbrCalls on
          -abrCalls on -rtvbrCalls on -nrtvbrCalls on -tnsScreening disabled
          -tnsProfile none -tnsStrip enabled
signalling new 3C2 0 5 up -admintype auto -ilmivci 16 -adminminvci 32
          -adminmaxvci 511 -adminversion auto -ilmireg enable -addressformat
          private -e164address disabled -ftpnniorigcost 100 -sigmode auto
          -sigscope auto -isigupc 0 -sscoptimer 10 -insapfilter 0 -onsapfilter
          0 -qosexp 0 -domain 1 -plantype unknown -maxvpi 1022
          -acceleratedclear disabled -pnni_rcc_vci 18 -useiefilter disabled
          -cg no -cgs yes -cds yes -bhli yes -blli yes -blli23 yes -aal yes
          -usedefaddr disabled -defaultcpn
          0x0000000000000000000000000000000000000000 -ubrCalls on -cbrCalls on
          -abrCalls on -rtvbrCalls on -nrtvbrCalls on -tnsScreening disabled
          -tnsProfile none -tnsStrip enabled
signalling new 3C3 0 5 up -admintype auto -ilmivci 16 -adminminvci 32
          -adminmaxvci 511 -adminversion auto -ilmireg enable -addressformat
          private -e164address disabled -ftpnniorigcost 100 -sigmode auto
          -sigscope auto -isigupc 0 -sscoptimer 10 -insapfilter 0 -onsapfilter
          0 -qosexp 0 -domain 1 -plantype unknown -maxvpi 1022
          -acceleratedclear disabled -pnni_rcc_vci 18 -useiefilter disabled
          -cg no -cgs yes -cds yes -bhli yes -blli yes -blli23 yes -aal yes
          -usedefaddr disabled -defaultcpn
          0x0000000000000000000000000000000000000000 -ubrCalls on -cbrCalls on
          -abrCalls on -rtvbrCalls on -nrtvbrCalls on -tnsScreening disabled
          -tnsProfile none -tnsStrip enabled
signalling new 3C4 0 5 up -admintype auto -ilmivci 16 -adminminvci 32
          -adminmaxvci 511 -adminversion auto -ilmireg enable -addressformat
          private -e164address disabled -ftpnniorigcost 100 -sigmode auto
          -sigscope auto -isigupc 0 -sscoptimer 10 -insapfilter 0 -onsapfilter
          0 -qosexp 0 -domain 1 -plantype unknown -maxvpi 1022
          -acceleratedclear disabled -pnni_rcc_vci 18 -useiefilter disabled
          -cg no -cgs yes -cds yes -bhli yes -blli yes -blli23 yes -aal yes
          -usedefaddr disabled -defaultcpn
          0x0000000000000000000000000000000000000000 -ubrCalls on -cbrCalls on
          -abrCalls on -rtvbrCalls on -nrtvbrCalls on -tnsScreening disabled
          -tnsProfile none -tnsStrip enabled
signalling new 5ACTL 0 5 up -admintype auto -ilmivci 16 -adminminvci 32
          -adminmaxvci 511 -adminversion auto -ilmireg enable -addressformat
          private -e164address disabled -ftpnniorigcost 100 -sigmode auto
          -sigscope auto -isigupc 0 -sscoptimer 7 -insapfilter 0 -onsapfilter
          0 -qosexp 0 -domain 1 -plantype unknown -maxvpi 4094
          -acceleratedclear disabled -pnni_rcc_vci 18 -useiefilter disabled
          -cg no -cgs yes -cds yes -bhli yes -blli yes -blli23 yes -aal yes
          -usedefaddr disabled -defaultcpn
          0x0000000000000000000000000000000000000000 -suppservices disabled
          -clip disabled -clir disabled -colp disabled -colr disabled -sub
          disabled -uus disabled -defconndpaddr
          0x0000000000000000000000000000000000000000 -ubrCalls on -cbrCalls on
          -abrCalls on -rtvbrCalls on -nrtvbrCalls on -tnsScreening disabled
          -tnsProfile none -tnsStrip enabled
# NSAP Network Prefix Table
# System Prompt
system prompt default
# Panic Action
system panic action reboot
# Originating Path Channel Scheduling
# Password Table
security login _rawpassword new ami
security login _rawpassword new testlab c1277b92ae874a3a182d27baf863cfc5
# Through Path Configuration Table
# Per Call Debugging Filter Table
# Traffic Descriptor Table
routing pnni trafdesc new 1 atmClpTaggingScr 906 453 171 -qos Unspecified
# PNNI Node Table
routing pnni node new 1 80
          80:160:0x47.0005.80.ffe100.0000.f258.10f9.ff5810f90001.00 true up
          default 0x47.0005.80.ffe100.0000.f258.10f9.ff5810f90001.00
          80:47.0005.80.ffe100.0000.f200.0000 false 1 5 5 true 50%
          normalTnsRouting 10 10 15 5 120 1800 200% 5 50% 5% 25% 50% 0
          -pglinit 15 -overridedelay 30 -reelecttime 15 -svccinit 4 -retrytime
          30 -callingintegritytime 35 -calledintegritytime 50
          -trafficdescriptorindex 1
# PNNI Route Tns Table
# PNNI Scope Mapping Table
routing pnni scopemapping modify 1 80 80 80 80 80 72 72 64 64 64 48 48 32 32 0
# PNNI Interface Table
routing pnni interface modify 1A1 0 1 0 True 5040 5040 5040 5040 5040 false
routing pnni interface modify 1B1 0 1 0 True 5040 5040 5040 5040 5040 false
routing pnni interface modify 3A1 0 1 0 True 5040 5040 5040 5040 5040 false
routing pnni interface modify 3A2 0 1 0 True 5040 5040 5040 5040 5040 false
routing pnni interface modify 3A3 0 1 0 True 5040 5040 5040 5040 5040 false
routing pnni interface modify 3A4 0 1 0 True 5040 5040 5040 5040 5040 false
routing pnni interface modify 3B1 0 1 0 True 5040 5040 5040 5040 5040 false
routing pnni interface modify 3B2 0 1 0 True 5040 5040 5040 5040 5040 false
routing pnni interface modify 3B3 0 1 0 True 5040 5040 5040 5040 5040 false
routing pnni interface modify 3B4 0 1 0 True 5040 5040 5040 5040 5040 false
routing pnni interface modify 3C1 0 1 0 True 5040 5040 5040 5040 5040 false
routing pnni interface modify 3C2 0 1 0 True 5040 5040 5040 5040 5040 false
routing pnni interface modify 3C3 0 1 0 True 5040 5040 5040 5040 5040 false
routing pnni interface modify 3C4 0 1 0 True 5040 5040 5040 5040 5040 false
routing pnni interface modify 5ACTL 0 1 0 True 5040 5040 5040 5040 5040 false
routing pnni interface modify CTL 0 1 0 True 5040 5040 5040 5040 5040 false
# PNNI Metrics Table
# PNNI Parent Node Externalization Table
# PNNI SPVCC Control Parameters
connections spvcc parameters 2000 20 10000 20 50% 10 1 600 reroute 10
# SPVx Redundancy Group
# Source PNNI PMP Root SPVCCs
# Source PNNI PMP Party SPVCCs
# PNNI Route Addr Configuration
# Hardware Port Table
hardware port modify 1A1 up lan
hardware port modify 1B1 up lan
hardware port modify 3A1 up lan
hardware port modify 3A2 up lan
hardware port modify 3A3 up lan
hardware port modify 3A4 up lan
hardware port modify 3B1 up lan
hardware port modify 3B2 up lan
hardware port modify 3B3 up lan
hardware port modify 3B4 up lan
hardware port modify 3C1 up lan
hardware port modify 3C2 up lan
hardware port modify 3C3 up lan
hardware port modify 3C4 up lan
hardware port modify 5A1 up
hardware port modify 5A2 up
hardware port modify 5A3 up
hardware port modify 5A4 up
hardware port modify 5A5 up
hardware port modify 5A6 up
hardware port modify 5A7 up
hardware port modify 5A8 up
hardware port modify 5A9 up
hardware port modify 5A10 up
hardware port modify 5A11 up
hardware port modify 5A12 up
hardware port modify 5A13 up
hardware port modify 5A14 up
hardware port modify 5A15 up
hardware port modify 5A16 up
hardware port modify 5A17 up
hardware port modify 5A18 up
hardware port modify 5A19 up
hardware port modify 5A20 up
hardware port modify 5A21 up
hardware port modify 5A22 up
hardware port modify 5A23 up
hardware port modify 5A24 up
hardware port modify CTL up
# NSAP Filtering Templates
# NSAP Filtering Table
# Date and Time
# Netmod Series LE Traffic Management Configuration
hardware netmod traffic le modify 1A 6 90% 90% 64 1
hardware netmod traffic le modify 1B 6 90% 90% 64 1
hardware netmod traffic le modify 3A 6 90% 90% 64 1
hardware netmod traffic le modify 3B 6 90% 90% 64 1
hardware netmod traffic le modify 3C 6 90% 90% 64 1
# Port Series LE Traffic Management Configuration
hardware port traffic le modify 1A1 ABR 256 256
hardware port traffic le modify 1A1 nrtVBR 256 256
hardware port traffic le modify 1A1 CBR-rtVBR 256 256
hardware port traffic le modify 1A1 UBR 256 256
hardware port traffic le modify 1B1 ABR 256 256
hardware port traffic le modify 1B1 nrtVBR 256 256
hardware port traffic le modify 1B1 CBR-rtVBR 256 256
hardware port traffic le modify 1B1 UBR 256 256
hardware port traffic le modify 3A1 ABR 256 256
hardware port traffic le modify 3A1 nrtVBR 256 256
hardware port traffic le modify 3A1 CBR-rtVBR 256 256
hardware port traffic le modify 3A1 UBR 256 256
hardware port traffic le modify 3A2 ABR 256 256
hardware port traffic le modify 3A2 nrtVBR 256 256
hardware port traffic le modify 3A2 CBR-rtVBR 256 256
hardware port traffic le modify 3A2 UBR 256 256
hardware port traffic le modify 3A3 ABR 256 256
hardware port traffic le modify 3A3 nrtVBR 256 256
hardware port traffic le modify 3A3 CBR-rtVBR 256 256
hardware port traffic le modify 3A3 UBR 256 256
hardware port traffic le modify 3A4 ABR 256 256
hardware port traffic le modify 3A4 nrtVBR 256 256
hardware port traffic le modify 3A4 CBR-rtVBR 256 256
hardware port traffic le modify 3A4 UBR 256 256
hardware port traffic le modify 3B1 ABR 256 256
hardware port traffic le modify 3B1 nrtVBR 256 256
hardware port traffic le modify 3B1 CBR-rtVBR 256 256
hardware port traffic le modify 3B1 UBR 256 256
hardware port traffic le modify 3B2 ABR 256 256
hardware port traffic le modify 3B2 nrtVBR 256 256
hardware port traffic le modify 3B2 CBR-rtVBR 256 256
hardware port traffic le modify 3B2 UBR 256 256
hardware port traffic le modify 3B3 ABR 256 256
hardware port traffic le modify 3B3 nrtVBR 256 256
hardware port traffic le modify 3B3 CBR-rtVBR 256 256
hardware port traffic le modify 3B3 UBR 256 256
hardware port traffic le modify 3B4 ABR 256 256
hardware port traffic le modify 3B4 nrtVBR 256 256
hardware port traffic le modify 3B4 CBR-rtVBR 256 256
hardware port traffic le modify 3B4 UBR 256 256
hardware port traffic le modify 3C1 ABR 256 256
hardware port traffic le modify 3C1 nrtVBR 256 256
hardware port traffic le modify 3C1 CBR-rtVBR 256 256
hardware port traffic le modify 3C1 UBR 256 256
hardware port traffic le modify 3C2 ABR 256 256
hardware port traffic le modify 3C2 nrtVBR 256 256
hardware port traffic le modify 3C2 CBR-rtVBR 256 256
hardware port traffic le modify 3C2 UBR 256 256
hardware port traffic le modify 3C3 ABR 256 256
hardware port traffic le modify 3C3 nrtVBR 256 256
hardware port traffic le modify 3C3 CBR-rtVBR 256 256
hardware port traffic le modify 3C3 UBR 256 256
hardware port traffic le modify 3C4 ABR 256 256
hardware port traffic le modify 3C4 nrtVBR 256 256
hardware port traffic le modify 3C4 CBR-rtVBR 256 256
hardware port traffic le modify 3C4 UBR 256 256
# Signaling Redundancy Cross Connects Table
# Access Control Table
security login profiles new readonly DEFAULT readonly
security login profiles new readonly "hardware netmod application upgrade" none
security login profiles new readonly security none
security login profiles new readonly "system batch" none
security login profiles new readonly "system cdb" none
security login profiles new readonly "system filesystem init" none
security login profiles new readonly "system license" none
security login profiles new readonly "system startup" none
security login profiles new readonly "system upgrade" none
security login profiles new user DEFAULT all
security login profiles new user debug readonly
security login profiles new user "hardware netmod application upgrade" none
security login profiles new user security none
security login profiles new user "security login password" all
security login profiles new user "system batch" none
security login profiles new user "system cdb" none
security login profiles new user "system filesystem init" none
security login profiles new user "system license" none
security login profiles new user "system startup" none
security login profiles new user "system upgrade" none
# User Profile Table
security login new ami console password admin
security login new ami http password admin
security login new ami telnet password admin
security login new testlab console password admin
security login new testlab http password admin
security login new testlab telnet password admin
# Default Profile Table
security login defaults new securid admin
# SNMP Notifications
# Radius Protocol and Vendor Attributes
security radius attributes new 1 User-Name string
security radius attributes new 2 Password string
security radius attributes new 4 NAS-IP-Address ipaddr
security radius attributes new 5 NAS-Port-Id integer
security radius attributes new 6 Service-Type integer
security radius attributes new 26 Vendor-Specific string
# Radius Attribute Values
security radius attributes values new 6 1 Login-User
security radius attributes values new 6 6 Administrative-User
# Radius Server Configuration Table
security radius modify -primPort 1812 -secPort 1812 -numOfRetries 3
          -retryInterval 3 -remoteProfile disabled -state disabled
# SONET Configuration
hardware port sonet modify 1A1 sonet none -scrambling on -emptycells unassigned
hardware port sonet modify 1B1 sonet none -scrambling on -emptycells unassigned
hardware port sonet modify 3A1 sonet none internal on unassigned
hardware port sonet modify 3A2 sonet none internal on unassigned
hardware port sonet modify 3A3 sonet none internal on unassigned
hardware port sonet modify 3A4 sonet none internal on unassigned
hardware port sonet modify 3B1 sonet none internal on unassigned
hardware port sonet modify 3B2 sonet none internal on unassigned
hardware port sonet modify 3B3 sonet none internal on unassigned
hardware port sonet modify 3B4 sonet none internal on unassigned
hardware port sonet modify 3C1 sonet none internal on unassigned
hardware port sonet modify 3C2 sonet none internal on unassigned
hardware port sonet modify 3C3 sonet none internal on unassigned
hardware port sonet modify 3C4 sonet none internal on unassigned
# Bit Error Monitoring
hardware port sonet errors modify 1A1 random disabled -sfber -3 -sdber -5
hardware port sonet errors modify 1B1 random disabled -sfber -3 -sdber -5
hardware port sonet errors modify 3A1 random disabled -sfber -3 -sdber -5
hardware port sonet errors modify 3A2 random disabled -sfber -3 -sdber -5
hardware port sonet errors modify 3A3 random disabled -sfber -3 -sdber -5
hardware port sonet errors modify 3A4 random disabled -sfber -3 -sdber -5
hardware port sonet errors modify 3B1 random disabled -sfber -3 -sdber -5
hardware port sonet errors modify 3B2 random disabled -sfber -3 -sdber -5
hardware port sonet errors modify 3B3 random disabled -sfber -3 -sdber -5
hardware port sonet errors modify 3B4 random disabled -sfber -3 -sdber -5
hardware port sonet errors modify 3C1 random disabled -sfber -3 -sdber -5
hardware port sonet errors modify 3C2 random disabled -sfber -3 -sdber -5
hardware port sonet errors modify 3C3 random disabled -sfber -3 -sdber -5
hardware port sonet errors modify 3C4 random disabled -sfber -3 -sdber -5
# SPANS Table
# PNNI SPVx Redirection Parameters
connections spvx-pp-redirection parameters disabled 12 none disabled 12 none
# Spvx redirection table
# Source PNNI PP SPVCCs
# SPVC SPANS Destination Table
# Source SPANS SPVCCs
# PNNI SPVPC Control Parameters
connections spvpc parameters 2000 20 15000 15 75% 10 600 reroute
# Source PNNI PP SPVPCs
# ILMI Service Registry Table
# Debugging Port
debug system port mode off
# System Information
system modify "ESX-3000 CONFIG-Andy TEST2" -reservedpmpminvci 155
          -reservedpmpmaxvci 255 -protocol tftp -connectionpreservation
          enabled -atmlayeroam disabled -httphelpurl default
          -clockscalingfactor 1 -fabric_id 00:20:48:58:10:f9 -pmpenable
          enabled -utiltimeperiod 15
# Console Syslog
system syslog console enabled
# Syslog Facility
system syslog facility daemon
# Syslog Information
# AMI Inactivity Timeout
system timeout 5
# Finger Interface
security finger disabled
# Timing Configuration Options
system timing modify switchMode none none
# SNMP Trap Threshold Table
system snmp traplog threshold modify risingAlarm 1 100
system snmp traplog threshold modify fallingAlarm 1 100
system snmp traplog threshold modify entConfigChange 1 100
system snmp traplog threshold modify asxSwLinkDown 1 100
system snmp traplog threshold modify asxSwLinkUp 1 100
system snmp traplog threshold modify asxHostLinkDown 1 100
system snmp traplog threshold modify asxHostLinkUp 1 100
system snmp traplog threshold modify asxNetModuleDown 1 100
system snmp traplog threshold modify asxNetModuleUp 1 100
system snmp traplog threshold modify asxPsInputDown 1 100
system snmp traplog threshold modify asxPsInputUp 1 100
system snmp traplog threshold modify asxPsOutputDown 1 100
system snmp traplog threshold modify asxPsOutputUp 1 100
system snmp traplog threshold modify asxFanBankDown 1 100
system snmp traplog threshold modify asxFanBankUp 1 100
system snmp traplog threshold modify asxLinkDown 1 100
system snmp traplog threshold modify asxLinkUp 1 100
system snmp traplog threshold modify asxSpansDown 1 100
system snmp traplog threshold modify asxSpansUp 1 100
system snmp traplog threshold modify asxTempSensorOverTemp 1 100
system snmp traplog threshold modify asxTempSensorRegularTemp 1 100
system snmp traplog threshold modify asxFabricTemperatureOverTemp 1 100
system snmp traplog threshold modify asxFabricTemperatureRegularTemp 1 100
system snmp traplog threshold modify asxSonetLOSDetected 1 100
system snmp traplog threshold modify asxSonetLOSCleared 1 100
system snmp traplog threshold modify asxSonetPathLabelDetected 1 100
system snmp traplog threshold modify asxSonetPathLabelCleared 1 100
system snmp traplog threshold modify asxSonetLineAISDetected 1 100
system snmp traplog threshold modify asxSonetLineAISCleared 1 100
system snmp traplog threshold modify asxDS3PLCPYellowDetected 1 100
system snmp traplog threshold modify asxDS3PLCPYellowCleared 1 100
system snmp traplog threshold modify asxDS3PLCPLOFDetected 1 100
system snmp traplog threshold modify asxDS3PLCPLOFCleared 1 100
system snmp traplog threshold modify asxDS3LOFDetected 1 100
system snmp traplog threshold modify asxDS3LOFCleared 1 100
system snmp traplog threshold modify asxDS3AISDetected 1 100
system snmp traplog threshold modify asxDS3AISCleared 1 100
system snmp traplog threshold modify asxDS3PlcpBIP8Detected 1 100
system snmp traplog threshold modify asxDS3PlcpBIP8Cleared 1 100
system snmp traplog threshold modify asxDS3PlcpFEBEDetected 1 100
system snmp traplog threshold modify asxDS3PlcpFEBECleared 1 100
system snmp traplog threshold modify asxDS3FramingFEBEDetected 1 100
system snmp traplog threshold modify asxDS3FramingFEBECleared 1 100
system snmp traplog threshold modify asxDS1PLCPYellowDetected 1 100
system snmp traplog threshold modify asxDS1PLCPYellowCleared 1 100
system snmp traplog threshold modify asxDS1PLCPLOFDetected 1 100
system snmp traplog threshold modify asxDS1PLCPLOFCleared 1 100
system snmp traplog threshold modify asxDS1YellowDetected 1 100
system snmp traplog threshold modify asxDS1YellowCleared 1 100
system snmp traplog threshold modify asxDS1AISDetected 1 100
system snmp traplog threshold modify asxDS1AISCleared 1 100
system snmp traplog threshold modify asxDS1LOSDetected 1 100
system snmp traplog threshold modify asxDS1LOSCleared 1 100
system snmp traplog threshold modify asxDS1LOFDetected 1 100
system snmp traplog threshold modify asxDS1LOFCleared 1 100
system snmp traplog threshold modify asxDS3FERFDetected 1 100
system snmp traplog threshold modify asxDS3FERFCleared 1 100
system snmp traplog threshold modify asxE3YellowDetected 1 100
system snmp traplog threshold modify asxE3YellowCleared 1 100
system snmp traplog threshold modify asxE3OOFDetected 1 100
system snmp traplog threshold modify asxE3OOFCleared 1 100
system snmp traplog threshold modify asxE3AtmLCDDetected 1 100
system snmp traplog threshold modify asxE3AtmLCDCleared 1 100
system snmp traplog threshold modify asxE3PLCPYellowDetected 1 100
system snmp traplog threshold modify asxE3PLCPYellowCleared 1 100
system snmp traplog threshold modify asxE1YellowDetected 1 100
system snmp traplog threshold modify asxE1YellowCleared 1 100
system snmp traplog threshold modify asxE1LOFDetected 1 100
system snmp traplog threshold modify asxE1LOFCleared 1 100
system snmp traplog threshold modify asxE1PLCPYellowDetected 1 100
system snmp traplog threshold modify asxE1PLCPYellowCleared 1 100
system snmp traplog threshold modify asxE1PLCPLOFDetected 1 100
system snmp traplog threshold modify asxE1PLCPLOFCleared 1 100
system snmp traplog threshold modify asxE1LOSDetected 1 100
system snmp traplog threshold modify asxE1LOSCleared 1 100
system snmp traplog threshold modify asxE1AISDetected 1 100
system snmp traplog threshold modify asxE1AISCleared 1 100
system snmp traplog threshold modify asxE3AISDetected 1 100
system snmp traplog threshold modify asxE3AISCleared 1 100
system snmp traplog threshold modify asxE3LOSDetected 1 100
system snmp traplog threshold modify asxE3LOSCleared 1 100
system snmp traplog threshold modify asxE3PLCPLOFDetected 1 100
system snmp traplog threshold modify asxE3PLCPLOFCleared 1 100
system snmp traplog threshold modify asxJ2YellowDetected 1 100
system snmp traplog threshold modify asxJ2YellowCleared 1 100
system snmp traplog threshold modify asxJ2AISDetected 1 100
system snmp traplog threshold modify asxJ2AISCleared 1 100
system snmp traplog threshold modify asxJ2LOSDetected 1 100
system snmp traplog threshold modify asxJ2LOSCleared 1 100
system snmp traplog threshold modify asxJ2LOFDetected 1 100
system snmp traplog threshold modify asxJ2LOFCleared 1 100
system snmp traplog threshold modify asxDS3LOSDetected 1 100
system snmp traplog threshold modify asxDS3LOSCleared 1 100
system snmp traplog threshold modify asxSonetLOFDetected 1 100
system snmp traplog threshold modify asxSonetLOFCleared 1 100
system snmp traplog threshold modify asxSonetLineRDIDetected 1 100
system snmp traplog threshold modify asxSonetLineRDICleared 1 100
system snmp traplog threshold modify asxSonetPathAISDetected 1 100
system snmp traplog threshold modify asxSonetPathAISCleared 1 100
system snmp traplog threshold modify asxSonetPathLOPDetected 1 100
system snmp traplog threshold modify asxSonetPathLOPCleared 1 100
system snmp traplog threshold modify asxSonetPathUNEQDetected 1 100
system snmp traplog threshold modify asxSonetPathUNEQCleared 1 100
system snmp traplog threshold modify asxSonetPathRDIDetected 1 100
system snmp traplog threshold modify asxSonetPathRDICleared 1 100
system snmp traplog threshold modify asxSonetAtmLCDDetected 1 100
system snmp traplog threshold modify asxSonetAtmLCDCleared 1 100
system snmp traplog threshold modify asxSonetAtmLineBIPDetected 1 100
system snmp traplog threshold modify asxSonetAtmLineBIPCleared 1 100
system snmp traplog threshold modify asxDS3IdleDetected 1 100
system snmp traplog threshold modify asxDS3IdleCleared 1 100
system snmp traplog threshold modify asxDS3AtmLCDDetected 1 100
system snmp traplog threshold modify asxDS3AtmLCDCleared 1 100
system snmp traplog threshold modify asxDS3PbitPerrDetected 1 100
system snmp traplog threshold modify asxDS3PbitPerrCleared 1 100
system snmp traplog threshold modify asxDS1PRBSDetected 1 100
system snmp traplog threshold modify asxDS1PRBSCleared 1 100
system snmp traplog threshold modify asxDS1AtmLCDDetected 1 100
system snmp traplog threshold modify asxDS1AtmLCDCleared 1 100
system snmp traplog threshold modify asxDS1CRCErrDetected 1 100
system snmp traplog threshold modify asxDS1CRCErrCleared 1 100
system snmp traplog threshold modify asxE3TrailChangeDetected 1 100
system snmp traplog threshold modify asxE3PlcpBIP8Detected 1 100
system snmp traplog threshold modify asxE3PlcpBIP8Cleared 1 100
system snmp traplog threshold modify asxE3PlcpFEBEDetected 1 100
system snmp traplog threshold modify asxE3PlcpFEBECleared 1 100
system snmp traplog threshold modify asxE3FramingFEBEDetected 1 100
system snmp traplog threshold modify asxE3FramingFEBECleared 1 100
system snmp traplog threshold modify asxE3FramingBIP8Detected 1 100
system snmp traplog threshold modify asxE3FramingBIP8Cleared 1 100
system snmp traplog threshold modify asxE1AtmLCDDetected 1 100
system snmp traplog threshold modify asxE1AtmLCDCleared 1 100
system snmp traplog threshold modify asxJ2RLOCDetected 1 100
system snmp traplog threshold modify asxJ2RLOCCleared 1 100
system snmp traplog threshold modify asxJ2HBERDetected 1 100
system snmp traplog threshold modify asxJ2HBERCleared 1 100
system snmp traplog threshold modify asxJ2PAISDetected 1 100
system snmp traplog threshold modify asxJ2PAISCleared 1 100
system snmp traplog threshold modify asxJ2AtmLCDDetected 1 100
system snmp traplog threshold modify asxJ2AtmLCDCleared 1 100
system snmp traplog threshold modify asxJ2TLOCDetected 1 100
system snmp traplog threshold modify asxJ2TLOCCleared 1 100
system snmp traplog threshold modify asxTP25LOSDetected 1 100
system snmp traplog threshold modify asxTP25LOSCleared 1 100
system snmp traplog threshold modify asxOutputQueueCongested 1 100
system snmp traplog threshold modify asxOutputQueueCellLoss 1 100
system snmp traplog threshold modify asxExtendedModeViolation 1 100
system snmp traplog threshold modify asxNonextendedModeWarning 1 100
system snmp traplog threshold modify crConfMemoryOflow 1 100
system snmp traplog threshold modify crXfrPrimaryXfrFailed 1 100
system snmp traplog threshold modify crXfrSecondaryXfrFailed 1 100
system snmp traplog threshold modify crConfMemAllocFail 1 100
system snmp traplog threshold modify crGeneralFailure 1 100
system snmp traplog threshold modify asxVPAISDetected 1 100
system snmp traplog threshold modify asxVPAISCleared 1 100
system snmp traplog threshold modify asxVPRDIDetected 1 100
system snmp traplog threshold modify asxVPRDICleared 1 100
system snmp traplog threshold modify asxNonextendedModeViolation 1 100
system snmp traplog threshold modify asxUnsupportedNetworkModule 1 100
system snmp traplog threshold modify asxIpFilterViolation 1 100
system snmp traplog threshold modify q2931AFRejectKnown 1 100
system snmp traplog threshold modify q2931AFRejectUnknown 1 100
system snmp traplog threshold modify q2931CreationFailure 1 100
system snmp traplog threshold modify asxPsCurrentDown 1 100
system snmp traplog threshold modify asxPsCurrentUp 1 100
system snmp traplog threshold modify asxPs5VoltDown 1 100
system snmp traplog threshold modify asxPs5VoltUp 1 100
system snmp traplog threshold modify asxSwitchLoginDetected 1 100
system snmp traplog threshold modify asxSwitchLoginFailed 1 100
system snmp traplog threshold modify pnniTdbGuardbandResrvFail 1 100
system snmp traplog threshold modify pnniTdbInconsistentState 1 100
system snmp traplog threshold modify asxShmem2OutputQueueCongested 1 100
system snmp traplog threshold modify asxShmem2OutputQueueCellLoss 1 100
system snmp traplog threshold modify fabricLvl3Lookup 1 100
system snmp traplog threshold modify fabricCorrectedLookup 1 100
system snmp traplog threshold modify spvcRerouteInitiated 1 100
system snmp traplog threshold modify asxQ2931Down 1 100
system snmp traplog threshold modify asxQ2931Up 1 100
system snmp traplog threshold modify asxFabricDown 1 100
system snmp traplog threshold modify asxFabricUp 1 100
system snmp traplog threshold modify asxQ2931CallClearing 1 100
system snmp traplog threshold modify pnniSpvccDown 1 100
system snmp traplog threshold modify pnniSpvccUp 1 100
system snmp traplog threshold modify pnniSpvccFail 1 100
system snmp traplog threshold modify pnniSpvpcDown 1 100
system snmp traplog threshold modify pnniSpvpcUp 1 100
system snmp traplog threshold modify pnniSpvpcFail 1 100
system snmp traplog threshold modify asxPortCardDown 1 100
system snmp traplog threshold modify asxPortCardUp 1 100
system snmp traplog threshold modify asxServiceCategoryOutputQueueCongested 1
          100
system snmp traplog threshold modify asxServiceCategoryOutputQueueCellLoss 1
          100
system snmp traplog threshold modify pnniNormalToOverloadTransition 1 100
system snmp traplog threshold modify pnniOverloadToNormalTransition 1 100
system snmp traplog threshold modify pnniPmpRerouteInitiated 1 100
system snmp traplog threshold modify pnniPmpSpvcUp 1 100
system snmp traplog threshold modify pnniPmpSpvcDown 1 100
system snmp traplog threshold modify pnniPmpSpvcFail 1 100
system snmp traplog threshold modify pnniSpvxRGroupSwover 1 100
system snmp traplog threshold modify asxSVXCPStateDroppedCall 1 100
system snmp traplog threshold modify pnniSpvccRedirectionSwover 1 100
system snmp traplog threshold modify pnniSpvpcRedirectionSwover 1 100
system snmp traplog threshold modify pnniSpvccRedirectionSwoverFailure 1 100
system snmp traplog threshold modify pnniSpvpcRedirectionSwoverFailure 1 100
system snmp traplog threshold modify coldStart 1 100
system snmp traplog threshold modify warmStart 1 100
system snmp traplog threshold modify linkDown 1 100
system snmp traplog threshold modify linkUp 1 100
system snmp traplog threshold modify authenticationFailure 1 100
system snmp traplog threshold modify foreTcLCDDetected 1 100
system snmp traplog threshold modify foreTcLCDCleared 1 100
system snmp traplog threshold modify forePlcpYellowDetected 1 100
system snmp traplog threshold modify forePlcpYellowCleared 1 100
system snmp traplog threshold modify forePlcpLOFDetected 1 100
system snmp traplog threshold modify forePlcpLOFCleared 1 100
system snmp traplog threshold modify syncStatusMsgChanged 1 100
system snmp traplog threshold modify atmTraceConnCompletion 1 100
# Frame UPC Contracts
# X.509 Distinguished Name Configuration
# Call Records Memory
services callrecords memory config rejectCall 128 0 20 0
# Call Records Filter Table
# Call Recording Billing Point
# Call Records Transfer Table
# Performance Monitoring Transfer Table
# ethernet Autonegotiation Data
hardware port ethernet auto-negotiation modify 5A1 auto
hardware port ethernet auto-negotiation modify 5A2 auto
hardware port ethernet auto-negotiation modify 5A3 auto
hardware port ethernet auto-negotiation modify 5A4 auto
hardware port ethernet auto-negotiation modify 5A5 auto
hardware port ethernet auto-negotiation modify 5A6 auto
hardware port ethernet auto-negotiation modify 5A7 auto
hardware port ethernet auto-negotiation modify 5A8 auto
hardware port ethernet auto-negotiation modify 5A9 auto
hardware port ethernet auto-negotiation modify 5A10 auto
hardware port ethernet auto-negotiation modify 5A11 auto
hardware port ethernet auto-negotiation modify 5A12 auto
hardware port ethernet auto-negotiation modify 5A13 auto
hardware port ethernet auto-negotiation modify 5A14 auto
hardware port ethernet auto-negotiation modify 5A15 auto
hardware port ethernet auto-negotiation modify 5A16 auto
hardware port ethernet auto-negotiation modify 5A17 auto
hardware port ethernet auto-negotiation modify 5A18 auto
hardware port ethernet auto-negotiation modify 5A19 auto
hardware port ethernet auto-negotiation modify 5A20 auto
hardware port ethernet auto-negotiation modify 5A21 auto
hardware port ethernet auto-negotiation modify 5A22 auto
hardware port ethernet auto-negotiation modify 5A23 auto
hardware port ethernet auto-negotiation modify 5A24 auto
# VLAN Configuration
ethernet vlan new default " 5A1   5A2   5A3   5A4   5A5   5A6   5A7   5A8
          5A9   5A10  5A11  5A12  5A13  5A14  5A15  5A16  5A17  5A18  5A19
          5A20  5A21  5A22  5A23  5A24"
# Bridge Parameters
ethernet bridge modify default 3600 disabled enabled
# Bridge STP Parameters Status
# Bridge Port Parameters Configuration
# Ethernet Statistics Table
# RMON History Control Table
# PortCard Table
hardware portcard modify 1 up
hardware portcard modify 3 up
hardware portcard modify 5 up
#
#
#
#



END


$responsesATM->{'if_show'} = <<'END';



File transfer was successful




ESX-3000-2 CONFIG-A:-> interfaces if show

Index      Name         Type               Speed Admin Oper Description



1          lo0          swLoopback      10000000 up    up   lo0



2          asx0         otherIfType     80000000 down  down asx0



3          qaa0         ipOverAtm       80000000 down  down qaa0



4          qaa1         ipOverAtm       80000000 down  down qaa1



5          qaa2         ipOverAtm       80000000 down  down qaa2



6          qaa3         ipOverAtm       80000000 down  down qaa3



7          ie0          etherCsmacd     10000000 up    up   ie0



33554440   1A1          atm            599039920 up    down Atm Interface



34603016   1B1          atm            599039920 up    down Atm Interface



100663304  3A1          atm            149759768 up    down Atm Interface



100663312  3A2          atm            149759768 up    down Atm Interface



100663320  3A3          atm            149759768 up    down Atm Interface



100663328  3A4          atm            149759768 up    down Atm Interface



101711880  3B1          atm            149759768 up    down Atm Interface



101711888  3B2          atm            149759768 up    down Atm Interface



101711896  3B3          atm            149759768 up    down Atm Interface



101711904  3B4          atm            149759768 up    down Atm Interface



102760456  3C1          atm            149759768 up    down Atm Interface



102760464  3C2          atm            149759768 up    down Atm Interface



102760472  3C3          atm            149759768 up    down Atm Interface



102760480  3C4          atm            149759768 up    down Atm Interface



167772168  5A1          isoCsmacd       10000000 up    down Ethernet Interface



167772176  5A2          isoCsmacd       10000000 up    down Ethernet Interface



167772184  5A3          isoCsmacd       10000000 up    down Ethernet Interface



167772192  5A4          isoCsmacd       10000000 up    down Ethernet Interface



167772200  5A5          isoCsmacd       10000000 up    down Ethernet Interface



167772208  5A6          isoCsmacd       10000000 up    down Ethernet Interface



167772216  5A7          isoCsmacd       10000000 up    down Ethernet Interface



167772224  5A8          isoCsmacd       10000000 up    down Ethernet Interface



167772232  5A9          isoCsmacd       10000000 up    down Ethernet Interface



167772240  5A10         isoCsmacd       10000000 up    down Ethernet Interface



167772248  5A11         isoCsmacd       10000000 up    down Ethernet Interface



167772256  5A12         isoCsmacd       10000000 up    down Ethernet Interface



167772264  5A13         isoCsmacd       10000000 up    down Ethernet Interface



167772272  5A14         isoCsmacd       10000000 up    down Ethernet Interface



167772280  5A15         isoCsmacd       10000000 up    down Ethernet Interface



167772288  5A16         isoCsmacd       10000000 up    down Ethernet Interface



167772296  5A17         isoCsmacd       10000000 up    down Ethernet Interface



167772304  5A18         isoCsmacd       10000000 up    down Ethernet Interface



167772312  5A19         isoCsmacd       10000000 up    down Ethernet Interface



167772320  5A20         isoCsmacd       10000000 up    down Ethernet Interface



167772328  5A21         isoCsmacd       10000000 up    down Ethernet Interface



167772336  5A22         isoCsmacd       10000000 up    down Ethernet Interface



167772344  5A23         isoCsmacd       10000000 up    down Ethernet Interface



167772352  5A24         isoCsmacd       10000000 up    down Ethernet Interface



168820728  5ACTL        atm            832999728 up    up   Atm Interface



1073741824 CTL          atm             79996080 up    up   Atm Interface



1073741825 default      aflane8023     652214272 up    up   LEC Interface





ESX-3000-2 CONFIG-A:-> 

END


$responsesATM->{'ip_show'} = <<'END';
interfaces ip show

Interface  State  Address         Netmask         Broadcast     (Setting)  MTU



lo0        up     127.0.0.1       255.0.0.0       N/A             N/A    32768



asx0       down   N/A             N/A             N/A             N/A      N/A



qaa0       down   N/A             N/A             N/A             N/A      N/A



qaa1       down   N/A             N/A             N/A             N/A      N/A



qaa2       down   N/A             N/A             N/A             N/A      N/A



qaa3       down   N/A             N/A             N/A             N/A      N/A



ie0        up     10.100.17.2     255.255.255.0   10.100.17.255     1     1500





ESX-3000-2 CONFIG-A:-> 

END


$responsesATM->{'auto_neg'} = <<'END';
hardware port ethernet auto-negotiation show

                                         Remote        Remote     Link



         Config.     Operation   Link    AutoNeg.      Operation  Transition



PortId   Mode        State       Status  State         State      Count



5A1      auto        10/Half     down    not-detected  N/A        0



5A2      auto        10/Half     down    not-detected  N/A        0



5A3      auto        10/Half     down    not-detected  N/A        0



5A4      auto        10/Half     down    not-detected  N/A        0



5A5      auto        10/Half     down    not-detected  N/A        0



5A6      auto        10/Half     down    not-detected  N/A        0



5A7      auto        10/Half     down    not-detected  N/A        0



5A8      auto        10/Half     down    not-detected  N/A        0



5A9      auto        10/Half     down    not-detected  N/A        0



5A10     auto        10/Half     down    not-detected  N/A        0



5A11     auto        10/Half     down    not-detected  N/A        0



5A12     auto        10/Half     down    not-detected  N/A        0



5A13     auto        10/Half     down    not-detected  N/A        0



5A14     auto        10/Half     down    not-detected  N/A        0



5A15     auto        10/Half     down    not-detected  N/A        0



5A16     auto        10/Half     down    not-detected  N/A        0



5A17     auto        10/Half     down    not-detected  N/A        0



5A18     auto        10/Half     down    not-detected  N/A        0



5A19     auto        10/Half     down    not-detected  N/A        0



5A20     auto        10/Half     down    not-detected  N/A        0



5A21     auto        10/Half     down    not-detected  N/A        0



5A22     auto        10/Half     down    not-detected  N/A        0



5A23     auto        10/Half     down    not-detected  N/A        0



5A24     auto        10/Half     down    not-detected  N/A        0





ESX-3000-2 CONFIG-A:-> 

END


$responsesATM->{'stp'} = <<'END';
ethernet bridge stp configuration show

VLAN Name    STP Priority  Max Age  Hello Time  Hold Time  Forward Delay



default               N/A      N/A         N/A        N/A            N/A





ESX-3000-2 CONFIG-A:-> 

END


$responsesATM->{'bridge'} = <<'END';
ethernet bridge show

VLAN Name   STP        MAC       #Ports  Bridge   Aging Time  IGMP



                       Address           Type                 Snooping



default     disabled   00:20:48:     24  transpar       3600  enabled



                       66:80:b6          entOnly





ESX-3000-2 CONFIG-A:-> 

END


$responsesATM->{'routes'} = <<'END';
interfaces ip route show

Destination      Gateway             Metric  Interface  Flags



default          10.100.17.1         1       ie0        G



10.100.17.0      10.100.17.2         0       ie0



127.0.0.0        127.0.0.1           0       lo0



127.0.0.1        127.0.0.1           0       lo0





ESX-3000-2 CONFIG-A:-> 

END


$responsesATM->{'vlans'} = <<'END';
ethernet vlan show

Name                Ports



default             5A1   5A2   5A3   5A4   5A5   5A6   5A7   5A8   5A9



                    5A10  5A11  5A12  5A13  5A14  5A15  5A16  5A17  5A18



                    5A19  5A20  5A21  5A22  5A23  5A24





ESX-3000-2 CONFIG-A:-> 

END


