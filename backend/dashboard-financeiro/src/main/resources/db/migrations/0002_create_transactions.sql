-- liquibase formatted sql

--changeset finance:002

CREATE TABLE transactions (
    id BINARY(16) NOT NULL,
    bank_account_id BINARY(16) NOT NULL,
    transaction_type VARCHAR(30) NOT NULL,
    amount DECIMAL(19,2) NOT NULL,
    transaction_date DATE NOT NULL,
    description VARCHAR(200) NOT NULL,
    category VARCHAR(80),
    notes VARCHAR(255),
    created_at DATETIME(6) NOT NULL,
    updated_at DATETIME(6) NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_transactions_bank_account
        FOREIGN KEY (bank_account_id)
            REFERENCES bank_accounts (id)
            ON DELETE CASCADE,
    KEY idx_transactions_bank_account (bank_account_id)
) ENGINE=InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;

