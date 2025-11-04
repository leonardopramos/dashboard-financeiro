-- ================================
-- ChangeSet 005-create-goal-contributions
-- ================================

CREATE TABLE goal_contributions (
    id UNIQUEIDENTIFIER NOT NULL PRIMARY KEY,
    goal_id UNIQUEIDENTIFIER NOT NULL,
    user_id UNIQUEIDENTIFIER NOT NULL,
    amount DECIMAL(19,2) NOT NULL,
    description VARCHAR(255),
    allocation_date DATE NOT NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);

ALTER TABLE goal_contributions
    ADD CONSTRAINT fk_goal_contributions_goal
        FOREIGN KEY (goal_id) REFERENCES financial_goals(id);

CREATE INDEX idx_goal_contributions_goal ON goal_contributions(goal_id);
CREATE INDEX idx_goal_contributions_user ON goal_contributions(user_id);
CREATE INDEX idx_goal_contributions_date ON goal_contributions(allocation_date);
