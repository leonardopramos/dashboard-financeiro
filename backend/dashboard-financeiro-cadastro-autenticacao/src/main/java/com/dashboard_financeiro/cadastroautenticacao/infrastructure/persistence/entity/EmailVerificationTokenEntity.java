package com.dashboard_financeiro.cadastroautenticacao.infrastructure.persistence.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "email_verification_tokens")
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class EmailVerificationTokenEntity {

    @Id
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private UserJpaEntity user;

    @Column(name = "code_hash", nullable = false, length = 120)
    private String codeHash;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "expires_at", nullable = false)
    private LocalDateTime expiresAt;

    @Column(name = "verified_at")
    private LocalDateTime verifiedAt;

    @Column(name = "attempts", nullable = false)
    private int attempts;

    @Column(name = "reason", length = 40)
    private String reason;

    public boolean isExpired(LocalDateTime reference) {
        return expiresAt.isBefore(reference);
    }

    @PrePersist
    void onCreate() {
        if (id == null) {
            id = UUID.randomUUID();
        }
        createdAt = LocalDateTime.now();
        attempts = attempts < 0 ? 0 : attempts;
    }

    public void incrementAttempts() {
        attempts = attempts + 1;
    }

    public boolean isVerified() {
        return verifiedAt != null;
    }
}
