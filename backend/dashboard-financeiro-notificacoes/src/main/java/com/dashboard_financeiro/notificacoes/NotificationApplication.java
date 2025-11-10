package com.dashboard_financeiro.notificacoes;

import com.dashboard_financeiro.notificacoes.config.NotificationEmailProperties;
import com.dashboard_financeiro.notificacoes.config.NotificationTopicsProperties;
import com.dashboard_financeiro.notificacoes.config.ResendProperties;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.EnableConfigurationProperties;

@SpringBootApplication
@EnableConfigurationProperties({NotificationTopicsProperties.class, NotificationEmailProperties.class, ResendProperties.class})
public class NotificationApplication {

	public static void main(String[] args) {
		SpringApplication.run(NotificationApplication.class, args);
	}

}
