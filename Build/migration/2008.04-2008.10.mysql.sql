
CREATE TABLE revisions (
    association_id INTEGER NOT NULL,
    revision LONGBLOB,
    revision_time TIMESTAMP NOT NULL,
    prev_revision_time TIMESTAMP,
    type VARCHAR(1) NOT NULL,
    head BIT NOT NULL DEFAULT 0,
    path VARCHAR(255) NOT NULL,
    author VARCHAR(60) NOT NULL,
    mime_type VARCHAR(60) NOT NULL DEFAULT 'plain/text',
    size INTEGER NOT NULL,
    crc32 BIGINT NOT NULL,
    CONSTRAINT revisions_pk PRIMARY KEY (association_id, revision_time, path)
) ENGINE=InnoDB;

CREATE INDEX revision_ndx ON revisions (association_id, head, path);

CREATE TABLE launchers ( 
    id INTEGER NOT NULL,
    name VARCHAR(64) NOT NULL,
    url VARCHAR(256) NOT NULL,
    CONSTRAINT launchers_pk PRIMARY KEY (id),
    CONSTRAINT unique_launcher UNIQUE (name)
) ENGINE=InnoDB;
CREATE INDEX launcher_name_ndx ON launchers (name);


CREATE TABLE discovery_arp (
    device_id INTEGER NOT NULL,
    ip_address VARCHAR(40) NOT NULL,
    ip_low BIGINT NOT NULL,
    ip_high BIGINT NOT NULL,
    mac_address BIGINT NOT NULL,
    interface VARCHAR(128)
) ENGINE=InnoDB;
CREATE INDEX arp_ipv4_ndx ON discovery_arp (ip_low);
CREATE INDEX arp_ipv6_ndx ON discovery_arp (ip_high, ip_low);
CREATE INDEX arp_mac_ndx ON discovery_arp (mac_address);
CREATE INDEX arp_did_ndx ON discovery_arp (device_id);

CREATE TABLE discovery_mac (
    device_id INTEGER NOT NULL,
    mac_address BIGINT,
    interface VARCHAR(128) NOT NULL,
    vlan VARCHAR(128)
) ENGINE=InnoDB;
CREATE INDEX mac_ndx ON discovery_mac (mac_address);
CREATE INDEX mac_did_ndx ON discovery_mac (device_id);

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
) ENGINE=InnoDB;
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
) ENGINE=InnoDB;
CREATE INDEX routing_did_ndx ON discovery_routing (device_id);

CREATE TABLE roles (
    role VARCHAR(40) NOT NULL,
    permissions VARCHAR(16384) NOT NULL,
    PRIMARY KEY (role)
);

CREATE TABLE users (
    username VARCHAR(60) NOT NULL,
    md5password VARCHAR(60) NOT NULL,
    fullname VARCHAR(80),
    email VARCHAR(80),
    role VARCHAR(40) NOT NULL,
    PRIMARY KEY (username),
    CONSTRAINT user_role_fk FOREIGN KEY (role) REFERENCES roles (role)
);

INSERT INTO roles (role, permissions) VALUES ('Administrator', 'org.ziptie.access.all');

INSERT INTO users (username, md5password, fullname, email, role) 
 VALUES ('admin', '37300eb78a16cbb5d39e3e8e2cca2011', 'ZipTie Administrator', 'ziptie@nowhere.x', 'Administrator');

ALTER TABLE tool_details MODIFY error VARCHAR(20000);

ALTER TABLE execution_history ADD executor VARCHAR(60);

ALTER TABLE device MODIFY backup_message VARCHAR(20000);
ALTER TABLE device MODIFY last_backup DATETIME;
ALTER TABLE device ADD last_telemetry DATETIME;

CREATE TABLE device_interface_ips (
    id BIGINT NOT NULL,
    device_id INTEGER NOT NULL,
    ip_address VARCHAR(40) NOT NULL,
    ip_low BIGINT NOT NULL,
    ip_high BIGINT NOT NULL,
    interface VARCHAR(128),
    same_ip_space BIT NOT NULL,
    CONSTRAINT interface_ips_fk FOREIGN KEY (device_id) REFERENCES device (device_id)
       ON DELETE CASCADE,
    CONSTRAINT device_interface_pk PRIMARY KEY (id)
) ENGINE=InnoDB;

CREATE INDEX interface_ips_ipv4_ndx ON device (ip_low);
CREATE INDEX interface_ips_ipv6_ndx ON device (ip_high, ip_low)
