CREATE TABLE users (
    id UNIQUEIDENTIFIER NOT NULL PRIMARY KEY,
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
    email_verified BIT DEFAULT 0 NOT NULL,
    active BIT DEFAULT 1 NOT NULL,
    registered_at DATETIME2 DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at DATETIME2 DEFAULT CURRENT_TIMESTAMP NOT NULL
);