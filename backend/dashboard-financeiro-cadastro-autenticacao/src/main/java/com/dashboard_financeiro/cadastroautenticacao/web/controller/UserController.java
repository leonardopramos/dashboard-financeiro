package com.dashboard_financeiro.cadastroautenticacao.web.controller;

import com.dashboard_financeiro.cadastroautenticacao.application.UserService;
import com.dashboard_financeiro.cadastroautenticacao.security.AuthenticatedUser;
import com.dashboard_financeiro.cadastroautenticacao.web.dto.CreateUserRequest;
import com.dashboard_financeiro.cadastroautenticacao.web.dto.UpdateUserRequest;
import com.dashboard_financeiro.cadastroautenticacao.web.dto.UserDTO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/users")
@RequiredArgsConstructor
@Tag(name = "Usuários")
public class UserController {

    private final UserService service;

    @PostMapping
    @Operation(
            summary = "Registrar usuário",
            description = "Cria um novo usuário e dispara verificação de e-mail."
    )
    public ResponseEntity<UserDTO> register(@Valid @RequestBody CreateUserRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.register(request));
    }

    @GetMapping("/{id}")
    @Operation(
            summary = "Buscar usuário por id",
            description = "Retorna o perfil do próprio usuário ou, se ADMIN, de outro usuário."
    )
    @SecurityRequirement(name = "bearerAuth")
    public ResponseEntity<UserDTO> getById(@PathVariable UUID id, @AuthenticationPrincipal AuthenticatedUser currentUser) {
        if (currentUser == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }

        if (!id.equals(currentUser.id()) && !currentUser.hasRole("ADMIN")) {
            throw new AccessDeniedException("Acesso negado para consultar outro usuário");
        }

        return ResponseEntity.ok(service.getById(id));
    }

    @PutMapping("/{id}")
    @Operation(
            summary = "Atualizar usuário",
            description = "Permite ao usuário alterar seus dados ou um ADMIN atualizar outro usuário."
    )
    @SecurityRequirement(name = "bearerAuth")
    public ResponseEntity<UserDTO> update(@PathVariable UUID id,
                                          @AuthenticationPrincipal AuthenticatedUser currentUser,
                                          @Valid @RequestBody UpdateUserRequest request) {
        if (currentUser == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }

        if (!id.equals(currentUser.id()) && !currentUser.hasRole("ADMIN")) {
            throw new AccessDeniedException("Acesso negado para atualizar outro usuário");
        }

        return ResponseEntity.ok(service.update(id, request));
    }

    @DeleteMapping("/{id}")
    @Operation(
            summary = "Remover usuário",
            description = "Exclui a própria conta ou, para ADMIN, remove outro usuário."
    )
    @SecurityRequirement(name = "bearerAuth")
    public ResponseEntity<Void> delete(@PathVariable UUID id,
                                       @AuthenticationPrincipal AuthenticatedUser currentUser) {
        if (currentUser == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }

        if (!id.equals(currentUser.id()) && !currentUser.hasRole("ADMIN")) {
            throw new AccessDeniedException("Acesso negado para excluir outro usuário");
        }

        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}
