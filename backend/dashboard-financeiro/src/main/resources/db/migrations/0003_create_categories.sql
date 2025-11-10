-- liquibase formatted sql

--changeset finance:003

CREATE TABLE categories (
    id BINARY(16) NOT NULL,
    user_id BINARY(16) NOT NULL,
    category_type VARCHAR(20) NOT NULL,
    name VARCHAR(80) NOT NULL,
    color VARCHAR(20),
    icon VARCHAR(80),
    active TINYINT(1) NOT NULL DEFAULT 1,
    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    CONSTRAINT uk_categories_user_name UNIQUE (user_id, name),
    KEY idx_categories_user (user_id)
) ENGINE=InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;

