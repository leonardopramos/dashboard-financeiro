package com.dashboard_financeiro.Dashboard.Financeiro.web.controller;

import com.dashboard_financeiro.Dashboard.Financeiro.application.TransactionService;
import com.dashboard_financeiro.Dashboard.Financeiro.security.AuthenticatedUser;
import com.dashboard_financeiro.Dashboard.Financeiro.web.dto.CreateTransactionRequest;
import com.dashboard_financeiro.Dashboard.Financeiro.web.dto.TransactionResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
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
public class TransactionController {

    private final TransactionService transactionService;

    @PostMapping
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
    public ResponseEntity<TransactionResponse> getById(@PathVariable UUID id,
                                                       @AuthenticationPrincipal AuthenticatedUser currentUser) {
        return ResponseEntity.ok(transactionService.findById(currentUser.id(), id));
    }

    @GetMapping("/bank-account/{bankAccountId}")
    public ResponseEntity<List<TransactionResponse>> getByBankAccount(@PathVariable UUID bankAccountId,
                                                                       @AuthenticationPrincipal AuthenticatedUser currentUser) {
        return ResponseEntity.ok(transactionService.findByBankAccount(currentUser.id(), bankAccountId));
    }

    @GetMapping
    public ResponseEntity<List<TransactionResponse>> getByUser(@AuthenticationPrincipal AuthenticatedUser currentUser) {
        return ResponseEntity.ok(transactionService.findByUser(currentUser.id()));
    }
}
