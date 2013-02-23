# contains a simple hash of vyatta command responses
package DataJUNOS;

use strict;
use warnings;
use Exporter 'import';
our @EXPORT_OK = qw($showRen $showFirewall $showVersion $showHardware $showUptime $showFeb $active $candidate $showInterfaces $showOspfInterface $showOspfOverview $showBgp $showOspf $snmp);

our $showRen =<<'END_SHOW_REN';
show chassis routing-engine 
Routing Engine status:
    Temperature                 28 degrees C / 82 degrees F
    CPU temperature             30 degrees C / 86 degrees F
    DRAM                       768 MB
    Memory utilization          13 percent
    CPU utilization:
      User                       0 percent
      Background                 0 percent
      Kernel                     0 percent
      Interrupt                  0 percent
      Idle                     100 percent
    Model                          RE-2.0
    Serial ID                      7d000007c7585001
    Start time                     2007-09-17 12:03:56 CDT
    Uptime                        350 days, 21 hours, 50 minutes, 14 seconds
    Load averages:                 1 minute   5 minute  15 minute
                                       0.07       0.02       0.00

testlab@DAL-M5> 
END_SHOW_REN

our $showHardware = <<'END_SHOW_HARDWARE';
show chassis hardware | display xml
<rpc-reply xmlns:junos="http://xml.juniper.net/junos/7.0R2/junos">
    <chassis-inventory xmlns="http://xml.juniper.net/junos/7.0R2/junos-chassis">
        <chassis junos:style="inventory">
            <name>Chassis</name>
            <serial-number>50412</serial-number>
            <description>M5</description>
            <chassis-module>
                <name>Midplane</name>
                <version>REV 03</version>
                <part-number>710-002650</part-number>
                <serial-number>HF1366</serial-number>
                <description>M5 Backplane</description>
            </chassis-module>
            <chassis-module>
                <name>Power Supply A</name>
                <version>Rev 04</version>
                <part-number>740-002497</part-number>
                <serial-number>MB10851</serial-number>
                <description>AC Power Supply</description>
            </chassis-module>
            <chassis-module>
                <name>Power Supply B</name>
                <version>Rev 04</version>
                <part-number>740-002497</part-number>
                <serial-number>MD12121</serial-number>
                <description>AC Power Supply</description>
            </chassis-module>
            <chassis-module>
                <name>Display</name>
                <version>REV 04</version>
                <part-number>710-001995</part-number>
                <serial-number>HF1093</serial-number>
                <description>M10 Display Board</description>
            </chassis-module>
            <chassis-module>
                <name>Routing Engine</name>
                <version>REV 04</version>
                <part-number>740-003877</part-number>
                <serial-number>9000016860</serial-number>
                <description>RE-2.0</description>
            </chassis-module>
            <chassis-module>
                <name>FEB</name>
                <version>REV 08</version>
                <part-number>710-002503</part-number>
                <serial-number>AL0635</serial-number>
                <description>Internet Processor IIv1</description>
            </chassis-module>
            <chassis-module>
                <name>FPC 0</name>
                <description>FPC</description>
                <chassis-sub-module>
                    <name>PIC 3</name>
                    <version>REV 04</version>
                    <part-number>750-002992</part-number>
                    <serial-number>HD0010</serial-number>
                    <description>4x F/E, 100 BASE-TX</description>
                </chassis-sub-module>
            </chassis-module>
        </chassis>
    </chassis-inventory>
    <cli>
        <banner></banner>
    </cli>
</rpc-reply>

testlab@DAL-M5>

END_SHOW_HARDWARE

our $showVersion = <<'END_SHOW_VERSION';
show version 
Hostname: DAL-M5
Model: m5
JUNOS Base OS boot [7.0R2.7]
JUNOS Base OS Software Suite [7.0R2.7]
JUNOS Kernel Software Suite [7.0R2.7]
JUNOS Packet Forwarding Engine Support (M5/M10) [7.0R2.7]
JUNOS Routing Software Suite [7.0R2.7]
JUNOS Online Documentation [7.0R2.7]
JUNOS Crypto Software Suite [7.0R2.7]

testlab@DAL-M5> 
END_SHOW_VERSION

our $showUptime = <<'END';
show system uptime 
Current time: 2007-04-25 15:23:55 CDT
System booted: 2007-03-08 10:09:09 CST (6w6d 04:14 ago)
Protocols started: 2007-03-08 10:10:49 CST (6w6d 04:13 ago)
Last configured: 2007-04-24 14:01:58 CDT (1d 01:21 ago) by ebasham
3:23PM CDT up 48 days,  4:15, 2 users, load averages: 0.08, 0.03, 0.00

testlab@DAL-M5> 
END

our $showFeb = <<'END';
show chassis feb 
FEB status:
  Temperature                        30 degrees C / 86 degrees F
  CPU utilization                     0 percent
  Interrupt utilization               0 percent
  Heap utilization                   51 percent
  Buffer utilization                 44 percent
  Total CPU DRAM                     32 MB
  Internet Processor II                 Version 1, Foundry IBM, Part number 9
  Start time:                           2007-03-08 10:11:49 CST
  Uptime:                              48 days, 4 hours, 12 minutes, 6 seconds

testlab@DAL-M5> 
END

our $candidate = <<'END';
show configuration 
version 7.0R2.7;
system {
    host-name DAL-M5;
    domain-name inside.eclyptic.com;
    time-zone America/Chicago;
    authentication-order tacplus;
    root-authentication {
        encrypted-password "$1$gxAppzHV$SipJNN1DqG9VnQhFEBsMG0"; ## SECRET-DATA
    }
    name-server {
        10.10.1.9;
    }
    tacplus-server {
        10.100.32.137 {
            secret "$9$MVtXxdaJDkmT7-Dk"; ## SECRET-DATA
            source-address 10.100.20.215;
        }
    }
    accounting {
        events change-log;
        destination {
            tacplus;
        }
    }
    login {
        message welcome;
        user ebasham {
            uid 2002;
            class super-user;
            authentication {
                encrypted-password brown23; ## SECRET-DATA
            }
        }
        user jerome {
            uid 2001;
            class superuser;
            authentication {
                encrypted-password "$1$EmWQNa5J$XgTPsRYuw8hTjOGaAwUKu."; ## SECRET-DATA
            }
        }
        user remote {
            uid 2003;
            class super-user;
        }
        user testlab {
            uid 2000;
            class super-user;
            authentication {
                encrypted-password "$1$mqNlDaHO$OefVYfKIu.OuiXqFbJ6xx/"; ## SECRET-DATA
            }
        }
    }
    services {
        ssh {
            root-login allow;
            protocol-version [ v2 v1 ];
            rate-limit 250;
        }
        telnet {
            connection-limit 250;
            rate-limit 250;
        }
    }
    syslog {
        user * {
            any emergency;
        }
        file messages {
            any notice;
            authorization info;
        }
    }
    ntp {
        peer 10.10.1.58;
        server 10.10.1.58;
        server 10.10.10.10;
    }
}
chassis {
    source-route;
}
interfaces {
    fe-0/3/0 {
        unit 0 {
            bandwidth 10m;
            family inet {
                address 10.100.20.45/30;
            }
            family mpls;
        }
    }
    fe-0/3/1 {
        unit 0 {
            bandwidth 4500000;
            family inet {
                address 10.100.20.21/30;
            }
            family mpls;
        }
    }
    fe-0/3/2 {
        unit 0 {
            family inet {
                address 10.100.20.41/30;
            }
            family mpls;
        }
    }
    fe-0/3/3 {
        unit 0 {
            bandwidth 10m;
            family inet {
                address 10.100.20.37/30;
            }
            family mpls;
        }
    }
    fxp0 {
        speed 10m;
        unit 0 {
            family inet;
        }
    }
    lo0 {
        unit 0 {
            family inet {
                address 10.100.20.215/32;
            }
            family iso;
        }
    }
}
snmp {
    description eric;
    location "the moon";
    contact "Robocop 2";
    community public {
        authorization read-only;
    }
    community testenv {
        authorization read-write;
        clients {
            10.100.32.53/32;
            10.0.0.0/32;
        }
    }
    trap-group config {
        targets {
            192.168.1.19;
            192.168.1.58;
        }
    }
}
routing-options {
    router-id 10.100.20.215;
    autonomous-system 200;
}
protocols {
    rsvp {
        interface all;
    }
    mpls {
        interface all;
    }
    bgp {
        group bgp-trial {
            type internal;
            local-address 10.100.20.215;
            neighbor 10.100.20.216;
            neighbor 10.100.20.222;
            neighbor 10.100.20.210;
            neighbor 10.100.20.213;
            neighbor 10.100.20.214;
            neighbor 10.100.20.221;
            neighbor 10.100.20.212;
        }
    }
    ospf {
        area 0.0.0.0 {
            interface all;
            interface fe-0/3/3.0;
            interface fe-0/3/2.0;
        }
    }
    ldp {
        interface all;
    }
}
policy-options {
    prefix-list net22 {
        22.0.0.0/8;
        23.5.0.0/16;
    }
    policy-statement from_ospf {
        from {
            protocol ospf;
            prefix-list net22;
        }
        then accept;
    }
    policy-statement from_other {
        term term_rick {
            from {
                protocol aggregate;
                route-filter 24.5.0.0/16 orlonger;
            }
            then accept;
        }
        from protocol [ direct static ];
        then accept;
    }
    policy-statement from_range {
        from {
            prefix-list net22;
        }
        then accept;
    }
    policy-statement cisco_network {
        from {
            prefix-list net22;
        }
        then accept;
    }
}
firewall {
    policer testpolicer {
        if-exceeding {
            bandwidth-limit 1m;
            burst-size-limit 356k;
        }
        then discard;
    }
    family inet {
        filter trial {
            term 1 {
                from {
                    address {
                        10.0.0.0/8;
                    }
                    protocol [ tcp udp ];
                }
                then accept;
            }
        }
    }
    filter testoutputfilter {
        term a {
            from {
                source-address {
                    0.0.0.0/32;
                }
                destination-address {
                    0.0.0.0/32;
                }
            }
            then policer testpolicer;
        }
    }
    filter testinputfilter {
        term a {
            from {
                source-address {
                    0.0.0.0/32;
                }
                destination-address {
                    0.0.0.0/32;
                }
            }
            then policer testpolicer;
        }
    }
}

testlab@DAL-M5> 
END

our $showOspfOverview =<<'END';
show ospf overview | display xml
<rpc-reply xmlns:junos="http://xml.juniper.net/junos/7.4R1/junos">
    <ospf-overview-information xmlns="http://xml.juniper.net/junos/7.4R1/junos-routing">
        <ospf-overview>
            <ospf-router-id>10.100.8.152</ospf-router-id>
            <ospf-full-spf-count>7</ospf-full-spf-count>
            <ospf-spf-delay>0.200000</ospf-spf-delay>
            <ospf-area-overview>
                <ospf-area>0.0.0.50</ospf-area>
                <ospf-stub-type>Not Stub</ospf-stub-type>
                <authentication-type>None</authentication-type>
                <ospf-abr-count>0</ospf-abr-count>
                <ospf-asbr-count>1</ospf-asbr-count>
                <ospf-nbr-overview>
                    <ospf-nbr-up-count>1</ospf-nbr-up-count>
                </ospf-nbr-overview>
            </ospf-area-overview>
        </ospf-overview>
    </ospf-overview-information>
    <cli>
        <banner></banner>
    </cli>
</rpc-reply>

testlab@RL-J4300>
END

our $showOspfInterface = <<'END';
show ospf interface detail | display xml
<rpc-reply xmlns:junos="http://xml.juniper.net/junos/7.0R2/junos">
    <ospf-interface-information xmlns="http://xml.juniper.net/junos/7.0R2/junos-routing">
        <ospf-interface>
            <interface-name>fe-0/3/0.0</interface-name>
            <ospf-interface-state>Down</ospf-interface-state>
            <ospf-area>0.0.0.0</ospf-area>
            <dr-id>0.0.0.0</dr-id>
            <bdr-id>0.0.0.0</bdr-id>
            <neighbor-count>0</neighbor-count>
            <interface-type>LAN</interface-type>
            <interface-address>10.100.20.45</interface-address>
            <address-mask>255.255.255.252</address-mask>
            <mtu>1500</mtu>
            <interface-cost>10</interface-cost>
            <adj-count>0</adj-count>
            <router-priority>128</router-priority>
            <hello-interval>10</hello-interval>
            <dead-interval>40</dead-interval>
            <retransmit-interval>5</retransmit-interval>
            <ospf-stub-type>Not Stub</ospf-stub-type>
            <authentication-type>None</authentication-type>
        </ospf-interface>
        <ospf-interface>
            <interface-name>fe-0/3/1.0</interface-name>
            <ospf-interface-state>DR</ospf-interface-state>
            <ospf-area>0.0.0.0</ospf-area>
            <dr-id>10.100.20.215</dr-id>
            <bdr-id>10.100.20.222</bdr-id>
            <neighbor-count>1</neighbor-count>
            <interface-type>LAN</interface-type>
            <interface-address>10.100.20.21</interface-address>
            <address-mask>255.255.255.252</address-mask>
            <mtu>1500</mtu>
            <interface-cost>22</interface-cost>
            <dr-address>10.100.20.21</dr-address>
            <bdr-address>10.100.20.22</bdr-address>
            <adj-count>1</adj-count>
            <router-priority>128</router-priority>
            <hello-interval>10</hello-interval>
            <dead-interval>40</dead-interval>
            <retransmit-interval>5</retransmit-interval>
            <ospf-stub-type>Not Stub</ospf-stub-type>
            <authentication-type>None</authentication-type>
        </ospf-interface>
        <ospf-interface>
            <interface-name>fe-0/3/2.0</interface-name>
            <ospf-interface-state>DR</ospf-interface-state>
            <ospf-area>0.0.0.0</ospf-area>
            <dr-id>10.100.20.215</dr-id>
            <bdr-id>10.100.26.1</bdr-id>
            <neighbor-count>1</neighbor-count>
            <interface-type>LAN</interface-type>
            <interface-address>10.100.20.41</interface-address>
            <address-mask>255.255.255.252</address-mask>
            <mtu>1500</mtu>
            <interface-cost>1</interface-cost>
            <dr-address>10.100.20.41</dr-address>
            <bdr-address>10.100.20.42</bdr-address>
            <adj-count>1</adj-count>
            <router-priority>128</router-priority>
            <hello-interval>10</hello-interval>
            <dead-interval>40</dead-interval>
            <retransmit-interval>5</retransmit-interval>
            <ospf-stub-type>Not Stub</ospf-stub-type>
            <authentication-type>None</authentication-type>
        </ospf-interface>
        <ospf-interface>
            <interface-name>fe-0/3/3.0</interface-name>
            <ospf-interface-state>DR</ospf-interface-state>
            <ospf-area>0.0.0.0</ospf-area>
            <dr-id>10.100.20.215</dr-id>
            <bdr-id>10.100.20.212</bdr-id>
            <neighbor-count>1</neighbor-count>
            <interface-type>LAN</interface-type>
            <interface-address>10.100.20.37</interface-address>
            <address-mask>255.255.255.252</address-mask>
            <mtu>1500</mtu>
            <interface-cost>10</interface-cost>
            <dr-address>10.100.20.37</dr-address>
            <bdr-address>10.100.20.38</bdr-address>
            <adj-count>1</adj-count>
            <router-priority>128</router-priority>
            <hello-interval>10</hello-interval>
            <dead-interval>40</dead-interval>
            <retransmit-interval>5</retransmit-interval>
            <ospf-stub-type>Not Stub</ospf-stub-type>
            <authentication-type>None</authentication-type>
        </ospf-interface>
        <ospf-interface>
            <interface-name>lo0.0</interface-name>
            <ospf-interface-state>DR</ospf-interface-state>
            <ospf-area>0.0.0.0</ospf-area>
            <dr-id>10.100.20.215</dr-id>
            <bdr-id>0.0.0.0</bdr-id>
            <neighbor-count>0</neighbor-count>
            <interface-type>LAN</interface-type>
            <interface-address>10.100.20.215</interface-address>
            <address-mask>255.255.255.255</address-mask>
            <mtu>65535</mtu>
            <interface-cost>0</interface-cost>
            <dr-address>10.100.20.215</dr-address>
            <adj-count>0</adj-count>
            <router-priority>128</router-priority>
            <hello-interval>10</hello-interval>
            <dead-interval>40</dead-interval>
            <retransmit-interval>5</retransmit-interval>
            <ospf-stub-type>Not Stub</ospf-stub-type>
            <authentication-type>None</authentication-type>
        </ospf-interface>
    </ospf-interface-information>
    <cli>
        <banner></banner>
    </cli>
</rpc-reply>

testlab@DAL-M5>
END

our $showBgp = <<'END';
 show bgp neighbor | display xml
<rpc-reply xmlns:junos="http://xml.juniper.net/junos/7.0R2/junos">
    <bgp-information xmlns="http://xml.juniper.net/junos/7.0R2/junos-routing">
        <bgp-peer junos:style="detail">
            <peer-address>10.100.20.210+179</peer-address>
            <peer-as>200</peer-as>
            <local-address>10.100.20.215+2731</local-address>
            <local-as>200</local-as>
            <peer-type>Internal</peer-type>
            <peer-state>Established</peer-state>
            <peer-flags>Sync</peer-flags>
            <last-state>OpenConfirm</last-state>
            <last-event>RecvKeepAlive</last-event>
            <last-error>Hold Timer Expired Error</last-error>
            <bgp-option-information xmlns="http://xml.juniper.net/junos/7.0R2/junos-routing">
                <bgp-options>Preference LocalAddress HoldTime Refresh</bgp-options>
                <bgp-options2></bgp-options2>
                <local-address>10.100.20.215</local-address>
                <holdtime>90</holdtime>
                <preference>170</preference>
            </bgp-option-information>
            <flap-count>4</flap-count>
            <bgp-error>
                <name>Hold Timer Expired Error</name>
                <send-count>4</send-count>
                <receive-count>0</receive-count>
            </bgp-error>
            <peer-id>10.100.20.210</peer-id>
            <local-id>10.100.20.215</local-id>
            <active-holdtime>90</active-holdtime>
            <keepalive-interval>30</keepalive-interval>
            <peer-index>0</peer-index>
            <nlri-type-peer>inet-unicast</nlri-type-peer>
            <nlri-type-session>inet-unicast</nlri-type-session>
            <peer-refresh-capability>2</peer-refresh-capability>
            <bgp-rib junos:style="detail">
                <name>inet.0</name>
                <rib-bit>10000</rib-bit>
                <bgp-rib-state>BGP restart is complete</bgp-rib-state>
                <send-state>in sync</send-state>
                <active-prefix-count>0</active-prefix-count>
                <received-prefix-count>0</received-prefix-count>
                <suppressed-prefix-count>0</suppressed-prefix-count>
                <advertised-prefix-count>0</advertised-prefix-count>
            </bgp-rib>
            <last-received>9</last-received>
            <last-sent>28</last-sent>
            <last-checked>28</last-checked>
            <input-messages>81340</input-messages>
            <input-updates>0</input-updates>
            <input-refreshes>0</input-refreshes>
            <input-octets>1545486</input-octets>
            <output-messages>81312</output-messages>
            <output-updates>0</output-updates>
            <output-refreshes>0</output-refreshes>
            <output-octets>1544982</output-octets>
            <bgp-output-queue>
                <number>0</number>
                <count>0</count>
            </bgp-output-queue>
        </bgp-peer>
        <bgp-peer junos:style="detail">
            <peer-address>10.100.20.212+20549</peer-address>
            <peer-as>200</peer-as>
            <local-address>10.100.20.215+179</local-address>
            <local-as>200</local-as>
            <peer-type>Internal</peer-type>
            <peer-state>Established</peer-state>
            <peer-flags>Sync</peer-flags>
            <last-state>OpenConfirm</last-state>
            <last-event>RecvKeepAlive</last-event>
            <last-error>Hold Timer Expired Error</last-error>
            <bgp-option-information xmlns="http://xml.juniper.net/junos/7.0R2/junos-routing">
                <bgp-options>Preference LocalAddress HoldTime Refresh</bgp-options>
                <bgp-options2></bgp-options2>
                <local-address>10.100.20.215</local-address>
                <holdtime>90</holdtime>
                <preference>170</preference>
            </bgp-option-information>
            <flap-count>4</flap-count>
            <bgp-error>
                <name>Hold Timer Expired Error</name>
                <send-count>3</send-count>
                <receive-count>0</receive-count>
            </bgp-error>
            <peer-id>10.100.20.212</peer-id>
            <local-id>10.100.20.215</local-id>
            <active-holdtime>90</active-holdtime>
            <keepalive-interval>30</keepalive-interval>
            <peer-index>1</peer-index>
            <nlri-type-peer>inet-unicast</nlri-type-peer>
            <nlri-type-session>inet-unicast</nlri-type-session>
            <peer-refresh-capability>2</peer-refresh-capability>
            <bgp-rib junos:style="detail">
                <name>inet.0</name>
                <rib-bit>10000</rib-bit>
                <bgp-rib-state>BGP restart is complete</bgp-rib-state>
                <send-state>in sync</send-state>
                <active-prefix-count>0</active-prefix-count>
                <received-prefix-count>0</received-prefix-count>
                <suppressed-prefix-count>0</suppressed-prefix-count>
                <advertised-prefix-count>0</advertised-prefix-count>
            </bgp-rib>
            <last-received>23</last-received>
            <last-sent>28</last-sent>
            <last-checked>28</last-checked>
            <input-messages>81331</input-messages>
            <input-updates>0</input-updates>
            <input-refreshes>0</input-refreshes>
            <input-octets>1545315</input-octets>
            <output-messages>81299</output-messages>
            <output-updates>0</output-updates>
            <output-refreshes>0</output-refreshes>
            <output-octets>1544707</output-octets>
            <bgp-output-queue>
                <number>0</number>
                <count>0</count>
            </bgp-output-queue>
        </bgp-peer>
        <bgp-peer junos:style="detail">
            <peer-address>10.100.20.213+179</peer-address>
            <peer-as>200</peer-as>
            <local-address>10.100.20.215+1542</local-address>
            <local-as>200</local-as>
            <peer-type>Internal</peer-type>
            <peer-state>Established</peer-state>
            <peer-flags>Sync</peer-flags>
            <last-state>OpenConfirm</last-state>
            <last-event>RecvKeepAlive</last-event>
            <last-error>Hold Timer Expired Error</last-error>
            <bgp-option-information xmlns="http://xml.juniper.net/junos/7.0R2/junos-routing">
                <bgp-options>Preference LocalAddress HoldTime Refresh</bgp-options>
                <bgp-options2></bgp-options2>
                <local-address>10.100.20.215</local-address>
                <holdtime>90</holdtime>
                <preference>170</preference>
            </bgp-option-information>
            <flap-count>26</flap-count>
            <bgp-error>
                <name>Hold Timer Expired Error</name>
                <send-count>25</send-count>
                <receive-count>0</receive-count>
            </bgp-error>
            <peer-id>10.100.20.213</peer-id>
            <local-id>10.100.20.215</local-id>
            <active-holdtime>90</active-holdtime>
            <keepalive-interval>30</keepalive-interval>
            <peer-index>3</peer-index>
            <nlri-type-peer>inet-unicast</nlri-type-peer>
            <nlri-type-session>inet-unicast</nlri-type-session>
            <peer-refresh-capability>2</peer-refresh-capability>
            <bgp-rib junos:style="detail">
                <name>inet.0</name>
                <rib-bit>10000</rib-bit>
                <bgp-rib-state>BGP restart is complete</bgp-rib-state>
                <send-state>in sync</send-state>
                <active-prefix-count>0</active-prefix-count>
                <received-prefix-count>0</received-prefix-count>
                <suppressed-prefix-count>0</suppressed-prefix-count>
                <advertised-prefix-count>0</advertised-prefix-count>
            </bgp-rib>
            <last-received>11</last-received>
            <last-sent>19</last-sent>
            <last-checked>19</last-checked>
            <input-messages>81339</input-messages>
            <input-updates>0</input-updates>
            <input-refreshes>0</input-refreshes>
            <input-octets>1545467</input-octets>
            <output-messages>81310</output-messages>
            <output-updates>0</output-updates>
            <output-refreshes>0</output-refreshes>
            <output-octets>1544944</output-octets>
            <bgp-output-queue>
                <number>0</number>
                <count>0</count>
            </bgp-output-queue>
        </bgp-peer>
        <bgp-peer junos:style="detail">
            <peer-address>10.100.20.214+46317</peer-address>
            <peer-as>200</peer-as>
            <local-address>10.100.20.215+179</local-address>
            <local-as>200</local-as>
            <peer-type>Internal</peer-type>
            <peer-state>Established</peer-state>
            <peer-flags>Sync</peer-flags>
            <last-state>OpenConfirm</last-state>
            <last-event>RecvKeepAlive</last-event>
            <last-error>Hold Timer Expired Error</last-error>
            <bgp-option-information xmlns="http://xml.juniper.net/junos/7.0R2/junos-routing">
                <bgp-options>Preference LocalAddress HoldTime Refresh</bgp-options>
                <bgp-options2></bgp-options2>
                <local-address>10.100.20.215</local-address>
                <holdtime>90</holdtime>
                <preference>170</preference>
            </bgp-option-information>
            <flap-count>5</flap-count>
            <bgp-error>
                <name>Hold Timer Expired Error</name>
                <send-count>3</send-count>
                <receive-count>0</receive-count>
            </bgp-error>
            <peer-id>10.100.20.214</peer-id>
            <local-id>10.100.20.215</local-id>
            <active-holdtime>90</active-holdtime>
            <keepalive-interval>30</keepalive-interval>
            <peer-index>4</peer-index>
            <nlri-type-peer>inet-unicast</nlri-type-peer>
            <nlri-type-session>inet-unicast</nlri-type-session>
            <peer-refresh-capability>2</peer-refresh-capability>
            <bgp-rib junos:style="detail">
                <name>inet.0</name>
                <rib-bit>10000</rib-bit>
                <bgp-rib-state>BGP restart is complete</bgp-rib-state>
                <send-state>in sync</send-state>
                <active-prefix-count>0</active-prefix-count>
                <received-prefix-count>0</received-prefix-count>
                <suppressed-prefix-count>0</suppressed-prefix-count>
                <advertised-prefix-count>0</advertised-prefix-count>
            </bgp-rib>
            <last-received>16</last-received>
            <last-sent>28</last-sent>
            <last-checked>28</last-checked>
            <input-messages>81332</input-messages>
            <input-updates>0</input-updates>
            <input-refreshes>0</input-refreshes>
            <input-octets>1545334</input-octets>
            <output-messages>81298</output-messages>
            <output-updates>0</output-updates>
            <output-refreshes>0</output-refreshes>
            <output-octets>1544688</output-octets>
            <bgp-output-queue>
                <number>0</number>
                <count>0</count>
            </bgp-output-queue>
        </bgp-peer>
        <bgp-peer junos:style="detail">
            <peer-address>10.100.20.216</peer-address>
            <peer-as>200</peer-as>
            <local-address>10.100.20.215</local-address>
            <local-as>0</local-as>
            <peer-type>Internal</peer-type>
            <peer-state>Active</peer-state>
            <peer-flags></peer-flags>
            <last-state>Idle</last-state>
            <last-event>Start</last-event>
            <last-error>Hold Timer Expired Error</last-error>
            <bgp-option-information xmlns="http://xml.juniper.net/junos/7.0R2/junos-routing">
                <bgp-options>Preference LocalAddress HoldTime Refresh</bgp-options>
                <bgp-options2></bgp-options2>
                <local-address>10.100.20.215</local-address>
                <holdtime>90</holdtime>
                <preference>170</preference>
            </bgp-option-information>
            <flap-count>1</flap-count>
            <bgp-error>
                <name>Hold Timer Expired Error</name>
                <send-count>1</send-count>
                <receive-count>0</receive-count>
            </bgp-error>
        </bgp-peer>
        <bgp-peer junos:style="detail">
            <peer-address>10.100.20.221+179</peer-address>
            <peer-as>200</peer-as>
            <local-address>10.100.20.215+4998</local-address>
            <local-as>200</local-as>
            <peer-type>Internal</peer-type>
            <peer-state>Established</peer-state>
            <peer-flags>Sync</peer-flags>
            <last-state>OpenConfirm</last-state>
            <last-event>RecvKeepAlive</last-event>
            <last-error>Hold Timer Expired Error</last-error>
            <bgp-option-information xmlns="http://xml.juniper.net/junos/7.0R2/junos-routing">
                <bgp-options>Preference LocalAddress HoldTime Refresh</bgp-options>
                <bgp-options2></bgp-options2>
                <local-address>10.100.20.215</local-address>
                <holdtime>90</holdtime>
                <preference>170</preference>
            </bgp-option-information>
            <flap-count>11</flap-count>
            <bgp-error>
                <name>Hold Timer Expired Error</name>
                <send-count>8</send-count>
                <receive-count>0</receive-count>
            </bgp-error>
            <peer-id>10.100.20.221</peer-id>
            <local-id>10.100.20.215</local-id>
            <active-holdtime>90</active-holdtime>
            <keepalive-interval>30</keepalive-interval>
            <peer-index>2</peer-index>
            <nlri-type-peer>inet-unicast</nlri-type-peer>
            <nlri-type-session>inet-unicast</nlri-type-session>
            <peer-refresh-capability>2</peer-refresh-capability>
            <bgp-rib junos:style="detail">
                <name>inet.0</name>
                <rib-bit>10000</rib-bit>
                <bgp-rib-state>BGP restart is complete</bgp-rib-state>
                <send-state>in sync</send-state>
                <active-prefix-count>0</active-prefix-count>
                <received-prefix-count>0</received-prefix-count>
                <suppressed-prefix-count>0</suppressed-prefix-count>
                <advertised-prefix-count>0</advertised-prefix-count>
            </bgp-rib>
            <last-received>16</last-received>
            <last-sent>28</last-sent>
            <last-checked>28</last-checked>
            <input-messages>81338</input-messages>
            <input-updates>0</input-updates>
            <input-refreshes>0</input-refreshes>
            <input-octets>1545448</input-octets>
            <output-messages>81311</output-messages>
            <output-updates>0</output-updates>
            <output-refreshes>0</output-refreshes>
            <output-octets>1544963</output-octets>
            <bgp-output-queue>
                <number>0</number>
                <count>0</count>
            </bgp-output-queue>
        </bgp-peer>
        <bgp-peer junos:style="detail">
            <peer-address>10.100.20.222</peer-address>
            <peer-as>200</peer-as>
            <local-address>10.100.20.215</local-address>
            <local-as>0</local-as>
            <peer-type>Internal</peer-type>
            <peer-state>Active</peer-state>
            <peer-flags></peer-flags>
            <last-state>Idle</last-state>
            <last-event>Start</last-event>
            <last-error>Hold Timer Expired Error</last-error>
            <bgp-option-information xmlns="http://xml.juniper.net/junos/7.0R2/junos-routing">
                <bgp-options>Preference LocalAddress HoldTime Refresh</bgp-options>
                <bgp-options2></bgp-options2>
                <local-address>10.100.20.215</local-address>
                <holdtime>90</holdtime>
                <preference>170</preference>
            </bgp-option-information>
            <flap-count>5</flap-count>
            <bgp-error>
                <name>Hold Timer Expired Error</name>
                <send-count>2</send-count>
                <receive-count>0</receive-count>
            </bgp-error>
        </bgp-peer>
    </bgp-information>
    <cli>
        <banner></banner>
    </cli>
</rpc-reply>

testlab@DAL-M5>
END

our $showOspf = <<'END';
show configuration protocols ospf | display xml
<rpc-reply xmlns:junos="http://xml.juniper.net/junos/7.0R2/junos">
    <configuration>
            <protocols>
                <ospf>
                    <area>
                        <name>0.0.0.0</name>
                        <interface>
                            <name>all</name>
                        </interface>
                        <interface>
                            <name>fe-0/3/3.0</name>
                        </interface>
                        <interface>
                            <name>fe-0/3/2.0</name>
                        </interface>
                    </area>
                </ospf>
            </protocols>
    </configuration>
    <cli>
        <banner></banner>
    </cli>
</rpc-reply>

testlab@DAL-M5>
END

our $active = <<'END';
file show /config/juniper.conf.gz 
version 7.0R2.7;
system {
    host-name DAL-M5;
    domain-name inside.eclyptic.com;
    time-zone America/Chicago;
    authentication-order tacplus;
    root-authentication {
        encrypted-password "$1$gxAppzHV$SipJNN1DqG9VnQhFEBsMG0";
    }
    name-server {
        10.10.1.9;
    }
    tacplus-server {
        10.100.32.137 {
            secret "$9$MVtXxdaJDkmT7-Dk";
            source-address 10.100.20.215;
        }
    }
    accounting {
        events change-log;
        destination {
            tacplus;
        }
    }
    login {
        message welcome;
        user ebasham {
            uid 2002;
            class super-user;
            authentication {
                encrypted-password brown23;
            }
        }
        user jerome {
            uid 2001;
            class superuser;
            authentication {
                encrypted-password "$1$EmWQNa5J$XgTPsRYuw8hTjOGaAwUKu.";
            }
        }
        user remote {
            uid 2003;
            class super-user;
        }
        user testlab {
            uid 2000;
            class super-user;
            authentication {
                encrypted-password "$1$mqNlDaHO$OefVYfKIu.OuiXqFbJ6xx/";
            }
        }
    }
    services {
        ssh {
            root-login allow;
            protocol-version [ v2 v1 ];
            rate-limit 250;
        }
        telnet {
            connection-limit 250;
            rate-limit 250;
        }
    }
    syslog {
        user * {
            any emergency;
        }
        file messages {
            any notice;
            authorization info;
        }
    }
    ntp {
        peer 10.10.1.58;
        server 10.10.1.58;
        server 10.10.10.10;
    }
}
chassis {
    source-route;
}
interfaces {
    fe-0/3/0 {
        unit 0 {
            bandwidth 10m;
            family inet {
                address 10.100.20.45/30;
            }
            family mpls;
        }
    }
    fe-0/3/1 {
        unit 0 {
            bandwidth 4500000;
            family inet {
                address 10.100.20.21/30;
            }
            family mpls;
        }
    }
    fe-0/3/2 {
        unit 0 {
            family inet {
                address 10.100.20.41/30;
            }
            family mpls;
        }
    }
    fe-0/3/3 {
        unit 0 {
            bandwidth 10m;
            family inet {
                address 10.100.20.37/30;
            }
            family mpls;
        }
    }
    fxp0 {
        speed 10m;
        unit 0 {
            family inet;
        }
    }
    lo0 {
        unit 0 {
            family inet {
                address 10.100.20.215/32;
            }
            family iso;
        }
    }
}
snmp {
    description eric;
    contact victor2;
    community public {
        authorization read-only;
    }
    community testenv {
        authorization read-write;
    }
}
routing-options {
    router-id 10.100.20.215;
    autonomous-system 200;
}
protocols {
    rsvp {
        interface all;
    }
    mpls {
        interface all;
    }
    bgp {
        group bgp-trial {
            type internal;
            local-address 10.100.20.215;
            neighbor 10.100.20.216;
            neighbor 10.100.20.222;
            neighbor 10.100.20.210;
            neighbor 10.100.20.213;
            neighbor 10.100.20.214;
            neighbor 10.100.20.221;
            neighbor 10.100.20.212;
        }
    }
    ospf {
        area 0.0.0.0 {
            interface all;
            interface fe-0/3/3.0;
            interface fe-0/3/2.0;
        }
    }
    ldp {
        interface all;
    }
}
policy-options {
    prefix-list net22 {
        22.0.0.0/8;
        23.5.0.0/16;
    }
    policy-statement from_ospf {
        from {
            protocol ospf;
            prefix-list net22;
        }
        then accept;
    }
    policy-statement from_other {
        term term_rick {
            from {
                protocol aggregate;
                route-filter 24.5.0.0/16 orlonger;
            }
            then accept;
        }
        from protocol [ direct static ];
        then accept;
    }
    policy-statement from_range {
        from {
            prefix-list net22;
        }
        then accept;
    }
    policy-statement cisco_network {
        from {
            prefix-list net22;
        }
        then accept;
    }
}
firewall {
    policer testpolicer {
        if-exceeding {
            bandwidth-limit 1m;
            burst-size-limit 356k;
        }
        then discard;
    }
    family inet {
        filter trial {
            term 1 {
                from {
                    address {
                        10.0.0.0/8;
                    }
                    protocol [ tcp udp ];
                }
                then accept;
            }
        }
    }
    filter testoutputfilter {
        term a {
            from {
                source-address {
                    0.0.0.0/32;
                }
                destination-address {
                    0.0.0.0/32;
                }
            }
            then policer testpolicer;
        }
    }
    filter testinputfilter {
        term a {
            from {
                source-address {
                    0.0.0.0/32;
                }
                destination-address {
                    0.0.0.0/32;
                }
            }
            then policer testpolicer;
        }
    }
}

testlab@DAL-M5> 
END

our $showFirewall = <<'END';
show configuration firewall | display xml
<rpc-reply xmlns:junos="http://xml.juniper.net/junos/7.0R2/junos">
    <configuration>
            <firewall>
                <policer>
                    <name>testpolicer</name>
                    <if-exceeding>
                        <bandwidth-limit>1m</bandwidth-limit>
                        <burst-size-limit>356k</burst-size-limit>
                    </if-exceeding>
                    <then>
                        <discard/>
                    </then>
                </policer>
                <family>
                    <inet>
                        <filter>
                            <name>trial</name>
                            <term>
                                <name>1</name>
                                <from>
                                    <address>
                                        <name>10.0.0.0/8</name>
                                    </address>
                                    <protocol>tcp</protocol>
                                    <protocol>udp</protocol>
                                </from>
                                <then>
                                    <accept/>
                                </then>
                            </term>
                            <term>
                                <name>2</name>
                                <from>
                                    <destination-address>
                                        <name>44.44.22.34/32</name>
                                    </destination-address>
                                    <port>1050-1070</port>
                                    <port>telnet</port>
                                </from>
                                <then>
                                    <log/>
                                    <accept/>
                                </then>
                            </term>
                            <term>
                                <name>3</name>
                                <from>
                                    <source-address>
                                        <name>192.55.12.0/25</name>
                                    </source-address>
                                    <destination-address>
                                        <name>68.3.0.0/32</name>
                                    </destination-address>
                                    <source-port>finger</source-port>
                                    <destination-port>ldap</destination-port>
                                </from>
                            </term>
                        </filter>
                    </inet>
                </family>
                <filter>
                    <name>testoutputfilter</name>
                    <term>
                        <name>a</name>
                        <from>
                            <source-address>
                                <name>0.0.0.0/32</name>
                            </source-address>
                            <destination-address>
                                <name>0.0.0.0/32</name>
                            </destination-address>
                        </from>
                        <then>
                            <policer>testpolicer</policer>
                        </then>
                    </term>
                </filter>
                <filter>
                    <name>testinputfilter</name>
                    <term>
                        <name>a</name>
                        <from>
                            <source-address>
                                <name>0.0.0.0/32</name>
                            </source-address>
                            <destination-address>
                                <name>0.0.0.0/32</name>
                            </destination-address>
                        </from>
                        <then>
                            <policer>testpolicer</policer>
                        </then>
                    </term>
                </filter>
                <filter>
                    <name>newguy</name>
                    <term>
                        <name>uno</name>
                        <from>
                            <source-address>
                                <name>88.44.22.0/32</name>
                            </source-address>
                            <source-address>
                                <name>99.44.22.1/32</name>
                            </source-address>
                            <port>snmp</port>
                        </from>
                        <then>
                            <reject>
                            </reject>
                        </then>
                    </term>
                    <term>
                        <name>dos</name>
                        <from>
                            <address>
                                <name>71.2.2.1/32</name>
                            </address>
                            <address>
                                <name>40.0.0.0/8</name>
                            </address>
                            <port>54</port>
                            <port>55</port>
                            <port>1055</port>
                            <port>1053</port>
                        </from>
                        <then>
                            <accept/>
                        </then>
                    </term>
                </filter>
            </firewall>
    </configuration>
    <cli>
        <banner></banner>
    </cli>
</rpc-reply>

testlab@DAL-M5>
END

our $showInterfaces = <<'END';
show interfaces | display xml | no-more 
<rpc-reply xmlns:junos="http://xml.juniper.net/junos/7.0R2/junos">
    <interface-information xmlns="http://xml.juniper.net/junos/7.0R2/junos-interface" junos:style="normal">
        <physical-interface>
            <name>fe-0/3/0</name>
            <admin-status junos:format="Enabled">up</admin-status>
            <oper-status>down</oper-status>
            <local-index>128</local-index>
            <snmp-index>39</snmp-index>
            <link-level-type>Ethernet</link-level-type>
            <mtu>1514</mtu>
            <source-filtering>disabled</source-filtering>
            <speed>100mbps</speed>
            <loopback>disabled</loopback>
            <if-flow-control>enabled</if-flow-control>
            <if-device-flags>
                <ifdf-present/>
                <ifdf-running/>
                <ifdf-down/>
            </if-device-flags>
            <if-config-flags>
                <iff-hardware-down/>
                <iff-snmp-traps/>
                <generic-value>16384</generic-value>
            </if-config-flags>
            <if-media-flags>
                <generic-value>4</generic-value>
            </if-media-flags>
            <physical-interface-cos-information>
                <physical-interface-cos-hw-max-queues>4</physical-interface-cos-hw-max-queues>
                <physical-interface-cos-use-max-queues>4</physical-interface-cos-use-max-queues>
            </physical-interface-cos-information>
            <current-physical-address>00:90:69:67:4c:5d</current-physical-address>
            <hardware-physical-address>00:90:69:67:4c:5d</hardware-physical-address>
            <interface-flapped junos:seconds="88674">2007-04-26 09:42:04 CDT (1d 00:37 ago)</interface-flapped>
            <traffic-statistics junos:style="brief">
                <input-bps>0</input-bps>
                <input-pps>0</input-pps>
                <output-bps>0</output-bps>
                <output-pps>0</output-pps>
            </traffic-statistics>
            <active-alarms>
                <interface-alarms>
                    <ethernet-alarm-link-down/>
                </interface-alarms>
            </active-alarms>
            <active-defects>
                <interface-alarms>
                    <ethernet-alarm-link-down/>
                </interface-alarms>
            </active-defects>
            <logical-interface>
                <name>fe-0/3/0.0</name>
                <local-index>67</local-index>
                <snmp-index>46</snmp-index>
                <if-config-flags>
                    <iff-device-down/>
                    <iff-snmp-traps/>
                </if-config-flags>
                <encapsulation>ENET2</encapsulation>
                <logical-interface-bandwidth>10mbps</logical-interface-bandwidth>
                <address-family>
                    <address-family-name>inet</address-family-name>
                    <mtu>1500</mtu>
                    <address-family-flags>
                        <ifff-none/>
                    </address-family-flags>
                    <interface-address>
                        <ifa-flags>
                            <ifaf-down/>
                            <ifaf-current-preferred/>
                            <ifaf-current-primary/>
                        </ifa-flags>
                        <ifa-destination>10.100.20.44/30</ifa-destination>
                        <ifa-local>10.100.20.45</ifa-local>
                        <ifa-broadcast>10.100.20.47</ifa-broadcast>
                    </interface-address>
                </address-family>
                <address-family>
                    <address-family-name>mpls</address-family-name>
                    <mtu>1488</mtu>
                    <address-family-flags>
                        <ifff-is-primary/>
                    </address-family-flags>
                </address-family>
            </logical-interface>
        </physical-interface>
        <physical-interface>
            <name>fe-0/3/1</name>
            <admin-status junos:format="Enabled">up</admin-status>
            <oper-status>up</oper-status>
            <local-index>129</local-index>
            <snmp-index>40</snmp-index>
            <link-level-type>Ethernet</link-level-type>
            <mtu>1514</mtu>
            <source-filtering>disabled</source-filtering>
            <speed>100mbps</speed>
            <loopback>disabled</loopback>
            <if-flow-control>enabled</if-flow-control>
            <if-device-flags>
                <ifdf-present/>
                <ifdf-running/>
            </if-device-flags>
            <if-config-flags>
                <iff-snmp-traps/>
                <generic-value>16384</generic-value>
            </if-config-flags>
            <if-media-flags>
                <generic-value>4</generic-value>
            </if-media-flags>
            <physical-interface-cos-information>
                <physical-interface-cos-hw-max-queues>4</physical-interface-cos-hw-max-queues>
                <physical-interface-cos-use-max-queues>4</physical-interface-cos-use-max-queues>
            </physical-interface-cos-information>
            <current-physical-address>00:90:69:67:4c:5e</current-physical-address>
            <hardware-physical-address>00:90:69:67:4c:5e</hardware-physical-address>
            <interface-flapped junos:seconds="927327">2007-04-16 16:44:31 CDT (1w3d 17:35 ago)</interface-flapped>
            <traffic-statistics junos:style="brief">
                <input-bps>5608</input-bps>
                <input-pps>14</input-pps>
                <output-bps>65312</output-bps>
                <output-pps>17</output-pps>
            </traffic-statistics>
            <active-alarms>
                <interface-alarms>
                    <alarm-not-present/>
                </interface-alarms>
            </active-alarms>
            <active-defects>
                <interface-alarms>
                    <alarm-not-present/>
                </interface-alarms>
            </active-defects>
            <logical-interface>
                <name>fe-0/3/1.0</name>
                <local-index>68</local-index>
                <snmp-index>44</snmp-index>
                <if-config-flags>
                    <iff-snmp-traps/>
                </if-config-flags>
                <encapsulation>ENET2</encapsulation>
                <logical-interface-bandwidth>4500kbps</logical-interface-bandwidth>
                <address-family>
                    <address-family-name>inet</address-family-name>
                    <mtu>1500</mtu>
                    <address-family-flags>
                        <ifff-none/>

                    </address-family-flags>
                    <interface-address>
                        <ifa-flags>
                            <ifaf-current-preferred/>
                            <ifaf-current-primary/>
                        </ifa-flags>
                        <ifa-destination>10.100.20.20/30</ifa-destination>
                        <ifa-local>10.100.20.21</ifa-local>
                        <ifa-broadcast>10.100.20.23</ifa-broadcast>
                    </interface-address>
                </address-family>
                <address-family>
                    <address-family-name>mpls</address-family-name>
                    <mtu>1488</mtu>
                    <address-family-flags>
                        <ifff-none/>
                    </address-family-flags>
                </address-family>
            </logical-interface>
        </physical-interface>
        <physical-interface>
            <name>fe-0/3/2</name>
            <admin-status junos:format="Enabled">up</admin-status>
            <oper-status>up</oper-status>
            <local-index>130</local-index>
            <snmp-index>41</snmp-index>
            <link-level-type>Ethernet</link-level-type>
            <mtu>1514</mtu>
            <source-filtering>disabled</source-filtering>
            <speed>100mbps</speed>
            <loopback>disabled</loopback>
            <if-flow-control>enabled</if-flow-control>
            <if-device-flags>
                <ifdf-present/>
                <ifdf-running/>
            </if-device-flags>
            <if-config-flags>
                <iff-snmp-traps/>
                <generic-value>16384</generic-value>
            </if-config-flags>
            <if-media-flags>
                <generic-value>4</generic-value>
            </if-media-flags>
            <physical-interface-cos-information>
                <physical-interface-cos-hw-max-queues>4</physical-interface-cos-hw-max-queues>
                <physical-interface-cos-use-max-queues>4</physical-interface-cos-use-max-queues>
            </physical-interface-cos-information>
            <current-physical-address>00:90:69:67:4c:5f</current-physical-address>
            <hardware-physical-address>00:90:69:67:4c:5f</hardware-physical-address>
            <interface-flapped junos:seconds="4316874">2007-03-08 10:12:04 CST (7w0d 23:07 ago)</interface-flapped>
            <traffic-statistics junos:style="brief">
                <input-bps>0</input-bps>
                <input-pps>0</input-pps>
                <output-bps>728</output-bps>
                <output-pps>1</output-pps>
            </traffic-statistics>
            <active-alarms>
                <interface-alarms>
                    <alarm-not-present/>
                </interface-alarms>
            </active-alarms>
            <active-defects>
                <interface-alarms>
                    <alarm-not-present/>
                </interface-alarms>
            </active-defects>
            <logical-interface>
                <name>fe-0/3/2.0</name>
                <local-index>69</local-index>
                <snmp-index>45</snmp-index>
                <if-config-flags>
                    <iff-snmp-traps/>
                </if-config-flags>
                <encapsulation>ENET2</encapsulation>
                <address-family>
                    <address-family-name>inet</address-family-name>
                    <mtu>1500</mtu>
                    <address-family-flags>
                        <ifff-none/>
                    </address-family-flags>
                    <interface-address>
                        <ifa-flags>
                            <ifaf-current-preferred/>
                            <ifaf-current-primary/>
                        </ifa-flags>
                        <ifa-destination>10.100.20.40/30</ifa-destination>
                        <ifa-local>10.100.20.41</ifa-local>
                        <ifa-broadcast>10.100.20.43</ifa-broadcast>
                    </interface-address>
                </address-family>
                <address-family>
                    <address-family-name>mpls</address-family-name>
                    <mtu>1488</mtu>
                    <address-family-flags>
                        <ifff-none/>
                    </address-family-flags>
                </address-family>
            </logical-interface>
        </physical-interface>
        <physical-interface>
            <name>fe-0/3/3</name>
            <admin-status junos:format="Enabled">up</admin-status>
            <oper-status>up</oper-status>
            <local-index>131</local-index>
            <snmp-index>42</snmp-index>
            <link-level-type>Ethernet</link-level-type>
            <mtu>1514</mtu>
            <source-filtering>disabled</source-filtering>
            <speed>100mbps</speed>
            <loopback>disabled</loopback>
            <if-flow-control>enabled</if-flow-control>
            <if-device-flags>
                <ifdf-present/>
                <ifdf-running/>
            </if-device-flags>
            <if-config-flags>
                <iff-snmp-traps/>
                <generic-value>16384</generic-value>
            </if-config-flags>
            <if-media-flags>
                <generic-value>4</generic-value>
            </if-media-flags>
            <physical-interface-cos-information>
                <physical-interface-cos-hw-max-queues>4</physical-interface-cos-hw-max-queues>
                <physical-interface-cos-use-max-queues>4</physical-interface-cos-use-max-queues>
            </physical-interface-cos-information>
            <current-physical-address>00:90:69:67:4c:60</current-physical-address>
            <hardware-physical-address>00:90:69:67:4c:60</hardware-physical-address>
            <interface-flapped junos:seconds="931981">2007-04-16 15:26:57 CDT (1w3d 18:53 ago)</interface-flapped>
            <traffic-statistics junos:style="brief">
                <input-bps>272</input-bps>
                <input-pps>0</input-pps>
                <output-bps>536</output-bps>
                <output-pps>0</output-pps>
            </traffic-statistics>
            <active-alarms>
                <interface-alarms>
                    <alarm-not-present/>
                </interface-alarms>
            </active-alarms>
            <active-defects>
                <interface-alarms>
                    <alarm-not-present/>
                </interface-alarms>
            </active-defects>
            <logical-interface>
                <name>fe-0/3/3.0</name>
                <local-index>70</local-index>
                <snmp-index>43</snmp-index>
                <if-config-flags>
                    <iff-snmp-traps/>
                </if-config-flags>
                <encapsulation>ENET2</encapsulation>
                <logical-interface-bandwidth>10mbps</logical-interface-bandwidth>
                <address-family>
                    <address-family-name>inet</address-family-name>
                    <mtu>1500</mtu>
                    <address-family-flags>
                        <ifff-none/>
                    </address-family-flags>
                    <interface-address>
                        <ifa-flags>
                            <ifaf-current-preferred/>
                            <ifaf-current-primary/>
                        </ifa-flags>
                        <ifa-destination>10.100.20.36/30</ifa-destination>
                        <ifa-local>10.100.20.37</ifa-local>
                        <ifa-broadcast>10.100.20.39</ifa-broadcast>
                    </interface-address>
                </address-family>
                <address-family>
                    <address-family-name>mpls</address-family-name>
                    <mtu>1488</mtu>
                    <address-family-flags>
                        <ifff-none/>
                    </address-family-flags>
                </address-family>
            </logical-interface>
        </physical-interface>
        <physical-interface>
            <name>dsc</name>
            <admin-status junos:format="Enabled">up</admin-status>
            <oper-status>up</oper-status>
            <local-index>5</local-index>
            <snmp-index>5</snmp-index>
            <if-type>Software-Pseudo</if-type>
            <mtu>Unlimited</mtu>
            <if-device-flags>
                <ifdf-present/>
                <ifdf-running/>
            </if-device-flags>
            <if-config-flags>
                <iff-snmp-traps/>
            </if-config-flags>
            <if-media-flags>
                <ifmf-none/>
            </if-media-flags>
            <interface-flapped junos:seconds="0">Never</interface-flapped>
            <traffic-statistics junos:style="brief">
                <input-packets>0</input-packets>
                <output-packets>0</output-packets>
            </traffic-statistics>
        </physical-interface>
        <physical-interface>
            <name>fxp0</name>
            <admin-status junos:format="Enabled">up</admin-status>
            <oper-status>down</oper-status>
            <local-index>1</local-index>
            <snmp-index>1</snmp-index>
            <if-type>Ethernet</if-type>
            <link-level-type>Ethernet</link-level-type>
            <mtu>1514</mtu>
            <speed>10m</speed>
            <if-device-flags>
                <ifdf-present/>
                <ifdf-running/>
                <ifdf-no-carrier/>
            </if-device-flags>
            <if-config-flags>
                <iff-hardware-down/>
                <iff-snmp-traps/>
            </if-config-flags>
            <link-type>Half-Duplex</link-type>
            <if-media-flags>
                <generic-value>4</generic-value>
            </if-media-flags>
            <current-physical-address junos:format="MAC 00:a0:a5:12:49:49">00:a0:a5:12:49:49</current-physical-address>
            <hardware-physical-address junos:format="MAC 00:a0:a5:12:49:49">00:a0:a5:12:49:49</hardware-physical-address>
            <interface-flapped junos:seconds="0">Never</interface-flapped>
            <traffic-statistics junos:style="brief">
                <input-packets>0</input-packets>
                <output-packets>0</output-packets>
            </traffic-statistics>
            <logical-interface>
                <name>fxp0.0</name>
                <local-index>1</local-index>
                <snmp-index>13</snmp-index>
                <if-config-flags>
                    <iff-device-down/>
                    <iff-snmp-traps/>
                </if-config-flags>
                <encapsulation>ENET2</encapsulation>
                <address-family>
                    <address-family-name>inet</address-family-name>
                    <mtu>1500</mtu>
                    <address-family-flags>
                        <ifff-is-primary/>
                    </address-family-flags>
                </address-family>
            </logical-interface>
        </physical-interface>
        <physical-interface>
            <name>fxp1</name>
            <admin-status junos:format="Enabled">up</admin-status>
            <oper-status>up</oper-status>
            <local-index>2</local-index>
            <snmp-index>2</snmp-index>
            <if-type>Ethernet</if-type>
            <link-level-type>Ethernet</link-level-type>
            <mtu>1514</mtu>
            <speed>100mbps</speed>
            <if-device-flags>
                <ifdf-present/>
                <ifdf-running/>
            </if-device-flags>
            <if-config-flags>
                <iff-snmp-traps/>
            </if-config-flags>
            <link-type>Full-Duplex</link-type>
            <if-media-flags>
                <generic-value>4</generic-value>
            </if-media-flags>
            <current-physical-address junos:format="MAC 00:a0:a5:12:49:48">00:a0:a5:12:49:48</current-physical-address>
            <hardware-physical-address junos:format="MAC 00:a0:a5:12:49:48">00:a0:a5:12:49:48</hardware-physical-address>
            <interface-flapped junos:seconds="0">Never</interface-flapped>
            <traffic-statistics junos:style="brief">
                <input-packets>22684702</input-packets>
                <output-packets>25744880</output-packets>
            </traffic-statistics>
            <logical-interface>
                <name>fxp1.0</name>
                <local-index>2</local-index>
                <snmp-index>14</snmp-index>
                <if-config-flags>
                    <iff-snmp-traps/>
                </if-config-flags>
                <encapsulation>ENET2</encapsulation>
                <address-family>
                    <address-family-name>tnp</address-family-name>
                    <mtu>1500</mtu>
                    <address-family-flags>
                        <ifff-primary/>
                        <ifff-is-primary/>
                    </address-family-flags>
                    <interface-address heading="Addresses">
                        <ifa-local>4</ifa-local>
                    </interface-address>
                </address-family>
            </logical-interface>
        </physical-interface>
        <physical-interface>
            <name>gre</name>
            <admin-status junos:format="Enabled">up</admin-status>
            <oper-status>up</oper-status>
            <local-index>9</local-index>
            <snmp-index>8</snmp-index>
            <if-type>GRE</if-type>
            <link-level-type>GRE</link-level-type>
            <mtu>Unlimited</mtu>
            <speed>Unlimited</speed>
            <if-device-flags>
                <ifdf-present/>
                <ifdf-running/>
            </if-device-flags>
            <if-config-flags>
                <iff-point-to-point/>
                <iff-snmp-traps/>
            </if-config-flags>
            <traffic-statistics junos:style="brief">
                <input-packets>0</input-packets>
                <output-packets>0</output-packets>
            </traffic-statistics>
        </physical-interface>
        <physical-interface>
            <name>ipip</name>
            <admin-status junos:format="Enabled">up</admin-status>
            <oper-status>up</oper-status>
            <local-index>10</local-index>
            <snmp-index>9</snmp-index>
            <if-type>IPIP</if-type>
            <link-level-type>IP-over-IP</link-level-type>
            <mtu>Unlimited</mtu>
            <speed>Unlimited</speed>
            <if-device-flags>
                <ifdf-present/>
                <ifdf-running/>
            </if-device-flags>
            <if-config-flags>
                <iff-snmp-traps/>
            </if-config-flags>
            <traffic-statistics junos:style="brief">
                <input-packets>0</input-packets>
                <output-packets>0</output-packets>
            </traffic-statistics>
        </physical-interface>
        <physical-interface>
            <name>lo0</name>
            <admin-status junos:format="Enabled">up</admin-status>
            <oper-status>up</oper-status>
            <local-index>6</local-index>
            <snmp-index>6</snmp-index>
            <if-type>Loopback</if-type>
            <mtu>Unlimited</mtu>
            <if-device-flags>
                <ifdf-present/>
                <ifdf-running/>
                <ifdf-loopback/>
            </if-device-flags>
            <if-config-flags>
                <iff-snmp-traps/>
            </if-config-flags>
            <if-media-flags>
                <ifmf-none/>
            </if-media-flags>
            <interface-flapped junos:seconds="0">Never</interface-flapped>
            <traffic-statistics junos:style="brief">
                <input-packets>1</input-packets>
                <output-packets>1</output-packets>
            </traffic-statistics>
            <logical-interface>
                <name>lo0.0</name>
                <local-index>64</local-index>
                <snmp-index>16</snmp-index>
                <if-config-flags>
                    <iff-snmp-traps/>
                </if-config-flags>
                <encapsulation>Unspecified</encapsulation>
                <traffic-statistics junos:style="brief">
                    <input-packets>1</input-packets>
                    <output-packets>1</output-packets>
                </traffic-statistics>
                <address-family>
                    <address-family-name>inet</address-family-name>
                    <mtu>Unlimited</mtu>
                    <address-family-flags>
                        <ifff-none/>
                    </address-family-flags>
                    <interface-address>
                        <ifa-flags>
                            <ifaf-current-default/>
                            <ifaf-current-primary/>
                        </ifa-flags>
                        <ifa-local>10.100.20.215</ifa-local>
                    </interface-address>
                </address-family>
                <address-family>
                    <address-family-name>iso</address-family-name>
                    <mtu>Unlimited</mtu>
                    <address-family-flags>
                        <ifff-none/>
                    </address-family-flags>
                </address-family>
            </logical-interface>
            <logical-interface>
                <name>lo0.16385</name>
                <local-index>66</local-index>
                <snmp-index>21</snmp-index>
                <if-config-flags>
                    <iff-snmp-traps/>
                </if-config-flags>
                <encapsulation>Unspecified</encapsulation>
                <traffic-statistics junos:style="brief">
                    <input-packets>0</input-packets>
                    <output-packets>0</output-packets>
                </traffic-statistics>
                <address-family>
                    <address-family-name>inet</address-family-name>
                    <mtu>Unlimited</mtu>
                    <address-family-flags>
                        <ifff-none/>
                    </address-family-flags>
                </address-family>
                <address-family>
                    <address-family-name>inet6</address-family-name>
                    <mtu>Unlimited</mtu>
                    <address-family-flags>
                        <ifff-none/>
                    </address-family-flags>
                    <interface-address heading="Addresses">
                        <ifa-local>fe80::2a0:a5ff:fe12:4949</ifa-local>
                    </interface-address>
                </address-family>
            </logical-interface>
        </physical-interface>
        <physical-interface>
            <name>lsi</name>
            <admin-status junos:format="Enabled">up</admin-status>
            <oper-status>up</oper-status>
            <local-index>4</local-index>
            <snmp-index>4</snmp-index>
            <if-type>Software-Pseudo</if-type>
            <link-level-type>LSI</link-level-type>
            <mtu>1496</mtu>
            <speed>Unlimited</speed>
            <if-device-flags>
                <ifdf-present/>
                <ifdf-running/>
            </if-device-flags>
            <if-config-flags>
                <iff-snmp-traps/>
            </if-config-flags>
            <if-media-flags>
                <ifmf-none/>
            </if-media-flags>
            <interface-flapped junos:seconds="0">Never</interface-flapped>
            <traffic-statistics junos:style="brief">
                <input-packets>0</input-packets>
                <output-packets>0</output-packets>
            </traffic-statistics>
        </physical-interface>
        <physical-interface>
            <name>mtun</name>
            <admin-status junos:format="Enabled">up</admin-status>
            <oper-status>up</oper-status>
            <local-index>66</local-index>
            <snmp-index>12</snmp-index>
            <if-type>Multicast-GRE</if-type>
            <link-level-type>GRE</link-level-type>
            <mtu>Unlimited</mtu>
            <speed>Unlimited</speed>
            <if-device-flags>
                <ifdf-present/>
                <ifdf-running/>
            </if-device-flags>
            <if-config-flags>
                <iff-snmp-traps/>
            </if-config-flags>
            <traffic-statistics junos:style="brief">
                <input-packets>0</input-packets>
                <output-packets>0</output-packets>
            </traffic-statistics>
        </physical-interface>
        <physical-interface>
            <name>pimd</name>
            <admin-status junos:format="Enabled">up</admin-status>
            <oper-status>up</oper-status>
            <local-index>65</local-index>
            <snmp-index>11</snmp-index>
            <if-type>PIMD</if-type>
            <link-level-type>PIM-Decapsulator</link-level-type>
            <mtu>Unlimited</mtu>
            <speed>Unlimited</speed>
            <if-device-flags>
                <ifdf-present/>
                <ifdf-running/>
            </if-device-flags>
            <if-config-flags>
                <iff-snmp-traps/>
            </if-config-flags>
            <traffic-statistics junos:style="brief">
                <input-packets>0</input-packets>
                <output-packets>0</output-packets>
            </traffic-statistics>
        </physical-interface>
        <physical-interface>
            <name>pime</name>
            <admin-status junos:format="Enabled">up</admin-status>
            <oper-status>up</oper-status>
            <local-index>64</local-index>
            <snmp-index>10</snmp-index>
            <if-type>PIME</if-type>
            <link-level-type>PIM-Encapsulator</link-level-type>
            <mtu>Unlimited</mtu>
            <speed>Unlimited</speed>
            <if-device-flags>
                <ifdf-present/>
                <ifdf-running/>
            </if-device-flags>
            <if-config-flags>
                <iff-snmp-traps/>
            </if-config-flags>
            <traffic-statistics junos:style="brief">
                <input-packets>0</input-packets>
                <output-packets>0</output-packets>
            </traffic-statistics>
        </physical-interface>
        <physical-interface>
            <name>tap</name>
            <admin-status junos:format="Enabled">up</admin-status>
            <oper-status>up</oper-status>
            <local-index>11</local-index>
            <snmp-index>7</snmp-index>
            <if-type>Software-Pseudo</if-type>
            <link-level-type>Interface-Specific</link-level-type>
            <mtu>Unlimited</mtu>
            <speed>Unlimited</speed>
            <if-device-flags>
                <ifdf-present/>
                <ifdf-running/>
            </if-device-flags>
            <if-config-flags>
                <iff-snmp-traps/>
            </if-config-flags>
            <if-media-flags>
                <ifmf-none/>
            </if-media-flags>
            <interface-flapped junos:seconds="0">Never</interface-flapped>
            <traffic-statistics junos:style="brief">
                <input-packets>0</input-packets>
                <output-packets>0</output-packets>
            </traffic-statistics>
        </physical-interface>
    </interface-information>
    <cli>
        <banner></banner>
    </cli>
</rpc-reply>

testlab@DAL-M5> 
END

our $snmp = <<'ENDSNMP';
testlab@DAL-M5> show configuration snmp | display xml
<rpc-reply xmlns:junos="http://xml.juniper.net/junos/7.0R2/junos">
    <configuration>
            <snmp>
                <description>eric</description>
                <location>testloc8</location>
                <contact>testcontact8</contact>
                <community>
                    <name>public</name>
                    <authorization>read-only</authorization>
                </community>
                <community>
                    <name>testenv</name>
                    <authorization>read-write</authorization>
                    <clients>
                        <name>10.100.32.53/32</name>
                    </clients>
                    <clients>
                        <name>10.0.0.0/32</name>
                    </clients>
                </community>
                <community>
                    <name>guPR7HexEs5unavU</name>
                    <authorization>read-only</authorization>
                    <clients>
                        <name>65.88.85.0/24</name>
                    </clients>
                </community>
                <community>
                    <name>Joemama</name>
                    <clients>
                        <name>65.88.66.0/24</name>
                    </clients>
                </community>
                <community>
                    <name>Ad354mgmt</name>
                    <authorization>read-only</authorization>
                    <clients>
                        <name>10.252.46.0/24</name>
                    </clients>
                    <clients>
                        <name>172.21.1.0/24</name>
                    </clients>
                    <clients>
                        <name>172.21.79.0/24</name>
                    </clients>
                    <clients>
                        <name>172.28.32.40/32</name>
                    </clients>
                </community>
                <community>
                    <name>public1</name>
                </community>
                <community>
                    <name>public2</name>
                    <authorization>read-write</authorization>
                </community>
                <community>
                    <name>public3</name>
                    <authorization>read-write</authorization>
                </community>
                <community>
                    <name>public6</name>
                    <authorization>read-write</authorization>
                </community>
                <community>
                    <name>public4</name>
                    <authorization>read-write</authorization>
                </community>
                <community>
                    <name>public7</name>
                    <authorization>read-write</authorization>
                </community>
                <trap-group>
                    <name>fred</name>
                    <categories>
                        <sonet-alarms>
                        </sonet-alarms>
                    </categories>
                    <targets>
                        <name>1.1.1.1</name>
                    </targets>
                </trap-group>
                <trap-group>
                    <name>test1</name>
                    <targets>
                        <name>2.2.2.2</name>
                    </targets>
                </trap-group>
                <trap-group>
                    <name>public7</name>
                    <targets>
                        <name>7.7.7.7</name>
                    </targets>
                </trap-group>
                <trap-group>
                    <name>public8</name>
                    <targets>
                        <name>8.8.8.8</name>
                    </targets>
                </trap-group>
            </snmp>
    </configuration>
    <cli>
        <banner></banner>
    </cli>
</rpc-reply>

testlab@DAL-M5>
ENDSNMP

1;
