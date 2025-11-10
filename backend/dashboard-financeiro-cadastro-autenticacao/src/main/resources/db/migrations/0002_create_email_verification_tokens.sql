-- ================================
-- ChangeSet 002-create-email-verification-tokens
-- ================================

CREATE TABLE email_verification_tokens (
    id BINARY(16) NOT NULL,
    user_id BINARY(16) NOT NULL,
    code_hash VARCHAR(120) NOT NULL,
    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    expires_at DATETIME(6) NOT NULL,
    verified_at DATETIME(6) NULL,
    attempts INT NOT NULL DEFAULT 0,
    reason VARCHAR(40) NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_email_verification_user
        FOREIGN KEY (user_id)
            REFERENCES users(id),
    KEY idx_email_verification_user_active (user_id, verified_at)
) ENGINE=InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;
