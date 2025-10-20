package com.dashboard_financeiro.Dashboard.Financeiro.infrastructure.persistence.repository;

import com.dashboard_financeiro.Dashboard.Financeiro.infrastructure.persistence.entity.FinancialGoalJpaEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface FinancialGoalJpaRepository extends JpaRepository<FinancialGoalJpaEntity, UUID> {

    List<FinancialGoalJpaEntity> findByUserIdAndActiveTrueOrderByEndDateAsc(UUID userId);

    Optional<FinancialGoalJpaEntity> findByIdAndUserId(UUID id, UUID userId);
}
