package com.dashboard_financeiro.Dashboard.Financeiro.infrastructure.persistence.repository;

import com.dashboard_financeiro.Dashboard.Financeiro.infrastructure.persistence.entity.GoalContributionJpaEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

public interface GoalContributionJpaRepository extends JpaRepository<GoalContributionJpaEntity, UUID> {

    @Query("SELECT COALESCE(SUM(c.amount), 0) FROM GoalContributionJpaEntity c WHERE c.goal.userId = :userId")
    BigDecimal sumByUser(UUID userId);

    @Query("SELECT COALESCE(SUM(c.amount), 0) FROM GoalContributionJpaEntity c WHERE c.goal.userId = :userId AND c.allocationDate BETWEEN :start AND :end")
    BigDecimal sumByUserBetween(UUID userId, LocalDate start, LocalDate end);

    @Query("SELECT COALESCE(SUM(c.amount), 0) FROM GoalContributionJpaEntity c WHERE c.goal.id = :goalId")
    BigDecimal sumByGoal(UUID goalId);
}
