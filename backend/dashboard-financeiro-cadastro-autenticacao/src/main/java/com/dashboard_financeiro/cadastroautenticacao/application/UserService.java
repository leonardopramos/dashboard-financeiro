package com.dashboard_financeiro.cadastroautenticacao.application;

import com.dashboard_financeiro.cadastroautenticacao.infrastructure.persistence.entity.UserJpaEntity;
import com.dashboard_financeiro.cadastroautenticacao.infrastructure.persistence.repository.UserJpaRepository;
import com.dashboard_financeiro.cadastroautenticacao.infrastructure.persistence.repository.EmailVerificationTokenRepository;
import com.dashboard_financeiro.cadastroautenticacao.messaging.UserEventProducer;
import com.dashboard_financeiro.cadastroautenticacao.messaging.event.UserRegisteredEvent;
import com.dashboard_financeiro.cadastroautenticacao.web.dto.CreateUserRequest;
import com.dashboard_financeiro.cadastroautenticacao.web.dto.UpdateUserRequest;
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
    private final EmailVerificationService emailVerificationService;
    private final EmailVerificationTokenRepository tokenRepository;

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
        emailVerificationService.createTokenFor(saved);
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

    @Transactional
    public UserDTO update(UUID id, UpdateUserRequest request) {
        UserJpaEntity entity = repo.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Usuário não encontrado"));

        String normalizedCpf = request.cpf().trim();
        repo.findByCpf(normalizedCpf)
                .filter(found -> !found.getId().equals(id))
                .ifPresent(u -> { throw new IllegalArgumentException("CPF já cadastrado"); });

        entity.setCpf(normalizedCpf);
        entity.setName(request.name().trim());
        entity.setStreet(trimToNull(request.street()));
        entity.setNumber(request.number());
        entity.setNeighborhood(trimToNull(request.neighborhood()));
        entity.setComplement(trimToNull(request.complement()));
        entity.setCity(trimToNull(request.city()));
        entity.setState(trimToNull(request.state() != null ? request.state().toUpperCase() : null));
        entity.setZipCode(normalizeZipCode(request.zipCode()));

        return UserDTO.from(entity);
    }

    @Transactional
    public void delete(UUID id) {
        UserJpaEntity entity = repo.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Usuário não encontrado"));

        tokenRepository.deleteByUser_Id(id);
        repo.delete(entity);
        log.info("Usuário removido com sucesso: {}", id);
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

    private String trimToNull(String value) {
        return StringUtils.hasText(value) ? value.trim() : null;
    }

    private String normalizeZipCode(String zipCode) {
        if (!StringUtils.hasText(zipCode)) {
            return null;
        }
        String digits = zipCode.replaceAll("\\D", "");
        if (digits.length() != 8) {
            return zipCode.trim();
        }
        return digits.substring(0, 5) + "-" + digits.substring(5);
    }
}
