package com.dashboard_financeiro.notificacoes.application;

import com.dashboard_financeiro.notificacoes.config.NotificationEmailProperties;
import com.dashboard_financeiro.notificacoes.infrastructure.persistence.entity.NotificationUserEntity;
import com.dashboard_financeiro.notificacoes.infrastructure.resend.ResendEmailClient;
import com.dashboard_financeiro.notificacoes.infrastructure.resend.ResendEmailResponse;
import com.dashboard_financeiro.notificacoes.messaging.event.EmailVerificationRequestedEvent;
import com.dashboard_financeiro.notificacoes.messaging.event.GoalStatusChangedEvent;
import com.dashboard_financeiro.notificacoes.messaging.event.TransactionCreatedEvent;
import com.dashboard_financeiro.notificacoes.messaging.event.UserCreatedEvent;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.text.NumberFormat;
import java.time.Duration;
import java.time.Instant;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class EmailNotificationService {

    private static final Locale LOCALE_PT_BR = new Locale("pt", "BR");
    private static final NumberFormat CURRENCY_FORMAT = NumberFormat.getCurrencyInstance(LOCALE_PT_BR);
    private static final DateTimeFormatter DATE_FORMAT = DateTimeFormatter.ofPattern("dd/MM/yyyy");
    private static final DateTimeFormatter DATE_TIME_FORMAT = DateTimeFormatter.ofPattern("dd/MM/yyyy 'às' HH:mm", LOCALE_PT_BR);

    private final ResendEmailClient emailClient;
    private final NotificationEmailProperties emailProperties;
    private final NotificationLogService logService;
    private final ObjectMapper objectMapper;
    private final EmailTemplateService templateService;

    public void sendWelcomeEmail(UserCreatedEvent event, NotificationUserEntity user) {
        String recipient = event.email() != null ? event.email() : resolveRecipient(user);
        String subject = "Bem-vindo ao Dashboard Financeiro";
        String userName = preferredName(event.name(), user);

        Map<String, Object> templateModel = new HashMap<>();
        templateModel.put("subject", subject);
        templateModel.put("userName", userName);
        templateModel.put("firstName", firstName(userName));
        templateModel.put("hasUser", user != null);

        String registeredAt = formatInstant(event.registeredAt());
        if (registeredAt != null) {
            templateModel.put("registeredAt", registeredAt);
        }

        sendEmail(
                user,
                recipient,
                subject,
                "welcome_email",
                "email/welcome-email",
                templateModel,
                serialize(event)
        );
    }

    public void sendEmailVerification(EmailVerificationRequestedEvent event, NotificationUserEntity user) {
        String recipient = event.email() != null ? event.email() : resolveRecipient(user);
        String subject = "Confirme seu e-mail no Dashboard Financeiro";
        String userName = preferredName(event.name(), user);
        String expiresAt = formatInstant(event.expiresAt());
        Long minutesRemaining = null;
        if (event.expiresAt() != null) {
            long minutes = Duration.between(Instant.now(), event.expiresAt()).toMinutes();
            if (minutes > 0) {
                minutesRemaining = minutes;
            }
        }

        Map<String, Object> templateModel = new HashMap<>();
        templateModel.put("subject", subject);
        templateModel.put("userName", userName);
        templateModel.put("firstName", firstName(userName));
        templateModel.put("verificationCode", event.code());
        templateModel.put("reason", event.reason());
        templateModel.put("hasUser", user != null);
        if (expiresAt != null) {
            templateModel.put("expiresAt", expiresAt);
        }
        if (minutesRemaining != null) {
            templateModel.put("expiresInMinutes", minutesRemaining);
        }

        sendEmail(
                user,
                recipient,
                subject,
                "email_verification",
                "email/email-verification",
                templateModel,
                serialize(event)
        );
    }

    public void sendTransactionNotification(TransactionCreatedEvent event, NotificationUserEntity user) {
        String recipient = resolveRecipient(user);
        String subject = "Nova transação registrada";
        String category = event.categoryName() != null ? event.categoryName() : "Sem categoria";
        String amount = CURRENCY_FORMAT.format(event.amount());
        String createdAt = event.createdAt() != null ? DATE_TIME_FORMAT.format(event.createdAt()) : null;

        Map<String, Object> templateModel = new HashMap<>();
        templateModel.put("userName", resolveName(user));
        templateModel.put("subject", subject);
        templateModel.put("transactionType", event.type());
        templateModel.put("transactionAmount", amount);
        templateModel.put("transactionDate", DATE_FORMAT.format(event.transactionDate()));
        templateModel.put("transactionCategory", category);
        templateModel.put("transactionDescription", event.description());
        templateModel.put("hasDescription", event.description() != null && !event.description().isBlank());
        templateModel.put("hasUser", user != null);
        if (createdAt != null) {
            templateModel.put("registeredAt", createdAt);
        }

        sendEmail(
                user,
                recipient,
                subject,
                "transaction_notification",
                "email/transaction-notification",
                templateModel,
                serialize(event)
        );
    }

    public void sendGoalNotification(GoalStatusChangedEvent event, NotificationUserEntity user) {
        String recipient = resolveRecipient(user);
        String status = event.status();
        boolean achieved = "ACHIEVED".equalsIgnoreCase(status);
        boolean exceeded = "EXCEEDED".equalsIgnoreCase(status);
        String normalizedStatus = status != null ? status.toUpperCase(Locale.ROOT) : "";
        String statusLabel = switch (normalizedStatus) {
            case "ACHIEVED" -> "Meta alcançada";
            case "EXCEEDED" -> "Meta excedida";
            default -> status != null ? status : "Atualização de meta";
        };

        String subject = achieved
                ? "Parabéns! Você atingiu uma meta financeira"
                : exceeded
                ? "Atenção! Meta financeira excedida"
                : "Atualização de meta financeira";

        String progress = CURRENCY_FORMAT.format(event.currentAmount()) + " / " + CURRENCY_FORMAT.format(event.targetAmount());
        String goalPeriod = event.endDate() != null
                ? DATE_FORMAT.format(event.startDate()) + " até " + DATE_FORMAT.format(event.endDate())
                : "Iniciada em " + DATE_FORMAT.format(event.startDate());
        String name = resolveName(user);
        String achievedAt = event.achievedAt() != null ? DATE_TIME_FORMAT.format(event.achievedAt()) : null;
        String updatedAt = event.updatedAt() != null ? DATE_TIME_FORMAT.format(event.updatedAt()) : null;

        Map<String, Object> templateModel = new HashMap<>();
        templateModel.put("userName", name);
        templateModel.put("subject", subject);
        templateModel.put("goalName", event.name());
        templateModel.put("goalStatus", normalizedStatus);
        templateModel.put("goalStatusLabel", statusLabel);
        templateModel.put("goalType", event.type() != null ? event.type() : "Meta financeira");
        templateModel.put("achieved", achieved);
        templateModel.put("exceeded", exceeded);
        templateModel.put("progress", progress);
        templateModel.put("goalPeriod", goalPeriod);
        templateModel.put("categoryName", event.categoryName() != null ? event.categoryName() : "Sem categoria");
        templateModel.put("hasCategory", event.categoryName() != null && !event.categoryName().isBlank());
        templateModel.put("hasUser", user != null);
        if (achievedAt != null) {
            templateModel.put("achievedAt", achievedAt);
        }
        if (updatedAt != null) {
            templateModel.put("updatedAt", updatedAt);
        }

        sendEmail(
                user,
                recipient,
                subject,
                "goal_notification",
                "email/goal-notification",
                templateModel,
                serialize(event)
        );
    }

    private void sendEmail(NotificationUserEntity user,
                           String recipient,
                           String subject,
                           String template,
                           String templateView,
                           Map<String, Object> templateModel,
                           String payload) {

        if (!emailProperties.enabled()) {
            log.info("Envio de e-mails desabilitado. Notificação para {} será apenas registrada.", recipient);
            logService.record(user, recipient, subject, template, payload, "DISABLED", "Envio desabilitado");
            return;
        }

        try {
            templateModel.putIfAbsent("brandName", "Dashboard Financeiro");
            templateModel.putIfAbsent("dashboardUrl", emailProperties.dashboardUrl());
            templateModel.putIfAbsent("supportEmail", emailProperties.fallback());
            String body = templateService.render(templateView, templateModel);
            ResendEmailResponse response = emailClient.send(
                    emailProperties.from(),
                    recipient,
                    subject,
                    body
            );

            if (response != null && response.id() != null) {
                log.debug("E-mail enviado via Resend (id: {}) para {}", response.id(), recipient);
            }
            logService.record(user, recipient, subject, template, payload, "SENT", null);
        } catch (Exception ex) {
            log.error("Erro ao enviar e-mail para {}: {}", recipient, ex.getMessage(), ex);
            logService.record(user, recipient, subject, template, payload, "FAILED", ex.getMessage());
        }
    }

    private String resolveRecipient(NotificationUserEntity user) {
        String email = user != null ? user.getEmail() : null;
        return email != null ? email : emailProperties.fallback();
    }

    private String resolveName(NotificationUserEntity user) {
        if (user == null || user.getName() == null || user.getName().isBlank()) {
            return "Usuário";
        }
        return user.getName().trim();
    }

    private String preferredName(String eventName, NotificationUserEntity user) {
        if (eventName != null && !eventName.isBlank()) {
            return eventName;
        }
        return resolveName(user);
    }

    private String firstName(String name) {
        if (name == null || name.isBlank()) {
            return "Usuário";
        }
        String trimmed = name.trim();
        int space = trimmed.indexOf(' ');
        return space > 0 ? trimmed.substring(0, space) : trimmed;
    }

    private String formatInstant(Instant instant) {
        if (instant == null) {
            return null;
        }
        return DATE_TIME_FORMAT.format(instant.atZone(ZoneId.systemDefault()));
    }

    private String serialize(Object event) {
        try {
            return objectMapper.writeValueAsString(event);
        } catch (JsonProcessingException e) {
            return "{}";
        }
    }
}
