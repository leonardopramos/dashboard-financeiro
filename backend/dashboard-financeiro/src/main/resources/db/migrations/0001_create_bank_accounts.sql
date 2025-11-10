-- liquibase formatted sql

--changeset finance:001

CREATE TABLE bank_accounts (
    id BINARY(16) NOT NULL,
    user_id BINARY(16) NOT NULL,
    institution_name VARCHAR(120) NOT NULL,
    branch_number VARCHAR(20) NOT NULL,
    account_number VARCHAR(30) NOT NULL,
    account_digit VARCHAR(5),
    account_type VARCHAR(30) NOT NULL,
    nickname VARCHAR(60),
    current_balance DECIMAL(19,2) NOT NULL,
    created_at DATETIME(6) NOT NULL,
    updated_at DATETIME(6) NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT uk_bank_accounts_user_account
        UNIQUE (user_id, institution_name, account_number, account_digit, branch_number),
    KEY idx_bank_accounts_user (user_id)
) ENGINE=InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;

