package com.dashboard_financeiro.notificacoes.infrastructure.persistence.repository;

import com.dashboard_financeiro.notificacoes.infrastructure.persistence.entity.NotificationUserEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface NotificationUserRepository extends JpaRepository<NotificationUserEntity, UUID> {
    Optional<NotificationUserEntity> findByEmailIgnoreCase(String email);
}
