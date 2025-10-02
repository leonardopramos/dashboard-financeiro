-- ================================
-- ChangeSet 001-create-bank-accounts
-- ================================

CREATE TABLE bank_accounts (
    id UNIQUEIDENTIFIER NOT NULL PRIMARY KEY,
    user_id UNIQUEIDENTIFIER NOT NULL,
    institution_name NVARCHAR(120) NOT NULL,
    branch_number NVARCHAR(20) NOT NULL,
    account_number NVARCHAR(30) NOT NULL,
    account_digit NVARCHAR(5),
    account_type NVARCHAR(30) NOT NULL,
    nickname NVARCHAR(60),
    current_balance DECIMAL(19,2) NOT NULL,
    created_at DATETIME2 NOT NULL,
    updated_at DATETIME2 NOT NULL
);

ALTER TABLE bank_accounts
ADD CONSTRAINT uk_bank_accounts_user_account
    UNIQUE (user_id, institution_name, account_number, account_digit, branch_number);

CREATE INDEX idx_bank_accounts_user
    ON bank_accounts (user_id);

-- ================================
-- ChangeSet 002-create-transactions
-- ================================

CREATE TABLE transactions (
    id UNIQUEIDENTIFIER NOT NULL PRIMARY KEY,
    bank_account_id UNIQUEIDENTIFIER NOT NULL,
    transaction_type NVARCHAR(30) NOT NULL,
    amount DECIMAL(19,2) NOT NULL,
    transaction_date DATE NOT NULL,
    description NVARCHAR(200) NOT NULL,
    category NVARCHAR(80),
    notes NVARCHAR(255),
    created_at DATETIME2 NOT NULL,
    updated_at DATETIME2 NOT NULL
);

ALTER TABLE transactions
ADD CONSTRAINT fk_transactions_bank_account
    FOREIGN KEY (bank_account_id)
    REFERENCES bank_accounts (id)
    ON DELETE CASCADE;

CREATE INDEX idx_transactions_bank_account
    ON transactions (bank_account_id);
