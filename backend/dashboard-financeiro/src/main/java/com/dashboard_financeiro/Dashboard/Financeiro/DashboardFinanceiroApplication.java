package com.dashboard_financeiro.Dashboard.Financeiro;

import com.dashboard_financeiro.Dashboard.Financeiro.config.JwtProperties;
import com.dashboard_financeiro.Dashboard.Financeiro.config.KafkaTopicsProperties;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.EnableConfigurationProperties;

@SpringBootApplication
@EnableConfigurationProperties({JwtProperties.class, KafkaTopicsProperties.class})
public class DashboardFinanceiroApplication {

	public static void main(String[] args) {
		SpringApplication.run(DashboardFinanceiroApplication.class, args);
	}

}
