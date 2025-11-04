package com.dashboard_financeiro.cadastroautenticacao.infrastructure.persistence.repository;

import com.dashboard_financeiro.cadastroautenticacao.infrastructure.persistence.entity.EmailVerificationTokenEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;

import java.time.LocalDateTime;
import java.util.Optional;
import java.util.UUID;

public interface EmailVerificationTokenRepository extends JpaRepository<EmailVerificationTokenEntity, UUID> {

    Optional<EmailVerificationTokenEntity> findFirstByUser_IdAndVerifiedAtIsNullOrderByCreatedAtDesc(UUID userId);

    @Modifying(clearAutomatically = true)
    @Query("update EmailVerificationTokenEntity t set t.verifiedAt = :timestamp where t.user.id = :userId and t.verifiedAt is null")
    void markAllAsVerified(UUID userId, LocalDateTime timestamp);
}
