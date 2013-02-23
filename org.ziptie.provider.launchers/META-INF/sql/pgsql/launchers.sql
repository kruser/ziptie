-- Define the table(s) for the Launchers Provider
--

--##############################################################
--#                    Launchers Tables/Indexes
--##############################################################

CREATE TABLE launchers ( 
    id INTEGER NOT NULL,
    name VARCHAR(64) NOT NULL,
    url VARCHAR(256) NOT NULL,
    CONSTRAINT launchers_pk PRIMARY KEY (id),
    CONSTRAINT unique_launcher UNIQUE (name)
);
CREATE INDEX launcher_name_ndx ON launchers (name);
