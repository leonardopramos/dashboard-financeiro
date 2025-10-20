package com.dashboard_financeiro.Dashboard.Financeiro.web.dto;

import com.dashboard_financeiro.Dashboard.Financeiro.domain.model.CategoryType;
import com.dashboard_financeiro.Dashboard.Financeiro.infrastructure.persistence.entity.CategoryJpaEntity;

import java.time.LocalDateTime;
import java.util.UUID;

public record CategoryResponse(
        UUID id,
        UUID userId,
        String name,
        CategoryType type,
        String color,
        String icon,
        boolean active,
        LocalDateTime createdAt,
        LocalDateTime updatedAt
) {
    public static CategoryResponse from(CategoryJpaEntity entity) {
        return new CategoryResponse(
                entity.getId(),
                entity.getUserId(),
                entity.getName(),
                entity.getType(),
                entity.getColor(),
                entity.getIcon(),
                entity.isActive(),
                entity.getCreatedAt(),
                entity.getUpdatedAt()
        );
    }
}
