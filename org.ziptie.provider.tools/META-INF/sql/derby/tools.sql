-- Define tables used by the core jobs.

CREATE TABLE tool_details (
    id INTEGER NOT NULL,
    execution_id INTEGER NOT NULL,
    device_id INTEGER,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    error VARCHAR(32672),
    grid_data CLOB,
    details CLOB,
    PRIMARY KEY (id),
    CONSTRAINT command_details_to_exec_fk FOREIGN KEY (execution_id) REFERENCES execution_history (id)
       ON DELETE CASCADE,
    CONSTRAINT command_details_to_device_fk FOREIGN KEY (device_id) REFERENCES device(device_id)
       ON DELETE CASCADE
);

CREATE INDEX tool_detail_etime_ndx ON tool_details (end_time);

CREATE TABLE plugin_exec_record (
    id INTEGER NOT NULL,
    execution_id INTEGER NOT NULL,
    format VARCHAR(255),
    plugin_name VARCHAR(255),
    PRIMARY KEY (id),
    CONSTRAINT plugin_to_hist_fk FOREIGN KEY (execution_id) REFERENCES execution_history (id)
       ON DELETE CASCADE
);
