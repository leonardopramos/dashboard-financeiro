package com.dashboard_financeiro.notificacoes.infrastructure.persistence.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "email_notification_log")
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class EmailNotificationLogEntity {

    @Id
    private UUID id;

    @ManyToOne
    @JoinColumn(name = "user_id")
    private NotificationUserEntity user;

    @Column(name = "email", nullable = false)
    private String email;

    @Column(name = "subject", nullable = false, length = 180)
    private String subject;

    @Column(name = "template", nullable = false, length = 80)
    private String template;

    @Column(name = "payload")
    private String payload;

    @Column(name = "status", nullable = false, length = 30)
    private String status;

    @Column(name = "error_message", length = 500)
    private String errorMessage;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @PrePersist
    void onCreate() {
        createdAt = LocalDateTime.now();
        if (id == null) {
            id = UUID.randomUUID();
        }
    }
}
