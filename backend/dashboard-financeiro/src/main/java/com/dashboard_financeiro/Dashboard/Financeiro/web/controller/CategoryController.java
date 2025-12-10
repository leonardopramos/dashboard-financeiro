package com.dashboard_financeiro.Dashboard.Financeiro.web.controller;

import com.dashboard_financeiro.Dashboard.Financeiro.application.CategoryService;
import com.dashboard_financeiro.Dashboard.Financeiro.security.AuthenticatedUser;
import com.dashboard_financeiro.Dashboard.Financeiro.web.dto.CategoryResponse;
import com.dashboard_financeiro.Dashboard.Financeiro.web.dto.CreateCategoryRequest;
import com.dashboard_financeiro.Dashboard.Financeiro.web.dto.UpdateCategoryRequest;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import java.net.URI;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/categories")
@RequiredArgsConstructor
@Tag(name = "Categorias")
@SecurityRequirement(name = "bearerAuth")
public class CategoryController {

    private final CategoryService categoryService;

    @PostMapping
    @Operation(
            summary = "Criar categoria",
            description = "Registra uma nova categoria personalizada vinculada ao usuário autenticado."
    )
    public ResponseEntity<CategoryResponse> create(@AuthenticationPrincipal AuthenticatedUser currentUser,
                                                   @Valid @RequestBody CreateCategoryRequest request) {
        CategoryResponse response = categoryService.create(currentUser.id(), request);
        URI location = ServletUriComponentsBuilder.fromCurrentRequest()
                .path("/{id}")
                .buildAndExpand(response.id())
                .toUri();
        return ResponseEntity.created(location).body(response);
    }

    @GetMapping
    @Operation(
            summary = "Listar categorias do usuário",
            description = "Retorna todas as categorias cadastradas pelo usuário autenticado."
    )
    public ResponseEntity<List<CategoryResponse>> list(@AuthenticationPrincipal AuthenticatedUser currentUser) {
        return ResponseEntity.ok(categoryService.list(currentUser.id()));
    }

    @PutMapping("/{id}")
    @Operation(
            summary = "Atualizar categoria",
            description = "Altera nome e configuração de uma categoria existente do usuário."
    )
    public ResponseEntity<CategoryResponse> update(@PathVariable UUID id,
                                                    @AuthenticationPrincipal AuthenticatedUser currentUser,
                                                    @Valid @RequestBody UpdateCategoryRequest request) {
        CategoryResponse response = categoryService.update(currentUser.id(), id, request);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{id}")
    @Operation(
            summary = "Remover categoria",
            description = "Exclui uma categoria do usuário autenticado e ajusta vínculos existentes."
    )
    public ResponseEntity<Void> delete(@PathVariable UUID id,
                                       @AuthenticationPrincipal AuthenticatedUser currentUser) {
        categoryService.delete(currentUser.id(), id);
        return ResponseEntity.status(HttpStatus.NO_CONTENT).build();
    }
}
