package com.dashboard_financeiro.notificacoes.web.controller;

import com.dashboard_financeiro.notificacoes.config.NotificationEmailProperties;
import com.dashboard_financeiro.notificacoes.config.NotificationTopicsProperties;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/notifications")
@RequiredArgsConstructor
@Tag(name = "Notificações", description = "Visão geral do serviço de notificações")
public class NotificationController {

    private final NotificationTopicsProperties topicsProperties;
    private final NotificationEmailProperties emailProperties;

    @GetMapping("/status")
    @Operation(
            summary = "Status e configuração do serviço",
            description = "Retorna informações sobre tópicos Kafka monitorados e configurações de e-mail."
    )
    public ResponseEntity<Map<String, Object>> status() {
        Map<String, Object> payload = new HashMap<>();
        payload.put("kafkaTopics", Map.of(
                "userEvents", topicsProperties.userEvents(),
                "transactionEvents", topicsProperties.transactionEvents(),
                "goalEvents", topicsProperties.goalEvents(),
                "emailVerificationEvents", topicsProperties.emailVerificationEvents()
        ));
        payload.put("email", Map.of(
                "from", emailProperties.from(),
                "fallback", emailProperties.fallback(),
                "enabled", emailProperties.enabled()
        ));
        return ResponseEntity.ok(payload);
    }
}
