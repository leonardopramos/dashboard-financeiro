package com.dashboard_financeiro.Dashboard.Financeiro.infrastructure.persistence.repository;

import com.dashboard_financeiro.Dashboard.Financeiro.infrastructure.persistence.entity.CategoryJpaEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface CategoryJpaRepository extends JpaRepository<CategoryJpaEntity, UUID> {

    List<CategoryJpaEntity> findByUserIdAndActiveTrueOrderByNameAsc(UUID userId);

    Optional<CategoryJpaEntity> findByIdAndUserId(UUID id, UUID userId);

    boolean existsByUserIdAndNameIgnoreCase(UUID userId, String name);

    Optional<CategoryJpaEntity> findByUserIdAndNameIgnoreCase(UUID userId, String name);
}
