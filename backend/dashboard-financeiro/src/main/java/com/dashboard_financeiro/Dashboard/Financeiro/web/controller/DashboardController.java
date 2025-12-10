package com.dashboard_financeiro.Dashboard.Financeiro.web.controller;

import com.dashboard_financeiro.Dashboard.Financeiro.application.DashboardRange;
import com.dashboard_financeiro.Dashboard.Financeiro.application.DashboardService;
import com.dashboard_financeiro.Dashboard.Financeiro.security.AuthenticatedUser;
import com.dashboard_financeiro.Dashboard.Financeiro.web.dto.DashboardOverviewResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.YearMonth;

@RestController
@RequestMapping("/api/v1/dashboard")
@RequiredArgsConstructor
@Tag(name = "Dashboard")
@SecurityRequirement(name = "bearerAuth")
public class DashboardController {

    private final DashboardService dashboardService;

    @GetMapping("/overview")
    @Operation(
            summary = "Consultar visão geral",
            description = "Retorna saldos, totais por tipo e evolução do período informado (ano/mês e range opcional)."
    )
    public ResponseEntity<DashboardOverviewResponse> overview(@AuthenticationPrincipal AuthenticatedUser currentUser,
                                                              @RequestParam(required = false) Integer year,
                                                              @RequestParam(required = false) Integer month,
                                                              @RequestParam(name = "range", required = false) String rawRange) {
        YearMonth reference = parseYearMonth(year, month);
        DashboardRange range = DashboardRange.fromQueryValue(rawRange).orElse(null);
        return ResponseEntity.ok(dashboardService.getOverview(currentUser.id(), reference, range));
    }

    private YearMonth parseYearMonth(Integer year, Integer month) {
        if (year == null || month == null) {
            return null;
        }

        if (month < 1 || month > 12) {
            throw new IllegalArgumentException("O mês deve estar entre 1 e 12");
        }

        return YearMonth.of(year, month);
    }
}
