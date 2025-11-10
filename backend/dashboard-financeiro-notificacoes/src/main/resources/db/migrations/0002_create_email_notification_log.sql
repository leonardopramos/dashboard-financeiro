-- liquibase formatted sql

--changeset notifications:002

CREATE TABLE email_notification_log (
    id BINARY(16) NOT NULL,
    user_id BINARY(16) NULL,
    email VARCHAR(255) NOT NULL,
    subject VARCHAR(180) NOT NULL,
    template VARCHAR(80) NOT NULL,
    payload LONGTEXT NULL,
    status VARCHAR(30) NOT NULL,
    error_message VARCHAR(500),
    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    CONSTRAINT fk_email_notification_user
        FOREIGN KEY (user_id)
            REFERENCES notification_users(id),
    KEY idx_notification_log_user (user_id)
) ENGINE=InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;

