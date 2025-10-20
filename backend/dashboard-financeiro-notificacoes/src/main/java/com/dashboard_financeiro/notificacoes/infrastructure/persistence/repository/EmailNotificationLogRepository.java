package com.dashboard_financeiro.notificacoes.infrastructure.persistence.repository;

import com.dashboard_financeiro.notificacoes.infrastructure.persistence.entity.EmailNotificationLogEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface EmailNotificationLogRepository extends JpaRepository<EmailNotificationLogEntity, UUID> {
}
