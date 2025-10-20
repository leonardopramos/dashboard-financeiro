package com.dashboard_financeiro.Dashboard.Financeiro.messaging;

import com.dashboard_financeiro.Dashboard.Financeiro.application.FinancialGoalService.GoalStatusChange;
import com.dashboard_financeiro.Dashboard.Financeiro.config.KafkaTopicsProperties;
import com.dashboard_financeiro.Dashboard.Financeiro.infrastructure.persistence.entity.TransactionJpaEntity;
import com.dashboard_financeiro.Dashboard.Financeiro.messaging.event.GoalStatusChangedEvent;
import com.dashboard_financeiro.Dashboard.Financeiro.messaging.event.TransactionCreatedEvent;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Component;

import java.util.List;

@Slf4j
@Component
@RequiredArgsConstructor
public class DomainEventPublisher {

    private final KafkaTemplate<String, Object> kafkaTemplate;
    private final KafkaTopicsProperties topics;

    public void publishTransactionCreated(TransactionJpaEntity transaction) {
        TransactionCreatedEvent event = new TransactionCreatedEvent(
                transaction.getId(),
                transaction.getBankAccount().getUserId(),
                transaction.getBankAccount().getId(),
                transaction.getType().name(),
                transaction.getAmount(),
                transaction.getTransactionDate(),
                transaction.getDescription(),
                transaction.getCategory() != null ? transaction.getCategory().getId().toString() : null,
                transaction.getCategory() != null ? transaction.getCategory().getName() : null,
                transaction.getCreatedAt()
        );

        kafkaTemplate.send(topics.transactionEvents(), event.transactionId().toString(), event)
                .whenComplete((result, ex) -> {
                    if (ex != null) {
                        log.error("Falha ao publicar evento de transação {}: {}", event.transactionId(), ex.getMessage(), ex);
                    } else {
                        log.debug("Evento de transação {} publicado com sucesso", event.transactionId());
                    }
                });
    }

    public void publishGoalStatusChanges(List<GoalStatusChange> changes) {
        for (GoalStatusChange change : changes) {
            GoalStatusChangedEvent event = new GoalStatusChangedEvent(
                    change.goal().getId(),
                    change.goal().getUserId(),
                    change.goal().getName(),
                    change.goal().getType().name(),
                    change.goal().getStatus().name(),
                    change.previousStatus().name(),
                    change.goal().getCurrentAmount(),
                    change.goal().getTargetAmount(),
                    change.goal().getStartDate(),
                    change.goal().getEndDate(),
                    change.goal().getCategory() != null ? change.goal().getCategory().getId().toString() : null,
                    change.goal().getCategory() != null ? change.goal().getCategory().getName() : null,
                    change.goal().getAchievedAt(),
                    change.goal().getUpdatedAt()
            );

            kafkaTemplate.send(topics.goalEvents(), event.goalId().toString(), event)
                    .whenComplete((result, ex) -> {
                        if (ex != null) {
                            log.error("Falha ao publicar evento de meta {}: {}", event.goalId(), ex.getMessage(), ex);
                        } else {
                            log.debug("Evento de meta {} publicado com sucesso", event.goalId());
                        }
                    });
        }
    }
}
