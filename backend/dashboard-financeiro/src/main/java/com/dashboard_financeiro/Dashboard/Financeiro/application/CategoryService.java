package com.dashboard_financeiro.Dashboard.Financeiro.application;

import com.dashboard_financeiro.Dashboard.Financeiro.domain.exception.BusinessException;
import com.dashboard_financeiro.Dashboard.Financeiro.domain.exception.ResourceNotFoundException;
import com.dashboard_financeiro.Dashboard.Financeiro.infrastructure.persistence.entity.CategoryJpaEntity;
import com.dashboard_financeiro.Dashboard.Financeiro.infrastructure.persistence.repository.CategoryJpaRepository;
import com.dashboard_financeiro.Dashboard.Financeiro.web.dto.CategoryResponse;
import com.dashboard_financeiro.Dashboard.Financeiro.web.dto.CreateCategoryRequest;
import com.dashboard_financeiro.Dashboard.Financeiro.web.dto.UpdateCategoryRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class CategoryService {

    private final CategoryJpaRepository repository;

    @Transactional
    public CategoryResponse create(UUID userId, CreateCategoryRequest request) {
        String normalizedName = request.name().trim();
        var existingOpt = repository.findByUserIdAndNameIgnoreCase(userId, normalizedName);
        if (existingOpt.isPresent()) {
            CategoryJpaEntity existing = existingOpt.get();
            if (existing.isActive()) {
                throw new BusinessException("Categoria já cadastrada com esse nome");
            }

            existing.setType(request.type());
            existing.setColor(request.color());
            existing.setIcon(request.icon());
            existing.setActive(true);
            CategoryJpaEntity reactivated = repository.save(existing);
            log.info("Categoria {} reativada para o usuário {}", reactivated.getId(), userId);
            return CategoryResponse.from(reactivated);
        }

        CategoryJpaEntity entity = CategoryJpaEntity.builder()
                .id(UUID.randomUUID())
                .userId(userId)
                .name(normalizedName)
                .type(request.type())
                .color(request.color())
                .icon(request.icon())
                .active(true)
                .build();

        CategoryJpaEntity saved = repository.save(entity);
        log.info("Categoria {} criada para o usuário {}", saved.getId(), userId);
        return CategoryResponse.from(saved);
    }

    @Transactional(readOnly = true)
    public List<CategoryResponse> list(UUID userId) {
        return repository.findByUserIdAndActiveTrueOrderByNameAsc(userId)
                .stream()
                .map(CategoryResponse::from)
                .toList();
    }

    @Transactional
    public CategoryResponse update(UUID userId, UUID categoryId, UpdateCategoryRequest request) {
        CategoryJpaEntity entity = getEntity(userId, categoryId);

        String normalizedName = request.name().trim();
        repository.findByUserIdAndNameIgnoreCase(userId, normalizedName)
                .filter(existing -> !existing.getId().equals(entity.getId()))
                .ifPresent(existing -> {
                    throw new BusinessException("Já existe outra categoria com esse nome");
                });

        entity.setName(normalizedName);
        entity.setType(request.type());
        entity.setColor(request.color());
        entity.setIcon(request.icon());
        entity.setActive(request.active());

        return CategoryResponse.from(repository.save(entity));
    }

    @Transactional
    public void delete(UUID userId, UUID categoryId) {
        CategoryJpaEntity entity = getEntity(userId, categoryId);
        entity.setActive(false);
        repository.save(entity);
        log.info("Categoria {} desativada para usuário {}", categoryId, userId);
    }

    @Transactional(readOnly = true)
    public CategoryJpaEntity getEntity(UUID userId, UUID categoryId) {
        CategoryJpaEntity category = repository.findByIdAndUserId(categoryId, userId)
                .orElseThrow(() -> new ResourceNotFoundException("Categoria não encontrada"));

        if (!category.isActive()) {
            throw new BusinessException("Categoria inativa");
        }

        return category;
    }
}
