-- liquibase formatted sql

--changeset finance:004

ALTER TABLE transactions
    ADD category_id BINARY(16) NULL;

ALTER TABLE transactions
    ADD CONSTRAINT fk_transactions_category
        FOREIGN KEY (category_id)
            REFERENCES categories(id);

ALTER TABLE transactions
    DROP COLUMN category;

CREATE INDEX idx_transactions_category
    ON transactions (category_id);

