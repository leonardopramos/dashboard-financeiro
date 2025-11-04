package com.dashboard_financeiro.notificacoes.application;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.thymeleaf.context.Context;
import org.thymeleaf.spring6.SpringTemplateEngine;

import java.util.Locale;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class EmailTemplateService {

    private static final Locale LOCALE_PT_BR = new Locale("pt", "BR");

    private final SpringTemplateEngine templateEngine;

    public String render(String templateName, Map<String, Object> variables) {
        Context context = new Context(LOCALE_PT_BR);
        context.setVariables(variables);
        return templateEngine.process(templateName, context);
    }
}
