-- Define tables used by the security.

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
 