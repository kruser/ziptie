-- Define the table(s) for the Managed Network Service
--

DROP TABLE IF EXISTS managed_network CASCADE;

CREATE TABLE managed_network (
    name VARCHAR(255) NOT NULL,
    is_default BIT NOT NULL,
    CONSTRAINT netman_pk PRIMARY KEY (name)
) ENGINE=InnoDB;

INSERT INTO managed_network (name, is_default) VALUES('Default', 1);
