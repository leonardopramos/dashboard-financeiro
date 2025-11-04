package com.dashboard_financeiro.Dashboard.Financeiro.application;

import java.time.LocalDate;
import java.time.Period;
import java.time.temporal.ChronoUnit;
import java.util.Locale;
import java.util.Optional;

public enum DashboardRange {
    LAST_12_MONTHS("12M", Period.ofMonths(12)),
    LAST_6_MONTHS("6M", Period.ofMonths(6)),
    LAST_1_MONTH("1M", Period.ofMonths(1)),
    LAST_1_WEEK("1W", Period.ofWeeks(1));

    private final String queryValue;
    private final Period period;

    DashboardRange(String queryValue, Period period) {
        this.queryValue = queryValue;
        this.period = period;
    }

    public String getQueryValue() {
        return queryValue;
    }

    public Period getPeriod() {
        return period;
    }

    public LocalDate resolveStartDate(LocalDate endInclusive) {
        LocalDate candidate = endInclusive.minus(period);
        return candidate.isBefore(endInclusive) ? candidate.plusDays(1) : endInclusive;
    }

    public ChronoUnit preferredBucket() {
        if (period.getYears() > 0 || period.getMonths() >= 1) {
            return ChronoUnit.MONTHS;
        }
        return ChronoUnit.DAYS;
    }

    public String label(Locale locale) {
        return switch (this) {
            case LAST_12_MONTHS -> "Últimos 12 meses";
            case LAST_6_MONTHS -> "Últimos 6 meses";
            case LAST_1_MONTH -> "Últimos 30 dias";
            case LAST_1_WEEK -> "Últimos 7 dias";
        };
    }

    public static Optional<DashboardRange> fromQueryValue(String raw) {
        if (raw == null || raw.isBlank()) {
            return Optional.empty();
        }
        String normalized = raw.trim().toUpperCase(Locale.ROOT);
        for (DashboardRange value : values()) {
            if (value.queryValue.equals(normalized)) {
                return Optional.of(value);
            }
        }
        return Optional.empty();
    }
}
