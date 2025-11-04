-- ================================
-- ChangeSet 002-create-email-verification-tokens
-- ================================

CREATE TABLE email_verification_tokens (
    id UNIQUEIDENTIFIER NOT NULL PRIMARY KEY,
    user_id UNIQUEIDENTIFIER NOT NULL,
    code_hash VARCHAR(120) NOT NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    expires_at DATETIME2 NOT NULL,
    verified_at DATETIME2 NULL,
    attempts INT NOT NULL DEFAULT 0,
    reason VARCHAR(40) NULL
);

ALTER TABLE email_verification_tokens
    ADD CONSTRAINT fk_email_verification_user
        FOREIGN KEY (user_id) REFERENCES users(id);

CREATE INDEX idx_email_verification_user_active
    ON email_verification_tokens (user_id)
    WHERE verified_at IS NULL;
