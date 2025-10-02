package com.dashboard_financeiro.Dashboard.Financeiro.application;

import com.dashboard_financeiro.Dashboard.Financeiro.domain.exception.BusinessException;
import com.dashboard_financeiro.Dashboard.Financeiro.domain.exception.ResourceNotFoundException;
import com.dashboard_financeiro.Dashboard.Financeiro.domain.model.TransactionType;
import com.dashboard_financeiro.Dashboard.Financeiro.infrastructure.persistence.entity.BankAccountJpaEntity;
import com.dashboard_financeiro.Dashboard.Financeiro.infrastructure.persistence.entity.TransactionJpaEntity;
import com.dashboard_financeiro.Dashboard.Financeiro.infrastructure.persistence.repository.TransactionJpaRepository;
import com.dashboard_financeiro.Dashboard.Financeiro.web.dto.CreateTransactionRequest;
import com.dashboard_financeiro.Dashboard.Financeiro.web.dto.TransactionResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class TransactionService {

    private final TransactionJpaRepository transactionRepository;
    private final BankAccountService bankAccountService;

    @Transactional
    public TransactionResponse register(CreateTransactionRequest request) {
        var bankAccount = bankAccountService.getEntity(request.bankAccountId());

        if (!bankAccount.getUserId().equals(request.userId())) {
            throw new BusinessException("Conta bancária não pertence ao usuário informado");
        }

        var amount = request.amount().setScale(2, RoundingMode.HALF_UP);

        BankAccountJpaEntity managedBankAccount = bankAccount;
        var entity = TransactionJpaEntity.builder()
                .id(UUID.randomUUID())
                .bankAccount(managedBankAccount)
                .type(request.type())
                .amount(amount)
                .transactionDate(request.transactionDate())
                .description(request.description())
                .category(request.category())
                .notes(request.notes())
                .build();

        applyBalanceChange(managedBankAccount, entity.getType(), entity.getAmount());

        var saved = transactionRepository.save(entity);
        bankAccountService.save(managedBankAccount);

        return TransactionResponse.from(saved);
    }

    @Transactional(readOnly = true)
    public TransactionResponse findById(UUID id) {
        return transactionRepository.findById(id)
                .map(TransactionResponse::from)
                .orElseThrow(() -> new ResourceNotFoundException("Transação não encontrada"));
    }

    @Transactional(readOnly = true)
    public List<TransactionResponse> findByBankAccount(UUID bankAccountId) {
        return transactionRepository.findByBankAccountId(bankAccountId)
                .stream()
                .map(TransactionResponse::from)
                .toList();
    }

    @Transactional(readOnly = true)
    public List<TransactionResponse> findByUser(UUID userId) {
        return transactionRepository.findByBankAccountUserId(userId)
                .stream()
                .map(TransactionResponse::from)
                .toList();
    }

    private void applyBalanceChange(BankAccountJpaEntity bankAccount, TransactionType type, BigDecimal amount) {
        BigDecimal current = bankAccount.getCurrentBalance();
        if (current == null) {
            current = BigDecimal.ZERO.setScale(2, RoundingMode.HALF_UP);
        }

        current = current.setScale(2, RoundingMode.HALF_UP);

        BigDecimal value = amount.setScale(2, RoundingMode.HALF_UP);

        if (type == TransactionType.EXPENSE || type == TransactionType.TRANSFER_OUT) {
            bankAccount.setCurrentBalance(current.subtract(value));
        } else {
            bankAccount.setCurrentBalance(current.add(value));
        }
    }
}
