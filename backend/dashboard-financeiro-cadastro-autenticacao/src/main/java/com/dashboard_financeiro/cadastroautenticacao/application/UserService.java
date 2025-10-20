package com.dashboard_financeiro.cadastroautenticacao.application;

import com.dashboard_financeiro.cadastroautenticacao.infrastructure.persistence.entity.UserJpaEntity;
import com.dashboard_financeiro.cadastroautenticacao.infrastructure.persistence.repository.UserJpaRepository;
import com.dashboard_financeiro.cadastroautenticacao.messaging.UserEventProducer;
import com.dashboard_financeiro.cadastroautenticacao.messaging.event.UserRegisteredEvent;
import com.dashboard_financeiro.cadastroautenticacao.web.dto.CreateUserRequest;
import com.dashboard_financeiro.cadastroautenticacao.web.dto.UserDTO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionSynchronization;
import org.springframework.transaction.support.TransactionSynchronizationManager;
import org.springframework.util.StringUtils;

import java.time.Instant;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class UserService {

    private final UserJpaRepository repo;
    private final PasswordEncoder encoder;
    private final UserEventProducer eventProducer;

    @Transactional
    public UserDTO register(CreateUserRequest req) {
        String normalizedEmail = normalizeEmail(req.email());
        String normalizedCpf = req.cpf() != null ? req.cpf().trim() : null;
        repo.findByEmail(normalizedEmail)
                .ifPresent(u -> { throw new IllegalArgumentException("Email já cadastrado"); });

        repo.findByCpf(normalizedCpf)
                .ifPresent(u -> { throw new IllegalArgumentException("CPF já cadastrado"); });

        var entity = UserJpaEntity.builder()
                .id(UUID.randomUUID())
                .cpf(normalizedCpf)
                .name(req.name().trim())
                .email(normalizedEmail)
                .password(encoder.encode(req.password()))
                .role(determineRole(req.role()))
                .street(req.street())
                .number(req.number())
                .neighborhood(req.neighborhood())
                .complement(req.complement())
                .city(req.city())
                .state(req.state())
                .zipCode(req.zipCode())
                .active(true)
                .emailVerified(false)
                .build();

        UserJpaEntity saved = repo.save(entity);
        enqueueUserRegisteredEvent(saved);
        log.info("Usuário cadastrado com sucesso: {}", saved.getId());
        return UserDTO.from(saved);
    }

    @Transactional(readOnly = true)
    public UserDTO getById(UUID id) {
        return repo.findById(id)
                .map(UserDTO::from)
                .orElseThrow(() -> new IllegalArgumentException("Usuário não encontrado"));
    }

    private void enqueueUserRegisteredEvent(UserJpaEntity entity) {
        Runnable publishTask = () -> publishUserRegistered(entity);
        if (TransactionSynchronizationManager.isSynchronizationActive()) {
            TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronization() {
                @Override
                public void afterCommit() {
                    publishTask.run();
                }
            });
        } else {
            publishTask.run();
        }
    }

    private void publishUserRegistered(UserJpaEntity entity) {
        Instant registeredAt = entity.getRegisteredAt() != null
                ? entity.getRegisteredAt().atZone(java.time.ZoneId.systemDefault()).toInstant()
                : Instant.now();

        eventProducer.publishUserRegistered(new UserRegisteredEvent(
                entity.getId(),
                entity.getEmail(),
                entity.getName(),
                entity.getRole(),
                entity.isEmailVerified(),
                registeredAt
        ));
    }

    private String determineRole(String role) {
        return StringUtils.hasText(role) ? role.trim().toUpperCase() : "USER";
    }

    private String normalizeEmail(String email) {
        return email == null ? null : email.trim().toLowerCase();
    }
}
