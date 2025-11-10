-- liquibase formatted sql

--changeset notifications:001

CREATE TABLE notification_users (
    id BINARY(16) NOT NULL,
    email VARCHAR(255) NOT NULL,
    name VARCHAR(150),
    active TINYINT(1) NOT NULL DEFAULT 1,
    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    CONSTRAINT uk_notification_users_email UNIQUE (email)
) ENGINE=InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;

