-- Define the table(s) for the Device Provider
--

-- Define the unique hibernate key sequence.  This should be
-- defined somewhere else.
--

DROP TABLE IF EXISTS persistent_key_gen;

CREATE TABLE persistent_key_gen (
	seq_name VARCHAR(64) PRIMARY KEY,
	seq_value BIGINT NOT NULL
) ENGINE=InnoDB;

--##############################################################
--#                    Device Tables/Indexes
--##############################################################

DROP TABLE IF EXISTS device;

CREATE TABLE device (
    device_id INTEGER NOT NULL,
    inode INTEGER NOT NULL,
    ip_address VARCHAR(40) NOT NULL,
    ip_low BIGINT NOT NULL,
    ip_high BIGINT NOT NULL,
    hostname VARCHAR(255),
    network VARCHAR(32) NOT NULL,
    adapter_id VARCHAR(64) NOT NULL,
    device_type VARCHAR(64),
    vendor_hw VARCHAR(64),
    hw_version VARCHAR(64),
    canonical_hw_version VARCHAR(240),
    model VARCHAR(64),
    vendor_sw VARCHAR(64),
    os_version VARCHAR(128),
    canonical_os_version VARCHAR(240),
    asset_identity VARCHAR(255),
    backup_status VARCHAR(128),
    backup_message VARCHAR(20000),
    last_backup DATETIME,
    last_telemetry DATETIME,
    CONSTRAINT device_pk PRIMARY KEY (device_id),
    CONSTRAINT unique_device UNIQUE (ip_address,network)
) ENGINE=InnoDB;

CREATE INDEX device_ipv4_ndx ON device (ip_low);

CREATE INDEX device_ipv6_ndx ON device (ip_high, ip_low);

CREATE INDEX device_hostname_ndx ON device (hostname);

CREATE INDEX device_hwver_ndx ON device (canonical_hw_version);

CREATE INDEX device_osver_ndx ON device (canonical_os_version);

CREATE INDEX device_makemodel_ndx ON device (vendor_hw, model);

CREATE INDEX device_last_backup_ndx ON device (last_backup);

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
CREATE INDEX interface_ips_ipv6_ndx ON device (ip_high, ip_low);

--##############################################################
--#                    Tag Tables/Indexes
--##############################################################

DROP TABLE IF EXISTS tag;

CREATE TABLE tag (
    tag_id INTEGER NOT NULL,
    tag VARCHAR(255) NOT NULL,
    tag_lower VARCHAR(255) NOT NULL,
    CONSTRAINT tag_pk PRIMARY KEY (tag_id),
    CONSTRAINT tag_tag_unique UNIQUE (tag_lower)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS device_tag;

CREATE TABLE device_tag (
    tag_id INTEGER NOT NULL,
    device_id INTEGER NOT NULL,
    CONSTRAINT tag_fk FOREIGN KEY (tag_id) REFERENCES tag (tag_id) ON DELETE CASCADE,
    CONSTRAINT tag_device_fk FOREIGN KEY (device_id) REFERENCES device (device_id)
       ON DELETE CASCADE
) ENGINE=InnoDB;
