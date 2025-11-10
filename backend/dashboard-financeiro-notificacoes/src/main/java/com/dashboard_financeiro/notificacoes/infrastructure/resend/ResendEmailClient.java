package com.dashboard_financeiro.notificacoes.infrastructure.resend;

import com.dashboard_financeiro.notificacoes.config.ResendProperties;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestClientResponseException;

import java.util.List;

@Slf4j
@Component
public class ResendEmailClient {

    private final ResendProperties properties;
    private final RestClient restClient;

    public ResendEmailClient(ResendProperties properties, RestClient.Builder builder) {
        this.properties = properties;
        this.restClient = builder
                .baseUrl(properties.baseUrl())
                .build();
    }

    public ResendEmailResponse send(String from, String to, String subject, String htmlBody) {
        if (!properties.hasApiKey()) {
            throw new ResendEmailException("Resend API key não configurada. Defina a variável RESEND_API_KEY.");
        }

        ResendEmailRequest payload = new ResendEmailRequest(
                from,
                List.of(to),
                subject,
                htmlBody
        );

        try {
            return restClient.post()
                    .uri("/emails")
                    .header(HttpHeaders.AUTHORIZATION, "Bearer " + properties.apiKey())
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(payload)
                    .retrieve()
                    .body(ResendEmailResponse.class);
        } catch (RestClientResponseException ex) {
            String responseSnippet = ex.getResponseBodyAsString();
            log.error("Erro da API Resend ({}): {}", ex.getStatusCode(), responseSnippet);
            throw new ResendEmailException("Falha ao enviar e-mail via Resend: " + ex.getStatusCode(), ex);
        } catch (RestClientException ex) {
            throw new ResendEmailException("Erro ao se comunicar com Resend: " + ex.getMessage(), ex);
        }
    }
}
