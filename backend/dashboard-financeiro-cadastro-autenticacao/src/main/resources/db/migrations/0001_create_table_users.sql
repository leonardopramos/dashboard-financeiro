CREATE TABLE users (
    id BINARY(16) NOT NULL,
    cpf VARCHAR(14) UNIQUE,
    name VARCHAR(150) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255),
    role VARCHAR(50) DEFAULT 'USER',
    street VARCHAR(255),
    number INT,
    neighborhood VARCHAR(150),
    complement VARCHAR(150),
    city VARCHAR(150),
    state VARCHAR(2),
    zip_code VARCHAR(10),
    email_verified TINYINT(1) NOT NULL DEFAULT 0,
    active TINYINT(1) NOT NULL DEFAULT 1,
    registered_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id)
) ENGINE=InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;
