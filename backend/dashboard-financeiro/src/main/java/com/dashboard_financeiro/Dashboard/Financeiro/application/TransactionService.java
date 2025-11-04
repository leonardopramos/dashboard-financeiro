package com.dashboard_financeiro.Dashboard.Financeiro.application;

import com.dashboard_financeiro.Dashboard.Financeiro.domain.exception.ResourceNotFoundException;
import com.dashboard_financeiro.Dashboard.Financeiro.domain.model.TransactionType;
import com.dashboard_financeiro.Dashboard.Financeiro.infrastructure.persistence.entity.BankAccountJpaEntity;
import com.dashboard_financeiro.Dashboard.Financeiro.infrastructure.persistence.entity.CategoryJpaEntity;
import com.dashboard_financeiro.Dashboard.Financeiro.infrastructure.persistence.entity.TransactionJpaEntity;
import com.dashboard_financeiro.Dashboard.Financeiro.infrastructure.persistence.repository.TransactionJpaRepository;
import com.dashboard_financeiro.Dashboard.Financeiro.messaging.DomainEventPublisher;
import com.dashboard_financeiro.Dashboard.Financeiro.web.dto.CreateTransactionRequest;
import com.dashboard_financeiro.Dashboard.Financeiro.web.dto.UpdateTransactionRequest;
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
    private final CategoryService categoryService;
    private final DomainEventPublisher eventPublisher;

    @Transactional
    public TransactionResponse register(UUID userId, CreateTransactionRequest request) {
        var bankAccount = bankAccountService.getEntity(userId, request.bankAccountId());

        var amount = request.amount().setScale(2, RoundingMode.HALF_UP);

        CategoryJpaEntity category = null;
        if (request.categoryId() != null) {
            category = categoryService.getEntity(userId, request.categoryId());
        }

        BankAccountJpaEntity managedBankAccount = bankAccount;
        var entity = TransactionJpaEntity.builder()
                .id(UUID.randomUUID())
                .bankAccount(managedBankAccount)
                .category(category)
                .type(request.type())
                .amount(amount)
                .transactionDate(request.transactionDate())
                .description(request.description())
                .notes(request.notes())
                .build();

        applyBalanceChange(managedBankAccount, entity.getType(), entity.getAmount());

        var saved = transactionRepository.save(entity);
        bankAccountService.save(managedBankAccount);
        eventPublisher.publishTransactionCreated(saved);

        return TransactionResponse.from(saved);
    }

    @Transactional(readOnly = true)
    public TransactionResponse findById(UUID userId, UUID id) {
        return transactionRepository.findByIdAndBankAccountUserId(id, userId)
                .map(TransactionResponse::from)
                .orElseThrow(() -> new ResourceNotFoundException("Transação não encontrada"));
    }

    @Transactional
    public TransactionResponse update(UUID userId, UUID transactionId, UpdateTransactionRequest request) {
        TransactionJpaEntity transaction = getEntity(userId, transactionId);

        BankAccountJpaEntity originalAccount = transaction.getBankAccount();
        var originalType = transaction.getType();
        var originalAmount = transaction.getAmount();

        reverseBalanceChange(originalAccount, originalType, originalAmount);

        BankAccountJpaEntity targetAccount = originalAccount;
        if (!originalAccount.getId().equals(request.bankAccountId())) {
            targetAccount = bankAccountService.getEntity(userId, request.bankAccountId());
        }

        CategoryJpaEntity category = null;
        if (request.categoryId() != null) {
            category = categoryService.getEntity(userId, request.categoryId());
        }

        var amount = request.amount().setScale(2, RoundingMode.HALF_UP);

        transaction.setBankAccount(targetAccount);
        transaction.setType(request.type());
        transaction.setAmount(amount);
        transaction.setTransactionDate(request.transactionDate());
        transaction.setDescription(request.description());
        transaction.setCategory(category);
        transaction.setNotes(request.notes());

        applyBalanceChange(targetAccount, transaction.getType(), transaction.getAmount());

        TransactionJpaEntity saved = transactionRepository.save(transaction);

        if (originalAccount.getId().equals(targetAccount.getId())) {
            bankAccountService.save(targetAccount);
        } else {
            bankAccountService.save(originalAccount);
            bankAccountService.save(targetAccount);
        }

        return TransactionResponse.from(saved);
    }

    @Transactional
    public void delete(UUID userId, UUID transactionId) {
        TransactionJpaEntity transaction = getEntity(userId, transactionId);

        BankAccountJpaEntity bankAccount = transaction.getBankAccount();
        reverseBalanceChange(bankAccount, transaction.getType(), transaction.getAmount());

        transactionRepository.delete(transaction);
        bankAccountService.save(bankAccount);
    }

    @Transactional(readOnly = true)
    public List<TransactionResponse> findByBankAccount(UUID userId, UUID bankAccountId) {
        bankAccountService.getEntity(userId, bankAccountId);
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

    private TransactionJpaEntity getEntity(UUID userId, UUID transactionId) {
        return transactionRepository.findByIdAndBankAccountUserId(transactionId, userId)
                .orElseThrow(() -> new ResourceNotFoundException("Transação não encontrada"));
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

    private void reverseBalanceChange(BankAccountJpaEntity bankAccount, TransactionType type, BigDecimal amount) {
        BigDecimal current = bankAccount.getCurrentBalance();
        if (current == null) {
            current = BigDecimal.ZERO.setScale(2, RoundingMode.HALF_UP);
        }

        current = current.setScale(2, RoundingMode.HALF_UP);

        BigDecimal value = amount.setScale(2, RoundingMode.HALF_UP);

        if (type == TransactionType.EXPENSE || type == TransactionType.TRANSFER_OUT) {
            bankAccount.setCurrentBalance(current.add(value));
        } else {
            bankAccount.setCurrentBalance(current.subtract(value));
        }
    }
}
