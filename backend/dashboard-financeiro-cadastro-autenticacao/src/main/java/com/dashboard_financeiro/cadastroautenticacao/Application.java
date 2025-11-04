package com.dashboard_financeiro.cadastroautenticacao;

import com.dashboard_financeiro.cadastroautenticacao.config.EmailVerificationProperties;
import com.dashboard_financeiro.cadastroautenticacao.config.JwtProperties;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.EnableConfigurationProperties;

@SpringBootApplication
@EnableConfigurationProperties({JwtProperties.class, EmailVerificationProperties.class})
public class Application {

	public static void main(String[] args) {
		SpringApplication.run(Application.class, args);
	}

}
