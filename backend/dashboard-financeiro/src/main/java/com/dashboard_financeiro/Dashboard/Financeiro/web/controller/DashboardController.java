package com.dashboard_financeiro.Dashboard.Financeiro.web.controller;

import com.dashboard_financeiro.Dashboard.Financeiro.application.DashboardService;
import com.dashboard_financeiro.Dashboard.Financeiro.security.AuthenticatedUser;
import com.dashboard_financeiro.Dashboard.Financeiro.web.dto.DashboardOverviewResponse;
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
public class DashboardController {

    private final DashboardService dashboardService;

    @GetMapping("/overview")
    public ResponseEntity<DashboardOverviewResponse> overview(@AuthenticationPrincipal AuthenticatedUser currentUser,
                                                              @RequestParam(required = false) Integer year,
                                                              @RequestParam(required = false) Integer month) {
        YearMonth reference = parseYearMonth(year, month);
        return ResponseEntity.ok(dashboardService.getOverview(currentUser.id(), reference));
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
