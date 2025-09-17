package com.dashboard_financeiro.cadastroautenticacao.web.dto;

import jakarta.validation.constraints.*;

public record CreateUserRequest(
        @NotBlank String cpf,
        @NotBlank String name,
        @Email @NotBlank String email,
        @Size(min = 6) String password,
        String role,
        String street,
        Integer number,
        String neighborhood,
        String complement,
        String city,
        String state,
        String zipCode
) {}
