package com.dashboard_financeiro.Dashboard.Financeiro.infrastructure.persistence.repository;

import com.dashboard_financeiro.Dashboard.Financeiro.infrastructure.persistence.entity.BankAccountJpaEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface BankAccountJpaRepository extends JpaRepository<BankAccountJpaEntity, UUID> {

    List<BankAccountJpaEntity> findByUserId(UUID userId);

    Optional<BankAccountJpaEntity> findByUserIdAndInstitutionNameAndAccountNumberAndAccountDigitAndBranchNumber(
            UUID userId,
            String institutionName,
            String accountNumber,
            String accountDigit,
            String branchNumber
    );
}
