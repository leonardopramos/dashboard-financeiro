-- ================================
-- ChangeSet 002-create-categories
-- ================================

CREATE TABLE categories (
    id UNIQUEIDENTIFIER NOT NULL PRIMARY KEY,
    user_id UNIQUEIDENTIFIER NOT NULL,
    category_type VARCHAR(20) NOT NULL,
    name VARCHAR(80) NOT NULL,
    color VARCHAR(20),
    icon VARCHAR(80),
    active BIT NOT NULL DEFAULT 1,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);

ALTER TABLE categories
    ADD CONSTRAINT uk_categories_user_name UNIQUE (user_id, name);

CREATE INDEX idx_categories_user
    ON categories (user_id);

-- ================================
-- ChangeSet 003-alter-transactions
-- ================================

ALTER TABLE transactions
    ADD category_id UNIQUEIDENTIFIER NULL;

ALTER TABLE transactions
    ADD CONSTRAINT fk_transactions_category
        FOREIGN KEY (category_id) REFERENCES categories(id);

ALTER TABLE transactions
    DROP COLUMN category;

CREATE INDEX idx_transactions_category
    ON transactions (category_id);

-- ================================
-- ChangeSet 004-create-financial-goals
-- ================================

CREATE TABLE financial_goals (
    id UNIQUEIDENTIFIER NOT NULL PRIMARY KEY,
    user_id UNIQUEIDENTIFIER NOT NULL,
    name VARCHAR(120) NOT NULL,
    goal_type VARCHAR(30) NOT NULL,
    category_id UNIQUEIDENTIFIER NULL,
    target_amount DECIMAL(19,2) NOT NULL,
    current_amount DECIMAL(19,2) NOT NULL DEFAULT 0,
    start_date DATE NOT NULL,
    end_date DATE NULL,
    goal_status VARCHAR(30) NOT NULL,
    description VARCHAR(255),
    active BIT NOT NULL DEFAULT 1,
    notify_on_achieve BIT NOT NULL DEFAULT 1,
    notify_on_exceed BIT NOT NULL DEFAULT 1,
    achieved_at DATETIME2 NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);

ALTER TABLE financial_goals
    ADD CONSTRAINT fk_financial_goals_category
        FOREIGN KEY (category_id) REFERENCES categories(id);

CREATE INDEX idx_financial_goals_user
    ON financial_goals (user_id);
