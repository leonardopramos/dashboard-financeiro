-- liquibase formatted sql

--changeset finance:006

CREATE TABLE goal_contributions (
    id BINARY(16) NOT NULL,
    goal_id BINARY(16) NOT NULL,
    user_id BINARY(16) NOT NULL,
    amount DECIMAL(19,2) NOT NULL,
    description VARCHAR(255),
    allocation_date DATE NOT NULL,
    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    CONSTRAINT fk_goal_contributions_goal
        FOREIGN KEY (goal_id)
            REFERENCES financial_goals(id),
    KEY idx_goal_contributions_goal (goal_id),
    KEY idx_goal_contributions_user (user_id),
    KEY idx_goal_contributions_date (allocation_date)
) ENGINE=InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;

