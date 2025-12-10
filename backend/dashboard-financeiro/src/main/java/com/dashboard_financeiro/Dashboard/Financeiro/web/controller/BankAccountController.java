package com.dashboard_financeiro.Dashboard.Financeiro.web.controller;

import com.dashboard_financeiro.Dashboard.Financeiro.application.BankAccountService;
import com.dashboard_financeiro.Dashboard.Financeiro.security.AuthenticatedUser;
import com.dashboard_financeiro.Dashboard.Financeiro.web.dto.BankAccountResponse;
import com.dashboard_financeiro.Dashboard.Financeiro.web.dto.CreateBankAccountRequest;
import com.dashboard_financeiro.Dashboard.Financeiro.web.dto.UpdateBankAccountRequest;
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
@RequestMapping("/api/v1/bank-accounts")
@RequiredArgsConstructor
@Tag(name = "Contas bancárias")
@SecurityRequirement(name = "bearerAuth")
public class BankAccountController {

    private final BankAccountService bankAccountService;

    @PostMapping
    @Operation(
            summary = "Criar conta bancária",
            description = "Cadastra uma nova conta bancária (instituição, tipo, saldo inicial) para o usuário autenticado."
    )
    public ResponseEntity<BankAccountResponse> create(@AuthenticationPrincipal AuthenticatedUser currentUser,
                                                      @Valid @RequestBody CreateBankAccountRequest request) {
        var response = bankAccountService.register(currentUser.id(), request);
        URI location = ServletUriComponentsBuilder.fromCurrentRequest()
                .path("/{id}")
                .buildAndExpand(response.id())
                .toUri();
        return ResponseEntity.created(location).body(response);
    }

    @GetMapping("/{id}")
    @Operation(
            summary = "Buscar conta bancária por id",
            description = "Retorna os detalhes de uma conta bancária do usuário autenticado."
    )
    public ResponseEntity<BankAccountResponse> getById(@PathVariable UUID id,
                                                       @AuthenticationPrincipal AuthenticatedUser currentUser) {
        return ResponseEntity.ok(bankAccountService.findById(currentUser.id(), id));
    }

    @PutMapping("/{id}")
    @Operation(
            summary = "Atualizar conta bancária",
            description = "Edita dados de uma conta bancária (nome, instituição, saldo) do usuário."
    )
    public ResponseEntity<BankAccountResponse> update(@PathVariable UUID id,
                                                      @AuthenticationPrincipal AuthenticatedUser currentUser,
                                                      @Valid @RequestBody UpdateBankAccountRequest request) {
        return ResponseEntity.ok(bankAccountService.update(currentUser.id(), id, request));
    }

    @GetMapping
    @Operation(
            summary = "Listar contas do usuário",
            description = "Retorna todas as contas bancárias cadastradas pelo usuário autenticado."
    )
    public ResponseEntity<List<BankAccountResponse>> getByUser(@AuthenticationPrincipal AuthenticatedUser currentUser) {
        return ResponseEntity.ok(bankAccountService.findByUser(currentUser.id()));
    }

    @DeleteMapping("/{id}")
    @Operation(
            summary = "Excluir conta bancária",
            description = "Remove uma conta bancária do usuário autenticado e suas referências em transações."
    )
    public ResponseEntity<Void> delete(@PathVariable UUID id,
                                       @AuthenticationPrincipal AuthenticatedUser currentUser) {
        bankAccountService.delete(currentUser.id(), id);
        return ResponseEntity.status(HttpStatus.NO_CONTENT).build();
    }
}
