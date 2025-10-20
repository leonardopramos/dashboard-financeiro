-- ================================
-- ChangeSet 001-create-notification-users
-- ================================

CREATE TABLE notification_users (
    id UNIQUEIDENTIFIER NOT NULL PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    name VARCHAR(150),
    active BIT NOT NULL DEFAULT 1,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);

ALTER TABLE notification_users
    ADD CONSTRAINT uk_notification_users_email UNIQUE (email);

-- ================================
-- ChangeSet 002-create-notification-log
-- ================================

CREATE TABLE email_notification_log (
    id UNIQUEIDENTIFIER NOT NULL PRIMARY KEY,
    user_id UNIQUEIDENTIFIER NULL,
    email VARCHAR(255) NOT NULL,
    subject VARCHAR(180) NOT NULL,
    template VARCHAR(80) NOT NULL,
    payload NVARCHAR(MAX) NULL,
    status VARCHAR(30) NOT NULL,
    error_message VARCHAR(500),
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);

ALTER TABLE email_notification_log
    ADD CONSTRAINT fk_email_notification_user
        FOREIGN KEY (user_id) REFERENCES notification_users(id);

CREATE INDEX idx_notification_log_user
    ON email_notification_log (user_id);
