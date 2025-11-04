package com.dashboard_financeiro.cadastroautenticacao.web.dto;

import jakarta.validation.constraints.NotBlank;

public record UpdateUserRequest(
        @NotBlank String cpf,
        @NotBlank String name,
        String street,
        Integer number,
        String neighborhood,
        String complement,
        String city,
        String state,
        String zipCode
) {}
