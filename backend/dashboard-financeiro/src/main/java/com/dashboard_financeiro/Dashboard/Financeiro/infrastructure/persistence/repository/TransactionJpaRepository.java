package com.dashboard_financeiro.Dashboard.Financeiro.infrastructure.persistence.repository;

import com.dashboard_financeiro.Dashboard.Financeiro.infrastructure.persistence.entity.TransactionJpaEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface TransactionJpaRepository extends JpaRepository<TransactionJpaEntity, UUID> {

    List<TransactionJpaEntity> findByBankAccountId(UUID bankAccountId);

    List<TransactionJpaEntity> findByBankAccountUserId(UUID userId);

    Optional<TransactionJpaEntity> findByIdAndBankAccountUserId(UUID id, UUID userId);

    List<TransactionJpaEntity> findByBankAccountUserIdAndTransactionDateBetween(UUID userId, java.time.LocalDate start, java.time.LocalDate end);
}
