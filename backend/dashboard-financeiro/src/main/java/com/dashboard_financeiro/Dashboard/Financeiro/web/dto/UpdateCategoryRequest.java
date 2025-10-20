package com.dashboard_financeiro.Dashboard.Financeiro.web.dto;

import com.dashboard_financeiro.Dashboard.Financeiro.domain.model.CategoryType;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record UpdateCategoryRequest(
        @NotBlank(message = "O nome da categoria é obrigatório")
        @Size(max = 80, message = "O nome deve ter no máximo 80 caracteres")
        String name,

        @NotNull(message = "O tipo da categoria é obrigatório")
        CategoryType type,

        @Size(max = 20, message = "A cor deve ter no máximo 20 caracteres")
        String color,

        @Size(max = 80, message = "O ícone deve ter no máximo 80 caracteres")
        String icon,

        boolean active
) {
}
