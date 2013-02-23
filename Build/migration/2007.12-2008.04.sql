connect 'jdbc:derby:ziptie;';

CREATE TABLE birt_report (
    execution_id INTEGER NOT NULL,
    details BLOB,
    CONSTRAINT birt_report_to_exec_fk FOREIGN KEY (execution_id) REFERENCES execution_history (id)
       ON DELETE CASCADE
);

CREATE TABLE birt_resolved_devices (
    device_id INTEGER NOT NULL,
    execution_id INTEGER NOT NULL,
    CONSTRAINT birt_report_devices_fk FOREIGN KEY (execution_id) REFERENCES execution_history (id)
       ON DELETE CASCADE
);

CREATE TABLE plugin_exec_record (
    id INTEGER NOT NULL,
    execution_id INTEGER NOT NULL,
    format VARCHAR(255),
    plugin_name VARCHAR(255),
    PRIMARY KEY (id),
    CONSTRAINT plugin_to_hist_fk FOREIGN KEY (execution_id) REFERENCES execution_history (id)
       ON DELETE CASCADE
);

INSERT INTO plugin_exec_record (id, execution_id, plugin_name) 
   SELECT DISTINCT execution_id, execution_id, discriminator FROM tool_details;

INSERT INTO persistent_key_gen (seq_name, seq_value)
   SELECT DISTINCT 'Plugin_Exec_Record_seq', MAX(id) + 1 FROM plugin_exec_record; 

UPDATE plugin_exec_record SET format = 'grid(text)';

ALTER TABLE tool_details DROP discriminator;
ALTER TABLE tool_details ADD COLUMN grid_data CLOB;

UPDATE tool_details SET grid_data = details;

ALTER TABLE device_to_cred_set_mappings DROP CONSTRAINT device_to_credential_set_fk;
ALTER TABLE device_to_cred_set_mappings ADD CONSTRAINT device_to_credential_set_fk FOREIGN KEY (fkCredentialSetId) REFERENCES cred_set(id) ON DELETE CASCADE;

ALTER TABLE device_to_protocol_mappings DROP CONSTRAINT device_to_protocol_fk;
ALTER TABLE device_to_protocol_mappings ADD CONSTRAINT device_to_protocol_fk FOREIGN KEY (fkProtocolId) REFERENCES protocols(id) ON DELETE CASCADE;

ALTER TABLE device ADD COLUMN device_type VARCHAR(64);
