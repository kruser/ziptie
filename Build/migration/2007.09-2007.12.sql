connect 'jdbc:derby:ziptie;';

CREATE TABLE execution_history (
    id INTEGER NOT NULL,
    trigger_name VARCHAR(80) NOT NULL,
    trigger_group VARCHAR(80) NOT NULL,
    job_name VARCHAR(80) NOT NULL,
    job_group VARCHAR(80) NOT NULL,
    job_type VARCHAR(80) NOT NULL,
    job_class VARCHAR(128) NOT NULL,
    canceled SMALLINT NOT NULL DEFAULT 0,
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    PRIMARY KEY (id)
);

CREATE INDEX exec_hist_start_ndx ON execution_history (start_time);
CREATE INDEX exec_hist_end_ndx ON execution_history (end_time);
CREATE INDEX exec_hist_trigger_ndx ON execution_history (trigger_name, trigger_group);
CREATE INDEX exec_hist_job_ndx ON execution_history (job_name, job_group);

-- Define tables used by the core jobs.

CREATE TABLE tool_details (
    id INTEGER NOT NULL,
    execution_id INTEGER NOT NULL,
    device_id INTEGER,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    error VARCHAR(32672),
    details CLOB,
    discriminator VARCHAR(255) NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT command_details_to_exec_fk FOREIGN KEY (execution_id) REFERENCES execution_history (id)
       ON DELETE CASCADE,
    CONSTRAINT command_details_to_device_fk FOREIGN KEY (device_id) REFERENCES device(device_id)
       ON DELETE CASCADE
);

CREATE INDEX tool_detail_etime_ndx ON tool_details (end_time, discriminator);
