package com.dashboard_financeiro.notificacoes.application;

import com.dashboard_financeiro.notificacoes.infrastructure.persistence.entity.EmailNotificationLogEntity;
import com.dashboard_financeiro.notificacoes.infrastructure.persistence.entity.NotificationUserEntity;
import com.dashboard_financeiro.notificacoes.infrastructure.persistence.repository.EmailNotificationLogRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class NotificationLogService {

    private final EmailNotificationLogRepository repository;

    @Transactional
    public void record(NotificationUserEntity user,
                       String email,
                       String subject,
                       String template,
                       String payload,
                       String status,
                       String errorMessage) {

        EmailNotificationLogEntity entity = EmailNotificationLogEntity.builder()
                .id(UUID.randomUUID())
                .user(user)
                .email(email)
                .subject(subject)
                .template(template)
                .payload(payload)
                .status(status)
                .errorMessage(errorMessage)
                .build();

        repository.save(entity);

        if ("SENT".equalsIgnoreCase(status)) {
            log.debug("Notificação registrada como enviada para {}", email);
        } else {
            log.warn("Falha ao enviar notificação para {}: {}", email, errorMessage);
        }
    }
}
