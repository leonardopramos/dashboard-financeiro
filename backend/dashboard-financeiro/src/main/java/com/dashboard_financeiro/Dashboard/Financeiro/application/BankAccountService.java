package com.dashboard_financeiro.Dashboard.Financeiro.application;

import com.dashboard_financeiro.Dashboard.Financeiro.domain.exception.BusinessException;
import com.dashboard_financeiro.Dashboard.Financeiro.domain.exception.ResourceNotFoundException;
import com.dashboard_financeiro.Dashboard.Financeiro.infrastructure.persistence.entity.BankAccountJpaEntity;
import com.dashboard_financeiro.Dashboard.Financeiro.infrastructure.persistence.repository.BankAccountJpaRepository;
import com.dashboard_financeiro.Dashboard.Financeiro.web.dto.BankAccountResponse;
import com.dashboard_financeiro.Dashboard.Financeiro.web.dto.CreateBankAccountRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class BankAccountService {

    private final BankAccountJpaRepository repository;

    @Transactional
    public BankAccountResponse register(UUID userId, CreateBankAccountRequest request) {
        String institutionName = request.institutionName().trim();
        String branchNumber = request.branchNumber().trim();
        String accountNumber = request.accountNumber().trim();
        String accountDigit = request.accountDigit() != null ? request.accountDigit().trim() : "";

        repository.findByUserIdAndInstitutionNameAndAccountNumberAndAccountDigitAndBranchNumber(
                userId,
                institutionName,
                accountNumber,
                accountDigit,
                branchNumber
        ).ifPresent(existing -> {
            throw new BusinessException("Conta bancária já cadastrada para este usuário");
        });

        BigDecimal initialBalance = request.initialBalance() != null
                ? request.initialBalance().setScale(2, RoundingMode.HALF_UP)
                : BigDecimal.ZERO.setScale(2, RoundingMode.HALF_UP);

        var entity = BankAccountJpaEntity.builder()
                .id(UUID.randomUUID())
                .userId(userId)
                .institutionName(institutionName)
                .branchNumber(branchNumber)
                .accountNumber(accountNumber)
                .accountDigit(accountDigit)
                .accountType(request.accountType())
                .nickname(request.nickname() != null ? request.nickname().trim() : null)
                .currentBalance(initialBalance)
                .build();

        return BankAccountResponse.from(repository.save(entity));
    }

    @Transactional(readOnly = true)
    public BankAccountJpaEntity getEntity(UUID userId, UUID id) {
        BankAccountJpaEntity entity = repository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Conta bancária não encontrada"));

        if (!entity.getUserId().equals(userId)) {
            throw new BusinessException("Conta bancária não pertence ao usuário informado");
        }

        return entity;
    }

    @Transactional
    public void save(BankAccountJpaEntity entity) {
        repository.save(entity);
    }

    @Transactional(readOnly = true)
    public BankAccountResponse findById(UUID userId, UUID id) {
        return BankAccountResponse.from(getEntity(userId, id));
    }

    @Transactional(readOnly = true)
    public List<BankAccountResponse> findByUser(UUID userId) {
        return repository.findByUserId(userId)
                .stream()
                .map(BankAccountResponse::from)
                .toList();
    }
}
