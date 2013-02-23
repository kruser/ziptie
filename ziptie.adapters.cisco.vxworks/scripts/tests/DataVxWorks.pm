package DataVxWorks;

use strict;
use warnings;
use Exporter 'import';
our @EXPORT_OK = qw($responsesVxWorks);

our $responsesVxWorks = {};

$responsesVxWorks->{home} = <<'END';
<html>

<head>

<title>Aironet_340 Summary Status</title>

<script LANGUAGE="JavaScript">

<!--



function verifyBrowser() {

var ms = navigator.appVersion.indexOf("MSIE");

ie4 = (ms>0) && (parseInt(navigator.appVersion.substring(ms+5, ms+6)) >= 4);

var ns = navigator.appName.indexOf("Netscape");

ns= (ns>=0) && (parseInt(navigator.appVersion.substring(0,1))>=4);



if (ie4)

return "ie4";

else

if(ns)

return "ns";

else

return false;

}



function addSearchString(inString, appString) {

return (inString.indexOf("?",0)<0)? inString+"?"+appString: inString+"&"+appString;

}



function goMap(newHref) {

var newHref = "map.shm";



if (verifyBrowser() == "ns") {

newHref=addSearchString(newHref, "bv=ns");

}



var newWindow = window.open("", "00409637e8d0Map", "width=350,height=400,resizable=1,scrollbars=1,dependent=0");



if(newWindow.document.title.length== 0){

  newWindow = window.open(newHref, "00409637e8d0Map", "width=350,height=400,resizable=1,scrollbars=1,dependent=0"); 

}



if(newWindow != null && !newWindow.closed ){

  newWindow.focus();

}



}

// -->

</script>



</head>



<body bgcolor="#FFFFFF" leftmargin="4" Text="black" LINK="black" ALINK="black" VLINK="black">

<div align="left">



<table border="0" cellspacing="1" align="left" width="600">

<tr>

<td nowrap><big><strong>Aironet_340</strong></big><font

color="#FF0000"><big><big><strong>&nbsp;&nbsp;&nbsp;Summary&nbsp;Status</strong></big></big></td>

<td valign="top" align="left" rowspan="2"><p align="right"><a href="http://www.cisco.com"><img

alt="Cisco's Homepage" src="CiscoLogo.jpg" border="0"></a></td>

</tr>

<tr>

<td nowrap><strong><font color="#FF0000"><small>Cisco AP340 11.21</small></font></strong></td>

</tr>

<tr>

<td style="border-bottom:" valign="top"><table border="0" width="100%" cellspacing="1" cellpadding="0"><tr>

<td style="border-left: 2 solid rgb(128,128,128); border-right: 0 none; border-top: 2 solid rgb(128,128,128); border-bottom: 0 none"

bgcolor="#C0C0C0" align="center"><p align="center"><strong><small><font color="#000000">Home</font></small></strong></td>

<td style="border-left: none; border-right: 2 solid rgb(128,128,128); border-top: none; border-bottom: 2 solid rgb(128,128,128)"

bgcolor="#C0C0C0" align="center"><p align="center"><strong><small><a href="JavaScript: goMap()"><font color="#000000">Map</font></a></small></strong></td>



<td style="border-left: none; border-right: 2 solid rgb(128,128,128); border-top: none; border-bottom: 2 solid rgb(128,128,128)"

bgcolor="#C0C0C0" align="center"><p align="center"><strong><small><a href="/StatsAllNetIf.shm"><font color="#000000">Network</font></a></small></strong></td>



<td style="border-left: none; border-right: 2 solid rgb(128,128,128); border-top: none; border-bottom: 2 solid rgb(128,128,128)"

bgcolor="#C0C0C0" align="center"><p align="center"><strong><small><a href="/ShowAssociations.shm"><font color="#000000">Associations</font></a></small></strong></td>



<td style="border-left: none; border-right: 2 solid rgb(128,128,128); border-top: none; border-bottom: 2 solid rgb(128,128,128)"

bgcolor="#C0C0C0" align="center"><p align="center"><strong><small><a href="/Setup.shm"><font color="#000000">Setup</font></a></small></strong></td>



<td style="border-left: none; border-right: 2 solid rgb(128,128,128); border-top: none; border-bottom: 2 solid rgb(128,128,128)"

bgcolor="#C0C0C0" align="center"><p align="center"><strong><small><a href="/ShowEvents.shm"><font color="#000000">Logs</font></a></small></strong></td>



<td style="border-left: none; border-right: 2 solid rgb(128,128,128); border-top: none; border-bottom: 2 solid rgb(128,128,128)"

bgcolor="#C0C0C0" align="center"><p align="center"><strong><small><a href="http://www.cisco.com/warp/public/779/smbiz/prodconfig/help/eag/air/ap3xx/index.shm.htm" target="00409637e8d0Help"><font color="#000000">Help</font></a></small></strong></td>



</tr></table>

</td>

<td valign="middle"><p align="center"><small>Uptime: 1 day, 01:38:29</small></td>

</tr>

<tr>

<td style="border-bottom:" valign="bottom" colspan="2" align="left"><div align="left"><table

border="1" width="595" cellpadding="2" cellspacing="0">

<tr>

<td width="100%" align="center" colspan="4" bgcolor="#FFFFBD"><a

href="/ShowAssociations.shm"><font face="helvetica,arial"><strong>Current Associations</strong></font></a></td>

</tr>

<tr>

<td width="28%" align="center" valign="bottom"><strong><a href="/ShowAssociations.shm?class5=1&class7=0&class6=0&class8=0&class3=0&class2=0&showAllNetwork=0">Clients: 0</a>

of <a href="/ShowAssociations.shm?class5=1&class7=0&class6=0&class8=0&class3=0&class2=0&showAllNetwork=1">0</a></strong></td>

<td width="28%" align="center"><strong><a href="/ShowAssociations.shm?class5=0&class7=1&class6=0&class8=0&class3=0&class2=0&showAllNetwork=0">Repeaters: 0</a>

of <a href="/ShowAssociations.shm?class5=0&class7=1&class6=0&class8=0&class3=0&class2=0&showAllNetwork=1">0</a></strong></td>

<td width="28%" align="center"><strong><a href="/ShowAssociations.shm?class5=0&class7=0&class6=1&class8=0&class3=0&class2=0&showAllNetwork=0">Bridges: 0</a>

of <a href="/ShowAssociations.shm?class5=0&class7=0&class6=1&class8=0&class3=0&class2=0&showAllNetwork=1">0</a></strong></td>

<td width="16%" align="center"><a href="/ShowAssociations.shm?class5=0&class7=0&class6=0&class8=1&class3=0&class2=0&showAllNetwork=1"><strong>APs: 1</strong></a></td>

</tr>

</table>

</div></td>

</tr>

<tr>

<td style="border-bottom:" valign="bottom" colspan="2" align="left"><table border="1"

width="595" cellpadding="2" cellspacing="0">

<tr>

<td colspan="3" bgcolor="#FFFFBD" align="center"><a href="/ShowEvents.shm"><font face="helvetica,arial"><strong>Recent Events</strong></font></a></td>

</tr>

<tr>

<td align="center"><strong>Time</strong></td>

<td align="center"><strong><a href="ShowEventsSummary.shm">Severity</a></strong></td>

<td align="center"><strong>Description</strong></td>

</tr>



</table>

</td>

</tr>

<tr>

<td style="border-bottom:" valign="bottom" colspan="2" align="left"><table border="1"

width="595" cellpadding="2" cellspacing="0">

<tr><td colspan="5"><table border="0" cellpadding="2" cellspacing="0" width="100%">

<tr>

<td bgcolor="#FFFFBD" width="25%">&nbsp;</td>

<td bgcolor="#FFFFBD" align="center" width="50%"><a href="/StatsAllNetIf.shm"><font face="helvetica,arial"><strong>Network Ports</strong></font></a></td>

<td align="right" bgcolor="#FFFFBD" width="25%"><em><a href="/SetNetworkDiagnostics.shm">Diagnostics</a></em>&nbsp;&nbsp;</td></tr>

</table></td></tr>

<tr>

<th width="20%" align="center"><strong>Device</strong></th>

<th width="20%" align="center"><strong>Status</strong></th>

<th width="20%" align="center"><strong>Mb/s</strong></th>

<th width="20%" align="center"><strong>IP Addr.</strong></th>

<th width="20%" align="center"><strong>MAC Addr.</strong></th>

</tr>

<tr>
<td align="center"><a href="/StatsEthernet.shm?ifIndex=1">Ethernet</a></td><td align="center"><font color="green">Up</font></td><td align="center">100.0</td><td align="center">10.100.1.2</td><td align="center"><tt>00409637e8d0</tt></td>
</tr>
<tr>
<td align="center"><a href="/StatsPC4800.shm?ifIndex=2">AP&nbsp;Radio</a></td><td align="center"><font color="green">Up</font></td><td align="center">11.0</td><td align="center">10.100.1.2</td><td align="center"><tt>00409637e8d0</tt></td>
</tr>


</table>

</td>

</tr>

<tr>

<td valign="middle" colspan="2"><table border="0" width="100%" cellspacing="0" cellpadding="0">

<tr>

<td align="center"><table border="0" width="100%">

<tr>

<td width="100%" colspan="3" align="center"><hr color="#6AB5FF">

<small>[Home][<a

href="JavaScript: goMap()">Map</a>][<a

href="/login.shm">Login</a>][<a

href="/StatsAllNetIf.shm">Network</a>][<a

href="/ShowAssociations.shm">Associations</a>]<a

href="/Setup.shm">[Setup</a>][<a

href="/ShowEvents.shm">Logs</a>][<a

href="http://www.cisco.com/warp/public/779/smbiz/prodconfig/help/eag/air/ap3xx/index.shm.htm" target="00409637e8d0Help" target="00409637e8d0Help">Help</a>]</small></td>

</tr>

<tr><td nowrap><small><small>Cisco AP340 11.21</small></small></td>

<td nowrap><font color="#3f3f3f" size="-2">® Copyright 2001 <a

href="http://www.cisco.com">Cisco Systems, Inc.</a></font></td>

<td align="right"><a href="/CiscoLegal.shm"><small><em>credits</em></small></a></td></tr>



</table>

</td>

</tr>

</table>

</td>

</tr>

</table>

</div>

</body>

</html>



END

$responsesVxWorks->{snmp} = <<'END';
<html>

<head>

<title>Aironet_340 SNMP Setup</title>

<script LANGUAGE="JavaScript">

<!--



function verifyBrowser() {

var ms = navigator.appVersion.indexOf("MSIE");

ie4 = (ms>0) && (parseInt(navigator.appVersion.substring(ms+5, ms+6)) >= 4);

var ns = navigator.appName.indexOf("Netscape");

ns= (ns>=0) && (parseInt(navigator.appVersion.substring(0,1))>=4);



if (ie4)

return "ie4";

else

if(ns)

return "ns";

else

return false;

}



function addSearchString(inString, appString) {

return (inString.indexOf("?",0)<0)? inString+"?"+appString: inString+"&"+appString;

}



function goMap(newHref) {

var newHref = "map.shm";



if (verifyBrowser() == "ns") {

newHref=addSearchString(newHref, "bv=ns");

}



var newWindow = window.open("", "00409637e8d0Map", "width=350,height=400,resizable=1,scrollbars=1,dependent=0");



if(newWindow.document.title.length== 0){

  newWindow = window.open(newHref, "00409637e8d0Map", "width=350,height=400,resizable=1,scrollbars=1,dependent=0"); 

}



if(newWindow != null && !newWindow.closed ){

  newWindow.focus();

}



}

// -->

</script>



<script LANGUAGE="JavaScript">

<!--

function doSubmit(whichButton) {

if (whichButton == "Apply" || whichButton == "OK") {

  return confirm("The settings shown on this page will be now be updated.\nClick 'OK' to approve.");

} else if (whichButton == "Restore") {

  return confirm("You have requested that ALL settings on this page be reverted to their Factory Defaults!\nAre you SURE you wish to do this?");

} else {

return true;

}

}

// -->

</script>



</head>



<body bgcolor="#FFFFFF" leftmargin="4" Text="black" LINK="black" ALINK="black" VLINK="black">

<div align="left">



<table border="0" cellspacing="1" align="left" width="600">

<tr>

<td nowrap><big><strong>Aironet_340</strong></big><font

color="#FF0000"><big><big><strong>&nbsp;&nbsp;&nbsp;SNMP&nbsp;Setup</strong></big></big></font></td>

<td valign="top" align="left" rowspan="2"><p align="right"><a href="http://www.cisco.com"><img

alt="Cisco's Homepage" src="CiscoLogo.jpg" border="0"></a></td>

</tr>

<tr>

<td nowrap><strong><font color="#FF0000"><small>Cisco AP340 11.21</small></font></strong></td>

</tr>

<tr>

<td style="border-bottom:" valign="top">

<table border="0" cellspacing="1" cellpadding="0"><tr>

<td style="border-left: none; border-right: 2 solid rgb(128,128,128); border-top: none; border-bottom: 2 solid rgb(128,128,128)"

bgcolor="#C0C0C0" align="center"><p align="center"><strong>&nbsp;&nbsp;<a href="JavaScript: goMap()"><small><font color="#000000">Map</font></small></a>&nbsp;&nbsp;</strong></td>

<td style="border-left: none; border-right: 2 solid rgb(128,128,128); border-top: none; border-bottom: 2 solid rgb(128,128,128)"

bgcolor="#C0C0C0" align="center"><p align="center"><strong><small>&nbsp;&nbsp;<a href="http://www.cisco.com/warp/public/779/smbiz/prodconfig/help/eag/air/ap3xx/SetSNMP.shm.htm" target="00409637e8d0Help"><font color="#000000">Help</font></a>&nbsp;&nbsp;</small></strong></td>

</tr></table>



</td>

<td valign="middle"><p align="center"><small>Uptime: 1 day, 01:38:30</small></td>

</tr>

<tr>

<td style="border-bottom:" valign="top" colspan="2"><form method="POST"

action="/cgi-bin/cgiSetupNav?NoScript=&RefererList=">

<table

border="0" cellpadding="0" cellspacing="0" width="100%" bgcolor="#FFFFBD">

<tr>

<td nowrap colspan="2" height="40">Simple Network Management Protocol (SNMP):&nbsp;&nbsp;<input type="radio" value="true" checked name="radio_enableSNMP">Enabled&nbsp;&nbsp;<input type="radio" value="false"  name="radio_enableSNMP">Disabled</td></tr>

<tr>

<td nowrap>System Description:</td>

<td nowrap>Cisco AP340 11.21</td>

</tr>

<tr>

<td nowrap>System Name:</td>

<td><input type="text" value="Aironet_340" name="text_sysName" size="32"></td>

</tr>

<tr>

<td nowrap>System Location:</td>

<td><input type="text" value="Austin, Texas" name="text_sysLocation" size="32"></td>

</tr>

<tr>

<td nowrap>System Contact:</td>

<td><input type="text" value="Brent Mills" name="text_sysContact" size="32"></td>

</tr>

<tr><td colspan="2">&nbsp;</td></tr>

<tr>

<td nowrap>SNMP Trap Destination:</td>

<td><input type="text" value="10.10.1.62" name="text_snmpTrapDest" size="32"></td>

</tr>

<tr>

<td nowrap>SNMP Trap Community:</td>

<td><input type="text" value="public" name="text_snmpTrapCommunity" size="32"></td>

</tr>

<tr><td colspan="2">&nbsp;</td></tr>

<tr>

<td nowrap colspan="2"><font FACE="Arial" SIZE="2"><a href="/QueryDB.shm">Browse

Management Information Base (MIB)</a></font></td>

</tr>

<tr><td colspan="2">&nbsp;</td></tr>

<tr><td width="100%" align="right" colspan="2" valign="bottom" nowrap height="45"><input

type="submit" value="Apply" name="Apply" onClick="return doSubmit('Apply')"><input

type="submit" value="&nbsp;&nbsp;OK&nbsp;&nbsp;" name="OK" onClick="return doSubmit('OK')">&nbsp;&nbsp;<input

type="submit" value="Cancel" name="Cancel">&nbsp;&nbsp;<input

type="submit" value="Restore Defaults" name="Restore" onClick="return doSubmit('Restore')"></td></tr>



</table>

</form>

</td>

</tr>

<tr>

<td valign="middle" colspan="2"><table border="0" width="100%" cellspacing="0" cellpadding="0">

<tr>

<td align="center"><table border="0" width="100%">

<tr><td width="100%" colspan="3" align="center"><hr color="#6AB5FF">

<small>[<a

href="JavaScript: goMap()">Map</a>][<a

href="/login.shm" target="00409637e8d0login">Login</a>][<a

href="http://www.cisco.com/warp/public/779/smbiz/prodconfig/help/eag/air/ap3xx/SetSNMP.shm.htm" target="00409637e8d0Help">Help</a>]</small></td></tr>



<tr><td nowrap><small><small>Cisco AP340 11.21</small></small></td>

<td nowrap><font color="#3f3f3f" size="-2">® Copyright 2001 <a

href="http://www.cisco.com">Cisco Systems, Inc.</a></font></td>

<td align="right"><a href="/CiscoLegal.shm"><small><em>credits</em></small></a></td></tr>



</table></td>

</tr>

</table>

</td>

</tr>

</table>

</div>

</body>

</html>



END

$responsesVxWorks->{config} = <<'END';
#===Beginning of Aironet_340 (Cisco AP340 11.21) Configuration File===

dot11AuthenticationResponseTimeOut.2=2050

dot11PowerManagementMode.2=active

dot11DesiredSSID.2=lab_cisco340

dot11OperationalRateSet.2=\x82\x84\x8b\x96

dot11BeaconPeriod.2=100

dot11DTIMPeriod.2=3

dot11AssociationResponseTimeOut.2=2000

dot11MultiDomainCapabilityEnabled.2=false

dot11AuthenticationAlgorithmsEnable.2.1=true

dot11AuthenticationAlgorithmsEnable.2.2=false

dot11AuthenticationAlgorithmsEnable.2.3=false

dot11PrivacyInvoked.2=false

dot11WEPDefaultKeyID.2=0

dot11WEPKeyMappingLength.2=0

dot11ExcludeUnencrypted.2=false

dot11RTSThreshold.2=2339

dot11ShortRetryLimit.2=32

dot11LongRetryLimit.2=32

dot11FragmentationThreshold.2=2338

dot11MaxTransmitMSDULifetime.2=5000

dot11MaxReceiveLifetime.2=10000

dot11ChannelAgilityEnabled.2=false

dot11CurrentTxAntenna.2=diversity

dot11CurrentRxAntenna.2=diversity

dot11CurrentTxPowerLevel.2=1

dot11CurrentDwellTime.2=19

dot11CurrentSet.2=1

dot11CurrentPattern.2=1

dot11CurrentChannel.2=1

dot11CurrentCCAMode.2=1

sysContact=Brent Mills

sysName=Aironet_340

sysLocation=Austin, Texas

ipRouteIfIndex.0.0.0.0=1

ipRouteMetric1.0.0.0.0=-1

ipRouteMetric2.0.0.0.0=-1

ipRouteMetric3.0.0.0.0=-1

ipRouteMetric4.0.0.0.0=-1

ipRouteNextHop.0.0.0.0=10.100.1.1

ipRouteType.0.0.0.0=other

ipRouteProto.0.0.0.0=other

ipRouteAge.0.0.0.0=0

ipRouteMask.0.0.0.0=255.255.255.0

ipRouteMetric5.0.0.0.0=-1

dot1dStpPriority.0=32768

dot1dStpBridgeMaxAge.0=2000

dot1dStpBridgeHelloTime.0=200

dot1dStpBridgeForwardDelay.0=1500

dot1dStpPortPriority.1=128

dot1dStpPortPriority.2=128

dot1dStpPortPriority.5=12

dot1dStpPortPriority.6=128

dot1dStpPortPriority.7=128

dot1dStpPortPriority.8=128

dot1dStpPortPriority.9=128

dot1dStpPortPriority.10=128

dot1dStpPortPriority.11=128

dot1dStpPortPriority.12=128

dot1dStpPortPriority.13=128

dot1dStpPortPriority.14=128

dot1dStpPortPriority.15=128

dot1dStpPortPriority.16=128

dot1dStpPortPriority.17=128

dot1dStpPortPriority.18=128

dot1dStpPortPriority.19=128

dot1dStpPortPriority.20=128

dot1dStpPortPriority.21=128

dot1dStpPortPriority.22=128

dot1dStpPortPriority.23=128

dot1dStpPortPriority.24=128

dot1dStpPortPriority.25=128

dot1dStpPortPriority.26=128

dot1dStpPortPriority.27=128

dot1dStpPortPriority.28=128

dot1dStpPortPriority.29=128

dot1dStpPortPriority.30=128

dot1dStpPortPriority.31=128

dot1dStpPortPriority.32=12

dot1dStpPortEnable.1=enabled

dot1dStpPortEnable.2=enabled

dot1dStpPortEnable.5=enabled

dot1dStpPortEnable.6=enabled

dot1dStpPortEnable.7=enabled

dot1dStpPortEnable.8=enabled

dot1dStpPortEnable.9=enabled

dot1dStpPortEnable.10=enabled

dot1dStpPortEnable.11=enabled

dot1dStpPortEnable.12=enabled

dot1dStpPortEnable.13=enabled

dot1dStpPortEnable.14=enabled

dot1dStpPortEnable.15=enabled

dot1dStpPortEnable.16=enabled

dot1dStpPortEnable.17=enabled

dot1dStpPortEnable.18=enabled

dot1dStpPortEnable.19=enabled

dot1dStpPortEnable.20=enabled

dot1dStpPortEnable.21=enabled

dot1dStpPortEnable.22=enabled

dot1dStpPortEnable.23=enabled

dot1dStpPortEnable.24=enabled

dot1dStpPortEnable.25=enabled

dot1dStpPortEnable.26=enabled

dot1dStpPortEnable.27=enabled

dot1dStpPortEnable.28=enabled

dot1dStpPortEnable.29=enabled

dot1dStpPortEnable.30=enabled

dot1dStpPortEnable.31=enabled

dot1dStpPortEnable.32=enabled

dot1dStpPortPathCost.1=100

dot1dStpPortPathCost.2=100

dot1dStpPortPathCost.5=100

dot1dStpPortPathCost.6=100

dot1dStpPortPathCost.7=100

dot1dStpPortPathCost.8=100

dot1dStpPortPathCost.9=100

dot1dStpPortPathCost.10=100

dot1dStpPortPathCost.11=100

dot1dStpPortPathCost.12=100

dot1dStpPortPathCost.13=100

dot1dStpPortPathCost.14=100

dot1dStpPortPathCost.15=100

dot1dStpPortPathCost.16=100

dot1dStpPortPathCost.17=100

dot1dStpPortPathCost.18=100

dot1dStpPortPathCost.19=100

dot1dStpPortPathCost.20=100

dot1dStpPortPathCost.21=100

dot1dStpPortPathCost.22=100

dot1dStpPortPathCost.23=100

dot1dStpPortPathCost.24=100

dot1dStpPortPathCost.25=100

dot1dStpPortPathCost.26=100

dot1dStpPortPathCost.27=100

dot1dStpPortPathCost.28=100

dot1dStpPortPathCost.29=100

dot1dStpPortPathCost.30=100

dot1dStpPortPathCost.31=100

dot1dStpPortPathCost.32=100

dot1dTpAgingTime.0=300

dot1dStaticAllowedToGoTo.0.3.189.148.68.147.0=00000000

dot1dStaticAllowedToGoTo.0.5.78.64.197.2.0=ffffffff

dot1dStaticAllowedToGoTo.0.6.27.224.49.219.0=00000000

dot1dStaticAllowedToGoTo.0.9.91.239.148.177.0=00000000

dot1dStaticAllowedToGoTo.0.17.67.169.107.12.0=00000000

dot1dStaticAllowedToGoTo.0.48.189.148.68.147.0=ffffffff

dot1dStaticStatus.0.3.189.148.68.147.0=permanent

dot1dStaticStatus.0.5.78.64.197.2.0=permanent

dot1dStaticStatus.0.6.27.224.49.219.0=permanent

dot1dStaticStatus.0.9.91.239.148.177.0=permanent

dot1dStaticStatus.0.17.67.169.107.12.0=permanent

dot1dStaticStatus.0.48.189.148.68.147.0=permanent

cdpGlobalRun=T

cdpGlobalMessageInterval=60

cdpGlobalHoldTime=180

sysFlags=192

languageCode=en-US

enableHTTP=T

enableTelnet=T

enableSNMP=T

enableDnsResolver=T

enableSNTP=F

pingTxLen=64

enablePSPF=F

sysExceptionReboot=T

enableSTP=F

enableRebootKey=F

bootconfigBootProtocol=none

bootconfigReadINI=ifSpecified

bootconfigServerConfigTimeout=120

bootconfigMultOfferTimeout=5

bootconfigReqLeaseDuration=1440

bootconfigMinLeaseDuration=0

bootconfigDev=fec0

bootconfigSaveServerResponse=T

bootconfigDhcpClassID=AP4800E

bootconfigBootCount=1238

bootconfigDhcpClientIdType=ethernet10Mb

bootconfigDhcpClientIdValue=

serialAdminStatus.1=up

serialBaud.1=9600

serialParity.1=none

serialDataBits.1=8

serialStopBits.1=1

serialFlowControl.1=swXonXoff

serialTerminalType.1=ANSI

serialTerminalLines.1=24

serialTerminalColumns.1=80

defaultFileServer=10.10.1.84

awcFileXferProtocol=TFTP

awcFileXferFileFirmwareSystem=AP340v1123T.exe

awcFileXferFileFirmwareRadio0=

awcFileXferFileWebUI=AP340v1123T.exe

awcFileXferFileFpgaPcmcia=

awcFileXferTftpPort=69

awcFileXferFtpDirectory=/

awcFileXferFilesFLASH=AP340v1200T.img

awcIfPhysAddress.1=00:00:00:00:00:00

awcIfPhysAddress.2=00:00:00:00:00:00

awcIfAdoptPrimaryIdentity.1=T

awcIfAdoptPrimaryIdentity.2=T

awcIfDefaultIpAddress.1=10.100.1.2

awcIfDefaultIpAddress.2=10.0.0.2

awcIfDefaultIpNetMask.1=255.255.255.0

awcIfDefaultIpNetMask.2=255.255.255.0

awcDot11StationRole.2=RoleAP

awcDot11PowerManagementSubMode.2=1

awcDot11UseAWCExtensions.2=T

awcDot11AllowAssocBroadcastSSID.2=F

awcDot11EnetEncapsulationDefault.2=encapRfc1042

awcDot11ForceReqFirmwareVersion.2=F

awcDot11BridgeSpacing.2=0

awcDot11DesiredSSIDMaxAssociatedSTA.2=0

awcDot11DesiredSSIDMicAlgorithm.2=micNone

awcDot11DesiredSSIDWEPKeyPermuteAlgorithm.2=wepPermuteNone

awcDot11DesiredSSIDInfrastructureWGB.2=true

awcDot11AuthenticationRequireEAP.2.1=false

awcDot11AuthenticationRequireEAP.2.2=false

awcDot11AuthenticationRequireEAP.2.3=true

awcDot11AuthenticationDefaultUcastAllowedToGoTo.2.1=ffffffff

awcDot11AuthenticationDefaultUcastAllowedToGoTo.2.2=ffffffff

awcDot11AuthenticationDefaultUcastAllowedToGoTo.2.3=ffffffff

awcDot11AllowEncrypted.2=false

awcDot11LEAPUserName.2=

#awcDot11LEAPPassword.2=

awcDot11DesiredBSS.2.1=00:00:00:00:00:00

awcDot11DesiredBSS.2.2=00:00:00:00:00:00

awcDot11DesiredBSS.2.3=00:00:00:00:00:00

awcDot11DesiredBSS.2.4=00:00:00:00:00:00

awcDot11AssignedSTA.2.2=00:00:00:00:00:00

awcDot11AssignedSTA.2.3=00:00:00:00:00:00

awcDot11AssignedSTA.2.4=00:00:00:00:00:00

awcDot11AssignedSTA.2.5=00:00:00:00:00:00

awcDot11AssignedSTA.2.6=00:00:00:00:00:00

awcDot11AssignedSTA.2.7=00:00:00:00:00:00

awcDot11AssignedSTA.2.8=00:00:00:00:00:00

awcDot11AssignedSTA.2.9=00:00:00:00:00:00

awcDot11AssignedSTA.2.10=00:00:00:00:00:00

awcDot11AssignedSTA.2.11=00:00:00:00:00:00

awcDot11AssignedSTA.2.12=00:00:00:00:00:00

awcDot11AssignedSTA.2.13=00:00:00:00:00:00

awcDot11AssignedSTA.2.14=00:00:00:00:00:00

awcDot11AssignedSTA.2.15=00:00:00:00:00:00

awcDot11AssignedSTA.2.16=00:00:00:00:00:00

awcDot11AssignedSTA.2.17=00:00:00:00:00:00

awcDot11AssignedSTA.2.18=00:00:00:00:00:00

awcDot11AssignedSTA.2.19=00:00:00:00:00:00

awcDot11AssignedSTA.2.20=00:00:00:00:00:00

awcDot11AssignedSTA.2.21=00:00:00:00:00:00

awcDot11AssignedSTA.2.22=00:00:00:00:00:00

awcDot11AssignedSTA.2.23=00:00:00:00:00:00

awcDot11AssignedSTA.2.24=00:00:00:00:00:00

awcDot11AssignedSTA.2.25=00:00:00:00:00:00

awcDot11AssignedSTA.2.26=00:00:00:00:00:00

awcDot11AssignedSTA.2.27=00:00:00:00:00:00

awcDot11AssignedSTA.2.28=00:00:00:00:00:00

awcDot11ModulationType.2=standard

awcDot11PreambleType.2=short

awcDot11Compatible3100.2=F

awcDot11Compatible4500.2=F

awcDot11ChannelAutoEnabled.2=false

awcDot11ChanSelectEnable.2.1=T

awcDot11ChanSelectEnable.2.2=T

awcDot11ChanSelectEnable.2.3=T

awcDot11ChanSelectEnable.2.4=T

awcDot11ChanSelectEnable.2.5=T

awcDot11ChanSelectEnable.2.6=T

awcDot11ChanSelectEnable.2.7=T

awcDot11ChanSelectEnable.2.8=T

awcDot11ChanSelectEnable.2.9=T

awcDot11ChanSelectEnable.2.10=T

awcDot11ChanSelectEnable.2.11=T

awcDot11ChanSelectEnable.2.12=T

awcDot11ChanSelectEnable.2.13=T

awcDot11ChanSelectEnable.2.14=T

allowBrowseWithoutLogin=F

protectLegalPage=F

defaultWebRoot=mfs0:/StdUI/

defaultHelpRoot=http://www.cisco.com/warp/public/779/smbiz/prodconfig/help/eag/air/ap3xx

getWebUI=

awcHttpdPort=80

awcConsoleAutoApply=F

resolverDomainSuffix=

defaultResolverDomain=inside

defaultResolverDomainServer.1=

defaultResolverDomainServer.2=

defaultResolverDomainServer.3=

snmpTrapDest=10.10.1.62

snmpTrapCommunity=public

defaultSntpServer=

awcFtMaxNumEntries=8192

awcFtTimeoutSecUnknown=300

awcFtTimeoutSecMcastAddr=28800

awcFtTimeoutSecDsHost=1800

awcFtTimeoutSecBridgeHost=1800

awcFtTimeoutSecClientSTA=1800

awcFtTimeoutSecBridge=28800

awcFtTimeoutSecRepeater=28800

awcFtTimeoutSecAccessPoint=28800

awcFtTimeoutSecBridgeRoot=28800

awcFtEnableAwcTpFdbTable=T

awcFtEnableMacAuthServer=F

awcFtEnableMacOrEapAuth=F

awcDot1dTpPortDefaultUcastAllowedToGoTo.1=ffffffff

awcDot1dTpPortDefaultUcastAllowedToGoTo.2=ffffffff

awcDot1dTpPortDefaultUcastAllowedToGoTo.5=ffffffff

awcDot1dTpPortDefaultUcastAllowedToGoTo.6=ffffffff

awcDot1dTpPortDefaultUcastAllowedToGoTo.7=ffffffff

awcDot1dTpPortDefaultUcastAllowedToGoTo.8=ffffffff

awcDot1dTpPortDefaultUcastAllowedToGoTo.9=ffffffff

awcDot1dTpPortDefaultUcastAllowedToGoTo.10=ffffffff

awcDot1dTpPortDefaultUcastAllowedToGoTo.11=ffffffff

awcDot1dTpPortDefaultUcastAllowedToGoTo.12=ffffffff

awcDot1dTpPortDefaultUcastAllowedToGoTo.13=ffffffff

awcDot1dTpPortDefaultUcastAllowedToGoTo.14=ffffffff

awcDot1dTpPortDefaultUcastAllowedToGoTo.15=ffffffff

awcDot1dTpPortDefaultUcastAllowedToGoTo.16=ffffffff

awcDot1dTpPortDefaultUcastAllowedToGoTo.17=ffffffff

awcDot1dTpPortDefaultUcastAllowedToGoTo.18=ffffffff

awcDot1dTpPortDefaultUcastAllowedToGoTo.19=ffffffff

awcDot1dTpPortDefaultUcastAllowedToGoTo.20=ffffffff

awcDot1dTpPortDefaultUcastAllowedToGoTo.21=ffffffff

awcDot1dTpPortDefaultUcastAllowedToGoTo.22=ffffffff

awcDot1dTpPortDefaultUcastAllowedToGoTo.23=ffffffff

awcDot1dTpPortDefaultUcastAllowedToGoTo.24=ffffffff

awcDot1dTpPortDefaultUcastAllowedToGoTo.25=ffffffff

awcDot1dTpPortDefaultUcastAllowedToGoTo.26=ffffffff

awcDot1dTpPortDefaultUcastAllowedToGoTo.27=ffffffff

awcDot1dTpPortDefaultUcastAllowedToGoTo.28=ffffffff

awcDot1dTpPortDefaultUcastAllowedToGoTo.29=ffffffff

awcDot1dTpPortDefaultUcastAllowedToGoTo.30=ffffffff

awcDot1dTpPortDefaultUcastAllowedToGoTo.31=ffffffff

awcDot1dTpPortDefaultUcastAllowedToGoTo.32=ffffffff

awcDot1dTpPortDefaultNUcastAllowedToGoTo.1=ffffffff

awcDot1dTpPortDefaultNUcastAllowedToGoTo.2=ffffffff

awcDot1dTpPortDefaultNUcastAllowedToGoTo.5=ffffffff

awcDot1dTpPortDefaultNUcastAllowedToGoTo.6=ffffffff

awcDot1dTpPortDefaultNUcastAllowedToGoTo.7=ffffffff

awcDot1dTpPortDefaultNUcastAllowedToGoTo.8=ffffffff

awcDot1dTpPortDefaultNUcastAllowedToGoTo.9=ffffffff

awcDot1dTpPortDefaultNUcastAllowedToGoTo.10=ffffffff

awcDot1dTpPortDefaultNUcastAllowedToGoTo.11=ffffffff

awcDot1dTpPortDefaultNUcastAllowedToGoTo.12=ffffffff

awcDot1dTpPortDefaultNUcastAllowedToGoTo.13=ffffffff

awcDot1dTpPortDefaultNUcastAllowedToGoTo.14=ffffffff

awcDot1dTpPortDefaultNUcastAllowedToGoTo.15=ffffffff

awcDot1dTpPortDefaultNUcastAllowedToGoTo.16=ffffffff

awcDot1dTpPortDefaultNUcastAllowedToGoTo.17=ffffffff

awcDot1dTpPortDefaultNUcastAllowedToGoTo.18=ffffffff

awcDot1dTpPortDefaultNUcastAllowedToGoTo.19=ffffffff

awcDot1dTpPortDefaultNUcastAllowedToGoTo.20=ffffffff

awcDot1dTpPortDefaultNUcastAllowedToGoTo.21=ffffffff

awcDot1dTpPortDefaultNUcastAllowedToGoTo.22=ffffffff

awcDot1dTpPortDefaultNUcastAllowedToGoTo.23=ffffffff

awcDot1dTpPortDefaultNUcastAllowedToGoTo.24=ffffffff

awcDot1dTpPortDefaultNUcastAllowedToGoTo.25=ffffffff

awcDot1dTpPortDefaultNUcastAllowedToGoTo.26=ffffffff

awcDot1dTpPortDefaultNUcastAllowedToGoTo.27=ffffffff

awcDot1dTpPortDefaultNUcastAllowedToGoTo.28=ffffffff

awcDot1dTpPortDefaultNUcastAllowedToGoTo.29=ffffffff

awcDot1dTpPortDefaultNUcastAllowedToGoTo.30=ffffffff

awcDot1dTpPortDefaultNUcastAllowedToGoTo.31=ffffffff

awcDot1dTpPortDefaultNUcastAllowedToGoTo.32=ffffffff

awcDot1dTpPortMaxNUcastPerSecond.1=0

awcDot1dTpPortMaxNUcastPerSecond.2=0

awcDot1dTpPortMaxNUcastPerSecond.5=0

awcDot1dTpPortMaxNUcastPerSecond.6=0

awcDot1dTpPortMaxNUcastPerSecond.7=0

awcDot1dTpPortMaxNUcastPerSecond.8=0

awcDot1dTpPortMaxNUcastPerSecond.9=0

awcDot1dTpPortMaxNUcastPerSecond.10=0

awcDot1dTpPortMaxNUcastPerSecond.11=0

awcDot1dTpPortMaxNUcastPerSecond.12=0

awcDot1dTpPortMaxNUcastPerSecond.13=0

awcDot1dTpPortMaxNUcastPerSecond.14=0

awcDot1dTpPortMaxNUcastPerSecond.15=0

awcDot1dTpPortMaxNUcastPerSecond.16=0

awcDot1dTpPortMaxNUcastPerSecond.17=0

awcDot1dTpPortMaxNUcastPerSecond.18=0

awcDot1dTpPortMaxNUcastPerSecond.19=0

awcDot1dTpPortMaxNUcastPerSecond.20=0

awcDot1dTpPortMaxNUcastPerSecond.21=0

awcDot1dTpPortMaxNUcastPerSecond.22=0

awcDot1dTpPortMaxNUcastPerSecond.23=0

awcDot1dTpPortMaxNUcastPerSecond.24=0

awcDot1dTpPortMaxNUcastPerSecond.25=0

awcDot1dTpPortMaxNUcastPerSecond.26=0

awcDot1dTpPortMaxNUcastPerSecond.27=0

awcDot1dTpPortMaxNUcastPerSecond.28=0

awcDot1dTpPortMaxNUcastPerSecond.29=0

awcDot1dTpPortMaxNUcastPerSecond.30=0

awcDot1dTpPortMaxNUcastPerSecond.31=0

awcDot1dTpPortMaxNUcastPerSecond.32=0

awcDot1dTpPortDefaultInEthertypeFilterId.1=0

awcDot1dTpPortDefaultInEthertypeFilterId.2=0

awcDot1dTpPortDefaultInEthertypeFilterId.5=0

awcDot1dTpPortDefaultInEthertypeFilterId.6=0

awcDot1dTpPortDefaultInEthertypeFilterId.7=0

awcDot1dTpPortDefaultInEthertypeFilterId.8=0

awcDot1dTpPortDefaultInEthertypeFilterId.9=0

awcDot1dTpPortDefaultInEthertypeFilterId.10=0

awcDot1dTpPortDefaultInEthertypeFilterId.11=0

awcDot1dTpPortDefaultInEthertypeFilterId.12=0

awcDot1dTpPortDefaultInEthertypeFilterId.13=0

awcDot1dTpPortDefaultInEthertypeFilterId.14=0

awcDot1dTpPortDefaultInEthertypeFilterId.15=0

awcDot1dTpPortDefaultInEthertypeFilterId.16=0

awcDot1dTpPortDefaultInEthertypeFilterId.17=0

awcDot1dTpPortDefaultInEthertypeFilterId.18=0

awcDot1dTpPortDefaultInEthertypeFilterId.19=0

awcDot1dTpPortDefaultInEthertypeFilterId.20=0

awcDot1dTpPortDefaultInEthertypeFilterId.21=0

awcDot1dTpPortDefaultInEthertypeFilterId.22=0

awcDot1dTpPortDefaultInEthertypeFilterId.23=0

awcDot1dTpPortDefaultInEthertypeFilterId.24=0

awcDot1dTpPortDefaultInEthertypeFilterId.25=0

awcDot1dTpPortDefaultInEthertypeFilterId.26=0

awcDot1dTpPortDefaultInEthertypeFilterId.27=0

awcDot1dTpPortDefaultInEthertypeFilterId.28=0

awcDot1dTpPortDefaultInEthertypeFilterId.29=0

awcDot1dTpPortDefaultInEthertypeFilterId.30=0

awcDot1dTpPortDefaultInEthertypeFilterId.31=0

awcDot1dTpPortDefaultInEthertypeFilterId.32=0

awcDot1dTpPortDefaultOutEthertypeFilterId.1=0

awcDot1dTpPortDefaultOutEthertypeFilterId.2=0

awcDot1dTpPortDefaultOutEthertypeFilterId.5=0

awcDot1dTpPortDefaultOutEthertypeFilterId.6=0

awcDot1dTpPortDefaultOutEthertypeFilterId.7=0

awcDot1dTpPortDefaultOutEthertypeFilterId.8=0

awcDot1dTpPortDefaultOutEthertypeFilterId.9=0

awcDot1dTpPortDefaultOutEthertypeFilterId.10=0

awcDot1dTpPortDefaultOutEthertypeFilterId.11=0

awcDot1dTpPortDefaultOutEthertypeFilterId.12=0

awcDot1dTpPortDefaultOutEthertypeFilterId.13=0

awcDot1dTpPortDefaultOutEthertypeFilterId.14=0

awcDot1dTpPortDefaultOutEthertypeFilterId.15=0

awcDot1dTpPortDefaultOutEthertypeFilterId.16=0

awcDot1dTpPortDefaultOutEthertypeFilterId.17=0

awcDot1dTpPortDefaultOutEthertypeFilterId.18=0

awcDot1dTpPortDefaultOutEthertypeFilterId.19=0

awcDot1dTpPortDefaultOutEthertypeFilterId.20=0

awcDot1dTpPortDefaultOutEthertypeFilterId.21=0

awcDot1dTpPortDefaultOutEthertypeFilterId.22=0

awcDot1dTpPortDefaultOutEthertypeFilterId.23=0

awcDot1dTpPortDefaultOutEthertypeFilterId.24=0

awcDot1dTpPortDefaultOutEthertypeFilterId.25=0

awcDot1dTpPortDefaultOutEthertypeFilterId.26=0

awcDot1dTpPortDefaultOutEthertypeFilterId.27=0

awcDot1dTpPortDefaultOutEthertypeFilterId.28=0

awcDot1dTpPortDefaultOutEthertypeFilterId.29=0

awcDot1dTpPortDefaultOutEthertypeFilterId.30=0

awcDot1dTpPortDefaultOutEthertypeFilterId.31=0

awcDot1dTpPortDefaultOutEthertypeFilterId.32=0

awcDot1dTpPortDefaultInIpProtoFilterId.1=0

awcDot1dTpPortDefaultInIpProtoFilterId.2=0

awcDot1dTpPortDefaultInIpProtoFilterId.5=0

awcDot1dTpPortDefaultInIpProtoFilterId.6=0

awcDot1dTpPortDefaultInIpProtoFilterId.7=0

awcDot1dTpPortDefaultInIpProtoFilterId.8=0

awcDot1dTpPortDefaultInIpProtoFilterId.9=0

awcDot1dTpPortDefaultInIpProtoFilterId.10=0

awcDot1dTpPortDefaultInIpProtoFilterId.11=0

awcDot1dTpPortDefaultInIpProtoFilterId.12=0

awcDot1dTpPortDefaultInIpProtoFilterId.13=0

awcDot1dTpPortDefaultInIpProtoFilterId.14=0

awcDot1dTpPortDefaultInIpProtoFilterId.15=0

awcDot1dTpPortDefaultInIpProtoFilterId.16=0

awcDot1dTpPortDefaultInIpProtoFilterId.17=0

awcDot1dTpPortDefaultInIpProtoFilterId.18=0

awcDot1dTpPortDefaultInIpProtoFilterId.19=0

awcDot1dTpPortDefaultInIpProtoFilterId.20=0

awcDot1dTpPortDefaultInIpProtoFilterId.21=0

awcDot1dTpPortDefaultInIpProtoFilterId.22=0

awcDot1dTpPortDefaultInIpProtoFilterId.23=0

awcDot1dTpPortDefaultInIpProtoFilterId.24=0

awcDot1dTpPortDefaultInIpProtoFilterId.25=0

awcDot1dTpPortDefaultInIpProtoFilterId.26=0

awcDot1dTpPortDefaultInIpProtoFilterId.27=0

awcDot1dTpPortDefaultInIpProtoFilterId.28=0

awcDot1dTpPortDefaultInIpProtoFilterId.29=0

awcDot1dTpPortDefaultInIpProtoFilterId.30=0

awcDot1dTpPortDefaultInIpProtoFilterId.31=0

awcDot1dTpPortDefaultInIpProtoFilterId.32=0

awcDot1dTpPortDefaultOutIpProtoFilterId.1=0

awcDot1dTpPortDefaultOutIpProtoFilterId.2=0

awcDot1dTpPortDefaultOutIpProtoFilterId.5=0

awcDot1dTpPortDefaultOutIpProtoFilterId.6=0

awcDot1dTpPortDefaultOutIpProtoFilterId.7=0

awcDot1dTpPortDefaultOutIpProtoFilterId.8=0

awcDot1dTpPortDefaultOutIpProtoFilterId.9=0

awcDot1dTpPortDefaultOutIpProtoFilterId.10=0

awcDot1dTpPortDefaultOutIpProtoFilterId.11=0

awcDot1dTpPortDefaultOutIpProtoFilterId.12=0

awcDot1dTpPortDefaultOutIpProtoFilterId.13=0

awcDot1dTpPortDefaultOutIpProtoFilterId.14=0

awcDot1dTpPortDefaultOutIpProtoFilterId.15=0

awcDot1dTpPortDefaultOutIpProtoFilterId.16=0

awcDot1dTpPortDefaultOutIpProtoFilterId.17=0

awcDot1dTpPortDefaultOutIpProtoFilterId.18=0

awcDot1dTpPortDefaultOutIpProtoFilterId.19=0

awcDot1dTpPortDefaultOutIpProtoFilterId.20=0

awcDot1dTpPortDefaultOutIpProtoFilterId.21=0

awcDot1dTpPortDefaultOutIpProtoFilterId.22=0

awcDot1dTpPortDefaultOutIpProtoFilterId.23=0

awcDot1dTpPortDefaultOutIpProtoFilterId.24=0

awcDot1dTpPortDefaultOutIpProtoFilterId.25=0

awcDot1dTpPortDefaultOutIpProtoFilterId.26=0

awcDot1dTpPortDefaultOutIpProtoFilterId.27=0

awcDot1dTpPortDefaultOutIpProtoFilterId.28=0

awcDot1dTpPortDefaultOutIpProtoFilterId.29=0

awcDot1dTpPortDefaultOutIpProtoFilterId.30=0

awcDot1dTpPortDefaultOutIpProtoFilterId.31=0

awcDot1dTpPortDefaultOutIpProtoFilterId.32=0

awcDot1dTpPortDefaultInIpPortFilterId.1=0

awcDot1dTpPortDefaultInIpPortFilterId.2=0

awcDot1dTpPortDefaultInIpPortFilterId.5=0

awcDot1dTpPortDefaultInIpPortFilterId.6=0

awcDot1dTpPortDefaultInIpPortFilterId.7=0

awcDot1dTpPortDefaultInIpPortFilterId.8=0

awcDot1dTpPortDefaultInIpPortFilterId.9=0

awcDot1dTpPortDefaultInIpPortFilterId.10=0

awcDot1dTpPortDefaultInIpPortFilterId.11=0

awcDot1dTpPortDefaultInIpPortFilterId.12=0

awcDot1dTpPortDefaultInIpPortFilterId.13=0

awcDot1dTpPortDefaultInIpPortFilterId.14=0

awcDot1dTpPortDefaultInIpPortFilterId.15=0

awcDot1dTpPortDefaultInIpPortFilterId.16=0

awcDot1dTpPortDefaultInIpPortFilterId.17=0

awcDot1dTpPortDefaultInIpPortFilterId.18=0

awcDot1dTpPortDefaultInIpPortFilterId.19=0

awcDot1dTpPortDefaultInIpPortFilterId.20=0

awcDot1dTpPortDefaultInIpPortFilterId.21=0

awcDot1dTpPortDefaultInIpPortFilterId.22=0

awcDot1dTpPortDefaultInIpPortFilterId.23=0

awcDot1dTpPortDefaultInIpPortFilterId.24=0

awcDot1dTpPortDefaultInIpPortFilterId.25=0

awcDot1dTpPortDefaultInIpPortFilterId.26=0

awcDot1dTpPortDefaultInIpPortFilterId.27=0

awcDot1dTpPortDefaultInIpPortFilterId.28=0

awcDot1dTpPortDefaultInIpPortFilterId.29=0

awcDot1dTpPortDefaultInIpPortFilterId.30=0

awcDot1dTpPortDefaultInIpPortFilterId.31=0

awcDot1dTpPortDefaultInIpPortFilterId.32=0

awcDot1dTpPortDefaultOutIpPortFilterId.1=0

awcDot1dTpPortDefaultOutIpPortFilterId.2=0

awcDot1dTpPortDefaultOutIpPortFilterId.5=0

awcDot1dTpPortDefaultOutIpPortFilterId.6=0

awcDot1dTpPortDefaultOutIpPortFilterId.7=0

awcDot1dTpPortDefaultOutIpPortFilterId.8=0

awcDot1dTpPortDefaultOutIpPortFilterId.9=0

awcDot1dTpPortDefaultOutIpPortFilterId.10=0

awcDot1dTpPortDefaultOutIpPortFilterId.11=0

awcDot1dTpPortDefaultOutIpPortFilterId.12=0

awcDot1dTpPortDefaultOutIpPortFilterId.13=0

awcDot1dTpPortDefaultOutIpPortFilterId.14=0

awcDot1dTpPortDefaultOutIpPortFilterId.15=0

awcDot1dTpPortDefaultOutIpPortFilterId.16=0

awcDot1dTpPortDefaultOutIpPortFilterId.17=0

awcDot1dTpPortDefaultOutIpPortFilterId.18=0

awcDot1dTpPortDefaultOutIpPortFilterId.19=0

awcDot1dTpPortDefaultOutIpPortFilterId.20=0

awcDot1dTpPortDefaultOutIpPortFilterId.21=0

awcDot1dTpPortDefaultOutIpPortFilterId.22=0

awcDot1dTpPortDefaultOutIpPortFilterId.23=0

awcDot1dTpPortDefaultOutIpPortFilterId.24=0

awcDot1dTpPortDefaultOutIpPortFilterId.25=0

awcDot1dTpPortDefaultOutIpPortFilterId.26=0

awcDot1dTpPortDefaultOutIpPortFilterId.27=0

awcDot1dTpPortDefaultOutIpPortFilterId.28=0

awcDot1dTpPortDefaultOutIpPortFilterId.29=0

awcDot1dTpPortDefaultOutIpPortFilterId.30=0

awcDot1dTpPortDefaultOutIpPortFilterId.31=0

awcDot1dTpPortDefaultOutIpPortFilterId.32=0

awcEventOffsetGMT=-300

awcEventUseDaylightSavingsTime=T

awcEventTimestampGMT=0

awcEventDisplayWallClockTime=T

awcEventDisplayUptimeAscending=F

awcEventDetailDefault=24

awcEventSeverityDispConsole=systemInfo

awcEventSeverityDispHtmlGUI=systemInfo

awcEventSeverityDispHtmlConsole=systemInfo

awcEventAlertSNMP=F

awcEventAlertSyslog=T

awcEventDispSeverityNULL=count

awcEventDispSeveritySilent=count

awcEventDispSeveritySystemFatal=record

awcEventDispSeverityProtocolFatal=notify

awcEventDispSeverityPortFatal=notify

awcEventDispSeveritySystemAlert=notify

awcEventDispSeverityProtocolAlert=notify

awcEventDispSeverityPortAlert=notify

awcEventDispSeverityExternalAlert=notify

awcEventDispSeveritySystemWarning=record

awcEventDispSeverityProtocolWarning=record

awcEventDispSeverityPortWarning=record

awcEventDispSeverityExternalWarning=record

awcEventDispSeveritySystemInfo=notify

awcEventDispSeverityProtocolInfo=record

awcEventDispSeverityPortInfo=notify

awcEventDispSeverityExternalInfo=notify

awcEventSyslogAddr=10.100.32.43

awcEventSyslogFacility=0

awcEventTraceStationSeverity=externalInfo

awcEventTraceLogSize=0

awcEventTracePacketLen=0

awcEtherIfSpeedSelect=autoDetect

awcEtherForcePortUnblock=false

awcIappMcastIpAddr=224.0.1.40

awcIappPort=2887

#awcIappEapPreauthSharedSecret=

awcP802dot1XVersion=d10

awcHotStandbyMACAddr=00:00:00:00:00:00

awcHotStandbyPollingFrequency=1

awcHotStandbyPollingTimeOut=5

awcHotStandbyInHotStandby=F

awcAaaServerProtocol.1=radius

awcAaaServerProtocol.2=radius

awcAaaServerProtocol.3=radius

awcAaaServerProtocol.4=radius

awcAaaServerName.1=

awcAaaServerName.2=

awcAaaServerName.3=

awcAaaServerName.4=

awcAaaServerPort.1=1812

awcAaaServerPort.2=1812

awcAaaServerPort.3=1812

awcAaaServerPort.4=1812

awcAaaServerTimeout.1=20

awcAaaServerTimeout.2=20

awcAaaServerTimeout.3=20

awcAaaServerTimeout.4=20

awcAaaClientName.1=

awcAaaClientName.2=

awcAaaClientName.3=

awcAaaClientName.4=

awcAaaServer8021xCapabilityEnabled.1=T

awcAaaServer8021xCapabilityEnabled.2=T

awcAaaServer8021xCapabilityEnabled.3=T

awcAaaServer8021xCapabilityEnabled.4=T

awcAaaServerMacAddrAuthEnabled.1=F

awcAaaServerMacAddrAuthEnabled.2=F

awcAaaServerMacAddrAuthEnabled.3=F

awcAaaServerMacAddrAuthEnabled.4=F

awcAaaServerAccountingEnabled.1=F

awcAaaServerAccountingEnabled.2=F

awcAaaServerAccountingEnabled.3=F

awcAaaServerAccountingEnabled.4=F

awcAcctServerProtocol.1=radius

awcAcctServerProtocol.2=radius

awcAcctServerProtocol.3=radius

awcAcctServerProtocol.4=radius

awcAcctServerName.1=

awcAcctServerName.2=

awcAcctServerName.3=

awcAcctServerName.4=

awcAcctServerPort.1=1813

awcAcctServerPort.2=1813

awcAcctServerPort.3=1813

awcAcctServerPort.4=1813

awcAcctServerTimeout.1=20

awcAcctServerTimeout.2=20

awcAcctServerTimeout.3=20

awcAcctServerTimeout.4=20

awcAcctServerUpdateEnable.1=T

awcAcctServerUpdateEnable.2=T

awcAcctServerUpdateEnable.3=T

awcAcctServerUpdateEnable.4=T

awcAcctServerUpdateDelay.1=600

awcAcctServerUpdateDelay.2=600

awcAcctServerUpdateDelay.3=600

awcAcctServerUpdateDelay.4=600

awcAcctClientName.1=

awcAcctClientName.2=

awcAcctClientName.3=

awcAcctClientName.4=

awcAcctSecureEnabled.1=F

awcAcctSecureEnabled.2=F

awcAcctSecureEnabled.3=F

awcAcctSecureEnabled.4=F

awcAcctGeneralEnabled.1=F

awcAcctGeneralEnabled.2=F

awcAcctGeneralEnabled.3=F

awcAcctGeneralEnabled.4=F

#awcAcctServerSharedSecret.1=

#awcAcctServerSharedSecret.2=

#awcAcctServerSharedSecret.3=

#awcAcctServerSharedSecret.4=

awcAcctEnable=F

awcAcctStopDelayEnable=T

awcAcctStopDelayTime=2

awcPfEtSetName.1=

awcPfEtDefaultDisposition.1=forward

awcPfEtDefaultUcastTimeToLive.1=0

awcPfEtDefaultNUcastTimeToLive.1=0

awcPfEtSetStatus.1=active

awcPfIppSetName.202=Voice Over IP

awcPfIppDefaultDisposition.202=forward

awcPfIppDefaultUcastTimeToLive.202=0

awcPfIppDefaultNUcastTimeToLive.202=0

awcPfIppSetStatus.202=active

awcPfIppDisposition.202.119=default

awcPfIppUserPriority.202.119=interactiveVoice

awcPfIppUcastTimeToLive.202.119=0

awcPfIppNUcastTimeToLive.202.119=0

awcPfIppAlert.202.119=F

awcPfIppStatus.202.119=active

awcVlanEncapMode=dot1qDisabled

awcNativeVlanId=0

awcVoIPVlanId=0

awcVoIPVlanEnabled=false

awcVlanEnabled.4095=true

awcVlanNUcastKeyRotationInterval.4095=0

awcVlanRowStatus.4095=active

awcVlanMicAlgorithm.4095=micNone

awcVlanWEPKeyPermuteAlgorithm.4095=wepPermuteNone

awcVlanNUcastKeyLen.4095.1=0

awcVlanNUcastKeyLen.4095.2=0

awcVlanNUcastKeyLen.4095.3=0

awcVlanNUcastKeyLen.4095.4=0

#awcVlanNUcastKeyValue.4095.1=

#awcVlanNUcastKeyValue.4095.2=

#awcVlanNUcastKeyValue.4095.3=

#awcVlanNUcastKeyValue.4095.4=

awcPublicVlanId=1

#===End of Aironet_340 Configuration File===



END

$responsesVxWorks->{users} = <<'END';
<html>

<head>

<title>Aironet_340 User Information</title>

<script LANGUAGE="JavaScript">

<!--



function verifyBrowser() {

var ms = navigator.appVersion.indexOf("MSIE");

ie4 = (ms>0) && (parseInt(navigator.appVersion.substring(ms+5, ms+6)) >= 4);

var ns = navigator.appName.indexOf("Netscape");

ns= (ns>=0) && (parseInt(navigator.appVersion.substring(0,1))>=4);



if (ie4)

return "ie4";

else

if(ns)

return "ns";

else

return false;

}



function addSearchString(inString, appString) {

return (inString.indexOf("?",0)<0)? inString+"?"+appString: inString+"&"+appString;

}



function goMap(newHref) {

var newHref = "map.shm";



if (verifyBrowser() == "ns") {

newHref=addSearchString(newHref, "bv=ns");

}



var newWindow = window.open("", "00409637e8d0Map", "width=350,height=400,resizable=1,scrollbars=1,dependent=0");



if(newWindow.document.title.length== 0){

  newWindow = window.open(newHref, "00409637e8d0Map", "width=350,height=400,resizable=1,scrollbars=1,dependent=0"); 

}



if(newWindow != null && !newWindow.closed ){

  newWindow.focus();

}



}

// -->

</script>



<script LANGUAGE="JavaScript">

<!--

function openNewWindow(url, targetName, winParam)

{ 

var newWindow = window.open(url, targetName, winParam)

if (newWindow != null) { 

newWindow.focus()

document.ShowUsers.target=targetName

}

}

// -->

</script>

<noscript>

<meta http-equiv="Refresh" content="0;URL=/ShowUsersNoScript.shm?NoScript=1">

</noscript>

</head>



<body bgcolor="#FFFFFF" leftmargin="4" Text="black" LINK="black" ALINK="black" VLINK="black">

<div align="left">



<table border="0" cellspacing="1" align="left" width="600">

<tr>

<td nowrap><big><strong>Aironet_340</strong></big>

<font color="#ff0000" size="4"><big><strong>&nbsp;&nbsp;&nbsp;User Information&nbsp;&nbsp;&nbsp;</font></strong></big>&nbsp;</td>

<td valign="top" align="left" rowspan="2"><p align="right"><a

href="http://www.cisco.com"><img alt="Cisco's Homepage" height="69"

src="CiscoLogo.jpg" border="0"></a></td>

</tr>

<tr>

</tr>

<tr>

<td style="border-bottom:" valign="top">

<table border="0" width="100%" cellspacing="1" cellpadding="0"><tr>

<td style="border-left: none; border-right: 2 solid rgb(128,128,128); border-top: none; border-bottom: 2 solid rgb(128,128,128)"

bgcolor="#C0C0C0" align="center"><p align="center"><strong><a href="/index.shm"><small><font color="#000000">Home</font></small></a></strong></td>



<td style="border-left: none; border-right: 2 solid rgb(128,128,128); border-top: none; border-bottom: 2 solid rgb(128,128,128)"

bgcolor="#C0C0C0" align="center"><p align="center"><strong><small><a href="JavaScript: goMap()"><font color="#000000">Map</font></a></small></strong></td>



<td style="border-left: none; border-right: 2 solid rgb(128,128,128); border-top: none; border-bottom: 2 solid rgb(128,128,128)"

bgcolor="#C0C0C0" align="center"><p align="center"><strong><small><a href="/StatsAllNetIf.shm"><font color="#000000">Network</font></a></small></strong></td>



<td style="border-left: none; border-right: 2 solid rgb(128,128,128); border-top: none; border-bottom: 2 solid rgb(128,128,128)"

bgcolor="#C0C0C0" align="center"><p align="center"><strong><small><a href="/ShowAssociations.shm"><font color="#000000">Associations</font></a></small></strong></td>



<td style="border-left: none; border-right: 2 solid rgb(128,128,128); border-top: none; border-bottom: 2 solid rgb(128,128,128)"

bgcolor="#C0C0C0" align="center"><p align="center"><strong><small><a href="/Setup.shm"><font color="#000000">Setup</font></a></small></strong></td>



<td style="border-left: none; border-right: 2 solid rgb(128,128,128); border-top: none; border-bottom: 2 solid rgb(128,128,128)"

bgcolor="#C0C0C0" align="center"><p align="center"><strong><small><a href="/ShowEvents.shm"><font color="#000000">Logs</font></a></small></strong></td>



<td style="border-left: none; border-right: 2 solid rgb(128,128,128); border-top: none; border-bottom: 2 solid rgb(128,128,128)"

bgcolor="#C0C0C0" align="center"><p align="center"><strong><small><a href="http://www.cisco.com/warp/public/779/smbiz/prodconfig/help/eag/air/ap3xx/ShowUsers.shm.htm" target="00409637e8d0Help"><font color="#000000">Help</font></a></small></strong></td>



</tr></table>



</td>

<td valign="middle"><p align="center"><small>Uptime: 1 day, 01:38:34</small></td>

</tr>

<tr>

<td style="border-bottom:" valign="top" colspan="2"><form method="POST"

name="ShowUsers" target="_self"

action="JavaScript: openNewWindow('User_admin.shm', 'User_Management', 'width=430,height=280,resizable=1')">



<div align="center"><center><table border="0" width="100%" align="center" cellspacing="0"

bgcolor="#FFFFBD">

<tr align="center"><td width="30%" align="center"><strong>User Name</strong></td>
<td width="14%" align="center"><strong>Write</strong></td>
<td width="14%" align="center"><strong>SNMP</strong></td>
<td width="14%" align="center"><strong>Ident</strong></td>
<td width="14%" align="center"><strong>Firmware</strong></td>
<td width="14%" align="center"><strong>Admin</strong></td>
</tr>
<tr><td width="30%" align="center">
<a href="JavaScript: openNewWindow('User_admin.shm?SU_userName=public', 'User_admin', 'width=500,height=348,resizable=1');">public</a></td>
<td width="14%" align="center">x</td>
<td width="14%" align="center">x</td>
<td width="14%" align="center">x</td>
<td width="14%" align="center">x</td>
<td width="14%" align="center">x</td>
</tr>
<tr><td width="30%" align="center">
<a href="JavaScript: openNewWindow('User_admin.shm?SU_userName=testenv', 'User_admin', 'width=500,height=348,resizable=1');">testenv</a></td>
<td width="14%" align="center">x</td>
<td width="14%" align="center">x</td>
<td width="14%" align="center">x</td>
<td width="14%" align="center">x</td>
<td width="14%" align="center">x</td>
</tr>
<tr><td width="30%" align="center">
<a href="JavaScript: openNewWindow('User_admin.shm?SU_userName=testlab', 'User_admin', 'width=500,height=348,resizable=1');">testlab</a></td>
<td width="14%" align="center">x</td>
<td width="14%" align="center">x</td>
<td width="14%" align="center">x</td>
<td width="14%" align="center">x</td>
<td width="14%" align="center">x</td>
</tr>
<tr><td width="30%" align="center">
<a href="JavaScript: openNewWindow('User_admin.shm?SU_userName=wayne', 'User_admin', 'width=500,height=348,resizable=1');">wayne</a></td>
<td width="14%" align="center">x</td>
<td width="14%" align="center">x</td>
<td width="14%" align="center">x</td>
<td width="14%" align="center">&nbsp;</td>
<td width="14%" align="center">x</td>
</tr>


<tr>

<td width="100%" align="center" colspan="6" bgcolor="#FFFFFF"><div align="right"><p><input

type="submit" value="Add New User" name="B1"></td>

</tr>

</table>

</center></div>

</form>

</td>

</tr>

<tr>

<td valign="middle" colspan="2"><table border="0" width="100%" cellspacing="0" cellpadding="0">

<tr>

<td align="center"><table border="0" width="100%">

<tr><td width="100%" colspan="3" align="center"><hr color="#6AB5FF">

<small>[<a href="/index.shm">Home</a>][<a

href="JavaScript: goMap()">Map</a>][<a

href="/login.shm">Login</a>][<a

href="/StatsAllNetIf.shm">Network</a>][<a

href="/ShowAssociations.shm">Associations</a>][<a

href="/Setup.shm">Setup</a>][<a

href="/ShowEvents.shm">Logs</a>][<a

href="http://www.cisco.com/warp/public/779/smbiz/prodconfig/help/eag/air/ap3xx/ShowUsers.shm.htm" target="00409637e8d0Help">Help</a>]</small></td></tr>



<tr><td nowrap><small><small>Cisco AP340 11.21</small></small></td>

<td nowrap><font color="#3f3f3f" size="-2">® Copyright 2001 <a

href="http://www.cisco.com">Cisco Systems, Inc.</a></font></td>

<td align="right"><a href="/CiscoLegal.shm"><small><em>credits</em></small></a></td></tr>



</table></td>

</tr>

</table>

</td>

</tr>

</table>

</div>

</body>

</html>



END

$responsesVxWorks->{routes} = <<'END';
<html>

<head>

<title>Aironet_340 Routing Setup</title>

<script LANGUAGE="JavaScript">

<!--



function verifyBrowser() {

var ms = navigator.appVersion.indexOf("MSIE");

ie4 = (ms>0) && (parseInt(navigator.appVersion.substring(ms+5, ms+6)) >= 4);

var ns = navigator.appName.indexOf("Netscape");

ns= (ns>=0) && (parseInt(navigator.appVersion.substring(0,1))>=4);



if (ie4)

return "ie4";

else

if(ns)

return "ns";

else

return false;

}



function addSearchString(inString, appString) {

return (inString.indexOf("?",0)<0)? inString+"?"+appString: inString+"&"+appString;

}



function goMap(newHref) {

var newHref = "map.shm";



if (verifyBrowser() == "ns") {

newHref=addSearchString(newHref, "bv=ns");

}



var newWindow = window.open("", "00409637e8d0Map", "width=350,height=400,resizable=1,scrollbars=1,dependent=0");



if(newWindow.document.title.length== 0){

  newWindow = window.open(newHref, "00409637e8d0Map", "width=350,height=400,resizable=1,scrollbars=1,dependent=0"); 

}



if(newWindow != null && !newWindow.closed ){

  newWindow.focus();

}



}

// -->

</script>



<script LANGUAGE="JavaScript">

<!--

function doSubmit(whichButton) {

if (whichButton == "Apply" || whichButton == "OK") {

  return confirm("The settings shown on this page will be now be updated.\nClick 'OK' to approve.");

} else if (whichButton == "Restore") {

  return confirm("You have requested that ALL settings on this page be reverted to their Factory Defaults!\nAre you SURE you wish to do this?");

} else {

return true;

}

}

// -->

</script>



</head>



<body bgcolor="#FFFFFF" leftmargin="4" Text="black" LINK="black" ALINK="black" VLINK="black">

<div align="left">



<table border="0" cellspacing="1" align="left" width="600">

<tr>

<td nowrap><big><strong>Aironet_340</strong></big><font

color="#FF0000"><big><big><strong>&nbsp;&nbsp;&nbsp;Routing&nbsp;Setup</strong></big></big></font></td>

<td valign="top" align="left" rowspan="2"><p align="right"><a href="http://www.cisco.com"><img

alt="Cisco's Homepage" src="CiscoLogo.jpg" border="0"></a></td>

</tr>

<tr>

<td nowrap><strong><font color="#FF0000"><small>Cisco AP340 11.21</small></font></strong></td>

</tr>

<tr>

<td style="border-bottom:" valign="top">

<table border="0" cellspacing="1" cellpadding="0"><tr>

<td style="border-left: none; border-right: 2 solid rgb(128,128,128); border-top: none; border-bottom: 2 solid rgb(128,128,128)"

bgcolor="#C0C0C0" align="center"><p align="center"><strong>&nbsp;&nbsp;<a href="JavaScript: goMap()"><small><font color="#000000">Map</font></small></a>&nbsp;&nbsp;</strong></td>

<td style="border-left: none; border-right: 2 solid rgb(128,128,128); border-top: none; border-bottom: 2 solid rgb(128,128,128)"

bgcolor="#C0C0C0" align="center"><p align="center"><strong><small>&nbsp;&nbsp;<a href="http://www.cisco.com/warp/public/779/smbiz/prodconfig/help/eag/air/ap3xx/SetRouting.shm.htm" target="00409637e8d0Help"><font color="#000000">Help</font></a>&nbsp;&nbsp;</small></strong></td>

</tr></table>



</td>

<td valign="middle"><p align="center"><small>Uptime: 1 day, 01:38:35</small></td>

</tr>

<tr>

<td style="border-bottom:" valign="top" colspan="2"><form method="POST"

action="/cgi-bin/cgiSetupNav?formPostProcess=cgiPostProcessSetRouting&NoScript=&RefererList=" name="formSetRouting">

<table border="0" cellpadding="0" cellspacing="0" width="100%" bgcolor="#FFFFBD">

<tr>

<td nowrap><strong>Default Gateway</strong>:</td>

<td colspan="2"><input type="text" value="10.100.1.1" name="text_ipRouteNextHop.0.0.0.0" size="20"></td>

</tr>

<tr>

<td nowrap colspan="3"><strong>New Network Route:</strong></td>

</tr>

<tr>

<td nowrap>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<small><strong>Dest Network:</strong></small></td>

<td colspan="2"><input type="text" name="newIpRouteDest" size="20"></td>

</tr>

<tr>

<td nowrap>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<small><strong>Gateway:</strong></small></td>

<td colspan="2"><input type="text" name="newIpRouteNextHop" size="20"></td>

</tr>

<tr>

<td nowrap>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<small><strong>Subnet Mask:</strong></small></td>

<td><input type="text" name="newIpRouteMask" size="20"></td>

<td nowrap><input type="submit" value="    Add    " name="Add"></td>

</tr>

<tr>

<td nowrap colspan="3"><strong>Installed Network Routes:</strong></td>

</tr>

<tr>

<td nowrap valign="top">&nbsp; </td>

<td nowrap valign="top"><select name="oldIpRouteDest" size="5">

</select></td>

<td nowrap valign="top"><input type="submit" value="Remove" name="Remove"></td>

</tr>



</table>

<table border="0" cellpadding="0" cellspacing="0" width="100%" bgcolor="#FFFFBD">

<tr><td width="100%" align="right" colspan="2" valign="bottom" nowrap height="45"><input

type="submit" value="Apply" name="Apply" onClick="return doSubmit('Apply')"><input

type="submit" value="&nbsp;&nbsp;OK&nbsp;&nbsp;" name="OK" onClick="return doSubmit('OK')">&nbsp;&nbsp;<input

type="submit" value="Cancel" name="Cancel">&nbsp;&nbsp;<input

type="submit" value="Restore Defaults" name="Restore" onClick="return doSubmit('Restore')"></td></tr>



</table>

</form>

</td>

</tr>

<tr>

<td valign="middle" colspan="2"><table border="0" width="100%" cellspacing="0" cellpadding="0">

<tr>

<td align="center"><table border="0" width="100%">

<tr><td width="100%" colspan="3" align="center"><hr color="#6AB5FF">

<small>[<a

href="JavaScript: goMap()">Map</a>][<a

href="/login.shm" target="00409637e8d0login">Login</a>][<a

href="http://www.cisco.com/warp/public/779/smbiz/prodconfig/help/eag/air/ap3xx/SetRouting.shm.htm" target="00409637e8d0Help">Help</a>]</small></td></tr>



<tr><td nowrap><small><small>Cisco AP340 11.21</small></small></td>

<td nowrap><font color="#3f3f3f" size="-2">® Copyright 2001 <a

href="http://www.cisco.com">Cisco Systems, Inc.</a></font></td>

<td align="right"><a href="/CiscoLegal.shm"><small><em>credits</em></small></a></td></tr>



</table></td>

</tr>

</table>

</td>

</tr>

</table>

</div>

</body>

</html>



END

$responsesVxWorks->{ifs1} = <<'END';
<html>

<head>

<title>Aironet_340 Ethernet Port</title>

<script LANGUAGE="JavaScript">

<!--



function verifyBrowser() {

var ms = navigator.appVersion.indexOf("MSIE");

ie4 = (ms>0) && (parseInt(navigator.appVersion.substring(ms+5, ms+6)) >= 4);

var ns = navigator.appName.indexOf("Netscape");

ns= (ns>=0) && (parseInt(navigator.appVersion.substring(0,1))>=4);



if (ie4)

return "ie4";

else

if(ns)

return "ns";

else

return false;

}



function addSearchString(inString, appString) {

return (inString.indexOf("?",0)<0)? inString+"?"+appString: inString+"&"+appString;

}



function goMap(newHref) {

var newHref = "map.shm";



if (verifyBrowser() == "ns") {

newHref=addSearchString(newHref, "bv=ns");

}



var newWindow = window.open("", "00409637e8d0Map", "width=350,height=400,resizable=1,scrollbars=1,dependent=0");



if(newWindow.document.title.length== 0){

  newWindow = window.open(newHref, "00409637e8d0Map", "width=350,height=400,resizable=1,scrollbars=1,dependent=0"); 

}



if(newWindow != null && !newWindow.closed ){

  newWindow.focus();

}



}

// -->

</script>



</head>



<body bgcolor="#FFFFFF" leftmargin="4" Text="black" LINK="black" ALINK="black" VLINK="black">

<div align="left">



<table border="0" cellspacing="1" align="left" width="600">

<tr>

<td nowrap><p align="left"><big><strong>Aironet_340</strong></big><font

color="#FF0000"><strong><big><big>&nbsp;&nbsp;&nbsp;Ethernet&nbsp;Port</big></big></strong></font></td>

<td valign="top" align="left"><p align="right"><a href="http://www.cisco.com"><img

alt="Cisco's Homepage" src="CiscoLogo.jpg" border="0"></a></td>

</tr>

<tr>

<td style="border-bottom:" valign="top">

<table border="0" width="100%" cellspacing="1" cellpadding="0"><tr>

<td style="border-left: none; border-right: 2 solid rgb(128,128,128); border-top: none; border-bottom: 2 solid rgb(128,128,128)"

bgcolor="#C0C0C0" align="center"><p align="center"><strong><a href="/index.shm"><small><font color="#000000">Home</font></small></a></strong></td>



<td style="border-left: none; border-right: 2 solid rgb(128,128,128); border-top: none; border-bottom: 2 solid rgb(128,128,128)"

bgcolor="#C0C0C0" align="center"><p align="center"><strong><small><a href="JavaScript: goMap()"><font color="#000000">Map</font></a></small></strong></td>



<td style="border-left: none; border-right: 2 solid rgb(128,128,128); border-top: none; border-bottom: 2 solid rgb(128,128,128)"

bgcolor="#C0C0C0" align="center"><p align="center"><strong><small><a href="/StatsAllNetIf.shm"><font color="#000000">Network</font></a></small></strong></td>



<td style="border-left: none; border-right: 2 solid rgb(128,128,128); border-top: none; border-bottom: 2 solid rgb(128,128,128)"

bgcolor="#C0C0C0" align="center"><p align="center"><strong><small><a href="/ShowAssociations.shm"><font color="#000000">Associations</font></a></small></strong></td>



<td style="border-left: none; border-right: 2 solid rgb(128,128,128); border-top: none; border-bottom: 2 solid rgb(128,128,128)"

bgcolor="#C0C0C0" align="center"><p align="center"><strong><small><a href="/Setup.shm"><font color="#000000">Setup</font></a></small></strong></td>



<td style="border-left: none; border-right: 2 solid rgb(128,128,128); border-top: none; border-bottom: 2 solid rgb(128,128,128)"

bgcolor="#C0C0C0" align="center"><p align="center"><strong><small><a href="/ShowEvents.shm"><font color="#000000">Logs</font></a></small></strong></td>



<td style="border-left: none; border-right: 2 solid rgb(128,128,128); border-top: none; border-bottom: 2 solid rgb(128,128,128)"

bgcolor="#C0C0C0" align="center"><p align="center"><strong><small><a href="http://www.cisco.com/warp/public/779/smbiz/prodconfig/help/eag/air/ap3xx/StatsEthernet.shm.htm" target="00409637e8d0Help"><font color="#000000">Help</font></a></small></strong></td>



</tr></table>



</td>

<td valign="middle"><p align="center"><small>Uptime: 1 day, 01:38:36</small> </td>

</tr>

<tr>

<td colspan="2" align="left"><form method="POST" action="/cgi-bin/cgiShowPortApply?ifIndex=1">

<table border="1" cellpadding="0" cellspacing="0" width="100%">

<tr><td colspan="4"><table border="0" cellpadding="2" cellspacing="0" width="100%">

<tr><td bgcolor="#FFFFBD" colspan="2" width="50%" style="border-right: medium none"><big><strong>&nbsp;Configuration</strong></big></td>

<td bgcolor="#FFFFBD" colspan="2" style="border-left: medium none" align="right"><small><strong>&nbsp;

<a href="/SetHwEthernet.shm?ifIndex=1">Set Properties</a> &nbsp; </strong></small></td>

</tr></table></td></tr>

<tr>
<td><font size="2">&nbsp;Status of &quot;fec0&quot;</font></td>
<td align="right"><font size="2"><font color="green">Up</font>&nbsp;&nbsp;(primary)</font>&nbsp;&nbsp;</td>
<td><font size="2">&nbsp;Maximum Rate (Mb/s)</font></td>
<td align="right"><font size="2">100.0</font>&nbsp;&nbsp;</td>
</tr><tr>
<td><font size="2">&nbsp;IP Address</font></td>
<td align="right"><font size="2">10.100.1.2</font>&nbsp;&nbsp;</td>
<td><font size="2">&nbsp;MAC Address</font></td>
<td align="right"><font size="2">00409637e8d0</font>&nbsp;&nbsp;</td>
</tr>
<tr>
<td><small>&nbsp;Duplex</small></td><td align="right"><small>Full&nbsp;&nbsp;</small></td><td><small>&nbsp;</small></td><td align="right"><small>&nbsp;&nbsp;</small></td></tr>


<tr><td colspan="4"><table border="0" cellpadding="2" cellspacing="0" width="100%">

<tr><td bgcolor="#FFFFBD" colspan="2" width="50%" style="border-right: medium none"><big><strong>&nbsp;Statistics</strong></big></td>

<td bgcolor="#FFFFBD" colspan="2" style="border-left: medium none" align="right"><small><input type="submit" value="Refresh" name="refresh"></small></td>

</tr></table></td></tr>

<tr bgcolor="#CFCFCF">
<td width="50%" colspan="2"><table width="100%" border="0" cellspacing="0" cellpadding="0"><tr><td width="25%">&nbsp;</td><td nowrap width="50%" align="center"><strong>Receive</strong></td><td width="25%" align="right">&nbsp;<font color="blue"><small><em>Alert</em>&nbsp;<input type="checkbox" name="alertSrc" value="T" ></small></font></td></tr></table></td>
<td width="50%" colspan="2"><table width="100%" border="0" cellspacing="0" cellpadding="0"><tr><td width="25%">&nbsp;</td><td nowrap width="50%" align="center"><strong>Transmit</strong></td><td width="25%" align="right"><font color="blue"><small><em>Alert</em>&nbsp;<input type="checkbox" name="alertDest" value="T" ></small></font></td></tr></table></td>
</tr>
<tr>
<td><small>&nbsp;Unicast Packets</small></td><td align="right"><small>59848&nbsp;&nbsp;</small></td>
<td><small>&nbsp;Unicast Packets</small></td><td align="right"><small>53452&nbsp;&nbsp;</small></td>
</tr><tr>
<td><small>&nbsp;Multicast Packets</small></td><td align="right"><small>108367&nbsp;&nbsp;</small></td>
<td><small>&nbsp;Multicast Packets</small></td><td align="right"><small>8008&nbsp;&nbsp;</small></td>
</tr><tr>
<td><small>&nbsp;Total Bytes</small></td><td align="right"><small>11907174&nbsp;&nbsp;</small></td>
<td><small>&nbsp;Total Bytes</small></td><td align="right"><small>10828106&nbsp;&nbsp;</small></td>
</tr><tr>
<td><small>&nbsp;Total Errors</small></td><td align="right"><small>0&nbsp;&nbsp;</small></td>
<td><small>&nbsp;Total Errors</small></td><td align="right"><small>0&nbsp;&nbsp;</small></td>
</tr><tr>
<td><small>&nbsp;Discarded Packets</small></td><td align="right"><small>0&nbsp;&nbsp;</small></td>
<td><small>&nbsp;Discarded Packets</small></td><td align="right"><small>0&nbsp;&nbsp;</small></td>
</tr>
<tr>
<td><small>&nbsp;Forwardable Packets</small></td><td align="right"><small>180571&nbsp;&nbsp;</small></td>
<td><small>&nbsp;Forwarded Packets</small></td><td align="right"><small>121386&nbsp;&nbsp;</small></td>
</tr><tr>
<td><small>&nbsp;Filtered Packets</small></td><td align="right"><small>46036&nbsp;&nbsp;</small></td>
<td align="right"><small>&nbsp;&nbsp;</small></td>
<td align="right"><small>&nbsp;&nbsp;</small></td>
</tr>
<tr bgcolor="#CFCFCF"><td colspan="2"><font size="-3">&nbsp;</font></td>
<td colspan="2"><font size="-3">&nbsp;</font></td></tr>
<tr>
<td><small>&nbsp;Packet CRC Errors</small></td><td align="right"><small>0&nbsp;&nbsp;</small></td><td><small>&nbsp;Max Retry Packets</small></td><td align="right"><small>0&nbsp;&nbsp;</small></td></tr><tr>
<td><small>&nbsp;Carrier Sense Lost</small></td><td align="right"><small>0&nbsp;&nbsp;</small></td><td><small>&nbsp;Total Collisions</small></td><td align="right"><small>0&nbsp;&nbsp;</small></td></tr><tr>
<td><small>&nbsp;Late Collisions</small></td><td align="right"><small>0&nbsp;&nbsp;</small></td><td><small>&nbsp;Late Collisions</small></td><td align="right"><small>0&nbsp;&nbsp;</small></td></tr><tr>
<td><small>&nbsp;Overrun Packets</small></td><td align="right"><small>0&nbsp;&nbsp;</small></td><td><small>&nbsp;Underrun Packets</small></td><td align="right"><small>0&nbsp;&nbsp;</small></td></tr><tr>
<td><small>&nbsp;Packets Too Long</small></td><td align="right"><small>0&nbsp;&nbsp;</small></td><td><small>&nbsp;</small></td><td align="right"><small>&nbsp;&nbsp;</small></td></tr><tr>
<td><small>&nbsp;Packets Too Short</small></td><td align="right"><small>0&nbsp;&nbsp;</small></td><td><small>&nbsp;</small></td><td align="right"><small>&nbsp;&nbsp;</small></td></tr><tr>
<td><small>&nbsp;Packets Truncated</small></td><td align="right"><small>0&nbsp;&nbsp;</small></td><td><small>&nbsp;</small></td><td align="right"><small>&nbsp;&nbsp;</small></td></tr>


</table>

</form></td></tr>

<tr>

<td valign="middle" colspan="2"><table border="0" width="100%" cellspacing="0" cellpadding="0">

<tr>

<td align="center"><table border="0" width="100%">

<tr><td width="100%" colspan="3" align="center"><hr color="#6AB5FF">

<small>[<a href="/index.shm">Home</a>][<a

href="JavaScript: goMap()">Map</a>][<a

href="/login.shm">Login</a>][<a

href="/StatsAllNetIf.shm">Network</a>][<a

href="/ShowAssociations.shm">Associations</a>][<a

href="/Setup.shm">Setup</a>][<a

href="/ShowEvents.shm">Logs</a>][<a

href="http://www.cisco.com/warp/public/779/smbiz/prodconfig/help/eag/air/ap3xx/StatsEthernet.shm.htm" target="00409637e8d0Help">Help</a>]</small></td></tr>



<tr><td nowrap><small><small>Cisco AP340 11.21</small></small></td>

<td nowrap><font color="#3f3f3f" size="-2">® Copyright 2001 <a

href="http://www.cisco.com">Cisco Systems, Inc.</a></font></td>

<td align="right"><a href="/CiscoLegal.shm"><small><em>credits</em></small></a></td></tr>



</table></td>

</tr>

</table>

</td>

</tr>

</table>

</div>

</body>

</html>



END

$responsesVxWorks->{ifi1} = <<'END';
<html>

<head>

<title>Aironet_340 Ethernet Identification</title>

<script LANGUAGE="JavaScript">

<!--



function verifyBrowser() {

var ms = navigator.appVersion.indexOf("MSIE");

ie4 = (ms>0) && (parseInt(navigator.appVersion.substring(ms+5, ms+6)) >= 4);

var ns = navigator.appName.indexOf("Netscape");

ns= (ns>=0) && (parseInt(navigator.appVersion.substring(0,1))>=4);



if (ie4)

return "ie4";

else

if(ns)

return "ns";

else

return false;

}



function addSearchString(inString, appString) {

return (inString.indexOf("?",0)<0)? inString+"?"+appString: inString+"&"+appString;

}



function goMap(newHref) {

var newHref = "map.shm";



if (verifyBrowser() == "ns") {

newHref=addSearchString(newHref, "bv=ns");

}



var newWindow = window.open("", "00409637e8d0Map", "width=350,height=400,resizable=1,scrollbars=1,dependent=0");



if(newWindow.document.title.length== 0){

  newWindow = window.open(newHref, "00409637e8d0Map", "width=350,height=400,resizable=1,scrollbars=1,dependent=0"); 

}



if(newWindow != null && !newWindow.closed ){

  newWindow.focus();

}



}

// -->

</script>



<script LANGUAGE="JavaScript">

<!--

function doSubmit(whichButton) {

if (whichButton == "Apply" || whichButton == "OK") {

  return confirm("The settings shown on this page will be now be updated.\nClick 'OK' to approve.");

} else if (whichButton == "Restore") {

  return confirm("You have requested that ALL settings on this page be reverted to their Factory Defaults!\nAre you SURE you wish to do this?");

} else {

return true;

}

}

// -->

</script>



</head>



<body bgcolor="#FFFFFF" leftmargin="4" Text="black" LINK="black" ALINK="black" VLINK="black">

<div align="left">



<table border="0" cellspacing="1" align="left" width="600">

<tr>

<td nowrap><big><strong>Aironet_340</strong></big><font

color="#FF0000"><big><big><strong>&nbsp;&nbsp;&nbsp;Ethernet&nbsp;Identification</strong></big></big></font></td>

<td valign="top" align="left" rowspan="2"><p align="right"><a href="http://www.cisco.com"><img

alt="Cisco's Homepage" src="CiscoLogo.jpg" border="0"></a></td>

</tr>

<tr>

<td nowrap><strong><font color="#FF0000"><small>Cisco AP340 11.21</small></font></strong></td>

</tr>

<tr>

<td style="border-bottom:" valign="top">

<table border="0" cellspacing="1" cellpadding="0"><tr>

<td style="border-left: none; border-right: 2 solid rgb(128,128,128); border-top: none; border-bottom: 2 solid rgb(128,128,128)"

bgcolor="#C0C0C0" align="center"><p align="center"><strong>&nbsp;&nbsp;<a href="JavaScript: goMap()"><small><font color="#000000">Map</font></small></a>&nbsp;&nbsp;</strong></td>

<td style="border-left: none; border-right: 2 solid rgb(128,128,128); border-top: none; border-bottom: 2 solid rgb(128,128,128)"

bgcolor="#C0C0C0" align="center"><p align="center"><strong><small>&nbsp;&nbsp;<a href="http://www.cisco.com/warp/public/779/smbiz/prodconfig/help/eag/air/ap3xx/SetIdentEthernet.shm.htm" target="00409637e8d0Help"><font color="#000000">Help</font></a>&nbsp;&nbsp;</small></strong></td>

</tr></table>



</td>

<td valign="middle"><p align="center"><small>Uptime: 1 day, 02:37:12</small></td>

</tr>

<tr>

<td style="border-bottom:" valign="top" colspan="2"><form method="POST"

action="/cgi-bin/cgiSetupNav?ifIndex=1&formPreProcess=cgiPreProcessIdent&NoScript=&RefererList=">

<table border="0" cellpadding="0" cellspacing="0" width="592" bgcolor="#FFFFBD">

<tr><td valign="top" nowrap colspan="2" height="40">Primary&nbsp;Port?&nbsp;&nbsp;

<input type="radio" name="radio_awcIfIsPrimary" value="T" checked>yes&nbsp;&nbsp;

<input type="radio" name="radio_awcIfIsPrimary" value="F" >no

&nbsp;&nbsp;&nbsp;&nbsp;Adopt Primary Port Identity?&nbsp;&nbsp;<input type="radio" value="true" checked name="radio_awcIfAdoptPrimaryIdentity">yes&nbsp;&nbsp;<input type="radio" value="false"  name="radio_awcIfAdoptPrimaryIdentity">no</td></tr>

<tr><td nowrap>MAC Addr.:</td>

<td nowrap>00:40:96:37:e8:d0</td></tr>

<tr><td nowrap>Default IP Address:</td>

<td><input type="text" value="10.100.1.2" name="text_awcIfDefaultIpAddress" size="17"></td></tr>

<tr><td nowrap>Default IP Subnet Mask: </td>

<td><input type="text" value="255.255.255.0" name="text_awcIfDefaultIpNetMask" size="17"></td></tr>

<tr><td nowrap>Current IP Address:</td>

<td nowrap>10.100.1.2</td></tr>

<tr><td nowrap>Current IP Subnet Mask:</td>

<td nowrap>255.255.255.0</td></tr>

<tr><td nowrap>Maximum Packet Data Length:</td>

<td nowrap>1500</td></tr>



<tr><td width="100%" align="right" colspan="2" valign="bottom" nowrap height="45"><input

type="submit" value="Apply" name="Apply" onClick="return doSubmit('Apply')"><input

type="submit" value="&nbsp;&nbsp;OK&nbsp;&nbsp;" name="OK" onClick="return doSubmit('OK')">&nbsp;&nbsp;<input

type="submit" value="Cancel" name="Cancel">&nbsp;&nbsp;<input

type="submit" value="Restore Defaults" name="Restore" onClick="return doSubmit('Restore')"></td></tr>



</table>

</form>

</td>

</tr>

<tr>

<td valign="middle" colspan="2"><table border="0" width="100%" cellspacing="0" cellpadding="0">

<tr>

<td align="center"><table border="0" width="100%">

<tr><td width="100%" colspan="3" align="center"><hr color="#6AB5FF">

<small>[<a

href="JavaScript: goMap()">Map</a>][<a

href="/login.shm" target="00409637e8d0login">Login</a>][<a

href="http://www.cisco.com/warp/public/779/smbiz/prodconfig/help/eag/air/ap3xx/SetIdentEthernet.shm.htm" target="00409637e8d0Help">Help</a>]</small></td></tr>



<tr><td nowrap><small><small>Cisco AP340 11.21</small></small></td>

<td nowrap><font color="#3f3f3f" size="-2">® Copyright 2001 <a

href="http://www.cisco.com">Cisco Systems, Inc.</a></font></td>

<td align="right"><a href="/CiscoLegal.shm"><small><em>credits</em></small></a></td></tr>



</table></td>

</tr>

</table>

</td>

</tr>

</table>

</div>

</body>

</html>


END

$responsesVxWorks->{ifi2} = <<'END';
<html>

<head>

<title>Aironet_340 AP&nbsp;Radio Identification</title>

<script LANGUAGE="JavaScript">

<!--



function verifyBrowser() {

var ms = navigator.appVersion.indexOf("MSIE");

ie4 = (ms>0) && (parseInt(navigator.appVersion.substring(ms+5, ms+6)) >= 4);

var ns = navigator.appName.indexOf("Netscape");

ns= (ns>=0) && (parseInt(navigator.appVersion.substring(0,1))>=4);



if (ie4)

return "ie4";

else

if(ns)

return "ns";

else

return false;

}



function addSearchString(inString, appString) {

return (inString.indexOf("?",0)<0)? inString+"?"+appString: inString+"&"+appString;

}



function goMap(newHref) {

var newHref = "map.shm";



if (verifyBrowser() == "ns") {

newHref=addSearchString(newHref, "bv=ns");

}



var newWindow = window.open("", "00409637e8d0Map", "width=350,height=400,resizable=1,scrollbars=1,dependent=0");



if(newWindow.document.title.length== 0){

  newWindow = window.open(newHref, "00409637e8d0Map", "width=350,height=400,resizable=1,scrollbars=1,dependent=0"); 

}



if(newWindow != null && !newWindow.closed ){

  newWindow.focus();

}



}

// -->

</script>



<script LANGUAGE="JavaScript">

<!--

function doSubmit(whichButton) {

if (whichButton == "Apply" || whichButton == "OK") {

  return confirm("The settings shown on this page will be now be updated.\nClick 'OK' to approve.");

} else if (whichButton == "Restore") {

  return confirm("You have requested that ALL settings on this page be reverted to their Factory Defaults!\nAre you SURE you wish to do this?");

} else {

return true;

}

}

// -->

</script>



</head>



<body bgcolor="#FFFFFF" leftmargin="4" Text="black" LINK="black" ALINK="black" VLINK="black">

<div align="left">



<table border="0" cellspacing="1" align="left" width="600"> 

<tr>

<td nowrap><big><strong>Aironet_340</strong></big><font

color="#FF0000"><big><big><strong>&nbsp;&nbsp;&nbsp;AP&nbsp;Radio&nbsp;Identification</strong></big></big></font></td>

<td valign="top" align="left" rowspan="2"><p align="right"><a href="http://www.cisco.com"><img

alt="Cisco's Homepage" src="CiscoLogo.jpg" border="0"></a></td>

</tr>

<tr>

<td nowrap><strong><font color="#FF0000"><small>Cisco AP340 11.21</small></font></strong></td>

</tr>

<tr>

<td style="border-bottom:" valign="top">

<table border="0" cellspacing="1" cellpadding="0"><tr>

<td style="border-left: none; border-right: 2 solid rgb(128,128,128); border-top: none; border-bottom: 2 solid rgb(128,128,128)"

bgcolor="#C0C0C0" align="center"><p align="center"><strong>&nbsp;&nbsp;<a href="JavaScript: goMap()"><small><font color="#000000">Map</font></small></a>&nbsp;&nbsp;</strong></td>

<td style="border-left: none; border-right: 2 solid rgb(128,128,128); border-top: none; border-bottom: 2 solid rgb(128,128,128)"

bgcolor="#C0C0C0" align="center"><p align="center"><strong><small>&nbsp;&nbsp;<a href="http://www.cisco.com/warp/public/779/smbiz/prodconfig/help/eag/air/ap3xx/SetIdentPC4800.shm.htm" target="00409637e8d0Help"><font color="#000000">Help</font></a>&nbsp;&nbsp;</small></strong></td>

</tr></table>



</td>

<td valign="middle"><p align="center"><small>Uptime: 1 day, 02:37:13</small></td>

</tr>

<tr>

<td style="border-bottom:" valign="top" colspan="2"><form method="POST"

action="/cgi-bin/cgiSetupNav?ifIndex=2&formPreProcess=cgiPreProcessIdent&NoScript=&RefererList=">

<table border="0" cellpadding="0" cellspacing="0" width="592" bgcolor="#FFFFBD">

<tr><td valign="top" nowrap colspan="2" height="40">Primary&nbsp;Port?&nbsp;&nbsp;

<input type="radio" name="radio_awcIfIsPrimary" value="T" >yes&nbsp;&nbsp;

<input type="radio" name="radio_awcIfIsPrimary" value="F" checked>no

&nbsp;&nbsp;&nbsp;&nbsp;Adopt Primary Port Identity?&nbsp;&nbsp;<input type="radio" value="true" checked name="radio_awcIfAdoptPrimaryIdentity">yes&nbsp;&nbsp;<input type="radio" value="false"  name="radio_awcIfAdoptPrimaryIdentity">no</td></tr>

<tr><td nowrap>MAC Addr.:</td>

<td nowrap>00:40:96:36:f3:5b</td></tr>

<tr><td nowrap>Default IP Address:</td>

<td><input type="text" value="10.0.0.2" name="text_awcIfDefaultIpAddress" size="17"></td></tr>

<tr><td nowrap>Default IP Subnet Mask: </td>

<td><input type="text" value="255.255.255.0" name="text_awcIfDefaultIpNetMask" size="17"></td></tr>

<tr><td nowrap>Current IP Address:</td>

<td nowrap>10.100.1.2</td></tr>

<tr><td nowrap>Current IP Subnet Mask:</td>

<td nowrap>255.255.255.0</td></tr>

<tr><td nowrap>Maximum Packet Data Length:</td>

<td nowrap>2304</td></tr>



<tr><td nowrap valign="bottom" height="40">Service Set ID (SSID):</td>

<td valign="bottom"><input type="text" value="lab_cisco340" name="text_dot11DesiredSSID" size="32"></td></tr>

<tr><td nowrap>LEAP User Name:</td>

<td><input type="text" value="" name="text_awcDot11LEAPUserName" size="32"></td></tr>

<tr><td nowrap>LEAP Password:</td>

<td><input type="password" value="{`NOCHANGE`}" name="password_awcDot11LEAPPassword" size="32" autocomplete="off"></td></tr>

<tr><td nowrap>Firmware Version:</td>

<td nowrap>5.02.02</td></tr>

<tr><td nowrap>Boot Block Version:</td>

<td nowrap>1.43</td></tr>



<tr><td width="100%" align="right" colspan="2" valign="bottom" nowrap height="45"><input

type="submit" value="Apply" name="Apply" onClick="return doSubmit('Apply')"><input

type="submit" value="&nbsp;&nbsp;OK&nbsp;&nbsp;" name="OK" onClick="return doSubmit('OK')">&nbsp;&nbsp;<input

type="submit" value="Cancel" name="Cancel">&nbsp;&nbsp;<input

type="submit" value="Restore Defaults" name="Restore" onClick="return doSubmit('Restore')"></td></tr>



</table>

</form>

</td>

</tr>

<tr>

<td valign="middle" colspan="2"><table border="0" width="100%" cellspacing="0" cellpadding="0">

<tr>

<td align="center"><table border="0" width="100%">

<tr><td width="100%" colspan="3" align="center"><hr color="#6AB5FF">

<small>[<a

href="JavaScript: goMap()">Map</a>][<a

href="/login.shm" target="00409637e8d0login">Login</a>][<a

href="http://www.cisco.com/warp/public/779/smbiz/prodconfig/help/eag/air/ap3xx/SetIdentPC4800.shm.htm" target="00409637e8d0Help">Help</a>]</small></td></tr>



<tr><td nowrap><small><small>Cisco AP340 11.21</small></small></td>

<td nowrap><font color="#3f3f3f" size="-2">® Copyright 2001 <a

href="http://www.cisco.com">Cisco Systems, Inc.</a></font></td>

<td align="right"><a href="/CiscoLegal.shm"><small><em>credits</em></small></a></td></tr>



</table></td>

</tr>

</table>

</td>

</tr>

</table>

</div>

</body>

</html>


END

$responsesVxWorks->{ifs2} = <<'END';
<html>
<head>
<title>Aironet_340 AP&nbsp;Radio Port</title>
<script LANGUAGE="JavaScript">
<!--

function verifyBrowser() {
var ms = navigator.appVersion.indexOf("MSIE");
ie4 = (ms>0) && (parseInt(navigator.appVersion.substring(ms+5, ms+6)) >= 4);
var ns = navigator.appName.indexOf("Netscape");
ns= (ns>=0) && (parseInt(navigator.appVersion.substring(0,1))>=4);

if (ie4)
return "ie4";
else
if(ns)
return "ns";
else
return false;
}

function addSearchString(inString, appString) {
return (inString.indexOf("?",0)<0)? inString+"?"+appString: inString+"&"+appString;
}

function goMap(newHref) {
var newHref = "map.shm";

if (verifyBrowser() == "ns") {
newHref=addSearchString(newHref, "bv=ns");
}

var newWindow = window.open("", "00409637e8d0Map", "width=350,height=400,resizable=1,scrollbars=1,dependent=0");

if(newWindow.document.title.length== 0){
  newWindow = window.open(newHref, "00409637e8d0Map", "width=350,height=400,resizable=1,scrollbars=1,dependent=0"); 
}

if(newWindow != null && !newWindow.closed ){
  newWindow.focus();
}

}
// -->
</script>

</head>

<body bgcolor="#FFFFFF" leftmargin="4" Text="black" LINK="black" ALINK="black" VLINK="black">
<div align="left">

<table border="0" cellspacing="1" align="left" width="600">
<tr>
<td nowrap><p align="left"><big><strong>Aironet_340</strong></big><font
color="#FF0000"><strong><big><big>&nbsp;&nbsp;&nbsp;AP&nbsp;Radio&nbsp;Port</big></big></strong></font></td>
<td valign="top" align="left"><p align="right"><a href="http://www.cisco.com"><img
alt="Cisco's Homepage" src="CiscoLogo.jpg" border="0"></a></td>
</tr>
<tr>
<td style="border-bottom:" valign="top">
<table border="0" width="100%" cellspacing="1" cellpadding="0"><tr>
<td style="border-left: none; border-right: 2 solid rgb(128,128,128); border-top: none; border-bottom: 2 solid rgb(128,128,128)"
bgcolor="#C0C0C0" align="center"><p align="center"><strong><a href="/index.shm"><small><font color="#000000">Home</font></small></a></strong></td>

<td style="border-left: none; border-right: 2 solid rgb(128,128,128); border-top: none; border-bottom: 2 solid rgb(128,128,128)"
bgcolor="#C0C0C0" align="center"><p align="center"><strong><small><a href="JavaScript: goMap()"><font color="#000000">Map</font></a></small></strong></td>

<td style="border-left: none; border-right: 2 solid rgb(128,128,128); border-top: none; border-bottom: 2 solid rgb(128,128,128)"
bgcolor="#C0C0C0" align="center"><p align="center"><strong><small><a href="/StatsAllNetIf.shm"><font color="#000000">Network</font></a></small></strong></td>

<td style="border-left: none; border-right: 2 solid rgb(128,128,128); border-top: none; border-bottom: 2 solid rgb(128,128,128)"
bgcolor="#C0C0C0" align="center"><p align="center"><strong><small><a href="/ShowAssociations.shm"><font color="#000000">Associations</font></a></small></strong></td>

<td style="border-left: none; border-right: 2 solid rgb(128,128,128); border-top: none; border-bottom: 2 solid rgb(128,128,128)"
bgcolor="#C0C0C0" align="center"><p align="center"><strong><small><a href="/Setup.shm"><font color="#000000">Setup</font></a></small></strong></td>

<td style="border-left: none; border-right: 2 solid rgb(128,128,128); border-top: none; border-bottom: 2 solid rgb(128,128,128)"
bgcolor="#C0C0C0" align="center"><p align="center"><strong><small><a href="/ShowEvents.shm"><font color="#000000">Logs</font></a></small></strong></td>

<td style="border-left: none; border-right: 2 solid rgb(128,128,128); border-top: none; border-bottom: 2 solid rgb(128,128,128)"
bgcolor="#C0C0C0" align="center"><p align="center"><strong><small><a href="http://www.cisco.com/warp/public/779/smbiz/prodconfig/help/eag/air/ap3xx/StatsPC4800.shm.htm" target="00409637e8d0Help"><font color="#000000">Help</font></a></small></strong></td>

</tr></table>

</td>
<td valign="middle"><p align="center"><small>Uptime: 1 day, 02:49:05</small> </td>
</tr>

<tr>
<td colspan="2" align="left"><form method="POST" action="/cgi-bin/cgiShowA500Apply?ifIndex=2" align="center">
<center><table border="0" cellpadding="0" cellspacing="0" width="100%">
<tr>
<td bgcolor="#FFFFD2" nowrap><strong>Options</strong>:<small>&nbsp;&nbsp;&nbsp;
Detailed Config.<input type="checkbox" name="showDetailedConfigBox" >&nbsp;&nbsp;
Detailed Stats.<input type="checkbox" name="showDetailedStatsBox" >&nbsp;&nbsp;
Individual Rates<input type="checkbox" name="showIndividualRatesBox" >
</small></td>
<td bgcolor="#FFFFD2" nowrap align="right"><small>
<input type="submit" value="Apply" name="apply">
</small></td>
</tr>

</table>
</center>
</td>
</tr>
<tr>
<td colspan="2" align="left">
<table border="1" cellpadding="0" cellspacing="0" width="100%">
<tr><td colspan="4"><table border="0" cellpadding="2" cellspacing="0" width="100%">
<tr><td bgcolor="#FFFFBD" colspan="2" width="50%" style="border-right: medium none"><big><strong>&nbsp;Configuration</strong></big></td>
<td bgcolor="#FFFFBD" colspan="2" style="border-left: medium none" align="right"><small><strong>&nbsp;
<a href="/SetHwPC4800.shm?ifIndex=2">Set Properties</a> &nbsp; </strong></small></td>
</tr></table></td></tr>
<tr>
<td><font size="2">&nbsp;Status of &quot;awc0&quot;</font></td>
<td align="right"><font size="2"><font color="green">Up</font></font>&nbsp;&nbsp;</td>
<td><font size="2">&nbsp;Maximum Rate (Mb/s)</font></td>
<td align="right"><font size="2">11.0</font>&nbsp;&nbsp;</td>
</tr><tr>
<td><font size="2">&nbsp;IP Address</font></td>
<td align="right"><font size="2">10.100.1.2</font>&nbsp;&nbsp;</td>
<td><font size="2">&nbsp;MAC Address</font></td>
<td align="right"><font size="2">00409637e8d0</font>&nbsp;&nbsp;</td>
</tr>
<tr>
<td><small>&nbsp;SSID</small></td><td align="right"><small>lab_cisco340&nbsp;&nbsp;</small></td><td><small>&nbsp;</small></td><td align="right"><small>&nbsp;&nbsp;</small></td></tr><tr>
<td><small>&nbsp;Operational Rates (Mb/s)</small></td><td align="right"><small><font color="green">1.0B</font>, <font color="green">2.0B</font>, <font color="green">5.5B</font>, <font color="green">11.0B</font>&nbsp;&nbsp;</small></td><td><small>&nbsp;Transmit Power (mW)</small></td><td align="right"><small>1&nbsp;&nbsp;</small></td></tr>

<tr><td colspan="4"><table border="0" cellpadding="2" cellspacing="0" width="100%">
<tr><td bgcolor="#FFFFBD" colspan="2" width="50%" style="border-right: medium none"><big><strong>&nbsp;Statistics</strong></big></td>
<td bgcolor="#FFFFBD" colspan="2" style="border-left: medium none" align="right"><small><input type="submit" value="Refresh" name="refresh"></small></td>
</tr></table></td></tr>
<tr bgcolor="#CFCFCF">
<td width="50%" colspan="2"><table width="100%" border="0" cellspacing="0" cellpadding="0"><tr><td width="25%">&nbsp;</td><td nowrap width="50%" align="center"><strong>Receive</strong></td><td width="25%" align="right">&nbsp;<font color="blue"><small><em>Alert</em>&nbsp;<input type="checkbox" name="alertSrc" value="T" ></small></font></td></tr></table></td>
<td width="50%" colspan="2"><table width="100%" border="0" cellspacing="0" cellpadding="0"><tr><td width="25%">&nbsp;</td><td nowrap width="50%" align="center"><strong>Transmit</strong></td><td width="25%" align="right"><font color="blue"><small><em>Alert</em>&nbsp;<input type="checkbox" name="alertDest" value="T" ></small></font></td></tr></table></td>
</tr>
<tr>
<td><small>&nbsp;Unicast Packets</small></td><td align="right"><small>0&nbsp;&nbsp;</small></td>
<td><small>&nbsp;Unicast Packets</small></td><td align="right"><small>0&nbsp;&nbsp;</small></td>
</tr><tr>
<td><small>&nbsp;Multicast Packets</small></td><td align="right"><small>0&nbsp;&nbsp;</small></td>
<td><small>&nbsp;Multicast Packets</small></td><td align="right"><small>0&nbsp;&nbsp;</small></td>
</tr><tr>
<td><small>&nbsp;Total Bytes</small></td><td align="right"><small>0&nbsp;&nbsp;</small></td>
<td><small>&nbsp;Total Bytes</small></td><td align="right"><small>0&nbsp;&nbsp;</small></td>
</tr><tr>
<td><small>&nbsp;Total Errors</small></td><td align="right"><small>0&nbsp;&nbsp;</small></td>
<td><small>&nbsp;Total Errors</small></td><td align="right"><small>0&nbsp;&nbsp;</small></td>
</tr><tr>
<td><small>&nbsp;Discarded Packets</small></td><td align="right"><small>0&nbsp;&nbsp;</small></td>
<td><small>&nbsp;Discarded Packets</small></td><td align="right"><small>0&nbsp;&nbsp;</small></td>
</tr>
<tr>
<td><small>&nbsp;Forwardable Packets</small></td><td align="right"><small>0&nbsp;&nbsp;</small></td>
<td><small>&nbsp;Forwarded Packets</small></td><td align="right"><small>0&nbsp;&nbsp;</small></td>
</tr><tr>
<td><small>&nbsp;Filtered Packets</small></td><td align="right"><small>0&nbsp;&nbsp;</small></td>
<td align="right"><small>&nbsp;&nbsp;</small></td>
<td align="right"><small>&nbsp;&nbsp;</small></td>
</tr>
<tr bgcolor="#CFCFCF"><td colspan="2"><font size="-3">&nbsp;</font></td>
<td colspan="2"><font size="-3">&nbsp;</font></td></tr>
<tr>
<td><small>&nbsp;Packet CRC Errors</small></td><td align="right"><small>193627&nbsp;&nbsp;</small></td><td><small>&nbsp;Max Retry Packets</small></td><td align="right"><small>0&nbsp;&nbsp;</small></td></tr><tr>
<td><small>&nbsp;Packet WEP Errors</small></td><td align="right"><small>0&nbsp;&nbsp;</small></td><td><small>&nbsp;Total Retries</small></td><td align="right"><small>0&nbsp;&nbsp;</small></td></tr><tr>
<td><small>&nbsp;Overrun Packets</small></td><td align="right"><small>0&nbsp;&nbsp;</small></td><td><small>&nbsp;Cancelled Assoc. Lost</small></td><td align="right"><small>0&nbsp;&nbsp;</small></td></tr><tr>
<td><small>&nbsp;Duplicate Packets</small></td><td align="right"><small>0&nbsp;&nbsp;</small></td><td><small>&nbsp;Cancelled AID</small></td><td align="right"><small>0&nbsp;&nbsp;</small></td></tr><tr>
<td><small>&nbsp;Lifetime Exceeded</small></td><td align="right"><small>0&nbsp;&nbsp;</small></td><td><small>&nbsp;Lifetime Exceeded</small></td><td align="right"><small>0&nbsp;&nbsp;</small></td></tr><tr>
<td><small>&nbsp;MIC Packets</small></td><td align="right"><small>0&nbsp;&nbsp;</small></td><td><small>&nbsp;MIC Packets</small></td><td align="right"><small>0&nbsp;&nbsp;</small></td></tr><tr>
<td><small>&nbsp;MIC Errors</small></td><td align="right"><small>0&nbsp;&nbsp;</small></td><td><small>&nbsp;MIC Errors</small></td><td align="right"><small>0&nbsp;&nbsp;</small></td></tr><tr>
<td><small>&nbsp;MIC Sequ. Errors</small></td><td align="right"><small>0&nbsp;&nbsp;</small></td><td><small>&nbsp;&nbsp;</small></td><td align="right"><small>&nbsp;&nbsp;</small></td></tr><tr>
<td><small>&nbsp;MIC Auth. Errors</small></td><td align="right"><small>0&nbsp;&nbsp;</small></td><td><small>&nbsp;&nbsp;</small></td><td align="right"><small>&nbsp;&nbsp;</small></td></tr>

</table>
</form></td></tr>
<tr>
<td valign="middle" colspan="2"><table border="0" width="100%" cellspacing="0" cellpadding="0">
<tr>
<td align="center"><table border="0" width="100%">
<tr><td width="100%" colspan="3" align="center"><hr color="#6AB5FF">
<small>[<a href="/index.shm">Home</a>][<a
href="JavaScript: goMap()">Map</a>][<a
href="/login.shm">Login</a>][<a
href="/StatsAllNetIf.shm">Network</a>][<a
href="/ShowAssociations.shm">Associations</a>][<a
href="/Setup.shm">Setup</a>][<a
href="/ShowEvents.shm">Logs</a>][<a
href="http://www.cisco.com/warp/public/779/smbiz/prodconfig/help/eag/air/ap3xx/StatsPC4800.shm.htm" target="00409637e8d0Help">Help</a>]</small></td></tr>

<tr><td nowrap><small><small>Cisco AP340 11.21</small></small></td>
<td nowrap><font color="#3f3f3f" size="-2">® Copyright 2001 <a
href="http://www.cisco.com">Cisco Systems, Inc.</a></font></td>
<td align="right"><a href="/CiscoLegal.shm"><small><em>credits</em></small></a></td></tr>

</table></td>
</tr>
</table>
</td>
</tr>
</table>
</div>
</body>
</html>

END

