-- liquibase formatted sql

--changeset finance:005

CREATE TABLE financial_goals (
    id BINARY(16) NOT NULL,
    user_id BINARY(16) NOT NULL,
    name VARCHAR(120) NOT NULL,
    goal_type VARCHAR(30) NOT NULL,
    category_id BINARY(16) NULL,
    target_amount DECIMAL(19,2) NOT NULL,
    current_amount DECIMAL(19,2) NOT NULL DEFAULT 0,
    start_date DATE NOT NULL,
    end_date DATE NULL,
    goal_status VARCHAR(30) NOT NULL,
    description VARCHAR(255),
    active TINYINT(1) NOT NULL DEFAULT 1,
    notify_on_achieve TINYINT(1) NOT NULL DEFAULT 1,
    notify_on_exceed TINYINT(1) NOT NULL DEFAULT 1,
    achieved_at DATETIME(6) NULL,
    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    CONSTRAINT fk_financial_goals_category
        FOREIGN KEY (category_id)
            REFERENCES categories(id),
    KEY idx_financial_goals_user (user_id)
) ENGINE=InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;

