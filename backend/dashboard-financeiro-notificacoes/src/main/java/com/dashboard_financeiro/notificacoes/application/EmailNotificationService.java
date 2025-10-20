package com.dashboard_financeiro.notificacoes.application;

import com.dashboard_financeiro.notificacoes.config.NotificationEmailProperties;
import com.dashboard_financeiro.notificacoes.infrastructure.persistence.entity.NotificationUserEntity;
import com.dashboard_financeiro.notificacoes.messaging.event.GoalStatusChangedEvent;
import com.dashboard_financeiro.notificacoes.messaging.event.TransactionCreatedEvent;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.mail.internet.MimeMessage;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.mail.MailSender;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;

import java.nio.charset.StandardCharsets;
import java.text.NumberFormat;
import java.time.format.DateTimeFormatter;
import java.util.Locale;

@Slf4j
@Service
@RequiredArgsConstructor
public class EmailNotificationService {

    private static final Locale LOCALE_PT_BR = new Locale("pt", "BR");
    private static final NumberFormat CURRENCY_FORMAT = NumberFormat.getCurrencyInstance(LOCALE_PT_BR);
    private static final DateTimeFormatter DATE_FORMAT = DateTimeFormatter.ofPattern("dd/MM/yyyy");

    private final JavaMailSender mailSender;
    private final NotificationEmailProperties emailProperties;
    private final NotificationLogService logService;
    private final ObjectMapper objectMapper;

    public void sendTransactionNotification(TransactionCreatedEvent event, NotificationUserEntity user) {
        String recipient = resolveRecipient(user);
        String subject = "Nova transação registrada";
        String category = event.categoryName() != null ? event.categoryName() : "Sem categoria";
        String amount = CURRENCY_FORMAT.format(event.amount());

        String body = """
                Olá %s,

                Uma nova transação foi registrada no Dashboard Financeiro.

                Tipo: %s
                Valor: %s
                Data: %s
                Categoria: %s
                Descrição: %s

                Continue acompanhando suas finanças pelo dashboard!
                """.formatted(
                resolveName(user),
                event.type(),
                amount,
                DATE_FORMAT.format(event.transactionDate()),
                category,
                event.description()
        );

        sendEmail(user, recipient, subject, body, "transaction_notification", serialize(event));
    }

    public void sendGoalNotification(GoalStatusChangedEvent event, NotificationUserEntity user) {
        String recipient = resolveRecipient(user);
        String status = event.status();
        boolean achieved = "ACHIEVED".equalsIgnoreCase(status);
        boolean exceeded = "EXCEEDED".equalsIgnoreCase(status);

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

        String body;
        if (achieved) {
            body = """
                    Olá %s,

                    Parabéns! Você atingiu a meta "%s".

                    Progresso: %s
                    Período: %s

                    Continue firme na sua jornada financeira.
                    """.formatted(name, event.name(), progress, goalPeriod);
        } else if (exceeded) {
            body = """
                    Olá %s,

                    Sua meta "%s" foi excedida.

                    Progresso: %s
                    Período: %s

                    Reveja seu planejamento e ajuste suas finanças.
                    """.formatted(name, event.name(), progress, goalPeriod);
        } else {
            body = """
                    Olá %s,

                    Sua meta "%s" foi atualizada.

                    Progresso: %s
                    Período: %s

                    """.formatted(name, event.name(), progress, goalPeriod);
        }

        sendEmail(user, recipient, subject, body, "goal_notification", serialize(event));
    }

    private void sendEmail(NotificationUserEntity user,
                           String recipient,
                           String subject,
                           String body,
                           String template,
                           String payload) {

        if (!emailProperties.enabled()) {
            log.info("Envio de e-mails desabilitado. Notificação para {} será apenas registrada.", recipient);
            logService.record(user, recipient, subject, template, payload, "DISABLED", "Envio desabilitado");
            return;
        }

        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, false, StandardCharsets.UTF_8.name());
            helper.setFrom(emailProperties.from());
            helper.setTo(recipient);
            helper.setSubject(subject);
            helper.setText(body, false);

            mailSender.send(message);
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
            return "usuário";
        }
        return user.getName();
    }

    private String serialize(Object event) {
        try {
            return objectMapper.writeValueAsString(event);
        } catch (JsonProcessingException e) {
            return "{}";
        }
    }
}
