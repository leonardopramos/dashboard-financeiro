package com.dashboard_financeiro.cadastroautenticacao.application;

import com.dashboard_financeiro.cadastroautenticacao.config.EmailVerificationProperties;
import com.dashboard_financeiro.cadastroautenticacao.infrastructure.persistence.entity.EmailVerificationTokenEntity;
import com.dashboard_financeiro.cadastroautenticacao.infrastructure.persistence.entity.UserJpaEntity;
import com.dashboard_financeiro.cadastroautenticacao.infrastructure.persistence.repository.EmailVerificationTokenRepository;
import com.dashboard_financeiro.cadastroautenticacao.infrastructure.persistence.repository.UserJpaRepository;
import com.dashboard_financeiro.cadastroautenticacao.messaging.UserEventProducer;
import com.dashboard_financeiro.cadastroautenticacao.messaging.event.EmailVerificationRequestedEvent;
import org.springframework.transaction.annotation.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.support.TransactionSynchronization;
import org.springframework.transaction.support.TransactionSynchronizationManager;

import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.util.Locale;

@Slf4j
@Service
@RequiredArgsConstructor
public class EmailVerificationService {

    private static final String DEFAULT_REASON = "REGISTRATION";

    private final EmailVerificationTokenRepository tokenRepository;
    private final EmailVerificationProperties properties;
    private final UserEventProducer userEventProducer;
    private final org.springframework.security.crypto.password.PasswordEncoder passwordEncoder;
    private final UserJpaRepository userJpaRepository;

    @Transactional
    public void createTokenFor(UserJpaEntity user) {
        createTokenFor(user, DEFAULT_REASON);
    }

    @Transactional
    public void createTokenFor(UserJpaEntity user, String reason) {
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime cooldownThreshold = now.minusMinutes(properties.resendCooldownMinutes());

        tokenRepository.findFirstByUser_IdAndVerifiedAtIsNullOrderByCreatedAtDesc(user.getId())
                .ifPresent(existing -> {
                    if (!existing.isExpired(now) && existing.getCreatedAt().isAfter(cooldownThreshold)) {
                        throw new IllegalStateException("Um código foi enviado recentemente. Aguarde alguns minutos antes de solicitar outro.");
                    }
                    log.debug("Invalidando token anterior para usuário {}", user.getId());
                    existing.setExpiresAt(now.minusSeconds(1));
                    tokenRepository.save(existing);
                });

        String rawCode = generateCode(properties.codeLength());
        LocalDateTime expiresAt = now.plusMinutes(properties.expirationMinutes());

        EmailVerificationTokenEntity entity = EmailVerificationTokenEntity.builder()
                .user(user)
                .codeHash(passwordEncoder.encode(rawCode))
                .expiresAt(expiresAt)
                .reason(reason != null ? reason.toUpperCase(Locale.ROOT) : DEFAULT_REASON)
                .build();

        EmailVerificationTokenEntity saved = tokenRepository.save(entity);
        enqueueVerificationRequestedEvent(user, rawCode, saved.getExpiresAt(), saved.getReason());
        log.info("Token de verificação gerado para usuário {}", user.getId());
    }

    @Transactional
    public void verify(UserJpaEntity user, String rawCode) {
        LocalDateTime now = LocalDateTime.now();

        EmailVerificationTokenEntity token = tokenRepository
                .findFirstByUser_IdAndVerifiedAtIsNullOrderByCreatedAtDesc(user.getId())
                .orElseThrow(() -> new IllegalArgumentException("Nenhum código de verificação pendente."));

        if (token.isExpired(now)) {
            throw new IllegalArgumentException("Código expirado. Solicite um novo código.");
        }

        if (!passwordEncoder.matches(rawCode, token.getCodeHash())) {
            token.incrementAttempts();
            if (token.getAttempts() >= properties.maxAttempts()) {
                token.setExpiresAt(now.minusSeconds(1));
                tokenRepository.save(token);
                throw new IllegalArgumentException("Número máximo de tentativas excedido. Solicite um novo código.");
            }
            tokenRepository.save(token);
            throw new IllegalArgumentException("Código inválido. Verifique e tente novamente.");
        }

        token.setVerifiedAt(now);
        tokenRepository.save(token);

        tokenRepository.markAllAsVerified(user.getId(), now);

        user.setEmailVerified(true);
        userJpaRepository.save(user); // persist verification flag update
        log.info("E-mail do usuário {} verificado com sucesso.", user.getId());
    }

    private void enqueueVerificationRequestedEvent(UserJpaEntity user,
                                                   String rawCode,
                                                   LocalDateTime expiresAt,
                                                   String reason) {
        Runnable publishTask = () -> {
            EmailVerificationRequestedEvent event = new EmailVerificationRequestedEvent(
                    user.getId(),
                    user.getEmail(),
                    user.getName(),
                    rawCode,
                    expiresAt.toInstant(ZoneOffset.UTC),
                    reason
            );
            userEventProducer.publishVerificationRequested(event);
        };

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

    private String generateCode(int length) {
        SecureRandom random = new SecureRandom();
        StringBuilder builder = new StringBuilder(length);
        for (int i = 0; i < length; i++) {
            builder.append(random.nextInt(10));
        }
        return builder.toString();
    }
}
