package com.dashboard_financeiro.Dashboard.Financeiro.web.controller;

import com.dashboard_financeiro.Dashboard.Financeiro.application.FinancialGoalService;
import com.dashboard_financeiro.Dashboard.Financeiro.security.AuthenticatedUser;
import com.dashboard_financeiro.Dashboard.Financeiro.web.dto.CreateFinancialGoalRequest;
import com.dashboard_financeiro.Dashboard.Financeiro.web.dto.FinancialGoalResponse;
import com.dashboard_financeiro.Dashboard.Financeiro.web.dto.UpdateFinancialGoalRequest;
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
@RequestMapping("/api/v1/goals")
@RequiredArgsConstructor
public class FinancialGoalController {

    private final FinancialGoalService goalService;

    @PostMapping
    public ResponseEntity<FinancialGoalResponse> create(@AuthenticationPrincipal AuthenticatedUser currentUser,
                                                        @Valid @RequestBody CreateFinancialGoalRequest request) {
        FinancialGoalResponse response = goalService.create(currentUser.id(), request);
        URI location = ServletUriComponentsBuilder.fromCurrentRequest()
                .path("/{id}")
                .buildAndExpand(response.id())
                .toUri();
        return ResponseEntity.created(location).body(response);
    }

    @GetMapping
    public ResponseEntity<List<FinancialGoalResponse>> list(@AuthenticationPrincipal AuthenticatedUser currentUser) {
        return ResponseEntity.ok(goalService.list(currentUser.id()));
    }

    @PutMapping("/{id}")
    public ResponseEntity<FinancialGoalResponse> update(@PathVariable UUID id,
                                                         @AuthenticationPrincipal AuthenticatedUser currentUser,
                                                         @Valid @RequestBody UpdateFinancialGoalRequest request) {
        FinancialGoalResponse response = goalService.update(currentUser.id(), id, request);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable UUID id,
                                       @AuthenticationPrincipal AuthenticatedUser currentUser) {
        goalService.delete(currentUser.id(), id);
        return ResponseEntity.status(HttpStatus.NO_CONTENT).build();
    }
}
