# contains a simple hash of vyatta command responses
package DataJUNOS2;

use strict;
use warnings;
use Exporter 'import';
our @EXPORT_OK = qw($responses2);

our $responses2;

$responses2->{showFirewall} = <<'END';
test-junos> show configuration firewall | display xml <rpc-reply xmlns:junos="http://xml.juniper.net/junos/8.3R4/junos">
    <configuration junos:commit-seconds="1206551362"
junos:commit-localtime="2008-03-26 17:09:22 GMT"
junos:commit-user="citi">
            <firewall>
                <policer>
                    <name>policer-1</name>
                    <if-exceeding>
                        <bandwidth-limit>384k</bandwidth-limit>
                        <burst-size-limit>15k</burst-size-limit>
                    </if-exceeding>
                    <then>
                        <discard/>
                    </then>
                </policer>
                <family>
                    <inet>
                        <service-filter>
                            <name>no icmp</name>
                            <term>
                                <name>deny ping</name>
                                <from>
                                    <protocol>icmp</protocol>
                                </from>
                                <then>
                                    <skip/>
                                </then>
                            </term>
                            <term>
                                <name>default</name>
                                <then>
                                    <service/>
                                </then>
                            </term>
                        </service-filter>
                    </inet>
                </family>
                <filter>
                    <name>filter-policer</name>
                    <term>
                        <name>term1</name>
                        <from>

<forwarding-class>cos-fc-voice</forwarding-class>
                        </from>
                        <then>
                            <policer>policer-1</policer>
                        </then>
                    </term>
                    <term>
                        <name>term2</name>
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

test-junos>
END
