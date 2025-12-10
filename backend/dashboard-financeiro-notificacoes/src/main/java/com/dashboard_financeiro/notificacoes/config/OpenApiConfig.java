package com.dashboard_financeiro.notificacoes.config;

import io.swagger.v3.oas.annotations.OpenAPIDefinition;
import io.swagger.v3.oas.annotations.info.Contact;
import io.swagger.v3.oas.annotations.info.Info;
import org.springframework.context.annotation.Configuration;

@Configuration
@OpenAPIDefinition(
        info = @Info(
                title = "Dashboard Financeiro – Notificações",
                version = "1.0",
                description = "Serviço responsável por consumir eventos e disparar e-mails de notificação.",
                contact = @Contact(name = "Dashboard Financeiro", email = "suporte@dashboard-financeiro.local")
        )
)
public class OpenApiConfig {
}
