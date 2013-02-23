-- Define the table(s) for the Managed Network Service
--

CREATE TABLE managed_network (
    name VARCHAR(255) NOT NULL,
    is_default SMALLINT not null,
    CONSTRAINT netman_pk PRIMARY KEY (name)
);

INSERT INTO managed_network (name, is_default) VALUES('Default', 1);
