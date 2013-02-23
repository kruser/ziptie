-- Define the table(s) for the Telemetry Provider
--

--##############################################################
--#                    Telemetry Tables/Indexes
--##############################################################

CREATE TABLE discovery_arp (
    device_id INTEGER NOT NULL,
    ip_address VARCHAR(40) NOT NULL,
    ip_low BIGINT NOT NULL,
    ip_high BIGINT NOT NULL,
    mac_address BIGINT NOT NULL,
    interface VARCHAR(128)
);
CREATE INDEX arp_ipv4_ndx ON discovery_arp (ip_low);
CREATE INDEX arp_ipv6_ndx ON discovery_arp (ip_high, ip_low);
CREATE INDEX arp_mac_ndx ON discovery_arp (mac_address);
CREATE INDEX arp_did_ndx ON discovery_arp (device_id);

CREATE TABLE discovery_mac (
    device_id INTEGER NOT NULL,
    mac_address BIGINT,
    interface VARCHAR(128) NOT NULL,
    vlan VARCHAR(128)
);
CREATE INDEX mac_ndx ON discovery_mac (mac_address);
CREATE INDEX mac_did_ndx ON discovery_mac (device_id);
CREATE INDEX mac_didint_ndx ON discovery_mac (device_id, interface);

CREATE TABLE discovery_xdp (
    device_id INTEGER NOT NULL,
    protocol VARCHAR(16) NOT NULL,
    ip_address VARCHAR(40),
    ip_low BIGINT,
    ip_high BIGINT,
    mac_address BIGINT,
    local_interface VARCHAR(128),
    remote_interface VARCHAR(128),
    platform VARCHAR(255),
    sys_name VARCHAR(128)
);
CREATE INDEX xdp_did_ndx ON discovery_xdp (device_id);

CREATE TABLE discovery_routing (
    device_id INTEGER NOT NULL,
    protocol VARCHAR(16) NOT NULL,
    remote_ip_address VARCHAR(40),
    remote_ip_low BIGINT,
    remote_ip_high BIGINT,
    router_id_ip_address VARCHAR(40),
    router_id_ip_low BIGINT,
    router_id_ip_high BIGINT,
    interface VARCHAR(128)
);
CREATE INDEX routing_did_ndx ON discovery_routing (device_id);
