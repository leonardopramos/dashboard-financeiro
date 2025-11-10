# Dashboard Financeiro — backend de operações

## Visão geral
- Spring Boot 3.5.5 (Java 25) atuando como orquestrador das rotas protegidas do domínio financeiro.
- Estrutura em camadas (`web`, `application`, `domain`, `infrastructure`, `security`, `messaging`) isolando controladores, serviços, regras de negócio, persistência e integração assíncrona.
- Autenticação obrigatória via JWT em todos os endpoints (`SecurityConfig` + filtro `JwtAuthenticationFilter`). O usuário autenticado é resolvido automaticamente e propagado para os serviços.

## Linha do tempo de desenvolvimento
- 17/09/2025 — Commit "Adição dos demais micro serviços do backend" adicionou o projeto `dashboard-financeiro` com build Gradle, `application.yml` inicial e suporte ao `docker-compose.yml`.
- 02/10/2025 — Commit "Criação de persistencia de conta bancaria e de transações" implementou serviços, controladores, entidades JPA, validações e o `ApiExceptionHandler` para contas bancárias e transações.
- 02/10/2025 — Commit "Ajustes e adicao de documentacao" consolidou a migração `0001_create_bank_and_transactions.sql` no Liquibase e incluiu a coleção Insomnia `insomnia/dashboard-financeiro-export.yaml`.

## Funcionalidades expostas
- **Contas bancárias** (`BankAccountController`/`Service`): criação, listagem do usuário autenticado e consulta detalhada. Normalização de campos, validação de duplicidade e atualização de saldo transacional.
- **Transações financeiras** (`TransactionController`/`Service`): lançamentos de receitas, despesas, transferências e movimentações categorizadas. A conta é validada contra o dono, o saldo é recalculado e eventos Kafka são emitidos após o commit.
- **Categorias personalizadas** (`CategoryController`/`Service`): CRUD de categorias por usuário, com reativação automática e validação de uso ativo antes de associar transações.
- **Metas financeiras** (`FinancialGoalController`/`Service`): criação, atualização, desativação e acompanhamento de metas do tipo `SAVINGS` e `EXPENSE_LIMIT`. O progresso é recalculado a cada transação elegível.
- **Dashboard consolidado** (`DashboardController`/`DashboardService`): fornece visão mensal com totais de receitas/despesas, saldo agregado nas contas, evolução dos últimos 6 meses, breakdown por categoria e snapshot das metas ativas.

## Persistência e migrações
- MySQL 8 com JPA/Hibernate; Liquibase controla o schema via `db/changelog/db.changelog-master.xml`.
- `0001_create_bank_and_transactions.sql`: tabelas `bank_accounts` e `transactions`.
- `0002_create_categories_and_goals.sql`: tabelas `categories` e `financial_goals`, além do relacionamento `transactions.category_id`.
- Índices otimizando busca por usuário e integridade de chaves estrangeiras (`categories`, `financial_goals`, `transactions`).

## Integração assíncrona (Kafka)
- Configuração via `KafkaConfig` + `KafkaTopicsProperties` apontando para `transactions.events` e `goals.events`.
- `TransactionService` publica `TransactionCreatedEvent` após o commit, garantindo consistência.
- Quando o progresso de metas altera status (`FinancialGoalService`), eventos `GoalStatusChangedEvent` são enviados para consumo do serviço de notificações.

## Segurança
- Filtro JWT valida assinatura HS256, popula `AuthenticatedUser` e impede acesso anônimo (exceto `/actuator/**`).
- DTOs de entrada removem `userId`; o usuário autenticado é extraído do token e reutilizado nos serviços.
- Tratamento consistente de erros (`ApiExceptionHandler`) para exceções de negócio, validação e argumentos inválidos.

## Testes e observações
- Mantém `DashboardFinanceiroApplicationTests` (carregamento de contexto). Cobertura adicional recomendada para serviços de categorias, metas e agregações.
- Projeto Gradle com `spring-boot-devtools`, `spring-kafka-test` e suporte a profiles (`docker`) para execução integrada com Docker Compose (`mysql`, `kafka`, `kafka-ui`).
