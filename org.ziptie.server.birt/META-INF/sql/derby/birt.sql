-- Define tables used by the BIRT report jobs.

CREATE TABLE birt_report (
    execution_id INTEGER NOT NULL,
    details BLOB,
    PRIMARY KEY (execution_id),
    CONSTRAINT birt_report_to_exec_fk FOREIGN KEY (execution_id) REFERENCES execution_history (id)
       ON DELETE CASCADE
);

CREATE TABLE birt_resolved_devices (
    device_id INTEGER NOT NULL,
    execution_id INTEGER NOT NULL,
    CONSTRAINT birt_report_devices_fk FOREIGN KEY (execution_id) REFERENCES execution_history (id)
       ON DELETE CASCADE
);
