package com.dashboard_financeiro.gateway;

import com.dashboard_financeiro.gateway.config.GatewayCorsProperties;
import com.dashboard_financeiro.gateway.config.GatewaySecurityProperties;
import com.dashboard_financeiro.gateway.config.JwtProperties;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.EnableConfigurationProperties;

@SpringBootApplication
@EnableConfigurationProperties({JwtProperties.class, GatewaySecurityProperties.class, GatewayCorsProperties.class})
public class ApiGatewayApplication {

    public static void main(String[] args) {
        SpringApplication.run(ApiGatewayApplication.class, args);
    }
}
