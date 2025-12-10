package com.dashboard_financeiro.Dashboard.Financeiro.web.controller;

import com.dashboard_financeiro.Dashboard.Financeiro.application.DashboardRange;
import com.dashboard_financeiro.Dashboard.Financeiro.application.FinancialGoalService;
import com.dashboard_financeiro.Dashboard.Financeiro.security.AuthenticatedUser;
import com.dashboard_financeiro.Dashboard.Financeiro.web.dto.AllocateGoalAmountRequest;
import com.dashboard_financeiro.Dashboard.Financeiro.web.dto.CreateFinancialGoalRequest;
import com.dashboard_financeiro.Dashboard.Financeiro.web.dto.FinancialGoalResponse;
import com.dashboard_financeiro.Dashboard.Financeiro.web.dto.GoalAllocationOverviewResponse;
import com.dashboard_financeiro.Dashboard.Financeiro.web.dto.UpdateFinancialGoalRequest;
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
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import java.net.URI;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/goals")
@RequiredArgsConstructor
@Tag(name = "Metas financeiras")
@SecurityRequirement(name = "bearerAuth")
public class FinancialGoalController {

    private final FinancialGoalService goalService;

    @PostMapping
    @Operation(
            summary = "Criar meta financeira",
            description = "Registra uma nova meta com valor alvo e prazo para o usuário autenticado."
    )
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
    @Operation(
            summary = "Listar metas do usuário",
            description = "Retorna todas as metas financeiras cadastradas pelo usuário autenticado."
    )
    public ResponseEntity<List<FinancialGoalResponse>> list(@AuthenticationPrincipal AuthenticatedUser currentUser) {
        return ResponseEntity.ok(goalService.list(currentUser.id()));
    }

    @GetMapping("/allocation")
    @Operation(
            summary = "Resumo de alocação",
            description = "Mostra quanto de cada meta já foi alocado/atingido em um período opcional."
    )
    public ResponseEntity<GoalAllocationOverviewResponse> allocationOverview(
            @AuthenticationPrincipal AuthenticatedUser currentUser,
            @RequestParam(name = "range", required = false) String rawRange) {
        DashboardRange range = DashboardRange.fromQueryValue(rawRange).orElse(null);
        return ResponseEntity.ok(goalService.getAllocationOverview(currentUser.id(), range));
    }

    @PostMapping("/{id}/allocate")
    @Operation(
            summary = "Alocar valor em meta",
            description = "Incrementa o valor alocado de uma meta específica do usuário."
    )
    public ResponseEntity<FinancialGoalResponse> allocate(@PathVariable UUID id,
                                                          @AuthenticationPrincipal AuthenticatedUser currentUser,
                                                          @Valid @RequestBody AllocateGoalAmountRequest request) {
        FinancialGoalResponse response = goalService.allocate(currentUser.id(), id, request);
        return ResponseEntity.ok(response);
    }

    @PutMapping("/{id}")
    @Operation(
            summary = "Atualizar meta financeira",
            description = "Edita nome, valor alvo ou datas de uma meta existente do usuário."
    )
    public ResponseEntity<FinancialGoalResponse> update(@PathVariable UUID id,
                                                         @AuthenticationPrincipal AuthenticatedUser currentUser,
                                                         @Valid @RequestBody UpdateFinancialGoalRequest request) {
        FinancialGoalResponse response = goalService.update(currentUser.id(), id, request);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{id}")
    @Operation(
            summary = "Excluir meta financeira",
            description = "Remove a meta informada e desaloca valores associados."
    )
    public ResponseEntity<Void> delete(@PathVariable UUID id,
                                       @AuthenticationPrincipal AuthenticatedUser currentUser) {
        goalService.delete(currentUser.id(), id);
        return ResponseEntity.status(HttpStatus.NO_CONTENT).build();
    }
}
