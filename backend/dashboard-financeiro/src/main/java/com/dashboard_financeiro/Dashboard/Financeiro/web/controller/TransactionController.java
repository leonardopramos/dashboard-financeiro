package com.dashboard_financeiro.Dashboard.Financeiro.web.controller;

import com.dashboard_financeiro.Dashboard.Financeiro.application.TransactionService;
import com.dashboard_financeiro.Dashboard.Financeiro.security.AuthenticatedUser;
import com.dashboard_financeiro.Dashboard.Financeiro.web.dto.CreateTransactionRequest;
import com.dashboard_financeiro.Dashboard.Financeiro.web.dto.TransactionResponse;
import com.dashboard_financeiro.Dashboard.Financeiro.web.dto.UpdateTransactionRequest;
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
@RequestMapping("/api/v1/transactions")
@RequiredArgsConstructor
@Tag(name = "Transações")
@SecurityRequirement(name = "bearerAuth")
public class TransactionController {

    private final TransactionService transactionService;

    @PostMapping
    @Operation(
            summary = "Registrar transação",
            description = "Cria uma nova transação (receita ou despesa) vinculada ao usuário autenticado."
    )
    public ResponseEntity<TransactionResponse> create(@AuthenticationPrincipal AuthenticatedUser currentUser,
                                                      @Valid @RequestBody CreateTransactionRequest request) {
        var response = transactionService.register(currentUser.id(), request);
        URI location = ServletUriComponentsBuilder.fromCurrentRequest()
                .path("/{id}")
                .buildAndExpand(response.id())
                .toUri();
        return ResponseEntity.created(location).body(response);
    }

    @GetMapping("/{id}")
    @Operation(
            summary = "Buscar transação por id",
            description = "Retorna os detalhes de uma transação específica do usuário autenticado."
    )
    public ResponseEntity<TransactionResponse> getById(@PathVariable UUID id,
                                                       @AuthenticationPrincipal AuthenticatedUser currentUser) {
        return ResponseEntity.ok(transactionService.findById(currentUser.id(), id));
    }

    @PutMapping("/{id}")
    @Operation(
            summary = "Atualizar transação",
            description = "Altera dados de uma transação existente, preservando a associação com o usuário."
    )
    public ResponseEntity<TransactionResponse> update(@PathVariable UUID id,
                                                      @AuthenticationPrincipal AuthenticatedUser currentUser,
                                                      @Valid @RequestBody UpdateTransactionRequest request) {
        return ResponseEntity.ok(transactionService.update(currentUser.id(), id, request));
    }

    @GetMapping("/bank-account/{bankAccountId}")
    @Operation(
            summary = "Listar por conta bancária",
            description = "Lista todas as transações vinculadas à conta bancária informada do usuário autenticado."
    )
    public ResponseEntity<List<TransactionResponse>> getByBankAccount(@PathVariable UUID bankAccountId,
                                                                       @AuthenticationPrincipal AuthenticatedUser currentUser) {
        return ResponseEntity.ok(transactionService.findByBankAccount(currentUser.id(), bankAccountId));
    }

    @GetMapping
    @Operation(
            summary = "Listar transações do usuário",
            description = "Retorna todas as transações do usuário autenticado."
    )
    public ResponseEntity<List<TransactionResponse>> getByUser(@AuthenticationPrincipal AuthenticatedUser currentUser) {
        return ResponseEntity.ok(transactionService.findByUser(currentUser.id()));
    }

    @DeleteMapping("/{id}")
    @Operation(
            summary = "Excluir transação",
            description = "Remove uma transação do usuário autenticado e deleta suas relações."
    )
    public ResponseEntity<Void> delete(@PathVariable UUID id,
                                       @AuthenticationPrincipal AuthenticatedUser currentUser) {
        transactionService.delete(currentUser.id(), id);
        return ResponseEntity.status(HttpStatus.NO_CONTENT).build();
    }
}
