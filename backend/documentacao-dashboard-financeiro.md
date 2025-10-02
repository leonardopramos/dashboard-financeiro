# Dashboard Financeiro — Entregas até 02/10/2025

## Visão geral do serviço
- Aplicação Spring Boot 3.5.5 (Java 25) responsável pelas operações financeiras do ecossistema do TCC.
- Estrutura em camadas (`web`, `application`, `domain`, `infrastructure`) que separa controladores REST, regras de negócio e acesso a dados.
- Uso intensivo de Lombok para reduzir boilerplate e Bean Validation para validar DTOs de entrada.

## Principais funcionalidades entregues
- **Gestão de contas bancárias** (`BankAccountController`, `BankAccountService`): cadastro com verificação de duplicidade por usuário/instituição/agência/conta, busca por ID e listagem por usuário. O fluxo normaliza campos, aplica saldo inicial com escala de duas casas e retorna `Location` no padrão REST.
- **Gestão de transações** (`TransactionController`, `TransactionService`): lançamento de receitas, despesas e transferências; valida se a conta pertence ao usuário informado; atualiza o saldo da conta conforme o tipo (`TransactionType`). Disponibiliza consultas por ID, conta e usuário.
- **Tratamento consistente de erros** (`ApiExceptionHandler`): converte exceções de negócio e validação em respostas estruturadas (`ApiErrorResponse`) com timestamp e caminho da requisição.
- **Modelagem de domínio**: enums para tipo de conta (`AccountType`) e transação (`TransactionType`); exceções dedicadas para regras de negócio e recursos inexistentes.

## Persistência e migrações
- Persistência via Spring Data JPA sobre SQL Server, com entidades `BankAccountJpaEntity` e `TransactionJpaEntity` mapeadas para as tabelas `bank_accounts` e `transactions`.
- Liquibase habilitado (`application.yml`) com changelog mestre (`db/changelog/db.changelog-master.xml`) incluindo o script `0001_create_bank_and_transactions.sql`, que cria tabelas, índices e chave estrangeira com `ON DELETE CASCADE`.
- Estratégia de atualização de saldo executada via JPA dentro de uma mesma transação (salva transação e persiste saldo recalculado da conta).

## Segurança e integrações
- Configuração básica do Spring Security (`SecurityConfig`) que desabilita CSRF, libera endpoints públicos (`/api/v1/auth/**`, `/api/v1/dashboard`, `/api/v1/bank-accounts/**`, `/api/v1/transactions/**`) e deixa espaço para autenticação futura das demais rotas. Disponibiliza `BCryptPasswordEncoder` para consumo por outros componentes.
- Configuração prévia de OAuth2 Client para login com Google (variáveis `GOOGLE_CLIENT_ID` e `GOOGLE_CLIENT_SECRET`); ainda não há controladores ou filtros implementando o fluxo.
- Dependências de mensageria (`spring-kafka`) já adicionadas e propriedades de Kafka preparadas, embora nenhuma produção/consumo tenha sido codificada até a data indicada.

## Testes e observações técnicas
- Testes automatizados limitados a `DashboardFinanceiroApplicationTests` (verificação de contexto). Não há testes unitários ou de integração cobrindo as regras de negócio.
- Projeto configurado com Gradle, `spring-boot-devtools` para hot reload e driver oficial `mssql-jdbc` para runtime.

## Integração com docker-compose.yml
- O serviço utiliza os recursos definidos em `docker-compose.yml` na raiz do backend: `sqlserver` (banco principal) e o cluster Kafka (`zookeeper`, `kafka`, `kafka-ui`).
- O profile `docker` em `application.yml` ajusta a URL do datasource para consumir o SQL Server publicado pelo container `sqlserver` dentro da rede `dashboard-network`.
- A configuração Kafka (`bootstrap-servers: localhost:9092`) assume os brokers levantados pelo mesmo compose, viabilizando futuras integrações assíncronas entre microserviços do TCC.
