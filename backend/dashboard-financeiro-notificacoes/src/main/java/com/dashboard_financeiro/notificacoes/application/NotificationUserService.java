package com.dashboard_financeiro.notificacoes.application;

import com.dashboard_financeiro.notificacoes.infrastructure.persistence.entity.NotificationUserEntity;
import com.dashboard_financeiro.notificacoes.infrastructure.persistence.repository.NotificationUserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class NotificationUserService {

    private final NotificationUserRepository repository;

    @Transactional
    public NotificationUserEntity upsertUser(UUID userId, String email, String name, boolean active) {
        NotificationUserEntity entity = repository.findById(userId)
                .orElseGet(() -> NotificationUserEntity.builder()
                        .id(userId)
                        .build());

        entity.setEmail(email.toLowerCase());
        entity.setName(name);
        entity.setActive(active);

        NotificationUserEntity saved = repository.save(entity);
        log.debug("Usuário de notificação {} sincronizado (ativo={})", saved.getId(), saved.isActive());
        return saved;
    }

    @Transactional(readOnly = true)
    public NotificationUserEntity findById(UUID userId) {
        return repository.findById(userId).orElse(null);
    }
}
