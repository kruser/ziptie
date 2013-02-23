-- Define the table(s) for the Config Provider
--

--##############################################################
--#                    Config Tables/Indexes
--##############################################################

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
