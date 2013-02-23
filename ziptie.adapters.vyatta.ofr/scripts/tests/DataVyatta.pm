# contains a simple hash of vyatta command responses
package DataVyatta;

use strict;
use warnings;
use Exporter 'import';
our @EXPORT_OK = qw($interfaces $showVersion $showHostname $showHostOS $showMemory $config);

our $showVersion = <<'END_SHOW_VERSION';
testlab@vyatta> show version[C[C
Version:    VC2
Built by:   autobuild@vyatta.com
Built on:   200702080056 -- Thu Feb  8 00:56:19 UTC 2007
System booted: Tue Apr 17 19:23:10 UTC 2007
Uptime: 20:16:57 up 53 min,  3 users,  load average: 0.00, 0.00, 0.00
testlab@vyatta> 
END_SHOW_VERSION

our $showHostname = <<'END_SHOW_HOSTNAME';
testlab@vyatta> show host name[C[C
vyatta
testlab@vyatta>
END_SHOW_HOSTNAME

our $showHostOS = <<'END_SHOW_HOSTOS';
testlab@vyatta> show host os[C[C
Linux vyatta 2.6.16 #1 Wed Feb 7 15:05:17 PST 2007 i686 GNU/Linux
testlab@vyatta> 
END_SHOW_HOSTOS

our $showMemory = <<'END_SHOW_MEMORY';
testlab@vyatta> show system memory[C[C
             total       used       free     shared    buffers     cached
Mem:       2075420     147316    1928104          0      16548      72684
Swap:            0          0          0
Total:     2075420     147316    1928104
testlab@vyatta> 
END_SHOW_MEMORY

our $config = <<'END_SHOW_CONFIG';
testlab@vyatta# show -all | no-more[C[C
    protocols {
        bgp {
            bgp-id: 10.100.19.218
            local-as: 100
            peer "10.100.19.220" {
                peer-port: 179
                local-port: 179
                local-ip: 10.100.19.218
                as: 100
                next-hop: 10.100.19.9
                holdtime: 90
                delay-open-time: 0
                client: false
                confederation-member: false
                disable: false
                ipv4-unicast: true
                ipv4-multicast: false
                ipv6-unicast: false
                ipv6-multicast: false
            }
            peer "10.100.19.219" {
                peer-port: 179
                local-port: 179
                local-ip: 10.100.19.218
                as: 100
                next-hop: 10.100.19.13
                holdtime: 90
                delay-open-time: 0
                client: false
                confederation-member: false
                disable: false
                ipv4-unicast: true
                ipv4-multicast: false
                ipv6-unicast: false
                ipv6-multicast: false
            }
            peer "10.100.19.217" {
                peer-port: 179
                local-port: 179
                local-ip: 10.100.19.218
                as: 100
                next-hop: 10.100.19.9
                holdtime: 90
                delay-open-time: 0
                client: false
                confederation-member: false
                disable: false
                ipv4-unicast: true
                ipv4-multicast: false
                ipv6-unicast: false
                ipv6-multicast: false
            }
        }
        ospf4 {
            router-id: 99.1.1.219
            rfc1583-compatibility: false
            ip-router-alert: false
            area 0.0.0.0 {
                area-type: "normal"
                interface eth1 {
                    link-type: "broadcast"
                }
            }
        }
        snmp {
            community public {
                authorization: "ro"
            }
            community secret {
                client 10.100.32.53
                client 10.100.32.55
                network 10.10.1.0/24
                authorization: "rw"
            }
            trap-target 10.100.32.53
            trap-target 10.100.55.43
            contact: "Eric Bashaminator"
            description: ""
            location: "Austin Lab"
        }
        static {
            disable: false
            route 0.0.0.0/0 {
                next-hop: 10.100.19.9
                metric: 1
            }
            route 10.100.19.219/32 {
                next-hop: 10.100.19.13
                metric: 1
            }
            route 10.100.19.220/32 {
                next-hop: 10.100.19.9
                metric: 1
            }
            route 10.100.19.217/32 {
                next-hop: 10.100.19.9
                metric: 1
            }
        }
    }
    policy {
        policy-statement "mxport_conn" {
            term 10 {
                from {
                    protocol: "bgp"
                }
                then {
                    action: "accept"
                }
            }
            term 20 {
                from {
                    protocol: "connected"
                }
                then {
                    action: "accept"
                }
            }
        }
    }
    interfaces {
        restore: false
        loopback lo {
            description: "loop"
            address 10.100.19.218 {
                prefix-length: 32
                disable: false
            }
        }
        ethernet eth0 {
            disable: false
            discard: false
            description: ""
            hw-id: 00:04:23:C7:AB:38
            duplex: "auto"
            speed: "auto"
            address 10.100.19.14 {
                prefix-length: 30
                disable: false
            }
        }
        ethernet eth1 {
            disable: false
            discard: false
            description: ""
            hw-id: 00:04:23:C7:AB:39
            duplex: "auto"
            speed: "auto"
        }
        ethernet eth2 {
            disable: false
            discard: false
            description: ""
            hw-id: 00:0C:F1:C7:3C:47
            duplex: "auto"
            speed: "auto"
            address 10.100.19.10 {
                prefix-length: 30
                disable: false
            }
            firewall {
                in {
                    name: "FWTEST1"
                }
                out {
                    name: "NOTHERE"
                }
            }
        }
    }
    firewall {
        log-martians: "enable"
        send-redirects: "disable"
        receive-redirects: "disable"
        ip-src-route: "disable"
        broadcast-ping: "disable"
        syn-cookies: "enable"
        name FWTEST1 {
            description: "block stuff"
            rule 1 {
                protocol: "tcp"
                action: "accept"
                log: "disable"
                source {
                    address: 10.10.30.46
                }
                destination {
                    port-name: "telnet"
                }
            }
            rule 10 {
                protocol: "udp"
                state {
                    established: "enable"
                }
                action: "reject"
                log: "disable"
                source {
                    network: 192.168.2.0/24
                    port-range {
                        start: 4000
                        stop: 4005
                    }
                }
                destination {
                    address: 77.2.2.2
                    port-number: 8000
                }
            }
        }
    }
    service {
        ssh {
            port: 22
            protocol-version: "v2"
        }
        telnet {
            port: 23
        }
    }
    system {
        host-name: "vyatta"
        domain-name: "alterpoint.com"
        name-server 10.10.1.11
        time-zone: "GMT"
        ntp-server "69.59.150.135"
        login {
            user root {
                full-name: ""
                authentication {
                    encrypted-password: "$1$$Ht7gBYnxI1xCdO/JOnodh."
                }
            }
            user vyatta {
                full-name: ""
                authentication {
                    encrypted-password: "$1$$Ht7gBYnxI1xCdO/JOnodh."
                }
            }
            user testlab {
                full-name: ""
                authentication {
                    encrypted-password: "$1$LJie4iRJ$QymvAnlQ.JilBvUtxjdtU1"
                    plaintext-password: ""
                }
            }
        }
        package {
            repository community {
                component: "main"
                url: "http://archive.vyatta.com/vyatta"
            }
        }
    }
    rtrmgr {
        config-directory: "/opt/vyatta/etc/config"
    }

[edit]
testlab@vyatta# 
END_SHOW_CONFIG

our $interfaces = <<'END';
 show interfaces
 eth0: <BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast qlen 100
    link/ether 00:04:23:c7:ab:38 brd ff:ff:ff:ff:ff:ff
    inet 10.100.19.14/30 brd 10.100.19.15 scope global eth0
    inet6 fe80::204:23ff:fec7:ab38/64 scope link
       valid_lft forever preferred_lft forever

    RX: bytes  packets  errors  dropped overrun mcast
    182464     2851     0       0       0       0
    TX: bytes  packets  errors  dropped carrier collsns
    15437126   218630   1       0       0       2
 eth1: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast qlen 1000
    link/ether 00:04:23:c7:ab:39 brd ff:ff:ff:ff:ff:ff
 eth2: <BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast qlen 1000
    link/ether 00:0c:f1:c7:3c:47 brd ff:ff:ff:ff:ff:ff
    inet 10.100.19.10/30 brd 10.100.19.11 scope global eth2
    inet6 fe80::20c:f1ff:fec7:3c47/64 scope link
       valid_lft forever preferred_lft forever

    RX: bytes  packets  errors  dropped overrun mcast
    53097995   749436   0       0       0       0
    TX: bytes  packets  errors  dropped carrier collsns
    43697553   545376   0       0       0       0
 lo: <LOOPBACK,UP> mtu 16436 qdisc noqueue
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
    inet 10.100.19.218/32 scope global lo
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever

    RX: bytes  packets  errors  dropped overrun mcast
    3342419768 447526957 0       0       0       0
    TX: bytes  packets  errors  dropped carrier collsns
    3342419768 447526957 0       0       0       0
testlab@vyatta>
END
1;
