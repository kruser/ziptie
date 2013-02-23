package DataLinksys;

use strict;
use warnings;
use Exporter 'import';
our @EXPORT_OK = qw($services $filters $firewall $home $gateway_to_gateway $dhcp $snmp $network);

our $firewall = <<'END';
<html>
<head><meta name="Pragma" content="No-Cache">
<meta name="GENERATOR" content="Microsoft FrontPage 5.0">
<meta name="ProgId" content="FrontPage.Editor.Document">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Web Management</title>
<base target="_self">
<style fprolloverstyle>A:hover {color: #00FFFF}
.help:link {text-decoration: underline}
.help:visited {text-decoration: underline}
.help:hover {color: #FFCC00; text-decoration: underline}
.logout:link {text-decoration: none}
.logout:visited {text-decoration: none}
.logout:hover {color: #FFCC00; text-decoration: none}
</style>
<style type="text/css">
body {font-family: Verdana, Helvetica, Arial, sans-serif; background-color: #ffffff;}
td, th, input, select {font-size: 11px}
</style>
<link rel="stylesheet" href="nk.css">
<script src="nk20060810141951.js"></script> <!--<script src="nk.js"></script>-->
<script src="lg20060810141951.js"></script> <!--<script src="lg.js"></script>-->
<script language=JavaScript>
function MM_reloadPage(init) {  //reloads the window if Nav4 resized
  if (init==true) with (navigator) {if ((appName=="Netscape")&&(parseInt(appVersion)==4)) {
    document.MM_pgW=innerWidth; document.MM_pgH=innerHeight; onresize=MM_reloadPage; }}
  else if (innerWidth!=document.MM_pgW || innerHeight!=document.MM_pgH) location.reload();
}
MM_reloadPage(true);
function MM_findObj(n, d) { //v4.0
  var p,i,x;  if(!d) d=document; if((p=n.indexOf("?"))>0&&parent.frames.length) {
    d=parent.frames[n.substring(p+1)].document; n=n.substring(0,p);}
  if(!(x=d[n])&&d.all) x=d.all[n]; for (i=0;!x&&i<d.forms.length;i++) x=d.forms[i][n];
  for(i=0;!x&&d.layers&&i<d.layers.length;i++) x=MM_findObj(n,d.layers[i].document);
  if(!x && document.getElementById) x=document.getElementById(n); return x;
}
function MM_showHideLayers() { //v3.0
  var i,p,v,obj,args=MM_showHideLayers.arguments;
  for (i=0; i<(args.length-2); i+=3) if ((obj=MM_findObj(args[i]))!=null) { v=args[i+2];
    if (obj.style) { obj=obj.style; v=(v==\'show\')?\'visible\':(v=\'hide\')?\'hidden\':v; }
    obj.visibility=v; }
}
function chTrust()
{
    if ((document.formf_general.blockJava.checked==false) && (document.formf_general.blockCookies.checked==false) && (document.formf_general.blockActiveX.checked==false) && (document.formf_general.blockProxy.checked==false))
	{
	    document.formf_general.noblockTrusted.checked=false;
		document.formf_general.noblockTrusted.disabled=true;
		if (document.formf_general.local_forbiddenURLs_del) // grey out
		{
		    if ((document.formdualwan.firewall0.value == " checked") || (document.formdualwan.firewall0.value == "")) // prevent endless loop in design mode
		        falseSubmit(document.formf_general);
		}
	}
	else
	    document.formf_general.noblockTrusted.disabled=false;
}
function addSel(t,s)
{
    var p=-1;
    if (t.value == "")
    {
        alert(aTrustedDomain);
	    s.form.forbiddenURLs_add.select();
	    return;
    }
    if (s.form.btnAddToList.value==sUpdateDomain)
    {
      p=-1;
      while (s.form.local_forbiddenURLs_del.options[++p].selected != true);
      
    }	
	
	for (var i=0; i < s.length; i++)
    {
          if (s.options[i].text==t.value)
  	      {
		      if (p != i)
			  {
                  alert(aTrustedDomainAlready);
	              return;
			  }
	      }
    }
	
	for (var i=0; i < s.form.local_forbiddenURLs_del.length; i++)
    {
        s.form.local_forbiddenURLs_del.options[i].selected=false;
    }
	
	if (s.form.btnAddToList.value==sAddtoList)
	{
    	if (s.length==50)
    	{
        	alert(aLimitTrustedDomain);
        	return;
    	}            	
	    p=s.length;
		s.length+=1;
	}	
    
    s.options[p].text=t.value;
	s.options[p].value=t.value;
    clearContent(t);
  
}
function clearContent(I)
{
    blurList2(I.form);
    I.value="";
	MM_showHideLayers(\'btnNew\',\'\',\'hidden\'); 
	I.select();
}
function tmpWord(n)
{
  this.length=n;
  for (var i=1; i<=n; i++)
  this[i]=0;
  return this;
}
function port2to65534Check(I)
{
  var d;
  d=parseInt(I.value,10);
  if (!(d<=65534 && d>=2))
  {
    alert(aPort2to65534Check);
    I.value=I.defaultValue;
    return;
  }
  I.value=d;
}
function delSel(s)
{
  var z;  
  var k;
  if (s.length > 0)
  {
    tmp=new tmpWord(s.length);
	tmpChanged=new tmpWord(s.length); 
    opvtmp=new tmpWord(s.length);
    opvtmpChanged=new tmpWord(s.length);
	 	
    for (var i=0; i < s.length; i++)
	{
	  tmp[i+1]=s.options[i].text;
	  opvtmp[i+1]=s.options[i].value;
	}	
		
    for (var i=0; i < s.length; i++)
	{
	  if (s.options[i].selected==true)
	  { 
		s.options[i].text="";
		s.options[i].value="";
	    tmp[i+1]=" ";
		opvtmp[i+1]=" ";	
		s.options[i].selected=false;
	  }
	}
 
	k=1;
	z=0;
    for (var j=1; j<=s.length; j++) 
	{ 
	     if (tmp[j]!=" ") 
         {
	                     tmpChanged[k]=tmp[j];
						 opvtmpChanged[k]=opvtmp[j];
        			     k++;
         }
		 else
		 {
		 				 z++;
		 }
    }
 
    for (var i=0; i < s.length-z; i++)
	{
 	    s.options[i].text=tmpChanged[i+1];  
        s.options[i].value=opvtmpChanged[i+1];
	    
	}
    s.length-=z;
  }
  clearContent(s.form.forbiddenURLs_add);
}
function exPosion(s)
{
  if (s.length > 0)
  {
    tmp=new tmpWord(s.length);
	tmpChanged=new tmpWord(s.length); 
    opvtmp=new tmpWord(s.length);
    opvtmpChanged=new tmpWord(s.length);
	 	
    for (var i=0; i < s.length; i++)
	{
	  tmp[i+1]=s.options[i].text;
	  opvtmp[i+1]=s.options[i].value;
	}	
		
    for (var i=0; i < s.length; i++)
	{
	  s.options[i].text=tmp[s.length-i];
	  s.options[i].value=opvtmp[s.length-i];
	}
	
    for (var i=0; i < s.length; i++)
	{
	    tmp[i+1]=" ";
		opvtmp[i+1]=" ";	
	}
  }
}
function selAll(s)
{
  if (s.length>0)
  {
    exPosion(s);
    for (var i=0; i < s.length; i++)
    s.options[i].selected=true;
  }
}
function falseSubmit(F)
{
  F.submitStatus.value=0; 
  F.action="f_general.htm#1";
      MM_showHideLayers(\'AutoNumber15\',\'\',\'hide\'); 
F.submit();
}
function showdeleteButton2(F)
{
  F.deleteForbidden.disabled=false;
  F.forbiddenURLs_add.value=F.local_forbiddenURLs_del.options[F.local_forbiddenURLs_del.selectedIndex].text;
  
  F.btnAddToList.value=sUpdateDomain; 
  F.deleteForbidden.disabled=false;
		
  MM_showHideLayers(\'btnNew\',\'\',\'show\');   
}
function blurList2(F)
{
    for (var i=0; i < F.local_forbiddenURLs_del.length; i++)
    {
      F.local_forbiddenURLs_del.options[i].selected=false;
    }
    F.btnAddToList.value=sAddtoList; 
    F.deleteForbidden.disabled=true;
}
function disable_FW1()
{
    var y;
	y=cChangePassword1;
	
    if (document.formf_general.adPassword.value=="admin")
	{
	    document.formf_general.firewall[0].checked=true;
		document.formf_general.firewall[1].checked=false; 
		
	    if (confirm(y))
		window.location.replace("password.htm");
			
	    return;
	}
	else
    disable_FW();
}
function chSH1()
{
    if (document.formf_general.adPassword.value=="admin")
	{
	    document.formf_general.remoteMng[0].checked=false;
		document.formf_general.remoteMng[1].checked=true;

	    if (document.formf_general.https[0].checked==true)
		{
			if (confirm(cChangePassword2))
			window.location.replace("password.htm");
		}
	    else
		{
			if (confirm(cChangePassword3))
			window.location.replace("password.htm");
		}

	    return;
	}
	else
    chSH();
}
function chHttpsSH1()
{
//    if (document.formf_general.adPassword.value=="admin")
//	{
//		document.formf_general.https[0].checked=false;
//		document.formf_general.https[1].checked=true;
//		if (confirm("The Router is currently set to its default password.\\nAs a security measure, you must change the password before the HTTPS feature can be enabled.\\nPress \'Ok\' to change your password, or press \'Cancel\' to leave the HTTPS feature disabled."))
//			window.location.replace("password.htm");
//		return;
//	}
//	else
		chSH();
}
function chSH()
{   
    if (document.formf_general.firewall[1].checked)
	{
	    document.formf_general.rmPort.disabled=true;
	}
	else if (document.formf_general.remoteMng[0].checked)
	{
	    document.formf_general.rmPort.disabled=false;
	}
	else if (document.formf_general.remoteMng[1].checked)
	{
	    document.formf_general.rmPort.disabled=true;	
	}
	
    if (document.formf_general.mtu_auto[0].checked)
	{
	    document.formf_general.bytesMTU.disabled=true;
	}
	else if (document.formf_general.mtu_auto[1].checked)
	{
	    document.formf_general.bytesMTU.disabled=false;	
	}	
}
function enable_FW()
{
  if (document.formf_general.spi0.value==" checked")
  document.formf_general.spi[0].checked=true;
  else 
  document.formf_general.spi[1].checked=true;
    
  if (document.formf_general.dos0.value==" checked")
  document.formf_general.dos[0].checked=true;
  else 
  document.formf_general.dos[1].checked=true;
  
  if (document.formf_general.blockWANReq0.value==" checked")
  document.formf_general.blockWANReq[0].checked=true;
  else 
  document.formf_general.blockWANReq[1].checked=true;
  
  if (document.formf_general.remoteMng0.value==" checked")
  {
      document.formf_general.remoteMng[0].checked=true;
	  document.formf_general.rmPort.disabled=false;
  }
  else 
  {
      document.formf_general.remoteMng[1].checked=true;
	  document.formf_general.rmPort.disabled=true;
  }
  
  
  
  document.formf_general.spi[0].disabled=false;
  document.formf_general.spi[1].disabled=false;
  document.formf_general.dos[0].disabled=false;
  document.formf_general.dos[1].disabled=false;
  document.formf_general.blockWANReq[0].disabled=false;
  document.formf_general.blockWANReq[1].disabled=false;
  document.formf_general.remoteMng[0].disabled=false;
  document.formf_general.remoteMng[1].disabled=false;
//  document.formf_general.passFP[0].disabled=false;
//  document.formf_general.passFP[1].disabled=false;
//  document.formf_general.rmPort.disabled=false;
}
function disable_FW()
{
  document.formf_general.spi[1].checked=true;
  document.formf_general.dos[1].checked=true;
  document.formf_general.blockWANReq[1].checked=true;
  document.formf_general.remoteMng[0].checked=true;  
    
  document.formf_general.spi[0].disabled=true;
  document.formf_general.spi[1].disabled=true;
  document.formf_general.dos[0].disabled=true;
  document.formf_general.dos[1].disabled=true;
  document.formf_general.blockWANReq[0].disabled=true;
  document.formf_general.blockWANReq[1].disabled=true;
  document.formf_general.remoteMng[0].disabled=true;
  document.formf_general.remoteMng[1].disabled=true;
//document.formf_general.passFP[0].disabled=true;
//document.formf_general.passFP[1].disabled=true;
  document.formf_general.rmPort.disabled=true;
}
function chSubmit(F)
{
//  enable_FW();
  if (F.local_forbiddenURLs_del)
  selAll(F.local_forbiddenURLs_del);
  F.submitStatus.value=1;
  window.status=wSave;
      MM_showHideLayers(\'AutoNumber15\',\'\',\'hide\');  
  F.submit();
}
function portCheck(I)
{
  var d;
  d=parseInt(I.value,10);
  if (!(d<=65535 && d>=1))
  {
    alert(aPortCheck);
    I.value=I.defaultValue;
    return;
  }
  I.value=d; 
}
function bytesCheck(I)
{
  var d;
  d=parseInt(I.value,10);
  if (!(d<1501 && d>=68))
  {
    alert(aBytesCheck);
    I.value=I.defaultValue;
    return;
  }
  I.value=d;  
}
function chDMZ()
{
//    if (document.formdualwan.dualwanEnabled.value=="0")
//	{
//	document.formf_general.blockWANReq[0].disabled=true;
//	document.formf_general.blockWANReq[1].disabled=true;
//	}
    if (document.formf_general.firewall[1].checked)
	{
        disable_FW();
	}
}
var wMap=null;
function openMap()
{
  if (wMap==null)
  wMap=window.open(\'map.htm\',\'sitemap\',\'menubar=no,scrollbars,width=670,height=470\');
}
function closeMap()
{
  if (wMap!=null)
  {
    wMap.close();
	wMap=null;
  }
}
function mapTo(p)
{
  document.location.href=p; 
  closeMap(); 
}
function chDismatch()
{
    if (document.formf_general.local_forbiddenURLs_del) document.formf_general.noblockTrusted.checked=true;
	else document.formf_general.noblockTrusted.checked=false; 
}
window.onfocus=closeMap;
</script>
</head>
<body link="#B5B5E6" vlink="#B5B5E6" alink="#B5B5E6" onLoad="chDismatch(); chDMZ(); chSH(); chTrust();" onUnLoad="closeMap()">
<DIV align=center>
   
  <table border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse" bordercolor="#111111" id="AutoNumber11" width="960" height="68">
    <tr> 
      <td valign="bottom" width="650" hetght="39" bgcolor="#6666CC"> <img border="0" src="images_rv042/clinksys.gif" width="165" height="57" align="middle"> 
      </td>
      <td valign="bottom" bgcolor="#6666CC" width="337"> 
        <div align="right"><font color="#FFFFFF"> <span style="font-size: 7pt">&nbsp;&nbsp;&nbsp;&nbsp;<font face="Arial"> 
          Firmware Version: 1.3.7.10</font></span><font face="Arial"><span style="font-size: 7pt">&nbsp;&nbsp;&nbsp;</span></font></font></div>
      </td>
    </tr>
    <tr> 
      <td colspan="2" valign="top"> <img border="0" src="images_rv042/UI_10.gif" width="960" height="11"></td>
    </tr>
  </table>
   
  
   
  <TABLE height=90 cellSpacing=0 cellPadding=0 width=960 bgColor=black border=0>
    <form name="formdualwan" method="post" action="">
      <input type="hidden" name="dualwanEnabled" value=\'0\'>
      <input type="hidden" name="firewall0" value=\'\'>
    </form>
    <TR> 
      <TD width="150" height=90 rowspan="3" align=middle bordercolor="#000000" bgColor=black style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"> 
        <H3 style="margin-top: 1; margin-bottom: 1" align="center"> <font color="#FFFFFF" face="Arial">Firewall</font></H3></TD>
      <TD width=690 height=33 align="center" vAlign=middle bordercolor="#000000" bgColor=#6666CC style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"> 
        <p align="right"><b><font color="#FFFFFF"><span lang="en-us"> 10/100 4-port 
          VPN Router&nbsp;&nbsp;&nbsp;&nbsp;</span></font></b> </TD>
      <TD vAlign=center width=120 bgColor=#000000 style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black" bordercolor="#000000"> 
        <p align="center"><font color="#FFFFFF"> <span style="font-size: 8pt"><b>RV042</b></span></font> 
      </TD>
    </TR>
    <TR> 
      <TD height=36 colspan="2" vAlign=center bordercolor="#000000" bgColor=#000000 style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"><table width="810" border="0" cellspacing="0" cellpadding="0" >
          <!--DWLayoutTable-->
          <tr  align="center"> 
            <td width="100" height="8" valign="middle" background="images_rv042/UI_06.gif" style=""></td>
            <td width="80" valign="middle" background="images_rv042/UI_06.gif"style=""></td>
            <td width="70" valign="middle" background="images_rv042/UI_06.gif"style=""></td>
            <td width="110" valign="middle" background="images_rv042/UI_06.gif"style=""></td>
            <td width="80" valign="middle" background="images_rv042/UI_07.gif"style=""></td>
            <td width="60" valign="middle" background="images_rv042/UI_06.gif"style=""></td>
            <td width="60" valign="middle" background="images_rv042/UI_06.gif"style=""></td>
            <td width="80" valign="middle" background="images_rv042/UI_06.gif"style=""></td>
            <td width="85" valign="middle" background="images_rv042/UI_06.gif"style=""></td>
            <td width="85" valign="middle" background="images_rv042/UI_06.gif"style=""></td>
          </tr>
          <tr  align="center" valign="middle"> 
            <td height="28" style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"> 
              <p align="center" style="margin-bottom: 4"> <b> <a class="mainmenu" href="home.htm" style="font-size: 8pt; text-decoration: none; font-weight:700"> 
                System<br>
                Summary</a></b> </td>
            <td bgcolor="#000000" style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"> 
              <p style="margin-top: 0; margin-bottom: 4"><b> <a class="mainmenu" href="network.htm" style="font-size: 8pt; text-decoration: none; font-weight:700">Setup</a></b> 
            </td>
            <td bgcolor="#000000" style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"> 
              <p style="margin-bottom: 4"> <b> <a class="mainmenu" href="dhcp_setup.htm" style="font-size: 8pt; text-decoration: none; font-weight:700">DHCP</a></b> 
            </td>
            <td bgcolor="#000000" style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"> 
              <p style="margin-bottom: 4"> <b> 
                <script>
          if (document.formdualwan.dualwanEnabled.value=="1") 
		  	  document.write(\'<a class="mainmenu" href="sys_dualwanw.htm" style="font-size: 8pt; text-decoration: none; font-weight:700">\');
          else document.write(\'<a class="mainmenu" href="sys_dualwan3.htm" style="font-size: 8pt; text-decoration: none; font-weight:700">\');
          </script>
                System<br>
                Management </a></b> </td>
            <td bgcolor="#6666CC" style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"> 
              <p style="margin-bottom: 4"><b> <font color="#FFFFFF" style="font-size: 8pt"> 
                Firewall</font></b> </td>
            <td bgcolor="#000000" style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"> 
              <p style="margin-bottom: 4"> <b> <a class="mainmenu" href="vpn_summary.htm" style="font-size: 8pt; text-decoration: none; font-weight:700">VPN</a></b> 
            </td>
            <td bgcolor="#000000" style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"> 
              <p style="margin-bottom: 4"> <b> <a class="mainmenu" href="log_setting.htm" style="font-size: 8pt; text-decoration: none; font-weight:700">Log</a></b> 
            </td>
            <td bgcolor="#000000" style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"> 
              <p style="margin-bottom: 4"> <b> <a class="mainmenu" href="wizard.htm" style="font-size: 8pt; text-decoration: none; font-weight:700">Wizard</a></b> 
            </td>
            <td bgcolor="#000000" style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"> 
              <p style="margin-bottom: 4"> <b> <a class="mainmenu" href="support.htm" style="font-size: 8pt; text-decoration: none; font-weight:700">Support</a></b> 
            </td>
            <td bgcolor="#000000" style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"> 
              <p style="margin-bottom: 4"> <b> <a class="mainmenu" href="javascript: window.close()" style="font-size: 8pt; text-decoration: none; font-weight:700">Logout</a></b> 
            </td>
          </tr>
        </table></TD>
    </TR>
    <TR> 
      <TD height=21 colspan="2" vAlign=center bordercolor="#000000" bgColor=#6666CC style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"><table width="810" border="0" cellspacing="0" cellpadding="0">
          <!--DWLayoutTable-->
          <tr align="center" valign="middle"> 
            <td width="82" rowspan="2"> 
              <p align="center"> <span style="font-size: 8pt; background-color:#6666CC"> 
                <font color="#FFFFFF"> 
                <!--f_general
                      <a class="submenu" href="f_general.htm" style="text-decoration: none"> 
                      f_general-->
                General 
                <!--f_general
                      </a> 
                      f_general-->
                </font> </span> </td>
            <td width="3" height="21" > <table border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse; border-left-style: solid; border-left-width: 2" bordercolor="#FFFFFF" id="AutoNumber14" height="10" width="3">
                <tr> 
                  <td width="1" height="12" align="center" valign="middle"></td>
                </tr>
              </table></td>
            <td width="104" rowspan="2" > <p align="center"> <span style="font-size: 8pt; background-color:#6666CC"> 
                <font color="#FFFFFF"> 
                <!--access_rules-->
                <script>
if (document.formdualwan.firewall0.value=="") document.write(\'<a class="submenu" href="access_rules0.htm" style="text-decoration: none">\'); 					  
else document.write(\'<a class="submenu" href="access_rules.htm" style="text-decoration: none">\'); 
</script>
                <!--access_rules-->
                Access Rules 
                <!--access_rules-->
                <!--access_rules-->
                </font> </span> </td>
            <td width="3" rowspan="2" > <table border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse; border-left-style: solid; border-left-width: 2" bordercolor="#FFFFFF" id="AutoNumber14" height="10" width="3">
                <tr> 
                  <td width="1" height="12" align="center" valign="middle"></td>
                </tr>
              </table></td>
            <td width="102" rowspan="3" > <p align="center"> <span style="font-size: 8pt; background-color:#6666CC"> 
                <font color="#FFFFFF"> 
                <!--content_filter-->
                <script>
if (document.formdualwan.firewall0.value=="") document.write(\'<a class="submenu" href="content_filter0.htm" style="text-decoration: none">\'); 		  
else document.write(\'<a class="submenu" href="content_filter.htm" style="text-decoration: none">\');
</script>
                <!--content_filter-->
                Content Filter 
                <!--content_filter-->
                <!--content_filter-->
                </font> </span> </td>
            <td width="516"></td>
          </tr>
        </table></TD>
    </TR>
  </TABLE>
  <TABLE height=5 cellSpacing=0 cellPadding=0 width=960 bgColor=black border=0>  
  <TR bgColor=black>
    <TD width=150 height=1 style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; font-family: Arial, Helvetica, sans-serif; color: black" bgcolor="#E7E7E7" bordercolor="#E7E7E7">
			<img border="0" src="images_rv042/UI_03.gif" width="150" height="15"></TD>
    <TD width=810 height=1 style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; font-family: Arial, Helvetica, sans-serif; color: black" bgcolor="#FFFFFF">
			<img border="0" src="images_rv042/UI_02.gif" width="810" height="15"></TD></TR>
  </TABLE>
			
  <table border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse" bordercolor="#111111" id="AutoNumber9" width="961">
    <form name="formf_general" method="post" action="f_general.htm" onSubmit=" bytesCheck(this.bytesMTU)">
      <tr> 
        <td height="25" valign="middle" bgcolor="#000000" bordercolor="#E7E7E7" bordercolorlight="#E7E7E7" bordercolordark="#E7E7E7" width="142" align="right"><font face="Arial, Helvetica, sans-serif"><b><font color="#FFFFFF">General</font></b> 
          </font></td>
        <td width="8" valign="top" bgcolor="#000000">&nbsp;</td>
        <td width="20" valign="top" bgcolor="#FFFFFF">&nbsp;</td>
        <td width="620" valign="top" bgcolor="#FFFFFF"><font size="+0">&nbsp;</font><font size="+0">&nbsp;</font> 
          <div align="left"> </div>
        </td>
        <td width="20" valign="top" bgcolor="#FFFFFF" rowspan="3">&nbsp;</td>
        <td background="images_rv042/UI_05.gif" width="14" valign="top" rowspan="3">&nbsp;</td>
        <td width="136" rowspan="2" valign="top" bgcolor="#6666CC" align="right"> 
          <a href="javascript: openMap()"><img src="images_rv042/sitemap-off.jpg" width="136" height="28" border="0" onMouseOver="this.src=\'images_rv042/sitemap-on.jpg\'" onMouseOut="this.src=\'images_rv042/sitemap-off.jpg\'"></a> 
          <br><br>
		 <div align="left"><font face="Arial" style="font-size: 8pt" color="#FFFFFF">
From the Firewall Tab, you can configure the Router to deny or allow specific internal users from accessing the Internet. You can also configure the Router to deny or allow specific Internet users from accessing the internal servers.		 
<br><br>
<a href="javascript: h_f_general();"><b><font face="Arial" style="font-size: 8pt" color="#FFFFFF">More...</font></b></a>	
		 </font></div> 
		  </td>
        <td width="1"></td>
      </tr>
      <tr> 
        <td valign="top" bgcolor="#E7E7E7" bordercolor="#E7E7E7" bordercolorlight="#E7E7E7" bordercolordark="#E7E7E7" height="243">&nbsp;</td>
        <td background="images_rv042/UI_04.gif" rowspan="2" valign="top">&nbsp;</td>
        <td rowspan="2" valign="top" bgcolor="#FFFFFF">&nbsp;</td>
        <td valign="top" bgcolor="#FFFFFF"> 
          <input type=hidden name="page" value="f_general.htm">
		  <input type=hidden name="adPassword" value=\' \'>
		  <input type=hidden name="submitStatus" value="1">		
          <br>
          <font face="Arial Unicode MS" size="+0">&nbsp;</font> <font size="+0"> 
          <p align="center"> </p>
          <center>
            <table cellspacing="0" border="0" width="98%" align="center">
              <tr> 
                <td width="267" align="right"><b><font face="Arial Unicode MS">Firewall 
                  :</font></b></td>
                <td width="14"> </td>
                <td width="89"> 
                  <div align="left"> <b><font face="Arial Unicode MS"> 
                    <input type="radio" name="firewall" value="1" onClick=enable_FW() >
                    
                    Enable </font></b></div>
                </td>
                <td width="92"><b><font face="Arial Unicode MS"> 
                  <input type="radio" name="firewall" value="0" onClick=disable_FW1()  checked>
                  
                  Disable</font></b></td>
                <td width="136">
                  
                </td>
              </tr>
              <tr> 
                <td width="267" align="right"><b><font face="Arial Unicode MS">SPI 
                  (Stateful Packet Inspection) :</font></b></td>
                <td width="14"> </td>
                <td width="89"> 
                  <div align="left"> <b><font face="Arial Unicode MS"> 
                    <input type="radio" name="spi" value="1"  checked>
                    
                    Enable </font></b></div>
                </td>
                <td width="92"><b><font face="Arial Unicode MS"> 
                  <input type="radio" name="spi" value="0" >
                  
                  Disable</font></b></td>
                <td width="136">
                  <input type="hidden" name="spi0" value=\' checked\'>
                </td>
              </tr>
              <tr> 
                <td width="267" align="right"><b><font face="Arial Unicode MS">DoS 
                  (Denial of Service) :</font></b></td>
                <td width="14"> </td>
                <td width="89"> 
                  <div align="left"> <b><font face="Arial Unicode MS"> 
                    <input type="radio" name="dos" value="1"  checked>
                    
                    Enable </font></b></div>
                </td>
                <td width="92"><b><font face="Arial Unicode MS"> 
                  <input type="radio" name="dos" value="0" >
                  
                  Disable</font></b></td>
                <td width="136">
                  <input type="hidden" name="dos0" value=\' checked\'>
                </td>
              </tr>
              <tr> 
                <td width="267" align="right"><b><font face="Arial Unicode MS"> 
                  Block WAN Request :</font></b></td>
                <td width="14"> </td>
                <td width="89"> 
                  <div align="left"> <b><font face="Arial Unicode MS"> 
                    <input type="radio" name="blockWANReq" value="1"  checked>
                    
                    Enable </font></b></div>
                </td>
                <td width="92"><b><font face="Arial Unicode MS"> 
                  <input type="radio" name="blockWANReq" value="0" >
                  
                  Disable</font></b></td>
                <td width="136">
                  <input type="hidden" name="blockWANReq0" value=\' checked\'>
                </td>
              </tr>
			  <tr> 
                <td width="267" align="right"><b><font face="Arial Unicode MS"> 
                  Remote Management :</font></b></td>
                <td width="14"> </td>
                <td width="89"> 
                  <div align="left"> <b><font face="Arial Unicode MS"> 
                    <input type="radio" name="remoteMng" value="1" onClick="chSH1()"  checked>
                    
                    Enable </font></b></div>
                </td>
                <td width="92"><b><font face="Arial Unicode MS">
                  <input type="radio" name="remoteMng" value="0" onClick="chSH()" >
                  
                  Disable</font></b></td>
                <td width="136">Port: 
                  <!--<select name="rmPort">
                    <option value="0"    #nk_get FW_general="18"   >80</option>
                    <option value="1"    #nk_get FW_general="19"   >8080</option>
                  </select>-->
				  <input name="rmPort" size="5" maxlength="5" onFocus="this.select();" onBlur=" portCheck(this)" value=80>
                  <input type="hidden" name="remoteMng0" value=\' checked\'>
                </td>
              </tr>
			  
			  <tr>
                <td width="267" align="right"><b><font face="Arial Unicode MS">
                  HTTPS :</font></b></td>
                <td width="14"> </td>
                <td width="89">
                  <div align="left"> <b><font face="Arial Unicode MS">
                    <input type="radio" name="https" value="1" onClick="chHttpsSH1()"  checked>
                    Enable </font></b></div>
                </td>
                <td width="92"><b><font face="Arial Unicode MS">
                  <input type="radio" name="https" value="0" onClick="chSH()" >
                  Disable</font></b></td>
                <td width="136">&nbsp;</td>
              </tr>
			  
              <tr> 
                <td width="267" align="right"><b><font face="Arial Unicode MS"> 
                  Multicast Pass Through :</font></b></td>
                <td width="14"> </td>
                <td width="89"> 
                  <div align="left"> <b><font face="Arial Unicode MS"> 
                    <input type="radio" name="passMulti" value="1"  checked>
                    
                    Enable </font></b></div>
                </td>
                <td width="92"><b><font face="Arial Unicode MS"> 
                  <input type="radio" name="passMulti" value="0" >
                  
                  Disable</font></b></td>
                <td width="136">&nbsp;</td>
              </tr>
              
              <!--			  
              <tr> 
                <td width="267" align="right"><b> <font face="Arial Unicode MS">Fragmented 
                  Packets Pass Through :</font></b></td>
                <td width="14"> </td>
                <td width="89"> 
                  <div align="left"> <b><font face="Arial Unicode MS"> 
                    <input type="radio" name="passFP" value="1" >
                     #nk_get FW_general="13"
                    
                    Enable </font></b></div>
                </td>
                <td width="92"><b><font face="Arial Unicode MS"> 
                  <input type="radio" name="passFP" value="0" >
                     #nk_get FW_general="12"
                    
                  Disable</font></b></td>
                <td width="136">&nbsp;</td>
              </tr>
-->
              <tr> 
                <td width="267" align="right"><b> <font face="Arial Unicode MS">MTU 
                  :</font></b></td>
                <td width="14"> </td>
                <td width="89"> 
                  <div align="left"> <b><font face="Arial Unicode MS"> 
                    <input type="radio" name="mtu_auto" value="1" onClick="chSH()"  checked>
                    
                    Auto</font></b></div>
                </td>
                <td width="92"><b><font face="Arial Unicode MS"> 
                  <input type="radio" name="mtu_auto" value="0" onClick="chSH()" >
                  
                  Manual</font></b></td>
                <td width="136"> 
                  <input type="text" name="bytesMTU" size="4" maxlength="4" onFocus="this.select();" onBlur=" bytesCheck(this)" value=\'1500\'>
                  bytes </td>
              </tr>
            </table>
            <br>
          </center>
          <br>
<hr align="center" size="1" color="#b5b5e6" noshade>
          <br>
          </font> </td>
        <td height="221"></td>
      </tr>
      <tr>
        <td valign="top" bgcolor="#E7E7E7" bordercolor="#E7E7E7" bordercolorlight="#E7E7E7" bordercolordark="#E7E7E7" height="37" align="right"><b><font face="Arial, Helvetica, sans-serif">Restrict 
          WEB Features</font></b></td> 
        <td valign="top" bgcolor="#FFFFFF">          <table width="98%" align="center" cellspacing="0" border="0">
            <tr> 
              <td width="41%" align="right"><b><font face="Arial, Helvetica, sans-serif">Block 
                :</font></b></td>
              <td width="3%"><b><font face="Arial, Helvetica, sans-serif"></font></b></td>
              <td width="56%"><b><font face="Arial, Helvetica, sans-serif">
                <input type="checkbox" name="blockJava" value="1" onClick="chTrust()" >
                Java</font></b></td>
            </tr>
            <tr> 
              <td width="41%"><b><font face="Arial, Helvetica, sans-serif"></font></b></td>
              <td width="3%"><b><font face="Arial, Helvetica, sans-serif"></font></b></td>
              <td width="56%"><b><font face="Arial, Helvetica, sans-serif"> 
                <input type="checkbox" name="blockCookies" value="1" onClick="chTrust()" >
                Cookies</font></b></td>
            </tr>
            <tr> 
              <td width="41%"><b><font face="Arial, Helvetica, sans-serif"></font></b></td>
              <td width="3%"><b><font face="Arial, Helvetica, sans-serif"></font></b></td>
              <td width="56%"><b><font face="Arial, Helvetica, sans-serif"> 
                <input type="checkbox" name="blockActiveX" value="1" onClick="chTrust()" >
                ActiveX</font></b></td>
            </tr>
            <tr> 
              <td width="41%"><b><font face="Arial, Helvetica, sans-serif"></font></b></td>
              <td width="3%"><b><font face="Arial, Helvetica, sans-serif"></font></b></td>
              <td width="56%"><b><font face="Arial, Helvetica, sans-serif"> 
                <input type="checkbox" name="blockProxy" value="1" onClick="chTrust()" >
                Access to HTTP Proxy Servers</font></b></td>
            </tr>
          </table>
		  <br><a name="1"></a>
           <table cellspacing="0" cellpadding="0" border="0" align="center">
            <tr> 
              <td> 
                <input type="checkbox"name="noblockTrusted" value="1" onClick="falseSubmit(this.form)" >
              </td>
              <td> 
                <div align="left"> &nbsp; <font face="Arial, Helvetica, sans-serif"><b>Don\'t 
                  block Java/ActiveX/Cookies/Proxy to Trusted Domains</b></font></div>
              </td>
            </tr>
          </table><br>
<!--
          <table border="0" width="98%" cellspacing="0" align="center">
            <tr> 
              <td width="48" valign="top">&nbsp;</td>
              <td width="531" valign="top" bgcolor="#CCCCFF"> 
                <center>
                  <center>
                  </center>
                  <center>
                    <b><font color="#000000">Trusted Domains</font></b>
                  </center>
                  <br>Add:
                    <input maxlength="23" name="forbiddenURLs_add" size="20" onFocus="this.select();" onBlur="sTrim(this);">
                  <br>
                    <input type="button" name="btnAddToList" value="Add to list" onClick=addSel(this.form.forbiddenURLs_add,this.form.local_forbiddenURLs_del)>
                  <br>
                </center>
              </td>
              <td width="48" valign="top">&nbsp;</td>
            </tr>
            <tr>
              <td valign="top">&nbsp;</td>
              <td valign="top" bgcolor="#CCCCFF">
                <center>
                  <select multiple name="local_forbiddenURLs_del"         size="10" onChange="showdeleteButton2(this.form);" style="width: 90%">
                     
                  </select>
                </center>
              </td>
              <td valign="top">&nbsp;</td>
            </tr>
            <tr> 
              <td valign="top">&nbsp;</td>
              <td valign="top" bgcolor="#CCCCFF"> 
                <table width="100%" align="center">
                  <tr> 
                    <td height="33" valign="top" width="153" align="center">&nbsp; </td>
                    <td width="178" valign="top" align="center"> 
                      <input type="button" name="deleteForbidden" value="Delete selected domain" onClick="delSel(this.form.local_forbiddenURLs_del)" disabled>
                    </td>
                    <td width="153" valign="top" align="left">
                    <span id="btnNew" style="visibility: hidden"> 
                      <input type="button" name="showNew" value="Add New" onClick="clearContent(this.form.forbiddenURLs_add)">
                    </span></td>
                  </tr>
                </table>
              </td>
              <td valign="top">&nbsp;</td>
            </tr>
          </table>		 
-->&nbsp;</td>
        <td valign="bottom" rowspan="2" bgcolor="#6666CC" align="right"><img src="images_rv042/cisco.gif" width="136" height="62"></td>
        <td height="37"></td>
      </tr>
      <tr> 
        <td height="25" colspan="2" valign="top" bgcolor="#000000" bordercolor="#E7E7E7" bordercolorlight="#E7E7E7" bordercolordark="#E7E7E7">&nbsp; 
        </td>
        <td valign="top" bgcolor="#6666CC" bordercolor="#E7E7E7" bordercolorlight="#E7E7E7" bordercolordark="#E7E7E7">&nbsp;</td>
        <td valign="middle" bgcolor="#6666CC" bordercolor="#E7E7E7" bordercolorlight="#E7E7E7" bordercolordark="#E7E7E7" align="center"> 
          <table border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse" bordercolor="#111111" id="AutoNumber15" width="220" align="right" height="19">
            <tr> 
              <td width="101" bgcolor="#42498C" align="center"> <a href="javascript: chSubmit(document.formf_general)"><font color="#FFFFFF" style="font-size: 8pt; font-weight: 700" face="Arial"> 
                Save Settings</font></a></td>
              <td width="8" align="center" bgcolor="#6666CC">&nbsp;</td>
              <td width="103" bgcolor="#434A8F" align="center"> <a href="f_general.htm"> 
                <font color="#FFFFFF" style="font-size: 8pt; font-weight: 700" face="Arial"> 
                Cancel Changes</font></a></td>
            </tr>
          </table>
        </td>
        <td valign="top" bgcolor="#6666CC" bordercolor="#E7E7E7" bordercolorlight="#E7E7E7" bordercolordark="#E7E7E7">&nbsp;</td>
        <td valign="top" bgcolor="#000000"> 
          <div align="center"> 
            <center>
            </center>
          </div>
        </td>
        <td></td>
      </tr>
    </form>
  </table>
    
</div></body>
</html>
END

our $dhcp = <<'END';
<html>
<head><meta name="Pragma" content="No-Cache">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Web Management</title>
<base target="_self">
<style fprolloverstyle>A:hover {color: #00FFFF}
.help:link {text-decoration: underline}
.help:visited {text-decoration: underline}
.help:hover {color: #FFCC00; text-decoration: underline}
.logout:link {text-decoration: none}
.logout:visited {text-decoration: none}
.logout:hover {color: #FFCC00; text-decoration: none}
</style>
<style type="text/css">
body {font-family: Arial, Verdana, sans-serif, Helvetica; background-color: #ffffff;}
td, th, input, select {font-size: 11px}
</style>
<link rel="stylesheet" href="nk.css">
<script src="nk20060810141951.js"></script> <!--<script src="nk.js"></script>-->
<script src="lg20060810141951.js"></script> <!--<script src="lg.js"></script>-->
<script language=JavaScript>
function MM_reloadPage(init) {  //reloads the window if Nav4 resized
  if (init==true) with (navigator) {if ((appName=="Netscape")&&(parseInt(appVersion)==4)) {
    document.MM_pgW=innerWidth; document.MM_pgH=innerHeight; onresize=MM_reloadPage; }}
  else if (innerWidth!=document.MM_pgW || innerHeight!=document.MM_pgH) location.reload();
}
MM_reloadPage(true);
function MM_findObj(n, d) { //v4.0
  var p,i,x;  if(!d) d=document; if((p=n.indexOf("?"))>0&&parent.frames.length) {
    d=parent.frames[n.substring(p+1)].document; n=n.substring(0,p);}
  if(!(x=d[n])&&d.all) x=d.all[n]; for (i=0;!x&&i<d.forms.length;i++) x=d.forms[i][n];
  for(i=0;!x&&d.layers&&i<d.layers.length;i++) x=MM_findObj(n,d.layers[i].document);
  if(!x && document.getElementById) x=document.getElementById(n); return x;
}
function MM_showHideLayers() { //v3.0
  var i,p,v,obj,args=MM_showHideLayers.arguments;
  for (i=0; i<(args.length-2); i+=3) if ((obj=MM_findObj(args[i]))!=null) { v=args[i+2];
    if (obj.style) { obj=obj.style; v=(v==\'show\')?\'visible\':(v=\'hide\')?\'hidden\':v; }
    obj.visibility=v; }
}
function chsetDNS()
{
    if (document.formDHCPSetup.setLanDNS)
	{
        if (document.formDHCPSetup.setLanDNS.checked==true)
        {
            document.formDHCPSetup.LanDnsNeq.value = 0;
            enableIt(document.formDHCPSetup.LanDnsA1);
            enableIt(document.formDHCPSetup.LanDnsA2);
            enableIt(document.formDHCPSetup.LanDnsA3);
            enableIt(document.formDHCPSetup.LanDnsA4);
            enableIt(document.formDHCPSetup.LanDnsB1);
            enableIt(document.formDHCPSetup.LanDnsB2);
            enableIt(document.formDHCPSetup.LanDnsB3);
            enableIt(document.formDHCPSetup.LanDnsB4);
        }
        else
        {
            document.formDHCPSetup.LanDnsNeq.value = 1;
            disableIt(document.formDHCPSetup.LanDnsA1);
            disableIt(document.formDHCPSetup.LanDnsA2);
            disableIt(document.formDHCPSetup.LanDnsA3);
            disableIt(document.formDHCPSetup.LanDnsA4);
            disableIt(document.formDHCPSetup.LanDnsB1);
            disableIt(document.formDHCPSetup.LanDnsB2);
            disableIt(document.formDHCPSetup.LanDnsB3);
            disableIt(document.formDHCPSetup.LanDnsB4);
        }
    }
}
function refreshMe()
{
//document.location.reload();
  document.location.href="dhcp_setup.htm"; 
}
function closeService()
{
  timer2=setTimeout("refreshMe()",1000);
}
function getIPNumber(ipAddr)
{
   var result = 0;
   var value = 0;
   var ipParts = new Array();
   ipParts = ipAddr.split(".");
   for (var i=0; i < ipParts.length; i++) 
   {
      var addr =  ipParts[i];
      if (i==0)
         value = addr * 256 * 256 * 256;
      else if (i == 1)
         value = addr * 256 * 256;
      else if (i == 2)
         value = addr * 256;
      else if (i == 3)
         value = addr * 1;
      result = result + value;
   }
   return result; 
}
function disableIt(obj)
{
    obj.disabled=true;
}
//2004.10.28 Ryoko
function selectEntry(n)
{
	if ( document.formDHCPSetup.dhcp_staticList1 )
	{
    	for (var i=0; i < document.formDHCPSetup.dhcp_staticList1.length; i++)
  		{
        	document.formDHCPSetup.dhcp_staticList1.options[i].selected=false;
  		}
    	document.formDHCPSetup.dhcp_staticList1.options[n].selected=true;
		showdeleteButton2(document.formDHCPSetup,document.formDHCPSetup.dhcp_staticList1);
	}
}
function enableIt(obj)
{
    obj.disabled=false;
}
function chDismatch()
{
	if(document.formDHCPSetup.dhcp_staticList1)
		sortIP(document.formDHCPSetup.dhcp_staticList1);
	if(document.formDHCPSetup.dhcp_chsubmit)
	if(document.formDHCPSetup.dhcp_chsubmit.value=="1")
	chSubmit(document.formDHCPSetup);
    if (document.formDHCPSetup.clTime) document.formDHCPSetup.dhcpStatus.checked=true;
	else document.formDHCPSetup.dhcpStatus.checked=false; 
    document.formDHCPSetup.submitStatus.value=1; 
}
function Ip2addSel(ta1,ta2,ta3,ta4,tb1,tb2,tb3,tb4,s) /*network.htm,adv-dmz.htm,dhcp-setup.htm*/
{
  if (ta1.value=="" || ta2.value=="" || ta3.value=="" || ta4.value=="")
  {
    alert(aIPAddressStart);	
  }
  else if (tb1.value=="" || tb2.value=="" || tb3.value=="" || tb4.value=="")
  {
    alert(aIPAddressEnd);
  }
  else
  {
    for (var i=0; i < s.length; i++)
    {
      if (s.options[i].text==(ta1.value+"."+ta2.value+"."+ta3.value+"."+ta4.value+" ~ "+tb1.value+"."+tb2.value+"."+tb3.value+"."+tb4.value))
  	  {
        alert(aAlready);
	    return;
	  }
    }    
    s.length+=1;
    s.options[s.length-1].text=ta1.value+"."+ta2.value+"."+ta3.value+"."+ta4.value;
    s.options[s.length-1].text+=" ~";
    s.options[s.length-1].text+=" "+tb1.value+"."+tb2.value+"."+tb3.value+"."+tb4.value;
    ta1.value="";  
    ta2.value="";
    ta3.value="";
    ta4.value="";
    tb1.value="";  
    tb2.value="";
    tb3.value="";
    tb4.value="";
  }
}
function sortIP(s)
{
var i=0,j=0;
  var p=-1;
  var pp;
  var qq; 
  var rightString;
  var tmpString;
  var temp;
  var ts=new tmpWord(3);  
//alert(s.length);
   for(i=0;i<s.length;i++)
	for(j=i+1;j<s.length;j++)
	{
        rightString=s.options[i].value;
    	pp=rightString.indexOf(" => ");
    	ts[1]=rightString.substring(0,pp); 
        rightString=s.options[j].value;
    	pp=rightString.indexOf(" => ");
    	ts[2]=rightString.substring(0,pp); 		
//		alert(ts[1]+"="+getIPNumber(ts[1]));
		//getIPNumber(ts[1]);
		if(eval(getIPNumber(ts[1]))>eval(getIPNumber(ts[2])))
		{
//		alert("big"+ts[1]+">"+ts[2]);
		temp=s.options[i].value;
		s.options[i].value=s.options[j].value;;
		s.options[j].value=temp;
		temp=s.options[i].text;
		s.options[i].text=s.options[j].text;;
		s.options[j].text=temp;		
		}
	}
}
function IpMACaddSel(t1,t2,t3,t4,m1,m2,m3,m4,m5,m6,s,Enable,userName) /*dhcp-setup*/
{
  var p=-1;
  var pp;
  var qq; 
  var rightString;
  var tmpString;
  var ts=new tmpWord(3);  
  var enable,enableText;
   
  if (t1.value=="" || t2.value=="" || t3.value=="" || t4.value=="")
  {
    alert(aIPAddress);
  }
  else if (m1.value=="" || m2.value=="" || m3.value=="" || m4.value=="" || m5.value=="" || m6.value=="")
  {
    alert(aMAC);
  }
  else
  {
    if (chValue(t1,t2,t3,t4,m1,m2,m3,m4,m5,m6,s) < 0) return;
	if (s.form.deviceIP.value==(t1.value+"."+t2.value+"."+t3.value+"."+t4.value))
  	{
		alert(aDeviceIPAlready);
		return;
	}
    if (s.form.btnAddToList.value==sUpdateEntry)
    {
      p=-1;
      while (s.options[++p].selected != true);
    }	
    for (var i=0; i < s.length; i++)
    {
	    rightString=s.options[i].value;
    	qq=rightString.length;
    	pp=rightString.indexOf(" => ");
    	ts[1]=rightString.substring(0,pp); 
    	tmpString=rightString;
    	rightString=tmpString.substring(pp+4,qq); 
        /*=>*/ 
    	//qq=rightString.length;
		qq=rightString.indexOf(" ");
    	ts[2]=rightString.substring(0,qq); 
		
		if (i != p)
		{
			if(!(eval(t1.value)==0&&eval(t2.value)==0&&eval(t3.value)==0&&eval(t4.value)==0))
        	if (ts[1]==(t1.value+"."+t2.value+"."+t3.value+"."+t4.value))
  	    	{
				alert(aIPAlready);
	    		return;
	    	}
        	if (ts[2]==(m1.value+"-"+m2.value+"-"+m3.value+"-"+m4.value+"-"+m5.value+"-"+m6.value))
  	    	{
				alert(aMACAlready);
				return;
	    	}
	    }
    }    
    for (var i=0; i < s.length; i++)
    {
        s.options[i].selected=false;
    }
	if (s.form.btnAddToList.value==sAddtoList)
	{
        if (s.length>=100)
    	{
        	alert(aLimitStaticIP);
        	return;
    	}        		 
	    p=s.length;
		s.length+=1;
	}	
	enable=0;
	if(Enable)
	if(Enable.checked==true)
	enable=1;
	enableText="Disabled";
	if(Enable)
	if(Enable.checked==true)
	enableText="Enabled";			
		
    s.options[p].text=t1.value+"."+t2.value+"."+t3.value+"."+t4.value;
	s.options[p].value=t1.value+"."+t2.value+"."+t3.value+"."+t4.value;
    s.options[p].text+=" =>";
	s.options[p].value+=" =>";
    s.options[p].text+=" "+m1.value+"-"+m2.value+"-"+m3.value+"-"+m4.value+"-"+m5.value+"-"+m6.value;
	s.options[p].value+=" "+m1.value+"-"+m2.value+"-"+m3.value+"-"+m4.value+"-"+m5.value+"-"+m6.value;
    s.options[p].text+="=>"+userName.value+"=>"+enableText;
//	s.options[p].value+=" =>"+enable;
	s.options[p].value+=" "+enable+" "+userName.value;
    clearContent(s.form);
  }
  sortIP(s);
}
function chValue(t1,t2,t3,t4,m1,m2,m3,m4,m5,m6,s)
{
    if (sIPCheck(t1) < 0) return -1;
    if (sIPCheck(t2) < 0) return -1;
	if (sIPCheck(t3) < 0) return -1;
    if (sIP0to254Check(t4) < 0) return -1; 
	if (MACCheck(m1) < 0) return -1;
	if (MACCheck(m2) < 0) return -1;
	if (MACCheck(m3) < 0) return -1;
	if (MACCheck(m4) < 0) return -1;  
	if (MACCheck(m5) < 0) return -1; 
	if (MACCheck(m6) < 0) return -1; 
	return 1;
}
function tmpWord(n)
{
  this.length=n;
  for (var i=1; i<=n; i++)
  this[i]=0;
  return this;
}
function delSel(s)
{
  var z;  
  var k;
  if (s.length > 0)
  {
    tmp=new tmpWord(s.length);
	tmpChanged=new tmpWord(s.length); 
    opvtmp=new tmpWord(s.length);
    opvtmpChanged=new tmpWord(s.length); 	
    for (var i=0; i < s.length; i++)
	{
	  tmp[i+1]=s.options[i].text;
      opvtmp[i+1]=s.options[i].value;
	}	
    for (var i=0; i < s.length; i++)
	{
	  if (s.options[i].selected==true)
	  { 
		s.options[i].text="";
		s.options[i].value="";
	    tmp[i+1]=" ";	
        opvtmp[i+1]=" ";
		s.options[i].selected=false;
	  }
	}
	k=1;
	z=0;
    for (var j=1; j<=s.length; j++) 
	{ 
	     if (tmp[j]!=" ") 
         {
             tmpChanged[k]=tmp[j];
             opvtmpChanged[k]=opvtmp[j];
		     k++;
         }
		 else
		 {
			 z++;
		 }
    }
    for (var i=0; i < s.length-z; i++)
	{
 	    s.options[i].text=tmpChanged[i+1];  
        s.options[i].value=opvtmpChanged[i+1];  
	}
    s.length-=z;
  }
  clearContent(s.form); 
}
function exPosion(s)
{
  if (s.length > 0)
  {
    tmp=new tmpWord(s.length);
	tmpChanged=new tmpWord(s.length); 
    opvtmp=new tmpWord(s.length);
    opvtmpChanged=new tmpWord(s.length);
	 	
    for (var i=0; i < s.length; i++)
	{
	  tmp[i+1]=s.options[i].text;
	  opvtmp[i+1]=s.options[i].value;
	}	
		
    for (var i=0; i < s.length; i++)
	{
	  s.options[i].text=tmp[s.length-i];
	  s.options[i].value=opvtmp[s.length-i];
	}
	
    for (var i=0; i < s.length; i++)
	{
	    tmp[i+1]=" ";
		opvtmp[i+1]=" ";	
	}
  }
}
function selAll(s)
{
  if (s.length>0)
  {
    exPosion(s);
    for (var i=0; i < s.length; i++)
    s.options[i].selected=true;
  }
}
function chSubmit(F)
{
//<--ryoko20040729 pptp IP check PPTPIP
	var tmpIp;
	if (F.ds4)
	if (eval(F.ds4.value) > eval(F.de4.value))
	{
	    tmpIp = F.ds4.value;
		F.ds4.value = F.de4.value;
		F.de4.value = tmpIp;
	}
	// <-- Eric
  if (F.ds4)
  if(F.PPTPEnabled.value==" checked") 
  if ((F.dsPPTP1.value==F.ds1.value) && (F.dsPPTP2.value==F.ds2.value) && (F.dsPPTP3.value==F.ds3.value)) // 2004/12/02 Eric
  if (((eval(F.ds4.value) >= eval(F.dsPPTP4.value)) && (eval(F.ds4.value) <= eval(F.dePPTP4.value))) 
   || ((eval(F.de4.value) >= eval(F.dsPPTP4.value)) && (eval(F.de4.value) <= eval(F.dePPTP4.value))))
  {
  	  alert(aDhcpRangeConflict);
	  F.ds4.select();
      return;
  } 
  if (F.ds4)  
  if(F.PPTPEnabled.value==" checked") 
  if ((F.dsPPTP1.value==F.ds1.value) && (F.dsPPTP2.value==F.ds2.value) && (F.dsPPTP3.value==F.ds3.value)) // 2004/12/02 Eric
  if (((eval(F.dsPPTP4.value) >= eval(F.ds4.value)) && (eval(F.dsPPTP4.value) <= eval(F.de4.value))) 
   || ((eval(F.dePPTP4.value) >= eval(F.ds4.value)) && (eval(F.dePPTP4.value) <= eval(F.de4.value))))
  {
  	  alert(aDhcpRangeConflict);
	  F.ds4.select();
      return;
  } 
//<--ryoko20040729 pptp IP check PPTPIP
//<--ryoko20040729 pptp IP check LanIp
  if (F.ds4)
  if(F.LanIp)
  {
    var IpLan,IpLan123,IpLan4;
	var IpPptp123,IpPptpStart4,IpPptpEnd4;
	var ipdmz=F.LanIp.value;
	var dmzIp123="",dmzIp4,tmp_dmz_length,tmp_dmz_string=ipdmz,tmp_num,tmp_num_total=0;
                tmp_dmz_length=ipdmz.length;
	for (var tmp_i=0; tmp_i < 3; tmp_i++)				
	{
    			tmp_num=tmp_dmz_string.indexOf(".");
				tmp_num_total=tmp_num_total+tmp_num+1;
				tmp_dmz_string=tmp_dmz_string.substring(tmp_num+1,tmp_dmz_length); 				
	}
    			tmp_num=tmp_dmz_string.indexOf(" ");	
				if(tmp_num!=-1)
				dmzIp4=tmp_dmz_string.substring(0,tmp_num)
				else
				dmzIp4=tmp_dmz_string;
				dmzIp123=ipdmz.substring(0,tmp_num_total-1);				
				IpLan123=dmzIp123;
				IpLan4=dmzIp4;				  
	IpPptp123=F.ds1.value+"."+F.ds2.value+"."+F.ds3.value;
	IpPptpStart4=F.ds4.value;
	IpPptpEnd4=F.de4.value;;	
    IpLan=F.LanIp.value;
	if(IpPptp123==IpLan123)
	if(eval(IpLan4)<=eval(IpPptpEnd4)&&eval(IpLan4)>=eval(IpPptpStart4))
    {
	//alert(aDhcpLanIpConflict);
	//return;
	}
  }
//<--ryoko20040729
    if (F.dhcpStatus.checked==true)
    {
        F.dhcpStatusChange.value="1";
    }
    else
    {
        F.dhcpStatusChange.value="0";
		if (F.dhcp_staticList1) selAll(F.dhcp_staticList1);
        F.submitStatus.value=1;
        window.status=wSave;
	    MM_showHideLayers(\'AutoNumber15\',\'\',\'hide\');  
        F.submit();
        return;
    }
    if (F.dhcp_staticList1) selAll(F.dhcp_staticList1);
	
	if (document.formDHCPSetup.LanDnsA1)
    if (document.formDHCPSetup.LanDnsA1.value=="0" && document.formDHCPSetup.LanDnsA2.value=="0" && document.formDHCPSetup.LanDnsA3.value=="0" && document.formDHCPSetup.LanDnsA4.value=="0")
	{
	    if (document.formDHCPSetup.LanDnsB1.value!="0" || document.formDHCPSetup.LanDnsB2.value!="0" || document.formDHCPSetup.LanDnsB3.value!="0" || document.formDHCPSetup.LanDnsB4.value!="0")
        exDNS();
		else
		{
		}
	}	
	/* 2004/04/22 Eric --> Exchange Start and End ip */
	var tmpIp;
	if (document.formDHCPSetup.ds4)
	if (eval(document.formDHCPSetup.ds4.value) > eval(document.formDHCPSetup.de4.value))
	{
	    tmpIp = document.formDHCPSetup.ds4.value;
		document.formDHCPSetup.ds4.value = document.formDHCPSetup.de4.value;
		document.formDHCPSetup.de4.value = tmpIp;
	}
	// <-- Eric
    F.submitStatus.value=1; 
    window.status=wSave;
        MM_showHideLayers(\'AutoNumber15\',\'\',\'hide\');  
  F.submit();
}
function exDNS()
{
        document.formDHCPSetup.LanDnsA1.value=document.formDHCPSetup.LanDnsB1.value;
        document.formDHCPSetup.LanDnsA2.value=document.formDHCPSetup.LanDnsB2.value;
        document.formDHCPSetup.LanDnsA3.value=document.formDHCPSetup.LanDnsB3.value;	
        document.formDHCPSetup.LanDnsA4.value=document.formDHCPSetup.LanDnsB4.value;
        document.formDHCPSetup.LanDnsB1.value="0";
		document.formDHCPSetup.LanDnsB2.value="0";
		document.formDHCPSetup.LanDnsB3.value="0";
		document.formDHCPSetup.LanDnsB4.value="0";			
}
function timeCheck(I)
{
  var d;
  d=parseInt(I.value,10);
  if (!(d<=43200 && d>=5))
  {
    alert(aMinuteSNumsCheck);
    I.value=I.defaultValue;
    return;
  }
  I.value=d;
}
function IPCheck(I)
{
  var d;
  d=parseInt(I.value,10);
  if (!(d<256 && d>=0))
  {
    alert(aIPCheck);
    I.value=I.defaultValue;
    return;
  }
  I.value=d;  
}
function IP0to254Check(I)
{
  var d;
  d=parseInt(I.value,10);
  if (!(d<255 && d>=0)) 
  {
    alert(aIP0to254Check);
    I.value=I.defaultValue;
    return;   
  }
  I.value=d;  
}
function sIPCheck(I)
{
  var d;
  d=parseInt(I.value,10);
  if (!(d<256 && d>=0))
  {
    alert(aIPCheck);
//    I.value=I.defaultValue;
    I.select();
    return -1;
  }
  I.value=d;
  return 1;  
}
function sIP0to254Check(I)
{
  var d;
  d=parseInt(I.value,10);
  if (!(d<255 && d>=0)) 
  {
    alert(aIP0to254Check);
//    I.value=I.defaultValue;
    I.select();
    return -1;   
  }
  I.value=d;  
  return 1;
}
function MACCheck(I)
{
  var m1=0;
  var m2=0;
  var single;
  m1=parseInt(I.value.charAt(0),16);
  m2=(I.value.length==2?parseInt(I.value.charAt(1),16):0);
  if (isNaN(m1) || isNaN(m2))
  {
    alert(aMACCheck);
//	I.value=I.defaultValue;
    I.select();
	return -1;
  }
  if (I.value.length==1) 
  {
    single=I.value;
    I.value="0"+single;
  }
  return 1;
}
function falseSubmit(F)
{
    if (F.dhcpStatus.checked==true)
    {
        F.dhcpStatusChange.value="1";
    }
    else 
    {
        F.dhcpStatusChange.value="0";
    }    
    F.submitStatus.value=0; 
	if (F.dhcp_staticList1) selAll(F.dhcp_staticList1);
	
        MM_showHideLayers(\'AutoNumber15\',\'\',\'hide\');  
  F.submit();
}
function showdeleteButton1(F)
{
    F.delDynamic.disabled=false;
}
function showdeleteButton2(F,s)
{
  var p;
  var q; 
  var forwardString=s.options[s.selectedIndex].value; 
  var rightString;
  var tmpString;
  var ts=new tmpWord(13); 
/**/
  if (s.selectedIndex==-1) return;
  rightString=forwardString;
/**/
    q=rightString.length;
    p=rightString.indexOf(".");
    ts[1]=rightString.substring(0,p); 
    tmpString=rightString;
    rightString=tmpString.substring(p+1,q); 
/*.*/	
    q=rightString.length;
    p=rightString.indexOf(".");
    ts[2]=rightString.substring(0,p); 
    tmpString=rightString;
    rightString=tmpString.substring(p+1,q); 
/*.*/
    q=rightString.length;
    p=rightString.indexOf(".");
    ts[3]=rightString.substring(0,p); 
    tmpString=rightString;
    rightString=tmpString.substring(p+1,q); 
/*.*/
    q=rightString.length;
    p=rightString.indexOf(" => ");
    ts[4]=rightString.substring(0,p); 
    tmpString=rightString;
    rightString=tmpString.substring(p+4,q); 
/* => */
    q=rightString.length;
    p=rightString.indexOf("-");
    ts[5]=rightString.substring(0,p); 
    tmpString=rightString;
    rightString=tmpString.substring(p+1,q); 
/*-*/
    q=rightString.length;
    p=rightString.indexOf("-");
    ts[6]=rightString.substring(0,p); 
    tmpString=rightString;
    rightString=tmpString.substring(p+1,q); 
/*-*/ 
    q=rightString.length;
    p=rightString.indexOf("-");
    ts[7]=rightString.substring(0,p); 
    tmpString=rightString;
    rightString=tmpString.substring(p+1,q); 
/*-*/  
    q=rightString.length;
    p=rightString.indexOf("-");
    ts[8]=rightString.substring(0,p); 
    tmpString=rightString;
    rightString=tmpString.substring(p+1,q); 
/*-*/
    q=rightString.length;
    p=rightString.indexOf("-");
    ts[9]=rightString.substring(0,p); 
    tmpString=rightString;
    rightString=tmpString.substring(p+1,q); 
/*-*/ 
    q=rightString.length;
    p=rightString.indexOf(" ");
    ts[10]=rightString.substring(0,p); 
    tmpString=rightString;
    rightString=tmpString.substring(p+1,q); 
/**/    
    q=rightString.length;
    p=rightString.indexOf(" ");
    ts[11]=rightString.substring(0,p); 
    tmpString=rightString;
    rightString=tmpString.substring(p+1,q); 
    q=rightString.length;
    ts[12]=rightString.substring(0,q); 
/*-----------------------------------------------------*/ 
    F.ss1.value=ts[1]; 
    F.ss2.value=ts[2]; 
    F.ss3.value=ts[3];  
    F.ss4.value=ts[4]; 
    F.sMAC1.value=ts[5];      
    F.sMAC2.value=ts[6];
    F.sMAC3.value=ts[7];
    F.sMAC4.value=ts[8];
    F.sMAC5.value=ts[9];
    F.sMAC6.value=ts[10];	
	if(F.dhcpEnable)
	F.dhcpEnable.checked=false;	 	
	if(ts[11]==1)
	if(F.dhcpEnable)
	F.dhcpEnable.checked=true;
	F.userName.value=ts[12];			       
    F.btnAddToList.value=sUpdateEntry; 
    MM_showHideLayers(\'btnNew\',\'\',\'show\');
    F.delStatic.disabled=false;
}
function blurList1(F)
{
/*
    for (var i=0; i < F.dhcp_dynamicList.length; i++)
    {
      F.dhcp_dynamicList.options[i].selected=false;
    }
    F.delDynamic.disabled=true;
*/
}
function blurList2(F)
{
    for (var i=0; i < F.dhcp_staticList1.length; i++)
    {
      F.dhcp_staticList1.options[i].selected=false;
    }
    F.delStatic.disabled=true;
}
function clearContent(F)
{
    blurList2(F);
    F.ss1.value="";
    F.ss2.value="";  
    F.ss3.value="";
    F.ss4.value="";
    F.sMAC1.value="";
    F.sMAC2.value="";
    F.sMAC3.value="";
    F.sMAC4.value="";
    F.sMAC5.value="";
    F.sMAC6.value="";		
	F.userName.value="";		
    F.btnAddToList.value=sAddtoList; 
	if(F.dhcpEnable)
	F.dhcpEnable.checked=false;	 
    MM_showHideLayers(\'btnNew\',\'\',\'hidden\'); 
	F.ss1.select();
}
var wMap=null;
function openMap()
{
  if (wMap==null)
  wMap=window.open(\'map.htm\',\'sitemap\',\'menubar=no,scrollbars,width=670,height=470\');
}
function closeMap()
{
  if (wMap!=null)
  {
    wMap.close();
	wMap=null;
  }
}
function mapTo(p)
{
  document.location.href=p; 
  closeMap(); 
}
function closeMC()
{  
	if (wDhcp_table!=null)
	closeTable(wDhcp_table);
	if (wDhcp_table1!=null)
	closeTable(wDhcp_table1);
}
window.onfocus=closeMC;
window.onfocus=closeMap;
</script>
</head>
<body link="#B5B5E6" vlink="#B5B5E6" alink="#B5B5E6" onLoad="chDismatch()" onUnLoad="closeMap()">
<DIV align=center>
<table border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse" bordercolor="#111111" id="AutoNumber11" width="960" height="68">
    <tr> 
      <td valign="bottom" width="650" hetght="39" bgcolor="#6666CC"> <img border="0" src="images_rv042/clinksys.gif" width="165" height="57" align="middle"> 
      </td>
      <td valign="bottom" bgcolor="#6666CC" width="337"> 
        <div align="right"><font color="#FFFFFF"> <span style="font-size: 7pt">&nbsp;&nbsp;&nbsp;&nbsp;<font face="Arial"> 
          Firmware Version: 1.3.7.10</font></span><font face="Arial"><span style="font-size: 7pt">&nbsp;&nbsp;&nbsp;</span></font></font></div>
      </td>
    </tr>
    <tr> 
      <td colspan="2" valign="top"> <img border="0" src="images_rv042/UI_10.gif" width="960" height="11"></td>
    </tr>
  </table>
   
  
   
  <TABLE height=90 cellSpacing=0 cellPadding=0 width=960 bgColor=black border=0>
    <form name="formdualwan" method="post" action="">
      <input type="hidden" name="dualwanEnabled" value=\'0\'>
      <input type="hidden" name="firewall0" value=\'\'>
    </form>
    <TR> 
      <TD width="150" height=90 rowspan="3" align=middle bordercolor="#000000" bgColor=black style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"> 
        <H3 style="margin-top: 1; margin-bottom: 1" align="center"> <font color="#FFFFFF" face="Arial">DHCP</font></H3></TD>
      <TD width=690 height=33 align="center" vAlign=middle bordercolor="#000000" bgColor=#6666CC style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"> 
        <p align="right"><b><font color="#FFFFFF"><span lang="en-us"> 10/100 4-port 
          VPN Router&nbsp;&nbsp;&nbsp;&nbsp;</span></font></b> </TD>
      <TD vAlign=center width=120 bgColor=#000000 style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black" bordercolor="#000000"> 
        <p align="center"><font color="#FFFFFF"> <span style="font-size: 8pt"><b>RV042</b></span></font> 
      </TD>
    </TR>
    <TR> 
      <TD height=36 colspan="2" vAlign=center bordercolor="#000000" bgColor=#000000 style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"><table width="810" border="0" cellspacing="0" cellpadding="0" >
          <!--DWLayoutTable-->
          <tr  align="center"> 
            <td width="100" height="8" valign="middle" background="images_rv042/UI_06.gif" style=""></td>
            <td width="80" valign="middle" background="images_rv042/UI_06.gif"style=""></td>
            <td width="70" valign="middle" background="images_rv042/UI_07.gif"style=""></td>
            <td width="110" valign="middle" background="images_rv042/UI_06.gif"style=""></td>
            <td width="80" valign="middle" background="images_rv042/UI_06.gif"style=""></td>
            <td width="60" valign="middle" background="images_rv042/UI_06.gif"style=""></td>
            <td width="60" valign="middle" background="images_rv042/UI_06.gif"style=""></td>
            <td width="80" valign="middle" background="images_rv042/UI_06.gif"style=""></td>
            <td width="85" valign="middle" background="images_rv042/UI_06.gif"style=""></td>
            <td width="85" valign="middle" background="images_rv042/UI_06.gif"style=""></td>
          </tr>
          <tr  align="center" valign="middle"> 
            <td height="28" bgcolor="#000000" style="border-style: none; border-width: medium; font-style:normal; font-variant:normal; font-weight:normal; font-size:10pt; color:black"> 
              <p align="center" style="margin-bottom: 4"> <b><a class="mainmenu" href="home.htm" style="font-size: 8pt; text-decoration: none; font-weight:700"> 
                System<br>
                Summary</a></b> </td>
            <td bgcolor="#000000" style="border-style: none; border-width: medium; font-style:normal; font-variant:normal; font-weight:normal; font-size:10pt; color:black"> 
              <p style="margin-top: 0; margin-bottom: 4"><b><a class="mainmenu" href="network.htm" style="font-size: 8pt; text-decoration: none; font-weight:700"> 
                Setup</a></b> </td>
            <td bgcolor="#6666CC" style="border-style: none; border-width: medium; font-style:normal; font-variant:normal; font-weight:normal; font-size:10pt; color:black"> 
              <p style="margin-bottom: 4"> <b><font color="#FFFFFF" style="font-size: 8pt"> 
                DHCP</font></b> </td>
            <td bgcolor="#000000" style="border-style: none; border-width: medium; font-style:normal; font-variant:normal; font-weight:normal; font-size:10pt; color:black"> 
              <p style="margin-bottom: 4"> <b> 
                <script>
          if (document.formdualwan.dualwanEnabled.value=="1") 
		  	  document.write(\'<a class="mainmenu" href="sys_dualwanw.htm" style="font-size: 8pt; text-decoration: none; font-weight:700">\');
          else document.write(\'<a class="mainmenu" href="sys_dualwan3.htm" style="font-size: 8pt; text-decoration: none; font-weight:700">\');
          </script>
                System<br>
                Management </a></b> </td>
            <td bgcolor="#000000" style="border-style: none; border-width: medium; font-style:normal; font-variant:normal; font-weight:normal; font-size:10pt; color:black"> 
              <p style="margin-bottom: 4"><b> <a class="mainmenu" href="f_general.htm" style="font-size: 8pt; text-decoration: none; font-weight:700"> 
                Firewall</a></b> </td>
            <td bgcolor="#000000" style="border-style: none; border-width: medium; font-style:normal; font-variant:normal; font-weight:normal; font-size:10pt; color:black"> 
              <p style="margin-bottom: 4"> <b> <a class="mainmenu" href="vpn_summary.htm" style="font-size: 8pt; text-decoration: none; font-weight:700">VPN</a></b> 
            </td>
            <td bgcolor="#000000" style="border-style: none; border-width: medium; font-style:normal; font-variant:normal; font-weight:normal; font-size:10pt; color:black"> 
              <p style="margin-bottom: 4"> <b> <a class="mainmenu" href="log_setting.htm" style="font-size: 8pt; text-decoration: none; font-weight:700">Log</a></b> 
            </td>
            <td bgcolor="#000000" style="border-style: none; border-width: medium; font-style:normal; font-variant:normal; font-weight:normal; font-size:10pt; color:black"> 
              <p style="margin-bottom: 4"> <b> <a class="mainmenu" href="wizard.htm" style="font-size: 8pt; text-decoration: none; font-weight:700">Wizard</a></b> 
            </td>
            <td bgcolor="#000000" style="border-style: none; border-width: medium; font-style:normal; font-variant:normal; font-weight:normal; font-size:10pt; color:black"> 
              <p style="margin-bottom: 4"> <b> <a class="mainmenu" href="support.htm" style="font-size: 8pt; text-decoration: none; font-weight:700">Support</a></b> 
            </td>
            <td bgcolor="#000000" style="border-style: none; border-width: medium; font-style:normal; font-variant:normal; font-weight:normal; font-size:10pt; color:black"> 
              <p style="margin-bottom: 4"> <b> <a class="mainmenu" href="javascript: window.close()" style="font-size: 8pt; text-decoration: none; font-weight:700">Logout</a></b> 
            </td>
          </tr>
        </table></TD>
    </TR>
    <TR> 
      <TD height=21 colspan="2" vAlign=center bordercolor="#000000" bgColor=#6666CC style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"><table width="810" border="0" cellspacing="0" cellpadding="0">
          <!--DWLayoutTable-->
          <tr align="center" valign="middle"> 
            <td width="73" height="21" > 
              <div align="center"><span style="font-size: 8pt; background-color:#6666CC"><font color="#FFFFFF"> 
                <!--dhcp_setup
                      <a class="submenu" href="dhcp_setup.htm" style="text-decoration: none"> 
                      dhcp_setup-->
                Setup 
                <!--dhcp_setup
                      </a> 
                      dhcp_setup-->
                </font></span></div></td>
            <td width="3" > <table border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse; border-left-style: solid; border-left-width: 2" bordercolor="#FFFFFF" id="AutoNumber14" height="10" width="3">
                <tr> 
                  <td width="1" height="12" align="center" valign="middle"></td>
                </tr>
              </table></td>
            <td width="78" > 
              <p align="center"> <span style="font-size: 8pt; background-color:#6666CC"> 
                <font color="#FFFFFF"> 
                <!--dhcp_status-->
                <a class="submenu" href="dhcp_status.htm" style="text-decoration: none"> 
                <!--dhcp_status-->
                Status 
                <!--dhcp_status-->
                </a> 
                <!--dhcp_status-->
                </font> </span> </td>
            <td width="656"></td>
          </tr>
        </table></TD>
    </TR>
  </TABLE>
  <TABLE height=5 cellSpacing=0 cellPadding=0 width=960 bgColor=black border=0>  
  <TR bgColor=black>
    <TD width=150 height=1 style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; font-family: Arial, Helvetica, sans-serif; color: black" bgcolor="#E7E7E7" bordercolor="#E7E7E7">
			<img border="0" src="images_rv042/UI_03.gif" width="150" height="15"></TD>
    <TD width=810 height=1 style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; font-family: Arial, Helvetica, sans-serif; color: black" bgcolor="#FFFFFF">
			<img border="0" src="images_rv042/UI_02.gif" width="810" height="15"></TD></TR>
  </TABLE>
			
  <table border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse" bordercolor="#111111" id="AutoNumber9" width="961">
    <form name="formDHCPSetup" method="post" action="dhcp_setup.htm">
      <tr> 
        <td height="25" valign="middle" bgcolor="#000000" bordercolor="#E7E7E7" bordercolorlight="#E7E7E7" bordercolordark="#E7E7E7" width="142" align="right"><font color="#FFFFFF"><b><font face="Arial, Helvetica, sans-serif">Setup</font></b></font> 
        </td>
        <td width="8" valign="top" bgcolor="#000000">&nbsp;</td>
        <td width="20" valign="top" bgcolor="#FFFFFF">&nbsp;</td>
        <td width="620" valign="top" bgcolor="#FFFFFF"><font size="+0">&nbsp;</font><font size="+0">&nbsp;</font> 
          <div align="left"> </div>
        </td>
        <td width="20" valign="top" bgcolor="#FFFFFF" rowspan="7">&nbsp;</td>
        <td background="images_rv042/UI_05.gif" width="14" valign="top" rowspan="7">&nbsp;</td>
        <td width="136" rowspan="6" valign="top" bgcolor="#6666CC" align="right"> 
          <a href="javascript: openMap()"><img src="images_rv042/sitemap-off.jpg" width="136" height="28" border="0" onMouseOver="this.src=\'images_rv042/sitemap-on.jpg\'" onMouseOut="this.src=\'images_rv042/sitemap-off.jpg\'"></a> 
          <br>
          <br>
          <div align="left"><font face="Arial" style="font-size: 8pt" color="#FFFFFF"> 
            The Router can be used as a DHCP (Dynamic Host Configuration Protocol) 
            server on your network. A DHCP server assigns available IP addresses 
            to each computer on your network automatically. <br>
            <br>
            <a href="javascript: h_dhcp_setup();"><b><font face="Arial" style="font-size: 8pt" color="#FFFFFF">More...</font></b></a>	
            </font></div>
        </td>
        <td width="1"></td>
      </tr>
      <tr> 
        <td valign="top" bgcolor="#E7E7E7" bordercolor="#E7E7E7" bordercolorlight="#E7E7E7" bordercolordark="#E7E7E7" height="59" align="right">&nbsp;</td>
        <td background="images_rv042/UI_04.gif" valign="top">&nbsp;</td>
        <td valign="top" bgcolor="#FFFFFF">&nbsp;</td>
        <td valign="top" bgcolor="#FFFFFF"> 
          <input type=hidden name="page" value="dhcp_setup.htm">
          <input type=hidden name="submitStatus" value="1">
          <input type=hidden name="dhcpStatusChange" value="0">
		  <input type="hidden" name="deviceIP" value=\'192.168.1.1\'>
		  <input type=hidden name="LanIp" value=\'192.168.1.1\'>		
		  
		  <input type=hidden name="LanMask" value=\'255.255.255.0\'>
		  <input type="hidden" name="dsPPTP1" value=\'192\'>
		  <input type="hidden" name="dsPPTP2" value=\'168\'>  
		  <input type="hidden" name="dsPPTP3" value=\'1\'>  
          <input type="hidden" name="dsPPTP4" value=\'200\'>
		  <input type="hidden" name="dePPTP1" value=\'192\'>
		  <input type="hidden" name="dePPTP2" value=\'168\'>
		  <input type="hidden" name="dePPTP3" value=\'1\'>
          <input type="hidden" name="dePPTP4" value=\'204\'>
          <input type="hidden" name="PPTPEnabled" value=\' \'>		
          <center>
            <input type="checkbox" name="dhcpStatus"  onClick="falseSubmit(this.form)" value="0"  checked>
            
            <b>Enable DHCP Server</b> <br>
             
            <br>
            <hr align="center" size="1" color="#b5b5e6" noshade>
            <br>
             
          </center>
        </td>
        <td></td>
      </tr>
      <tr> 
        <td valign="top" bgcolor="#E7E7E7" bordercolor="#E7E7E7" bordercolorlight="#E7E7E7" bordercolordark="#E7E7E7" height="57" align="right"><b><font face="Arial, Helvetica, sans-serif"> 
           
          Dynamic IP 
           
          </font></b></td>
        <td background="images_rv042/UI_04.gif" valign="top">&nbsp;</td>
        <td valign="top" bgcolor="#FFFFFF">&nbsp;</td>
        <td valign="top" bgcolor="#FFFFFF"> 
           
          <p align="center"><b>Client Lease Time&nbsp;&nbsp; </b><font size="3"><b> 
            <input type="text" name="clTime" size="5" maxlength="5" onFocus="this.select();" onBlur="  timeCheck(this);" value=\'1440\'>
            </b></font><b> &nbsp; Minutes &nbsp;</b></p>
          <table width="98%" border="0" align="center">
            <tr> 
              <td> 
                <div align="right"></div>
                <div align="center"><b>Dynamic IP Range</b><font face="Arial Unicode MS"> 
                  </font></div>
                <font size="3"><b> </b></font></td>
            </tr>
            <tr> 
              <td valign="middle" align="center"> 
                <div align="center"><b>Range Start : &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
                  <input type=hidden name="ds1" value=\'192\'>
                  192
                  . 
                  <input type=hidden name="ds2" value=\'168\'>
                  168
                  . 
                  <input type=hidden name="ds3" value=\'1\'>
                  1
                  . 
                  <input type=text name="ds4" value=\'29\' maxlength="3" onBlur=" NetworkRangeCheck(this, this.form.LanIp.value, this.form.LanMask.value, 4)" size="3" onFocus="this.select(); blurList1(this.form);">
                  </b></div>
              </td>
            </tr>
            <tr> 
              <td align="center" valign="middle"> 
                <div align="center"><b>&nbsp;&nbsp;Range End : &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
                  <input type=hidden name="de1" value=\'192\'>
                  192
                  . 
                  <input type=hidden name="de2" value=\'168\'>
                  168
                  . 
                  <input type=hidden name="de3" value=\'1\'>
                  1
                  . 
                  <input type=text name="de4" value=\'254\' maxlength="3" onBlur=" NetworkRangeCheck(this, this.form.LanIp.value, this.form.LanMask.value, 4)" size="3" onFocus="this.select(); blurList1(this.form);">
                  </b></div>
              </td>
            </tr>
          </table>
          <br>
          <hr align="center" size="1" color="#b5b5e6" noshade>
          <br>
           
        </td>
        <td rowspan="3"></td>
      </tr>
      <tr> 
        <td valign="top" bgcolor="#E7E7E7" bordercolor="#E7E7E7" bordercolorlight="#E7E7E7" bordercolordark="#E7E7E7" height="43" align="right"><font face="Arial, Helvetica, sans-serif"><b> 
          Static IP 
          </b></font></td>
        <td background="images_rv042/UI_04.gif" valign="top">&nbsp;</td>
        <td valign="top" bgcolor="#FFFFFF">&nbsp;</td>
        <td valign="top" bgcolor="#FFFFFF"> 
          <table width="98%" align="center" cellspacing="0" border="0">
             <tr>
                  <td width ="46" height="18" valign="top">&nbsp;</td>
                  <td valign="top" colspan="2" align="right">                 <input type="button" value="Show new IP user" name="MAC_to_List" onClick=" openTable(\'Dhcp_table1.htm\')">&nbsp;</td>
                  <td width="51" valign="top">&nbsp;</td>
                </tr>
                <tr> 
			<tr> 
              <td width="46" height="18" valign="top">&nbsp;</td>
              <td valign="top" colspan="2" bgcolor="#CCCCFF" align="center"> <b><font face="Arial, Helvetica, sans-serif">Static Entry</font></b> </td>
              <td width="51" valign="top">&nbsp;</td>
            </tr>
            <tr> 
              <td height="18" valign="top" width="46">&nbsp;</td>
              <td width="152" valign="middle" align="right" bgcolor="#CCCCFF"> 
                <b><font face="Arial, Helvetica, sans-serif">Static IP Address: &nbsp;</font></b></td>
              <td width="351" valign="middle" align="left" bgcolor="#CCCCFF"> &nbsp; 
                <font face="Arial, Helvetica, sans-serif"> 
                <input type=text name="ss1"                maxlength="3" size="3" onFocus="this.select()">
                . 
                <input type=text name="ss2"                maxlength="3" size="3" onFocus="this.select()">
                . 
                <input type=text name="ss3"                maxlength="3" size="3" onFocus="this.select()">
                . 
                <input type=text name="ss4"                maxlength="3" size="3" onFocus="this.select()">
                </font>&nbsp; </td>
              <td valign="top" width="51">&nbsp;</td>
            </tr>
            <tr> 
              <td height="27" valign="top" width="46">&nbsp;</td>
              <td valign="middle" align="right" bgcolor="#CCCCFF" width="152"><b><font face="Arial, Helvetica, sans-serif">MAC 
                Address: &nbsp;</font></b></td>
              <td valign="middle" align="left" bgcolor="#CCCCFF" width="351"> 
                &nbsp;<b> </b><font face="Arial, Helvetica, sans-serif">
                <input type=text name="sMAC1"                size="2" maxlength="2" onFocus="this.select()">
                -
				<input type=text name="sMAC2"                size="2" maxlength="2" onFocus="this.select()">
                -
				<input type=text name="sMAC3"                size="2" maxlength="2" onFocus="this.select()">
                -
				<input type=text name="sMAC4"                size="2" maxlength="2" onFocus="this.select()">
                -
				<input type=text name="sMAC5"                size="2" maxlength="2" onFocus="this.select()">
                -
				<input type=text name="sMAC6"                size="2" maxlength="2" onFocus="this.select()">
                </font></td>
              <td valign="top" width="51">&nbsp;</td>
            </tr>
			 <tr> 
              <td height="27" valign="top" width="46">&nbsp;</td>
              <td valign="middle" align="right" bgcolor="#CCCCFF" width="152"><b><font face="Arial, Helvetica, sans-serif">Name: &nbsp;</font></b></td>
              <td valign="middle" align="left" bgcolor="#CCCCFF" width="351"> 
                &nbsp;<b> </b><font face="Arial, Helvetica, sans-serif"><input type=text name="userName"                maxlength="12" size="12" onFocus="this.select()">&nbsp;
                </font></td>
              <td valign="top" width="51">&nbsp;</td>
            </tr>
			 <tr> 
              <td height="27" valign="top" width="46">&nbsp;</td>
              <td valign="middle" align="right" bgcolor="#CCCCFF" width="152"><b><font face="Arial, Helvetica, sans-serif">Enable: &nbsp;</font></b></td>
              <td valign="middle" align="left" bgcolor="#CCCCFF" width="351"> 
                &nbsp;<font face="Arial, Helvetica, sans-serif">
				 <input type="checkbox" name="dhcpEnable"  value="0" >
                </font></td>
              <td valign="top" width="51">&nbsp;</td>
            </tr>
			<tr> 
              <td valign="top" height="96" width="46">&nbsp;</td>
              <td colspan="2" valign="top" bgcolor="#CCCCFF"> 
                <div align="center"> <b><font size="3"><b> 
                  <input type="button" value="Add to list" name="btnAddToList" onClick="IpMACaddSel(this.form.ss1,this.form.ss2,this.form.ss3,this.form.ss4,this.form.sMAC1,this.form.sMAC2,this.form.sMAC3,this.form.sMAC4,this.form.sMAC5,this.form.sMAC6,this.form.dhcp_staticList1,this.form.dhcpEnable,this.form.userName);">
                  </b></font></b><br>
                  <b><font size="3"><b> 
                  <select multiple name="dhcp_staticList1"                      size="10" onChange="showdeleteButton2(this.form, this)" style="width: 90%">
                    
                  </select>
                  </b></font></b><br>
                  <b><font size="3"><b> </b></font></b> </div>
              </td>
              <td valign="top" width="51">&nbsp;</td>
            </tr>
            <tr> 
              <td valign="top" width="46">&nbsp;</td>
              <td colspan="2" valign="top" align="center" bgcolor="#CCCCFF">
                <table width="100%" align="center">
                  <tr> 
                    <td height="33" valign="top" width="153" align="center">&nbsp; </td>
                    <td width="178" valign="top" align="center"> 
                      <input type="button" value="Delete selected Entry" name="delStatic" onClick="delSel(this.form.dhcp_staticList1);" disabled>
                    </td>
                    <td width="153" valign="top" align="left"> <span id="btnNew" style="visibility: hidden"> 
                      <input type="button" name="showNew" value="Add New" onClick="clearContent(this.form)">
                      </span></td>
                  </tr>
                </table>
              </td>
              <td valign="top" width="51">&nbsp;</td>
            </tr>
			<tr><td height="30"></td>
				<td></td><td></td></tr>
			<tr><td></td><td colspan="2"><input type="checkbox" name="BlockMacWrongIP"  value="1" >
			            <font size="2"><b>Block MAC address on the list with wrong IP address</b></font></td></tr>
			<tr><td></td><td colspan="2"><input type="checkbox" name="BlockMacNotList"  value="1" >			
                        <font size="2"><b>Block MAC address not on the list</b> </font></td></tr>
          </table>
		  <br>
          <hr align="center" size="1" color="#b5b5e6" noshade>
          <br>
        </td>
      </tr>
      <tr> 
        <td valign="top" bgcolor="#E7E7E7" bordercolor="#E7E7E7" bordercolorlight="#E7E7E7" bordercolordark="#E7E7E7" align="right"><font face="Arial, Helvetica, sans-serif"><b> 
           
          DNS 
           
          </b></font></td>
        <td background="images_rv042/UI_04.gif" valign="top">&nbsp;</td>
        <td valign="top" bgcolor="#FFFFFF">&nbsp;</td>
        <td valign="top" bgcolor="#FFFFFF"> 
           
          <table width="98%" align="center">            
            <tr> 
              <td align="right" nowrap width="38%"> 
                <p align="right"><font face="Arial Unicode MS"><b> DNS Server 
                  (Required) 1:</b></font> 
              </td>
              <td nowrap width="62%"> 
                <div align="left"><font face="Arial Unicode MS"> 
                  <input type="text" name="LanDnsA1" value=\'0\' maxlength="3" size="3" onFocus="this.select();" onBlur=" IPCheck(this)">
                  . 
                  <input type="text" name="LanDnsA2" value=\'0\' maxlength="3" size="3" onFocus="this.select();" onBlur=" IPCheck(this)">
                  . 
                  <input type="text" name="LanDnsA3" value=\'0\' maxlength="3" size="3" onFocus="this.select();" onBlur=" IPCheck(this)">
                  . 
                  <input type="text" name="LanDnsA4" value=\'0\' maxlength="3" size="3" onFocus="this.select();" onBlur=" IP0to254Check(this)">
                  </font></div>
              </td>
            </tr>
            <tr> 
              <td align="right" nowrap width="38%" height="11"> 
                <div align="right"><font face="Arial Unicode MS"><b>2:</b></font></div>
              </td>
              <td nowrap width="62%" height="11"> 
                <div align="left"><font face="Arial Unicode MS"> 
                  <input type="text" name="LanDnsB1" value=\'0\' maxlength="3" size="3" onFocus="this.select();" onBlur=" IPCheck(this)">
                  . 
                  <input type="text" name="LanDnsB2" value=\'0\' maxlength="3" size="3" onFocus="this.select();" onBlur=" IPCheck(this)">
                  . 
                  <input type="text" name="LanDnsB3" value=\'0\' maxlength="3" size="3" onFocus="this.select();" onBlur=" IPCheck(this)">
                  . 
                  <input type="text" name="LanDnsB4" value=\'0\' maxlength="3" size="3" onFocus="this.select();" onBlur=" IP0to254Check(this)">
                  </font></div>
              </td>
            </tr>
          </table>
		  <br>
          <hr align="center" size="1" color="#b5b5e6" noshade>
          <br>
           
        </td>
      </tr>
      <tr> 
        <td valign="top" bgcolor="#E7E7E7" bordercolor="#E7E7E7" bordercolorlight="#E7E7E7" bordercolordark="#E7E7E7" rowspan="2" align="right"><b><font face="Arial, Helvetica, sans-serif"> 
          </font></b><b> 
           
          WINS 
           
          </b></td>
        <td background="images_rv042/UI_04.gif" rowspan="2" valign="top">&nbsp;</td>
        <td rowspan="2" valign="top" bgcolor="#FFFFFF">&nbsp;</td>
        <td rowspan="2" valign="top" bgcolor="#FFFFFF"> 
           
          <table width="98%" border="0" align="center">
            <tr> 
              <td align="center" valign="middle"> 
                <div align="center"><b>WINS Server :</b><font size="3"><b> 
                  <input type="text" name="WSip1" value=\'0\' size="3" maxlength="3" onFocus="this.select();" onBlur=" IPCheck(this)">
                  . 
                  <input type="text" name="WSip2" value=\'0\' size="3" maxlength="3" onFocus="this.select();" onBlur=" IPCheck(this)">
                  . 
                  <input type="text" name="WSip3" value=\'0\' size="3" maxlength="3" onFocus="this.select();" onBlur=" IPCheck(this)">
                  . 
                  <input type="text" name="WSip4" value=\'0\' size="3" maxlength="3" onFocus="this.select();" onBlur=" IPCheck(this)">
                  </b></font></div>
              </td>
            </tr>
          </table>
           
          <br>
          <br>
          <br>
        </td>
        <td height="70"></td>
      </tr>
      <tr> 
        <td valign="bottom" rowspan="2" bgcolor="#6666CC" align="right"><img src="images_rv042/cisco.gif" width="136" height="62"></td>
        <td height="37"></td>
      </tr>
      <tr> 
        <td height="25" colspan="2" valign="top" bgcolor="#000000" bordercolor="#E7E7E7" bordercolorlight="#E7E7E7" bordercolordark="#E7E7E7">&nbsp; 
        </td>
        <td valign="top" bgcolor="#6666CC" bordercolor="#E7E7E7" bordercolorlight="#E7E7E7" bordercolordark="#E7E7E7">&nbsp;</td>
        <td valign="middle" bgcolor="#6666CC" bordercolor="#E7E7E7" bordercolorlight="#E7E7E7" bordercolordark="#E7E7E7"> 
          <table border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse" bordercolor="#111111" id="AutoNumber15" width="220" align="right" height="19">
            <tr> 
              <td width="101" bgcolor="#42498C" align="center"> <a href="javascript: chSubmit(document.formDHCPSetup)"><font color="#FFFFFF" style="font-size: 8pt; font-weight: 700" face="Arial"> 
                Save Settings</font></a></td>
              <td width="8" align="center" bgcolor="#6666CC">&nbsp;</td>
              <td width="103" bgcolor="#434A8F" align="center"> <a href="dhcp_setup.htm"> 
                <font color="#FFFFFF" style="font-size: 8pt; font-weight: 700" face="Arial"> 
                Cancel Changes</font></a></td>
            </tr>
          </table>
        </td>
        <td valign="top" bgcolor="#6666CC" bordercolor="#E7E7E7" bordercolorlight="#E7E7E7" bordercolordark="#E7E7E7">&nbsp;</td>
        <td valign="top" bgcolor="#000000"> 
          <div align="center"> 
            <center>
            </center>
          </div>
        </td>
        <td></td>
      </tr>
    </form>
  </table>
    
            </div></body>
</html>
END

our $home = <<'END_HOME';
<html>

<head><meta name="Pragma" content="No-Cache">

<!--<meta http-equiv="refresh" content="5">-->
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

<title>Web Management</title>

<base target="_self">

<style fprolloverstyle>A:hover {color: #00FFFF}

.help:link {text-decoration: underline}

.help:visited {text-decoration: underline}

.help:hover {color: #FFCC00; text-decoration: underline}

.logout:link {text-decoration: none}

.logout:visited {text-decoration: none}

.logout:hover {color: #FFCC00; text-decoration: none}

</style>

<style type="text/css">

body {font-family:Arial, Verdana, sans-serif, Helvetica; background-color: #ffffff;}

td, input, select {font-size: 11px}

</style>
<link rel="stylesheet" href="nk.css">
<script src="nk20060810141951.js"></script> <!--<script src="nk.js"></script>-->

<script language=JavaScript>
function chRenew()
{
    if (document.formsummary.getHMark.value!="")
	document.location="#"+document.formsummary.getHMark.value;
}
function falseSubmit(n)
{
  document.formsummary.submitStatus.value=n;
  document.formsummary.submit();
}

var wMap=null;
function openMap()
{
  if (wMap==null)
  wMap=window.open(\'map.htm\',\'sitemap\',\'menubar=no,scrollbars,width=670,height=470\');

}
function closeMap()
{
  if (wMap!=null)
  {
    wMap.close();
	wMap=null;
  }
}
function mapTo(p)
{
  document.location.href=p; 
  closeMap(); 
}
window.onfocus=closeMap;
</script>
</head>



<body link="#B5B5E6" vlink="#B5B5E6" alink="#B5B5E6" onLoad="chRenew()" onUnLoad="closeMap()">

<DIV align=center>




  <table border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse" bordercolor="#111111" id="AutoNumber11" width="960" height="68">

    <tr> 

      <td valign="bottom" width="650" hetght="39" bgcolor="#6666CC"> <img border="0" src="images_rv042/clinksys.gif" width="165" height="57" align="middle"> 

      </td>

      <td valign="bottom" bgcolor="#6666CC" width="337"> 


        <div align="right"><font color="#FFFFFF"> <span style="font-size: 7pt">&nbsp;&nbsp;&nbsp;&nbsp; 

          Firmware Version: 1.3.7.10</span><font face="Arial"><span style="font-size: 7pt">&nbsp;&nbsp;&nbsp;</span></font></font></div>

      </td>



    </tr>

    <tr> 

      <td colspan="2" valign="top"> <img border="0" src="images_rv042/UI_10.gif" width="960" height="11"></td>



    </tr>

  </table>

   

  



   



  <table width="960" height="90" border="0" cellspacing="0" cellpadding="0">
    <form name="formdualwan" method="post" action="">
      <input type="hidden" name="dualwanEnabled" value=\'0\'>
      <input type="hidden" name="firewall0" value=\'\'>
    </form>
    <tr> 
      <td width="150" height="90" rowspan="3" align="center" valign="middle" bgcolor="#000000"style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"> 
        <h3 style="margin-top: 1; margin-bottom: 1" align="center"><font face="Arial" color="#FFFFFF"> System<br>
          Summary</font></h3></td>
      <td width="690" height="33" align="right" valign="middle" bgcolor="#6666CC" style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"> 
        <p><b><font color="#FFFFFF"><span lang="en-us"> 10/100 4-port VPN Router&nbsp;&nbsp;&nbsp;&nbsp;</span></font></b></td>
      <td width="120" bgcolor="#000000"style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"> 
        <p align="center"><font color="#FFFFFF"> <span style="font-size: 8pt"><b>RV042</b></span></font> 
      </td>
    </tr>
    <tr> 
      <td colspan="2" bgcolor="#6666CC"><table width="810" border="0" cellspacing="0" cellpadding="0" >
          <!--DWLayoutTable-->
          <tr  align="center"> 
            <td width="100" height="8" valign="middle" background="images_rv042/UI_07.gif" style=""></td>
            <td width="80" valign="middle" background="images_rv042/UI_06.gif"style=""></td>
            <td width="70" valign="middle" background="images_rv042/UI_06.gif"style=""></td>
            <td width="110" valign="middle" background="images_rv042/UI_06.gif"style=""></td>
            <td width="80" valign="middle" background="images_rv042/UI_06.gif"style=""></td>
            <td width="60" valign="middle" background="images_rv042/UI_06.gif"style=""></td>
            <td width="60" valign="middle" background="images_rv042/UI_06.gif"style=""></td>
            <td width="80" valign="middle" background="images_rv042/UI_06.gif"style=""></td>
            <td width="85" valign="middle" background="images_rv042/UI_06.gif"style=""></td>
            <td width="85" valign="middle" background="images_rv042/UI_06.gif"style=""></td>
          </tr>
          <tr  align="center" valign="middle"> 
            <td height="28" style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"> 
              <p align="center" style="margin-bottom: 4"> <b> <font color="#FFFFFF" style="font-size: 8pt"> 
                System<br>
                Summary</font></b> </td>
            <td bgcolor="#000000" style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"> 
              <p align="center" style="margin-bottom: 4"><b> <a class="mainmenu" href="network.htm" style="font-size: 8pt; text-decoration: none; font-weight:700">Setup</a></b> 
            </td>
            <td bgcolor="#000000" style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"> 
              <p style="margin-bottom: 4"> <b> <a class="mainmenu" href="dhcp_setup.htm" style="font-size: 8pt; text-decoration: none; font-weight:700">DHCP</a></b> 
            </td>
            <td bgcolor="#000000" style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"> 
              <p style="margin-bottom: 4"> <b> 
                <script>
          if (document.formdualwan.dualwanEnabled.value=="1") 
		  	  document.write(\'<a class="mainmenu" href="sys_dualwanw.htm" style="font-size: 8pt; text-decoration: none; font-weight:700">\');
          else document.write(\'<a class="mainmenu" href="sys_dualwan3.htm" style="font-size: 8pt; text-decoration: none; font-weight:700">\');
          </script>
                System<br>
                Management </b> </td>
            <td bgcolor="#000000" style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"> 
              <p style="margin-bottom: 4"><b> <a class="mainmenu" href="f_general.htm" style="font-size: 8pt; text-decoration: none; font-weight:700"> 
                Firewall</a></b> </td>
            <td bgcolor="#000000" style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"> 
              <p style="margin-bottom: 4"> <b> <a class="mainmenu" href="vpn_summary.htm" style="font-size: 8pt; text-decoration: none; font-weight:700">VPN</a></b> 
            </td>
            <td bgcolor="#000000" style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"> 
              <p style="margin-bottom: 4"> <b> <a class="mainmenu" href="log_setting.htm" style="font-size: 8pt; text-decoration: none; font-weight:700">Log</a></b> 
            </td>
            <td bgcolor="#000000" style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"> 
              <p style="margin-bottom: 4"> <b> <a class="mainmenu" href="wizard.htm" style="font-size: 8pt; text-decoration: none; font-weight:700">Wizard</a></b> 
            </td>
            <td bgcolor="#000000" style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"> 
              <p style="margin-bottom: 4"> <b> <a class="mainmenu" href="support.htm" style="font-size: 8pt; text-decoration: none; font-weight:700">Support</a></b> 
            </td>
            <td bgcolor="#000000" style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"> 
              <p style="margin-bottom: 4"> <b> <a class="mainmenu" href="javascript: window.close()" style="font-size: 8pt; text-decoration: none; font-weight:700">Logout</a></b> 
            </td>
          </tr>
        </table></td>
    </tr>
    <tr> 
      <td height="21" colspan="2" bgcolor="#6666CC">&nbsp;</td>
    </tr>
  </table>
  <TABLE height=5 cellSpacing=0 cellPadding=0 width=960 bgColor=black border=0>  



  <TR bgColor=black>



    <TD width=150 height=1 style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black" bgcolor="#E7E7E7" bordercolor="#E7E7E7">



			<img border="0" src="images_rv042/UI_03.gif" width="150" height="15"></TD>



    <TD width=810 height=1 style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black" bgcolor="#FFFFFF">



			<img border="0" src="images_rv042/UI_02.gif" width="810" height="15"></TD></TR>



  </TABLE>











			



  <table border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse" bordercolor="#111111" id="AutoNumber9" width="961" height="209">
    <form name="formsummary" method="post" action="home.htm#1">
      <tr> 
        <td valign="middle" bgcolor="#E7E7E7" bordercolor="#E7E7E7" bordercolorlight="#E7E7E7" bordercolordark="#E7E7E7" width="142"> 
          <div align="right"><font color="#FFFFFF"><b></b></font></div>
        </td>
        <td width="8" valign="top" bgcolor="#E7E7E7" bordercolor="#E7E7E7" background="images_rv042/UI_04.gif">&nbsp;</td>
        <td width="20" valign="top" bgcolor="#FFFFFF">&nbsp;</td>
        <td width="620" valign="top" bgcolor="#FFFFFF"><font size="+0">&nbsp;</font><font size="+0">&nbsp;</font> 
          <div align="left"> 
            <input type=hidden name="page" value="home.htm">
            <input type="hidden" name="dualwanEnabled" value=\'0\'>
            <input type="hidden" name="submitStatus" value="0">
			<input type="hidden" name="getHMark" value=\'\'>
			<input type=hidden name="DmzRangeFlag" value=\'0\'>
          </div>
        </td>
        <td width="20" valign="top" bgcolor="#FFFFFF" rowspan="11">&nbsp;</td>
        <td background="images_rv042/UI_05.gif" width="14" valign="top" rowspan="11">&nbsp;</td>
        <td width="136" rowspan="10" valign="top" bgcolor="#6666CC" align="right"> 
          <div align="right"><a href="javascript: openMap()"><img src="images_rv042/sitemap-off.jpg" width="136" height="28" border="0" onMouseOver="this.src=\'images_rv042/sitemap-on.jpg\'" onMouseOut="this.src=\'images_rv042/sitemap-off.jpg\'"></a> 
            <br>
            <br>
          </div>
          <div align="left"><font face="Arial" style="font-size: 8pt" color="#FFFFFF">The System Summary screen displays the router\'s current status and settings. This information is read only. If you click the button with underline, it will hyperlink to related setup pages. 
		  On the right side of the screen and all other screens in the Utility will be a link to the Site Map, which has links to all of the Utility\'s tabs.
		  <br><br>
		  Serial Number: The serial number of the RV042 unit.
<br><br>
System up time: The length of time in Days, Hours, and Minutes that the RV042 is active.
<br><br>
Firmware version: The current version number of the firmware installed on this unit.
<br><br>
CPU: The type of the RV042 processor. It is Intel IXP425/422.
<br><br>
DRAM: The size of DRAM on the board. It is 32MB.
<br><br>
Flash: The size of Flash on the board. It is 8MB. 
<br><br>
Configuration: If you need guideline to re-configure the router, you may launch Wizard.
<br><br>
Port Statistics: Users can click the port number from port diagram to see the status of the selected port.
<br><br>
<a href="javascript: h_home();"><b><font face="Arial" style="font-size: 8pt" color="#FFFFFF">More...</font></b></a>
		  </font></div> 
          </td>
        <td width="1"></td>
      </tr>
      <tr> 
        <td valign="top" bgcolor="#E7E7E7" bordercolor="#E7E7E7" bordercolorlight="#E7E7E7" bordercolordark="#E7E7E7" rowspan="2"> 
          <div align="right"><b>System Information</b></div>
        </td>
        <td background="images_rv042/UI_04.gif" valign="top" rowspan="2">&nbsp;</td>
        <td valign="top" bgcolor="#FFFFFF" rowspan="2">&nbsp;</td>
        <td valign="top" bgcolor="#FFFFFF" rowspan="2"> 
          <table width="98%" align="center" style="line-height: 0.8em">
            <tr> 
              <td width="41%">Serial Number : &nbsp;&nbsp; 
                DHY005B00300
              </td>
              <td width="59%">Firmware version : &nbsp;&nbsp; 
                1.3.7.10  (Aug 10 2006 14:19:51)
              </td>
            </tr>
          </table>
          <table width="98%" align="center">
            <tr> 
              <td width="243" height="21">CPU : &nbsp;&nbsp; 
                Intel IXP425-266
              </td>
              <td width="210">DRAM : &nbsp;&nbsp; 
                32M
              </td>
              <td width="139">Flash : &nbsp;&nbsp; 
                8M
              </td>
            </tr>
          </table>
          <table align="center" width="98%">
            <tr> 
              <td height="20">System up time :  &nbsp;&nbsp;
                37 Days 18 Hours 30 Minutes 0 Seconds
                &nbsp;&nbsp; (Now: 
                
                Fri Feb  7 2003 10:29:52
                ) </td>
            </tr>
          </table>
          <br>
          <hr align="center" size="1" color="#b5b5e6" noshade>
          <br>
        </td>
        <td></td>
      </tr>
      <tr> 
        <td></td>
      </tr>
      <tr> 
        <td valign="top" bgcolor="#E7E7E7" bordercolor="#E7E7E7" bordercolorlight="#E7E7E7" bordercolordark="#E7E7E7"> 
          <div align="right"><b>Configuration</b></div>
        </td>
        <td background="images_rv042/UI_04.gif" valign="top">&nbsp;</td>
        <td valign="top" bgcolor="#FFFFFF">&nbsp;</td>
        <td valign="top" bgcolor="#FFFFFF"> If you need guideline to re-configure 
          the router, you may launch wizard. <font size="-1"> 
          <input type="button" value="Setup Wizard" name="B3" onClick="document.location.href=\'wizard.htm\'" style="font-size: 11px">
          </font><br> 
          <br>
          <hr align="center" size="1" color="#b5b5e6" noshade>
          <br>
        </td>
        <td></td>
      </tr>
      <tr> 
        <td valign="top" bgcolor="#E7E7E7" bordercolor="#E7E7E7" bordercolorlight="#E7E7E7" bordercolordark="#E7E7E7" rowspan="2"> 
          <div align="right"><b>Port Statistics</b></div>
        </td>
        <td background="images_rv042/UI_04.gif" valign="top" rowspan="2">&nbsp;</td>
        <td valign="top" bgcolor="#FFFFFF" rowspan="2">&nbsp;</td>
        <td valign="top" height="100"> 
          <table width="406" align="center" cellpadding="0" cellspacing="0" border="0" height="110">
            <tr> 
              <td width="41" height="110" valign="top"><img src="images_rv042/left.gif" width="41" height="110"></td>
              <td width="52" valign="top"><img src=\'images_rv042/po1_0.gif\' width="52" height="110" usemap="#MapP1" border="0"></td>
              <td width="45" valign="top"><img src=\'images_rv042/po2_0.gif\' width="45" height="110" usemap="#MapP2" border="0"></td>
              <td width="45" valign="top"><img src=\'images_rv042/po3_0.gif\' width="45" height="110" usemap="#MapP3" border="0"></td>
              <td width="47" valign="top"><img src=\'images_rv042/po4_0.gif\' width="47" height="110" usemap="#MapP4" border="0"></td>
              <td width="51" valign="top"><img src=\'images_rv042/wan_1.gif\' width="51" height="110" usemap="#MapWAN" border="0"></td>
              <td width="54" valign="top"><img src=\'images_rv042/dmz_00.gif\' width="54" height="110" usemap="#MapDMZ" border="0"></td>
              <td width="71" valign="top"><img src="images_rv042/right.gif" width="71" height="110"></td>
            </tr>
          </table>
        </td>
        <td></td>
      </tr>
      <tr> 
        <td valign="top">
		  <table width="100%" align="center" cellpadding="0" cellspacing="0" border="0">
            <tr> 
              <td height="19" width="154" valign="top">&nbsp;</td>
              <td valign="top" width="186" align="center">LAN</td>
              <td width="49" valign="top" align="center"> 
                <script>
if (document.formsummary.dualwanEnabled.value=="0") document.write("WAN");
else document.write("WAN1");
</script>
              </td>
              <td width="50" valign="top" align="center"> 
                <script>
if (document.formsummary.dualwanEnabled.value=="0") document.write("DMZ");
else document.write("WAN2");
</script>
              </td>
              <td width="181" valign="top">&nbsp;</td>
            </tr>
          </table>
<a name="1"></a>		
          <hr align="center" size="1" color="#b5b5e6" noshade>
          <br>
        </td>
        <td></td>
      </tr>
      <tr> 

        <td valign="top" bgcolor="#E7E7E7" bordercolor="#E7E7E7" bordercolorlight="#E7E7E7" bordercolordark="#E7E7E7"> 
          <div align="right"><b>Network Setting Status</b></div>
        </td>
        <td background="images_rv042/UI_04.gif" valign="top">&nbsp;</td>
        <td valign="top" bgcolor="#FFFFFF">&nbsp;</td>
        <td valign="top" bgcolor="#FFFFFF">
 
          <table width="98%" align="center" style="line-height: 0.8em">
            <tr valign="middle"> 
              <td width="41%"><u><font color="#0000FF"><a href="network.htm"><font color="#000000">LAN 
                IP</font></a></font></u><font color="#000000"> : </font> </td>
              <td colspan="2"> 
                192.168.1.1
              </td>
            </tr>
            <tr valign="middle"> 
              <td width="41%"><font color="#0000FF"><u><a href="network.htm"> 
                <font color="#000000"> 
                <script>
if (document.formsummary.dualwanEnabled.value=="0") document.write("WAN IP");
else document.write("WAN1 IP");
</script>
                </font></a></u></font><font color="#000000"> :</font> </td>
              <td width="32%"> 
                10.100.4.40 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
              </td>
              <td width="27%"> 
                 
              </td>
            </tr>
            <tr valign="middle"> 
              <td width="41%"><font color="#0000FF"><u><a href="network.htm"><font color="#000000"> 
                <script>
if (document.formsummary.dualwanEnabled.value=="0") document.write("DMZ IP");
else document.write("WAN2 IP");
</script>
                </font></a></u></font><font color="#000000"> :</font> </td>
              <td width="32%"> 
                <script> 
				    if ((document.formsummary.dualwanEnabled.value=="0") && (document.formsummary.DmzRangeFlag.value=="1"))
					    document.write("---");
					else
                		document.write(\'0.0.0.0 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; \');			
				</script>
              </td>
              <td width="27%"> 
                 
              </td>
            </tr>
            <tr valign="middle"> 
              <td width="41%"><u><font color="#0000FF"><a href="adv_routing.htm"><font color="#000000">Mode</font></a></font></u><font color="#000000"> 
                : </font></td>
              <td colspan="2"> 
                Gateway
              </td>
            </tr>
            <tr valign="middle"> 
              <td width="41%"><u><font color="#0000FF"><a href="network.htm"><font color="#000000">DNS</font></a></font></u> 
                <font color="#000000"> 
                <script>
				if (document.formsummary.dualwanEnabled.value=="1")
				{
				     document.write("(WAN1) :");
					 document.write("<br>");
					 document.write("<font color=\'#FFFFFF\'>DNS</font> (WAN2) :");
				}
				else
				document.write(" :");
				</script>
                </font></td>
              <td colspan="2"> 
                10.10.1.9  &nbsp;&nbsp;&nbsp; 10.10.1.9
                &nbsp;
              </td>
            </tr>
            <tr valign="middle"> 
              <td width="41%"><u><font color="#0000FF"><a href="adv_ddns.htm"><font color="#000000">DDNS</font></a></font></u><font color="#000000"> 
                <script>if (document.formsummary.dualwanEnabled.value=="1") document.write("(WAN1 &nbsp; | &nbsp; WAN2)");</script>
                : </font></td>
              <td colspan="2"> 
                Off
              </td>
            </tr>
            <tr valign="middle"> 
              <td width="41%"><font color="#0000FF"><u><a href="adv_dmz.htm"><font color="#000000">DMZ 
                Host</font></a> </u></font><font color="#000000"> : </font></td>
              <td colspan="2"> 
                Disabled
              </td>
            </tr>
          </table>
          <br>
          <hr align="center" size="1" color="#b5b5e6" noshade>
          <br>
        </td>
        <td></td>

      </tr>
      <tr> 
        <td valign="top" bgcolor="#E7E7E7" bordercolor="#E7E7E7" bordercolorlight="#E7E7E7" bordercolordark="#E7E7E7"> 
          <div align="right"><b>Firewall Setting Status</b></div>
        </td>
        <td background="images_rv042/UI_04.gif" valign="top">&nbsp;</td>
        <td valign="top" bgcolor="#FFFFFF">&nbsp;</td>
        <td valign="top" bgcolor="#FFFFFF"> 
          <table width="98%" align="center" style="line-height: 0.8em">
            <tr> 
              <td width="41%"><u><font color="#0000FF"><a href="f_general.htm"><font color="#000000">SPI (Stateful 
                Packet Inspection)</font></a></font></u><font color="#000000"> 
                :</font></td>
              <td width="59%">
<script>
if (document.formdualwan.firewall0.value=="") document.write(\'Off\');			   
else document.write(\'On\');
</script>				
              </td>
            </tr>
            <tr> 
              <td width="41%"><u><font color="#0000FF"><a href="f_general.htm"><font color="#000000">DoS (Denial 
                of Service)</font></a></font></u><font color="#000000"> :</font> 
              </td>
              <td width="59%">
<script>			   
if (document.formdualwan.firewall0.value=="") document.write(\'Off\');			   
else document.write(\'On\');
</script>				
              </td>
            </tr>
            <tr> 
              <td width="41%"><a href="f_general.htm"><font color="#000000">Block 
                WAN Request</font></a><font color="#000000"> :</font></td>
              <td width="59%">
<script> 
if (document.formdualwan.firewall0.value=="") document.write(\'Off\');			   
else document.write(\'On\');
</script>
              </td>
            </tr>
            <!--

            <tr> 

              <td width="40%"><font face="Arial Unicode MS" size="-1"><u><font color="#0000FF"><a href="content_filter.htm"><font color="#000000">Content 

                Filter</font></a></font></u><font color="#000000"> Type : </font></font></td>

              <td width="60%">&nbsp;</td>

            </tr>

			-->
          </table>
          <br>
          <hr align="center" size="1" color="#b5b5e6" noshade>
          <br>
        </td>
        <td></td>
      </tr>
      <tr> 
        <td valign="top" bgcolor="#E7E7E7" bordercolor="#E7E7E7" bordercolorlight="#E7E7E7" bordercolordark="#E7E7E7"> 
          <div align="right"><b>VPN Setting Status</b></div>
        </td>
        <td background="images_rv042/UI_04.gif" valign="top">&nbsp;</td>
        <td valign="top" bgcolor="#FFFFFF">&nbsp;</td>
        <td valign="top" bgcolor="#FFFFFF"> 
          <table width="98%" align="center" style="line-height: 0.8em">
            <tr> 
              <td width="41%"><font color="#000000"><a href="vpn_summary.htm"><font color="#000000">VPN 
                Summary</font></a> : </font></td>
              <td width="59%">&nbsp;</td>
            </tr>
            <tr> 
              <td width="41%"><font color="#000000">Tunnel(s) Used :</font></td>
              <td width="59%"> 
                0
              </td>
            </tr>
            <tr> 
              <td width="41%"><font color="#000000">Tunnel(s) Available : </font></td>
              <td width="59%"> 
                50
              </td>
            </tr>
            <tr> 
              <td width="41%"> 
                No Group VPN was defined.
              </td>
              <td width="59%"> 
                
              </td>
            </tr>
            
          </table>
          <br>
          <hr align="center" size="1" color="#b5b5e6" noshade>
          <br>
        </td>
        <td></td>
      </tr>
      <tr> 
        <td valign="top" bgcolor="#E7E7E7" bordercolor="#E7E7E7" bordercolorlight="#E7E7E7" bordercolordark="#E7E7E7" rowspan="2"> 
          <div align="right"><b>Log Setting Status</b></div>
        </td>
        <td background="images_rv042/UI_04.gif" valign="top" rowspan="2">&nbsp;</td>
        <td valign="top" bgcolor="#FFFFFF" rowspan="2">&nbsp;</td>
        <td valign="top" bgcolor="#FFFFFF" rowspan="2">
		<a href=\'log_setting.htm\'><font color=\'#000000\'>E-mail</font></a> cannot be sent because you have not specified an outbound SMTP server address.
		 
          <br>
          <br>
          <br>
        </td>
        <td height="20"></td>
      </tr>
      <tr> 
        <td valign="bottom" rowspan="2" bgcolor="#6666CC" align="right"><img src="images_rv042/cisco.gif" width="136" height="62"></td>
        <td height="55"></td>
      </tr>
      <tr> 
        <td height="25" colspan="2" valign="top" bgcolor="#000000" bordercolor="#E7E7E7" bordercolorlight="#E7E7E7" bordercolordark="#E7E7E7">&nbsp; 
        </td>
        <td valign="top" bgcolor="#6666CC" bordercolor="#E7E7E7" bordercolorlight="#E7E7E7" bordercolordark="#E7E7E7">&nbsp;</td>
        <td valign="top" bgcolor="#6666CC" bordercolor="#E7E7E7" bordercolorlight="#E7E7E7" bordercolordark="#E7E7E7">&nbsp; 
        </td>
        <td valign="top" bgcolor="#6666CC" bordercolor="#E7E7E7" bordercolorlight="#E7E7E7" bordercolordark="#E7E7E7">&nbsp;</td>
        <td valign="top" bgcolor="#000000"> 
          <div align="center"> 
            <center>
            </center>
          </div>
        </td>
        <td></td>
      </tr>
      <tr> 
        <td height="0"></td>
        <td></td>
        <td></td>
        <td></td>
        <td></td>
        <td></td>
        <td></td>
        <td></td>
      </tr>
    </form>
  </table>



    



            </div>
<map name="MapP1"> 
  <area shape="rect" coords="5,47,51,91" href="javascript: openPort(\'1\')" alt="Port1 Information" title="Port1 Information">
</map>
<map name="MapP2"> 
  <area shape="rect" coords="1,48,46,90" href="javascript: openPort(\'2\')" alt="Port2 Information" title="Port2 Information">
</map>
<map name="MapP3"> 
  <area shape="rect" coords="1,48,47,90" href="javascript: openPort(\'3\')" alt="Port3 Information" title="Port3 Information">
</map>
<map name="MapP4"> 
  <area shape="rect" coords="1,48,49,90" href="javascript: openPort(\'4\')" alt="Port4 Information" title="Port4 Information">
</map>
<map name="MapWAN"> 
<script>
if (document.formsummary.dualwanEnabled.value=="1")
{
  document.write(\'<area shape="rect" coords="2,47,52,90" href="\');
  document.write("javascript: openPort(\'10\')");   
  document.write(\'" alt="WAN1 Port Information" title="WAN1 Port Information">\'); 
}
else
{
  document.write(\'<area shape="rect" coords="2,47,52,90" href="\');
  document.write("javascript: openPort(\'10\')");   
  document.write(\'" alt="WAN Port Information" title="WAN Port Information">\'); 
}
</script>
</map>
<map name="MapDMZ"> 
<script>
if (document.formsummary.dualwanEnabled.value=="1")
{
  document.write(\'<area shape="rect" coords="1,47,51,91" href="\');
  document.write("javascript: openPort(\'9\')");
  document.write(\'" alt="WAN2 Port Information" title="WAN2 Port Information">\');      
}
else
{
  document.write(\'<area shape="rect" coords="1,47,51,91" href="\');
  document.write("javascript: openPort(\'9\')");
  document.write(\'" alt="DMZ Port Information" title="DMZ Port Information">\');    
}
</script>
</map>
</body>







</html>
 


END_HOME

our $gateway_to_gateway = <<'END_GATEWAY';
<html>
<head><meta name="Pragma" content="No-Cache">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Web Management</title>
<base target="_self">
<style fprolloverstyle>A:hover {color: #00FFFF}
.help:link {text-decoration: underline}
.help:visited {text-decoration: underline}
.help:hover {color: #FFCC00; text-decoration: underline}
.logout:link {text-decoration: none}
.logout:visited {text-decoration: none}
.logout:hover {color: #FFCC00; text-decoration: none}
</style>
<style type="text/css">
body {font-family: Arial, Verdana, sans-serif, Helvetica; background-color: #ffffff;}
td, th, input, select {font-size: 11px}
</style>
<link rel="stylesheet" href="nk.css">
<script src="nk20060810141951.js"></script> <!--<script src="nk.js"></script>-->
<script src="lg20060810141951.js"></script> <!--<script src="lg.js"></script>-->
<script language=JavaScript>
function MM_reloadPage(init) {  //reloads the window if Nav4 resized

  if (init==true) with (navigator) {if ((appName=="Netscape")&&(parseInt(appVersion)==4)) {

    document.MM_pgW=innerWidth; document.MM_pgH=innerHeight; onresize=MM_reloadPage; }}

  else if (innerWidth!=document.MM_pgW || innerHeight!=document.MM_pgH) location.reload();

}

MM_reloadPage(true);





function MM_findObj(n, d) { //v4.0

  var p,i,x;  if(!d) d=document; if((p=n.indexOf("?"))>0&&parent.frames.length) {

    d=parent.frames[n.substring(p+1)].document; n=n.substring(0,p);}

  if(!(x=d[n])&&d.all) x=d.all[n]; for (i=0;!x&&i<d.forms.length;i++) x=d.forms[i][n];

  for(i=0;!x&&d.layers&&i<d.layers.length;i++) x=MM_findObj(n,d.layers[i].document);

  if(!x && document.getElementById) x=document.getElementById(n); return x;

}



function MM_showHideLayers() { //v3.0

  var i,p,v,obj,args=MM_showHideLayers.arguments;

  for (i=0; i<(args.length-2); i+=3) if ((obj=MM_findObj(args[i]))!=null) { v=args[i+2];

    if (obj.style) { obj=obj.style; v=(v==\'show\')?\'visible\':(v=\'hide\')?\'hidden\':v; }

    obj.visibility=v; }

}

function showDnsResolve()
{
    if (document.formgtg.radioDnsResolve[1])
    if (document.formgtg.radioDnsResolve[1].selectedIndex == 1)
	{
	    MM_showHideLayers(\'ipRSW234\',\'\',\'hide\');
		document.formgtg.ipRSW1[1].size=40;
	    document.formgtg.ipRSW1[1].maxLength=60;
//        if (n==1) document.formgtg.ipRSW1[0].value=document.formgtg.ipRSW1[1].value; // 2004/07/12 Eric
		document.formgtg.ipRSW1[1].value=document.formgtg.DnsResolve.value;
		
		document.formgtg.ipRSW2[1].size=1;
	    document.formgtg.ipRSW2[1].maxLength=1;
		document.formgtg.ipRSW3[1].size=1;
	    document.formgtg.ipRSW3[1].maxLength=1;
		document.formgtg.ipRSW4[1].size=1;
	    document.formgtg.ipRSW4[1].maxLength=1;
	}
	else
	{
	    document.formgtg.ipRSW1[1].size=3;
	    document.formgtg.ipRSW1[1].maxLength=3;
//        if (n==1) document.formgtg.DnsResolve.value=document.formgtg.ipRSW1[1].value; // 2004/07/12 Eric
		document.formgtg.ipRSW1[1].value=document.formgtg.ipRSW1[0].value;
		
		document.formgtg.ipRSW2[1].size=3;
	    document.formgtg.ipRSW2[1].maxLength=3;
		document.formgtg.ipRSW3[1].size=3;
	    document.formgtg.ipRSW3[1].maxLength=3;
		document.formgtg.ipRSW4[1].size=3;
	    document.formgtg.ipRSW4[1].maxLength=3;
	    MM_showHideLayers(\'ipRSW234\',\'\',\'show\');		
	}

}
function IPDNSCheck(I)
{
    if (I.form.radioDnsResolve[1])
    if (I.form.radioDnsResolve[1].selectedIndex == 1)
	{
	    // no check
    }
	else
	{
	    IPCheck(I);
	}
}
function chDismatch()
{
    if (document.formgtg.typeLSW[1]) document.formgtg.tunnelStatus.checked=true;
	else document.formgtg.tunnelStatus.checked=false;
    if (document.formgtg.typeLSW[1])
	{
        if (document.formgtg.ipLSW1 && document.formgtg.L_textFQDN[1]) document.formgtg.typeLSW[1].selectedIndex=1;
	    else if (document.formgtg.ipLSW1 && document.formgtg.L_userName[1]) document.formgtg.typeLSW[1].selectedIndex=2;
        else if (document.formgtg.ipLSW1) document.formgtg.typeLSW[1].selectedIndex=0;
	    else if (document.formgtg.L_textFQDN[1]) document.formgtg.typeLSW[1].selectedIndex=3;
        else if (document.formgtg.L_userName[1]) document.formgtg.typeLSW[1].selectedIndex=4;
	}
	
	if (document.formgtg.typeLSG[1])
	{
        if (document.formgtg.smLSG1[1]) document.formgtg.typeLSG[1].selectedIndex=1;
	    else if (document.formgtg.rangeLSG[1]) document.formgtg.typeLSG[1].selectedIndex=2;
		else document.formgtg.typeLSG[1].selectedIndex=0;
	}
    if (document.formgtg.typeRSW[1])
	{
        if (document.formgtg.ipRSW2[1] && document.formgtg.textFQDN[1]) document.formgtg.typeRSW[1].selectedIndex=1;
	    else if (document.formgtg.ipRSW2[1] && document.formgtg.userName[1]) document.formgtg.typeRSW[1].selectedIndex=2;
        else if (document.formgtg.ipRSW2[1]) document.formgtg.typeRSW[1].selectedIndex=0;
	    else if (document.formgtg.textFQDN[1]) document.formgtg.typeRSW[1].selectedIndex=3;
        else if (document.formgtg.userName[1]) document.formgtg.typeRSW[1].selectedIndex=4;
		// <-- 2004/09/13 Ryoko Change ipRSW1[1] to ipRSW2[1]		
	}
	
	if (document.formgtg.typeRSG[1])
	{
        if (document.formgtg.smRSG1[1]) document.formgtg.typeRSG[1].selectedIndex=1;
	    else if (document.formgtg.rangeRSG[1]) document.formgtg.typeRSG[1].selectedIndex=2;
		else document.formgtg.typeRSG[1].selectedIndex=0;
	}
	
	if (document.formgtg.typeKeyMode[1])
	{
        if (document.formgtg.inSPI[1]) document.formgtg.typeKeyMode[1].selectedIndex=0;
	    else if (document.formgtg.select[1]) document.formgtg.typeKeyMode[1].selectedIndex=1;
	}
    if (document.formgtg.PFSp[1])
	{	
	    if (document.formgtg.select4[1]) document.formgtg.PFSp[1].checked=true;
	    else document.formgtg.PFSp[1].checked=false;
	}
}
function chLGaT()
{
    if (document.formgtg.tunnelStatus.checked==true)
	{
    	if (document.formgtg.select6.selectedIndex==0)
		{
		    if (document.formgtg.typeLSW[1])
	    	if (document.formgtg.typeLSW[1].selectedIndex<3)
			{
		    	document.formgtg.ipLSW1.value=\'10\';
				document.formgtg.ipLSW2.value=\'100\';
				document.formgtg.ipLSW3.value=\'4\';
				document.formgtg.ipLSW4.value=\'40\';
			}
	
		}
		else if (document.formgtg.select6.selectedIndex==1)
		{
		    if (document.formgtg.typeLSW[1])
	    	if (document.formgtg.typeLSW[1].selectedIndex<3)
			{
		    	document.formgtg.ipLSW1.value=\'0\';
				document.formgtg.ipLSW2.value=\'0\';
				document.formgtg.ipLSW3.value=\'0\';
				document.formgtg.ipLSW4.value=\'0\';
			}	
	
		}
	}
}
function falseSubmit(F,n)
{
  if (F.typeKeyMode[1].selectedIndex==1) {
      if (F.PFSp[1].checked==true)
	  F.PFSp[0].value="checked";
      else
	  F.PFSp[0].value="";
  }
  
  if (F.radioDnsResolve[1]) //F.typeRSW[1].selectedIndex =0, 1 or 2
  if (F.radioDnsResolve[1].selectedIndex == 1)
  {			
      sTrim(F.ipRSW1[1]);
			      		
	  // Exchange to Normal Name
	  F.DnsResolve.value=F.ipRSW1[1].value;
	  //F.ipRSW1[1].value=F.ipRSW1[0].value;
	  F.ipRSW1[2].value=F.ipRSW1[0].value;
	  F.ipRSW1[2].disabled=false;
	  // <-- Eric					
  }
  else
      F.ipRSW1[2].disabled=true; // <-- 2004/09/13 Ryoko
  
  F.submitStatus.value=0;
  F.action="gateway_to_gateway.htm"+"#"+n;
      MM_showHideLayers(\'AutoNumber15\',\'\',\'hide\');  
  F.submit();
}
function falseSubmit1(F,n)
{
  if (F.typeKeyMode[1].selectedIndex==0) {
      if (F.PFSp[1].checked==true)
	  F.PFSp[0].value="checked";
      else
	  F.PFSp[0].value="";
  }
  
  if (F.radioDnsResolve[1]) //F.typeRSW[1].selectedIndex =0, 1 or 2
  if (F.radioDnsResolve[1].selectedIndex == 1)
  {			
      sTrim(F.ipRSW1[1]);
			      		
	  // Exchange to Normal Name
	  F.DnsResolve.value=F.ipRSW1[1].value;
	  //F.ipRSW1[1].value=F.ipRSW1[0].value;
	  F.ipRSW1[2].value=F.ipRSW1[0].value;
	  F.ipRSW1[2].disabled=false;
	  // <-- Eric					
  }
  else
      F.ipRSW1[2].disabled=true; // <-- 2004/09/13 Ryoko  
 
  F.submitStatus.value=0;
  F.action="gateway_to_gateway.htm"+"#"+n;
      MM_showHideLayers(\'AutoNumber15\',\'\',\'hide\');  
  F.submit();
}
function changeStatus(F)
{
  if (F.tunnelStatus.checked==true)
  {
    F.tunnelStatusChange.value=1;
  }
  else 
  {
    if (F.editStatus.value=="0")
    {
        alert(aDisableTunnel);
        return;
    }
    F.tunnelStatusChange.value=2;
  }    
    F.submitStatus.value=0;
 
        MM_showHideLayers(\'AutoNumber15\',\'\',\'hide\');  
  F.submit();
}
function IPCheck(I)
{
  var d;
  d=parseInt(I.value,10);
  if (!(d<256 && d>=0))
  {
    alert(aIPCheck);
    I.value=I.defaultValue;
    return;
  }
  I.value=d;
}
function IP0to254Check(I)
{
  var d;
  d=parseInt(I.value,10);
  if (!(d<255 && d>=0)) 
  {
    alert(aIP0to254Check);
    I.value=I.defaultValue;
    return;    
  }
  I.value=d;
}
function MKCheck(I)
{
  var d;
  d=parseInt(I.value,10);
  if (!(d<256 && d>=0))
  {
    alert(aMaskCheck);
    I.value=I.defaultValue;
    return;
  }
  I.value=d;
}
function lifetimeCheck(I)
{
  var d;
  d=parseInt(I.value,10);
  if (!(d<=86400 && d>=120))
  {
    alert(aSALifeTimeCheck);    
    I.value=I.defaultValue;
    return;
  }
  I.value=d;
}
function lifetime2Check(I)
{
  var d;
  d=parseInt(I.value,10);
  if (!(d<=28800 && d>=120))
  {
    alert(aSALifeTime2Check);    
    I.value=I.defaultValue;
    return;
  }
  I.value=d;
}
function chSubmit(F)
{
// Ryoko 2004/12/13/Phase 2 Encryption and Phase2 Authentication
  if(F.select5[1]&&F.typehase2A[1])
  if(F.select5[1].value==0&&F.typehase2A[1].value==0)
  {
   alert(sP2AuthEncthesame);
	return;  
  }
  if (F.tunnelName.value=="") {
	alert(aTunnelName);
	F.tunnelName.select();
	return;
  }
  if (F.tunnelStatus.checked==true)
  {
    if (F.typeLSW[1])
    if ((F.typeLSW[1].selectedIndex==1)||(F.typeLSW[1].selectedIndex==3))
    {
	  if (F.L_textFQDN[1])
      if (F.L_textFQDN[1].value=="") 
      {
	  alert(aDomainName);
	  F.L_textFQDN[1].select();
	  return;
      }
    }
	
	if (F.typeLSW[1])
    if ((F.typeLSW[1].selectedIndex==2)||(F.typeLSW[1].selectedIndex==4))
    {
	  if (F.L_userName[1])
      if (F.L_userName[1].value=="") 
      {
	  alert(aUserName);
	  F.L_userName[1].select();
	  return;
      }
	  if (F.L_domainName[1])
      if (F.L_domainName[1].value=="") 
      {
	  alert(aDomainName);
	  F.L_domainName[1].select();
	  return;
      }
    }
	
	if (F.typeRSW[1])
// 2004/04/12 Eric --> if (F.typeRSW[1].selectedIndex<3)
    {
/* 2004/04/20 Eric
    	if (F.typeRSW[1].selectedIndex == 0)
		{
            if (chipRSW(F) < 0) return;
    	}
*/
		if (F.radioDnsResolve[1]) //F.typeRSW[1].selectedIndex =0, 1 or 2
		if (F.radioDnsResolve[1].selectedIndex == 0)
		{
		    if (chipRSW(F) < 0) return;		
            F.ipRSW1[2].disabled=true; // 2004/09/13 Ryoko					
		}
		else
		{			
			sTrim(F.ipRSW1[1]);
      		if (F.ipRSW1[1].value=="") 
      		{
	  			alert(aResolvedName);
	  			F.ipRSW1[1].select();
	  			return;
      		}
			// Exchange to Normal Name
			F.DnsResolve.value=F.ipRSW1[1].value;
			//F.ipRSW1[1].value=F.ipRSW1[0].value;
			F.ipRSW1[2].value=F.ipRSW1[0].value;
	        F.ipRSW1[2].disabled=false;
			// <-- Eric		
	        // <-- 2004/09/13 Ryoko			
		}
	}
// <-- Eric
	
	if (F.typeRSW[1])	
    if ((F.typeRSW[1].selectedIndex==1)||(F.typeRSW[1].selectedIndex==3))
    {
	  if (F.textFQDN[1])
      if (F.textFQDN[1].value=="") 
      {
	  alert(aDomainName);
	  F.textFQDN[1].select();
	  return;
      }
    }
	
	if (F.typeRSW[1])
    if ((F.typeRSW[1].selectedIndex==2)||(F.typeRSW[1].selectedIndex==4))
    {
	  if (F.userName[1])
      if (F.userName[1].value=="") 
      {
	  alert(aUserName);
	  F.userName[1].select();
	  return;
      }
	  if (F.domainName[1])
      if (F.domainName[1].value=="") 
      {
	  alert(aDomainName);
	  F.domainName[1].select();
	  return;
      }
    }
	
    /* 2004/07/12 Eric --> move chipRSW() <-- Eric */
	
	if (F.ipRSG1[1] && F.ipRSG2[1] && F.ipRSG3[1] && F.ipRSG4[1])
    if (F.ipRSG1[1].value=="" || F.ipRSG2[1].value=="" || F.ipRSG3[1].value=="" || F.ipRSG4[1].value=="")
    {
	  alert(aIPAddressRSG);
	  if (F.ipRSG1[1].value=="") F.ipRSG1[1].select();
	  else if (F.ipRSG2[1].value=="") F.ipRSG2[1].select();
	  else if (F.ipRSG3[1].value=="") F.ipRSG3[1].select();
	  else if (F.ipRSG4[1].value=="") F.ipRSG4[1].select();
	  return;
    }
	if (F.typeRSG[1])
	if (F.typeRSG[1].selectedIndex==2)
	{
	    if (F.rangeRSG[1])
	    if (F.rangeRSG[1].value=="")
		{
		    alert(aIPRangeRSG);
			F.rangeRSG[1].select();
			return;
		}	
	}
	if (F.typeKeyMode[1])
    if (F.typeKeyMode[1].selectedIndex==0)
    {
	  if (F.inSPI[1])
      if (F.inSPI[1].value=="")
      {
	  alert(aIncomeSPI);
	  F.inSPI[1].select();
	  return;
      }
	  if (F.outSPI[1])
      if (F.outSPI[1].value=="")
      {
	  alert(aOutgoSPI);
	  F.outSPI[1].select();
	  return;
      }
	  if (F.keyEncryption[1])
      if (F.keyEncryption[1].value=="")
      {
	  alert(aEncryptionKey);
	  F.keyEncryption[1].select();
	  return;
      }
	  if (F.keyAuthentication[1])
      if (F.keyAuthentication[1].value=="")
      {
	  alert(aAuthenticationKey);
	  F.keyAuthentication[1].select();
	  return;
      }
    }
	
	if (F.typeKeyMode[1])
    if (F.typeKeyMode[1].selectedIndex==1)
    {
	  if (F.keyPreshared2[1])
      if (F.keyPreshared2[1].value=="")
      {
	  alert(aPresharedKey);
	  F.keyPreshared2[1].select();
	  return;
      }
	  if (F.lifetimeSA1[1])
      if (F.lifetimeSA1[1].value=="")
      {
	  alert(aP1SALifeTime);
	  F.lifetimeSA1[1].select();
	  return;
      }
	  if (F.lifetimeSA2[1])
      if (F.lifetimeSA2[1].value=="")
      {
	  alert(aP2SALifeTime);
	  F.lifetimeSA2[1].select();
	  return;
      }
    }
  }
/* 2003/10/28 Eric --> */
  var ip1,ip2,ip3,ip4;
  var y;
  y=cC2GMode;
  
  ip1="";
  ip2="";
  ip3="";
  ip4="";     
   
  if (F.ipRSW2[1])// <-- 2004/09/13 Ryoko Change ipRSW1[1] to ipRSW2[1]
  {
      if (F.smRSG1[1])
	  {
	      ip1=F.ipRSG1[1].value & F.smRSG1[1].value;
	      ip2=F.ipRSG2[1].value & F.smRSG2[1].value;
		  ip3=F.ipRSG3[1].value & F.smRSG3[1].value;
		  ip4=F.ipRSG4[1].value & F.smRSG4[1].value;
	      if ((ip1==F.ipRSW1[1].value) && (ip2==F.ipRSW2[1].value) && (ip3==F.ipRSW3[1].value) && (ip4==F.ipRSW4[1].value))
          {
       	      if (!confirm(y))
              {
                  window.location.replace("client_to_gateway_t.htm");
				  return;
			  }		  
		  }		  
	  }
	  else
	  {
	      if ((F.ipRSG1[1].value==F.ipRSW1[1].value) && (F.ipRSG2[1].value==F.ipRSW2[1].value) && (F.ipRSG3[1].value==F.ipRSW3[1].value) && (F.ipRSG4[1].value==F.ipRSW4[1].value))
          {
       	      if (!confirm(y))
              {
                  window.location.replace("client_to_gateway_t.htm");
				  return;
			  }		  
		  }
      }
  }  
  // 2004/08/18 Eric --> Check Local Security Group IP Address and Remote Security Group IP Address in the same network.
  if (chSameLsgRsg() < 0) return; 
  // <-- Eric
  
/* ------------------- */   
  F.submitStatus.value=1;
  F.tunnelStatusChange.value=0;
  window.status=wSave;
      MM_showHideLayers(\'AutoNumber15\',\'\',\'hide\');  
  F.submit();
}
// 2004/07/12 Eric -->
function chipRSW(F)
{
	    	if (F.ipRSW1[1] && F.ipRSW2[1] && F.ipRSW3[1] && F.ipRSW4[1])
			if (F.ipRSW1[1].value=="" || F.ipRSW2[1].value=="" || F.ipRSW3[1].value=="" || F.ipRSW4[1].value=="")
        	{
	        	alert(aIPAddressRSW);
	        	if (F.ipRSW1[1].value=="") F.ipRSW1[1].select();
	        	else if (F.ipRSW2[1].value=="") F.ipRSW2[1].select();
	        	else if (F.ipRSW3[1].value=="") F.ipRSW3[1].select();
	        	else if (F.ipRSW4[1].value=="") F.ipRSW4[1].select();
	        	return -1;
        	}
		
			if (F.ipRSW1[1] && F.ipRSW2[1] && F.ipRSW3[1] && F.ipRSW4[1])
        	if (F.ipRSW1[1].value=="0" && F.ipRSW2[1].value=="0" && F.ipRSW3[1].value=="0" && F.ipRSW4[1].value=="0")
        	{
          		alert(aIPRSWCheck);
	  			F.ipRSW1[1].select();
	  			return -1;
        	}
			return 1;
}
// <-- Eric
function checkKeySize(change)
{ 
  if (document.formgtg.keyEncryption[1]) if (change=="E") document.formgtg.keyEncryption[1].value="";
  if (document.formgtg.keyAuthentication[1]) if (change=="A") document.formgtg.keyAuthentication[1].value="";
  if (document.formgtg.tunnelStatus.checked==true)
  {
      if (document.formgtg.typeKeyMode[1])
      if (document.formgtg.typeKeyMode[1].selectedIndex==0)
      {
	    if (document.formgtg.typeEncryption[1])
        if (document.formgtg.typeEncryption[1].selectedIndex==0) 
	    {
	      document.formgtg.keyEncryption[1].size=16;
	      document.formgtg.keyEncryption[1].maxLength=16;
	    }
		if (document.formgtg.typeEncryption[1])
        if (document.formgtg.typeEncryption[1].selectedIndex==1) 
	    {
	      document.formgtg.keyEncryption[1].size=48;
	      document.formgtg.keyEncryption[1].maxLength=48;
	    }
		if (document.formgtg.typeAuthentication[1])
        if (document.formgtg.typeAuthentication[1].selectedIndex==0) 
	    {
	      document.formgtg.keyAuthentication[1].size=32;
	      document.formgtg.keyAuthentication[1].maxLength=32;
	    }
		if (document.formgtg.typeAuthentication[1])	
        if (document.formgtg.typeAuthentication[1].selectedIndex==1) 
	    {
	      document.formgtg.keyAuthentication[1].size=40;
	      document.formgtg.keyAuthentication[1].maxLength=40;
	    }		    
      }
  }	  
}
function KEYCheck(key,type,I)
{
  var inputLength;
  var formLength;
  var charF;
  var stringInput;
  var stringZero="";
  
  inputLength=I.value.length;
  if (key=="E")
  {
    for (var i=0; i<inputLength; i++)
    {
	  charF=parseInt(I.value.charAt(i),16);
      if (isNaN(charF))
      {
        alert(aEncryptionKeyCheck);
        I.value=I.defaultValue;
        return;
      }	  
    }	
    if (type==0) //16
	{
	  formLength=16;
	}
	if (type==1) //48
	{
	  formLength=48;
	}
  }
  
  if (key=="A") 
  {
    for (var i=0; i<inputLength; i++)
    {
	  charF=parseInt(I.value.charAt(i),16);
      if (isNaN(charF))
      {
        alert(aAuthenticationKeyCheck);
        I.value=I.defaultValue;
        return;
      }	  
    } 
    if (type==0) //32
	{
	  formLength=32;
	}
	if (type==1) //40
	{
	  formLength=40;
	}  
  }
  if (inputLength<formLength)
  {
    for (var j=0; j<(formLength-inputLength); j++)
	{
	  stringZero+="0";
	}
    stringInput=I.value;
    I.value=stringInput+stringZero;	
  }	
}
function SPICheck(SPI,I)
{
  var stringInput;
  var charF;
  var j=0;
  for (var i=0; i<I.value.length; i++)
  {
	charF=parseInt(I.value.charAt(i),16);
    if (isNaN(charF))
    {
      if (SPI=="I") alert(aIncomeSPIHexCheck);
      if (SPI=="O") alert(aOutgoSPIHexCheck);	  
      I.value=I.defaultValue;
      return;
    }	  
  } 
  while (I.value.charAt(j)=="0") j++;
  stringInput=I.value.substring(j,I.value.length);
  if (stringInput.length<3)
  {
    if (SPI=="I") alert(aIncomeSPICheck);
    if (SPI=="O") alert(aOutgoSPICheck);
    I.value=I.defaultValue;
  }
  else
  {
   I.value=stringInput;
  }  
}
function opAdvanced(I,F)
{
  if (I.value=="1")
  {
    F.submitStatus.value="11";   //close area
  }
  else
  {
    F.submitStatus.value="10";   //open area
  }
  
  if (F.radioDnsResolve[1]) //F.typeRSW[1].selectedIndex =0, 1 or 2
  if (F.radioDnsResolve[1].selectedIndex == 1)
  {			
      sTrim(F.ipRSW1[1]);
			      		
	  // Exchange to Normal Name
	  F.DnsResolve.value=F.ipRSW1[1].value;
	  //F.ipRSW1[1].value=F.ipRSW1[0].value;
	  F.ipRSW1[2].value=F.ipRSW1[0].value;
	  F.ipRSW1[2].disabled=false;
	  // <-- Eric					
  }
  else
      F.ipRSW1[2].disabled=true; // <-- 2004/09/13 Ryoko
  
      MM_showHideLayers(\'AutoNumber15\',\'\',\'hide\');  
  F.submit();
}
function pageReset()
{
    if (document.formgtg.pageStatus.value=="1")
	{
	    document.formgtg.submitStatus.value="111";
      MM_showHideLayers(\'AutoNumber15\',\'\',\'hide\');  		
		document.formgtg.submit();
	}
	else
	window.location.replace(\'gateway_to_gateway.htm\');
}
var wMap=null;
function openMap()
{
  if (wMap==null)
  wMap=window.open(\'map.htm\',\'sitemap\',\'menubar=no,scrollbars,width=670,height=470\');
}
function closeMap()
{
  if (wMap!=null)
  {
    wMap.close();
	wMap=null;
  }
}
function mapTo(p)
{
  document.location.href=p; 
  closeMap(); 
}
window.onfocus=closeMap;
function chAfterSubmit()
{
   var y;
   y=cGatewayToGatewayOk;
   
   if (document.formgtg.afterSubmit.value=="1")
   {
       if (!confirm(y))
       window.location.replace("vpn_summary.htm");
	   
   }
   else if (document.formgtg.afterSubmit.value=="2")
   {
       window.location.replace("vpn_summary.htm");
   }
   
   /* 2003/08/26 Eric ==> */
   if (document.formgtg.areaMark.value=="1")
   document.location="#1";
   // <== Eric
}
</script>
</head>
<body link="#B5B5E6" vlink="#B5B5E6" alink="#B5B5E6" onUnLoad="closeMap()" onLoad="chAfterSubmit(); chDismatch(); chLGaT(); showDnsResolve(); checkKeySize(\'0\');">
<DIV align=center>
   
  <table border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse" bordercolor="#111111" id="AutoNumber11" width="960" height="68">
    <tr> 
      <td valign="bottom" width="650" hetght="39" bgcolor="#6666CC"> <img border="0" src="images_rv042/clinksys.gif" width="165" height="57" align="middle"> 
      </td>
      <td valign="bottom" bgcolor="#6666CC" width="337"> 
        <div align="right"><font color="#FFFFFF"> <span style="font-size: 7pt">&nbsp;&nbsp;&nbsp;&nbsp;<font face="Arial"> 
          Firmware Version: 1.3.7.10</font></span><font face="Arial"><span style="font-size: 7pt">&nbsp;&nbsp;&nbsp;</span></font></font></div>
      </td>
    </tr>
    <tr> 
      <td colspan="2" valign="top"> <img border="0" src="images_rv042/UI_10.gif" width="960" height="11"></td>
    </tr>
  </table>
   
  
   
  <TABLE height=90 cellSpacing=0 cellPadding=0 width=960 bgColor=black border=0>
    <form name="formdualwan" method="post" action="">
      <input type="hidden" name="dualwanEnabled" value=\'0\'>
      <input type="hidden" name="firewall0" value=\'\'>
    </form>
    <TR> 
      <TD align=middle bgColor=black height=90 style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black" bordercolor="#000000" width="150"> 
        <H3 style="margin-top: 1; margin-bottom: 1" align="center"> <font color="#FFFFFF" face="Arial">VPN</font></H3></TD>
      <TD vAlign=center width=810 bgColor=#000000 height=49 style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black" bordercolor="#000000"> 
        <TABLE cellPadding=0 width="810" border=0 height="90" cellspacing="0" style="border-collapse: collapse; font-style:normal; font-variant:normal; font-weight:normal; font-size:10pt; color:black" bgcolor="#6666CC">
          <TBODY>
            <TR> 
              <TD height="33" valign="middle" bgcolor="#6666CC" width="690" style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black" align="right"> 
                <p><b><font color="#FFFFFF"><span lang="en-us"> 10/100 4-port 
                  VPN Router&nbsp;&nbsp;&nbsp;&nbsp;</span></font></b> </TD>
              <TD width="120" valign="middle" style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black" bgcolor="#000000" bordercolor="#000000" bordercolorlight="#000000" bordercolordark="#000000" align="center"> 
                <p align="center"><font color="#FFFFFF"> <span style="font-size: 8pt"><b>RV042</b></span></font> 
              </TD>
            </TR>
            <TR> 
              <TD colspan="3" bgcolor="#000000" style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"><table width="810" border="0" cellspacing="0" cellpadding="0" >
                  <!--DWLayoutTable-->
                  <tr  align="center"> 
                    <td width="100" height="8" valign="middle" background="images_rv042/UI_06.gif" style=""></td>
                    <td width="80" valign="middle" background="images_rv042/UI_06.gif"style=""></td>
                    <td width="70" valign="middle" background="images_rv042/UI_06.gif"style=""></td>
                    <td width="110" valign="middle" background="images_rv042/UI_06.gif"style=""></td>
                    <td width="80" valign="middle" background="images_rv042/UI_06.gif"style=""></td>
                    <td width="60" valign="middle" background="images_rv042/UI_07.gif"style=""></td>
                    <td width="60" valign="middle" background="images_rv042/UI_06.gif"style=""></td>
                    <td width="80" valign="middle" background="images_rv042/UI_06.gif"style=""></td>
                    <td width="85" valign="middle" background="images_rv042/UI_06.gif"style=""></td>
                    <td width="85" valign="middle" background="images_rv042/UI_06.gif"style=""></td>
                  </tr>
                  <tr  align="center" valign="middle"> 
                    <td height="28" style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"> 
                      <p align="center" style="margin-bottom: 4"> <b><a class="mainmenu" href="home.htm" style="font-size: 8pt; text-decoration: none; font-weight:700"> 
                        System<br>
                        Summary</a></b> </td>
                    <td bgcolor="#000000" style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"> 
                      <p style="margin-top: 0; margin-bottom: 4"><b> <a class="mainmenu" href="network.htm" style="font-size: 8pt; text-decoration: none; font-weight:700">Setup</a></b> 
                    </td>
                    <td bgcolor="#000000" style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"> 
                      <p style="margin-bottom: 4"> <b> <a class="mainmenu" href="dhcp_setup.htm" style="font-size: 8pt; text-decoration: none; font-weight:700">DHCP</a></b> 
                    </td>
                    <td bgcolor="#000000" style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"> 
                      <p style="margin-bottom: 4"> <b> 
                        <script>
          if (document.formdualwan.dualwanEnabled.value=="1") 
		  	  document.write(\'<a class="mainmenu" href="sys_dualwanw.htm" style="font-size: 8pt; text-decoration: none; font-weight:700">\');
          else document.write(\'<a class="mainmenu" href="sys_dualwan3.htm" style="font-size: 8pt; text-decoration: none; font-weight:700">\');
          </script>
                        System<br>
                        Management </a></b> </td>
                    <td bgcolor="#000000" style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"> 
                      <p style="margin-bottom: 4"><b> <a class="mainmenu" href="f_general.htm" style="font-size: 8pt; text-decoration: none; font-weight:700"> 
                        Firewall</a></b> </td>
                    <td bgcolor="#6666CC" style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"> 
                      <p style="margin-bottom: 4"> <b> <font color="#FFFFFF" style="font-size: 8pt">VPN</font></b> 
                    </td>
                    <td bgcolor="#000000" style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"> 
                      <p style="margin-bottom: 4"> <b> <a class="mainmenu" href="log_setting.htm" style="font-size: 8pt; text-decoration: none; font-weight:700">Log</a></b> 
                    </td>
                    <td bgcolor="#000000" style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"> 
                      <p style="margin-bottom: 4"> <b> <a class="mainmenu" href="wizard.htm" style="font-size: 8pt; text-decoration: none; font-weight:700">Wizard</a></b> 
                    </td>
                    <td bgcolor="#000000" style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"> 
                      <p style="margin-bottom: 4"> <b> <a class="mainmenu" href="support.htm" style="font-size: 8pt; text-decoration: none; font-weight:700">Support</a></b> 
                    </td>
                    <td bgcolor="#000000" style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"> 
                      <p style="margin-bottom: 4"> <b> <a class="mainmenu" href="javascript: window.close()" style="font-size: 8pt; text-decoration: none; font-weight:700">Logout</a></b> 
                    </td>
                  </tr>
                </table></TD>
            </TR>
            <TR bgcolor="#6666CC"> 
              <TD colspan="3" style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"> 
                
              <table width="810" border="0" cellspacing="0" cellpadding="0">
                <tr align="center" valign="middle"> 
                  <td width="90" height="21"> 
                    <p align="center"> <span style="font-size: 8pt; background-color:#6666CC"> 
                      <font color="#FFFFFF"> 
                      <!--vpn_summary-->
                      <a class="submenu" href="vpn_summary.htm" style="text-decoration: none"> 
                      <!--vpn_summary-->
                      Summary 
                      <!--vpn_summary-->
                      </a> 
                      <!--vpn_summary-->
                      </font> </span> 
                  </td>
                  <td width="3" height="21"> 
                    <table border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse; border-left-style: solid; border-left-width: 2" bordercolor="#FFFFFF" id="AutoNumber14" height="10" width="3">
                      <tr> 
                        <td width="1" height="12" align="center" valign="middle"></td>
                      </tr>
                    </table>
                  </td>
                  <td width="140" height="21"> 
                    <p align="center"> <span style="font-size: 8pt; background-color:#6666CC"> 
                      <font color="#FFFFFF"> 
                      <!--gateway_to_gateway
                      <a class="submenu" href="gateway_to_gateway.htm" style="text-decoration: none"> 
                      gateway_to_gateway-->
                      Gateway to Gateway 
                      <!--gateway_to_gateway
                      </a> 
                      gateway_to_gateway-->
                      </font> </span> 
                  </td>
                  <td width="3" height="21"> 
                    <table border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse; border-left-style: solid; border-left-width: 2" bordercolor="#FFFFFF" id="AutoNumber14" height="10" width="3">
                      <tr> 
                        <td width="1" height="12" align="center" valign="middle"></td>
                      </tr>
                    </table>
                  </td>
                  <td width="120" height="21"> 
                    <p align="center"> <span style="font-size: 8pt; background-color:#6666CC"> 
                      <font color="#FFFFFF"> 
                      <!--client_to_gateway-->
                      <a class="submenu" href="client_to_gateway_t.htm" style="text-decoration: none"> 
                      <!--client_to_gateway-->
                      Client to Gateway 
                      <!--client_to_gateway-->
                      </a> 
                      <!--client_to_gateway-->
                      </font> </span> 
                  </td>
                  <td width="3" height="21"> 
                    <table border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse; border-left-style: solid; border-left-width: 2" bordercolor="#FFFFFF" id="AutoNumber14" height="10" width="3">
                      <tr> 
                        <td width="1" height="12" align="center" valign="middle"></td>
                      </tr>
                    </table>
                  </td>
                  <td width="128" height="21">
				      <p align="center"> <span style="font-size: 8pt; background-color:#6666CC"> 
                      <font color="#FFFFFF"> 
                      <!--vpn_clients-->
                      <a class="submenu" href="vpn_clients.htm" style="text-decoration: none"> 
                      <!--vpn_clients-->
                      VPN Client Access 
                      <!--vpn_clients-->
                      </a> 
                      <!--vpn_clients-->
                      </font> </span>
				  </td>
                  <td width="5" height="21">
				    <table border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse; border-left-style: solid; border-left-width: 2" bordercolor="#FFFFFF" id="AutoNumber14" height="10" width="3">
                      <tr> 
                        <td width="1" height="12" align="center" valign="middle"></td>
                      </tr>
                    </table>
				  </td>
                  <td width="125" height="21"> 
                    <p align="center"> <span style="font-size: 8pt; background-color:#6666CC"> 
                      <font color="#FFFFFF"> 
                      <!--adv_through-->
                      <a class="submenu" href="adv_through.htm" style="text-decoration: none"> 
                      <!--adv_through-->
                      VPN Pass Through 
                      <!--adv_through-->
                      </a> 
                      <!--adv_through-->
                      </font> </span> 
                  </td>
                  <td width="5" height="21"> 
				  
                    <table border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse; border-left-style: solid; border-left-width: 2" bordercolor="#FFFFFF" id="AutoNumber14" height="10" width="3">
                      <tr> 
                        <td width="1" height="12" align="center" valign="middle"></td>
                      </tr>
                    </table>
				  
                  </td>
                  <td width="100" height="21">
				   
                    <p align="center"> <span style="font-size: 8pt; background-color:#6666CC"> 
                      <font color="#FFFFFF"> 
                      <!--pptp-->
                      <a class="submenu" href="pptp.htm" style="text-decoration: none"> 
                      <!--pptp-->
                      PPTP Server 
                      <!--pptp-->
                      </a> 
                      <!--pptp-->
                      </font> </span>
				   
                  </td>
                  <td width="88" height="21">&nbsp;</td>
                </tr>
              </table>
            </TD>
            </TR>
          </TBODY>
        </TABLE></TD>
    </TR>
  </TABLE>
  <TABLE height=5 cellSpacing=0 cellPadding=0 width=960 bgColor=black border=0>  
  <TR bgColor=black>
    <TD width=150 height=1 style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; font-family: Arial, Helvetica, sans-serif; color: black" bgcolor="#E7E7E7" bordercolor="#E7E7E7">
			<img border="0" src="images_rv042/UI_03.gif" width="150" height="15"></TD>
    <TD width=810 height=1 style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; font-family: Arial, Helvetica, sans-serif; color: black" bgcolor="#FFFFFF">
			<img border="0" src="images_rv042/UI_02.gif" width="810" height="15"></TD></TR>
  </TABLE>
			
  <table border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse" bordercolor="#111111" id="AutoNumber9" width="961">
    <form name="formgtg" action="gateway_to_gateway.htm" method=post>
      <input type=hidden name="editStatus" value=\'0\'>
      <tr> 
        <td height="25" valign="middle" bgcolor="#000000" bordercolor="#E7E7E7" bordercolorlight="#E7E7E7" bordercolordark="#E7E7E7" width="142" align="right"><font color="#FFFFFF"><b> 
          <script>
if (document.formgtg.editStatus.value=="1")
document.write("Edit the Tunnel");
else document.write("Add a new Tunnel");
</script>
          </b></font></td>
        <td width="8" valign="top" bgcolor="#000000">&nbsp;</td>
        <td width="20" valign="top" bgcolor="#FFFFFF">&nbsp;</td>
        <td width="620" valign="top" bgcolor="#FFFFFF"><font size="+0">&nbsp;</font><font size="+0">&nbsp;</font> 
          <div align="left"> </div>
        </td>
        <td width="20" valign="top" bgcolor="#FFFFFF" rowspan="7">&nbsp;</td>
        <td background="images_rv042/UI_05.gif" width="14" valign="top" rowspan="7">&nbsp;</td>
        <td width="136" rowspan="6" valign="top" bgcolor="#6666CC" align="right"> 
          <a href="javascript: openMap()"><img src="images_rv042/sitemap-off.jpg" width="136" height="28" border="0" onMouseOver="this.src=\'images_rv042/sitemap-on.jpg\'" onMouseOut="this.src=\'images_rv042/sitemap-off.jpg\'"></a> 
          <br>
          <br>
          <div align="left"><font face="Arial" style="font-size: 8pt" color="#FFFFFF"> 
            By setting this page, users can add the new tunnel between two VPN 
            devices.<br>
            <br>
            Tunnel No.: The tunnel number will be generated automatically from 
            1~50. <br>
            <br>
            Tunnel Name: Enter the Tunnel Name, such as LA Office, Branch Site, 
            Corporate Site, etc.  <br>
            <br>
            <a href="javascript: h_gateway_to_gateway();"><b><font face="Arial" style="font-size: 8pt" color="#FFFFFF">More...</font></b></a>	
            </font></div>
        </td>
        <td width="1"></td>
      </tr>
      <tr> 
        <td valign="top" bgcolor="#E7E7E7" bordercolor="#E7E7E7" bordercolorlight="#E7E7E7" bordercolordark="#E7E7E7" width="142" height="140">&nbsp;</td>
        <td background="images_rv042/UI_04.gif" width="8" valign="top">&nbsp;</td>
        <td width="20" valign="top" bgcolor="#FFFFFF">&nbsp;</td>
        <td width="620" valign="top" bgcolor="#FFFFFF"> 
          <input type=hidden name="page" value="gateway_to_gateway.htm">
          <input type="hidden" name="afterSubmit" value=\'0\'>
          <input type="hidden" name="pageStatus" value=\'0\'>
		  <input type=hidden name="areaMark" value=\'0\'>
          <input type=hidden name="submitStatus" value="1">
          <input type=hidden name="tunnelStatusChange" value="0">
<input type=hidden name="typeLSW" value=\'\'>
<input type=hidden name="L_textFQDN" value=\'\'>
<input type=hidden name="L_userName" value=\'\'>
<input type=hidden name="L_domainName" value=\'\'>
<input type=hidden name="typeLSG" value=\'\'> 
<input type=hidden name="ipLSG1" value=\'192\'> 
<input type=hidden name="ipLSG2" value=\'168\'> 
<input type=hidden name="ipLSG3" value=\'1\'> 
<input type=hidden name="ipLSG4" value=\'0\'> 
<input type=hidden name="smLSG1" value=\'255\'>
<input type=hidden name="smLSG2" value=\'255\'>
<input type=hidden name="smLSG3" value=\'255\'>
<input type=hidden name="smLSG4" value=\'0\'>
<input type=hidden name="rangeLSG" value=\'254\'>
<input type=hidden name="typeRSW" value=\'\'>
<input type=hidden name="ipRSW1" value=\'\'>
<input type=hidden name="ipRSW2" value=\'\'>
<input type=hidden name="ipRSW3" value=\'\'>
<input type=hidden name="ipRSW4" value=\'\'>
<input type=hidden name="textFQDN" value=\'\'>
<input type=hidden name="userName" value=\'\'>
<input type=hidden name="domainName" value=\'\'>
<input type=hidden name="typeRSG" value=\'\'>
<input type=hidden name="ipRSG1" value=\'\'>
<input type=hidden name="ipRSG2" value=\'\'>
<input type=hidden name="ipRSG3" value=\'\'>
<input type=hidden name="ipRSG4" value=\'\'>
<input type=hidden name="rangeRSG" value=\'254\'>
<input type=hidden name="smRSG1" value=\'255\'>
<input type=hidden name="smRSG2" value=\'255\'>
<input type=hidden name="smRSG3" value=\'255\'>
<input type=hidden name="smRSG4" value=\'0\'>
<input type=hidden name="typeKeyMode" value=\'\'>
<input type=hidden name="select" value=\'\'>
<input type=hidden name="select2" value=\'\'>
<input type=hidden name="select3" value=\'\'>
<input type=hidden name="select4" value=\'\'>
<input type=hidden name="select5" value=\'\'>
<input type=hidden name="typehase2A" value=\'\'>
<input type=hidden name="PFSp" value=\'checked\'>
<input type=hidden name="lifetimeSA1" value=\'28800\'>
<input type=hidden name="lifetimeSA2" value=\'3600\'> 
<input type=hidden name="keyPreshared2" value=""> 
<input type=hidden name="inSPI"  value=\'\'>
<input type=hidden name="outSPI" value=\'\'>
<input type=hidden name="typeEncryption" value=\'\'>
<input type=hidden name="typeAuthentication" value=\'\'>
<input type=hidden name="keyEncryption" value=\'\'>
<input type=hidden name="keyAuthentication" value=\'\'>
<input type=hidden name="ahAlg" value=\'\'>
<input type=hidden name="radioDnsResolve" value=\'0\'>
<input type=hidden name="DnsResolve" value=\'\'>
<!--          <input type="button" value="Wizard" onClick="openWizard(\'3\')" name="button">-->
           
          <br>
           
          <table width="98%" align="center">
            <tr> 
              <td width="13%">&nbsp;</td>
              <td width="22%"> 
                <div align="right">Tunnel No. </div>
              </td>
              <td width="65%"> 
                <input type="text" name="tunnelNo" size="4" maxlength="4" style="background-color: #cccccc" readOnly value=\'3\'>
              </td>
            </tr>
            <tr> 
              <td width="13%">&nbsp;</td>
              <td width="22%"> 
                <div align="right">Tunnel Name</div>
              </td>
              <td width="65%"> 
                <input type="text" name="tunnelName" size="20" maxlength="40" value=\'\'  onFocus="this.select();" onBlur="sTrim(this);">
              </td>
            </tr>
            <!--nk_get dual-wan status, show this or not-->
            <tr> 
              <td width="13%">&nbsp;</td>
              <td width="22%"> 
                <div align="right">Interface</div>
              </td>
              <td width="65%"> 
                <select name="select6" onChange="chLGaT()"><option 
                   value="1">WAN1</option> <option  
                   value="2">WAN2</option> 
                </select>
              </td>
            </tr>
            <!---->
            <tr> 
              <td width="13%">&nbsp;</td>
              <td width="22%"> 
                <div align="right">Enable </div>
              </td>
              <td width="65%"> 
                <input type="checkbox" name="tunnelStatus" onClick="changeStatus(this.form)" value=1 checked disabled>
                
              </td>
            </tr>
          </table>						  
          <br>
           
<a name="11"></a>		  
          <hr align="center" size="1" color="#b5b5e6" noshade>
          <br>
           
        </td>
        <td></td>
      </tr>
      <tr> 
        <td valign="top" bgcolor="#E7E7E7" bordercolor="#E7E7E7" bordercolorlight="#E7E7E7" bordercolordark="#E7E7E7" width="142" align="right" height="60"><b><font face="Arial, Helvetica, sans-serif"> 
           
          Local Group Setup 
           
          </font></b></td>
        <td background="images_rv042/UI_04.gif" width="8" valign="top">&nbsp;</td>
        <td width="20" valign="top" bgcolor="#FFFFFF">&nbsp;</td>
        <td width="620" valign="top" bgcolor="#FFFFFF">
           
          <table width="98%" align="center">
            <tr>
              <td width="11">&nbsp;</td>
              <td width="193"> 
                <div align="right">Local Security Gateway Type</div>
              </td>
              <td width="388"> 
		  
                <select name="typeLSW" onChange="falseSubmit(this.form,\'11\')">
		  <option value="1"  
                  selected>IP Only</option>
                  <option value="2"  
                  >IP + Domain Name(FQDN) Authentication</option>
                  <option value="3"  
		  >IP + E-mail Addr.(USER FQDN) Authentication</option>
                  <option value="4"
		  >Dynamic IP + Domain Name(FQDN) Authentication</option>
                  <option value="5"  
		  >Dynamic IP + E-mail Addr.(USER FQDN) Authentication</option>
                </select>
              </td>
            </tr>
          </table>
           
           
          <table width="98%" align="center">
            <tr> 
              <td width="26">&nbsp;</td>
              <td width="178"> 
                <div align="right">IP address</div>
              </td>
              <td width="388"> 
                <input type="text" name="ipLSW1" size="3" maxlength="3" style="background-color: #cccccc" readOnly value=\'\'>
                . 
                <input type="text" name="ipLSW2" size="3" maxlength="3" style="background-color: #cccccc" readOnly value=\'\'>
                . 
                <input type="text" name="ipLSW3" size="3" maxlength="3" style="background-color: #cccccc" readOnly value=\'\'>
                . 
                <input type="text" name="ipLSW4" size="3" maxlength="3" style="background-color: #cccccc" readOnly value=\'\'>
              </td>
            </tr>
          </table>
           
          <!--
          <table width="98%" align="center">
            <tr> 
              <td width="19">&nbsp;</td>
              <td width="185"> 
                <div align="right">Domain Name</div>
              </td>
              <td width="388"> 
                <input type="text" name="L_textFQDN" size="40" maxlength="40" value=\'\'  onFocus="this.select();" onBlur="sTrim(this);">
              </td>
            </tr>
          </table>
          <table width="98%" align="center">
            <tr> 
              <td width="28">&nbsp;</td>
              <td width="176"> 
                <div align="right">IP address</div>
              </td>
              <td width="388"> 
                <input type="text" name="ipLSW1" size="3" maxlength="3" style="background-color: #cccccc" readOnly value=\'\'>
                . 
                <input type="text" name="ipLSW2" size="3" maxlength="3" style="background-color: #cccccc" readOnly value=\'\'>
                . 
                <input type="text" name="ipLSW3" size="3" maxlength="3" style="background-color: #cccccc" readOnly value=\'\'>
                . 
                <input type="text" name="ipLSW4" size="3" maxlength="3" style="background-color: #cccccc" readOnly value=\'\'>
              </td>
            </tr>
          </table>
          -->
          <!--
          <table width="98%" align="center">
            <tr> 
              <td width="28">&nbsp;</td>
              <td width="176"> 
                <div align="right">E-mail address</div>
              </td>
              <td width="388">
                <input type="text" name="L_userName" size="10" maxlength="20" value=\'\'  onFocus="this.select();" onBlur="sTrim(this);">
                @
                <input type="text" name="L_domainName" size="40" maxlength="40" value=\'\'  onFocus="this.select();" onBlur="sTrim(this);">
              </td>
            </tr>
          </table>
          <table width="98%" align="center">
            <tr> 
              <td width="28">&nbsp;</td>
              <td width="176"> 
                <div align="right">IP address</div>
              </td>
              <td width="388"> 
                <input type="text" name="ipLSW1" size="3" maxlength="3" style="background-color: #cccccc" readOnly value=\'\'>
                . 
                <input type="text" name="ipLSW2" size="3" maxlength="3" style="background-color: #cccccc" readOnly value=\'\'>
                . 
                <input type="text" name="ipLSW3" size="3" maxlength="3" style="background-color: #cccccc" readOnly value=\'\'>
                . 
                <input type="text" name="ipLSW4" size="3" maxlength="3" style="background-color: #cccccc" readOnly value=\'\'>
              </td>
            </tr>
          </table>
          -->
          <!--
          <table width="98%" align="center">
            <tr> 
              <td width="19">&nbsp;</td>
              <td width="185"> 
                <div align="right">Domain Name</div>
              </td>
              <td width="388"> 
                <input type="text" name="L_textFQDN" size="40" maxlength="40" value=\'\'  onFocus="this.select();" onBlur="sTrim(this);">
              </td>
            </tr>
          </table>
          -->
          <!--
          <table width="98%" align="center">
            <tr> 
              <td width="28">&nbsp;</td>
              <td width="176"> 
                <div align="right">E-mail address</div>
              </td>
              <td width="388">
                <input type="text" name="L_userName" size="10" maxlength="20" value=\'\'  onFocus="this.select();" onBlur="sTrim(this);">
                @
                <input type="text" name="L_domainName" size="40" maxlength="40" value=\'\'  onFocus="this.select();" onBlur="sTrim(this);">
              </td>
            </tr>
          </table>
          -->
           
          <table width="98%" align="center">
            <tr> 
              <td width="35">&nbsp;</td>
              <td width="168"> 
                <div align="right">Local Security Group Type</div>
              </td>
              <td width="389">
			   
                <select name="typeLSG"          onChange="falseSubmit(this.form,\'11\')"><option value=1  
                  >IP</option>
                  <option value=2  
                  selected>Subnet</option>
                  <option value=3  
                  >IP Range</option> 
                </select>
              </td>
            </tr>
          </table>
           
          <!--
          <table width="98%" align="center">
            <tr> 
              <td width="35">&nbsp;</td>
              <td width="168"> 
                <div align="right">IP address</div>
              </td>
              <td width="389"> 
                <input type="text" name="ipLSG1" size="3" maxlength="3" onFocus="this.select();" onBlur=" IPCheck(this);" value=\'192\'>
                . 
                <input type="text" name="ipLSG2" size="3" maxlength="3" onFocus="this.select();" onBlur=" IPCheck(this);" value=\'168\'>
                . 
                <input type="text" name="ipLSG3" size="3" maxlength="3" onFocus="this.select();" onBlur=" IPCheck(this);" value=\'1\'>
                . 
                <input type="text" name="ipLSG4" size="3" maxlength="3" onFocus="this.select();" onBlur=" IP0to254Check(this);" value=\'0\'>
              </td>
            </tr>
          </table>
          -->
           
          <table width="98%" align="center">
            <tr> 
              <td width="36">&nbsp;</td>
              <td width="168"> 
                <div align="right">IP address</div>
              </td>
              <td width="388"> 
                <input type="text" name="ipLSG1" size="3" maxlength="3" onFocus="this.select();" onBlur=" IPCheck(this);" value=\'192\'>
                . 
                <input type="text" name="ipLSG2" size="3" maxlength="3" onFocus="this.select();" onBlur=" IPCheck(this);" value=\'168\'>
                . 
                <input type="text" name="ipLSG3" size="3" maxlength="3" onFocus="this.select();" onBlur=" IPCheck(this);" value=\'1\'>
                . 
                <input type="text" name="ipLSG4" size="3" maxlength="3" onFocus="this.select();" onBlur=" IP0to254Check(this);" value=\'0\'>
              </td>
            </tr>
            <tr> 
              <td width="36">&nbsp;</td>
              <td width="168"> 
                <div align="right">Subnet Mask</div>
              </td>
              <td width="388"> 
                <input type="text" name="smLSG1" size="3" maxlength="3" onFocus="this.select();" onBlur=" MKCheck(this);" value=\'255\'>
                . 
                <input type="text" name="smLSG2" size="3" maxlength="3" onFocus="this.select();" onBlur=" MKCheck(this);" value=\'255\'>
                . 
                <input type="text" name="smLSG3" size="3" maxlength="3" onFocus="this.select();" onBlur=" MKCheck(this);" value=\'255\'>
                . 
                <input type="text" name="smLSG4" size="3" maxlength="3" onFocus="this.select();" onBlur=" MKCheck(this);" value=\'0\'>
              </td>
            </tr>
          </table>
           
          <!--
          <table width="98%" align="center">
            <tr> 
              <td width="36">&nbsp;</td>
              <td width="169"> 
                <div align="right">IP range</div>
              </td>
              <td width="387"> 
                <input type="text" name="ipLSG1" size="3" maxlength="3" onFocus="this.select();" onBlur=" IPCheck(this);" value=\'192\'>
                . 
                <input type="text" name="ipLSG2" size="3" maxlength="3" onFocus="this.select();" onBlur=" IPCheck(this);" value=\'168\'>
                . 
                <input type="text" name="ipLSG3" size="3" maxlength="3" onFocus="this.select();" onBlur=" IPCheck(this);" value=\'1\'>
                . 
                <input type="text" name="ipLSG4" size="3" maxlength="3" onFocus="this.select();" onBlur=" IP0to254Check(this);" value=\'0\'>
                to 
                <input type="text" name="rangeLSG" size="3" maxlength="3" onFocus="this.select();" onBlur=" IP0to254Check(this);" value=\'254\'>
              </td>
            </tr>
          </table>
          -->
           
<a name="12"></a>		  
          <br>
          <hr align="center" size="1" color="#b5b5e6" noshade>
          <br>
           
        </td>
        <td></td>
      </tr>
      <tr> 
        <td valign="top" bgcolor="#E7E7E7" bordercolor="#E7E7E7" bordercolorlight="#E7E7E7" bordercolordark="#E7E7E7" width="142" align="right"><b><font face="Arial, Helvetica, sans-serif"> 
           
          Remote Group Setup 
           
          </font></b></td>
        <td background="images_rv042/UI_04.gif" width="8" valign="top">&nbsp;</td>
        <td width="20" valign="top" bgcolor="#FFFFFF">&nbsp;</td>
        <td width="620" valign="top" bgcolor="#FFFFFF"> 
           
          <table width="98%" align="center">
            <tr> 
              <td width="11">&nbsp;</td>
              <td width="193"> 
                <div align="right">Remote Security Gateway Type</div>
              </td>
              <td width="388">
   
                <select name="typeRSW" onChange="falseSubmit(this.form,\'12\')">
		  <option value="1"  
                  selected>IP Only</option>
                  <option value="2"  
                  >IP + Domain Name(FQDN) Authentication</option>
                  <option value="3"  
		  >IP + E-mail Addr.(USER FQDN) Authentication</option>
                  <option value="4"
		  >Dynamic IP + Domain Name(FQDN) Authentication</option>
                  <option value="5"  
		  >Dynamic IP + E-mail Addr.(USER FQDN) Authentication</option>
                </select>
              </td>
            </tr>
          </table>
           
           
          <table width="98%" align="center">
            <tr> 
              <td width="28">&nbsp;</td>
              <td align="right">
                <select name="radioDnsResolve" onChange="showDnsResolve()">
				<option value="0" selected>IP address</option>
				<option value="1" >IP by DNS Resolved</option>
                </select>
              </td>
              <td width="388"> 
                <input type="text" name="ipRSW1" size="3" maxlength="3" onFocus="this.select();" onBlur=" IPDNSCheck(this);" value=\'\'><span id="ipRSW234">
                . 
                <input type="text" name="ipRSW2" size="3" maxlength="3" onFocus="this.select();" onBlur=" IPCheck(this);" value=\'\'>
                . 
                <input type="text" name="ipRSW3" size="3" maxlength="3" onFocus="this.select();" onBlur=" IPCheck(this);" value=\'\'>
                . 
                <input type="text" name="ipRSW4" size="3" maxlength="3" onFocus="this.select();" onBlur=" IP0to254Check(this);" value=\'\'></span>
              </td>
            </tr>
          </table>
           
          <!--
          <table width="98%" align="center">
            <tr> 
              <td width="28">&nbsp;</td>
              <td align="right">
                <select name="radioDnsResolve" onChange="showDnsResolve()">
				<option value="0" selected>IP address</option>
				<option value="1" >IP by DNS Resolved</option>
                </select>
              </td>
              <td width="388"> 
                <input type="text" name="ipRSW1" size="3" maxlength="3" onFocus="this.select();" onBlur=" IPDNSCheck(this);" value=\'\'><span id="ipRSW234">
                . 
                <input type="text" name="ipRSW2" size="3" maxlength="3" onFocus="this.select();" onBlur=" IPCheck(this);" value=\'\'>
                . 
                <input type="text" name="ipRSW3" size="3" maxlength="3" onFocus="this.select();" onBlur=" IPCheck(this);" value=\'\'>
                . 
                <input type="text" name="ipRSW4" size="3" maxlength="3" onFocus="this.select();" onBlur=" IP0to254Check(this);" value=\'\'></span>
              </td>
            </tr>
          </table>
		  <table width="98%" align="center">
            <tr> 
              <td width="19">&nbsp;</td>
              <td width="185"> 
                <div align="right">Domain Name</div>
              </td>
              <td width="388"> 
                <input type="text" name="textFQDN" size="40" maxlength="40" value=\'\'  onFocus="this.select();" onBlur="sTrim(this);">
              </td>
            </tr>
          </table>
          -->
          <!--
          <table width="98%" align="center">
            <tr> 
              <td width="28">&nbsp;</td>
              <td align="right">
                <select name="radioDnsResolve" onChange="showDnsResolve()">
				<option value="0" selected>IP address</option>
				<option value="1" >IP by DNS Resolved</option>
                </select>
              </td>
              <td width="388"> 
                <input type="text" name="ipRSW1" size="3" maxlength="3" onFocus="this.select();" onBlur=" IPDNSCheck(this);" value=\'\'><span id="ipRSW234">
                . 
                <input type="text" name="ipRSW2" size="3" maxlength="3" onFocus="this.select();" onBlur=" IPCheck(this);" value=\'\'>
                . 
                <input type="text" name="ipRSW3" size="3" maxlength="3" onFocus="this.select();" onBlur=" IPCheck(this);" value=\'\'>
                . 
                <input type="text" name="ipRSW4" size="3" maxlength="3" onFocus="this.select();" onBlur=" IP0to254Check(this);" value=\'\'></span>
              </td>
            </tr>
          </table>
		  <table width="98%" align="center">
            <tr> 
              <td width="28">&nbsp;</td>
              <td width="176"> 
                <div align="right">E-mail address</div>
              </td>
              <td width="388">
                <input type="text" name="userName" size="10" maxlength="20" value=\'\'  onFocus="this.select();" onBlur="sTrim(this);">
                @
                <input type="text" name="domainName" size="40" maxlength="40" value=\'\'  onFocus="this.select();" onBlur="sTrim(this);">
              </td>
            </tr>
          </table>
          -->
          <!--
          <table width="98%" align="center">
            <tr> 
              <td width="19">&nbsp;</td>
              <td width="185"> 
                <div align="right">Domain Name</div>
              </td>
              <td width="388"> 
                <input type="text" name="textFQDN" size="40" maxlength="40" value=\'\'  onFocus="this.select();" onBlur="sTrim(this);">
              </td>
            </tr>
          </table>
          -->
          <!--
          <table width="98%" align="center">
            <tr> 
              <td width="28">&nbsp;</td>
              <td width="176"> 
                <div align="right">E-mail address</div>
              </td>
              <td width="388">
                <input type="text" name="userName" size="10" maxlength="20" value=\'\'  onFocus="this.select();" onBlur="sTrim(this);">
                @
                <input type="text" name="domainName" size="40" maxlength="40" value=\'\'  onFocus="this.select();" onBlur="sTrim(this);">
              </td>
            </tr>
          </table>
          -->
           
          <table width="98%" align="center">
            <tr> 
              <td width="23">&nbsp;</td>
              <td width="181"> 
                <div align="right">Remote Security Group Type</div>
              </td>
              <td width="388">
   
                <select name="typeRSG"          onChange="falseSubmit(this.form,\'12\')"><option value="1"  
                  >IP</option>
                  <option value="2"  
                  selected>Subnet</option>
                  <option value="3"  
                  >IP Range</option> 
                </select>
              </td>
            </tr>
          </table>
           
          <!--
          <table width="98%" align="center">
            <tr> 
              <td width="28">&nbsp;</td>
              <td width="176"> 
                <div align="right">IP address</div>
              </td>
              <td width="388"> 
                <input type="text" name="ipRSG1" size="3" maxlength="3" onFocus="this.select();" onBlur=" IPCheck(this);" value=\'\'>
                . 
                <input type="text" name="ipRSG2" size="3" maxlength="3" onFocus="this.select();" onBlur=" IPCheck(this);" value=\'\'>
                . 
                <input type="text" name="ipRSG3" size="3" maxlength="3" onFocus="this.select();" onBlur=" IPCheck(this);" value=\'\'>
                . 
                <input type="text" name="ipRSG4" size="3" maxlength="3" onFocus="this.select();" onBlur=" IP0to254Check(this);" value=\'\'>
              </td>
            </tr>
          </table>
          -->
           
          <table width="98%" align="center">
            <tr> 
              <td width="27">&nbsp;</td>
              <td width="177"> 
                <div align="right">IP address</div>
              </td>
              <td width="388"> 
                <input type="text" name="ipRSG1" size="3" maxlength="3" onFocus="this.select();" onBlur=" IPCheck(this);" value=\'\'>
                . 
                <input type="text" name="ipRSG2" size="3" maxlength="3" onFocus="this.select();" onBlur=" IPCheck(this);" value=\'\'>
                . 
                <input type="text" name="ipRSG3" size="3" maxlength="3" onFocus="this.select();" onBlur=" IPCheck(this);" value=\'\'>
                . 
                <input type="text" name="ipRSG4" size="3" maxlength="3" onFocus="this.select();" onBlur=" IP0to254Check(this);" value=\'\'>
              </td>
            </tr>
            <tr> 
              <td width="27">&nbsp;</td>
              <td width="177"> 
                <div align="right">Subnet Mask</div>
              </td>
              <td width="388"> 
                <input type="text" name="smRSG1" size="3" maxlength="3" onFocus="this.select();" onBlur=" MKCheck(this);" value=\'255\'>
                . 
                <input type="text" name="smRSG2" size="3" maxlength="3" onFocus="this.select();" onBlur=" MKCheck(this);" value=\'255\'>
                . 
                <input type="text" name="smRSG3" size="3" maxlength="3" onFocus="this.select();" onBlur=" MKCheck(this);" value=\'255\'>
                . 
                <input type="text" name="smRSG4" size="3" maxlength="3" onFocus="this.select();" onBlur=" MKCheck(this);" value=\'0\'>
              </td>
            </tr>
          </table>
           
          <!--
          <table width="98%" align="center">
            <tr> 
              <td width="26">&nbsp;</td>
              <td width="178"> 
                <div align="right">IP range</div>
              </td>
              <td width="388"> 
                <input type="text" name="ipRSG1" size="3" maxlength="3" onFocus="this.select();" onBlur=" IPCheck(this);" value=\'\'>
                . 
                <input type="text" name="ipRSG2" size="3" maxlength="3" onFocus="this.select();" onBlur=" IPCheck(this);" value=\'\'>
                . 
                <input type="text" name="ipRSG3" size="3" maxlength="3" onFocus="this.select();" onBlur=" IPCheck(this);" value=\'\'>
                . 
                <input type="text" name="ipRSG4" size="3" maxlength="3" onFocus="this.select();" onBlur=" IP0to254Check(this);" value=\'\'>
                to 
                <input type="text" name="rangeRSG" size="3" maxlength="3" onFocus="this.select();" onBlur=" IP0to254Check(this);" value=\'254\'>
              </td>
            </tr>
          </table>
          -->
           
<a name="13"></a>		  
          <br>
          <hr align="center" size="1" color="#b5b5e6" noshade>
          <br>
           
        </td>
        <td></td>
      </tr>
      <tr> 
        <td valign="top" bgcolor="#E7E7E7" bordercolor="#E7E7E7" bordercolorlight="#E7E7E7" bordercolordark="#E7E7E7" width="142" align="right"><b><font face="Arial, Helvetica, sans-serif"> 
           
          IPSec Setup 
           
          </font></b></td>
        <td background="images_rv042/UI_04.gif" width="8" valign="top">&nbsp;</td>
        <td width="20" valign="top" bgcolor="#FFFFFF">&nbsp;</td>
        <td width="620" valign="top" bgcolor="#FFFFFF"> 
           
          <table width="98%" align="center">
            <tr> 
              <td width="24">&nbsp;</td>
              <td width="180"> 
                <div align="right">Keying Mode</div>
              </td>
              <td width="388"> 
  
                <select name="typeKeyMode"          onChange="falseSubmit1(this.form,\'13\')"><option value=1  
                  >Manual</option>
                  <option value=2  
                  selected>IKE with Preshared key</option> 
                </select>
              </td>
            </tr>
          </table>
           
          <!--
          <table width="98%" align="center">
            <tr> 
              <td width="13">&nbsp;</td>
              <td width="191"> 
                <div align="right">Incoming SPI</div>
              </td>
              <td width="388"> 
                <input type="text" name="inSPI" maxlength="8" size="8" onFocus="this.select();" onBlur=" SPICheck(\'I\',this)" value=\'\'>
              </td>
            </tr>
            <tr> 
              <td width="13">&nbsp;</td>
              <td width="191"> 
                <div align="right">Outgoing SPI</div>
              </td>
              <td width="388"> 
                <input type="text" name="outSPI" maxlength="8" size="8" onFocus="this.select();" onBlur=" SPICheck(\'O\',this)" value=\'\'>
              </td>
            </tr>
            <tr> 
              <td width="13">&nbsp;</td>
              <td width="191"> 
                <div align="right">Encryption</div>
              </td>
              <td width="388"> 
                <select name="typeEncryption" onChange="checkKeySize(\'E\')"><option  
                   value=1 >DES</option> <option  
                   value=2 >3DES</option> 
                </select>
              </td>
            </tr>
            <tr> 
              <td width="13">&nbsp;</td>
              <td width="191"> 
                <div align="right">Authentication</div>
              </td>
              <td width="388"> 
                <select name="typeAuthentication" onChange="checkKeySize(\'A\')"><option  
                   value=1 >MD5</option> <option  
                   value=2 >SHA1</option> 
                </select>
              </td>
            </tr>
            <tr> 
              <td width="13">&nbsp;</td>
              <td width="191"> 
                <div align="right">Encryption Key</div>
              </td>
              <td width="388"> 
                <input type="text" name="keyEncryption" size="50" maxlength="50" onFocus="this.select();" onBlur=" KEYCheck(\'E\',this.form.typeEncryption[1].selectedIndex,this)" value=\'\'>
              </td>
            </tr>
            <tr> 
              <td width="13">&nbsp;</td>
              <td width="191"> 
                <div align="right">Authentication Key</div>
              </td>
              <td width="388"> 
                <input type="text" name="keyAuthentication" size="50" maxlength="50" onFocus="this.select();" onBlur=" KEYCheck(\'A\',this.form.typeAuthentication[1].selectedIndex,this)" value=\'\'>
              </td>
            </tr>
          </table>
          -->
           
          <table width="98%" align="center">
            <tr> 
              <td width="24">&nbsp;</td>
              <td width="180"> 
                <div align="right">Phase1 DH Group</div>
              </td>
              <td width="388"> 
                <select name="select"><option 
                   value=1 selected>Group1</option> <option  
                   value=2 >Group2</option> <option  
                   value=3 >Group5</option> 
                </select>
              </td>
            </tr>
            <tr> 
              <td width="24">&nbsp;</td>
              <td width="180"> 
                <div align="right">Phase1 Encryption</div>
              </td>
              <td width="388"> 
                <select name="select2">
		  <option value=1 >DES</option>
		  <option value=2 >3DES</option>
		  <option value=3 >AES-128</option>
		  <option value=4 >AES-192</option>
		  <option value=5 >AES-256</option>
                </select>
              </td>
            </tr>
            <tr> 
              <td width="24">&nbsp;</td>
              <td width="180"> 
                <div align="right">Phase1 Authentication</div>
              </td>
              <td width="388"> 
                <select name="select3"                                ><option  
                   value=1 >MD5</option> <option  
                   value=2 >SHA1</option> 
                </select>
              </td>
            </tr>
            <tr> 
              <td width="21">&nbsp;</td>
              <td width="183"> 
                <div align="right">Phase1 SA Life Time</div>
              </td>
              <td width="388"> 
                <input type="text" name="lifetimeSA1" size="10" maxlength="10" onFocus="this.select();" onBlur=" lifetimeCheck(this)" value=\'28800\'>
                seconds </td>
            </tr>
            <tr>
            <tr> 
              <td width="24">&nbsp;</td>
              <td width="180"> 
                <div align="right">Perfect Forward Secrecy</div>
              </td>
              <td width="388">
   
                <input type="checkbox" name="PFSp" onClick="falseSubmit(this.form,\'13\');" value="1" checked>
              </td>
            </tr>
          </table>
           
           
          <table width="98%" align="center">
            <tr> 
              <td width="25">&nbsp;</td>
              <td width="179"> 
                <div align="right">Phase2 DH Group</div>
              </td>
              <td width="388"> 
                <select name="select4"                       ><option 
                   value=1 selected>Group1</option> <option  
                   value=2 >Group2</option> <option  
                   value=3 >Group5</option> 
                </select>
              </td>
            </tr>
          </table>
           
           
          <table width="98%" align="center">
            <tr> 
              <td width="21">&nbsp;</td>
              <td width="183"> 
                <div align="right">Phase2 Encryption</div>
              </td>
              <td width="388"> 
                <select name="select5">
		  <option value=0 >NULL</option>
		  <option value=1 selected>DES</option>
	 	  <option value=2 >3DES</option>
		  <option value=3 >AES-128</option>
		  <option value=4 >AES-192</option>
		  <option value=5 >AES-256</option>
                </select>
              </td>
            </tr>
            <tr> 
              <td width="21">&nbsp;</td>
              <td width="183"> 
                <div align="right">Phase2 Authentication</div>
              </td>
              <td width="388"> 
                <select name="typehase2A">
		  <option value=0 >NULL</option>
		  <option value=1 selected>MD5</option>
		  <option value=2 >SHA1</option> 
                </select>
              </td>
            </tr>
            <tr> 
              <td width="21">&nbsp;</td>
              <td width="183"> 
                <div align="right">Phase2 SA Life Time</div>
              </td>
              <td width="388"> 
                <input type="text" name="lifetimeSA2" size="10" maxlength="10" onFocus="this.select();" onBlur=" lifetime2Check(this)" value=\'3600\'>
                seconds </td>
            </tr>
            <tr> 
              <td width="21">&nbsp;</td>
              <td width="183"> 
                <div align="right">Preshared Key</div>
              </td>
              <td width="388"> 
                <input type="text" name="keyPreshared2" size="30" maxlength="30" value=""  onFocus="this.select();" onBlur="sTrim(this);">
              </td>
            </tr>
          </table>
           
           
          <input type="hidden" name="advancedStatus" value=\'0\'>
<a name="1"></a>
<script>
if ((document.formgtg.advancedStatus.value=="1") && (document.formgtg.typeKeyMode[1].selectedIndex==1))
{
  document.write(\'<input type="button" name="advanced" value="Advanced -" onClick="opAdvanced(this.form.advancedStatus,this.form)">\');
}
else if (document.formgtg.typeKeyMode[1].selectedIndex==1)
{
  document.write(\'<input type="button" name="advanced" value="Advanced +" onClick="opAdvanced(this.form.advancedStatus,this.form)">\');
}		  
          
</script>
           
          <!--
          <br>
          <hr align="center" size="1" color="#b5b5e6" noshade>
          <br>
-->
        </td>
        <td></td>
      </tr>
      <tr> 
        <td valign="top" bgcolor="#E7E7E7" bordercolor="#E7E7E7" bordercolorlight="#E7E7E7" bordercolordark="#E7E7E7" width="142" align="right" rowspan="2"><b><font face="Arial, Helvetica, sans-serif"> 
          <!--
		Advanced
-->
          </font></b></td>
        <td background="images_rv042/UI_04.gif" width="8" valign="top" rowspan="2">&nbsp;</td>
        <td width="20" valign="top" bgcolor="#FFFFFF" rowspan="2">&nbsp;</td>
        <td width="620" valign="top" bgcolor="#FFFFFF" rowspan="2"> 
          <!--
          <table width="98%" align="center">
            <tr> 
              <td width="6%">&nbsp;</td>
              <td width="7%">
                <input type="checkbox" name="aggressiveMode" value="1" >
                
                </td>
              <td width="87%"> Aggressive Mode</td>
            </tr>
            <tr> 
              <td width="6%">&nbsp;</td>
              <td width="7%"> 
                <input type="checkbox" name="IPComp" value="1" >
                
                </td>
              <td width="87%"> Compress (Support 
                IP Payload Compression Protocol(IPComp))</td>
            </tr>
            <tr> 
              <td width="6%">&nbsp;</td>
              <td width="7%"> 
                <input type="checkbox" name="keepAlive"  value="1" >
                
                </td>
              <td width="87%"> Keep-Alive</td>
            </tr>
            <tr> 
              <td width="6%">&nbsp;</td>
              <td width="7%">
                <input type="checkbox" name="ahHash" value="1" >
              </td>
              <td width="87%">AH Hash Algorithm 
                <select name="ahAlg">
                  <option value="1" >MD5</option>
                  <option value="2" >SHA1</option>
                </select>
              </td>
            </tr>
            <tr>
              <td width="6%">&nbsp;</td>
              <td width="7%"> 
                <input type="checkbox" name="biosBC"  value="1" >
                </td>
              <td width="87%"> NetBIOS broadcast</td>
            </tr>
            <tr>
              <td width="6%">&nbsp;</td>
              <td width="7%"> 
                <input type="checkbox" name="NATT"  value="1" >
                </td>
              <td width="87%"> NAT Traversal</td>
            </tr>
            <tr> 
              <td width="6%">&nbsp;</td>
              <td width="7%">
                <input type="checkbox" name="DPD" value="1" checked>
              </td>
              <td width="87%">Dead Peer Detection (DPD)&nbsp;&nbsp;&nbsp;Interval 
		<input type="text" name="DPDInterval" maxlength=3 size=3 onFocus="this.select();" onBlur=" DPDtimeCheck(this)" value=\'10\'>
		seconds
              </td>
            </tr>
          </table>
-->
		  		<input type=hidden name="ipRSW1" value=\'\' disabled> <!--2004/09/13 Ryoko-->  		  		  		  
          <br>
          <br>
          <br>
        </td>
        <td height="15"></td>
      </tr>
      <tr> 
        <td valign="bottom" rowspan="2" bgcolor="#6666CC" align="right"><img src="images_rv042/cisco.gif" width="136" height="62"></td>
        <td height="37"></td>
      </tr>
      <tr> 
        <td height="25" colspan="2" valign="top" bgcolor="#000000" bordercolor="#E7E7E7" bordercolorlight="#E7E7E7" bordercolordark="#E7E7E7">&nbsp; 
        </td>
        <td valign="top" bgcolor="#6666CC" bordercolor="#E7E7E7" bordercolorlight="#E7E7E7" bordercolordark="#E7E7E7">&nbsp;</td>
        <td valign="middle" bgcolor="#6666CC" bordercolor="#E7E7E7" bordercolorlight="#E7E7E7" bordercolordark="#E7E7E7"> 
          <table border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse" bordercolor="#111111" id="AutoNumber15" width="220" align="right" height="19">
            <tr> 
              <td width="101" bgcolor="#42498C" align="center"> <a href="javascript: chSubmit(document.formgtg)"><font color="#FFFFFF" style="font-size: 8pt; font-weight: 700" face="Arial"> 
                Save Settings</font></a></td>
              <td width="8" align="center" bgcolor="#6666CC">&nbsp;</td>
              <td width="103" bgcolor="#434A8F" align="center"> <a href="javascript: pageReset()"> 
                <font color="#FFFFFF" style="font-size: 8pt; font-weight: 700" face="Arial"> 
                Cancel Changes</font></a></td>
            </tr>
          </table>
        </td>
        <td valign="top" bgcolor="#6666CC" bordercolor="#E7E7E7" bordercolorlight="#E7E7E7" bordercolordark="#E7E7E7">&nbsp;</td>
        <td valign="top" bgcolor="#000000"> 
          <div align="center"> 
            <center>
            </center>
          </div>
        </td>
        <td></td>
      </tr>
    </form>
  </table>
    
            </div></body>
</html>
END_GATEWAY

our $snmp = <<'END_SNMP';
<html>
<head><meta name="Pragma" content="No-Cache">
<meta name="GENERATOR" content="Microsoft FrontPage 5.0">
<meta name="ProgId" content="FrontPage.Editor.Document">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Web Management</title>
<base target="_self">
<style fprolloverstyle>A:hover {color: #00FFFF}
.help:link {text-decoration: underline}
.help:visited {text-decoration: underline}
.help:hover {color: #FFCC00; text-decoration: underline}
.logout:link {text-decoration: none}
.logout:visited {text-decoration: none}
.logout:hover {color: #FFCC00; text-decoration: none}
</style>
<style type="text/css">
body {font-family: Arial, Verdana, sans-serif, Helvetica; background-color: #ffffff;}
td, th, input, select {font-size: 11px}
</style>
<link rel="stylesheet" href="nk.css">
<script src="nk20060810141951.js"></script> <!--<script src="nk.js"></script>-->
<script src="lg20060810141951.js"></script> <!--<script src="lg.js"></script>-->
<script language=JavaScript>
function chDismatch()
{
    if (document.formsys_snmp.snmp_Mib2SysName) document.formsys_snmp.snmpStatus.checked=true;
	else document.formsys_snmp.snmpStatus.checked=false; 
}
function falseSubmit(F)
{
    if (F.snmpStatus.checked==true)
        F.snmpStatusChange.value=1;
    else
        F.snmpStatusChange.value=0;

    F.submitStatus.value=0;
        MM_showHideLayers(\'AutoNumber15\',\'\',\'hide\');  
  F.submit();
}

function checkIPformat(s)  /* s.value : string */
{
    var p1,p2,p3,p4;
    var rightString, sIP1,sIP2,sIP3,sIP4;
    var d1, d2, d3, d4;

    if (s.value.length<=0)
        return -1;
    p1=s.value.indexOf(\'.\');
    if (p1<=0)
        return -1;
    sIP1=s.value.substring(0,p1);
    rightString=s.value.substring(p1+1,s.value.length);
    p2=rightString.indexOf(\'.\');
    if (p2<=0)
        return -1;
    sIP2=rightString.substring(0,p2);
    rightString=rightString.substring(p2+1,rightString.length);
    p3=rightString.indexOf(\'.\');
    if (p3<=0)
        return -1;
    sIP3=rightString.substring(0,p3);
    sIP4=rightString.substring(p3+1,rightString.length);
    d1=parseInt(sIP1,10);
    d2=parseInt(sIP2,10);
    d3=parseInt(sIP3,10);
    d4=parseInt(sIP4,10);
    if (d1<=255 && d1>=0 && d2<=255 && d2>=0 && d3<=255 && d3>=0 && d4<=255 && d4>=0)
        return 1;
    else
        return -1; 
}

function chSubmit(F)
{
    var p2=-1;
	var p3=-1;
	var leftString, sIP3, sIP4;
    var d3, d4;
	
	if (F.snmp_SendTrap)
    if (F.snmp_SendTrap.value.length>0)
	{
        if(checkIPformat(F.snmp_SendTrap)<0)
        {
            alert(aIPAddress);
            F.snmp_SendTrap.select();
            return;			
        }
	    p3=F.snmp_SendTrap.value.lastIndexOf(\'.\');
		if (p3>0)
		{
		    leftString=F.snmp_SendTrap.value.substring(0,p3);
			p2=leftString.lastIndexOf(\'.\');
			if (p2>0)
			{
			    sIP3=leftString.substring(p2+1,p3);
                sIP4=F.snmp_SendTrap.value.substring(p3+1,F.snmp_SendTrap.value.length);
				
                d3=parseInt(sIP3,10);
                if (d3<=255 && d3>=0) 
                {
                    d4=parseInt(sIP4,10);
                    if (d4==255)
					{
					    alert(aSNMPToBroadcast);
						F.snmp_SendTrap.select();
						return;
				    }

                }
 	
			}
		
		}
	
	
	}
	
    if (F.snmpStatus.checked==true)
        F.snmpStatusChange.value=1;
    else
        F.snmpStatusChange.value=0;
		
	F.submitStatus.value=1;	
    window.status=wSave;
        MM_showHideLayers(\'AutoNumber15\',\'\',\'hide\');  
  F.submit();
}
var wMap=null;
function openMap()
{
  if (wMap==null)
  wMap=window.open(\'map.htm\',\'sitemap\',\'menubar=no,scrollbars,width=670,height=470\');

}
function closeMap()
{
  if (wMap!=null)
  {
    wMap.close();
	wMap=null;
  }
}
function mapTo(p)
{
  document.location.href=p; 
  closeMap(); 
}
window.onfocus=closeMap;
</script>
</head>
<body link="#B5B5E6" vlink="#B5B5E6" alink="#B5B5E6" onLoad="chDismatch()" onUnLoad="closeMap()">
<DIV align=center> 
<table border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse" bordercolor="#111111" id="AutoNumber11" width="960" height="68">
<tr> 
    <td valign="bottom" width="650" hetght="39" bgcolor="#6666CC"> <img border="0" src="images_rv042/clinksys.gif" width="165" height="57" align="middle"></td>
    <td valign="bottom" bgcolor="#6666CC" width="337"> 
        <div align="right"><font color="#FFFFFF"> <span style="font-size: 7pt">&nbsp;&nbsp;&nbsp;&nbsp;<font face="Arial"> 
        Firmware Version: 1.3.7.10</font></span><font face="Arial"><span style="font-size: 7pt">&nbsp;&nbsp;&nbsp;</span></font></font></div>
    </td>
</tr>
<tr> 
    <td colspan="2" valign="top"> <img border="0" src="images_rv042/UI_10.gif" width="960" height="11"></td>
</tr>
</table>
  <TABLE height=90 cellSpacing=0 cellPadding=0 width=960 bgColor=black border=0>
    <form name="formdualwan" method="post" action="">
      <input type="hidden" name="dualwanEnabled" value=\'0\'>
      <input type="hidden" name="firewall0" value=\'\'>
    </form>
    <TR> 
      <TD align=middle bgColor=black height=90 style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black" bordercolor="#000000" width="150"> 
        <H3 style="margin-top: 1; margin-bottom: 1" align="center"> <font face="Arial" color="#FFFFFF">System<br>
          Management</font></H3></TD>
      <TD vAlign=center width=810 bgColor=#000000 height=49 style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black" bordercolor="#000000"> 
        <TABLE cellPadding=0 width="810" border=0 height="90" cellspacing="0" style="border-collapse: collapse; font-style:normal; font-variant:normal; font-weight:normal; font-size:10pt; color:black" bgcolor="#6666CC">
          <TBODY>
            <TR> 
              <TD height="33" valign="middle" bgcolor="#6666CC" width="690" style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black" align="right"> 
                <p><b><font color="#FFFFFF"><span lang="en-us"> 10/100 4-port 
                  VPN Router&nbsp;&nbsp;&nbsp;&nbsp;</span></font></b> </TD>
              <TD width="120" valign="middle" style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black" bgcolor="#000000" bordercolor="#000000" bordercolorlight="#000000" bordercolordark="#000000" align="center"> 
                <p align="center"><font color="#FFFFFF"> <span style="font-size: 8pt"><b>RV042</b></span></font> 
              </TD>
            </TR>
            <TR> 
              <TD colspan="3" bgcolor="#000000" style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"><table width="810" border="0" cellspacing="0" cellpadding="0" >
                  <!--DWLayoutTable-->
                  <tr  align="center"> 
                    <td width="100" height="8" valign="middle" background="images_rv042/UI_06.gif" style=""></td>
                    <td width="80" valign="middle" background="images_rv042/UI_06.gif"style=""></td>
                    <td width="70" valign="middle" background="images_rv042/UI_06.gif"style=""></td>
                    <td width="110" valign="middle" background="images_rv042/UI_07.gif"style=""></td>
                    <td width="80" valign="middle" background="images_rv042/UI_06.gif"style=""></td>
                    <td width="60" valign="middle" background="images_rv042/UI_06.gif"style=""></td>
                    <td width="60" valign="middle" background="images_rv042/UI_06.gif"style=""></td>
                    <td width="80" valign="middle" background="images_rv042/UI_06.gif"style=""></td>
                    <td width="85" valign="middle" background="images_rv042/UI_06.gif"style=""></td>
                    <td width="85" valign="middle" background="images_rv042/UI_06.gif"style=""></td>
                  </tr>
                  <tr  align="center" valign="middle"> 
                    <td height="28" style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"> 
                      <p align="center" style="margin-bottom: 4"> <b><a class="mainmenu" href="home.htm" style="font-size: 8pt; text-decoration: none; font-weight:700"> 
                        System<br>
                        Summary</a></b> </td>
                    <td bgcolor="#000000" style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"> 
                      <p align="center" style="margin-bottom: 4"><b> <a class="mainmenu" href="network.htm" style="font-size: 8pt; text-decoration: none; font-weight:700">Setup</a></b> 
                    </td>
                    <td bgcolor="#000000" style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"> 
                      <p style="margin-bottom: 4"> <b> <a class="mainmenu" href="dhcp_setup.htm" style="font-size: 8pt; text-decoration: none; font-weight:700">DHCP</a></b> 
                    </td>
                    <td bgcolor="#6666CC" style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"> 
                      <p style="margin-bottom: 4"> <b> <font color="#FFFFFF" style="font-size: 8pt"> 
                        System<br>
                        Management </font></b> </td>
                    <td bgcolor="#000000" style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"> 
                      <p style="margin-bottom: 4"><b> <a class="mainmenu" href="f_general.htm" style="font-size: 8pt; text-decoration: none; font-weight:700"> 
                        Firewall</a></b> </td>
                    <td bgcolor="#000000" style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"> 
                      <p style="margin-bottom: 4"> <b> <a class="mainmenu" href="vpn_summary.htm" style="font-size: 8pt; text-decoration: none; font-weight:700">VPN</a></b> 
                    </td>
                    <td bgcolor="#000000" style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"> 
                      <p style="margin-bottom: 4"> <b> <a class="mainmenu" href="log_setting.htm" style="font-size: 8pt; text-decoration: none; font-weight:700">Log</a></b> 
                    </td>
                    <td bgcolor="#000000" style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"> 
                      <p style="margin-bottom: 4"> <b> <a class="mainmenu" href="wizard.htm" style="font-size: 8pt; text-decoration: none; font-weight:700">Wizard</a></b> 
                    </td>
                    <td bgcolor="#000000" style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"> 
                      <p style="margin-bottom: 4"> <b> <a class="mainmenu" href="support.htm" style="font-size: 8pt; text-decoration: none; font-weight:700">Support</a></b> 
                    </td>
                    <td bgcolor="#000000" style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"> 
                      <p style="margin-bottom: 4"> <b> <a class="mainmenu" href="javascript: window.close()" style="font-size: 8pt; text-decoration: none; font-weight:700">Logout</a></b> 
                    </td>
                  </tr>
                </table></TD>
            </TR>
            <TR bgcolor="#6666CC"> 
              <TD colspan="3" style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"><table width="810" height="21" border="0" cellpadding="0" cellspacing="0">
                  <!--DWLayoutTable-->
                  <tr align="center" valign="middle"> 
                    <td width="94" height="21" > 
                      <p align="center"> <span style="font-size: 8pt; background-color:#6666CC"> 
                        <font color="#FFFFFF"> 
                        <!--sys_dualwan-->
                        <!--<a href="sys_dualwan.htm" style="text-decoration: none">-->
                        <script>
					    if (document.formdualwan.dualwanEnabled.value=="1") document.write(\'<a class="submenu" href="sys_dualwanw.htm" style="text-decoration: none">\');
						else document.write(\'<a class="submenu" href="sys_dualwan3.htm" style="text-decoration: none">\');
					  </script>
                        <!--sys_dualwan-->
                        Dual-WAN 
                        <!--sys_dualwan-->
                        <!--sys_dualwan-->
                        </font> </span> </td>
                    <td width="3"> <table border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse; border-left-style: solid; border-left-width: 2" bordercolor="#FFFFFF" id="AutoNumber14" height="10" width="3">
                        <tr> 
                          <td width="1" height="12" align="center" valign="middle"></td>
                        </tr>
                      </table></td>
                    <td width="72" > 
                      <p align="center"> <span style="font-size: 8pt; background-color:#6666CC"> 
                        <font color="#FFFFFF"> 
                        <!--sys_snmp
                        <a class="submenu" href="sys_snmp.htm" style="text-decoration: none"> 
                        sys_snmp-->
                        SNMP 
                        <!--sys_snmp
                        </a> 
                        sys_snmp-->
                        </font> </span> </td>
                    <td width="3" > <table border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse; border-left-style: solid; border-left-width: 2" bordercolor="#FFFFFF" id="AutoNumber14" height="10" width="3">
                        <tr> 
                          <td width="1" height="12" align="center" valign="middle"></td>
                        </tr>
                      </table></td>
                    <td width="90" > 
                      <p align="center"> <span style="font-size: 8pt; background-color:#6666CC"> 
                        <font color="#FFFFFF"> 
                        <!--sys_diag-->
                        <a class="submenu" href="sys_diag.htm" style="text-decoration: none"> 
                        <!--sys_diag-->
                        Diagnostic 
                        <!--sys_diag-->
                        </a> 
                        <!--sys_diag-->
                        </font> </span> </td>
                    <td width="3" > <table border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse; border-left-style: solid; border-left-width: 2" bordercolor="#FFFFFF" id="AutoNumber14" height="10" width="3">
                        <tr> 
                          <td width="1" height="12" align="center" valign="middle"></td>
                        </tr>
                      </table></td>
                    <td width="112" > <p align="center"> <span style="font-size: 8pt; background-color:#6666CC"> 
                        <font color="#FFFFFF"> 
                        <!--sys_factory-->
                        <a class="submenu" href="sys_factory.htm" style="text-decoration: none"> 
                        <!--sys_factory-->
                        Factory Default 
                        <!--sys_factory-->
                        </a> 
                        <!--sys_factory-->
                        </font> </span> </td>
                    <td width="3" > <table border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse; border-left-style: solid; border-left-width: 2" bordercolor="#FFFFFF" id="AutoNumber14" height="10" width="3">
                        <tr> 
                          <td width="1" height="12" align="center" valign="middle"></td>
                        </tr>
                      </table></td>
                    <td width="128" > <p align="center"> <span style="font-size: 8pt; background-color:#6666CC"> 
                        <font color="#FFFFFF"> 
                        <!--sys_firmware-->
                        <a class="submenu" href="sys_firmware.htm" style="text-decoration: none"> 
                        <!--sys_firmware-->
                        Firmware Upgrade 
                        <!--sys_firmware-->
                        </a> 
                        <!--sys_firmware-->
                        </font> </span> </td>
                    <td width="3" > <table border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse; border-left-style: solid; border-left-width: 2" bordercolor="#FFFFFF" id="AutoNumber14" height="10" width="3">
                        <tr> 
                          <td width="1" height="12" align="center" valign="middle"></td>
                        </tr>
                      </table></td>
                    <td width="72" > <p align="center"> <span style="font-size: 8pt; background-color:#6666CC"> 
                        <font color="#FFFFFF"> 
                        <!--sys_restart-->
                        <a class="submenu" href="sys_restart.htm" style="text-decoration: none"> 
                        <!--sys_restart-->
                        Restart 
                        <!--sys_restart-->
                        </a> 
                        <!--sys_restart-->
                        </font> </span> </td>
                    <td width="3" > <table border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse; border-left-style: solid; border-left-width: 2" bordercolor="#FFFFFF" id="AutoNumber14" height="10" width="3">
                        <tr> 
                          <td width="1" height="12" align="center" valign="middle"></td>
                        </tr>
                      </table></td>
                    <td width="105" > <p align="center"> <span style="font-size: 8pt; background-color:#6666CC"> 
                        <font color="#FFFFFF"> 
                        <!--sys_setting-->
                        <a class="submenu" href="sys_setting.htm" style="text-decoration: none"> 
                        <!--sys_setting-->
                        Setting Backup 
                        <!--sys_setting-->
                        </a> 
                        <!--sys_setting-->
                        </font> </span> </td>
                    <td width="119">&nbsp;</td>
                  </tr>
                </table></TD>
            </TR>
          </TBODY>
        </TABLE></TD>
    </TR>
  </TABLE>
  <table height=5 cellspacing=0 cellpadding=0 width=960 bgcolor=black border=0>
    <tr bgcolor=black> 
      <td width=150 height=1 style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; font-family: Arial, Helvetica, sans-serif; color: black" bgcolor="#E7E7E7" bordercolor="#E7E7E7"> 
        <img border="0" src="images_rv042/UI_03.gif" width="150" height="15"></td>
      <td width=810 height=1 style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; font-family: Arial, Helvetica, sans-serif; color: black" bgcolor="#FFFFFF"> 
        <img border="0" src="images_rv042/UI_02.gif" width="810" height="15"></td>
    </tr>
  </table>
  <table border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse" bordercolor="#111111" id="AutoNumber9" width="961">
    <tr> 
      <td height="25" valign="middle" bgcolor="#000000" bordercolor="#E7E7E7" bordercolorlight="#E7E7E7" bordercolordark="#E7E7E7" width="142" align="right"><font color="#FFFFFF"><b><font face="Arial, Helvetica, sans-serif">SNMP</font></b></font></td>
      <td width="8" valign="top" bgcolor="#000000">&nbsp;</td>
      <td width="20" valign="top" bgcolor="#FFFFFF">&nbsp;</td>
      <td width="620" valign="top" bgcolor="#FFFFFF"><font size="+0">&nbsp;</font><font size="+0">&nbsp;</font> 
        <div align="left"> </div>
      </td>
      <td width="20" valign="top" bgcolor="#FFFFFF" rowspan="3">&nbsp;</td>
      <td background="images_rv042/UI_05.gif" width="14" valign="top" rowspan="3">&nbsp;</td>
      <td width="136" rowspan="2" valign="top" bgcolor="#6666CC" align="right"> 
        <a href="javascript: openMap()"><img src="images_rv042/sitemap-off.jpg" width="136" height="28" border="0" onMouseOver="this.src=\'images_rv042/sitemap-on.jpg\'" onMouseOut="this.src=\'images_rv042/sitemap-off.jpg\'"></a> 
        <br><br>
		<div align="left"><font face="Arial" style="font-size: 8pt" color="#FFFFFF"> 
          SNMP, or Simple Network Management Protocol, is a network protocol that 
          provides network administrators with the ability to monitor the status 
          of the RV042 and receive notification of any critical events as they 
          occur on the network. <br>
          <br>
<a href="javascript: h_sys_snmp();"><b><font face="Arial" style="font-size: 8pt" color="#FFFFFF">More...</font></b></a>		
		</font></div>
		</td>
      <td width="1"></td>
    </tr>
    <tr> 
      <td valign="top" bgcolor="#E7E7E7" bordercolor="#E7E7E7" bordercolorlight="#E7E7E7" bordercolordark="#E7E7E7" rowspan="2" height="280">&nbsp;</td>
      <td background="images_rv042/UI_04.gif" valign="top" rowspan="2">&nbsp;</td>
      <td valign="top" bgcolor="#FFFFFF" rowspan="2">&nbsp;</td>
      <td valign="top" bgcolor="#FFFFFF" rowspan="2"> 
        <table width="600" align="center">
          <tr> 
            <td> 
              <form name="formsys_snmp" method="post" action="sys_snmp.htm">
                <input type=hidden name="page" value="sys_snmp.htm">
                <input type=hidden name="submitStatus" value="1">
                <input type=hidden name="snmpStatusChange" value="0">
                <br>
                <font face="Arial Unicode MS" size="+0"></font> 
                <p align="center"> <font size="+0"><b><font face="verdana" size="2"> 
                  </font></b></font><b> <font face="Arial">SNMP : </font><font face="Arial Unicode MS">Enable <input type="checkbox" name="snmpStatus" value="0" onClick="falseSubmit(this.form)"  checked>
                  
                   </font></b></p>
                 
                <font size="+0"> 
                <center>
                  <table cellpadding="0" width="98%" border="0">
                    <tr> 
                      <td> 
                        <table cellspacing="0" width="45%" align="center" border="0">
                          <tr> 
                            <td noWrap align="right"><b><font face="Arial Unicode MS">System 
                              Name:</font></b> </td>
                            <td><font face="Arial Unicode MS"><b> 
                              <input type="text" name="snmp_Mib2SysName" maxlength="255" size="30" value=\'linksys-vpn\' onFocus="this.select();" onBlur="sTrim(this);"> 
                              </b></font> </td>
                          </tr>
                          <tr> 
                            <td noWrap align="right"><b><font face="Arial Unicode MS">System 
                              Contact:</font></b> </td>
                            <td><font face="Arial Unicode MS"><b> 
                              <input type="text" name="snmp_Mib2SysContact" maxlength="255" size="30" value=\'Dylan Is Testing This\' onFocus="this.select();" onBlur="sTrim(this);"> 
                              </b></font> </td>
                          </tr>
                          <tr> 
                            <td noWrap align="right"><b><font face="Arial Unicode MS">System 
                              Location:</font></b> </td>
                            <td><font face="Arial Unicode MS"><b> 
                              <input type="text" name="snmp_Mib2SysLocation" maxlength="255" size="30" value=\'Somewhere in Austin ...\' onFocus="this.select();" onBlur="sTrim(this);"> 
                              </b></font> </td>
                          </tr>
                          <tr> 
                            <td><b><font face="Arial Unicode MS">&nbsp;</font></b></td>
                            <td><b><font face="Arial Unicode MS">&nbsp;</font></b></td>
                          </tr>
                          <tr> 
                            <td noWrap align="right"><b><font face="Arial Unicode MS">Get 
                              Community Name:</font></b> </td>
                            <td><font face="Arial Unicode MS"><b> 
                              <input type="text" name="snmp_GetCommunity" maxlength="63" size="30" value=\'public\'  onFocus="this.select();" onBlur="sTrim(this);">
                              </b></font> </td>
                          </tr>
                          <tr> 
                            <td noWrap align="right"><b><font face="Arial Unicode MS">Set 
                              Community Name:</font></b> </td>
                            <td><font face="Arial Unicode MS"><b> 
                              <input type="text" name="snmp_SetCommunity" maxlength="63" size="30" value=\'private\'  onFocus="this.select();" onBlur="sTrim(this);">
                              </b></font> </td>
                          </tr>
                          <tr>
                            <td noWrap align="right"><b><font face="Arial Unicode MS">Trap
                              Community Name:</font></b> </td>
                            <td><font face="Arial Unicode MS"><b>
                              <input type="text" name="snmp_TrapCommunity" maxlength="63" size="30" value=\'public\'  onFocus="this.select();" onBlur="sTrim(this);">
                              </b></font> </td>
                          </tr>
                          <tr> 
                            <td align="right" nowrap><b><font face="Arial Unicode MS">Send 
                              SNMP Trap to: </font></b></td>
                            <td><b><font face="Arial Unicode MS"><b> 
                              <input type="text" name="snmp_SendTrap" maxlength="63" size="30" value=\'10.100.32.50\'  onFocus="this.select();" onBlur="sTrim(this);">
                              </b></font></b></td>
                          </tr>
                          <tr> 
                            <td>&nbsp;</td>
                            <td>&nbsp;</td>
                          </tr>
                        </table>
                      </td>
                    </tr>
                  </table>
                </center>
                </font> <br>
                 
              </form>
            </td>
          </tr>
        </table>
      </td>
      <td height="200"></td>
    </tr>
    <tr> 
      <td valign="bottom" rowspan="2" bgcolor="#6666CC" align="right"><img src="images_rv042/cisco.gif" width="136" height="62"></td>
      <td height="37"></td>
    </tr>
    <tr> 
      <td height="25" colspan="2" valign="top" bgcolor="#000000" bordercolor="#E7E7E7" bordercolorlight="#E7E7E7" bordercolordark="#E7E7E7">&nbsp; 
      </td>
      <td valign="top" bgcolor="#6666CC" bordercolor="#E7E7E7" bordercolorlight="#E7E7E7" bordercolordark="#E7E7E7">&nbsp;</td>
      <td valign="middle" bgcolor="#6666CC" bordercolor="#E7E7E7" bordercolorlight="#E7E7E7" bordercolordark="#E7E7E7" align="center"> 
        <table border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse" bordercolor="#111111" id="AutoNumber15" width="220" align="right" height="19">
          <tr> 
            <td width="101" bgcolor="#42498C" align="center"> <font color="#FFFFFF" style="font-size: 8pt; font-weight: 700" face="Arial"> 
              <a href="javascript:chSubmit(document.formsys_snmp)"><font color="#FFFFFF">Save 
              Settings</font></a></font> </td>
            <td width="8" align="center" bgcolor="#6666CC">&nbsp;</td>
            <td width="103" bgcolor="#434A8F" align="center"> <font color="#FFFFFF" style="font-size: 8pt; font-weight: 700" face="Arial"> 
              <a href="sys_snmp.htm"><font color="#FFFFFF">Cancel 
              Changes</font></a></font> </td>
          </tr>
        </table>
      </td>
      <td valign="top" bgcolor="#6666CC" bordercolor="#E7E7E7" bordercolorlight="#E7E7E7" bordercolordark="#E7E7E7">&nbsp;</td>
      <td valign="top" bgcolor="#000000"> 
        <div align="center"> 
          <center>
          </center>
        </div>
      </td>
      <td></td>
    </tr>
  </table>
</div></body>
</html>
END_SNMP

our $network = <<'END_NETWORK';
<html>
<head><meta name="Pragma" content="No-Cache">
<meta name="GENERATOR" content="Microsoft FrontPage 5.0">
<meta name="ProgId" content="FrontPage.Editor.Document">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Web Management</title>
<base target="_self">
<style fprolloverstyle>A:hover {color: #00FFFF}
.help:link {text-decoration: underline}
.help:visited {text-decoration: underline}
.help:hover {color: #FFCC00; text-decoration: underline}
.logout:link {text-decoration: none}
.logout:visited {text-decoration: none}
.logout:hover {color: #FFCC00; text-decoration: none}
.mainmenu:link {color: #FFFFFF; text-decoration: none}
.mainmenu:visited {color: #FFFFFF; text-decoration: none}
.mainmenu:hover {color: #00FFFF; text-decoration: none}
.submenu:link {color: #333333; text-decoration: none}
.submenu:visited {color: #333333; text-decoration: none}
.submenu:hover {color: #00FFFF; text-decoration: none}
</style>
<style type="text/css">
body {font-family: Arial, Verdana, sans-serif, Helvetica; background-color: #ffffff;}
td, input, select {font-size: 11px}
</style>
<script src="nk20060810141951.js"></script> <!--<script src="nk.js"></script>-->
<script src="lg20060810141951.js"></script> <!--<script src="lg.js"></script>-->
<script language=JavaScript>
function EchoCheck(I, status)
{
    var d;
    d=parseInt(I.value,10);
	
    if (status == "interval")
	{
        if (!(d<=9999 && d>=5))
        {
            alert(aEchoIntervalCheck);
            I.value=I.defaultValue;
            return;
        }	
	}
	
	if (status == "failure")
	{
        if (!(d<=99 && d>=1))
        {
            alert(aEchoFailureCheck);
            I.value=I.defaultValue;
            return;
        }	
	}
	
    I.value=d;
}
function chDismatchLanMask(F)
{

//20040730 ryoko default lan ip
    var IpLan,IpLan123,IpLan1,IpLan2,IpLan3,IpLan4;
	var IpPptp123,IpPptpStart4,IpPptpEnd4;
	var ipdmz=F.LanIp.value;
	var dmzIp123="",dmzIp4,tmp_dmz_length,tmp_dmz_string=ipdmz,tmp_num,tmp_num_total=0;
                tmp_dmz_length=ipdmz.length;
	var tmp_i=0;
	for (tmp_i=0; tmp_i < 3; tmp_i++)				
	{
    			tmp_num=tmp_dmz_string.indexOf(".");
				if(tmp_i==0)
				IpLan1=ipdmz.substring(0,tmp_num);
				else if(tmp_i==1)
				IpLan2=ipdmz.substring(tmp_num_total,tmp_num_total+tmp_num);
				else if(tmp_i==2)
				IpLan3=ipdmz.substring(tmp_num_total,tmp_num_total+tmp_num);
				tmp_num_total=tmp_num_total+tmp_num+1;
				tmp_dmz_string=tmp_dmz_string.substring(tmp_num+1,tmp_dmz_length); 
	}
    			tmp_num=tmp_dmz_string.indexOf(" ");	
				if(tmp_num!=-1)
				IpLan4=tmp_dmz_string.substring(0,tmp_num)
				else
				IpLan4=tmp_dmz_string;
				F.LanIp1.value=IpLan1;
				F.LanIp2.value=IpLan2;
				F.LanIp3.value=IpLan3;
				F.LanIp4.value=IpLan4;
//20040730 ryoko default lan ip
//20040730 ryoko default submask
	ipdmz=F.netMaskAll.value;
	dmzIp123="",tmp_dmz_string=ipdmz,tmp_num,tmp_num_total=0;
                tmp_dmz_length=ipdmz.length;
	for (tmp_i=0; tmp_i < 3; tmp_i++)				
	{
    			tmp_num=tmp_dmz_string.indexOf(".");
				if(tmp_i==0)
				IpLan1=ipdmz.substring(0,tmp_num);
				else if(tmp_i==1)
				IpLan2=ipdmz.substring(tmp_num_total,tmp_num_total+tmp_num);
				else if(tmp_i==2)
				IpLan3=ipdmz.substring(tmp_num_total,tmp_num_total+tmp_num);
				tmp_num_total=tmp_num_total+tmp_num+1;
				tmp_dmz_string=tmp_dmz_string.substring(tmp_num+1,tmp_dmz_length); 
	}
    			tmp_num=tmp_dmz_string.indexOf(" ");	
				if(tmp_num!=-1)
				IpLan4=tmp_dmz_string.substring(0,tmp_num)
				else
				IpLan4=tmp_dmz_string;
				F.netMaskIp1.value=IpLan1;
				F.netMaskIp2.value=IpLan2;
				F.netMaskIp3.value=IpLan3;
				F.netMaskIp4.value=IpLan4;
//20040730 ryoko default submask	  


}

function chDismatch()
{
    if (document.formNetwork.Wan1AliasIp1 && document.formNetwork.Wan1UserName) document.formNetwork.WAN1ConnectionType.selectedIndex=3;
	else if (document.formNetwork.Wan1UserName) document.formNetwork.WAN1ConnectionType.selectedIndex=2;
	else if (document.formNetwork.Wan1AliasIp1) document.formNetwork.WAN1ConnectionType.selectedIndex=1;
	else if (document.formNetwork.setWan1DNS) document.formNetwork.WAN1ConnectionType.selectedIndex=0;
	
    if (document.formNetwork.Wan2AliasIp1 && document.formNetwork.Wan2UserName) document.formNetwork.WAN2ConnectionType.selectedIndex=3;
	else if (document.formNetwork.Wan2UserName) document.formNetwork.WAN2ConnectionType.selectedIndex=2;
	else if (document.formNetwork.Wan2AliasIp1) document.formNetwork.WAN2ConnectionType.selectedIndex=1;
	else if (document.formNetwork.setWan2DNS) document.formNetwork.WAN2ConnectionType.selectedIndex=0;
    /* 2004/11/25 Eric --> */
	if (document.formNetwork.wan_dmz[1].checked == true)
	{
	    if (document.formNetwork.Wan2DmzIp5) document.formNetwork.DmzSubnetRange[1].checked=true;
		else document.formNetwork.DmzSubnetRange[0].checked=true;
	}
    // <-- Eric
}
function chHost(I)
{
    if (I.value=="")
    {
        alert(aHostName);
        I.value=I.defaultValue;
        return;
    }

}
function chDomain(I)
{
    if (I.value=="")
    {
        alert(aDomainName);
        I.value=I.defaultValue;
        return;
    }
}
function falseSubmit(F,n) //Jump area
{
    F.submitStatus.value=0; 
    document.formNetwork.WAN1ConnectionType.disabled=false;
    document.formNetwork.WAN2ConnectionType.disabled=false;
	
	F.action="network.htm"+"#"+n;	
        MM_showHideLayers(\'AutoNumber15\',\'\',\'hide\');  
  F.submit();
}
function exDNS(iface)
{
  switch (iface)
  {
    case \'WAN1\':
        document.formNetwork.Wan1DnsA1.value=document.formNetwork.Wan1DnsB1.value;
        document.formNetwork.Wan1DnsA2.value=document.formNetwork.Wan1DnsB2.value;
        document.formNetwork.Wan1DnsA3.value=document.formNetwork.Wan1DnsB3.value;	
        document.formNetwork.Wan1DnsA4.value=document.formNetwork.Wan1DnsB4.value;
        document.formNetwork.Wan1DnsB1.value="0";
		document.formNetwork.Wan1DnsB2.value="0";
		document.formNetwork.Wan1DnsB3.value="0";
		document.formNetwork.Wan1DnsB4.value="0";			
	break;
    case \'WAN2\':
        document.formNetwork.Wan2DnsA1.value=document.formNetwork.Wan2DnsB1.value;
        document.formNetwork.Wan2DnsA2.value=document.formNetwork.Wan2DnsB2.value;
        document.formNetwork.Wan2DnsA3.value=document.formNetwork.Wan2DnsB3.value;	
        document.formNetwork.Wan2DnsA4.value=document.formNetwork.Wan2DnsB4.value;
        document.formNetwork.Wan2DnsB1.value="0";
		document.formNetwork.Wan2DnsB2.value="0";
		document.formNetwork.Wan2DnsB3.value="0";
		document.formNetwork.Wan2DnsB4.value="0";	
	break;
  }	
}
function chSubmit(F)
{
//<--ryoko20050125 DMZ range  check Specify WAN IP Address
    if(F.wan_dmz[1])
	if(F.wan_dmz[1].checked==true)
    if(F.WAN1ConnectionType)		
    if(F.WAN1ConnectionType.value==2)	
	if(F.DmzSubnetRange[1])
	if(F.DmzSubnetRange[1].checked==true)
	if(F.Wan1AliasIp4&&F.Wan2DmzIp4&&F.Wan2DmzIp5)
	if((eval(F.Wan1AliasIp4.value)>=eval(F.Wan2DmzIp4.value))&&(eval(F.Wan1AliasIp4.value)<=eval(F.Wan2DmzIp5.value)))
	{
//	alert(F.Wan1AliasIp4.value+":"+F.Wan2DmzIp4.value+":"+F.Wan2DmzIp5.value);

	alert(aDMZSubnetRangeConflict);
	return;
	}
//<--ryoko20040729 DHCP IP check LanIp
	if(F.ipAddr1)
    if(F.DhcpEnabled1.value==" checked") 
	if(F.ipAddr1.value==F.dsDHCP1.value)
	if(F.ipAddr2.value==F.dsDHCP2.value)
	if(F.ipAddr3.value==F.dsDHCP3.value)
	if(eval(F.ipAddr4.value)<=eval(F.deDHCP4.value)&&eval(F.ipAddr4.value)>=eval(F.dsDHCP4.value))
    {
	//alert(aDhcpLanIpConflict);
	//return;
	}
	
//<--ryoko20040729 log_report IP check LanIp
	if(F.netMask)
	if(eval(F.netMask.value)!=eval(F.netMaskIp4.value))
    {
	   alert(aChangedSubnet);
	}
	// 2004/11/25 Eric -->
	if (document.formNetwork.Wan2DmzIp5)
	{
	    if (eval(document.formNetwork.Wan2DmzIp5.value) < eval(document.formNetwork.Wan2DmzIp4.value))
		{
		    tmpString=document.formNetwork.Wan2DmzIp5.value;
			document.formNetwork.Wan2DmzIp5.value=document.formNetwork.Wan2DmzIp4.value;
			document.formNetwork.Wan2DmzIp4.value=tmpString;
		}
	
	}
	// <-- Eric
/* 2003/09/24 Eric --> */
    if (F.wan_dmz[1].checked==true)
	{
	    if (F.DmzSubnetRange[0].checked==true) // 2004/04/21 Eric
	    if ((F.Wan2AliasIp1.value==F.ipAddr1.value) && (F.Wan2AliasIp2.value==F.ipAddr2.value) && (F.Wan2AliasIp3.value==F.ipAddr3.value))
		{
		    alert(aDMZSubnetConflict);
			F.Wan2AliasIp1.select();
			return;
		} 
		if (F.DmzSubnetRange[1].checked==true) // 2004/04/21 Eric
		if ((F.Wan2DmzIp1.value==F.ipAddr1.value) && (F.Wan2DmzIp2.value==F.ipAddr2.value) && (F.Wan2DmzIp3.value==F.ipAddr3.value))
		{
		    alert(aDMZSubnetConflict);
			F.Wan2DmzIp1.select();
			return;
		}
    }
// <-- Eric
/************************ chDNS 2003/07/23 /Eric *******************************/	
	if (document.formNetwork.WAN1ConnectionType.selectedIndex==0 && document.formNetwork.setWan1DNS.checked==true)
	{
	    if (document.formNetwork.Wan1DnsA1.value=="0" && document.formNetwork.Wan1DnsA2.value=="0" && document.formNetwork.Wan1DnsA3.value=="0" && document.formNetwork.Wan1DnsA4.value=="0")
		{
	        if (document.formNetwork.Wan1DnsB1.value!="0" || document.formNetwork.Wan1DnsB2.value!="0" || document.formNetwork.Wan1DnsB3.value!="0" || document.formNetwork.Wan1DnsB4.value!="0")
            exDNS("WAN1");
			else
			{
/*
			    alert("Please Input DNS Server.");
				document.formNetwork.Wan1DnsA1.select();
				return;
*/
                alert(aNoDNS);
			}
	    }
	}
	if (document.formNetwork.WAN2ConnectionType.selectedIndex==0 && document.formNetwork.setWan2DNS.checked==true)
	{
	    if (document.formNetwork.Wan2DnsA1.value=="0" && document.formNetwork.Wan2DnsA2.value=="0" && document.formNetwork.Wan2DnsA3.value=="0" && document.formNetwork.Wan2DnsA4.value=="0")
		{
	        if (document.formNetwork.Wan2DnsB1.value!="0" || document.formNetwork.Wan2DnsB2.value!="0" || document.formNetwork.Wan2DnsB3.value!="0" || document.formNetwork.Wan2DnsB4.value!="0")
            exDNS("WAN2");
			else
			{
/*			
			    alert("Please Input DNS Server.");
				document.formNetwork.Wan2DnsA1.select();
				return;
*/
                alert(aNoDNS);				
			}
	    }
	}
			
/*******************************************************************************/	
/************************ chStatic 2003/07/23 /Eric ****************************/
	//20040817ryoko check PPTP
	if (document.formNetwork.WAN1ConnectionType.selectedIndex==1||document.formNetwork.WAN1ConnectionType.selectedIndex==3) //for dual-wan and dmz
	{
		//20040817ryoko check PPTP
		if(document.formNetwork.Wan1DnsA1)
	    if ((document.formNetwork.Wan1DnsA1.value=="0" && document.formNetwork.Wan1DnsA2.value=="0" && document.formNetwork.Wan1DnsA3.value=="0" && document.formNetwork.Wan1DnsA4.value=="0") && (document.formNetwork.Wan1DnsB1.value!="0" || document.formNetwork.Wan1DnsB2.value!="0" || document.formNetwork.Wan1DnsB3.value!="0" || document.formNetwork.Wan1DnsB4.value!="0"))
        exDNS("WAN1");
			
        if ((document.formNetwork.Wan1AliasIp1.value!="0" || document.formNetwork.Wan1AliasIp2.value!="0" || document.formNetwork.Wan1AliasIp3.value!="0" || document.formNetwork.Wan1AliasIp4.value!="0") || (document.formNetwork.Wan1RouterIp1.value!="0" || document.formNetwork.Wan1RouterIp2.value!="0" || document.formNetwork.Wan1RouterIp3.value!="0" || document.formNetwork.Wan1RouterIp4.value!="0"))
		{
		    if (document.formNetwork.Wan1AliasIp1.value=="0" && document.formNetwork.Wan1AliasIp2.value=="0" && document.formNetwork.Wan1AliasIp3.value=="0" && document.formNetwork.Wan1AliasIp4.value=="0")
			{
			    alert(aIPAddressWAN);
				document.formNetwork.Wan1AliasIp1.select();
				return;
			}		
		    if (document.formNetwork.Wan1AliasMaskIp1.value=="0" && document.formNetwork.Wan1AliasMaskIp2.value=="0" && document.formNetwork.Wan1AliasMaskIp3.value=="0" && document.formNetwork.Wan1AliasMaskIp4.value=="0")
			{
			    alert(aMask);
				document.formNetwork.Wan1AliasMaskIp1.select();
				return;
			}
		    if (document.formNetwork.Wan1RouterIp1.value=="0" && document.formNetwork.Wan1RouterIp2.value=="0" && document.formNetwork.Wan1RouterIp3.value=="0" && document.formNetwork.Wan1RouterIp4.value=="0")
			{
			    alert(aGateway);
				document.formNetwork.Wan1RouterIp1.select();
				return;
			}			
 			//20040817ryoko check PPTP
			if(document.formNetwork.Wan1DnsA1)
		    if (document.formNetwork.Wan1DnsA1.value=="0" && document.formNetwork.Wan1DnsA2.value=="0" && document.formNetwork.Wan1DnsA3.value=="0" && document.formNetwork.Wan1DnsA4.value=="0")
			{
/*
			    alert("Please Input DNS Server.");
				document.formNetwork.Wan1DnsA1.select();
				return;
*/
                alert(aNoDNS);				
			}		
		}
	}	
	if ((document.formNetwork.WAN2ConnectionType.selectedIndex==1) && (document.formNetwork.wan_dmz[0].checked==true)||(document.formNetwork.WAN2ConnectionType.selectedIndex==3) && (document.formNetwork.wan_dmz[0].checked==true)) //only for dual-wan
	{
		if (document.formNetwork.Wan2DnsA1)
	    if ((document.formNetwork.Wan2DnsA1.value=="0" && document.formNetwork.Wan2DnsA2.value=="0" && document.formNetwork.Wan2DnsA3.value=="0" && document.formNetwork.Wan2DnsA4.value=="0") && (document.formNetwork.Wan2DnsB1.value!="0" || document.formNetwork.Wan2DnsB2.value!="0" || document.formNetwork.Wan2DnsB3.value!="0" || document.formNetwork.Wan2DnsB4.value!="0"))
        exDNS("WAN2");
			
        if ((document.formNetwork.Wan2AliasIp1.value!="0" || document.formNetwork.Wan2AliasIp2.value!="0" || document.formNetwork.Wan2AliasIp3.value!="0" || document.formNetwork.Wan2AliasIp4.value!="0") || (document.formNetwork.Wan2RouterIp1.value!="0" || document.formNetwork.Wan2RouterIp2.value!="0" || document.formNetwork.Wan2RouterIp3.value!="0" || document.formNetwork.Wan2RouterIp4.value!="0"))
		{
		    if (document.formNetwork.Wan2AliasIp1.value=="0" && document.formNetwork.Wan2AliasIp2.value=="0" && document.formNetwork.Wan2AliasIp3.value=="0" && document.formNetwork.Wan2AliasIp4.value=="0")
			{
			    alert(aIPAddressWAN);
				document.formNetwork.Wan2AliasIp1.select();
				return;
			}		
		    if (document.formNetwork.Wan2AliasMaskIp1.value=="0" && document.formNetwork.Wan2AliasMaskIp2.value=="0" && document.formNetwork.Wan2AliasMaskIp3.value=="0" && document.formNetwork.Wan2AliasMaskIp4.value=="0")
			{
			    alert(aMask);
				document.formNetwork.Wan2AliasMaskIp1.select();
				return;
			}
		    if (document.formNetwork.Wan2RouterIp1.value=="0" && document.formNetwork.Wan2RouterIp2.value=="0" && document.formNetwork.Wan2RouterIp3.value=="0" && document.formNetwork.Wan2RouterIp4.value=="0")
			{
			    alert(aGateway);
				document.formNetwork.Wan2RouterIp1.select();
				return;
			}			
			if (document.formNetwork.Wan2DnsA1)
		    if (document.formNetwork.Wan2DnsA1.value=="0" && document.formNetwork.Wan2DnsA2.value=="0" && document.formNetwork.Wan2DnsA3.value=="0" && document.formNetwork.Wan2DnsA4.value=="0")
			{
/*			
			    alert("Please Input DNS Server.");
				document.formNetwork.Wan2DnsA1.select();
				return;
*/
                alert(aNoDNS);				
			}		
		}	
	}
	//2003/07/28 Eric=>
	if ((document.formNetwork.WAN2ConnectionType.selectedIndex==1) && (document.formNetwork.wan_dmz[1].checked==true)) //only for dual-wan
	{
	    if (document.formNetwork.DmzSubnetRange[0].checked==true) // 2004/11/25 Eric
        if ((document.formNetwork.Wan2AliasIp1.value!="0" || document.formNetwork.Wan2AliasIp2.value!="0" || document.formNetwork.Wan2AliasIp3.value!="0" || document.formNetwork.Wan2AliasIp4.value!="0") || (document.formNetwork.Wan2AliasMaskIp1.value!="0" || document.formNetwork.Wan2AliasMaskIp2.value!="0" || document.formNetwork.Wan2AliasMaskIp3.value!="0" || document.formNetwork.Wan2AliasMaskIp4.value!="0"))
		{
		    if (document.formNetwork.Wan2AliasIp1.value=="0" && document.formNetwork.Wan2AliasIp2.value=="0" && document.formNetwork.Wan2AliasIp3.value=="0" && document.formNetwork.Wan2AliasIp4.value=="0")
			{
			    alert(aIPAddressWAN);
				document.formNetwork.Wan2AliasIp1.select();
				return;
			}
			if (document.formNetwork.Wan2AliasMaskIp1) // 2004/11/25 Eric
		    if (document.formNetwork.Wan2AliasMaskIp1.value=="0" && document.formNetwork.Wan2AliasMaskIp2.value=="0" && document.formNetwork.Wan2AliasMaskIp3.value=="0" && document.formNetwork.Wan2AliasMaskIp4.value=="0")
			{
			    alert(aMask);
				document.formNetwork.Wan2AliasMaskIp1.select();
				return;
			}		
		}	
	}
	//<=Eric

    document.formNetwork.WAN1ConnectionType.disabled=false;
    document.formNetwork.WAN2ConnectionType.disabled=false;
	
// 2004/11/25 Eric
    if (F.Wan2DmzIp1)
	{
	    F.Wan2DmzIp1.disabled=false;
	    F.Wan2DmzIp2.disabled=false;
		F.Wan2DmzIp3.disabled=false;
		F.Wan2DmzIp4.disabled=false;
		F.Wan2DmzIp5.disabled=false;
	}
// <-- Eric	
	
	if(F.ipAddr1)
	if(F.ipAddr1.value!=F.LanIp1.value||F.ipAddr2.value!=F.LanIp2.value||F.ipAddr3.value!=F.LanIp3.value||eval(F.ipAddr4.value)!=eval(F.LanIp4.value))
    {
	    if (!confirm(cDeviceIP))
	    return;
	}	
// 2003/07/28 Eric    if (document.formNetwork.wan_dmz[1].checked==true) selAll(F.DMZRangeList);
    F.submitStatus.value=1;
    window.status=wSave;		
        MM_showHideLayers(\'AutoNumber15\',\'\',\'hide\');  
  F.submit();
}


function IPCheck(I)
{
    var d;
    d=parseInt(I.value,10);
    if (!(d<256 && d>=0))
    {
        alert(aIPCheck);
        I.value=I.defaultValue;
        return;
    }
    I.value=d;
}

function IP0to254Check(I)
{
    var d;
    d=parseInt(I.value,10);
    if (!(d<255 && d>=0)) 
    {
        alert(aIP0to254Check);
        I.value=I.defaultValue;
        return;    
    }
    I.value=d;
}

function IP1to254Check(I)
{
    var d;
    d=parseInt(I.value,10);
    if (!(d<255 && d>=1)) 
    {
        alert(aIP1to254Check);
        I.value=I.defaultValue;
        return;    
    }
    I.value=d;
}

function MKCheck(I)
{
    var d;
    d=parseInt(I.value,10);
    if (!(d<256 && d>=0))
    {
        alert(aMaskCheck);
        I.value=I.defaultValue;
        return;
    }
    I.value=d;
}

/*
function netMaskCheck(I)
{
    var d;
    d=parseInt(I.value,10);
    if (!(d==0 || d==128 || d==192 || d==224 || d==240 || d==248 || d==252 || d==254))
    {
        alert(\'Incorrect NetMask value!\');
        I.value=I.defaultValue;
    }
}
*/

function minCheck(I)
{
    var d;
    d=parseInt(I.value,10);
    if (!(d<100000 && d>0))
    {
        alert(aMinuteNums2Check);
        I.value=I.defaultValue;
        return;
    }
    I.value=d;
}

function secCheck(I)
{
    var d;
    d=parseInt(I.value,10);
    if (!(d<10000000 && d>0))
    {
        alert(aSecondNums3Check);
        I.value=I.defaultValue;
        return;
    }
    I.value=d;
}

function disableIt(obj)
{
    obj.disabled=true;
}

function enableIt(obj)
{
    obj.disabled=false;
}

function chsetDNS()
{

    if (document.formNetwork.wan_dmz[0].checked==true)
    {
      enableWANType();	 
    }
    else if (document.formNetwork.wan_dmz[1].checked==true)
    {
      onlyStatic();
    }

    if (document.formNetwork.WAN1ConnectionType.options[0].selected==true)
    {
        if (document.formNetwork.setWan1DNS.checked==true) 
        {
            document.formNetwork.Wan1DnsNeq.value = 0;
            enableIt(document.formNetwork.Wan1DnsA1);
            enableIt(document.formNetwork.Wan1DnsA2);
            enableIt(document.formNetwork.Wan1DnsA3);
            enableIt(document.formNetwork.Wan1DnsA4);
            enableIt(document.formNetwork.Wan1DnsB1);
            enableIt(document.formNetwork.Wan1DnsB2);
            enableIt(document.formNetwork.Wan1DnsB3);
            enableIt(document.formNetwork.Wan1DnsB4);
        }
        else
        {
            document.formNetwork.Wan1DnsNeq.value = 1;
            disableIt(document.formNetwork.Wan1DnsA1);
            disableIt(document.formNetwork.Wan1DnsA2);
            disableIt(document.formNetwork.Wan1DnsA3);
            disableIt(document.formNetwork.Wan1DnsA4);
            disableIt(document.formNetwork.Wan1DnsB1);
            disableIt(document.formNetwork.Wan1DnsB2);
            disableIt(document.formNetwork.Wan1DnsB3);
            disableIt(document.formNetwork.Wan1DnsB4);
        }
    }
    if (document.formNetwork.WAN2ConnectionType.options[0].selected==true)
    {
        if (document.formNetwork.setWan2DNS.checked==true) 
        {
            document.formNetwork.Wan2DnsNeq.value = 0;
            enableIt(document.formNetwork.Wan2DnsA1);
            enableIt(document.formNetwork.Wan2DnsA2);
            enableIt(document.formNetwork.Wan2DnsA3);
            enableIt(document.formNetwork.Wan2DnsA4);
            enableIt(document.formNetwork.Wan2DnsB1);
            enableIt(document.formNetwork.Wan2DnsB2);
            enableIt(document.formNetwork.Wan2DnsB3);
            enableIt(document.formNetwork.Wan2DnsB4);
        }
        else
        {
            document.formNetwork.Wan2DnsNeq.value = 1;
            disableIt(document.formNetwork.Wan2DnsA1);
            disableIt(document.formNetwork.Wan2DnsA2);
            disableIt(document.formNetwork.Wan2DnsA3);
            disableIt(document.formNetwork.Wan2DnsA4);
            disableIt(document.formNetwork.Wan2DnsB1);
            disableIt(document.formNetwork.Wan2DnsB2);
            disableIt(document.formNetwork.Wan2DnsB3);
            disableIt(document.formNetwork.Wan2DnsB4);
        }
    }

}
function chDmzRange()
{
    if (document.formNetwork.wan_dmz[1].checked==true)
	{
	    if (document.formNetwork.DmzSubnetRange[1].checked==true)
		{
		    if (document.formNetwork.WAN1ConnectionType.selectedIndex != 1)
			{
			    alert(aDmzRangeStaticWan);
			    document.formNetwork.Wan2DmzIp1.disabled=true;
			    document.formNetwork.Wan2DmzIp2.disabled=true;
			    document.formNetwork.Wan2DmzIp3.disabled=true;
				document.formNetwork.Wan2DmzIp4.disabled=true;
				document.formNetwork.Wan2DmzIp5.disabled=true;
			}
		}
	}
}
function setDmzRange()
{
    if (document.formNetwork.wan_dmz[1].checked==true)
	{
	    if (document.formNetwork.DmzSubnetRange[1].checked==true)
		{
		    if (document.formNetwork.WAN1ConnectionType.selectedIndex == 1)
			{
			    document.formNetwork.Wan2DmzIp1.value=document.formNetwork.Wan1AliasIp1.value;
			    document.formNetwork.Wan2DmzIp2.value=document.formNetwork.Wan1AliasIp2.value;
			    document.formNetwork.Wan2DmzIp3.value=document.formNetwork.Wan1AliasIp3.value;		
			}
		}	
	}
}
function enableWANType()
{
  if (document.formNetwork.clickDualwan.value=="1")
  {
      alert(aDualWAN);
/*
      if (!confirm("Route has been changed to Dual WAN mode, it will take effect after you save the settings."))
      {
          document.formNetwork.wan_dmz[0].checked=document.formNetwork.wan_dmz[0].defaultChecked;
          document.formNetwork.clickDualwan.value="0";
          return;
      }
*/	  
  }
  
  document.formNetwork.WAN1ConnectionType.disabled=false;
  document.formNetwork.WAN2ConnectionType.disabled=false;
/*  
  if (document.formNetwork.WAN2ConnectionType.selectedIndex==1)
  {
	  document.formNetwork.Wan2DnsA1.disabled=false;
	  document.formNetwork.Wan2DnsA2.disabled=false;
	  document.formNetwork.Wan2DnsA3.disabled=false;
	  document.formNetwork.Wan2DnsA4.disabled=false;
	  document.formNetwork.Wan2DnsB1.disabled=false;
	  document.formNetwork.Wan2DnsB2.disabled=false;
	  document.formNetwork.Wan2DnsB3.disabled=false;
	  document.formNetwork.Wan2DnsB4.disabled=false;
  }	  	    
*/
  if (document.formNetwork.clickDualwan.value=="1") falseSubmit(document.formNetwork,\'0\');
}
function onlyStatic()
{
  if (document.formNetwork.clickDmz.value=="1")
  {
      alert(aDMZMode);  
/*  
      if (!confirm("Route has been changed to DMZ mode, it will take effect after you save the settings."))
      {
          document.formNetwork.wan_dmz[1].checked=document.formNetwork.wan_dmz[1].defaultChecked;  
          document.formNetwork.clickDmz.value="0";
          return;
      }
*/	  
  }  
  
// 2003/09/17 Eric -->  if ((document.formNetwork.WAN1ConnectionType.selectedIndex==1) && (document.formNetwork.WAN2ConnectionType.selectedIndex==1))
  if (document.formNetwork.WAN2ConnectionType.selectedIndex==1)
  {

// 2003/09/17 Eric -->      document.formNetwork.WAN1ConnectionType.disabled=true;
      document.formNetwork.WAN2ConnectionType.disabled=true;
/*	Change to don\'t show Subnet Mask area, but nk_get dmz area.  
	  document.formNetwork.Wan2DnsA1.disabled=true;
	  document.formNetwork.Wan2DnsA2.disabled=true;
	  document.formNetwork.Wan2DnsA3.disabled=true;
	  document.formNetwork.Wan2DnsA4.disabled=true;
	  document.formNetwork.Wan2DnsB1.disabled=true;
	  document.formNetwork.Wan2DnsB2.disabled=true;
	  document.formNetwork.Wan2DnsB3.disabled=true;
	  document.formNetwork.Wan2DnsB4.disabled=true;	  
*/
  }
  else
  {
    document.formNetwork.WAN1ConnectionType.disabled=false;  //open for jump area
    document.formNetwork.WAN2ConnectionType.disabled=false;  //open for jump area
// 2003/09/17 Eric -->    document.formNetwork.WAN1ConnectionType.selectedIndex=1;
    document.formNetwork.WAN2ConnectionType.selectedIndex=1;
//    falseSubmit(document.formNetwork);
  }
  if (document.formNetwork.clickDmz.value=="1") falseSubmit(document.formNetwork,\'0\');      
}

/********************************************************************************/
var wMap=null;
function openMap()
{
  if (wMap==null)
  wMap=window.open(\'map.htm\',\'sitemap\',\'menubar=no,scrollbars,width=670,height=470\');

}
function closeMap()
{
  if (wMap!=null)
  {
    wMap.close();
	wMap=null;
  }

}
function mapTo(p)
{
  document.location.href=p; 
  closeMap(); 
}
function closeService()
{
  timer1=setTimeout("closeChild()",1000);
  timer2=setTimeout("refreshMe()",3000);
}

function refreshMe()
{
    falseSubmit(document.formNetwork,\'10\');
}
var wMLan=null;
function openMLan()
{
  if (wMLan==null)
  wMLan=window.open(\'mlan.htm\',\'mlan\',\'menubar=no,scrollbars,width=500,height=500\');

}
function closeChild()
{
  if (wMLan!=null)
  {
    wMLan.close();
	wMLan=null;
  }  
}
function closeMC()
{
  closeMap();
  closeChild();
}
//window.onfocus=closeMap;
window.onfocus=closeMC;
</script>
</head>
<body link="#B5B5E6" vlink="#B5B5E6" alink="#B5B5E6" onLoad="chDismatch(); chsetDNS(); chDmzRange(); setDmzRange(); chDismatchLanMask(document.formNetwork);" onUnLoad="closeMap()">
<DIV align=center>
<table border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse" bordercolor="#111111" id="AutoNumber11" width="960" height="68">
<tr> 
    <td valign="bottom" width="650" hetght="39" bgcolor="#6666CC"> <img border="0" src="images_rv042/clinksys.gif" width="165" height="57" align="middle"></td>
    <td valign="bottom" bgcolor="#6666CC" width="337"> 
        <div align="right"><font color="#FFFFFF"> <span style="font-size: 7pt">&nbsp;&nbsp;&nbsp;&nbsp;<font face="Arial"> 
        Firmware Version: 1.3.7.10</font></span><font face="Arial"><span style="font-size: 7pt">&nbsp;&nbsp;&nbsp;</span></font></font></div>
    </td>
</tr>
<tr>
    <td colspan="2" valign="top"> <img border="0" src="images_rv042/UI_10.gif" width="960" height="11"></td>
</tr>
</table>
  <TABLE height=90 cellSpacing=0 cellPadding=0 width=960 bgColor=black border=0>
    <form name="formdualwan" method="post" action="">
      <input type="hidden" name="dualwanEnabled" value=\'0\'>
      <input type="hidden" name="firewall0" value=\'\'>
    </form>
    <TR> 
      <TD width="150" height=90 rowspan="3" align=middle bordercolor="#000000" bgColor=black style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"> 
        <H3 style="margin-top: 1; margin-bottom: 1" align="center"> <font color="#FFFFFF" face="Arial">Setup</font></H3></TD>
      <TD width=690 height=33 align="center" vAlign=middle bordercolor="#000000" bgColor=#6666CC style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"> 
        <p align="right"><b><font color="#FFFFFF"><span lang="en-us"> 10/100 4-port 
          VPN Router&nbsp;&nbsp;&nbsp;&nbsp;</span></font></b> </TD>
      <TD vAlign=center width=120 bgColor=#000000 style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black" bordercolor="#000000"> 
        <p align="center"><font color="#FFFFFF"> <span style="font-size: 8pt"><b>RV042</b></span></font> 
      </TD>
    </TR>
    <TR> 
      <TD height=36 colspan="2" vAlign=center bordercolor="#000000" bgColor=#000000 style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"><table width="810" border="0" cellspacing="0" cellpadding="0" >
          <!--DWLayoutTable-->
          <tr  align="center"> 
            <td width="100" height="8" valign="middle" background="images_rv042/UI_06.gif" style=""></td>
            <td width="80" valign="middle" background="images_rv042/UI_07.gif"style=""></td>
            <td width="70" valign="middle" background="images_rv042/UI_06.gif"style=""></td>
            <td width="110" valign="middle" background="images_rv042/UI_06.gif"style=""></td>
            <td width="80" valign="middle" background="images_rv042/UI_06.gif"style=""></td>
            <td width="60" valign="middle" background="images_rv042/UI_06.gif"style=""></td>
            <td width="60" valign="middle" background="images_rv042/UI_06.gif"style=""></td>
            <td width="80" valign="middle" background="images_rv042/UI_06.gif"style=""></td>
            <td width="85" valign="middle" background="images_rv042/UI_06.gif"style=""></td>
            <td width="85" valign="middle" background="images_rv042/UI_06.gif"style=""></td>
          </tr>
          <tr  align="center" valign="middle"> 
            <td height="28" bgcolor="#000000" style="border-style: none; border-width: medium; font-style:normal; font-variant:normal; font-weight:normal; font-size:10pt; color:black"> 
              <p align="center" style="margin-bottom: 4"> <b><a class="mainmenu" href="home.htm" style="font-size: 8pt; text-decoration: none; font-weight:700"> 
                System<br>
                Summary</a></b> </td>
            <td bgcolor="#6666CC" style="border-style: none; border-width: medium; font-style:normal; font-variant:normal; font-weight:normal; font-size:10pt; color:black"> 
              <p style="margin-top: 0; margin-bottom: 4"><b><font color="#FFFFFF" style="font-size: 8pt"> 
                Setup</font></b> </td>
            <td bgcolor="#000000" style="border-style: none; border-width: medium; font-style:normal; font-variant:normal; font-weight:normal; font-size:10pt; color:black"> 
              <p style="margin-bottom: 4"> <b> <a class="mainmenu" href="dhcp_setup.htm" style="font-size: 8pt; text-decoration: none; font-weight:700">DHCP</a></b> 
            </td>
            <td bgcolor="#000000" style="border-style: none; border-width: medium; font-style:normal; font-variant:normal; font-weight:normal; font-size:10pt; color:black"> 
              <p style="margin-bottom: 4"> <b> 
                <script>
          if (document.formdualwan.dualwanEnabled.value=="1") 
		  	  document.write(\'<a class="mainmenu" href="sys_dualwanw.htm" style="font-size: 8pt; text-decoration: none; font-weight:700">\');
          else document.write(\'<a class="mainmenu" href="sys_dualwan3.htm" style="font-size: 8pt; text-decoration: none; font-weight:700">\');
          </script>
                System<br>
                Management </a></b> </td>
            <td bgcolor="#000000" style="border-style: none; border-width: medium; font-style:normal; font-variant:normal; font-weight:normal; font-size:10pt; color:black"> 
              <p style="margin-bottom: 4"><b> <a class="mainmenu" href="f_general.htm" style="font-size: 8pt; text-decoration: none; font-weight:700"> 
                Firewall</a></b> </td>
            <td bgcolor="#000000" style="border-style: none; border-width: medium; font-style:normal; font-variant:normal; font-weight:normal; font-size:10pt; color:black"> 
              <p style="margin-bottom: 4"> <b> <a class="mainmenu" href="vpn_summary.htm" style="font-size: 8pt; text-decoration: none; font-weight:700">VPN</a></b> 
            </td>
            <td bgcolor="#000000" style="border-style: none; border-width: medium; font-style:normal; font-variant:normal; font-weight:normal; font-size:10pt; color:black"> 
              <p style="margin-bottom: 4"> <b> <a class="mainmenu" href="log_setting.htm" style="font-size: 8pt; text-decoration: none; font-weight:700">Log</a></b> 
            </td>
            <td bgcolor="#000000" style="border-style: none; border-width: medium; font-style:normal; font-variant:normal; font-weight:normal; font-size:10pt; color:black"> 
              <p style="margin-bottom: 4"> <b> <a class="mainmenu" href="wizard.htm" style="font-size: 8pt; text-decoration: none; font-weight:700">Wizard</a></b> 
            </td>
            <td bgcolor="#000000" style="border-style: none; border-width: medium; font-style:normal; font-variant:normal; font-weight:normal; font-size:10pt; color:black"> 
              <p style="margin-bottom: 4"> <b> <a class="mainmenu" href="support.htm" style="font-size: 8pt; text-decoration: none; font-weight:700">Support</a></b> 
            </td>
            <td bgcolor="#000000" style="border-style: none; border-width: medium; font-style:normal; font-variant:normal; font-weight:normal; font-size:10pt; color:black"> 
              <p style="margin-bottom: 4"> <b> <a class="mainmenu" href="javascript: window.close()" style="font-size: 8pt; text-decoration: none; font-weight:700">Logout</a></b> 
            </td>
          </tr>
        </table></TD>
    </TR>
    <TR> 
      <TD height=21 colspan="2" vAlign=center bordercolor="#000000" bgColor=#6666CC style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"><table width="810" border="0" cellspacing="0" cellpadding="0">
          <tr> 
            <td width="83" height="21" align="center"> <p align="center"> <span style="font-size: 8pt; background-color:#6666CC"> 
                <font color="#FFFFFF"> 
                <!--network
                <a class="submenu" href="network.htm" style="text-decoration: none"> 
                network-->
                Network 
                <!--network
                </a> 
                network-->
                </font> </span> </td>
            <td width="3" align="center"> <table border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse; border-left-style: solid; border-left-width: 2" bordercolor="#FFFFFF" id="AutoNumber14" height="10" width="3">
                <tr> 
                  <td width="1" height="12" align="center" valign="middle"></td>
                </tr>
              </table></td>
            <td width="85" align="center"> <p align="center"> <span style="font-size: 8pt; background-color:#6666CC"> 
                <font color="#FFFFFF"> 
                <!--password-->
                <a class="submenu" href="password.htm" style="text-decoration: none"> 
                <!--password-->
                Password 
                <!--password-->
                </a> 
                <!--password-->
                </font> </span> </td>
            <td width="3" align="center" > <table border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse; border-left-style: solid; border-left-width: 2" bordercolor="#FFFFFF" id="AutoNumber14" height="10" width="3">
                <tr> 
                  <td width="1" height="12" align="center" valign="middle"></td>
                </tr>
              </table></td>
            <td width="60" align="center"> <p align="center"> <span style="font-size: 8pt; background-color:#6666CC"> 
                <font color="#FFFFFF"> 
                <!--time-->
                <a class="submenu" href="time.htm" style="text-decoration: none"> 
                <!--time-->
                Time 
                <!--time-->
                </a> 
                <!--time-->
                </font> </span> </td>
            <td width="3" align="center" > <table border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse; border-left-style: solid; border-left-width: 2" bordercolor="#FFFFFF" id="AutoNumber14" height="10" width="3">
                <tr> 
                  <td width="1" height="12" align="center" valign="middle"></td>
                </tr>
              </table></td>
            <td width="85" align="center"> <p align="center"> <span style="font-size: 8pt; background-color:#6666CC"> 
                <font color="#FFFFFF"> 
                <!--adv_dmz-->
                <a class="submenu" href="adv_dmz.htm" style="text-decoration: none"> 
                <!--adv_dmz-->
                DMZ Host 
                <!--adv_dmz-->
                </a> 
                <!--adv_dmz-->
                </font> </span> </td>
            <td width="3" align="center" > <table border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse; border-left-style: solid; border-left-width: 2" bordercolor="#FFFFFF" id="AutoNumber14" height="10" width="3">
                <tr> 
                  <td width="1" height="12" align="center" valign="middle"></td>
                </tr>
              </table></td>
            <td width="90" align="center"> <p align="center"> <span style="font-size: 8pt; background-color:#6666CC"> 
                <font color="#FFFFFF"> 
                <!--adv_forwarding-->
                <a class="submenu" href="adv_forwarding.htm" style="text-decoration: none"> 
                <!--adv_forwarding-->
                Forwarding 
                <!--adv_forwarding-->
                </a> 
                <!--adv_forwarding-->
                </font> </span> </td>
            <td width="3" align="center" > <table border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse; border-left-style: solid; border-left-width: 2" bordercolor="#FFFFFF" id="AutoNumber14" height="10" width="3">
                <tr> 
                  <td width="1" height="12" align="center" valign="middle"></td>
                </tr>
              </table></td>
            <td width="60" align="center" > <p align="center"> <span style="font-size: 8pt; background-color:#6666CC"> 
                <font color="#FFFFFF"> 
                <!--adv_nat-->
                <a class="submenu" href="adv_upnp.htm" style="text-decoration: none"> 
                <!--adv_nat-->
                UPnP 
                <!--adv_nat-->
                </a> 
                <!--adv_nat-->
                </font> </span> </td>
            <td width="3" align="center" > <table border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse; border-left-style: solid; border-left-width: 2" bordercolor="#FFFFFF" id="AutoNumber14" height="10" width="3">
                <tr> 
                  <td width="1" height="12" align="center" valign="middle"></td>
                </tr>
              </table></td>
            <td width="125"> <p align="center"> <span style="font-size: 8pt; background-color:#6666CC"> 
                <font color="#FFFFFF"> 
                <!--adv_nat-->
                <a class="submenu" href="adv_nat.htm" style="text-decoration: none"> 
                <!--adv_nat-->
                One-to-One NAT 
                <!--adv_nat-->
                </a> 
                <!--adv_nat-->
                </font> </span> </td>
            <td width="3" > <table border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse; border-left-style: solid; border-left-width: 2" bordercolor="#FFFFFF" id="AutoNumber14" height="10" width="3">
                <tr> 
                  <td width="1" height="12" align="center" valign="middle"></td>
                </tr>
              </table></td>
            <td width="20" ><!--DWLayoutEmptyCell-->&nbsp;</td>
            <td width="47" > <a href="adv_mac.htm" style="text-decoration: none"> 
              <font color="#FFFFFF">More...</font></a> </td>
            <td width="20" > <b> <a href="adv_mac.htm" style="text-decoration: none; font-weight:700"><font color="#FFFFFF" style="font-size: 8pt">>></font></a></b> 
            </td>
            <td width="114">&nbsp;</td>
          </tr>
        </table></TD>
    </TR>
  </TABLE>
  <table height=5 cellspacing=0 cellpadding=0 width=960 bgcolor=black border=0>
    <tr bgcolor=black> 
      <td width=150 height=1 style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; font-family: Arial, Helvetica, sans-serif; color: black" bgcolor="#E7E7E7" bordercolor="#E7E7E7"> 
        <img border="0" src="images_rv042/UI_03.gif" width="150" height="15"></td>
      <td width=810 height=1 style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; font-family: Arial, Helvetica, sans-serif; color: black" bgcolor="#FFFFFF"> 
        <img border="0" src="images_rv042/UI_02.gif" width="810" height="15"></td>
    </tr>
  </table>
  <table border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse" bordercolor="#111111" id="AutoNumber9" width="961">
    <form name="formNetwork" action="network.htm" method="post">
      <tr> 
        <td height="25" bgcolor="#000000" bordercolor="#E7E7E7" bordercolorlight="#E7E7E7" bordercolordark="#E7E7E7" width="142"> 
          <div align="right"><font color="#FFFFFF" face="Arial, Helvetica, sans-serif"><b>Network</b></font></div>
        </td>
        <td width="8" valign="top" bgcolor="#000000">&nbsp;</td>
        <td width="20" valign="top" bgcolor="#FFFFFF">&nbsp;</td>
        <td width="620" valign="top" bgcolor="#FFFFFF"><font size="+0">&nbsp;</font><font size="+0">&nbsp;</font> 
          <div align="left"> </div>
        </td>
        <td width="20" valign="top" bgcolor="#FFFFFF" rowspan="6">&nbsp;</td>
        <td background="images_rv042/UI_05.gif" width="14" valign="top" rowspan="6">&nbsp;</td>
        <td width="136" rowspan="5" valign="top" bgcolor="#6666CC" align="right"> 
          <a href="javascript: openMap()"><img src="images_rv042/sitemap-off.jpg" width="136" height="28" border="0" onMouseOver="this.src=\'images_rv042/sitemap-on.jpg\'" onMouseOut="this.src=\'images_rv042/sitemap-off.jpg\'"></a> 
          <br><br> 
		  <div align="left"><font face="Arial" style="font-size: 8pt" color="#FFFFFF">
		  The Setup screen contains all of the router\'s basic setup functions. The device can be used in most network settings without changing any of the default values. Some users may need to enter additional information in order to connect to the Internet through an ISP (Internet Service Provider) or broadband (DSL, cable modem) carrier.
		  <br><br>
		    Host Name &amp; Domain Name:<br> Enter a host and domain name for the 
            Router. Some ISPs (Internet Service Providers) may require these names 
            as identification, and these settings can be obtained from your ISP. 
            In most cases, leaving these fields blank will work. 
            <br><br>LAN Setting:<br> This is the Router\'s LAN IP Address and Subnet Mask. 
              The default value is 192.168.1.1 for IP address and 255.255.255.0 
              for the Subnet Mask.

			  <br><br>
			 <a href="javascript: h_network();"><b><font face="Arial" style="font-size: 8pt" color="#FFFFFF">More...</font></b></a>  
             </font> 
          </div> 
		  </td>
        <td width="1"></td>
      </tr>
      <tr> 
        <td valign="top" bgcolor="#E7E7E7" bordercolor="#E7E7E7" bordercolorlight="#E7E7E7" bordercolordark="#E7E7E7">&nbsp;</td>
        <td background="images_rv042/UI_04.gif" valign="top">&nbsp;</td>
        <td valign="top" bgcolor="#FFFFFF">&nbsp;</td>
        <td valign="top" bgcolor="#FFFFFF"> 
          <input type=hidden name="page" value="network.htm">
          <input type=hidden name="submitStatus" value="1">
		  <input type=hidden name="clickDualwan" value="0">
		  <input type=hidden name="clickDmz" value="0">		
			  <input type=hidden name="LanIp" value=\'192.168.1.1\'>		  
			  <input type=hidden name="LanIp1" value=\'196\'>		  
			  <input type=hidden name="LanIp2" value=\'\'>		  
			  <input type=hidden name="LanIp3" value=\'\'>		  
			  <input type=hidden name="LanIp4" value=\'\'>		  
    	      <input type="hidden" name="dsPPTP1" value=\'192\'>
    	      <input type="hidden" name="dsPPTP2" value=\'168\'>
    	      <input type="hidden" name="dsPPTP3" value=\'1\'>
    	      <input type="hidden" name="dsPPTP4" value=\'200\'>
        	  <input type="hidden" name="dePPTP4" value=\'204\'>		  		  
              <input type=hidden name="dsDHCP1" value=\'192\'>
              <input type=hidden name="dsDHCP2" value=\'168\'>
              <input type=hidden name="dsDHCP3" value=\'1\'>				
              <input type=hidden name="dsDHCP4" value=\'29\'>
			  <input type=hidden name="deDHCP4" value=\'254\'>
			  <input type=hidden name="netMaskAll" value=\'255.255.255.0\'>
			  <input type=hidden name="netMaskIp1" value=\'\'>
			  <input type=hidden name="netMaskIp2" value=\'\'>
			  <input type=hidden name="netMaskIp3" value=\'\'>
			  <input type=hidden name="netMaskIp4" value=\'\'>
		  	  <input type=hidden name="DhcpEnabled1" value=\' checked\'>
			  <input type="hidden" name="PPTPEnabled" value=\' \'>
  
          <!--way2-->
<br>
          <table border="0" align="center" width="98%">
            <tr> 
              <td width="83" height="30" nowrap>&nbsp;</td>
              <td width="130" height="30" nowrap> 
                <div align="right"><font face="Arial Unicode MS" color="#0000FF"><b>Host 
                  Name:</b></font></div>
              </td>
              <td width="353" height="30" nowrap><font face="Arial Unicode MS"> 
                <input type="text" name="hostname" maxlength="31" size="20" value=\'Linksys\' onFocus="this.select();" onBlur="sTrim(this);">
                </font><font size="-2"><b><font face="Arial Unicode MS"> (Required 
                by some ISPs)</font></b></font><b> </b> </td>
            </tr>
            <tr> 
              <td height="35" nowrap>&nbsp;</td>
              <td height="35" nowrap> 
                <div align="right"><font face="Arial Unicode MS" color="#0000FF"><b>Domain 
                  Name:</b></font></div>
              </td>
              <td height="35" nowrap><font face="Arial Unicode MS"> 
                <input type="text" name="DomainName" maxlength="63" size="20" value=\'\' onFocus="this.select();" onBlur="sTrim(this);">
                <b><font size="-2">(Required by some ISPs)</font></b></font> </td>
            </tr>
          </table>
          <br>
          <hr align="center" size="1" color="#b5b5e6" noshade>
        </td>
        <td></td>
      </tr>
      <tr> 
        <td valign="top" bgcolor="#E7E7E7" bordercolor="#E7E7E7" bordercolorlight="#E7E7E7" bordercolordark="#E7E7E7"> 
          <div align="right"><font face="Arial, Helvetica, sans-serif"><b>LAN 
            Setting</b></font></div>
        </td>
        <td background="images_rv042/UI_04.gif" valign="top">&nbsp;</td>
        <td valign="top" bgcolor="#FFFFFF">&nbsp;</td>
        <td valign="top" bgcolor="#FFFFFF"> <br>
          <table cellspacing="0" border="0" align="center" width="98%">
            <tr> 
              <td nowrap height="20" width="57"> 
                <center>
                  <font face="Arial Unicode MS" size="2"> </font> 
                </center>
              </td>
              <td colspan="2" height="20" nowrap> 
                <div align="center"><font face="Arial Unicode MS" color="blue" size="1"><b><font size="-2">(MAC 
                  Address: 
                  00-14-bf-81-9e-a6
                  )</font></b></font><font face="Arial Unicode MS" size="-2"></font></div>
              </td>
              <td nowrap height="20" width="55">&nbsp;</td>
            </tr>
            <tr> 
              <td height="3" nowrap></td>
              <td width="230" height="0" nowrap> 
                <div align="center"><font face="Arial Unicode MS" color="blue"><b>Device 
                  IP Address</b></font></div>
              </td>
              <td height="0" width="230" nowrap> 
                <div align="center"><font face="Arial Unicode MS" color="blue"><b>Subnet 
                  Mask</b></font></div>
              </td>
              <td height="0" nowrap>&nbsp;</td>
            </tr>
            <tr> 
              <td height="20" nowrap></td>
              <td height="20" nowrap> 
                <div align="center"><font face="Arial Unicode MS"> 
                  <input type="text" name="ipAddr1" value=\'192\' maxlength="3" size="3" onFocus="this.select();" onBlur=" IPCheck(this);">
                  . 
                  <input type="text" name="ipAddr2" value=\'168\' maxlength="3" size="3" onFocus="this.select();" onBlur=" IPCheck(this);">
                  . 
                  <input type="text" name="ipAddr3" value=\'1\' maxlength="3" size="3" onFocus="this.select();" onBlur=" IPCheck(this);">
                  . 
                  <input type="text" name="ipAddr4" value=\'1\' maxlength="3" size="3" onFocus="this.select();" onBlur=" IP1to254Check(this);">
                  </font></div>
              </td>
              <td height="20" nowrap> 
                <div align="center"> <font face="Arial Unicode MS"> 
                  <select name="netMask" size="1"><option value="0" 
                     selected>255.255.255.0</option>
                    <option value="128"  
                     >255.255.255.128</option> <option value="192"  
                     >255.255.255.192</option> <option value="224"  
                     >255.255.255.224</option> <option value="240"  
                     >255.255.255.240</option> <option value="248"  
                     >255.255.255.248</option> <option value="252"  
                     >255.255.255.252</option> 
                  </select>
                  </font></div>
              </td>
              <td height="20" nowrap>&nbsp;</td>
            </tr>
          </table><br>
		  <table cellspacing="0" border="0" align="center" width="98%">
		    <tr> 
              <td nowrap height="20" width="57"> 
                <center>
                  <font face="Arial Unicode MS" size="2"> </font> 
                </center>
              </td>
              <td colspan="2" height="20" nowrap> 
                <div align="center"><b>Multiple Subnet Setting</b></div>
              </td>
              <td nowrap height="20" width="55">&nbsp;</td>
            </tr>
            <tr> 
              <td nowrap height="20" width="57"> 
                <center>
                  <font face="Arial Unicode MS" size="2"> </font> 
                </center>
              </td>
              <td height="20" nowrap> 
                <div align="center">
                  <input type="checkbox" name="MLanSetting" value="checkbox" disabled >
                  <b>Multiple Subnet
                  &nbsp;&nbsp;&nbsp;<input type="button" name="Button" value="Add / Edit" onClick="openMLan()">
                  </b></div>
              </td>
              <td height="20" nowrap>&nbsp; </td>
              <td nowrap height="20" width="55">&nbsp;</td>
            </tr>
            <tr> 
              <td height="3" nowrap></td>
              <td width="230" height="0" nowrap> 
                <div align="center"></div>
              </td>
              <td height="0" width="230" nowrap> 
                <div align="center"></div>
              </td>
              <td height="0" nowrap>&nbsp;</td>
            </tr>
          </table>
<a name="0"></a>			  
          <br>
          <hr align="center" size="1" color="#b5b5e6" noshade>
          <br>
        </td>
        <td rowspan="2"></td>
      </tr>
      <tr> 
        <td valign="top" bgcolor="#E7E7E7" bordercolor="#E7E7E7" bordercolorlight="#E7E7E7" bordercolordark="#E7E7E7" align="right"><b><font face="Arial, Helvetica, sans-serif">Dual-WAN 
          / DMZ Setting</font></b></td>
        <td background="images_rv042/UI_04.gif" valign="top">&nbsp;</td>
        <td valign="top" bgcolor="#FFFFFF">&nbsp;</td>
        <td valign="top" bgcolor="#FFFFFF">
			
          <table width="98%" align="center">
            <tr> 
              <td width="34%">&nbsp;</td>
              <td width="19%"><b><font face="Arial Unicode MS"> 
                <input type="radio" value="1" name="wan_dmz" onClick="this.form.clickDualwan.value=\'1\'; enableWANType();"  >
                Dual WAN</font></b></td>
              <td width="15%"><b><font face="Arial Unicode MS"> 
                <input type="radio" value="0" name="wan_dmz" onClick="this.form.clickDmz.value=\'1\'; onlyStatic();"  checked>
                </font><font face="Arial Unicode MS" size="2"> </font><font face="Arial Unicode MS">DMZ</font></b></td>
              <td width="32%">&nbsp;</td>
            </tr>
          </table>
          <br>
          <hr align="center" size="1" color="#b5b5e6" noshade>
		  <br>		
		</td>
      </tr>
      <tr> 
        <td valign="top" bgcolor="#E7E7E7" bordercolor="#E7E7E7" bordercolorlight="#E7E7E7" bordercolordark="#E7E7E7" rowspan="2"> 
          <div align="right"><font face="Arial, Helvetica, sans-serif"><b>WAN 
            Connection Type</b></font></div>
        </td>
        <td background="images_rv042/UI_04.gif" valign="top" rowspan="2">&nbsp;</td>
        <td valign="top" bgcolor="#FFFFFF" rowspan="2">&nbsp;</td>
        <td valign="top" bgcolor="#FFFFFF" rowspan="2"> 
          <div align="center"><b><font color="#0000FF" face="Arial, Helvetica, sans-serif">
<script>
if (document.formNetwork.wan_dmz[0].checked) document.write("WAN1");
else document.write("WAN");
</script>
		  </font></b> 
          </div>
<a name="1"></a>		  
          <p align="center"> <font face="Arial Unicode MS"> 
            <select name="WAN1ConnectionType" onChange="falseSubmit(this.form,\'1\')"><option value="1"  
               >Obtain an IP automatically</option> <option value="2"  
               selected>Static IP</option>
              <option value="3"  
               >PPPoE</option>
              <option value="4"  
               >PPTP</option>
			   
			  <option value="8"  >Heart Beat Signal</option>
                             
            </select>
            </font><font face="Arial Unicode MS" color="red" size="2">&nbsp;&nbsp;</font></p>
          <!--
          <table width="98%" align="center">
            <tr> 
              <td colspan="2" height="24"> 
                <div align="center"> 
                  <input type=hidden name=Wan1DnsNeq value=0>
                  <input type="checkbox" name="setWan1DNS" value="1" onClick="chsetDNS();"  checked>
                  <b>Use the Following DNS Server Addresses:</b></div>
              </td>
            </tr>
            <tr> 
              <td align="right" nowrap width="38%"> 
                <p align="right"><font face="Arial Unicode MS"><b> DNS Server 
                  (Required) 1:</b></font> 
              </td>
              <td nowrap width="62%"> 
                <div align="left"><font face="Arial Unicode MS"> 
                  <input type="text" name="Wan1DnsA1" value=\'10\' maxlength="3" size="3" onFocus="this.select();" onBlur=" IPCheck(this)">
                  . 
                  <input type="text" name="Wan1DnsA2" value=\'10\' maxlength="3" size="3" onFocus="this.select();" onBlur=" IPCheck(this)">
                  . 
                  <input type="text" name="Wan1DnsA3" value=\'1\' maxlength="3" size="3" onFocus="this.select();" onBlur=" IPCheck(this)">
                  . 
                  <input type="text" name="Wan1DnsA4" value=\'9\' maxlength="3" size="3" onFocus="this.select();" onBlur=" IP0to254Check(this)">
                  </font></div>
              </td>
            </tr>
            <tr> 
              <td align="right" nowrap width="38%" height="11"> 
                <div align="right"><font face="Arial Unicode MS"><b>2:</b></font></div>
              </td>
              <td nowrap width="62%" height="11"> 
                <div align="left"><font face="Arial Unicode MS"> 
                  <input type="text" name="Wan1DnsB1" value=\'10\' maxlength="3" size="3" onFocus="this.select();" onBlur=" IPCheck(this)">
                  . 
                  <input type="text" name="Wan1DnsB2" value=\'10\' maxlength="3" size="3" onFocus="this.select();" onBlur=" IPCheck(this)">
                  . 
                  <input type="text" name="Wan1DnsB3" value=\'1\' maxlength="3" size="3" onFocus="this.select();" onBlur=" IPCheck(this)">
                  . 
                  <input type="text" name="Wan1DnsB4" value=\'9\' maxlength="3" size="3" onFocus="this.select();" onBlur=" IP0to254Check(this)">
                  </font></div>
              </td>
            </tr>
          </table>
          <p> 
            -->
             
          </p>
          <table align="center" width="98%">
            <tr> 
              <td align="right" nowrap width="38%"> 
                <div align="right"><font face="Arial Unicode MS">&nbsp;&nbsp;&nbsp;&nbsp;<b>Specify 
                  WAN IP Address:</b></font></div>
              </td>
              <td nowrap width="62%"> 
                <div align="left"><font face="Arial Unicode MS"> 
                  <input type="text" name="Wan1AliasIp1" value=\'10\' maxlength="3" size="3" onFocus="this.select();" onBlur=" IPCheck(this); setDmzRange()">
                  . 
                  <input type="text" name="Wan1AliasIp2" value=\'100\' maxlength="3" size="3" onFocus="this.select();" onBlur=" IPCheck(this); setDmzRange()">
                  . 
                  <input type="text" name="Wan1AliasIp3" value=\'4\' maxlength="3" size="3" onFocus="this.select();" onBlur=" IPCheck(this); setDmzRange()">
                  . 
                  <input type="text" name="Wan1AliasIp4" value=\'40\' maxlength="3" size="3" onFocus="this.select();" onBlur=" IP0to254Check(this)">
                  </font></div>
              </td>
            </tr>
            <tr> 
              <td align="right" nowrap width="38%"> 
                <div align="right"> 
                  <ul>
                  </ul>
                </div>
                <p align="right"><font face="Arial Unicode MS"><b>Subnet Mask:</b></font></p>
              </td>
              <td nowrap width="62%"> 
                <div align="left"><font face="Arial Unicode MS"> 
                  <input type="text" name="Wan1AliasMaskIp1" value=\'255\' maxlength="3" size="3" onFocus="this.select();" onBlur=" MKCheck(this)">
                  . 
                  <input type="text" name="Wan1AliasMaskIp2" value=\'255\' maxlength="3" size="3" onFocus="this.select();" onBlur=" MKCheck(this)">
                  . 
                  <input type="text" name="Wan1AliasMaskIp3" value=\'255\' maxlength="3" size="3" onFocus="this.select();" onBlur=" MKCheck(this)">
                  . 
                  <input type="text" name="Wan1AliasMaskIp4" value=\'0\' maxlength="3" size="3" onFocus="this.select();" onBlur=" MKCheck(this)">
                  </font></div>
              </td>
            </tr>
            <tr> 
              <td align="right" nowrap width="38%" height="13"> 
                <div align="right"> 
                  <ul>
                  </ul>
                </div>
                <p align="right"><font face="Arial Unicode MS"><b>Default Gateway 
                  Address:</b></font></p>
              </td>
              <td nowrap width="62%" height="13"> 
                <div align="left"><font face="Arial Unicode MS"> 
                  <input type="text" name="Wan1RouterIp1" value=\'10\' maxlength="3" size="3" onFocus="this.select();" onBlur=" IPCheck(this)">
                  . 
                  <input type="text" name="Wan1RouterIp2" value=\'100\' maxlength="3" size="3" onFocus="this.select();" onBlur=" IPCheck(this)">
                  . 
                  <input type="text" name="Wan1RouterIp3" value=\'4\' maxlength="3" size="3" onFocus="this.select();" onBlur=" IPCheck(this)">
                  . 
                  <input type="text" name="Wan1RouterIp4" value=\'1\' maxlength="3" size="3" onFocus="this.select();" onBlur=" IP0to254Check(this)">
                  </font></div>
              </td>
            </tr>
            <tr> 
              <td align="right" nowrap width="38%" height="8"> 
                <p align="right"><font face="Arial Unicode MS"><b> DNS Server 
                  (Required) 1:</b></font> 
              </td>
              <td nowrap width="62%" height="8"> 
                <div align="left"><font face="Arial Unicode MS"> 
                  <input type="text" name="Wan1DnsA1" value=\'10\' maxlength="3" size="3" onFocus="this.select();" onBlur=" IPCheck(this)">
                  . 
                  <input type="text" name="Wan1DnsA2" value=\'10\' maxlength="3" size="3" onFocus="this.select();" onBlur=" IPCheck(this)">
                  . 
                  <input type="text" name="Wan1DnsA3" value=\'1\' maxlength="3" size="3" onFocus="this.select();" onBlur=" IPCheck(this)">
                  . 
                  <input type="text" name="Wan1DnsA4" value=\'9\' maxlength="3" size="3" onFocus="this.select();" onBlur=" IP0to254Check(this)">
                  </font></div>
              </td>
            </tr>
            <tr> 
              <td align="right" nowrap width="38%" height="6"> 
                <div align="right"><font face="Arial Unicode MS"><b>2:</b></font></div>
              </td>
              <td nowrap width="62%" height="6"> 
                <div align="left"><font face="Arial Unicode MS"> 
                  <input type="text" name="Wan1DnsB1" value=\'10\' maxlength="3" size="3" onFocus="this.select();" onBlur=" IPCheck(this)">
                  . 
                  <input type="text" name="Wan1DnsB2" value=\'10\' maxlength="3" size="3" onFocus="this.select();" onBlur=" IPCheck(this)">
                  . 
                  <input type="text" name="Wan1DnsB3" value=\'1\' maxlength="3" size="3" onFocus="this.select();" onBlur=" IPCheck(this)">
                  . 
                  <input type="text" name="Wan1DnsB4" value=\'9\' maxlength="3" size="3" onFocus="this.select();" onBlur=" IP0to254Check(this)">
                  </font></div>
              </td>
            </tr>
          </table>
          <p> 
             
            <!--
          </p>
          <table align="center" width="98%">
            <tr> 
              <td align="right" nowrap width="22%"> 
                <div align="right"><font size="2" face="Arial Unicode MS">&nbsp;&nbsp;&nbsp;&nbsp;</font><font face="Arial Unicode MS"><b></b></font></div>
              </td>
              <td nowrap width="16%"> 
                <div align="right"><font face="Arial Unicode MS"><b>User Name:</b></font></div>
              </td>
              <td nowrap width="62%"> 
                <input type="text" name="Wan1UserName" value=\'\' size="20" maxlength="60"  onFocus="this.select();" onBlur="sTrim(this);">
              </td>
            </tr>
            <tr> 
              <td align="right" height="11" nowrap width="22%"> 
                <div align="right"> </div>
                <p align="right"><b></b></p>
              </td>
              <td height="11" nowrap width="16%"> 
                <div align="right"><b><font face="Arial Unicode MS">Password:</font></b></div>
              </td>
              <td height="11" nowrap width="62%"> 
                <input type="password" name="Wan1PassWord" value=\'\' size="20" maxlength="60"  onFocus="this.select();" onBlur="sTrim(this);">
              </td>
            </tr>
            <tr> 
              <td align="right" height="11" nowrap width="22%"> 
                <div align="right"> </div>
                <p align="right"><b></b></p>
              </td>
              <td height="11" nowrap width="16%"> 
                <div align="right"><b><font face="Arial Unicode MS">Service Name:</font></b></div>
              </td>
              <td height="11" nowrap width="62%"> 
                <input type="text" name="Wan1ServiceName" value=\'\' size="20" maxlength="60"  onFocus="this.select();" onBlur="sTrim(this);">
              </td>
            </tr>
            <tr> 
              <td align="right" nowrap width="22%"> 
                <p align="left"><font face="Arial, Helvetica, sans-serif"> </font> 
              </td>
              <td align="right" colspan="2" nowrap> 
                <div align="left"><font face="Arial, Helvetica, sans-serif"> 
                  <input type="radio" name=Wan1ConnectAlive value="1"  checked>
                  <b><font face="Arial Unicode MS">Connect on Demand: Max Idle 
                  Time</font></b> 
                  <input type="text" name=Wan1IdleTime value=\'5\' size="5" maxlength="5" onFocus="this.select();" onBlur=" minCheck(this)">
                  <b><font face="Arial Unicode MS">Min.</font></b></font> <font face="Arial, Helvetica, sans-serif"> 
                  </font><font face="Arial, Helvetica, sans-serif"> </font></div>
              </td>
            </tr>
            <tr> 
              <td align="right" nowrap width="22%"> 
                <div align="left"><font face="Arial Unicode MS" size="2"> <b> 
                  </b></font></div>
              </td>
              <td align="right" colspan="2" nowrap> 
                <div align="left"><font face="Arial Unicode MS" size="2"> 
                  <input type="radio" name=Wan1ConnectAlive value="2"  >
</font><font face="Arial Unicode MS"><b>Keep Alive: Interval
					       <input type="text" name="wan1_echo_interval" maxlength=4 size=4 onFocus="this.select();" onBlur=" EchoCheck(this, \'interval\')" value=\'30\'> Sec.
										 
                </b></font>                  </font></div>
              </td>
            </tr>
          </table>
		  <table align="center" width="98%">
            <tr> 
              <td align="right" nowrap width="22%"> 
                <div align="left"><font face="Arial Unicode MS"><b> 
                  </b></font></div>
              </td>
			  <td align="right" nowrap width="4%"> 
                <p align="left"><font face="Arial, Helvetica, sans-serif"> </font> 
              </td>
              <td align="right" nowrap width="74%"> 
                <div align="left"><font face="Arial Unicode MS"><b> 
                    Keep Alive: Retry Times
					      <input type="text" name="wan1_echo_failure" maxlength=2 size=2 onFocus="this.select();" onBlur=" EchoCheck(this, \'failure\')" value=\'5\'> Times
					
                </b></font></div>
              </td>
            </tr>
            <tr> 
              <td align="right" nowrap width="22%"> 
                <p align="left"><font face="Arial, Helvetica, sans-serif"> </font> 
              </td>
			  <td align="right" nowrap width="4%"> 
                <p align="left"><font face="Arial, Helvetica, sans-serif"> </font> 
              </td>
              <td align="right" nowrap width="74%">
                <div align="left">
<font face="Arial Unicode MS"><b>Keep Alive: Redail Period</b></font><font face="Arial Unicode MS" size="2"><b> 
                  <input type="text" name=Wan1RedialTime value=\'30\' size="7" maxlength="7" onFocus="this.select();" onBlur=" secCheck(this)">
                  </b></font><font face="Arial Unicode MS"><b> Sec.</b> </font></div>
              </td>
            </tr>

          </table> 		
          <p>
            -->
            <!--
          </p>
          <table align="center" width="98%">
            <tr>
              <td align="right" nowrap width="33">
                <div align="right"><font size="2" face="Arial Unicode MS">&nbsp;&nbsp;&nbsp;&nbsp;</font><font face="Arial Unicode MS"><b></b></font></div>
              </td>
              <td colspan="2" nowrap>
                <div align="right"><font face="Arial Unicode MS"><b>Specify WAN
                  IP Address:</b></font></div>
              </td>
              <td nowrap width="356">
                <input type="text" name="Wan1AliasIp1" value=\'10\' size="3" maxlength="3" onFocus="this.select();" onBlur=" IPCheck(this)">
                .
                <input type="text" name="Wan1AliasIp2" value=\'100\' size="3" maxlength="3" onFocus="this.select();" onBlur=" IPCheck(this)">
                .
                <input type="text" name="Wan1AliasIp3" value=\'4\' size="3" maxlength="3" onFocus="this.select();" onBlur=" IPCheck(this)">
                .
                <input type="text" name="Wan1AliasIp4" value=\'40\' size="3" maxlength="3" onFocus="this.select();" onBlur=" IP0to254Check(this)">
              </td>
            </tr>
            <tr>
              <td align="right" nowrap width="33" height="15">&nbsp;</td>
              <td colspan="2" nowrap height="15">
                <div align="right"><font face="Arial Unicode MS"><b>Subnet Mask:</b></font></div>
              </td>
              <td nowrap width="356" height="15">
                <input type="text" name="Wan1AliasMaskIp1" value=\'255\' size="3" maxlength="3" onFocus="this.select();" onBlur=" MKCheck(this)">
                .
                <input type="text" name="Wan1AliasMaskIp2" value=\'255\' size="3" maxlength="3" onFocus="this.select();" onBlur=" MKCheck(this)">
                .
                <input type="text" name="Wan1AliasMaskIp3" value=\'255\' size="3" maxlength="3" onFocus="this.select();" onBlur=" MKCheck(this)">
                .
                <input type="text" name="Wan1AliasMaskIp4" value=\'0\' size="3" maxlength="3" onFocus="this.select();" onBlur=" MKCheck(this)">
              </td>
            </tr>
            <tr>
              <td align="right" nowrap width="33">&nbsp;</td>
              <td colspan="2" nowrap>
                <div align="right"><font face="Arial Unicode MS"><b>Default Gateway
                  Address:</b></font></div>
              </td>
              <td nowrap width="356">
                <input type="text" name="Wan1RouterIp1" value=\'10\' size="3" maxlength="3" onFocus="this.select();" onBlur=" IPCheck(this)">
                .
                <input type="text" name="Wan1RouterIp2" value=\'100\' size="3" maxlength="3" onFocus="this.select();" onBlur=" IPCheck(this)">
                .
                <input type="text" name="Wan1RouterIp3" value=\'4\' size="3" maxlength="3" onFocus="this.select();" onBlur=" IPCheck(this)">
                .
                <input type="text" name="Wan1RouterIp4" value=\'1\' size="3" maxlength="3" onFocus="this.select();" onBlur=" IP0to254Check(this)">
              </td>
            </tr>
            <tr>
              <td align="right" height="24" nowrap width="33">&nbsp;</td>
              <td height="24" colspan="2" nowrap>
                <div align="right"><font face="Arial Unicode MS"><b>User Name:</b></font></div>
              </td>
              <td height="24" nowrap width="356">
                <input type="text" name="Wan1UserName" value=\'\' size="20" maxlength="60"  onFocus="this.select();" onBlur="sTrim(this);">
              </td>
            </tr>
            <tr>
              <td align="right" height="8" nowrap width="33">
                <div align="right"> </div>
                <p align="right"><b></b></p>
              </td>
              <td height="8" colspan="2" nowrap>
                <div align="right"><b><font face="Arial Unicode MS">Password:</font></b></div>
              </td>
              <td height="8" nowrap width="356">
                <input type="password" name="Wan1PassWord" value=\'\' size="20" maxlength="60"   onFocus="this.select();" onBlur="sTrim(this);">
              </td>
            </tr>
            <tr>
              <td align="right" colspan="2" height="66" rowspan="2">
                <p align="left">
              </td>
              <td align="right" colspan="2" nowrap>
                <div align="left"><font face="Arial, Helvetica, sans-serif">
                  <input type="radio" name=Wan1ConnectAlive value="1"  checked>
                  <b><font face="Arial Unicode MS">Connect on Demand: Max Idle
                  Time</font></b>
                  <input type="text" name=Wan1IdleTime value=\'5\' size="5" maxlength="5" onFocus="this.select();" onBlur=" minCheck(this)">
                  <b><font face="Arial Unicode MS">Min.</font></b></font> <font face="Arial, Helvetica, sans-serif">
                  </font><font face="Arial, Helvetica, sans-serif"> </font></div>
              </td>
            </tr>
            <tr>
              <td align="right" colspan="2" nowrap height="11">
                <div align="left"><font face="Arial Unicode MS" size="2">
                  <input type="radio" name=Wan1ConnectAlive value="2"  >
                  </font><font face="Arial Unicode MS"><b>Keep Alive: Redial Period</b></font><font face="Arial Unicode MS" size="2"><b>
                  <input type="text" name=Wan1RedialTime value=\'30\' size="7" maxlength="7" onFocus="this.select();" onBlur=" secCheck(this)">
                  </b></font><font face="Arial Unicode MS"><b> Sec.</b> </font></div>
              </td>
            </tr>
          </table>
          -->
		  <!--  
          
          <table align="center" width="98%">
            <tr> 
              <td align="right" nowrap width="22%"> 
                <div align="right"><font size="2" face="Arial Unicode MS">&nbsp;&nbsp;&nbsp;&nbsp;</font><font face="Arial Unicode MS"><b></b></font></div>
              </td>
              <td nowrap width="20%"> 
                <div align="right"><font face="Arial Unicode MS"><b>User Name:</b></font></div>
              </td>
              <td nowrap width="58%"> 
                <input type="text" name="Wan1HBSUserName" value=\'\' size="20" maxlength="60"  onFocus="this.select();" onBlur="sTrim(this);">
              </td>
            </tr>
            <tr> 
              <td align="right" height="11" nowrap width="22%"> 
                <div align="right"> </div>
                <p align="right"><b></b></p>
              </td>
              <td height="11" nowrap width="20%"> 
                <div align="right"><b><font face="Arial Unicode MS">Password:</font></b></div>
              </td>
              <td height="11" nowrap width="58%"> 
                <input type="password" name="Wan1HBSPassWord" value=\'\' size="20" maxlength="60"  onFocus="this.select();" onBlur="sTrim(this);">
              </td>
            </tr>		             
			<tr> 
              <td align="right" nowrap width="22%"> 
                <div align="right"><font size="2" face="Arial Unicode MS">&nbsp;&nbsp;&nbsp;&nbsp;</font><font face="Arial Unicode MS"><b></b></font></div>
              </td>
              <td nowrap width="20%"> 
                <div align="right"><font face="Arial Unicode MS"><b>Heart Beat Server:</b></font></div>
              </td>
              <td nowrap width="58%"> 
                <input type="text" name="Wan1HBSServer" value=\'\' size="20" maxlength="60"  onFocus="this.select();" onBlur="sTrim(this);">
              </td>
            </tr>                     
          </table>
          <p> 
           -->
          <p><br>
          </p>
          <div align="center"><b><font color="#0000FF" face="Arial, Helvetica, sans-serif">
<script>
if (document.formNetwork.wan_dmz[0].checked) document.write("WAN2");
else document.write("DMZ");
</script>
		  </font></b></div>
<a name="2"></a>		  
          <p align="center"> <font face="Arial Unicode MS"> 
            <select name="WAN2ConnectionType" onChange="falseSubmit(this.form,\'2\')"><option value="1"  
               >Obtain an IP automatically</option> <option value="2"  
               selected>Static IP</option>
              <option value="3"  
               >PPPoE</option>
              <option value="4"  
               >PPTP</option>
			   
			  <option value="8"  >Heart Beat Signal</option>
                             
            </select>
            </font><font face="Arial Unicode MS" color="red" size="2">&nbsp;&nbsp;</font></p>
          <!--
          <div align="center"></div>
          <p></p>
          <table width="98%" align="center">
            <tr> 
              <td colspan="2" height="19"> 
                <div align="center"> 
                  <input type=hidden name=Wan2DnsNeq value=0>
                  <input type="checkbox" name="setWan2DNS" value="1" onClick="chsetDNS();"  checked>
                  <b>Use the Following DNS Server Addresses:</b></div>
              </td>
            </tr>
            <tr> 
              <td align="right" nowrap width="38%" height="8"> 
                <p align="right"><font face="Arial Unicode MS"><b> DNS Server 
                  (Required) 1:</b></font> 
              </td>
              <td nowrap width="62%" height="8"> 
                <div align="left"><font face="Arial Unicode MS"> 
                  <input type="text" name="Wan2DnsA1" value=\'0\' maxlength="3" size="3" onFocus="this.select();" onBlur=" IPCheck(this)">
                  . 
                  <input type="text" name="Wan2DnsA2" value=\'0\' maxlength="3" size="3" onFocus="this.select();" onBlur=" IPCheck(this)">
                  . 
                  <input type="text" name="Wan2DnsA3" value=\'0\' maxlength="3" size="3" onFocus="this.select();" onBlur=" IPCheck(this)">
                  . 
                  <input type="text" name="Wan2DnsA4" value=\'0\' maxlength="3" size="3" onFocus="this.select();" onBlur=" IP0to254Check(this)">
                  </font></div>
              </td>
            </tr>
            <tr> 
              <td align="right" nowrap width="38%" height="16"> 
                <div align="right"><font face="Arial Unicode MS"><b>2:</b></font></div>
              </td>
              <td nowrap width="62%" height="16"> 
                <div align="left"><font face="Arial Unicode MS"> 
                  <input type="text" name="Wan2DnsB1" value=\'0\' maxlength="3" size="3" onFocus="this.select();" onBlur=" IPCheck(this)">
                  . 
                  <input type="text" name="Wan2DnsB2" value=\'0\' maxlength="3" size="3" onFocus="this.select();" onBlur=" IPCheck(this)">
                  . 
                  <input type="text" name="Wan2DnsB3" value=\'0\' maxlength="3" size="3" onFocus="this.select();" onBlur=" IPCheck(this)">
                  . 
                  <input type="text" name="Wan2DnsB4" value=\'0\' maxlength="3" size="3" onFocus="this.select();" onBlur=" IP0to254Check(this)">
                  </font></div>
              </td>
            </tr>
          </table>
          -->
		   
		  <table width="98%" align="center">
            <tr> 
              <td width="34%">&nbsp;</td>
              <td width="19%"><b><font face="Arial Unicode MS"> 
                <input type="radio" value="0" name="DmzSubnetRange" onClick="falseSubmit(document.formNetwork,\'2\')"  checked>
                Subnet</font></b></td>
              <td width="45%"><b><font face="Arial Unicode MS"> 
                <input type="radio" value="1" name="DmzSubnetRange" onClick="falseSubmit(document.formNetwork,\'2\')"  >
                </font><font face="Arial Unicode MS" size="2"> </font><font face="Arial Unicode MS">Range &nbsp;</font></b>(DMZ & WAN within same subnet)</td>
              <td width="2%">&nbsp;</td>
            </tr>
          </table>
		   
		  
		  <!--
		  <table width="98%" align="center">
		    
		    <tr> 
              <td align="right" nowrap width="38%"> 
                <div align="right"><font face="Arial Unicode MS">&nbsp;&nbsp;&nbsp;&nbsp;<b>IP Range for DMZ port:</b></font></div>
              </td>
              <td nowrap width="62%"> 
                <div align="left"><font face="Arial Unicode MS"> 
                  <input type="text" name="Wan2DmzIp1" value=\'0\' maxlength="3" size="3" style="background-color: #cccccc" readOnly>
                  . 
                  <input type="text" name="Wan2DmzIp2" value=\'0\' maxlength="3" size="3" style="background-color: #cccccc" readOnly>
                  . 
                  <input type="text" name="Wan2DmzIp3" value=\'0\' maxlength="3" size="3" style="background-color: #cccccc" readOnly>
                  . 
                  <input type="text" name="Wan2DmzIp4" value=\'0\' maxlength="3" size="3" onFocus="this.select();" onBlur=" IP0to254Check(this)">
				  to
				  <input type="text" name="Wan2DmzIp5" value=\'0\' maxlength="3" size="3" onFocus="this.select();" onBlur=" IP0to254Check(this)">
                  </font></div>
              </td>
            </tr>
		  </table>
		  -->
           
          <table align="center" width="98%">
            <tr> 
              <td align="right" nowrap width="38%"> 
                <div align="right"><font face="Arial Unicode MS">&nbsp;&nbsp;&nbsp;&nbsp;<b>
<script>
if (document.formNetwork.wan_dmz[1].checked)
 document.write("Specify DMZ IP Address:");
else if ((document.formNetwork.wan_dmz[0].checked) && (document.formNetwork.WAN2ConnectionType.selectedIndex==1))
 document.write("Specify WAN IP Address:");
</script>	
				</b></font></div>
              </td>
              <td nowrap width="62%"> 
                <div align="left"><font face="Arial Unicode MS"> 
                  <input type="text" name="Wan2AliasIp1" value=\'0\' maxlength="3" size="3" onFocus="this.select();" onBlur=" IPCheck(this)">
                  . 
                  <input type="text" name="Wan2AliasIp2" value=\'0\' maxlength="3" size="3" onFocus="this.select();" onBlur=" IPCheck(this)">
                  . 
                  <input type="text" name="Wan2AliasIp3" value=\'0\' maxlength="3" size="3" onFocus="this.select();" onBlur=" IPCheck(this)">
                  . 
                  <input type="text" name="Wan2AliasIp4" value=\'0\' maxlength="3" size="3" onFocus="this.select();" onBlur=" IP0to254Check(this)">
                  </font></div>
              </td>
            </tr>
            <tr> 
              <td align="right" nowrap width="38%"> 
                <div align="right"> 
                  <ul>
                  </ul>
                </div>
                <p align="right"><font face="Arial Unicode MS"><b>Subnet Mask:</b></font></p>
              </td>
              <td nowrap width="62%"> 
                <div align="left"><font face="Arial Unicode MS"> 
                  <input type="text" name="Wan2AliasMaskIp1" value=\'0\' maxlength="3" size="3" onFocus="this.select();" onBlur=" MKCheck(this)">
                  . 
                  <input type="text" name="Wan2AliasMaskIp2" value=\'0\' maxlength="3" size="3" onFocus="this.select();" onBlur=" MKCheck(this)">
                  . 
                  <input type="text" name="Wan2AliasMaskIp3" value=\'0\' maxlength="3" size="3" onFocus="this.select();" onBlur=" MKCheck(this)">
                  . 
                  <input type="text" name="Wan2AliasMaskIp4" value=\'0\' maxlength="3" size="3" onFocus="this.select();" onBlur=" MKCheck(this)">
                  </font></div>
              </td>
            </tr>			
	</table>
 
<!--	
    <table align="center" width="98%">	
            <tr> 
              <td align="right" nowrap width="38%" height="13"> 
                <div align="right"> 
                  <ul>
                  </ul>
                </div>
                <p align="right"><font face="Arial Unicode MS"><b>Default Gateway 
                  Address:</b></font></p>
              </td>
              <td nowrap width="62%" height="13"> 
                <div align="left"><font face="Arial Unicode MS"> 
                  <input type="text" name="Wan2RouterIp1" value=\'0\' maxlength="3" size="3" onFocus="this.select();" onBlur=" IPCheck(this)">
                  . 
                  <input type="text" name="Wan2RouterIp2" value=\'0\' maxlength="3" size="3" onFocus="this.select();" onBlur=" IPCheck(this)">
                  . 
                  <input type="text" name="Wan2RouterIp3" value=\'0\' maxlength="3" size="3" onFocus="this.select();" onBlur=" IPCheck(this)">
                  . 
                  <input type="text" name="Wan2RouterIp4" value=\'0\' maxlength="3" size="3" onFocus="this.select();" onBlur=" IP0to254Check(this)">
                  </font></div>
              </td>
            </tr>
            <tr> 
              <td align="right" nowrap width="38%" height="8"> 
                <p align="right"><font face="Arial Unicode MS"><b> DNS Server 
                  (Required) 1:</b></font> 
              </td>
              <td nowrap width="62%" height="8"> 
                <div align="left"><font face="Arial Unicode MS"> 
                  <input type="text" name="Wan2DnsA1" value=\'0\' maxlength="3" size="3" onFocus="this.select();" onBlur=" IPCheck(this)">
                  . 
                  <input type="text" name="Wan2DnsA2" value=\'0\' maxlength="3" size="3" onFocus="this.select();" onBlur=" IPCheck(this)">
                  . 
                  <input type="text" name="Wan2DnsA3" value=\'0\' maxlength="3" size="3" onFocus="this.select();" onBlur=" IPCheck(this)">
                  . 
                  <input type="text" name="Wan2DnsA4" value=\'0\' maxlength="3" size="3" onFocus="this.select();" onBlur=" IP0to254Check(this)">
                  </font></div>
              </td>
            </tr>
            <tr> 
              <td align="right" nowrap width="38%" height="6"> 
                <div align="right"><font face="Arial Unicode MS"><b>2:</b></font></div>
              </td>
              <td nowrap width="62%" height="6"> 
                <div align="left"><font face="Arial Unicode MS"> 
                  <input type="text" name="Wan2DnsB1" value=\'0\' maxlength="3" size="3" onFocus="this.select();" onBlur=" IPCheck(this)">
                  . 
                  <input type="text" name="Wan2DnsB2" value=\'0\' maxlength="3" size="3" onFocus="this.select();" onBlur=" IPCheck(this)">
                  . 
                  <input type="text" name="Wan2DnsB3" value=\'0\' maxlength="3" size="3" onFocus="this.select();" onBlur=" IPCheck(this)">
                  . 
                  <input type="text" name="Wan2DnsB4" value=\'0\' maxlength="3" size="3" onFocus="this.select();" onBlur=" IP0to254Check(this)">
                  </font></div>
              </td>
            </tr>
          </table>
          <p>		  
-->
<!--
          
-->   
<!--
          </p>
          <table align="center" width="98%">
            <tr> 
              <td align="right" nowrap width="22%"> 
                <div align="right"><font size="2" face="Arial Unicode MS">&nbsp;&nbsp;&nbsp;&nbsp;</font><font face="Arial Unicode MS"><b></b></font></div>
              </td>
              <td nowrap width="16%"> 
                <div align="right"><font face="Arial Unicode MS"><b>User Name:</b></font></div>
              </td>
              <td nowrap width="62%"> 
                <input type="text" name="Wan2UserName" value=\'\' size="20" maxlength="60"  onFocus="this.select();" onBlur="sTrim(this);">
              </td>
            </tr>
            <tr> 
              <td align="right" height="11" nowrap width="22%"> 
                <div align="right"> </div>
                <p align="right"><b></b></p>
              </td>
              <td height="11" nowrap width="16%"> 
                <div align="right"><b><font face="Arial Unicode MS">Password:</font></b></div>
              </td>
              <td height="11" nowrap width="62%"> 
                <input type="password" name="Wan2PassWord" value=\'\' size="20" maxlength="60"  onFocus="this.select();" onBlur="sTrim(this);">
              </td>
            </tr>
            <tr> 
              <td align="right" height="11" nowrap width="22%"> 
                <div align="right"> </div>
                <p align="right"><b></b></p>
              </td>
              <td height="11" nowrap width="16%"> 
                <div align="right"><b><font face="Arial Unicode MS">Service Name:</font></b></div>
              </td>
              <td height="11" nowrap width="62%"> 
                <input type="text" name="Wan2ServiceName" value=\'\' size="20" maxlength="60"  onFocus="this.select();" onBlur="sTrim(this);">
              </td>
            </tr>
            <tr> 
              <td align="right" nowrap width="22%"> 
                <p align="left"><font face="Arial, Helvetica, sans-serif"> </font> 
              </td>
              <td align="right" colspan="2" nowrap> 
                <div align="left"><font face="Arial, Helvetica, sans-serif"> 
                  <input type="radio" name=Wan2ConnectAlive value="1"  checked>
                  <b><font face="Arial Unicode MS">Connect on Demand: Max Idle 
                  Time</font></b> 
                  <input type="text" name=Wan2IdleTime value=\'5\' size="5" maxlength="5" onFocus="this.select();" onBlur=" minCheck(this)">
                  <b><font face="Arial Unicode MS">Min.</font></b></font> <font face="Arial, Helvetica, sans-serif"> 
                  </font><font face="Arial, Helvetica, sans-serif"> </font></div>
              </td>
            </tr>
            <tr> 
              <td align="right" nowrap width="22%"> 
                <div align="left"><font face="Arial Unicode MS" size="2"> <b> 
                  </b></font></div>
              </td>
              <td align="right" colspan="2" nowrap> 
                <div align="left"><font face="Arial Unicode MS" size="2"> 
                  <input type="radio" name=Wan2ConnectAlive value="2"  >
					</font><font face="Arial Unicode MS"><b>
                     Keep Alive: Interval
					 <input type="text" name="wan2_echo_interval" maxlength=4 size=4 onFocus="this.select();" onBlur=" EchoCheck(this, \'interval\')" value=\'30\'> 
					 Sec.
										 
                </b></font>
                  </font></div>
              </td>
            </tr>
          </table>
		 <table align="center" width="98%">
            <tr> 
              <td align="right" nowrap width="22%"> 
                <div align="left"><font face="Arial Unicode MS"><b> 
                  </b></font></div>
              </td>
			  <td align="right" nowrap width="4%"> 
                <p align="left"><font face="Arial, Helvetica, sans-serif"> </font> 
              </td>
              <td align="right" nowrap width="74%"> 
                <div align="left"><font face="Arial Unicode MS"><b> 
                    Keep Alive: Retry Times
					<input type="text" name="wan2_echo_failure" maxlength=2 size=2 onFocus="this.select();" onBlur=" EchoCheck(this, \'failure\')" value=\'5\'> Times
					
                </b></font></div>
              </td>
            </tr>
            <tr> 
              <td align="right" nowrap width="22%"> 
                <p align="left"><font face="Arial, Helvetica, sans-serif"> </font> 
              </td>
			  <td align="right" nowrap width="4%"> 
                <p align="left"><font face="Arial, Helvetica, sans-serif"> </font> 
              </td>
              <td align="right" nowrap width="74%">
                <div align="left"><font face="Arial Unicode MS"><b>Keep Alive: Redail Period</b></font><font face="Arial Unicode MS" size="2"><b> 
                  <input type="text" name=Wan2RedialTime value=\'30\' size="7" maxlength="7" onFocus="this.select();" onBlur=" secCheck(this)">
                  </b></font><font face="Arial Unicode MS"><b> Sec.</b> </font></div>
              </td>
            </tr>

          </table> 		  
          <p>
            -->
            <!--
          <div align="center"></div>
          <p></p>
          <table align="center" width="98%">
            <tr>
              <td align="right" nowrap width="33" height="19">
                <div align="right"><font size="2" face="Arial Unicode MS">&nbsp;&nbsp;&nbsp;&nbsp;</font><font face="Arial Unicode MS"><b></b></font></div>
              </td>
              <td colspan="2" nowrap height="19">
                <div align="right"><font face="Arial Unicode MS"><b>Specify WAN
                  IP Address:</b></font></div>
              </td>
              <td nowrap width="356">
                <input type="text" name="Wan2AliasIp1" value=\'0\' size="3" maxlength="3" onFocus="this.select();" onBlur=" IPCheck(this)">
                .
                <input type="text" name="Wan2AliasIp2" value=\'0\' size="3" maxlength="3" onFocus="this.select();" onBlur=" IPCheck(this)">
                .
                <input type="text" name="Wan2AliasIp3" value=\'0\' size="3" maxlength="3" onFocus="this.select();" onBlur=" IPCheck(this)">
                .
                <input type="text" name="Wan2AliasIp4" value=\'0\' size="3" maxlength="3" onFocus="this.select();" onBlur=" IP0to254Check(this)">
              </td>
            </tr>
            <tr>
              <td align="right" nowrap width="33" height="13">&nbsp;</td>
              <td colspan="2" nowrap height="13">
                <div align="right"><font face="Arial Unicode MS"><b>Subnet Mask:</b></font></div>
              </td>
              <td nowrap width="356" height="15">
                <input type="text" name="Wan2AliasMaskIp1" value=\'0\' size="3" maxlength="3" onFocus="this.select();" onBlur=" MKCheck(this)">
                .
                <input type="text" name="Wan2AliasMaskIp2" value=\'0\' size="3" maxlength="3" onFocus="this.select();" onBlur=" MKCheck(this)">
                .
                <input type="text" name="Wan2AliasMaskIp3" value=\'0\' size="3" maxlength="3" onFocus="this.select();" onBlur=" MKCheck(this)">
                .
                <input type="text" name="Wan2AliasMaskIp4" value=\'0\' size="3" maxlength="3" onFocus="this.select();" onBlur=" MKCheck(this)">
              </td>
            </tr>
            <tr>
              <td align="right" nowrap width="33">&nbsp;</td>
              <td colspan="2" nowrap>
                <div align="right"><font face="Arial Unicode MS"><b>Default Gateway
                  Address:</b></font></div>
              </td>
              <td nowrap width="356">
                <input type="text" name="Wan2RouterIp1" value=\'0\' size="3" maxlength="3" onFocus="this.select();" onBlur=" IPCheck(this)">
                .
                <input type="text" name="Wan2RouterIp2" value=\'0\' size="3" maxlength="3" onFocus="this.select();" onBlur=" IPCheck(this)">
                .
                <input type="text" name="Wan2RouterIp3" value=\'0\' size="3" maxlength="3" onFocus="this.select();" onBlur=" IPCheck(this)">
                .
                <input type="text" name="Wan2RouterIp4" value=\'0\' size="3" maxlength="3" onFocus="this.select();" onBlur=" IP0to254Check(this)">
              </td>
            </tr>
            <tr>
              <td align="right" height="21" nowrap width="33">&nbsp;</td>
              <td height="21" colspan="2" nowrap>
                <div align="right"><font face="Arial Unicode MS"><b>User Name:</b></font></div>
              </td>
              <td height="24" nowrap width="356">
                <input type="text" name="Wan2UserName" value=\'\' size="20" maxlength="60"   onFocus="this.select();" onBlur="sTrim(this);">
              </td>
            </tr>
            <tr>
              <td align="right" height="2" nowrap width="33">
                <div align="right"> </div>
                <p align="right"><b></b></p>
              </td>
              <td height="2" colspan="2" nowrap>
                <div align="right"><b><font face="Arial Unicode MS">Password:</font></b></div>
              </td>
              <td height="11" nowrap width="62%">
                <input type="password" name="Wan2PassWord" value=\'\' size="20" maxlength="60"  onFocus="this.select();" onBlur="sTrim(this);">
              </td>
            </tr>
            <tr>
              <td align="right" colspan="2" height="66" rowspan="2">
                <p align="left">
              </td>
              <td align="right" colspan="2" nowrap>
                <div align="left"><font face="Arial, Helvetica, sans-serif">
                  <input type="radio" name=Wan2ConnectAlive value="1"  checked>
                  <b><font face="Arial Unicode MS">Connect on Demand: Max Idle
                  Time</font></b>
                  <input type="text" name=Wan2IdleTime value=\'5\' size="5" maxlength="5" onFocus="this.select();" onBlur=" minCheck(this)">
                  <b><font face="Arial Unicode MS">Min.</font></b></font> <font face="Arial, Helvetica, sans-serif">
                  </font><font face="Arial, Helvetica, sans-serif"> </font></div>
              </td>
            </tr>
            <tr>
              <td align="right" colspan="2" nowrap>
                <div align="left"><font face="Arial Unicode MS" size="2">
                  <input type="radio" name=Wan2ConnectAlive value="2"  >
                  </font><font face="Arial Unicode MS"><b>Keep Alive: Redial Period</b></font><font face="Arial Unicode MS" size="2"><b>
                  <input type="text" name=Wan2RedialTime value=\'30\' size="7" maxlength="7" onFocus="this.select();" onBlur=" secCheck(this)">
                  </b></font><font face="Arial Unicode MS"><b> Sec.</b> </font></div>
              </td>
            </tr>
          </table>
          -->
		  <!--  
          
          <table align="center" width="98%">
            <tr> 
              <td align="right" nowrap width="22%"> 
                <div align="right"><font size="2" face="Arial Unicode MS">&nbsp;&nbsp;&nbsp;&nbsp;</font><font face="Arial Unicode MS"><b></b></font></div>
              </td>
              <td nowrap width="20%"> 
                <div align="right"><font face="Arial Unicode MS"><b>User Name:</b></font></div>
              </td>
              <td nowrap width="58%"> 
                <input type="text" name="Wan2HBSUserName" value=\'\' size="20" maxlength="60"  onFocus="this.select();" onBlur="sTrim(this);">
              </td>
            </tr>
            <tr> 
              <td align="right" height="11" nowrap width="22%"> 
                <div align="right"> </div>
                <p align="right"><b></b></p>
              </td>
              <td height="11" nowrap width="20%"> 
                <div align="right"><b><font face="Arial Unicode MS">Password:</font></b></div>
              </td>
              <td height="11" nowrap width="58%"> 
                <input type="password" name="Wan2HBSPassWord" value=\'\' size="20" maxlength="60"  onFocus="this.select();" onBlur="sTrim(this);">
              </td>
            </tr>		             
			<tr> 
              <td align="right" nowrap width="22%"> 
                <div align="right"><font size="2" face="Arial Unicode MS">&nbsp;&nbsp;&nbsp;&nbsp;</font><font face="Arial Unicode MS"><b></b></font></div>
              </td>
              <td nowrap width="20%"> 
                <div align="right"><font face="Arial Unicode MS"><b>Heart Beat Server:</b></font></div>
              </td>
              <td nowrap width="58%"> 
                <input type="text" name="Wan2HBSServer" value=\'\' size="20" maxlength="60"  onFocus="this.select();" onBlur="sTrim(this);">
              </td>
            </tr>                     
          </table>
          <p> 
           -->
          <br>
          <br>
          <br>
        </td>
        <td height="376"></td>
      </tr>
      <tr> 
        <td valign="bottom" rowspan="2" bgcolor="#6666CC" align="right"><img src="images_rv042/cisco.gif" width="136" height="62"></td>
        <td height="49"></td>
      </tr>
      <tr> 
        <td height="25" colspan="2" valign="top" bgcolor="#000000" bordercolor="#E7E7E7" bordercolorlight="#E7E7E7" bordercolordark="#E7E7E7">&nbsp; 
        </td>
        <td valign="top" bgcolor="#6666CC" bordercolor="#E7E7E7" bordercolorlight="#E7E7E7" bordercolordark="#E7E7E7">&nbsp;</td>
        <td valign="middle" bgcolor="#6666CC" bordercolor="#E7E7E7" bordercolorlight="#E7E7E7" bordercolordark="#E7E7E7"> 
          <table border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse" bordercolor="#111111" id="AutoNumber15" width="220" align="right" height="19">
            <tr> 
              <td width="101" bgcolor="#42498C" align="center"> <font color="#FFFFFF" style="font-size: 8pt; font-weight: 700" face="Arial"> 
                <a href="javascript:chSubmit(document.formNetwork)"><font color="#FFFFFF">Save 
                Settings</font></a></font></td>
              <td width="8" align="center" bgcolor="#6666CC">&nbsp;</td>
              <td width="103" bgcolor="#434A8F" align="center"> <font color="#FFFFFF" style="font-size: 8pt; font-weight: 700" face="Arial"> 
                <a href="network.htm"><font color="#FFFFFF">Cancel 
                Changes</font></a></font></td>
            </tr>
          </table>
        </td>
        <td valign="top" bgcolor="#6666CC" bordercolor="#E7E7E7" bordercolorlight="#E7E7E7" bordercolordark="#E7E7E7">&nbsp;</td>
        <td valign="top" bgcolor="#000000"> 
          <div align="center"> 
            <center>
            </center>
          </div>
        </td>
        <td></td>
      </tr>
      <tr> 
        <td height="0"></td>
        <td></td>
        <td></td>
        <td></td>
        <td></td>
        <td></td>
        <td></td>
        <td></td>
      </tr>
    </form>
  </table>
    
            </div></body>

</html>
END_NETWORK

our $filters = <<'END_FILTERS';
<html>

<head><meta name="Pragma" content="No-Cache">
<meta name="GENERATOR" content="Microsoft FrontPage 5.0">
<meta name="ProgId" content="FrontPage.Editor.Document">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Web Management</title>
<base target="_self">
<style fprolloverstyle>A:hover {color: #00FFFF}
.help:link {text-decoration: underline}
.help:visited {text-decoration: underline}
.help:hover {color: #FFCC00; text-decoration: underline}
.logout:link {text-decoration: none}
.logout:visited {text-decoration: none}
.logout:hover {color: #FFCC00; text-decoration: none}
.npage:link {color: #0000FF; text-decoration: none}
.npage:visited {text-decoration: none}
.npage:hover {color: #0000FF; text-decoration: underline}
</style>
<style type="text/css">
body {font-family: Arial, Verdana, sans-serif, Helvetica; background-color: #ffffff;}
td, th, input, select {font-size: 11px}
</style>
<link rel="stylesheet" href="nk.css">
<script src="nk20060810141951.js"></script> <!--<script src="nk.js"></script>-->
<script src="lg20060810141951.js"></script> <!--<script src="lg.js"></script>-->
<script language=JavaScript>
function afterRemove()
{
  if (document.formaccess_rules.AfterRemove.value=="1")
  window.location.replace("access_rules.htm");

}
function chTotalRules(F)
{
    if (parseInt(F.totalRules.value,10)>=50)
	{
	    alert(aLimitRules);
		return;
	}
	else
	window.location.replace('edit_access_rules.htm');

}
function perPageRefresh()
{
  document.formaccess_rules.submitStatus.value="1";
  window.status=wRefresh;  
  document.formaccess_rules.submit();
}
function reqPage(n)
{
//  document.formvpn_summary.PageList.selectedIndex+=parseInt(n,10);
//  document.formvpn_summary.tunnelUsed.value=document.formvpn_summary.PageList.selectedIndex+1+parseInt(n,10);
  document.formaccess_rules.ReqPage.value=document.formaccess_rules.JumpPage.selectedIndex+1+parseInt(n,10);
  document.formaccess_rules.submitStatus.value="2";
  window.status=wDownLoad;  
  document.formaccess_rules.submit();
}
function changePolicy(s,e,p)
{
  var y=0;
  y = confirm(cChangePriority);
  if (y)
  {
    document.formaccess_rules.ChangeEntry.value=e;
    document.formaccess_rules.ChangePolicy.value=p;  
    document.formaccess_rules.submitStatus.value="3"; 
    window.status=wChangePriority;	 
    document.formaccess_rules.submit();
  }
  else
  {
    s.selectedIndex=e-1;
  }
  
}
function enableLine(c,e)
{
  if (c.checked)
  { 
      document.formaccess_rules.EnableLine.value=e;
      window.status=wEnableRules; 	 
  }	  
  else 
  {
      document.formaccess_rules.DisableLine.value=e;
      window.status=wDisableRules;	  
  }	  
  document.formaccess_rules.submitStatus.value="4";  
  window.status=wRefresh;   
  document.formaccess_rules.submit();
}
function editLine(n)
{
  document.formaccess_rules.EditLine.value=n;
  document.formaccess_rules.submitStatus.value="5";  
  window.status=wEditRules;  
  document.formaccess_rules.submit();
}
function removeLine(n)
{
  if (document.formaccess_rules.submitClick.value == "0")
  if (confirm(cRemoveRules1+n+cRightNow))
  {
    document.formaccess_rules.submitClick.value="1";
    document.formaccess_rules.RemoveLine.value=n;
    document.formaccess_rules.submitStatus.value="6";  
    window.status=wRemoveRules;	
    document.formaccess_rules.submit();
  }
}
function defaultRules()
{
    document.formaccess_rules.submitStatus.value="10";  
    window.status=wRestoreRules;	
    document.formaccess_rules.submit();
}
function falseSubmit(F)
{
  F.submitStatus.value=0; 
      MM_showHideLayers('AutoNumber15','','hide');  
  F.submit();
}
var wMap=null;
function openMap()
{
  if (wMap==null)
  wMap=window.open('map.htm','sitemap','menubar=no,scrollbars,width=670,height=470');

}
function closeMap()
{
  if (wMap!=null)
  {
    wMap.close();
	wMap=null;
  }
}
function mapTo(p)
{
  document.location.href=p; 
  closeMap(); 
}
window.onfocus=closeMap;
</script>
</head>
<body link="#B5B5E6" vlink="#B5B5E6" alink="#B5B5E6" onLoad="afterRemove()" onUnLoad="closeMap()">
<DIV align=center>


   
  <table border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse" bordercolor="#111111" id="AutoNumber11" width="960" height="68">
    <tr> 
      <td valign="bottom" width="650" hetght="39" bgcolor="#6666CC"> <img border="0" src="images_rv042/clinksys.gif" width="165" height="57" align="middle"> 
      </td>
      <td valign="bottom" bgcolor="#6666CC" width="337"> 
        <div align="right"><font color="#FFFFFF"> <span style="font-size: 7pt">&nbsp;&nbsp;&nbsp;&nbsp;<font face="Arial"> 
          Firmware Version: 1.3.7.10</font></span><font face="Arial"><span style="font-size: 7pt">&nbsp;&nbsp;&nbsp;</span></font></font></div>
      </td>

    </tr>
    <tr> 
      <td colspan="2" valign="top"> <img border="0" src="images_rv042/UI_10.gif" width="960" height="11"></td>

    </tr>
  </table>
   
  
   
  <TABLE height=90 cellSpacing=0 cellPadding=0 width=960 bgColor=black border=0>
    <form name="formdualwan" method="post" action="">
      <input type="hidden" name="dualwanEnabled" value='0'>
      <input type="hidden" name="firewall0" value=' checked'>
    </form>
    <TR> 
      <TD width="150" height=90 rowspan="3" align=middle bordercolor="#000000" bgColor=black style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"> 
        <H3 style="margin-top: 1; margin-bottom: 1" align="center"> <font color="#FFFFFF" face="Arial">Firewall</font></H3></TD>
      <TD width=690 height=33 align="center" vAlign=middle bordercolor="#000000" bgColor=#6666CC style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"> 
        <p align="right"><b><font color="#FFFFFF"><span lang="en-us"> 10/100 4-port 
          VPN Router&nbsp;&nbsp;&nbsp;&nbsp;</span></font></b> </TD>
      <TD vAlign=center width=120 bgColor=#000000 style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black" bordercolor="#000000"> 
        <p align="center"><font color="#FFFFFF"> <span style="font-size: 8pt"><b>RV042</b></span></font> 
      </TD>
    </TR>
    <TR> 
      <TD height=36 colspan="2" vAlign=center bordercolor="#000000" bgColor=#000000 style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"><table width="810" border="0" cellspacing="0" cellpadding="0" >
          <!--DWLayoutTable-->
          <tr  align="center"> 
            <td width="100" height="8" valign="middle" background="images_rv042/UI_06.gif" style=""></td>
            <td width="80" valign="middle" background="images_rv042/UI_06.gif"style=""></td>
            <td width="70" valign="middle" background="images_rv042/UI_06.gif"style=""></td>
            <td width="110" valign="middle" background="images_rv042/UI_06.gif"style=""></td>
            <td width="80" valign="middle" background="images_rv042/UI_07.gif"style=""></td>
            <td width="60" valign="middle" background="images_rv042/UI_06.gif"style=""></td>
            <td width="60" valign="middle" background="images_rv042/UI_06.gif"style=""></td>
            <td width="80" valign="middle" background="images_rv042/UI_06.gif"style=""></td>
            <td width="85" valign="middle" background="images_rv042/UI_06.gif"style=""></td>
            <td width="85" valign="middle" background="images_rv042/UI_06.gif"style=""></td>
          </tr>
          <tr  align="center" valign="middle"> 
            <td height="28" style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"> 
              <p align="center" style="margin-bottom: 4"> <b> <a class="mainmenu" href="home.htm" style="font-size: 8pt; text-decoration: none; font-weight:700"> 
                System<br>
                Summary</a></b> </td>
            <td bgcolor="#000000" style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"> 
              <p style="margin-top: 0; margin-bottom: 4"><b> <a class="mainmenu" href="network.htm" style="font-size: 8pt; text-decoration: none; font-weight:700">Setup</a></b> 
            </td>
            <td bgcolor="#000000" style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"> 
              <p style="margin-bottom: 4"> <b> <a class="mainmenu" href="dhcp_setup.htm" style="font-size: 8pt; text-decoration: none; font-weight:700">DHCP</a></b> 
            </td>
            <td bgcolor="#000000" style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"> 
              <p style="margin-bottom: 4"> <b> 
                <script>
          if (document.formdualwan.dualwanEnabled.value=="1") 
		  	  document.write('<a class="mainmenu" href="sys_dualwanw.htm" style="font-size: 8pt; text-decoration: none; font-weight:700">');
          else document.write('<a class="mainmenu" href="sys_dualwan3.htm" style="font-size: 8pt; text-decoration: none; font-weight:700">');
          </script>
                System<br>
                Management </b> </td>
            <td bgcolor="#6666CC" style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"> 
              <p style="margin-bottom: 4"><b> <font color="#FFFFFF" style="font-size: 8pt"> 
                Firewall</font></b> </td>
            <td bgcolor="#000000" style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"> 
              <p style="margin-bottom: 4"> <b> <a class="mainmenu" href="vpn_summary.htm" style="font-size: 8pt; text-decoration: none; font-weight:700">VPN</a></b> 
            </td>
            <td bgcolor="#000000" style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"> 
              <p style="margin-bottom: 4"> <b> <a class="mainmenu" href="log_setting.htm" style="font-size: 8pt; text-decoration: none; font-weight:700">Log</a></b> 
            </td>
            <td bgcolor="#000000" style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"> 
              <p style="margin-bottom: 4"> <b> <a class="mainmenu" href="wizard.htm" style="font-size: 8pt; text-decoration: none; font-weight:700">Wizard</a></b> 
            </td>
            <td bgcolor="#000000" style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"> 
              <p style="margin-bottom: 4"> <b> <a class="mainmenu" href="support.htm" style="font-size: 8pt; text-decoration: none; font-weight:700">Support</a></b> 
            </td>
            <td bgcolor="#000000" style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"> 
              <p style="margin-bottom: 4"> <b> <a class="mainmenu" href="javascript: window.close()" style="font-size: 8pt; text-decoration: none; font-weight:700">Logout</a></b> 
            </td>
          </tr>
        </table></TD>
    </TR>
    <TR> 
      <TD height=21 colspan="2" vAlign=center bordercolor="#000000" bgColor=#6666CC style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; color: black"> 
        <table width="810" border="0" cellspacing="0" cellpadding="0" style="border-collapse: collapse; font-style:normal; font-variant:normal; font-weight:normal; font-size:10pt; color:black">
          <tr align="center" valign="middle"> 
            <td width="82" height="21"> 
              <p align="center"> <span style="font-size: 8pt; background-color:#6666CC"> 
                <font color="#FFFFFF"> 
                <!--f_general-->
                <a class="submenu" href="f_general.htm" style="text-decoration: none"> 
                <!--f_general-->
                General 
                <!--f_general-->
                </a> </font> </span> </td>
            <td width="3"> <table border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse; border-left-style: solid; border-left-width: 2" bordercolor="#FFFFFF" id="AutoNumber14" height="10" width="3">
                <tr> 
                  <td width="1" height="12" align="center" valign="middle"></td>
                </tr>
              </table></td>
            <td width="104" rowspan="2"> <p align="center"> <span style="font-size: 8pt; background-color:#6666CC"> 
                <font color="#FFFFFF"> 
                <!--access_rules
                      <a class="submenu" href="access_rules.htm" style="text-decoration: none"> 
                      access_rules-->
                Access Rules 
                <!--access_rules
                      </a> 
                      access_rules-->
                </font> </span> </td>
            <td width="3" rowspan="2"> <table border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse; border-left-style: solid; border-left-width: 2" bordercolor="#FFFFFF" id="AutoNumber14" height="10" width="3">
                <tr> 
                  <td width="1" height="12" align="center" valign="middle"></td>
                </tr>
              </table></td>
            <td width="102" rowspan="3"> <p align="center"> <span style="font-size: 8pt; background-color:#6666CC"> 
                <font color="#FFFFFF"> 
                <!--content_filter-->
                <a class="submenu" href="content_filter.htm" style="text-decoration: none"> 
                <!--content_filter-->
                Content Filter 
                <!--content_filter-->
                </a> 
                <!--content_filter-->
                </font> </span></td>
            <td width="516">&nbsp;</td>
          </tr>
        </table></TD>
    </TR>
  </TABLE>
  <TABLE height=5 cellSpacing=0 cellPadding=0 width=960 bgColor=black border=0>  
  <TR bgColor=black>
    <TD width=150 height=1 style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; font-family: Arial, Helvetica, sans-serif; color: black" bgcolor="#E7E7E7" bordercolor="#E7E7E7">
			<img border="0" src="images_rv042/UI_03.gif" width="150" height="15"></TD>
    <TD width=810 height=1 style="font-style: normal; font-variant: normal; font-weight: normal; font-size: 10pt; font-family: Arial, Helvetica, sans-serif; color: black" bgcolor="#FFFFFF">
			<img border="0" src="images_rv042/UI_02.gif" width="810" height="15"></TD></TR>
  </TABLE>


			
  <table border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse" bordercolor="#111111" id="AutoNumber9" width="961">
    <form name="formaccess_rules" method="post" action="access_rules.htm">
      <tr> 
        <td valign="middle" bgcolor="#000000" bordercolor="#E7E7E7" bordercolorlight="#E7E7E7" bordercolordark="#E7E7E7" width="142" align="right" height="25"><font color="#FFFFFF"><b><font face="Arial, Helvetica, sans-serif">Access 
          Rules</font></b></font> </td>
        <td width="8" valign="top" bgcolor="#000000">&nbsp;</td>
        <td width="20" valign="top" bgcolor="#FFFFFF">&nbsp;</td>
        <td width="620" valign="top" bgcolor="#FFFFFF"><font size="+0">&nbsp;</font><font size="+0">&nbsp;</font> 
          <div align="left"><span style="font-size: 8pt; background-color:#6666CC"><font color="#FFFFFF">
            <!--f_general-->
            </font></span> </div>
        </td>
        <td width="20" valign="top" bgcolor="#FFFFFF" rowspan="3">&nbsp;</td>
        <td background="images_rv042/UI_05.gif" width="14" valign="top" rowspan="3">&nbsp;</td>
        <td width="136" rowspan="2" valign="top" bgcolor="#6666CC" align="right"> 
          <a href="javascript: openMap()"><img src="images_rv042/sitemap-off.jpg" width="136" height="28" border="0" onMouseOver="this.src='images_rv042/sitemap-on.jpg'" onMouseOut="this.src='images_rv042/sitemap-off.jpg'"></a> 
          <p>
		  <div align="left"><font face="Arial" style="font-size: 8pt" color="#FFFFFF"> 
            Network Access Rules evaluate network traffic's Source IP address, 
            Destination IP address, and IP protocol type to decide if the IP traffic 
            is allowed to pass through the firewall. 
			<br><br>
            <a href="javascript: h_access_rules();"><b><font face="Arial" style="font-size: 8pt" color="#FFFFFF">More...</font></b></a>			
			</font></div>  
		  </td>
        <td width="1"></td>
      </tr>
      <tr> 
        <td valign="top" bgcolor="#E7E7E7" bordercolor="#E7E7E7" bordercolorlight="#E7E7E7" bordercolordark="#E7E7E7" rowspan="2" height="280">&nbsp;</td>
        <td background="images_rv042/UI_04.gif" valign="top" rowspan="2">&nbsp;</td>
        <td valign="top" bgcolor="#FFFFFF" rowspan="2">&nbsp;</td>
        <td valign="top" bgcolor="#FFFFFF" rowspan="2"> 
          <input type=hidden name="page" value="access_rules.htm">
          <input type=hidden name="submitStatus" value="0">
          <input type="hidden" name="ReqPage" value="0">
          <input type="hidden" name="ChangeEntry" value="0">
          <input type="hidden" name="ChangePolicy" value="0">
          <input type="hidden" name="EnableLine" value="0">
          <input type="hidden" name="DisableLine" value="0">
          <input type="hidden" name="EditLine" value="0">
          <input type="hidden" name="RemoveLine" value="0">
          <input type="hidden" name="thisPage" value='1'>
          <input type="hidden" name="totalPage" value='1'>
		  <input type="hidden" name="totalRules" value='8'>
		  <input type="hidden" name="AfterRemove" value='0'>
          <input type="hidden" name="submitClick" value="0"> <br>
          <font size="+0"> 
          <center>
            <table width="98%">
              <tr> 
                <td width="21%"> 
                  <script>
if (document.formaccess_rules.thisPage.value!="1")
{
  document.write('<div><a class="npage" href="javascript: reqPage');				
  document.write("('-1')");
  document.write('"><font color="#0000FF">&lt;&lt;Previous page</font></a></div>');       
}
</script>
                </td>
                <td width="34%"> 
                  <div align="center"><a href="javascript"></a>Jump to 
                    <select name="JumpPage" onChange="reqPage('0')">
                      <option selected>1</option>
                    </select>
                    / 
                    1
                    page </div>
                </td>
                <td width="27%"> 
                  <div align="center"> 
                    <select name="perPage" onChange="perPageRefresh()">
                      <option value="0">5</option><option value="1">10</option><option value="2">20</option><option value="3" selected>40</option>
                    </select>
                    entries per page</div>
                </td>
                <td width="18%"> 
                  <script>				
if (document.formaccess_rules.thisPage.value!=document.formaccess_rules.totalPage.value)
{
  document.write('<div align="right"><a class="npage" href="javascript: reqPage');
  document.write("('1')");
  document.write('"><font color="#0000FF">Next page &gt;&gt;</font></a></div>');                
}
</script>
                </td>
              </tr>
            </table>
            <table cellspacing="0" border="1" bordercolor="#C0C0C0" style="border-collapse: collapse" width="100%">
              <tr bgcolor="#CCCCFF" align="center" valign="middle"> 
                <td bordercolor="#C0C0C0" width="41">Priority</td>
                <td bordercolor="#C0C0C0" width="38">Enable</td>
                <td bordercolor="#C0C0C0" width="36">Action</td>
                <td bordercolor="#C0C0C0" width="81">Service</td>
                <td bordercolor="#C0C0C0" width="40">Source Interface</td>
                <td bordercolor="#C0C0C0" width="92">Source</td>
                <td bordercolor="#C0C0C0" width="92">Destination</td>
                <td bordercolor="#C0C0C0" width="78">Time</td>
                <td bordercolor="#C0C0C0" width="62">Day</td>
                <td bordercolor="#C0C0C0" width="45"> </td>
                <td bordercolor="#C0C0C0" width="25">Delete</td>
              </tr>
              <tr bordercolor="#C0C0C0" align="center"><td width="41">
<select name="pe1" onChange="changePolicy(this,'1',this.selectedIndex+1)">
<option selected>1</option><option>2</option><option>3</option><option>4</option><option>5</option></select></td><td width="38">
<input type="checkbox" name="enablePolicy" value="1" onClick="enableLine(this,'1')" checked></td>
<td><font color="#009900">Allow</font></td>
<td>DNS [53]</td>
<td>DMZ</td>
<td>Any</td>
<td>Any</td>
<td>9:55 ~ 9:59</td>
<td>All week</td>
<td>
<input type="button" name="Button" value="Edit" onClick="editLine('1')"></td>
<td> <a href="javascript: removeLine('1')">
<img src="images/trash.gif" width="20" height="16" align="middle" alt="Delete" border="0"></a></td></tr>
<tr bordercolor="#C0C0C0" align="center"><td width="41">
<select name="pe2" onChange="changePolicy(this,'2',this.selectedIndex+1)">
<option>1</option><option selected>2</option><option>3</option><option>4</option><option>5</option></select></td><td width="38">
<input type="checkbox" name="enablePolicy" value="2" onClick="enableLine(this,'2')" checked></td>
<td><font color="#009900">Allow</font></td>
<td>HTTPS [443]</td>
<td>LAN</td>
<td>Any</td>
<td>Any</td>
<td>10:0 ~ 12:0</td>
<td>Mon, Tue, Wed, </td>
<td>
<input type="button" name="Button" value="Edit" onClick="editLine('2')"></td>
<td> <a href="javascript: removeLine('2')">
<img src="images/trash.gif" width="20" height="16" align="middle" alt="Delete" border="0"></a></td></tr>
<tr bordercolor="#C0C0C0" align="center"><td width="41">
<select name="pe3" onChange="changePolicy(this,'3',this.selectedIndex+1)">
<option>1</option><option>2</option><option selected>3</option><option>4</option><option>5</option></select></td><td width="38">
<input type="checkbox" name="enablePolicy" value="3" onClick="enableLine(this,'3')" checked></td>
<td><font color="#009900">Allow</font></td>
<td>TELNETSSL [992]</td>
<td>WAN</td>
<td>99.1.5.6 ~ 99.1.5.6</td>
<td>10.1.0.0 ~ 10.1.255.255</td>
<td>Always</td>
<td bordercolor="#C0C0C0"> </td>
<td>
<input type="button" name="Button" value="Edit" onClick="editLine('3')"></td>
<td> <a href="javascript: removeLine('3')">
<img src="images/trash.gif" width="20" height="16" align="middle" alt="Delete" border="0"></a></td></tr>
<tr bordercolor="#C0C0C0" align="center"><td width="41">
<select name="pe4" onChange="changePolicy(this,'4',this.selectedIndex+1)">
<option>1</option><option>2</option><option>3</option><option selected>4</option><option>5</option></select></td><td width="38">
<input type="checkbox" name="enablePolicy" value="4" onClick="enableLine(this,'4')" checked></td>
<td><font color="#990000">Deny</font></td>
<td>FTP [21]</td>
<td>DMZ</td>
<td>Any</td>
<td>Any</td>
<td>Always</td>
<td bordercolor="#C0C0C0"> </td>
<td>
<input type="button" name="Button" value="Edit" onClick="editLine('4')"></td>
<td> <a href="javascript: removeLine('4')">
<img src="images/trash.gif" width="20" height="16" align="middle" alt="Delete" border="0"></a></td></tr>
<tr bordercolor="#C0C0C0" align="center"><td width="41">
<select name="pe5" onChange="changePolicy(this,'5',this.selectedIndex+1)">
<option>1</option><option>2</option><option>3</option><option>4</option><option selected>5</option></select></td><td width="38">
<input type="checkbox" name="enablePolicy" value="5" onClick="enableLine(this,'5')" checked></td>
<td><font color="#009900">Allow</font></td>
<td>DNS [53]</td>
<td>DMZ</td>
<td>10.0.0.0 ~ 10.255.255.255</td>
<td>Any</td>
<td>Always</td>
<td bordercolor="#C0C0C0"> </td>
<td>
<input type="button" name="Button" value="Edit" onClick="editLine('5')"></td>
<td> <a href="javascript: removeLine('5')">
<img src="images/trash.gif" width="20" height="16" align="middle" alt="Delete" border="0"></a></td></tr>
<tr bordercolor="#C0C0C0" align="center"><td width="41">
&nbsp;</td><td width="38">
<input type="checkbox" checked disabled></td>
<td><font color="#009900">Allow</font></td>
<td>All Traffic [0]</td>
<td>LAN</td>
<td>Any</td>
<td>Any</td>
<td>Always</td>
<td bordercolor="#C0C0C0"> </td>
<td>
&nbsp;</td>
<td>&nbsp;</td></tr>
<tr bordercolor="#C0C0C0" align="center"><td width="41">
&nbsp;</td><td width="38">
<input type="checkbox" checked disabled></td>
<td><font color="#990000">Deny</font></td>
<td>All Traffic [0]</td>
<td>WAN</td>
<td>Any</td>
<td>Any</td>
<td>Always</td>
<td bordercolor="#C0C0C0"> </td>
<td>
&nbsp;</td>
<td>&nbsp;</td></tr>
<tr bordercolor="#C0C0C0" align="center"><td width="41">
&nbsp;</td><td width="38">
<input type="checkbox" checked disabled></td>
<td><font color="#990000">Deny</font></td>
<td>All Traffic [0]</td>
<td>DMZ</td>
<td>Any</td>
<td>Any</td>
<td>Always</td>
<td bordercolor="#C0C0C0"> </td>
<td>
&nbsp;</td>
<td>&nbsp;</td></tr>

            </table>
          </center>
          <br>
		  <table width="98%" align="center">
            <tr> 
              <td width="3%">&nbsp;</td>
              <td align="right" width="43%"><font size="+0"> 
                <input type="button" value="Add New Rule" name="B3" onClick="chTotalRules(this.form)">
                </font></td>
              <td align="center" width="2%">&nbsp;</td>
              <td width="44%" align="left"> 
                <input type="button" name="btnDefault" value="Restore to Default Rules" onClick="defaultRules()">
              </td>
              <td width="8%">&nbsp;</td>
            </tr>
          </table>

          </font> 
		  <br>
          <br>
          <br>
        </td>
        <td height="150"></td>
      </tr>
      <tr> 
        <td valign="bottom" rowspan="2" bgcolor="#6666CC" align="right"><img src="images_rv042/cisco.gif" width="136" height="62"></td>
        <td height="37"></td>
      </tr>
      <tr> 
        <td height="25" colspan="2" valign="top" bgcolor="#000000" bordercolor="#E7E7E7" bordercolorlight="#E7E7E7" bordercolordark="#E7E7E7">&nbsp; 
        </td>
        <td valign="top" bgcolor="#6666CC" bordercolor="#E7E7E7" bordercolorlight="#E7E7E7" bordercolordark="#E7E7E7">&nbsp;</td>
        <td valign="top" bgcolor="#6666CC" bordercolor="#E7E7E7" bordercolorlight="#E7E7E7" bordercolordark="#E7E7E7">&nbsp; 
        </td>
        <td valign="top" bgcolor="#6666CC" bordercolor="#E7E7E7" bordercolorlight="#E7E7E7" bordercolordark="#E7E7E7">&nbsp;</td>
        <td valign="top" bgcolor="#000000"> 
          <div align="center"> 
            <center>
            </center>
          </div>
        </td>
        <td></td>
      </tr>
    </form>
  </table>
    
            </div></body>

</html>
END_FILTERS

our $services = <<'END_SERVICES';
 
<html>
<head>
<title>Service Management</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

<style type="text/css">
body {font-family: Arial, Verdana, sans-serif, Helvetica; background-color: #ffffff;}
td, th, input, select {font-size: 11px}
</style>

<script src="nk20060810141951.js"></script> <!--<script src="nk.js"></script>-->
<script src="lg20060810141951.js"></script> <!--<script src="lg.js"></script>-->
<script language=JavaScript>
function MM_reloadPage(init) {  //reloads the window if Nav4 resized
  if (init==true) with (navigator) {if ((appName=="Netscape")&&(parseInt(appVersion)==4)) {
    document.MM_pgW=innerWidth; document.MM_pgH=innerHeight; onresize=MM_reloadPage; }}
  else if (innerWidth!=document.MM_pgW || innerHeight!=document.MM_pgH) location.reload();
}
MM_reloadPage(true);


function MM_findObj(n, d) { //v4.0
  var p,i,x;  if(!d) d=document; if((p=n.indexOf("?"))>0&&parent.frames.length) {
    d=parent.frames[n.substring(p+1)].document; n=n.substring(0,p);}
  if(!(x=d[n])&&d.all) x=d.all[n]; for (i=0;!x&&i<d.forms.length;i++) x=d.forms[i][n];
  for(i=0;!x&&d.layers&&i<d.layers.length;i++) x=MM_findObj(n,d.layers[i].document);
  if(!x && document.getElementById) x=document.getElementById(n); return x;
}

function MM_showHideLayers() { //v3.0
  var i,p,v,obj,args=MM_showHideLayers.arguments;
  for (i=0; i<(args.length-2); i+=3) if ((obj=MM_findObj(args[i]))!=null) { v=args[i+2];
    if (obj.style) { obj=obj.style; v=(v=='show')?'visible':(v='hide')?'hidden':v; }
    obj.visibility=v; }
}


var sID=0;
function falseSubmit(F)
{
  F.submitStatus.value=0; 
      MM_showHideLayers('AutoNumber15','','hide');  
  F.submit();
}
function tmpWord(n)
{
  this.length=n;
  for (var i=1; i<=n; i++)
  this[i]=0;
  return this;
}

function delSel(s,I)
{
  var z;  
  var k;

  if (s.length > 0)
  {
    tmp=new tmpWord(s.length);
    tmpChanged=new tmpWord(s.length); 
    opvtmp=new tmpWord(s.length);
    opvtmpChanged=new tmpWord(s.length); 

    for (var i=0; i < s.length; i++)
	{
	  tmp[i+1]=s.options[i].text;
	  opvtmp[i+1]=s.options[i].value;
	}	

    for (var i=0; i < s.length; i++)
	{
/*-------------------------------------------------------*/	
	  if (s.options[i].selected==true)
	  { 
		    s.options[i].text="";
		    s.options[i].value="";
	        tmp[i+1]=" ";
	        opvtmp[i+1]=" ";		
		    s.options[i].selected=false;	
	  }
/*------------------------------------------------------*/	  
	}
	k=1;
	z=0;
    for (var j=1; j<=s.length; j++) 
	{ 
	     if (tmp[j]!=" ") 
         {
	            tmpChanged[k]=tmp[j];
     	        opvtmpChanged[k]=opvtmp[j];
        		k++;
         }
		 else
		 {
		 		z++;
		 }
    }
    for (var i=0; i < s.length-z; i++)
	{
 	    s.options[i].text=tmpChanged[i+1]; 
 	    s.options[i].value=opvtmpChanged[i+1];  	 
	}
    s.length-=z;
  }
  clearContent(s.form,I); 
}

function ckStatus(F,ad,I)
{
//  if (ad.value=="Update this service") clearContent(F,I);
}
function clearContent(F,I)
{
  if (I==F.deletePortRangeService)
  {
    F.addPortRangeService.disabled=false;  
    F.V_name.value="";
	F.V_protocol.options[0].selected=true;  
    F.V_portS.value="";
    F.V_portE.value="";
	if (F.upnpOpen.value=="1") F.Vpint.value="";

    for (var i=0; i < F.PortRangeList.length; i++)
    {
      F.PortRangeList.options[i].selected=false;
    }	    
    F.addPortRangeService.value=sAddtoList; 
    F.deletePortRangeService.disabled=true;  
	
	MM_showHideLayers('btnNew','','hidden'); 
	F.V_name.select(); 
  }
}
function exPosion(s)
{
  if (s.length > 0)
  {
    tmp=new tmpWord(s.length);
	tmpChanged=new tmpWord(s.length); 
    opvtmp=new tmpWord(s.length);
    opvtmpChanged=new tmpWord(s.length);
	 	
    for (var i=0; i < s.length; i++)
	{
	  tmp[i+1]=s.options[i].text;
	  opvtmp[i+1]=s.options[i].value;
	}	
		
    for (var i=0; i < s.length; i++)
	{
	  s.options[i].text=tmp[s.length-i];
	  s.options[i].value=opvtmp[s.length-i];
	}
	
    for (var i=0; i < s.length; i++)
	{
	    tmp[i+1]=" ";
		opvtmp[i+1]=" ";	

	}
  }
}

function selAll(s)
{
  if (s.length>0)
  {
    exPosion(s);
    for (var i=0; i < s.length; i++)
    s.options[i].selected=true;
  }
}

function showList(s)
{
  if (s.selectedIndex==-1) return;
  var p;
  var q; 
  var forwardString=s.options[s.selectedIndex].value; 
  var ssID=0;  
  var rightString;
  var tmpString;
  var ts=new tmpWord(6); 

  rightString=forwardString;
  q=rightString.length;      
  p=rightString.lastIndexOf("{");  
  ts[1]=rightString.substring(0,p);
  tmpString=rightString; 
  rightString=tmpString.substring(p+1,q);      


/*----------------------------------------------------*/  
    for (var j=2; j<=5; j++)
    {  
      q=rightString.length;
      p=rightString.indexOf(";");
      ts[j]=rightString.substring(0,p); 
      tmpString=rightString;
      rightString=tmpString.substring(p+1,q); 
    }
    q=rightString.length;
    p=rightString.indexOf("}");
    ts[6]=rightString.substring(0,p); 
    tmpString=rightString;
    rightString=tmpString.substring(p+1,q); 
/*-----------------------------------------------------*/  
    s.form.V_name.value=ts[1];
	sID=ts[2];
	ssID=parseInt(ts[2]);
	if (ts[3]==6) s.form.V_protocol.selectedIndex=0;
	if (ts[3]==17) s.form.V_protocol.selectedIndex=1;
	if (ts[3]==1) s.form.V_protocol.selectedIndex=2;
    s.form.V_portS.value=ts[4]; 
    s.form.V_portE.value=ts[5];  
	if (s.form.upnpOpen.value=="1") s.form.Vpint.value=ts[6]; 

    s.form.addPortRangeService.value=sUpdateService; 
	
	if (!(ssID>0 && ssID<33554432))
	{
      s.form.deletePortRangeService.disabled=false;
	  s.form.addPortRangeService.disabled=false;	
	}
	else
	{
	//It is default service, you can't delete it!
      s.form.deletePortRangeService.disabled=true;
	  s.form.addPortRangeService.disabled=true;	
    }
	
	MM_showHideLayers('btnNew','','show'); 
}
function PortRangeaddSel(aName,Pro,ePo1,ePo2,iPo,s) /* */
{
  var p=-1;
  var efP=0;
  var etP=0;

  var p1;
  var q; 
  var forwardString; 
  var rightString;
  var tmpString;
  var ts=new tmpWord(7); 
   
  if (aName.value=="")
  {
    alert(aServiceName);		
  }
  else if (ePo1.value=="" || ePo2.value=="")   
  {
    alert(aPortRange);	  
  }
  else
  {
    if (s.form.upnpOpen.value=="1")
    {
      if (iPo.value=="") 
	  {
	    alert(aPortInternal);
	    return;
	  }	  
    } 
	
	if (chValue(aName,Pro,ePo1,ePo2,iPo,s) < 0) return;
	 
    if (parseInt(ePo2.value)<parseInt(ePo1.value))   
    {
      efP=ePo1.value;
	  etP=ePo2.value;
	  ePo1.value=etP;
	  ePo2.value=efP;
    }

	if (s.form.addPortRangeService.value==sUpdateService)
    {
      p=-1;
      while (s.form.PortRangeList.options[++p].selected != true);

//      s.form.PortRangeList.options[p].selected=true;
//      delSel(s);
    }
	
    for (var i=1; i < document.formservice.PortRangeList.length; i++)
    {
          
            forwardString=s.options[i].value; 		  
  			rightString=forwardString;
  			q=rightString.length;      
  			p1=rightString.lastIndexOf("{");  
  			ts[1]=rightString.substring(0,p1);
  			tmpString=rightString; 
  			rightString=tmpString.substring(p1+1,q);      


/*----------------------------------------------------*/  
    		for (var j=2; j<=5; j++)
    		{  
      			q=rightString.length;
      			p1=rightString.indexOf(";");
      			ts[j]=rightString.substring(0,p1); 
      			tmpString=rightString;
      			rightString=tmpString.substring(p1+1,q); 
    		}
    		q=rightString.length;
    		p1=rightString.indexOf("}");
    		ts[6]=rightString.substring(0,p1); 
    		tmpString=rightString;
    		rightString=tmpString.substring(p1+1,q); 
/*-----------------------------------------------------*/  		  
		  
		   if ( ( (ts[3]=="6") && (Pro.selectedIndex==0) ) || ( (ts[3]=="17") && (Pro.selectedIndex==1) ) )
	       {
		       if ((eval(ePo1.value) >= eval(ts[4])) && (eval(ePo1.value) <= eval(ts[5]))
			   || (eval(ePo2.value) >= eval(ts[4])) && (eval(ePo2.value) <= eval(ts[5])))
			   {
			       if (p!=i)
				   {
//	2004/05/17	                   alert(aProtocolPortAlready);
//	2004/05/17	                   return;
				   }
			   }
			   
			   if ((eval(ts[4]) >= eval(ePo1.value)) && (eval(ts[4]) <= eval(ePo2.value))
			   || (eval(ts[5]) >= eval(ePo1.value)) && (eval(ts[5]) <= eval(ePo2.value)))
			   {
			       if (p!=i)
				   {
//	2004/05/17	                   alert(aProtocolPortAlready);
//	2004/05/17	                   return;
				   }
			   }
			   
	       }
    }
	
 	

    for (var i=0; i < s.form.PortRangeList.length; i++)
    {
        s.form.PortRangeList.options[i].selected=false;
    }
	
	if (s.form.addPortRangeService.value==sAddtoList) 
	{
  	   if (document.formservice.PortRangeList.length==100)
  	   {
          alert(aLimitService);
          return;
  	   } 	
	            
	    	   
       sID=0;
	   p=s.length;
	   s.length+=1;
	} 
    
    s.options[p].value=aName.value;
    s.options[p].value+="{";
    s.options[p].value+=sID;
    s.options[p].value+=";";	
    s.options[p].value+=Pro.value;
    s.options[p].value+=";";	
    s.options[p].value+=ePo1.value;
    s.options[p].value+=";";
    s.options[p].value+=ePo2.value;
    s.options[p].value+=";";
	if (s.form.upnpOpen.value=="1") s.options[p].value+=iPo.value; 
	else  s.options[p].value+="0"; 
	s.options[p].value+="}";   
    s.options[p].text=aName.value+"["+Pro.options[Pro.selectedIndex].text+"/"+ePo1.value+"~"+ePo2.value+"]";
    	
    clearContent(s.form,s.form.deletePortRangeService);
    s.form.deletePortRangeService.disabled=true;
  }  		
}
function chValue(aName,Pro,ePo1,ePo2,iPo,s)
{
    if (PortCheck(ePo1) < 0) return -1;
	if (PortCheck(ePo2) < 0) return -1;
	
    return 1;
}
function PortCheck(I)
{
  var d;
  d=parseInt(I.value,10);
  if (!(d<=65535 && d>0)) 
  {
    alert(aPortCheck);
//    I.value=I.defaultValue;
    I.select();
    return -1;    
  }
  I.value=d;
  return 1;
}

function chSubmit(F)
{
  selAll(F.PortRangeList); 
  opener.closeService(); 
  window.status=wSave; 
      MM_showHideLayers('AutoNumber15','','hide');  
  F.submit();
}

function addtoList()
{
/* ckNameList  onFocus="this.select();" onBlur=" ckName(this,this.form.PortRangeList);"*/   
  if (document.formservice.upnpOpen.value=="1")
  PortRangeaddSel(document.formservice.V_name,document.formservice.V_protocol,document.formservice.V_portS,document.formservice.V_portE,document.formservice.Vpint,document.formservice.PortRangeList);
  else
  PortRangeaddSel(document.formservice.V_name,document.formservice.V_protocol,document.formservice.V_portS,document.formservice.V_portE,"0",document.formservice.PortRangeList);
}


</script>
</head>

<body text="#000000">
<form name="formservice" method="post" action="service0.htm">
<input type="hidden" name="upnpOpen" value="0">
  <table width="450" height="255" align="center" bgcolor="#b5b5e6">
    <tr> 
      <td colspan="2" height="16">&nbsp; </td>
      <td colspan="3">&nbsp;</td>
    </tr>
    <tr align="center"> 
      <td valign="middle" width="3" height="16"> 
        <div align="center"></div>

      </td>
      <td valign="middle" width="164">Service Name</td>
      <td rowspan="9" valign="middle" colspan="2"> 
        <select multiple name="PortRangeList" size="15" onChange="showList(this.form.PortRangeList);" style="width: 100%">
          <option value="All Traffic{16777216;6;1;65535;0}">All Traffic [TCP&UDP/1~65535]</option><option value="DNS{16777217;17;53;53;0}">DNS [UDP/53~53]</option><option value="FTP{16777218;6;21;21;0}">FTP [TCP/21~21]</option><option value="HTTP{16777219;6;80;80;0}">HTTP [TCP/80~80]</option><option value="HTTP Secondary{16777220;6;8080;8080;0}">HTTP Secondary [TCP/8080~8080]</option><option value="HTTPS{16777221;6;443;443;0}">HTTPS [TCP/443~443]</option><option value="HTTPS Secondary{16777222;6;8443;8443;0}">HTTPS Secondary [TCP/8443~8443]</option><option value="TFTP{16777223;17;69;69;0}">TFTP [UDP/69~69]</option><option value="IMAP{16777224;6;143;143;0}">IMAP [TCP/143~143]</option><option value="NNTP{16777225;6;119;119;0}">NNTP [TCP/119~119]</option><option value="POP3{16777227;6;110;110;0}">POP3 [TCP/110~110]</option><option value="SNMP{16777228;17;161;161;0}">SNMP [UDP/161~161]</option><option value="SMTP{16777229;6;25;25;0}">SMTP [TCP/25~25]</option><option value="TELNET{16777230;6;23;23;0}">TELNET [TCP/23~23]</option><option value="TELNET Secondary{16777231;6;8023;8023;0}">TELNET Secondary [TCP/8023~8023]</option><option value="TELNETSSL{16777232;6;992;992;0}">TELNETSSL [TCP/992~992]</option><option value="DHCP{16777233;17;67;67;0}">DHCP [UDP/67~67]</option><option value="PPTP{134217728;6;1723;1723;0}">PPTP [TCP/1723~1723]</option><option value="IPSec{134217729;17;500;500;0}">IPSec [UDP/500~500]</option><option value="L2TP{134217730;17;1701;1701;0}">L2TP [UDP/1701~1701]</option>

        </select>
      </td>
      <td rowspan="9" valign="middle" width="3">&nbsp;</td>
    </tr>
    <tr align="center"> 
      <td valign="middle" width="3" height="29">&nbsp; </td>
      <td valign="middle" width="164"> 
        <input type="text" name="V_name" style="background-color: #FFFFCC;" maxlength="11" size="11" onFocus="this.select(); ckStatus(this.form,this.form.addPortRangeService,this.form.deletePortRangeService);">
      </td>

    </tr>
    <tr align="center"> 
      <td valign="middle" width="3" height="16">&nbsp;</td>
      <td valign="middle" width="164">&nbsp;</td>
    </tr>
    <tr align="center"> 
      <td valign="middle" width="3" height="16">&nbsp; </td>
      <td valign="middle" width="164">Protocol </td>
    </tr>

    <tr align="center"> 
      <td valign="middle" width="3" height="22">&nbsp; </td>
      <td valign="middle" width="164"> 
        <select name="V_protocol">
          <option value="6" selected>TCP</option>
          <option value="17">UDP</option>
        </select>
      </td>

    </tr>
    <tr align="center"> 
      <td valign="middle" width="3" height="16">&nbsp; </td>
      <td valign="middle" width="164">Port Range</td>
    </tr>
    <tr align="center"> 
      <td valign="top" width="3" height="29"> </td>
      <td valign="top" width="164"> 
        <input type="text" name="V_portS"              maxlength="5" onFocus="this.select();" size="5">

        to 
        <input type="text" name="V_portE"              maxlength="5" onFocus="this.select();" size="5">
      </td>
    </tr>
    <tr> 
      <td align="center" valign="middle" width="3" height="21">&nbsp; </td>
      <td align="center" valign="middle" width="164"> 
        <script>
if (document.formservice.upnpOpen.value=="1")
{
  document.write("Internal Port");	  
}	
</script>
      </td>

    </tr>
    <tr align="center"> 
      <td valign="top" width="3" height="43">&nbsp; </td>
      <td valign="top" width="164"> 
        <script>
if (document.formservice.upnpOpen.value=="1")
{	
  document.write('<input type="text" name="Vpint" maxlength="5" size="5" onFocus="this.select();" onBlur=" ');   
  document.write("if (this.value!='') PortCheck(this)");         
  document.write('">');      
}	
</script>
      </td>
    </tr>
    <tr> 
      <td width="3" height="16"> 
        <div align="center"> </div>

        <div align="center"> </div>
        <div align="center"> </div>
      </td>
      <td width="164">&nbsp;</td>
      <td colspan="2">&nbsp; </td>
      <td width="3">&nbsp;</td>
    </tr>

    <tr> 
      <td valign="middle" align="center" width="3" height="33">&nbsp; </td>
      <td valign="middle" align="center" width="164"> 
        <input type="button" name="addPortRangeService" value="Add to list" onClick="addtoList()">
      </td>
      <td valign="middle" align="right" width="169"> 
        <input type="button" name="deletePortRangeService" value="Delete selected service" onClick="delSel(this.form.PortRangeList,this);" disabled>
      </td>
      <td width="84" valign="middle" align="center"> <span id="btnNew" style="visibility: hidden"> 
        <input type="button" name="showNew" value="Add New" onClick="clearContent(this.form,this.form.deletePortRangeService)">

        </span> </td>
      <td valign="middle" align="center" width="3">&nbsp;</td>
    </tr>
    <tr> 
      <td colspan="5" valign="middle" align="center" height="21"> 
        <hr align="center" size="1" color="#6666CC" noshade width="98%">
      </td>
    </tr>
    <tr> 
      <td valign="middle" align="center" width="3" height="44"> <br>

        <br>
        <br>
      </td>
      <td valign="top" align="center" width="164"> 
        <input type="button" name="save" value="Save Setting" style="background-color: #42498C; color: #FFFFFF; font-size: 8pt; font-weight: 700; font-family: Arial;" onClick="chSubmit(this.form)">
      </td>
      <td valign="top" align="center" colspan="2"> 
        <input type="button" name="cancel" value="Cancel Changes" style="background-color: #42498C; color: #FFFFFF; font-size: 8pt; font-weight: 700; font-family: Arial;" onClick="document.location.reload();">
        &nbsp;&nbsp;&nbsp; 
        <input type="button" name="btnExit" value="   Exit   " style="background-color: #42498C; color: #FFFFFF; font-size: 8pt; font-weight: 700; font-family: Arial;" onClick="window.close()">

      </td>
      <td valign="middle" align="center" width="3">&nbsp;</td>
    </tr>
  </table>
</form>
</body>
</html>
END_SERVICES
1;