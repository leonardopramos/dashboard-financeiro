package com.dashboard_financeiro.notificacoes.infrastructure.resend;

import java.util.List;

record ResendEmailRequest(
        String from,
        List<String> to,
        String subject,
        String html
) {
}
